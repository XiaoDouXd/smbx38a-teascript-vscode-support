// ================================================================
// 语法分析模板构建相关类的设计
// ================================================================

import { TextDocument } from "vscode-languageserver-textdocument";
import { Position, CompletionItem, Diagnostic } from "vscode-languageserver";
import linq from "linq";

type DocumentCompletionCallback = (match:MatchResult) => CompletionItem[];
type PatternMatchedCallback = (patternMatch: PatternMatchResult) => void;
type ScopeMatchedCallback = (scopeMatch: ScopeMatchResult) => void;
type DocumentDiagnoseCallback = (unMatched: UnMatchedText) => Diagnostic[];
type PatternItemDictionary = { [key: string]: (pattern: GrammarPattern) => PatternItem };

// ----------------------------------------------------------------
/** 匹配模板基类: 是所有词汇、段落捕获模板的基类 */
abstract class PatternItem
{
    /** 模板名称 */
    name = "pattern";

    /** 严格匹配 */
    strict = false;
    /** 可忽略的 */
    ignorable = false;
    /** 多结果 */
    multi = false;
    /** 语法模板 */
    pattern: GrammarPattern;
    /** 父模板 */
    parent?: OrderedPatternSet;    
    /** 排除字段 */
    ignore?: RegExp;

    /**
     * 匹配方法
     * @param doc 待匹配的文本
     * @param startOffset 起始点偏移量
     * @return 匹配结果
     */
    abstract match(doc: TextDocument, startOffset: number): MatchResult;
    /**
     * @param pattern 语法模板
     * @param ignorable 是否可忽略
     */
    constructor(pattern: GrammarPattern, ignorable = false)
    {
        this.pattern = pattern;
        this.ignorable = ignorable;

        if (pattern.ignore) this.ignore = pattern.ignore;
    }
    toString(): string
    {
        return this.ignorable ? `[${this.name}]` : `<${this.name}>`;
    }
}
/** 空模板: 用于一个段落内的所有捕获空字符 */
class EmptyPattern extends PatternItem
{
    name = "space";
    constructor(pattern: GrammarPattern, ignorable = false)
    {
        super(pattern, ignorable);
    }
    /**
     * 分词
     * @param doc 待匹配的文本
     * @param startOffset 开始位置
     * @param crossLine 是否跨行
     * @returns 正则表达式执行组
     */
    static skipEmpty(doc: TextDocument, startOffset: number, crossLine = false): RegExpExecArray
    {
        // 这俩正则表达式可以匹配语句中的空格
        // 若 crossLine == true 则还可以匹配换行符
        const reg = crossLine ?
            /(((?:\s|\/\*(?!\/).*?\*\/)*)(\/\/.*[\r]?[\n]?)?)*/
            :
            /((?:[ \t]|\/\*(?!\/).*?\*\/)*)?/;
        const text = doc.getText().substring(startOffset);
        const match = reg.exec(text);

        // match.index 是匹配结果的第一个字符在整一段文字中的索引位置
        // match[n] 对应第n个捕获组的匹配结果
        // 由上所以 match[0] 为整个表达式的匹配结果
        // 若匹配失败则 match == null
        if (match.index > 0)
            return null;
        return match;
    }
    /**
     * 是否为空串
     * @param text 待检查的字符串
     * @param crossLine 是否跨行
     * @returns 
     */
    static isEmpty(text: string,crossLine = false)
    {
        const reg = crossLine ?
            /^(((?:\s|\/\*(?!\/).*?\*\/)*)(\/\/.*[\r]?[\n]?)?)*$/
            :
            /^((?:[\t]|\/\*(?!\/).*?\*\/)*)?$/;
        return reg.test(text);
    }
    match(doc: TextDocument, startOffset: number): MatchResult
    {
        // 捕获到的所有空字符
        const empty = EmptyPattern.skipEmpty(doc, startOffset, this.pattern.crossLine);

        // ---------------------------------------------
        // 构建捕获结果
        const match = new MatchResult(doc, this);
        match.startOffset = startOffset;
        if (empty && empty[0].length > 0)
        {
            // 捕获到了东西(虽然只是空格之类的...)
            match.endOffset = startOffset + empty[0].length;
            match.matched = true;
        }
        else
        {
            // 啥都没捕获到
            match.endOffset = startOffset;
            match.matched = false;
        }
        return match;
    }
}
/** 正则表达式模板: 未定义正则表达式, 需要在构造时指出 */
class RegExpPattern extends PatternItem
{
    name = "regExp";
    /** 相关正则表达式 */
    regExp: RegExp;

