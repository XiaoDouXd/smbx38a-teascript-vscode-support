// ================================================================
// 语法分析模板构建相关类的设计
// ================================================================

import { TextDocument } from 'vscode-languageserver-textdocument';
import { Position, CompletionItem, Diagnostic, Hover, CompletionParams } from 'vscode-languageserver/node';
import { NoParamCallback } from 'fs';
import { teaBuiltinKeywordCompletion, teaBuiltinTypesCompletion } from './tea-context';
import { log } from 'console';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const linq = require('linq');

type EmptyAction = () => void;
type DocumentCompletionCallback = (match: MatchResult) => { items: CompletionItem[], isBreak: boolean };
type DocumentHoverCallback = (match: MatchResult) => Promise<Hover>;
type PatternMatchedCallback = (patternMatch: PatternMatchResult) => void;
type ScopeMatchedCallback = (scopeMatch: ScopeMatchResult) => void;
type DocumentDiagnoseCallback = (unMatched: UnMatchedText) => Diagnostic[];
type PatternItemDictionary = { [key: string]: (pattern: GrammarPatternDeclare) => PatternItem };
type CompletionPostProcessing = (items: CompletionItem[], params: CompletionParams) => CompletionItem[];

// ----------------------------------------------------------------
/** 匹配模板基类: 是所有词汇、段落捕获模板的基类 */
abstract class PatternItem {
    /** 模板名称 */
    name = "pattern";

    /** 严格匹配 */
    strict = false;
    /** 可忽略的 */
    ignorable = false;
    /** 多结果 */
    multi = false;
    /** 语法模板 */
    pattern: GrammarPatternDeclare;
    /** 父模板 */
    parent?: OrderedPatternSet;
    /** 排除字段 */
    ignore?: RegExp;
    /** 为域模板 */
    protected _forScope = false;

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
    constructor(pattern: GrammarPatternDeclare, ignorable = false) {
        this.pattern = pattern;
        this.ignorable = ignorable;

        if (pattern != null && pattern.ignore != null) this.ignore = pattern.ignore;
    }

    toString(): string {
        return this.ignorable ? `[${this.name}]` : `<${this.name}>`;
    }

    forScope(): boolean {
        return this._forScope;
    }
}

/** 空模板: 用于一个段落内的所有捕获空字符 */
class EmptyPattern extends PatternItem {
    name = "space";
    constructor(pattern: GrammarPatternDeclare, ignorable = false) {
        super(pattern, ignorable);
    }

    /**
     * 分词
     * @param doc 待匹配的文本
     * @param startOffset 开始位置
     * @param crossLine 是否跨行
     * @returns 正则表达式执行组
     */
    static skipEmpty(doc: TextDocument, startOffset: number, crossLine = false): RegExpExecArray {
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
    static isEmpty(text: string, crossLine = false) {
        const reg = crossLine ?
            /^(((?:\s|\/\*(?!\/).*?\*\/)*)(\/\/.*[\r]?[\n]?)?)*$/
            :
            /^((?:[\t]|\/\*(?!\/).*?\*\/)*)?$/;
        return reg.test(text);
    }

    match(doc: TextDocument, startOffset: number): MatchResult {
        // 捕获到的所有空字符
        const empty = EmptyPattern.skipEmpty(doc, startOffset, this.pattern.crossLine);

        // ---------------------------------------------
        // 构建捕获结果
        const match = new MatchResult(doc, this);
        match.startOffset = startOffset;
        if (empty && empty[0].length > 0) {
            // 捕获到了东西(虽然只是空格之类的...)
            match.endOffset = startOffset + empty[0].length;
            match.matched = true;
        }
        else {
            // 啥都没捕获到
            match.endOffset = startOffset;
            match.matched = false;
        }
        return match;
    }
}

/** 正则表达式模板: 未定义正则表达式, 需要在构造时指出 */
class RegExpPattern extends PatternItem {
    name = "regExp";
    /** 相关正则表达式 */
    regExp: RegExp;

    /**
     * @param reg 正则表达式
     */
    constructor(pattern: GrammarPatternDeclare, reg: RegExp, ignorable = false) {
        super(pattern, ignorable);
        this.regExp = reg;
    }

    match(doc: TextDocument, startOffset: number): MatchResult {
        // 检查段前的空字符
        const skip = EmptyPattern.skipEmpty(doc, startOffset, this.pattern.crossLine);
        if (skip)
            // 跳过空字符
            startOffset += skip[0].length;

        // 截取后面的字符
        const text = doc.getText().substring(startOffset);

        // 通过该模板默认的正则表达式匹配
        const match = new MatchResult(doc, this);

        const regMatch = this.regExp.exec(text);

        // 匹配排除模板
        if (this.ignore != null) {
            const test = this.ignore.exec(text);
            if (test != null && regMatch != null && test[0] == regMatch[0]) {
                match.endOffset = startOffset;
                match.matched = false;
                return match;
            }
        }

        match.startOffset = startOffset;
        if (!regMatch || regMatch.index !== 0) {
            match.endOffset = startOffset;
            match.matched = false;
        }
        else {
            match.endOffset = startOffset + regMatch[0].length;
            match.matched = true;
        }
        return match;
    }
}

/** 重命名模板: 可以以其它一些模板为原型复制出一些新模板 */
class NamedPattern extends PatternItem {
    patternItem: PatternItem;

    /**
     * @param name 名称
     * @param patternItem 要复制的模板
     */
    constructor(pattern: GrammarPatternDeclare, name: string, patternItem: PatternItem) {
        super(pattern, patternItem.ignorable);
        this.name = name;
        this.patternItem = patternItem;
    }

    match(doc: TextDocument, startOffset: number): MatchResult {
        const match = this.patternItem.match(doc, startOffset);
        match.patternName = this.name;

        return match;
    }
}

/** 文本模板: 完美匹配单词文本, 当然括号内、空格等其它运算符号分开的单词做了分词处理 */
class TextPattern extends RegExpPattern {
    text: string;
    currentIdx = 0;

