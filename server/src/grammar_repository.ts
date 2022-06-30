// ================================================================
// 语法分析知识库构建相关类的定义
// ================================================================

import { TextDocument } from "vscode-languageserver-textdocument";
import { Position, CompletionItem, Diagnostic } from "vscode-languageserver";
import linq from "linq";

type DocumentCompletionCallback = (match:MatchResult) => CompletionItem[];
type PatternMatchedCallback = (patternMatch: PatternMatchResult) => void;
type ScopeMatchedCallback = (scopeMatch: ScopeMatchResult) => void;
type DocumentDiagnoseCallback = (unMatched: UnMatchedText) => Diagnostic[];
type PatternItemDictionary = { [key: string]: (pattern: GrammarPattern) => PatternItem };

/** 匹配模式基类: 是所有词汇捕获模式的基类 */
abstract class PatternItem
{
    /** 模式名称 */
    name = "pattern";
    /** 父模式 */
    parent?: OrderedPatternSet;
    /** 严格匹配 */
    strict = false;
    /** 可忽略的 */
    ignorable = false;
    /** 多结果 */
    multi = false;
    /** 匹配语法 */
    pattern: GrammarPattern;

    /**
     * 匹配方法
     * @param doc 待匹配的文本
     * @param startOffset 起始点偏移量
     * @return 匹配结果
     */
    abstract match(doc: TextDocument, startOffset: number): MatchResult;
    /**
     * @param pattern 语法
     * @param ignorable 是否可忽略
     */
    constructor(pattern: GrammarPattern, ignorable = false)
    {
        this.pattern = pattern;
        this.ignorable = ignorable;
    }
    toString(): string
    {
        return this.ignorable ? `[${this.name}]` : `<${this.name}>`;
    }
}
/** 空模式: 用于一个段落内的所有捕获空字符 */
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
/** 正则表达式模式 */
class RegExpPattern extends PatternItem
{
    name = "regExp";
    /** 相关正则表达式 */
    regExp: RegExp;

    /**
     * @param pattern 匹配语法
     * @param reg 正则表达式
     * @param ignorable 可忽略的
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
        
        const text = doc.getText().substring(startOffset);
        const regMatch = this.regExp.exec(text);
        const match = new MatchResult(doc, this);
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
class NamedPattern extends PatternItem
{
    patternItem: PatternItem;
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
class TextPattern extends RegExpPattern
{
    text: string;
    currentIdx = 0;
    get ignoreCase() { return this.regExp.ignoreCase; }
    constructor(pattern: GrammarPattern, text: string, ignorable = false, ignoreCase = false)
    {
        super(pattern, new RegExp(text.replace(/[|\\{}()[\]^$+*?.]/g, '\\$&'), ignoreCase ? "i" : ""), ignorable);
        this.text = text;
        this.name = text;
    }
}
class StringPattern extends RegExpPattern
{
    name = "string";
    begin = false;
    slash = false;
    end = false;
    constructor(pattern: GrammarPattern, ignorable = false)
    {
        super(pattern, /"([^\\"]|\\\S|\\")*"/, ignorable);
    }
}
class NumberPattern extends RegExpPattern
{
    name = "number";
    constructor(pattern: GrammarPattern, ignorable = false)
    {
        super(pattern, /[+-]?[0-9]+\.?[0-9]*/, ignorable);
    }
}
class IdentifierPattern extends RegExpPattern
{
    name = "identifier";
    constructor(pattern: GrammarPattern, ignorable = false)
    {
        super(pattern, /[_a-zA-Z][_a-zA-Z0-9]*/, ignorable);
    }
}