    /**
     * @param reg 正则表达式
     */
    constructor(pattern: GrammarPattern, reg: RegExp, ignorable = false)
    {
        super(pattern, ignorable);
        this.regExp = reg;
    }
    match(doc: TextDocument, startOffset: number): MatchResult
    {
        // 检查段前的空字符
        const skip = EmptyPattern.skipEmpty(doc, startOffset, this.pattern.crossLine);
        if (skip)
            // 跳过空字符
            startOffset += skip[0].length;
        
        // 截取后面的字符
        const text = doc.getText().substring(startOffset);

        // 通过该模板默认的正则表达式匹配
        const match = new MatchResult(doc, this);
        
        // 匹配排除模板
        if (this.ignore && this.ignore.exec(text)[0] == text)
        {
            match.endOffset = startOffset;
            match.matched = false;
            return match;
        }

        const regMatch = this.regExp.exec(text);
        match.startOffset = startOffset;
        if (!regMatch || regMatch.index !== 0)
        {
            match.endOffset = startOffset;
            match.matched = false;
        }
        else
        {
            match.endOffset = startOffset + regMatch[0].length;
            match.matched = true;
        }
        return match;
    }
}
/** 重命名模板: 可以以其它一些模板为原型复制出一些新模板 */
class NamedPattern extends PatternItem
{
    patternItem: PatternItem;

    /**
     * @param name 名称
     * @param patternItem 要复制的模板
     */
    constructor(pattern: GrammarPattern, name: string, patternItem: PatternItem)
    {
        super(pattern, patternItem.ignorable);
        this.name = name;
        this.patternItem = patternItem;
    }
    match(doc: TextDocument, startOffset: number): MatchResult
    {
        const match = this.patternItem.match(doc, startOffset);
        match.patternName = this.name;
        
        return match;
    }
}
/** 文本模板: 将连续文本根据其中的+-*\/.()...等符号进行划分并匹配 */
class TextPattern extends RegExpPattern
{
    text: string;
    currentIdx = 0;
    get ignoreCase() { return this.regExp.ignoreCase; }
    /**
     * @param text 文本
     * @param ignoreCase 是否忽略大小写
     */
    constructor(pattern: GrammarPattern, text: string, ignorable = false, ignoreCase = false)
    {
        // 将文本分割开, 用\$&替换掉特殊符号
        super(pattern, new RegExp(text.replace(/[|\\{}()[\]^$+*?.]/g, '\\$&'), ignoreCase ? "i" : ""), ignorable);
        this.text = text;
        this.name = text;
    }
}
/** 字符串模板: 匹配所有被两个双引号夹住形式的字符串 */
class StringPattern extends RegExpPattern
{
    name = "string";
    begin = false;
    slash = false;
    end = false;
    constructor(pattern: GrammarPattern, ignorable = false)
    {
        // 匹配两个双引号夹起来的形状
        super(pattern, /"([^\\"]|\\\S|\\")*"/, ignorable);
    }
}
/** 数字模板: 匹配所有数字 */
class NumberPattern extends RegExpPattern
{
    name = "number";
    constructor(pattern: GrammarPattern, ignorable = false)
    {
        // 匹配所有数字
        super(pattern, /[+-]?[0-9]+\.?[0-9]*/, ignorable);
    }
}
/** 命名模板: 匹配所有的变量、函数、结构体等名称 */
class IdentifierPattern extends RegExpPattern
{
    name = "identifier";
    constructor(pattern: GrammarPattern, ignorable = false)
    {
        super(pattern, /[_a-zA-Z][_a-zA-Z0-9]*/, ignorable);
    }
}

/** 依序模板组: 若中间有些模板无法匹配则后面的内容就都不匹配了 */
class OrderedPatternSet extends PatternItem
{
    name = "nest";
    /** 子模板集 */
    subPatterns: PatternItem[] = [];
    /** 当前节点的id */
    currentIdx = 0;
    /** 子模板的个数 */
    get count() { return this.subPatterns.length; }

    /**
     * 添加子模板
     * @param patternItem 待添加的子模板
     */
    addSubPattern(patternItem: PatternItem)
    {
        this.subPatterns.push(patternItem);
    }
    /**
     * 依序模板组的匹配
     * 划定作用域的准备工作
     */
    match(doc: TextDocument, startOffset: number): MatchResult
    {
        // 创建匹配结果的容器
        const match = new MatchResult(doc, this);
        match.startOffset = startOffset;

        try 
        {
            // 遍历每一个子模板
            for (let i = 0; i < this.subPatterns.length; i++)
            {
                // 尝试匹配
                const subMatch = this.subPatterns[i].match(doc, startOffset);
                if (!subMatch.matched)
                {
                    // 其实这段就是在说:
                    // 若本段落有子段落并且现在已经离开了该子段落
                    // 则标记该子段落的结尾
                    // 如果为严格匹配且当前的匹配结果(可能是与兄弟模板匹配的结果)不为空
                    if (this.strict && !EmptyPattern.isEmpty(subMatch.text))
                    {
                        // 为匹配结果加上新的子段落
                        match.addChildren(subMatch);
                        match.endOffset = subMatch.endOffset;
                        match.matched = false;
                        return match;
                    }
                    // 如果该段可忽略
                    if (this.subPatterns[i].ignorable)
                        continue;
                    
                    //
                    match.addChildren(subMatch);
                    match.endOffset = subMatch.endOffset;
                    match.matched = false;
                    return match;
                }

                // 若匹配上了部分关键字, 则后移开始指针
                match.addChildren(subMatch);
                startOffset = subMatch.endOffset;
                if (this.subPatterns[i].multi)
                    i--;
            }

            // 若子段落为没有
            if (match.children.length === 0)
            {
                match.endOffset = match.startOffset + 1;
                match.matched = false;
            }
            else
            {
                match.endOffset = match.children[match.children.length - 1].endOffset;
                match.startOffset = match.children[0].startOffset;
                match.matched = true;
            }
        }
        catch (ex)
        {
            console.error(ex);
        }
        return match;
    }
    toString()
    {
        const str = super.toString() + "\r\n" + this.subPatterns.map(pattern => pattern.toString()).join("\r\n").split(/\r\n/g).map(str => "\t" + str).join("\r\n");
        return str;
    }
}
/** 选择模板树: 跳过无法匹配的模板继续往后面匹配 */
class OptionalPatternSet extends OrderedPatternSet
{
    name = "optional";