    get ignoreCase() { return this.regExp.ignoreCase; }

    /**
     * @param text 文本
     * @param ignoreCase 是否忽略大小写
     */
    constructor(pattern: GrammarPatternDeclare, text: string, ignorable = false, ignoreCase = true) {
        // 匹配单词文本
        super(pattern, new RegExp(text.replace(/[|\\{}()[\]^$+*?.=:]/g, '\\$&'), ignoreCase ? "i" : ""), ignorable);
        this.text = text;
        this.name = text;
    }
}
/** 字符串模板: 匹配所有被两个双引号夹住形式的字符串 */
class StringPattern extends RegExpPattern {
    name = "string";
    begin = false;
    slash = false;
    end = false;

    constructor(pattern: GrammarPatternDeclare, ignorable = false) {
        // 匹配两个双引号夹起来的形状
        super(pattern, /"([^\\"]|\\\S|\\")*"/, ignorable);
    }
}
/** 数字模板: 匹配所有数字 */
class NumberPattern extends RegExpPattern {
    name = "number";

    constructor(pattern: GrammarPatternDeclare, ignorable = false) {
        // 匹配所有数字
        super(pattern, /[+-]?[0-9]+\.?[0-9]*/, ignorable);
    }
}

/** 命名模板: 匹配所有的变量、函数、结构体等名称 */
class IdentifierPattern extends RegExpPattern {
    name = "identifier";
    constructor(pattern: GrammarPatternDeclare, ignorable = false) {
        super(pattern, /[_a-zA-Z][_a-zA-Z0-9]*/, ignorable);
    }
}
/** 全通过模板: 一般用来占位 */
class AllPattern extends PatternItem {
    name = "all";
    constructor(pattern: GrammarPatternDeclare) {
        super(pattern, false);
    }

    match(doc: TextDocument, startOffset: number): MatchResult {
        const match = new MatchResult(doc, this);
        match.startOffset = startOffset;
        match.endOffset = startOffset;
        match.matched = true;

        return match;
    }
}

/** 依序模板组: 若中间有些模板无法匹配则后面的内容就都不匹配了 */
class OrderedPatternSet extends PatternItem {
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
    addSubPattern(patternItem: PatternItem) {
        this.subPatterns.push(patternItem);
    }