class OrderedPatternSet extends PatternItem
{
    name = "nest";
    subPatterns: PatternItem[] = [];
    currentIdx = 0;
    get count() { return this.subPatterns.length; }
    addSubPattern(patternItem: PatternItem)
    {
        this.subPatterns.push(patternItem);
    }
    toString()
    {
        const str = super.toString() + "\r\n" + this.subPatterns.map(pattern => pattern.toString()).join("\r\n").split(/\r\n/g).map(str => "\t" + str).join("\r\n");
        return str;
    }
    match(doc: TextDocument, startOffset: number): MatchResult
    {
        const match = new MatchResult(doc, this);
        match.startOffset = startOffset;
        try 
        {
            for (let i = 0; i < this.subPatterns.length; i++)
            {
                const subMatch = this.subPatterns[i].match(doc, startOffset);
                if (!subMatch.matched)
                {
                    if (this.strict && !EmptyPattern.isEmpty(subMatch.text))
                    {
                        match.addChildren(subMatch);
                        match.endOffset = subMatch.endOffset;
                        match.matched = false;
                        return match;
                    }
                    if (this.subPatterns[i].ignorable)
                        continue;
                    match.addChildren(subMatch);
                    match.endOffset = subMatch.endOffset;
                    match.matched = false;
                    return match;
                }
                match.addChildren(subMatch);
                startOffset = subMatch.endOffset;
                if (this.subPatterns[i].multi)
                    i--;
            }
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
}
class OptionalPatternSet extends OrderedPatternSet
{
    name = "optional";

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
class ScopePattern extends OrderedPatternSet
{
    name = "scope";
    scope: GrammarScope;

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

/** 匹配结果基类: 用于保存各种模式匹配的结果 */
class MatchResult
{
    /** 基准文本段落 */
    document: TextDocument;
    /** 对应的匹配模式 */
    patternItem: PatternItem;
    /** 模式名称 */
    patternName: string = null;
    /** 开始文本偏移量 */
    startOffset: number;
    /** 末尾文本偏移量 */
    endOffset: number;

    /** 是否匹配 */
    matched = true;
    /** 域 */
    scope: GrammarScope;
    /** 状态 */
    state: any = null;
    /** 父级匹配结果(父段落) */
    parent: MatchResult = null;
    /** 子匹配结果(子段落) */
    children: MatchResult[] = [];

    /** 匹配域 */
    matchedScope: ScopeMatchResult;
    /** 匹配模式 */
    matchedPattern: PatternMatchResult;
    /** 不匹配模式 */
    unmatchedPattern: UnMatchedPattern;

    /** 对应的语法模式 */
    private _pattern: GrammarPattern = null;

    /** 开始位置(相对于基准段落) */
    get start() { return this.document.positionAt(this.startOffset); }
    /** 结束位置(相对于基准段落) */
    get end() { return this.document.positionAt(this.endOffset); }
    /** 文本长度 */
    get length() { return this.endOffset - this.startOffset; }
    /** 文本内容 */
    get text() { return this.document.getText({ start: this.start, end: this.end }); }
    /** 模式 */
    get pattern() { return this._pattern ? this._pattern : this.patternItem.pattern; }
    /** 设置模式 @param value 要设置的模式 */
    set pattern(value) { this._pattern = value; }

    /**
     * @param doc 基准文本段落
     * @param patternItem 匹配所用的模式
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
/** 模式匹配结果 */
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
class UnMatchedPattern extends UnMatchedText
{
    constructor(doc: TextDocument, patternItem: PatternItem, matches: MatchResult[])
    {
        super(doc, patternItem.pattern._scope, matches);
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
class PatternDictionary
{
    [key: string]: GrammarPattern;
}
class ScopeDictionary
{
    [key: string]: GrammarScope;
}
class GrammarScope
{
    begin: string;
    end: string;
    skipMode?: "line" | "space";
    patterns?: GrammarPattern[];
    scopes?: GrammarScope[];
    name?: string;
    ignore?: GrammarPattern;
    pairMatch?: string[][];
    onMatched?: ScopeMatchedCallback;
    onCompletion?: DocumentCompletionCallback;
    _compiledPattern?: ScopePattern;
    _grammar?: LanguageGrammar;
}
class GrammarPattern
{
    static String: GrammarPattern = { patterns: ["<string>"], name: "String" };
    static Number: GrammarPattern = { patterns: ['<number>'], name: "Number" };
    static Identifier: GrammarPattern = { patterns: ['<identifier>'], name: "Identifier" };
    patterns: string[];
    caseInsensitive?: boolean = false;
    dictionary?: PatternDictionary;
    keepSpace?: boolean = false;
    name?: string;
    id?: string;
    strict?: boolean = false;
    crossLine?: boolean = false;
    scopes?: ScopeDictionary;
    recursive?: boolean = false;

    onMatched?: PatternMatchedCallback;
    onDiagnostic?: DocumentDiagnoseCallback;
    onCompletion?: DocumentCompletionCallback;
    _parent?: GrammarPattern;
    _nameInParent?: string;
    _scope?: GrammarScope;
    _compiledPattern?: PatternItem;
    _grammar?: LanguageGrammar;
    _compiling?: boolean = false;
}
class LanguageGrammar
{
    patterns?: GrammarPattern[];
    name?: string;
    ignore?: GrammarPattern;
    stringDelimiter?: string[];
    pairMatch?: string[][];
    patternRepository?: PatternDictionary;
    scopeRepository?: ScopeDictionary;
    onCompletion?: DocumentCompletionCallback;
}
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
            pattern.dictionary[name]._grammar = pattern._grammar;
            subPattern = compilePattern(pattern.dictionary[name]);
        }
        else if (pattern._grammar.patternRepository && pattern._grammar.patternRepository[name])
        {
            pattern._grammar.patternRepository[name]._grammar = pattern._grammar;
            subPattern = compilePattern(pattern._grammar.patternRepository[name]);
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
        else if (pattern._grammar.scopeRepository && pattern._grammar.scopeRepository[name])
            scope = pattern._grammar.scopeRepository[name];

        if (!scope)
            throw new Error("Pattern undefined.");
        scope._grammar = pattern._grammar;
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
function analysePatternItem(item: string, pattern: GrammarPattern): PatternItem
{
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
function compilePattern(pattern: GrammarPattern): PatternItem
{
    if (pattern === GrammarPattern.String)
        return new StringPattern(pattern);
    if (pattern._compiledPattern)
        return pattern._compiledPattern;
    pattern._compiling = true;
    const patternList: OptionalPatternSet = new OptionalPatternSet(pattern, true);
    pattern._compiledPattern = patternList;
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
            pattern._compiledPattern = patternList.subPatterns[0];
            return patternList.subPatterns[0];
        }
    }
    return patternList;
}
function compileScope(scope: GrammarScope, pattern: GrammarPattern): ScopePattern
{
    if (scope._compiledPattern)
        return scope._compiledPattern;
    const patternList = new ScopePattern(pattern, scope);
    patternList.addSubPattern(new TextPattern(pattern, scope.begin, false));
    scope._compiledPattern = patternList;
    scope.patterns.forEach(pt =>
    {
        pt._grammar = pattern._grammar;
        const subPattern = compilePattern(pt);
        subPattern.ignorable = true;
        subPattern.multi = true;
        patternList.addSubPattern(subPattern);
    });
    patternList.addSubPattern(new TextPattern(pattern, scope.end, false));
    patternList.name = scope.name ? scope.name : "Scope";
    return patternList;
}
function compileGrammar(grammarDeclare: LanguageGrammar): Grammar
{
    const grammar = new Grammar(grammarDeclare);
    grammarDeclare.patterns.forEach(pattern =>
    {
        pattern._grammar = grammarDeclare;
        const pt = compilePattern(pattern);
        grammar.addSubPattern(pt);
    });
    return grammar;
}
function matchGrammar(grammar: Grammar, doc: TextDocument): GrammarMatchResult
{
    return grammar.match(doc, 0);
}
function includePattern(patternName: string): GrammarPattern
{
    return { patterns: [`<${patternName}>`] };
}
function namedPattern(patternName: string): GrammarPattern
{
    return { patterns: [`<${patternName}>`] };
}


export
{
    LanguageGrammar,
    GrammarPattern,
    compileGrammar,
    matchGrammar,
    GrammarScope,
    includePattern,
    namedPattern,
    MatchResult,
    PatternMatchResult,
    ScopeMatchResult,
    UnMatchedPattern
};