    /**
     * 选择模板树的匹配
     */
    match(doc: TextDocument, startOffset: number): MatchResult
    {
        const match = new PatternMatchResult(doc, this);
        match.startOffset = startOffset;
        const failedMatches: MatchResult[] = [];
        for (let i = 0; i < this.subPatterns.length; i++)
        {
            const subMatch = this.subPatterns[i].match(doc, startOffset);
            if (!subMatch.matched)
            {
                failedMatches.push(subMatch);
                continue;
            }
            match.addChildren(subMatch);
            break;
        }
        if (match.children.length === 0)
        {
            match.endOffset = match.startOffset + 1;
            match.matched = false;
            const unMatched = new UnMatchedPattern(doc, this, failedMatches);
            unMatched.startOffset = startOffset;
            unMatched.endOffset = linq.from(failedMatches).max(match => match.endOffset);
            return unMatched;
        }
        else
        {
            match.endOffset = match.children[match.children.length - 1].endOffset;
            match.startOffset = match.children[0].startOffset;
            match.matched = true;
        }
        return match;
    }
}
/** 域模板: 用来做域的划分 */
class ScopePattern extends OrderedPatternSet
{
    name = "scope";
    /** 域 */
    scope: GrammarScope;


    /**
     * @param scope 域
     */
    constructor(pattern: GrammarPattern, scope: GrammarScope)
    {
        super(pattern, false);
        this.scope = scope;
    }
    match(doc: TextDocument, startOffset: number): MatchResult
    {
        function cleanSpace()
        {
            const skip = EmptyPattern.skipEmpty(doc, startOffset, true);
            if (skip)
                startOffset += skip[0].length;
        }
        const match = new ScopeMatchResult(doc, this);
        match.startOffset = startOffset;
        try 
        {
            cleanSpace();
            
            const subMatch = this.subPatterns[0].match(doc, startOffset);
            match.beginMatch = subMatch;
            match.endOffset = startOffset = subMatch.endOffset;
            if (!subMatch.matched)
            {
                match.matched = false;
                return match;
            }
            else
                cleanSpace();

            let hasMatched = false;
            let failedMatches: MatchResult[] = [];
            for (let i = 1; i < this.subPatterns.length; i++)
            {
                const subMatch = this.subPatterns[i].match(doc, startOffset);
                if (!subMatch.matched)
                {
                    failedMatches.push(subMatch);
                    if (i < this.subPatterns.length - 1)
                        continue;
                }
                else
                {
                    failedMatches = [];
                    if (i === this.subPatterns.length - 1)
                    {
                        match.endMatch = subMatch;
                        break;
                    }
                    match.addChildren(subMatch);
                    match.endOffset = startOffset = subMatch.endOffset;
                    hasMatched = true;

                    cleanSpace();
                }

                if (!hasMatched)
                {
                    const unMatched = new UnMatchedText(doc, this.scope, failedMatches);
                    failedMatches = [];
                    unMatched.startOffset = startOffset;
                    match.addChildren(unMatched);
                    if (!this.scope.skipMode || this.scope.skipMode === "line")
                    {
                        const pos = doc.positionAt(startOffset);
                        pos.line++;
                        pos.character = 0;
                        startOffset = doc.offsetAt(pos);
                        unMatched.endOffset = startOffset - 1;
                        const pos2 = doc.positionAt(startOffset);
                        if (pos2.line !== pos.line)
                        {
                            match.matched = false;
                            return match;
                        }
                    }
                    else
                    {
                        startOffset = linq.from(unMatched.allMatches).max(match => match.endOffset);
                        unMatched.endOffset = startOffset;
                    }
                    cleanSpace();
                }
                i = 0;
                hasMatched = false;
            }
            if (!match.endMatch)
            {
                match.startOffset = match.beginMatch.startOffset;
                match.matched = false;
                return match;
            }
            else
            {
                match.startOffset = match.beginMatch.startOffset;
                match.endOffset = match.endMatch.endOffset;
                match.matched = true;
            }
        }
        catch (ex)
        {
            console.error(ex);
        }
        return match;
    }
}
/** 语法模板: 全局意义上的语法分析类 其 match() 方法给出语法分析结果 */
class Grammar extends ScopePattern
{
    name = "grammar";
    grammar: LanguageGrammar;
    constructor(grammar: LanguageGrammar)
    {
        super(null, null);
        this.grammar = grammar;
    }
    match(doc: TextDocument, startOffset = 0): GrammarMatchResult
    {
        function cleanSpace()
        {
            const skip = EmptyPattern.skipEmpty(doc, startOffset, true);
            if (skip)
                startOffset += skip[0].length;
        }
        const match = new GrammarMatchResult(doc, this);
        const end = doc.getText().length;
        match.startOffset = 0;
        while (startOffset != end)
        {
            let hasMatched = false;
            let failedMathes: MatchResult[] = [];
            for (let i = 0; i < this.subPatterns.length; i++)
            {
                const subMatch = this.subPatterns[i].match(doc, startOffset);
                if (!subMatch.matched)
                {
                    failedMathes.push(subMatch);
                    continue;
                }
                failedMathes = [];
                hasMatched = true;
                match.addChildren(subMatch);
                match.endOffset = startOffset = subMatch.endOffset;
                cleanSpace();
                break;
            }

            if (!hasMatched)
            {
                const unMatched = new UnMatchedText(doc, this.scope, failedMathes);
                failedMathes = [];
                unMatched.startOffset = startOffset;
                match.addChildren(unMatched);

                const pos = doc.positionAt(startOffset);
                pos.line++;
                pos.character = 0;
                startOffset = doc.offsetAt(pos);
                unMatched.endOffset = startOffset - 1;
                
                const pos2 = doc.positionAt(startOffset);
                if (pos2.line !== pos.line)
                {
                    break;
                }
                cleanSpace();
            }
        }
        match.endOffset = end;
        match.matched = true;

        match.processSubMatches();

        return match;
    }
}