    /**
     * 依序模板组的匹配
     * 划定作用域的准备工作
     */
    match(doc: TextDocument, startOffset: number): MatchResult {
        // 创建匹配结果的容器
        const match = new MatchResult(doc, this);
        match.startOffset = startOffset;

        /** 递归寻找上一个匹配结果末尾有没有域 */
        function forScope(ma: MatchResult): ScopeMatchResult {
            if (ma.forScope())
                return ma as ScopeMatchResult;
            if (ma.children.length >= 1) {
                return forScope(ma.children[ma.children.length - 1]);
            }
            return null;
        }

        try {
            // 遍历每一个子模板
            for (let i = 0; i < this.subPatterns.length; i++) {
                // 尝试匹配
                const subMatch = this.subPatterns[i].match(doc, startOffset);
                // 该段匹配不上
                if (!subMatch.matched) {
                    // 其实这段就是在说:
                    // 若本段落有子段落并且现在已经离开了该子段落
                    // 则标记该子段落的结尾
                    // 如果为严格匹配且当前的匹配结果(可能是与兄弟模板匹配的结果)不为空
                    if (this.strict && !EmptyPattern.isEmpty(subMatch.text)) {
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

                // 若域端点是隐式的...上一次结尾处匹配的是域, 则这次从域的端点开始继续匹配
                const scopeMa = forScope(subMatch);
                if (scopeMa != null) {
                    if (!scopeMa.scope.grammar?.explicitScopeExtreme) {
                        startOffset = scopeMa.endMatch.startOffset;
                    }
                }
                // 否则显式域端点
                else
                    startOffset = subMatch.endOffset;

                if (this.subPatterns[i].multi)
                    i--;
            }

            // 若子段落为没有
            if (match.children.length === 0) {
                match.endOffset = match.startOffset + 1;
                match.matched = false;
            }
            else {
                match.endOffset = match.children[match.children.length - 1].endOffset;
                match.startOffset = match.children[0].startOffset;
                match.matched = true;
            }
        }
        catch (ex) {
            console.error(ex);
        }
        return match;
    }

    toString() {
        const str = super.toString() + "\r\n" + this.subPatterns.map(pattern => pattern.toString()).join("\r\n").split(/\r\n/g).map(str => "\t" + str).join("\r\n");
        return str;
    }
}

/** 可选模板组: 跳过无法匹配的模板继续往后面匹配 */
class OptionalPatternSet extends OrderedPatternSet {
    name = "optional";

    /**
     * 可选模板组的匹配
     */
    match(doc: TextDocument, startOffset: number): MatchResult {
        const match = new PatternMatchResult(doc, this);
        match.startOffset = startOffset;
        const failedMatches: MatchResult[] = [];
        for (let i = 0; i < this.subPatterns.length; i++) {
            const subMatch = this.subPatterns[i].match(doc, startOffset);
            if (!subMatch.matched) {
                failedMatches.push(subMatch);
                continue;
            }
            match.addChildren(subMatch);
            break;
        }
        if (match.children.length === 0) {
            match.endOffset = match.startOffset + 1;
            match.matched = false;
            const unMatched = new UnMatchedPattern(doc, this, failedMatches);
            unMatched.startOffset = startOffset;
            unMatched.endOffset = linq.from(failedMatches).max((match: MatchResult) => match.endOffset);
            return unMatched;
        }
        else {
            match.endOffset = match.children[match.children.length - 1].endOffset;
            match.startOffset = match.children[0].startOffset;
            match.matched = true;
        }
        return match;
    }
}

/** 域模板: 用来做域的匹配 */
class ScopePattern extends OrderedPatternSet {
    name = "scope";
    /** 域 */
    scope: GrammarScopeDeclare;

    /**
     * @param scope 域
     */
    constructor(pattern: GrammarPatternDeclare, scope: GrammarScopeDeclare) {
        super(pattern, false);
        this.scope = scope;
        this._forScope = true;
    }

    /** 域的匹配 */
    match(doc: TextDocument, startOffset: number): MatchResult {
        /** 跳过空格 */
        function cleanSpace() {
            const skip = EmptyPattern.skipEmpty(doc, startOffset, true);
            if (skip)
                startOffset += skip[0].length;
        }

        // 新建域匹配结果
        const match = new ScopeMatchResult(doc, this);

        // 开始匹配
        match.startOffset = startOffset;
        try {
            cleanSpace();

            // 匹配第一个模板, 第一个开始模板, 若没有显式开始则不管
            const subMatch = this.subPatterns[0].match(doc, startOffset);
            match.beginMatch = subMatch;
            match.endOffset = startOffset = subMatch.endOffset;
            if (!subMatch.matched) {
                match.matched = false;
                return match;
            }
            else
                cleanSpace();

            let hasMatched = false;
            // 没匹配上的子模板
            let failedMatches: MatchResult[] = [];

            // 对每个子模板进行匹配
            for (let i = 1; i < this.subPatterns.length; i++) {
                // 子模板匹配结果
                const subMatch = this.subPatterns[i].match(doc, startOffset);

                // 若该子模版没匹配
                if (!subMatch.matched) {
                    // 放到失败匹配模板中
                    failedMatches.push(subMatch);
                    // 若还有别的模板则继续尝试匹配
                    if (i < this.subPatterns.length - 1)
                        continue;
                }
                // 若该子模板匹配了
                else {
                    // 清空失败的匹配模板
                    failedMatches = [];
                    // 若该子模板是最后一个匹配模板
                    if (i === this.subPatterns.length - 1) {
                        // 记下来并退出匹配
                        match.endMatch = subMatch;
                        break;
                    }
                    // 记下子匹配结果
                    match.addChildren(subMatch);
                    // 记下尾指针
                    match.endOffset = startOffset = subMatch.endOffset;
                    // 已经有匹配了
                    hasMatched = true;

                    // 跳过空格
                    cleanSpace();
                }

                // 若接下来这段完全没有模板能匹配上
                if (!hasMatched) {
                    // 新建未匹配结果
                    const unMatched = new UnMatchedText(doc, this.scope, failedMatches);
                    // 清空失败匹配
                    failedMatches = [];
                    unMatched.startOffset = startOffset;
                    match.addChildren(unMatched);
                    if (!this.scope.skipMode || this.scope.skipMode === "line") {
                        const pos = doc.positionAt(startOffset);
                        pos.line++;
                        pos.character = 0;
                        startOffset = doc.offsetAt(pos);
                        unMatched.endOffset = startOffset - 1;
                        const pos2 = doc.positionAt(startOffset);
                        if (pos2.line !== pos.line) {
                            match.matched = false;
                            return match;
                        }
                    }
                    else {
                        startOffset = linq.from(unMatched.allMatches).max((match: MatchResult) => match.endOffset);
                        unMatched.endOffset = startOffset;
                    }

                    // 跳过空格
                    cleanSpace();
                }

                i = 0;
                hasMatched = false;
            }

            // 结束模板
            if (!match.endMatch) {
                match.startOffset = match.beginMatch.startOffset;
                match.matched = false;
                return match;
            }
            else {
                match.startOffset = match.beginMatch.startOffset;
                match.endOffset = match.endMatch.endOffset;
                match.matched = true;
            }
        }
        catch (ex) {
            console.error(ex);
        }
        return match;
    }
}

/** 语法模板: 全局意义上的语法分析类 其 match() 方法给出语法分析结果 */
class Grammar extends ScopePattern {
    name = "grammar";
    grammar: LanguageGrammar;
    constructor(grammar: LanguageGrammar) {
        super(null, null);
        this.grammar = grammar;
    }

    match(doc: TextDocument, startOffset = 0): GrammarMatchResult {
        function cleanSpace() {
            const skip = EmptyPattern.skipEmpty(doc, startOffset, true);
            if (skip)
                startOffset += skip[0].length;
        }

        try {
            // 清除前面的空格
            // 新建匹配结果
            const match = new GrammarMatchResult(doc, this);
            // 定位尾部
            const end = doc.getText().length;
            match.startOffset = 0;
            while (startOffset != end) {
                let hasMatched = false;
                let failedMatches: MatchResult[] = [];
                for (let i = 0; i < this.subPatterns.length; i++) {
                    const subMatch = this.subPatterns[i].match(doc, startOffset);
                    if (!subMatch.matched) {
                        failedMatches.push(subMatch);
                        continue;
                    }
                    failedMatches = [];
                    hasMatched = true;
                    match.addChildren(subMatch);
                    match.endOffset = startOffset = subMatch.endOffset;
                    cleanSpace();
                    break;
                }

                if (!hasMatched) {
                    const unMatched = new UnMatchedText(doc, this.scope, failedMatches);
                    failedMatches = [];
                    unMatched.startOffset = startOffset;
                    match.addChildren(unMatched);

                    const pos = doc.positionAt(startOffset);
                    pos.line++;
                    pos.character = 0;
                    startOffset = doc.offsetAt(pos);
                    unMatched.endOffset = startOffset - 1;

                    const pos2 = doc.positionAt(startOffset);
                    if (pos2.line !== pos.line) {
                        break;
                    }
                    cleanSpace();
                }
            }

            if (!match.scope)
                match.scope = new GlobalScopeDeclare(this.grammar, this.grammar.onMatchedInit);
            match.endOffset = end;
            match.matched = true;

            match.processSubMatches();

            return match;
        }
        catch (ex) {
            console.log(ex);
        }
    }
}

/** 匹配结果基类: 用于保存各种模板匹配的结果 */
class MatchResult {
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
    scope: GrammarScopeDeclare;
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
    private _pattern: GrammarPatternDeclare = null;
    /** 是否为域匹配结果 */
    protected _forScope = false;

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
    /** 是否是域的匹配结果 */
    forScope(): boolean { return this._forScope; }
    /** 转换为域的匹配结果 */
    setForScope() { this._forScope = true; }

    /**
     * @param doc 基准文本段落
     * @param patternItem 匹配所用的模板
     */
    constructor(doc: TextDocument, patternItem: PatternItem) {
        this.document = doc;
        this.patternItem = patternItem;
    }

    toString(): string {
        return this.text;
    }

    /**
     * 加入子匹配结果
     * @param match 待加入的匹配结果
     */
    addChildren(match: MatchResult) {
        match.parent = this;
        this.children.push(match);
    }

    /**
     * 查找某位置对应的最小匹配结果(段落)
     * @param pos 位置
     * @returns 匹配结果(段落)
     */
    locateMatchAtPosition(pos: Position): MatchResult {
        const offset = this.document.offsetAt(pos);

        // 当前段落不包含该位置
        if (offset < this.startOffset || this.endOffset < offset) return this;

        // 当前段落为最小段落
        if (this.children.length <= 0)
            return this;

        // 找到第一个包含 pos 位置的子段落(子匹配结果)
        const child = linq.from(this.children).where((child: MatchResult) => child.startOffset <= offset && offset <= child.endOffset).firstOrDefault();
        if (!child)
            return this;

        return child.locateMatchAtPosition(pos);
    }
}

/** 模板匹配结果 */
class PatternMatchResult extends MatchResult {
    private _matchesList: MatchResult[] = null;

    private get allMatches(): MatchResult[] {
        if (this.children.length <= 0)
            return [];
        if (!this._matchesList) {
            let list = [this.children[0]];
            for (let i = 0; i < list.length; i++) {
                if (list[i] instanceof PatternMatchResult || list[i] instanceof ScopeMatchResult || list[i] instanceof UnMatchedText)
                    continue;
                list = list.concat(list[i].children);

            }
            this._matchesList = list;
        }
        return this._matchesList;
    }

    getMatch(name: string): MatchResult[] {
        if (this.children.length <= 0)
            return null;

        return linq.from(this.allMatches).where((match: MatchResult) => match.patternName === name).toArray();

    }

    processSubMatches() {
        if (this.pattern.onMatched)
            this.pattern.onMatched(this);

        this.allMatches.forEach(match => {
            if (match != this) {
                match.matchedScope = this.matchedScope;
                match.matchedPattern = this;
            }
            if (match instanceof ScopeMatchResult) {
                match.processSubMatches();
            }
            else if (match instanceof PatternMatchResult) {
                match.processSubMatches();
            }
            else if (match instanceof UnMatchedText) {
                match.processSubMatches();
            }
        });
    }
}

/** 域匹配结果 */
class ScopeMatchResult extends MatchResult {
    beginMatch: MatchResult;
    endMatch: MatchResult;

    constructor(doc: TextDocument, scope: ScopePattern) {
        super(doc, scope);
        this.scope = scope.scope;
        this._forScope = true;
    }

    processSubMatches() {
        if (this.scope && this.scope.onMatched)
            this.scope.onMatched(this);

        let matchList: MatchResult[] = [this];
        for (let i = 0; i < matchList.length; i++) {
            const subMatch = matchList[i];
            if (i > 0) {
                subMatch.matchedScope = this;
                subMatch.matchedPattern = this.matchedPattern;
                if (subMatch instanceof ScopeMatchResult) {
                    subMatch.processSubMatches();
                    continue;
                }
                else if (subMatch instanceof PatternMatchResult) {
                    subMatch.processSubMatches();
                    continue;
                }
                else if (subMatch instanceof UnMatchedText) {
                    subMatch.processSubMatches();
                    continue;
                }
            }
            matchList = matchList.concat(subMatch.children);
        }
    }
}
/** 语法匹配结果 */
class GrammarMatchResult extends ScopeMatchResult {

    static initCallback: EmptyAction = null;
    static completionPostProcessing: CompletionPostProcessing = null;

    static disable = false;
    static shieldKeywordCompletion = false;

    grammar: LanguageGrammar;
    lastMatch: GrammarMatchResult = null;

    constructor(doc: TextDocument, grammar: Grammar) {
        super(doc, grammar);
        this.grammar = grammar.grammar;
    }

    requestCompletion(pos: CompletionParams): CompletionItem[] {
        if (GrammarMatchResult.initCallback != null)
            GrammarMatchResult.initCallback();

        GrammarMatchResult.disable = false;
        GrammarMatchResult.shieldKeywordCompletion = false;
        var completions = GrammarMatchResult.completionPostProcessing
            ? GrammarMatchResult.completionPostProcessing(this.requestCompletionInner(pos), pos)
            : this.requestCompletionInner(pos);

        if (!GrammarMatchResult.shieldKeywordCompletion)
            completions = completions.concat(teaBuiltinTypesCompletion).concat(teaBuiltinKeywordCompletion(pos));
        completions = linq.from(completions)
            .where((item: CompletionItem) => item !== undefined)
            .distinct((comp: CompletionItem) => comp.label)
            .toArray();

        return completions;
    }

    private requestCompletionInner(pos: CompletionParams): CompletionItem[] {
        let completions: CompletionItem[] = [];
        let isBreak = false;

        // 获得当前光标位置
        let match = this.locateMatchAtPosition(pos.position);
        if (!match) return completions;

        if (match instanceof UnMatchedPattern) {
            var info = match.requestCompletionWithBreak(pos.position);
            completions = info ? completions.concat(info.items) : completions;
            isBreak = info?.isBreak;
        }
        else if (match instanceof UnMatchedText) {
            completions = completions.concat(match.requestCompletion(pos.position));
        }
        else if (match instanceof GrammarMatchResult) {
            var compInfo = match.grammar.onCompletion ? match.grammar.onCompletion(match) : null
            completions = compInfo ? completions.concat(compInfo.items) : completions;

            isBreak = compInfo?.isBreak;
            GrammarMatchResult.shieldKeywordCompletion = true;
        }
        else if (match instanceof ScopeMatchResult) {
            var compInfo = match.scope.onCompletion ? match.scope.onCompletion(match) : null
            completions = compInfo ? completions.concat(compInfo.items) : completions;

            isBreak = compInfo?.isBreak;
            GrammarMatchResult.shieldKeywordCompletion = true;
        }

        if (GrammarMatchResult.disable) return [];
        for (let matchP = match; matchP != null && !isBreak; matchP = matchP.parent) {
            if (matchP instanceof PatternMatchResult && matchP.pattern.onCompletion) {
                const compInfo = matchP.pattern.onCompletion(matchP);
                completions = compInfo ? completions.concat(compInfo.items) : completions;
                isBreak ||= compInfo?.isBreak;
            }

            if (!matchP.patternName) continue;
            if (matchP.matchedPattern && matchP.matchedPattern.pattern.onCompletion) {
                const comps = matchP.matchedPattern.pattern.onCompletion(matchP);
                if (GrammarMatchResult.disable) return [];

                completions = comps ? completions.concat(comps.items) : completions;
                isBreak ||= comps?.isBreak;
            }

            if (matchP.matchedScope && matchP.matchedScope.scope.onCompletion) {
                const comps = matchP.matchedScope.scope.onCompletion(matchP);
                if (GrammarMatchResult.disable) return [];
                completions = comps ? completions.concat(comps.items) : completions;
                isBreak ||= comps?.isBreak;
            }
        }

        if (GrammarMatchResult.disable) return [];
        return completions;
    }

    requestHover(pos: Position): Promise<Hover> {
        // 获得当前光标位置
        const match = this.locateMatchAtPosition(pos);
        if (!match || !match.matched)
            return Promise.resolve({ contents: [""] });

        for (let matchP = match; matchP != null; matchP = matchP.parent) {
            if (matchP.pattern)
                if (matchP.pattern.onHover)
                    return matchP.pattern.onHover(match);
        }

        return Promise.resolve({
            contents: [""]
        });
    }
}

/** 未匹配文本 */
class UnMatchedText extends MatchResult {
    allMatches: MatchResult[];
    matched = false;
    protected _matchesList: MatchResult[] = null;

    protected get allSubMatches(): MatchResult[] {
        if (this.allMatches.length <= 0)
            return [];
        if (!this._matchesList) {
            let list = this.allMatches;
            for (let i = 0; i < list.length; i++) {
                if (list[i] instanceof PatternMatchResult || list[i] instanceof ScopeMatchResult || list[i] instanceof UnMatchedText)
                    continue;
                list = list.concat(list[i].children);
            }
            this._matchesList = list;
        }
        return this._matchesList;
    }

    constructor(doc: TextDocument, scope: GrammarScopeDeclare, matches: MatchResult[]) {
        super(doc, null);
        this.scope = scope;
        this.allMatches = matches;
    }

    processSubMatches() {
        this.allMatches.forEach(match => match.parent = this);
        this.allSubMatches.forEach(match => {
            match.matchedPattern = this.matchedPattern;
            match.matchedScope = this.matchedScope;
            if (match instanceof PatternMatchResult || match instanceof ScopeMatchResult || match instanceof UnMatchedText) {
                match.processSubMatches();
            }
        });
    }

    requestCompletion(pos: Position): CompletionItem[] {
        let completions: CompletionItem[] = [];
        let isBreak = false;

        this.allMatches.forEach(match => {
            if (isBreak) return;
            let endMatch = match.locateMatchAtPosition(pos);

            if (!endMatch) return;
            if (match instanceof UnMatchedPattern) {
                var info = match.requestCompletionWithBreak(pos);
                completions = info ? completions.concat(info.items) : completions;
                isBreak = info?.isBreak;
            }
            else if (endMatch instanceof UnMatchedText) completions = completions.concat(endMatch.requestCompletion(pos));

            for (let matchP = endMatch; matchP != this && !isBreak; matchP = matchP.parent) {
                if (!matchP.patternName) continue;
                if (matchP.unmatchedPattern && matchP.unmatchedPattern.pattern.onCompletion) {
                    const comps = matchP.unmatchedPattern.pattern.onCompletion(matchP);
                    completions = comps ? completions.concat(comps.items) : completions;
                    isBreak ||= comps?.isBreak;
                }
                else {
                    if (matchP.matchedPattern && matchP.matchedPattern.pattern.onCompletion) {
                        const comps = matchP.matchedPattern.pattern.onCompletion(matchP);
                        completions = comps ? completions.concat(comps.items) : completions;
                        isBreak ||= comps?.isBreak;
                    }
                    if (matchP.matchedScope && matchP.matchedScope.scope.onCompletion) {
                        const comps = matchP.matchedScope.scope.onCompletion(matchP);
                        completions = comps ? completions.concat(comps.items) : completions;
                        isBreak ||= comps?.isBreak;
                    }
                }
            }
        });

        if (this.matchedScope && this.matchedScope.scope && this.matchedScope.scope.onCompletion && !isBreak) {
            var compInfo = this.matchedScope.scope.onCompletion(this);
            completions = compInfo ? completions.concat(compInfo.items) : completions;
        }
        return completions;
    }

    addChildren(match: MatchResult) {
        match.parent = this;
        this.allMatches.push(match);
    }
}

/** 未匹配模板 */
class UnMatchedPattern extends UnMatchedText {
    constructor(doc: TextDocument, patternItem: PatternItem, matches: MatchResult[]) {
        super(doc, patternItem.pattern.scope, matches);
        this.patternItem = patternItem;
    }

    processSubMatches() {
        this.allMatches.forEach(match => match.parent = this);
        this.allSubMatches.forEach(match => {
            match.unmatchedPattern = this;
            match.matchedPattern = this.matchedPattern;
            match.matchedScope = this.matchedScope;
            if (match instanceof PatternMatchResult || match instanceof ScopeMatchResult || match instanceof UnMatchedText) {
                match.processSubMatches();
            }
        });
    }

    requestCompletionWithBreak(pos: Position): { items: CompletionItem[], isBreak: boolean } {
        let completions: CompletionItem[] = [];
        if (this.pattern.onCompletion) {
            const compInfo = this.pattern.onCompletion(this);
            completions = compInfo ? compInfo.items : super.requestCompletion(pos);
            if (compInfo && !compInfo.isBreak) {
                completions = completions.concat(super.requestCompletion(pos));
            }
            return { items: completions, isBreak: compInfo?.isBreak };
        }
        else return { items: super.requestCompletion(pos), isBreak: false };
    }

    getMatch(name: string): MatchResult[] {
        return linq.from(this.allSubMatches).where((match: MatchResult) => match.patternName === name).toArray();
    }
}

/** 模板声明 */
class PatternDictionary {
    [key: string]: GrammarPatternDeclare;
}

/** 域声明 */
class ScopeDictionary {
    [key: string]: GrammarScopeDeclare;
}

/** 域语法声明 */
class GrammarScopeDeclare {
    /** 开始模板 */
    begin: string[];
    /** 结束模板 */
    end: string[];
    /** 载入模式 */
    skipMode?: "line" | "space";
    /** 域内内容分解模板 */
    patterns?: GrammarPatternDeclare[];
    /** 嵌套域 */
    scopes?: GrammarScopeDeclare[];
    /** 名称 */
    name?: string;
    /** 排除的语法模板 */
    ignore?: GrammarPatternDeclare;
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

/** 全局域声明 */
class GlobalScopeDeclare extends GrammarScopeDeclare {
    onPatternMatched: PatternMatchedCallback;

    constructor(grammar: LanguageGrammar, onMatch: ScopeMatchedCallback) {
        super();
        this.begin = [""];
        this.end = [""];

        this.name = "GLOBAL";
        this.grammar = grammar;
        this.onMatched = (match) => {
            onMatch(match);
        };
    }
}

/** 模板语法声明 */
class GrammarPatternDeclare {
    /** 字符串标签 */
    static String: GrammarPatternDeclare = { patterns: ["<string>"], name: "String" };
    /** 数字标签 */
    static Number: GrammarPatternDeclare = { patterns: ['<number>'], name: "Number" };
    /** 命名标签 */
    static Identifier: GrammarPatternDeclare = { patterns: ['<identifier>'], name: "Identifier" };

    /** 模板集 */
    patterns: string[];
    /** 是否忽略大小写 */
    caseInsensitive?: boolean = true;
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
    /** 悬停提示时回调 */
    onHover?: DocumentHoverCallback;

    /** 父语法模板 */
    parent?: GrammarPatternDeclare;
    /** 在父语法模板中的名称 */
    nameInParent?: string;
    /** 域语法声明 */
    scope?: GrammarScopeDeclare;
    /** 语法模板 */
    compiledPattern?: PatternItem;
    /** 语法定义 */
    grammar?: LanguageGrammar;
    /** 编译时运行 */
    compiling?: boolean = false;
}

/** 语法定义 */
class LanguageGrammar {
    /** 具有显式域端点 */
    explicitScopeExtreme = false;

    // ---------------------------------------------
    /** 全局的语法模板 */
    patterns?: GrammarPatternDeclare[];
    /** 名称 */
    name?: string;
    /** 排除模板列表 */
    ignore?: GrammarPatternDeclare;
    /** 分隔符定义 */
    stringDelimiter?: string[];
    /** 符号对匹配(比如像括号、引号之类的) */
    pairMatch?: string[][];
    /** 模板声明 */
    patternRepository?: PatternDictionary;
    /** 域声明 */
    scopeRepository?: ScopeDictionary;

    onMatchedInit?: ScopeMatchedCallback;
    /** 补全时回调 */
    onCompletion?: DocumentCompletionCallback;
}

// ---------------------------------------------------------------- 相关方法
/**
 * 括号内模板分析:
 * 这里使用的括号有四种"[]"、"<>"、"{}"、"//", 分别标记"可有可无片段"、"引用的声明片段"、"域"、"正则表达式"
 * @param item 待分析字符串
 * @param pattern 分析使用的语法模板
 * @return 匹配模板
 */
function analyzeBracketItem(item: string, pattern: GrammarPatternDeclare): PatternItem {
    const buildInPattern: PatternItemDictionary = {
        "string": (pt: GrammarPatternDeclare) => new StringPattern(pt),
        "number": (pt: GrammarPatternDeclare) => new NumberPattern(pt),
        "identifier": (pt: GrammarPatternDeclare) => new IdentifierPattern(pt),
        " ": (pt: GrammarPatternDeclare) => new EmptyPattern(pt),
    };

    // 若是引用已声明的模板
    if (item[0] === "<" && item[item.length - 1] === ">") {
        let subPattern: PatternItem;
        // 获取模板名
        const name = item.substring(1, item.length - 1);

        // 寻找同名模板, 优先级: 内建模板-本地模板声明-全局模板声明-默认(命名模板)
        if (buildInPattern[name])
            subPattern = buildInPattern[name](pattern);
        else if (pattern.dictionary && pattern.dictionary[name]) {
            pattern.dictionary[name].grammar = pattern.grammar;
            subPattern = compilePattern(pattern.dictionary[name]);
        }
        else if (pattern.grammar.patternRepository && pattern.grammar.patternRepository[name]) {
            pattern.grammar.patternRepository[name].grammar = pattern.grammar;
            subPattern = compilePattern(pattern.grammar.patternRepository[name]);
        }
        else
            subPattern = new IdentifierPattern(pattern);

        // 是否可忽略模板
        subPattern.ignorable = false;
        // 以该模板名命名模板
        return new NamedPattern(pattern, name, subPattern);
    }
    // 若是该括号内的内容为可选内容
    else if (item[0] === "[" && item[item.length - 1] === "]") {
        // 去掉括号
        item = item.substring(1, item.length - 1);

        // 是否可重复
        let multi = false;

        // 如果结尾有...则为可重复
        if (item.endsWith("...")) {
            multi = true;
            item = item.substring(0, item.length - 3);
        }

        // 中间部分拿去做模板分析
        const subPattern = analyzePatternItem(item, pattern);

        // 可忽略、可重复
        subPattern.ignorable = true;
        subPattern.multi = multi;
        return subPattern;
    }
    // 若是该括号内的内容为域
    else if (item[0] === "{" && item[item.length - 1] === "}") {
        // 去掉括号
        const name = item.substring(1, item.length - 1);

        // 创建寻找域声明
        let scope: GrammarScopeDeclare;
        if (pattern.scopes && pattern.scopes[name])
            scope = pattern.scopes[name];
        else if (pattern.grammar.scopeRepository && pattern.grammar.scopeRepository[name])
            scope = pattern.grammar.scopeRepository[name];
        if (!scope)
            throw new Error("meta-grammar.analyzeBracketItem.error: 该模板域未定义");

        // 保存信息并整理
        scope.grammar = pattern.grammar;
        return compileScope(scope, pattern);
    }
    // 若是该括号内的内容是正则表达式
    else if (item.startsWith("/") && item.endsWith("/")) {
        const reg = item.substring(1, item.length - 1);

        // 创建正则表达式模板
        const subPattern = new RegExpPattern(pattern, new RegExp(reg, pattern.caseInsensitive ? "i" : ""), false);
        // 命名
        subPattern.name = reg;
        return subPattern;
    }

    throw new Error(
        "meta-grammar.analyzeBracketItem.error: 模板括号分析时发现语法错误, " +
        "涉及模板名: " + pattern?.name
    );
}

/**
 * 模板分析
 * @param item 待分析字符串
 * @param pattern 分析使用的语法模板
 * @returns 匹配模板
 */
function analyzePatternItem(item: string, pattern: GrammarPatternDeclare): PatternItem {
    // 一些重要元符号
    const bracketStart = ["<", "[", "{", "/"];
    const bracketEnd = [">", "]", "}", "/"];
    const spaceChars = [" "];

    // 字符串中是否存在开始括号
    const isBracketStart = (chr: string): boolean => bracketStart.indexOf(chr) >= 0;
    // 字符串中是否存在结束括号
    const isBracketEnd = (chr: string): boolean => bracketEnd.indexOf(chr) >= 0;
    // 字符串中是否有空格
    const isSpace = (chr: string): boolean => spaceChars.indexOf(chr) >= 0;

    // 状态: 没在括号内时、在括号内时
    enum State { CollectWords, MatchBracket }

    const patternItem: OrderedPatternSet = new OrderedPatternSet(pattern, false);

    let state: State = State.CollectWords;

    // 括号深度
    let bracketDepth = 0;
    // 单词
    let words = "";

    for (let i = 0; i < item.length; i++) {
        // 没在任何括号内时
        if (state === State.CollectWords) {
            // 当前字符为"\"
            if (item[i] === "\\") {
                // 将下一位字符放入单词中
                words += item[++i];
                continue;
            }
            // 当前字符是开始括号
            if (isBracketStart(item[i])) {
                // 若当前单词不为空
                if (words !== "")
                    // 根据当前单词新建单词模板
                    patternItem.addSubPattern(new TextPattern(pattern, words));

                // 现在单词的内容已经变成了当前开始括号
                words = item[i];
                // 状态修改为匹配括号
                state = State.MatchBracket;
                // 增加括号深度
                bracketDepth++;
                continue;
            }
            // 若当前字符是空格
            else if (isSpace(item[i])) {
                // 当单词不为空时新建单词模板
                if (words !== "")
                    patternItem.addSubPattern(new TextPattern(pattern, words));

                // 赋空
                words = "";

                // 如果决定保留空格, 则根据空格新建空格模板
                if (pattern.keepSpace)
                    patternItem.addSubPattern(new EmptyPattern(pattern, false));

                continue;
            }
            // 若当前字符是结束括号
            else if (isBracketEnd(item[i]))
                throw new Error(
                    "meta-grammar.analyzePatternItem.error: 闭合括号找不到对应的开始括号, " +
                    "涉及模板名: " + pattern?.name
                );

            // 其它字符则直接存入单词
            else {
                words += item[i];
                continue;
            }
        }
        // 在括号内时
        // 在这个条件判断中, 我期望把当前层括号内的所有内容都原封不动地读入
        // 然后括号内若还有括号, 则递归调用该函数进行解析
        else if (state === State.MatchBracket) {
            // 当前字母是"\"
            if (item[i] === "\\") {
                // 将当前位和下一位都加入单词
                words += (item[i] + item[++i]);
                continue;
            }

            words += item[i];

            // 当前字母是结束括号
            if (isBracketEnd(item[i])) {
                // 深度减
                bracketDepth--;
                // 若当前层读取完了, 递归解析该括号内的内容
                if (bracketDepth === 0) {
                    patternItem.addSubPattern(analyzeBracketItem(words, pattern));
                    words = "";
                    // 回到分词状态
                    state = State.CollectWords;
                    continue;
                }
            }
            // 若又有括号...
            else if (isBracketStart(item[i]))
                bracketDepth++;
        }
    }

    // 若该条模板分析完成且结尾还有一个词
    if (state === State.CollectWords && words !== "")
        // 创建该词的文本模板
        patternItem.addSubPattern(new TextPattern(pattern, words, false, pattern.caseInsensitive));
    // 若括号没闭合, 报错
    else if (state === State.MatchBracket && bracketDepth > 0)
        throw new Error(
            "meta-grammar.analyzePatternItem.error: 模板括号未闭合, " +
            "涉及模板名: " + pattern?.name
        );

    // 若依序组模板组无结果
    if (patternItem.subPatterns.length === 0)
        throw new Error(
            "meta-grammar.analyzePatternItem.error: 模板无内容, " +
            "涉及模板名: " + pattern?.name
        );

    // 若模板只有一个子模板
    else if (patternItem.subPatterns.length === 1) {
        // 该模板的可忽略性则直接受到它子模板的影响
        patternItem.subPatterns[0].ignorable = patternItem.ignorable;
        return patternItem.subPatterns[0];
    }
    return patternItem;
}

/**
 * 编译模板: 将模板语法声明整理为模板
 * @param pattern 语法模板
 * @returns 匹配模板
 */
function compilePattern(pattern: GrammarPatternDeclare): PatternItem {
    // 若该模板声明为字符串模板、已经预定义好的模板
    // 则直接返回
    if (pattern === GrammarPatternDeclare.String)
        return new StringPattern(pattern);
    if (pattern.compiledPattern)
        return pattern.compiledPattern;

    // ---------------------------------------- 开始编译语法声明
    pattern.compiling = true;
    // 先获得声明里用到的模板列表
    const patternList: OptionalPatternSet = new OptionalPatternSet(pattern, true);
    pattern.compiledPattern = patternList;
    pattern.patterns.forEach(pt => {
        // 子模板
        const subPattern = analyzePatternItem(pt, pattern);
        subPattern.strict = pattern.strict ? true : false;
        subPattern.ignorable = true;
        patternList.addSubPattern(subPattern);
    });

    if (patternList.count === 0)
        throw new Error(
            "meta-grammar.analyzePatternItem.error: 模板无内容, " +
            "涉及模板名: " + pattern?.name
        );

    // 模板列表只有一个
    if (patternList.count === 1) {
        if (patternList.subPatterns[0] == patternList)
            throw new Error(
                "meta-grammar.analyzePatternItem.error: 模板发生了循环定义, " +
                "涉及模板名: " + pattern?.name
            );
        // 一些其它设置
        if (!(pattern.id || pattern.onMatched || pattern.onCompletion || pattern.onDiagnostic)) {
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
function compileScope(scope: GrammarScopeDeclare, pattern: GrammarPatternDeclare): ScopePattern {
    // 若为已经预定义的模板
    if (scope.compiledPattern)
        return scope.compiledPattern;

    // ---------------------------------------- 开始编译域语法声明
    const patternList = new ScopePattern(pattern, scope);
    // 域的开始模板
    if (!scope.grammar?.explicitScopeExtreme) {
        const beginPatterns = new OptionalPatternSet(pattern, false);
        scope.begin.forEach(s => {
            beginPatterns.addSubPattern(new TextPattern(pattern, s, false));
        });
        patternList.addSubPattern(beginPatterns);
    }
    else {
        patternList.addSubPattern(new AllPattern(pattern));
    }
    scope.compiledPattern = patternList;

    // 域内的模板
    scope.patterns.forEach(pt => {
        pt.grammar = pattern.grammar;
        const subPattern = compilePattern(pt);
        subPattern.ignorable = true;
        subPattern.multi = true;

        // 当没有显式端点时不能直接嵌套域
        if (!scope.grammar?.explicitScopeExtreme) {
            if (patternList.name === subPattern.name)
                throw new Error(
                    "meta-grammar.analyzePatternItem.error: 在无端点域模板中发生了嵌套, " +
                    "涉及模板名: " + pattern?.name
                );
        }

        patternList.addSubPattern(subPattern);
    });

    // 域的结束模板
    const endPatterns = new OptionalPatternSet(pattern, false);
    scope.end.forEach(s => {
        endPatterns.addSubPattern(new TextPattern(pattern, s, false));
    });
    patternList.addSubPattern(endPatterns);
    // 名称(默认为Scope)
    patternList.name = scope.name ? scope.name : "Scope";
    return patternList;
}

/**
 * 编译语法定义
 * @param grammarDeclare 语法定义
 * @returns 语法模板
 */
function compileGrammar(grammarDeclare: LanguageGrammar): Grammar {
    const grammar = new Grammar(grammarDeclare);
    // 逐条编译语法内的声明
    grammarDeclare.patterns.forEach(pattern => {
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
function matchGrammar(grammar: Grammar, doc: TextDocument): GrammarMatchResult {
    return grammar.match(doc, 0);
}

/**
 * 加入模板
 * @param patternName 模板名
 * @returns 模板语法声明
 */
function includePattern(patternName: string): GrammarPatternDeclare {
    return { patterns: [`<${patternName}>`] };
}

/**
 * 命名模板
 * @param patternName 模板名称
 * @returns 模板语法声明
 */
function namedPattern(patternName: string): GrammarPatternDeclare {
    return { patterns: [`<${patternName}>`] };
}

/**
 * 从匹配结果中匹配结果
 * @param match 匹配结果
 * @param name 要匹配的模板
 * @param defaultValue 无匹配结果时传递的默认值
 * @returns 匹配结果的匹配结果
 */
function getMatchedProps(match: PatternMatchResult | UnMatchedPattern, name: string, defaultValue: string = null) {
    if (!match)
        return defaultValue;
    const value = match.getMatch(name)[0];
    if (!value)
        return defaultValue;
    return value.text;
}

// ----------------------------------------------------------------
export {
    LanguageGrammar,
    GrammarPatternDeclare,
    GrammarScopeDeclare,
    MatchResult,
    PatternMatchResult,
    ScopeMatchResult,
    UnMatchedPattern,
    GrammarMatchResult,

    includePattern,
    namedPattern,
    compileGrammar,
    matchGrammar,
    getMatchedProps
};