/** 匹配结果基类: 用于保存各种模板匹配的结果 */
class MatchResult
{
    /** 未匹配的原始文本段落 */
    document: TextDocument;
    /** 对应的匹配模板 */
    patternItem: PatternItem;
    /** 模板名称 */
    patternName: string = null;
    /** 开始文本偏移量 */
    startOffset: number;
    /** 末尾文本偏移量 */
    endOffset: number;

    /** 是否匹配 */
    matched = true;
    /** 域 */
    scope: GrammarScope;
    /** 内容在上下文知识库中的形态 */
    state: any = null;
    /** 父级匹配结果(父段落) */
    parent: MatchResult = null;
    /** 子匹配结果(子段落) */
    children: MatchResult[] = [];

    /** 匹配域 */
    matchedScope: ScopeMatchResult;
    /** 匹配模板 */
    matchedPattern: PatternMatchResult;
    /** 不匹配模板 */
    unmatchedPattern: UnMatchedPattern;

    /** 对应的语法模板 */
    private _pattern: GrammarPattern = null;

    /** 开始位置(相对于基准段落) */
    get start() { return this.document.positionAt(this.startOffset); }
    /** 结束位置(相对于基准段落) */
    get end() { return this.document.positionAt(this.endOffset); }
    /** 文本长度 */
    get length() { return this.endOffset - this.startOffset; }
    /** 匹配结果中的文本内容 */
    get text() { return this.document.getText({ start: this.start, end: this.end }); }
    /** 模板 */
    get pattern() { return this._pattern ? this._pattern : this.patternItem.pattern; }
    /** 设置模板 @param value 要设置的模板 */
    set pattern(value) { this._pattern = value; }

    /**
     * @param doc 基准文本段落
     * @param patternItem 匹配所用的模板
     */
    constructor(doc: TextDocument, patternItem: PatternItem)
    {
        this.document = doc;
        this.patternItem = patternItem;
    }
    toString(): string
    {
        return this.text;
    }

    /**
     * 加入子匹配结果
     * @param match 待加入的匹配结果
     */
    addChildren(match: MatchResult)
    {
        match.parent = this;
        this.children.push(match);
    }

    /**
     * 查找某位置对应的最小匹配结果(段落)
     * @param pos 位置
     * @returns 匹配结果(段落)
     */
    locateMatchAtPosition(pos: Position): MatchResult
    {
        const offset = this.document.offsetAt(pos);

        // 当前段落不包含该位置
        if (offset < this.startOffset || this.endOffset < offset)
            return null;

        // 当前段落为最小段落
        if (this.children.length <= 0)
            return this;
        
        // 找到第一个包含 pos 位置的子段落(子匹配结果)
        const child = linq.from(this.children).where(child => child.startOffset <= offset && offset <= child.endOffset).firstOrDefault();
        if (!child)
            return this;

        return child.locateMatchAtPosition(pos);
    }
}
/** 模板匹配结果 */
class PatternMatchResult extends MatchResult
{
    private _matchesList: MatchResult[] = null;
    private get allMathches(): MatchResult[]
    {
        if (this.children.length <= 0)
            return [];
        if (!this._matchesList)
        {
            let list = [this.children[0]];
            for (let i = 0; i < list.length; i++)
            {
                if (list[i] instanceof PatternMatchResult || list[i] instanceof ScopeMatchResult || list[i] instanceof UnMatchedText)
                    continue;
                if (!list[i])
                    console.log(list[i]);
                list = list.concat(list[i].children);
                
            }
            this._matchesList = list;
        }
        return this._matchesList;
    }
    getMatch(name: string): MatchResult[]
    {
        if (this.children.length <= 0)
            return null;

        return linq.from(this.allMathches).where(match => match.patternName === name).toArray();

    }
    processSubMatches()
    {
        if (this.pattern.onMatched)
            this.pattern.onMatched(this);

        this.allMathches.forEach(match =>
        {
            if (match != this)
            {
                match.matchedScope = this.matchedScope;
                match.matchedPattern = this;
            }
            if (match instanceof ScopeMatchResult)
            {
                match.processSubMatches();
            }
            else if (match instanceof PatternMatchResult)
            {
                match.processSubMatches();
            }
            else if (match instanceof UnMatchedText)
            {
                match.processSubMatches();
            }
        });
    }
}
/** 域匹配结果 */
class ScopeMatchResult extends MatchResult
{
    beginMatch: MatchResult;
    endMatch: MatchResult;
    constructor(doc: TextDocument, scope: ScopePattern)
    {
        super(doc, scope);
        this.scope = scope.scope;
    }
    processSubMatches()
    {
        if (this.scope && this.scope.onMatched)
            this.scope.onMatched(this);

        let matchList: MatchResult[] = [this];
        for (let i = 0; i < matchList.length; i++)
        {
            const subMatch = matchList[i];
            if (i > 0)
            {
                subMatch.matchedScope = this;
                subMatch.matchedPattern = this.matchedPattern;
                if (subMatch instanceof ScopeMatchResult)
                {
                    subMatch.processSubMatches();
                    continue;
                }
                else if (subMatch instanceof PatternMatchResult)
                {
                    subMatch.processSubMatches();
                    continue;
                }
                else if (subMatch instanceof UnMatchedText)
                {
                    subMatch.processSubMatches();
                    continue;
                }
            }
            matchList = matchList.concat(subMatch.children);
        }
    }
}
/** 语法匹配结果 */
class GrammarMatchResult extends ScopeMatchResult
{
    grammar: LanguageGrammar;
    constructor(doc: TextDocument, grammar: Grammar)
    {
        super(doc, grammar);
        this.grammar = grammar.grammar;
    }
    requestCompletion(pos: Position): CompletionItem[]
    {
        let completions: CompletionItem[] = [];
        const match = this.locateMatchAtPosition(pos);
        if (!match)
            return [];
        if (match instanceof UnMatchedPattern)
        {
            completions = completions.concat(match.requestCompletion(pos));
        }
        if (match instanceof UnMatchedText)
        {
            completions = completions.concat(match.requestCompletion(pos));
        }
        else if (match instanceof GrammarMatchResult)
        {
            completions = match.grammar.onCompletion ?
                completions.concat(match.grammar.onCompletion(match)) :
                completions;
        }
        else if (match instanceof ScopeMatchResult)
        {
            completions = (match.scope && match.scope.onCompletion) ?
                completions.concat(match.scope.onCompletion(match)) :
                completions;
        }
        for (let matchP = match; matchP != null; matchP = matchP.parent)
        {
            if (matchP instanceof PatternMatchResult && matchP.pattern.onCompletion)
            {
                completions = completions.concat(matchP.pattern.onCompletion(matchP));
            }
            if (!matchP.patternName)
                continue;
            if (matchP.matchedPattern && matchP.matchedPattern.pattern.onCompletion)
            {
                const comps = matchP.matchedPattern.pattern.onCompletion(matchP);
                completions = completions.concat(comps);
            }
            if (matchP.matchedScope && matchP.matchedScope.scope.onCompletion)
            {
                const comps = matchP.matchedScope.scope.onCompletion(matchP);
                completions = completions.concat(comps);
            }
        }

        completions = linq.from(completions)
            .where(item => item !== undefined)
            .distinct(comp=>comp.label)
            .toArray();
        return completions;
    }
}
/** 未匹配文本 */
class UnMatchedText extends MatchResult
{
    allMatches: MatchResult[];
    matched = false;
    protected _matchesList: MatchResult[] = null;
    protected get allSubMatches(): MatchResult[]
    {
        if (this.allMatches.length <= 0)
            return [];
        if (!this._matchesList)
        {
            let list = this.allMatches;
            for (let i = 0; i < list.length; i++)
            {
                if (list[i] instanceof PatternMatchResult || list[i] instanceof ScopeMatchResult || list[i] instanceof UnMatchedText)
                    continue;
                list = list.concat(list[i].children);
            }
            this._matchesList = list;
        }
        return this._matchesList;
    }
    constructor(doc: TextDocument, scope: GrammarScope, matches: MatchResult[])
    {
        super(doc, null);
        this.scope = scope;
        this.allMatches = matches;
    }
    processSubMatches()
    {
        this.allMatches.forEach(match => match.parent = this);
        this.allSubMatches.forEach(match =>
        {
            match.matchedPattern = this.matchedPattern;
            match.matchedScope = this.matchedScope;
            if (match instanceof PatternMatchResult || match instanceof ScopeMatchResult || match instanceof UnMatchedText)
            {
                match.processSubMatches();
            }
        });
    }
    requestCompletion(pos: Position): CompletionItem[]
    {
        let completions: CompletionItem[] = [];
        this.allMatches.forEach(match =>
        {
            const endMatch = match.locateMatchAtPosition(pos);
            if (!endMatch)
                return;
            if (match instanceof UnMatchedPattern)
            {
                completions = completions.concat(match.requestCompletion(pos));
            }
            if (endMatch instanceof UnMatchedText)
            {
                completions = completions.concat(endMatch.requestCompletion(pos));
            }
            for (let matchP = endMatch; matchP != this; matchP = matchP.parent)
            {
                if (!matchP.patternName)
                    continue;
                if (matchP.unmatchedPattern && matchP.unmatchedPattern.pattern.onCompletion)
                {
                    const comps = matchP.unmatchedPattern.pattern.onCompletion(matchP);
                    completions = completions.concat(comps);
                }
                else
                {
                    if (matchP.matchedPattern && matchP.matchedPattern.pattern.onCompletion)
                    {
                        const comps = matchP.matchedPattern.pattern.onCompletion(matchP);
                        completions = completions.concat(comps);
                    }
                    if (matchP.matchedScope && matchP.matchedScope.scope.onCompletion)
                    {
                        const comps = matchP.matchedScope.scope.onCompletion(matchP);
                        completions = completions.concat(comps);
                    }
                }

            }
        });
        completions = (this.matchedScope && this.matchedScope.scope && this.matchedScope.scope.onCompletion) ?
            completions.concat(this.matchedScope.scope.onCompletion(this)) :
            completions;
        return completions;
    }
    addChildren(match: MatchResult)
    {
        match.parent = this;
        this.allMatches.push(match);
    }
}
/** 未匹配模板 */
class UnMatchedPattern extends UnMatchedText
{
    constructor(doc: TextDocument, patternItem: PatternItem, matches: MatchResult[])
    {
        super(doc, patternItem.pattern.scope, matches);
        this.patternItem = patternItem;
    }
    processSubMatches()
    {
        this.allMatches.forEach(match => match.parent = this);
        this.allSubMatches.forEach(match =>
        {
            match.unmatchedPattern = this;
            match.matchedPattern = this.matchedPattern;
            match.matchedScope = this.matchedScope;
            if (match instanceof PatternMatchResult || match instanceof ScopeMatchResult || match instanceof UnMatchedText)
            {
                match.processSubMatches();
            }
        });
    }
    requestCompletion(pos: Position)
    {
        let completions: CompletionItem[] = [];
        if (this.pattern.onCompletion)
            completions = completions.concat(this.pattern.onCompletion(this));
        return completions.concat(super.requestCompletion(pos));
    }
    getMatch(name: string): MatchResult[]
    {
        return linq.from(this.allSubMatches).where(match => match.patternName === name).toArray();
    }
}
/** 模板声明 */
class PatternDictionary
{
    [key: string]: GrammarPattern;
}
/** 域声明 */
class ScopeDictionary
{
    [key: string]: GrammarScope;
}
/** 域语法声明 */
class GrammarScope
{
    /** 开始模板 */
    begin: string;
    /** 结束模板 */
    end: string;
    /** 是否跨行 */
    skipMode?: "line" | "space";
    /** 域内内容分解模板 */
    patterns?: GrammarPattern[];
    /** 嵌套域 */
    scopes?: GrammarScope[];
    /** 名称 */
    name?: string;
    /** 排除的语法模板 */
    ignore?: GrammarPattern;
    /** 符号对匹配(比如像括号、引号之类的) */
    pairMatch?: string[][];
    /** 匹配时回调 */
    onMatched?: ScopeMatchedCallback;
    /** 补全时回调 */
    onCompletion?: DocumentCompletionCallback;
    /** 编译模板 */
    compiledPattern?: ScopePattern;
    /** 语法定义 */
    grammar?: LanguageGrammar;
}
/** 模板语法声明 */
class GrammarPattern
{
    /** 字符串标签 */
    static String: GrammarPattern = { patterns: ["<string>"], name: "String" };
    /** 数字标签 */
    static Number: GrammarPattern = { patterns: ['<number>'], name: "Number" };
    /** 命名标签 */
    static Identifier: GrammarPattern = { patterns: ['<identifier>'], name: "Identifier" };

    /** 模板集 */
    patterns: string[];
    /** 是否懒惰匹配 */
    caseInsensitive?: boolean = false;
    /** 模板声明 */
    dictionary?: PatternDictionary;
    /** 保留空格 */
    keepSpace?: boolean = false;
    /** 名称 */
    name?: string;
    /** 编号 */
    id?: string;
    /** 严格匹配 */
    strict?: boolean = false;
    /** 跨行识别 */
    crossLine?: boolean = false;
    /** 域声明 */
    scopes?: ScopeDictionary;
    /** 递归匹配 */
    recursive?: boolean = false;
    /** 排除结果 */
    ignore?: RegExp;

    /** 匹配时回调 */
    onMatched?: PatternMatchedCallback;
    /** 诊断时回调 */
    onDiagnostic?: DocumentDiagnoseCallback;
    /** 补全时回调 */
    onCompletion?: DocumentCompletionCallback;

    /** 父语法模板 */
    parent?: GrammarPattern;
    /** 在父语法模板中的名称 */
    nameInParent?: string;
    /** 域语法声明 */
    scope?: GrammarScope;
    /** 语法模板 */
    compiledPattern?: PatternItem;
    /** 语法定义 */
    grammar?: LanguageGrammar;
    /** 编译时运行 */
    compiling?: boolean = false;
}
/** 语法定义 */
class LanguageGrammar
{
    /** 语法模板 */
    patterns?: GrammarPattern[];
    /** 名称 */
    name?: string;
    /** 排除模板列表 */
    ignore?: GrammarPattern;
    /** 分隔符定义 */
    stringDelimiter?: string[];
    /** 符号对匹配(比如像括号、引号之类的) */
    pairMatch?: string[][];
    /** 模板声明 */
    patternRepository?: PatternDictionary;
    /** 域声明 */
    scopeRepository?: ScopeDictionary;

    /** 补全时回调 */
    onCompletion?: DocumentCompletionCallback;
}

// ---------------------------------------------------------------- 相关方法
/** 
 * 括号分析:
 * 这里使用的括号有四种"[]"、"<>"、"{}"、"//", 分别标记"可有可无片段"、"引用的声明片段"、"域"、"正则表达式"
 * @param item 待分析字符串
 * @param pattern 分析使用的语法模板
 * @return 匹配模板
 */
function analyseBracketItem(item: string, pattern: GrammarPattern): PatternItem
{
    const buildInPattern: PatternItemDictionary = {
        "string": (pt: GrammarPattern) => new StringPattern(pt),
        "number": (pt: GrammarPattern) => new NumberPattern(pt),
        "identifier": (pt: GrammarPattern) => new IdentifierPattern(pt),
        " ": (pt: GrammarPattern) => new EmptyPattern(pt),
    };

    if (item[0] === "<" && item[item.length - 1] === ">")
    {
        let subPattern: PatternItem;
        const name = item.substring(1, item.length - 1);
        if (buildInPattern[name])
            subPattern = buildInPattern[name](pattern);
        else if (pattern.dictionary && pattern.dictionary[name])
        {
            pattern.dictionary[name].grammar = pattern.grammar;
            subPattern = compilePattern(pattern.dictionary[name]);
        }
        else if (pattern.grammar.patternRepository && pattern.grammar.patternRepository[name])
        {
            pattern.grammar.patternRepository[name].grammar = pattern.grammar;
            subPattern = compilePattern(pattern.grammar.patternRepository[name]);
        }
        else
            subPattern = new IdentifierPattern(pattern);
        
        subPattern.ignorable = false;
        return new NamedPattern(pattern, name, subPattern);
    }
    else if (item[0] === "[" && item[item.length - 1] === "]")
    {
        item = item.substring(1, item.length - 1);
        let multi = false;
        if (item.endsWith("..."))
        {
            multi = true;
            item = item.substring(0, item.length - 3);
        }
        const subPattern = analysePatternItem(item, pattern);
        subPattern.ignorable = true;
        subPattern.multi = multi;
        return subPattern;
    }
    else if (item[0] === "{" && item[item.length - 1] === "}")
    {
        const name = item.substring(1, item.length - 1);
        let scope: GrammarScope;
        if (pattern.scopes && pattern.scopes[name])
            scope = pattern.scopes[name];
        else if (pattern.grammar.scopeRepository && pattern.grammar.scopeRepository[name])
            scope = pattern.grammar.scopeRepository[name];

        if (!scope)
            throw new Error("Pattern undefined.");
        scope.grammar = pattern.grammar;
        return compileScope(scope, pattern);
    }
    else if (item.startsWith("/") && item.endsWith("/"))
    {
        const reg = item.substring(1, item.length - 1);
        const subPattern = new RegExpPattern(pattern, new RegExp(reg, pattern.caseInsensitive ? "i" : ""), false);
        subPattern.name = reg;
        return subPattern;
    }

    throw new Error("Syntax Error.");
}
/**
 * 模板分析
 * @param item 待分析字符串
 * @param pattern 分析使用的语法模板
 * @returns 匹配模板
 */
function analysePatternItem(item: string, pattern: GrammarPattern): PatternItem
{
    // 一些重要元符号
    const bracketStart = ["<", "[", "{", "/"];
    const bracketEnd = [">", "]", "}", "/"];
    const spaceChars = [" "];
    const isBracketStart = (chr: string): boolean => bracketStart.indexOf(chr) >= 0;
    const isBracketEnd = (chr: string): boolean => bracketEnd.indexOf(chr) >= 0;
    const isSpace = (chr: string): boolean => spaceChars.indexOf(chr) >= 0;
    
    enum State { CollectWords, MatchBracket }

    const patternItem: OrderedPatternSet = new OrderedPatternSet(pattern, false);
    let state: State = State.CollectWords;
    let bracketDepth = 0;
    let words = "";

    for (let i = 0; i < item.length; i++)
    {
        if (state === State.CollectWords)
        {
            if (item[i] === "\\")
            {
                words += item[++i];
                continue;
            }
            if (isBracketStart(item[i]))
            {
                if (words !== "")
                    patternItem.addSubPattern(new TextPattern(pattern, words));
                words = item[i];
                state = State.MatchBracket;
                bracketDepth++;
                continue;
            }
            else if (isSpace(item[i]))
            {
                if (words !== "")
                    patternItem.addSubPattern(new TextPattern(pattern, words));
                words = "";
                if (pattern.keepSpace)
                    patternItem.addSubPattern(new EmptyPattern(pattern, false));
                continue;
            }
            else if (isBracketEnd(item[i]))
                throw new Error("Syntax error.");
            else
            {
                words += item[i];
                continue;
            }
        }
        else if (state === State.MatchBracket)
        {
            if (item[i] === "\\")
            {
                words += (item[i] + item[++i]);
                continue;
            }
            words += item[i];
            if (isBracketEnd(item[i]))
            {
                bracketDepth--;
                if (bracketDepth === 0)
                {
                    patternItem.addSubPattern(analyseBracketItem(words, pattern));
                    words = "";
                    state = State.CollectWords;
                    continue;
                }
            }
            else if (isBracketStart(item[i]))
                bracketDepth++;
        }
    }

    if (state === State.CollectWords && words !== "")
        patternItem.addSubPattern(new TextPattern(pattern, words, false, pattern.caseInsensitive));
    else if (state === State.MatchBracket && bracketDepth > 0)
        throw new Error("Syntax error.");

    if (patternItem.subPatterns.length === 0)
        throw new Error("No pattern.");
    else if (patternItem.subPatterns.length === 1)
    {
        patternItem.subPatterns[0].ignorable = patternItem.ignorable;
        return patternItem.subPatterns[0];
    }
    return patternItem;
}
/**
 * 编译模板: 将模板语法声明整理为匹配模板
 * @param pattern 语法模板
 * @returns 匹配模板
 */
function compilePattern(pattern: GrammarPattern): PatternItem
{
    if (pattern === GrammarPattern.String)
        return new StringPattern(pattern);
    if (pattern.compiledPattern)
        return pattern.compiledPattern;
    pattern.compiling = true;
    const patternList: OptionalPatternSet = new OptionalPatternSet(pattern, true);
    pattern.compiledPattern = patternList;
    pattern.patterns.forEach(pt =>
    {
        const subPattern = analysePatternItem(pt, pattern);
        subPattern.strict = pattern.strict ? true : false;
        subPattern.ignorable = true;
        patternList.addSubPattern(subPattern);
    });
    if (patternList.count === 0)
        throw new Error("No pattern.");
    if (patternList.count === 1)
    {
        if (patternList.subPatterns[0] == patternList)
            throw new Error("Looped.");
        if (!(pattern.id || pattern.onMatched || pattern.onCompletion || pattern.onDiagnostic))
        {
            patternList.subPatterns[0].ignorable = true;
            pattern.compiledPattern = patternList.subPatterns[0];
            return patternList.subPatterns[0];
        }
    }
    return patternList;
}
/**
 * 编译域: 将域语法声明整理为域模板
 * @param scope 域语法声明
 * @param pattern 模板语法声明
 * @returns 域模板
 */
function compileScope(scope: GrammarScope, pattern: GrammarPattern): ScopePattern
{
    if (scope.compiledPattern)
        return scope.compiledPattern;
    const patternList = new ScopePattern(pattern, scope);
    patternList.addSubPattern(new TextPattern(pattern, scope.begin, false));
    scope.compiledPattern = patternList;
    scope.patterns.forEach(pt =>
    {
        pt.grammar = pattern.grammar;
        const subPattern = compilePattern(pt);
        subPattern.ignorable = true;
        subPattern.multi = true;
        patternList.addSubPattern(subPattern);
    });
    patternList.addSubPattern(new TextPattern(pattern, scope.end, false));
    patternList.name = scope.name ? scope.name : "Scope";
    return patternList;
}
/**
 * 编译语法定义
 * @param grammarDeclare 语法定义
 * @returns 语法模板
 */
function compileGrammar(grammarDeclare: LanguageGrammar): Grammar
{
    const grammar = new Grammar(grammarDeclare);
    grammarDeclare.patterns.forEach(pattern =>
    {
        pattern.grammar = grammarDeclare;
        const pt = compilePattern(pattern);
        grammar.addSubPattern(pt);
    });
    return grammar;
}
/**
 * 匹配语法
 * @param grammar 语法模板
 * @param doc 文本
 * @returns 
 */
function matchGrammar(grammar: Grammar, doc: TextDocument): GrammarMatchResult
{
    return grammar.match(doc, 0);
}
/**
 * 加入模板
 * @param patternName 模板名
 * @returns 模板语法声明
 */
function includePattern(patternName: string): GrammarPattern
{
    return { patterns: [`<${patternName}>`] };
}
/**
 * 命名模板
 * @param patternName 模板名称
 * @returns 模板语法声明
 */
function namedPattern(patternName: string): GrammarPattern
{
    return { patterns: [`<${patternName}>`] };
}
/**
 * 从匹配结果中匹配结果
 * @param match 匹配结果
 * @param name 要匹配的模板
 * @param defaultValue 无匹配结果时传递的默认值
 * @returns 匹配结果的匹配结果
 */
function getMatchedProps(match: PatternMatchResult|UnMatchedPattern, name: string, defaultValue: string = null)
{
    if (!match)
        return defaultValue;
    const value = match.getMatch(name)[0];
    if (!value)
        return defaultValue;
    return value.text;
}

// ----------------------------------------------------------------
export
{
    LanguageGrammar,
    GrammarPattern,
    GrammarScope,
    MatchResult,
    PatternMatchResult,
    ScopeMatchResult,
    UnMatchedPattern,

    includePattern,
    namedPattern,
    compileGrammar,
    matchGrammar,
    getMatchedProps
};