// ================================================================
// 构建 smbx tea script 的语法模板
// ================================================================

import {
    TeaContext, TeaVar, TeaFunc,
    teaBuiltinTypesCompletion,
    createCompletionItemsForFunc,
    createCompletionItemsForVar,
    TeaGlobalContext,
    TeaType,
    teaBuiltinKeywordCompletion,
    exportFunc,
    globalValue
} from './tea-context';
import { LanguageGrammar, GrammarPatternDeclare, getMatchedProps, includePattern, MatchResult, GrammarMatchResult } from './meta-grammar';
import { CompletionItemKind, CompletionItem } from 'vscode-languageserver';

// ----------------------------------------------------------------

let isInDim = false;
let isInBlock = false;
let isShowExportedFunc = true;

GrammarMatchResult.initCallback = () => {
    isInDim = false;
    isInBlock = false;
    isShowExportedFunc = true;
}

GrammarMatchResult.completionPostProcessing = (items, params) => {
    if (items.length <= 0) {
        items = items.concat(teaBuiltinKeywordCompletion(params))
        if (isShowExportedFunc)
            exportFunc.forEach((v, k) => {
                if (k == params.textDocument.uri) return;
                v.forEach(i => {
                    items.push(i.toCompletionItem())
                })
            })
        return items;
    }

    if (isInDim && !isInBlock) return teaBuiltinKeywordCompletion(params);
    else {
        if (isShowExportedFunc)
            exportFunc.forEach((v, k) => {
                if (k == params.textDocument.uri) return;
                v.forEach(i => {
                    items.push(i.toCompletionItem())
                })
            })
        return items;
    }
}

/** 获得对象类型 */
function getObjectType(match: MatchResult, context: TeaContext): TeaType | null {
    if (!match || !context) return null;
    const reg = /([_a-zA-Z][_a-zA-Z0-9]*)(\s*\(.*\))?/;
    let name = "";

    // 处理点访问形态: prev.sub
    if (match.children && match.children.length === 2) {
        if (match.children[0].text === ".") {
            const prevIdx = match.parent.children.indexOf(match) - 1;
            const prevMatch = match.parent.children[prevIdx];
            const t = getObjectType(prevMatch, context);
            if (!t) return null;
            const childName = match.children[1].text;
            const r = reg.exec(childName);
            if (!r) return null;
            const member = t.getMember(r[1]);
            return member ? member.type : null;
        }
        name = match.children[1].text;
    }
    else {
        name = match.text;
    }

    const result = reg.exec(name);
    if (!result) return null;

    // 修复点: 旧实现用 result.length 判断是否函数调用,
    // 但 RegExp.exec 的 length 总是分组数+1, 永远走变量分支.
    // 这里改为检测是否真的捕获到了括号(分组2).
    const isCall = !!result[2];
    if (isCall) {
        const f = context.getFunc(result[1]);
        return f ? f.type : null;
    }
    const v = context.getVariable(result[1]);
    return v ? v.type : null;
}

/** 表达式匹配回调 */
function onExpressionCompletion(match: MatchResult): { items: CompletionItem[], isBreak: boolean } {
    const context = match.matchedScope.state as TeaContext;
    if (match.patternName === "expr-unit") {
        if (match.text === ".") {
            isShowExportedFunc = false;
            return {
                items: context.getAllVariables().map(v => {
                    if (v.dotFlag)
                        return {
                            label: v.name,
                            kind: CompletionItemKind.Variable,
                            detail: v.toString()
                        };
                }), isBreak: true
            };
        }

        return {
            items: createCompletionItemsForVar(context.getAllVariables(), match.startOffset)
                .concat(createCompletionItemsForFunc(context.global.functions, match.startOffset)),
            isBreak: false
        }
    }
    else if (match.patternName === "operator") {
        GrammarMatchResult.shieldKeywordCompletion = true;
        if (match.text.endsWith('.')) {
            isShowExportedFunc = false;
            const context = match.matchedScope.state as TeaContext;
            const prevIdx = match.parent.parent.children.indexOf(match.parent) - 1;
            const prevMatch = match.parent.parent.children[prevIdx];
            const type = getObjectType(prevMatch, context);

            if (!type) return { items: [], isBreak: false };

            if (type.orderedMember) {
                // 排序基数
                const base = 1000;
                return {
                    items: type.members.map((member, idx) => {
                        return {
                            label: member.name,
                            detail: member.toString(),
                            sortText: (base + idx).toString(),
                            kind: CompletionItemKind.Field
                        };
                    }), isBreak: true
                };
            }
            else {
                return {
                    items: type.members.map((member) => {
                        return {
                            label: member.name,
                            detail: member.toString(),
                            kind: CompletionItemKind.Field
                        };
                    }), isBreak: true
                };
            }
        }
    }

    if (match.text === "" || match.text.endsWith(".")) {
        const context = match.matchedScope.state as TeaContext;
        const prevIdx = match.parent.parent.children.indexOf(match.parent) - 1;
        const prevMatch = match.parent.parent.children[prevIdx];
        const type = prevMatch ? getObjectType(prevMatch, context) : null;

        if (!type) return { items: [], isBreak: false };
        isShowExportedFunc = false;
        GrammarMatchResult.shieldKeywordCompletion = true;
        if (type.orderedMember) {
            // 排序基数
            const base = 1000;
            return {
                items: type.members.map((member, idx) => {
                    return {
                        label: member.name,
                        detail: member.toString(),
                        sortText: (base + idx).toString(),
                        kind: CompletionItemKind.Field
                    };
                }), isBreak: true
            };
        }
        else {
            return {
                items: type.members.map((member) => {
                    return {
                        label: member.name,
                        detail: member.toString(),
                        kind: CompletionItemKind.Field
                    };
                }), isBreak: true
            };
        }
    }

    return {
        items: [],
        isBreak: false
    };
}

// ----------------------------------------------------------------

/** tea 语言的语法模板 */
const teaGrammarPattern: LanguageGrammar = {
    explicitScopeExtreme: false,
    stringDelimiter: ["\""],
    pairMatch: [
        ["(", ")"],
        ["[", "]"],
        ["{", "}"],
        ["\"", "\""]
    ],
    ignore: {
        patterns: [
            "/'[.]*/"
        ]
    },
    onMatchedInit: (match) => {
        match.state instanceof TeaGlobalContext;
        match.state = new TeaGlobalContext();
    },

    // ------------------------------------------- 语法定义
    // 全局的语法模板
    patterns: [
        {
            name: "Global",
            id: "global",
            patterns: [
                // ---------- 表达式和跳转
                "<expression>",
                "<func-call-prefix>",
                "<goto-call>",

                // ---------- 声明和定义
                "<var-declare>",
                "<func-definition>",
                "<goto-flag>",

                // ---------- 逻辑结构
                "<if-structure>",
                "<for-loop>",
                "<dow-loop>",
                "<do-loop-w>",
                "<do-loop>",
                "<with-structure>",
                "<select-structure>",
            ]
        }
    ],
    patternRepository: {
        // 变量定义
        "var-declare": {
            name: "Var Declare",
            patterns: [
                "Dim <name> [, <name> ...] As <type> [= <expression>]"
            ],
            dictionary: {
                "type": GrammarPatternDeclare.Identifier,
                "name": GrammarPatternDeclare.Identifier,
            },
            onMatched: (match) => {
                const type = match.getMatch("type")[0]?.text;
                const names = match.getMatch("name");
                if (!type || !names || names.length === 0) return;
                const context = match.matchedScope.state as TeaContext;
                if (!context) return;
                isInDim = true;
                // 修复点: 旧实现只把第一个 name 入符号表
                // 'Dim a, b, c As Integer' 中 b/c 会丢失
                for (const n of names) {
                    if (!n.text) continue;
                    const va = new TeaVar(context.getType(type), n.text);
                    va.pos = match.endOffset;
                    context.addVariable(va);
                }
            },
            onCompletion: (_m) => {
                GrammarMatchResult.shieldKeywordCompletion = false;
                return { items: teaBuiltinTypesCompletion, isBreak: false };
            }
        },
        // 表达式定义
        "expression": {
            name: "Expression",
            patterns: [
                "<expr-unit> [<operator> <expr-unit> ...]"
            ],
            strict: true,
            dictionary: {
                "expr-unit": {
                    name: "Expression Unit with Operator",
                    patterns: ["[<unary-operator> ...]<unit>[<postfix>]"],
                    dictionary: {
                        "unit": {
                            name: "Expression Unit",
                            patterns: [
                                "<func-call-val>",
                                "<func-call>",
                                "<var>",
                                "<number>",
                                "<string>",
                                "<dot-op>",
                                "<bracket>"
                            ]
                        },
                        "unary-operator": {
                            name: "Unary Operator",
                            patterns: ["!", "+", "-", "~", "++",
                                "--", "*", "&", "not", "Not"]
                        },
                        "postfix": {
                            name: "Postfix Operator",
                            patterns: ["++", "--", "\\[<expression>\\]"]
                        }
                    }
                },
                "operator": {
                    name: "Operator",
                    patterns: [
                        "/(((\\+|-|\\*|\\/|%|=|&|\\||\\^|<>|<<|>>|<|>|<=|>=|==)=?)|(\\.|\\?|~|,)|(And|Or|Xor|Eqv|Imp|and|or|xor|eqv|imp|Mod|mod))/"
                    ]
                }
            },
            onCompletion: onExpressionCompletion,
        },
        "expression-un-strict": {
            name: "Expression",
            strict: false,
            patterns: [
                "<expr-unit> [<operator> <expr-unit> ...]"
            ],
            dictionary: {
                "expr-unit": {
                    name: "Expression Unit with Operator",
                    patterns: ["[<unary-operator> ...]<unit>[<postfix>]"],
                    dictionary: {
                        "unit": {
                            name: "Expression Unit",
                            patterns: [
                                "<func-call-val>",
                                "<func-call>",
                                "<identifier>",
                                "<number>",
                                "<string>",
                                "<dot-op>",
                                "<bracket>"
                            ]
                        },
                        "unary-operator": {
                            name: "Unary Operator",
                            patterns: ["!", "+", "-", "~", "++",
                                "--", "*", "&", "not", "Not"]
                        },
                        "postfix": {
                            name: "Postfix Operator",
                            patterns: ["++", "--", "\\[<expression>\\]"]
                        }
                    }
                },
                "operator": {
                    name: "Operator",
                    patterns: [
                        "/(((\\+|-|\\*|\\/|%|=|&|\\||\\^|<>|<<|>>|<|>|<=|>=|==)=?)|(\\.|\\?|~|,)|(And|Or|Xor|Eqv|Imp|and|or|xor|eqv|imp))/"
                    ]
                }
            },
            onCompletion: onExpressionCompletion
        },
        // 括号表达式定义
        "bracket": {
            name: "Bracket",
            patterns: ["(<expression>)"]
        },
        // 函数参数声明
        "func-params-declare": {
            name: "Params Declare",
            patterns: ["<name> As <type> [= <expression>]"],
            dictionary: {
                "type": GrammarPatternDeclare.Identifier,
                "name": GrammarPatternDeclare.Identifier,
            },
            onMatched: (match) => {
                const type = getMatchedProps(match, "type");
                const name = getMatchedProps(match, "name");
                const func = match.matchedPattern?.state as TeaFunc;
                func?.addParameter(new TeaVar(func.functionContext.getType(type), name));
            }
        },
        // 函数体定义
        "func-definition": {
            name: "Function Definition",
            patterns: [
                "[Export] Script <name>([<func-params-declare>][, <func-params-declare>...][, Return <type>]) {block} End Script",
                "[Export] Script <name>(Return <type>) {block} End Script"
            ],
            dictionary: {
                "type": GrammarPatternDeclare.Identifier,
                "name": GrammarPatternDeclare.Identifier,
            },
            crossLine: true,
            onMatched: (match) => {
                const type = getMatchedProps(match, "type");
                const name = getMatchedProps(match, "name");
                if (!name) return;

                const context = match.matchedScope.state as TeaContext;
                if (!context) return;
                const func = new TeaFunc(context.getType(type || "Void"), name);

                if (/^\s*Export\b/i.test(match.text)) {
                    let tempList = exportFunc.get(match.document.uri);
                    if (!tempList) {
                        tempList = [];
                        exportFunc.set(match.document.uri, tempList);
                    }
                    tempList.push(func);
                    func.export = true;
                }

                func.pos = match.startOffset;
                context.global.addFunction(func);

                // 修复点: 旧实现先 context.addContext(con), 再 func.setFunctionContext(con)
                // 后者会再做一次 global.addContext, 导致 con 同时挂在两个父节点上,
                // 也会让函数参数被注入两遍.
                const con = new TeaContext();
                con.global = context.global;
                context.addContext(con);
                func.setFunctionContext(con);

                match.state = func;
            },
            onCompletion: (match) => {
                if (match.patternName === "type") {
                    return { items: teaBuiltinTypesCompletion, isBreak: false };
                }
                return { items: [], isBreak: false };
            }
        },
        // 对象调用
        "object": {
            name: "Object",
            crossLine: true,
            patterns: [
                "<func-call-val>", "<identifier>"
            ],
            onMatched: (match) => {
                // match
            }
        },
        // goto 目标声明
        "goto-flag": {
            name: "GoTo Flag",
            patterns: ["<name>:"],
            dictionary: {
                "name": GrammarPatternDeclare.Identifier
            },
            onMatched: (match) => {
                // ToDo: GoTo 语句的识别其实并未完善 小豆 20220704
            }
        },
        // 变量
        "var": {
            name: "Var",
            ignore: /(Do|do|Loop|loop|Else|else)/,
            patterns: [
                "<identifier>"
            ]
        },

        // ------------------------------------------- 调用定义
        // Call 修饰的函数调用
        "func-call-prefix": {
            name: "Function Call Prefix",
            crossLine: true,
            patterns: ["Call <fname>([<expression>] [, <expression> ...])"],
            dictionary: {
                "fname": {
                    patterns: ["<identifier>"]
                }
            },
            onHover: (match) => {
                // 修复点: 旧实现把整个 'Call funcName(...)' 文本作为函数名查询, 永远查不到.
                // 现在只取 fname 子节点.
                const name = getMatchedProps(match.matchedPattern, "fname");
                const context = match.matchedScope?.state as TeaContext;
                if (!name || !context)
                    return Promise.resolve({ contents: [""] });

                const o = context.global.getFunc(name);
                return Promise.resolve({ contents: [`${o ? o.toString() : ""}`] });
            },
            onCompletion: (_m) => {
                GrammarMatchResult.shieldKeywordCompletion = true;
                return { items: [], isBreak: false };
            }
        },
        // 变量函数调用
        "func-call-val": {
            name: "Function Call Var",
            strict: false,
            patterns: ["<name>(<val>)", "Array(<val>(<expression>))"],
            dictionary: {
                "name": {
                    patterns: [
                        "Array", "Val", "GVal"
                    ],
                },
                "val": GrammarPatternDeclare.Identifier
            },
            onMatched: (match) => {
                const val = getMatchedProps(match, "val");
                if (!val) return;
                let tempList = globalValue.get(match.document.uri);
                if (!tempList) {
                    tempList = [];
                    globalValue.set(match.document.uri, tempList);
                }
                // 同一文档内同名 global var 只记一次, 避免补全列表里重复
                if (!tempList.includes(val)) tempList.push(val);
            },
            onCompletion: (_match) => {
                const seen = new Set<string>();
                const exportCompletionInfos: CompletionItem[] = [];
                globalValue.forEach((v) => {
                    v.forEach(i => {
                        if (seen.has(i)) return;
                        seen.add(i);
                        exportCompletionInfos.push({
                            label: i,
                            kind: CompletionItemKind.Field,
                            detail: "GlobalVar 全局变量",
                        });
                    });
                });
                GrammarMatchResult.shieldKeywordCompletion = true;
                return { items: exportCompletionInfos, isBreak: true };
            }
        },
        // 函数调用
        "func-call": {
            name: "Function Call",
            patterns: ["<name>(<expression> [, <expression> ...])"],
            crossLine: true,
            dictionary: {
                "name": {
                    patterns: [
                        "<identifier>"
                    ],
                    // 修复点: 旧实现带 /g 标志的正则在反复 exec 时会保留 lastIndex,
                    // 造成跨调用结果漂移. 这里去掉 g 标志.
                    ignore: /^(Array|Val|GVal|Str|GStr|GV|V)$/i
                }
            },
            onHover: (match) => {
                const name = getMatchedProps(match.matchedPattern, "name");
                const context = match.matchedScope?.state as TeaContext;
                if (!name || !context) return Promise.resolve({ contents: [""] });
                const o = context.global.getFunc(name);
                return Promise.resolve({ contents: [`${o ? o.toString() : ""}`] });
            },
            onCompletion: (_match) => {
                GrammarMatchResult.shieldKeywordCompletion = true;
                return { items: [], isBreak: false };
            }
        },
        // goto 语句
        "goto-call": {
            name: "GoTo Call",
            patterns: ["GoTo <name>"],
            dictionary: {
                name: GrammarPatternDeclare.Identifier
            },
            onMatched: (match) => {
                // ToDo: GoTo 语句的识别其实并未完善 小豆 20220704
            }
        },

        // ------------------------------------------- 逻辑结构
        "cond": {
            name: "Condition",
            patterns: ["<expression-un-strict>"],
            onCompletion: (match) => {
                GrammarMatchResult.shieldKeywordCompletion = true;
                return { items: [], isBreak: true };
            }
        },
        "if-structure": {
            name: "If Structure",
            // 优先匹配多行形态; 多行不成功(Then 后有非空非注释内容)时再尝试单行形态.
            // 单行形态: If <cond> Then <statement>  -- 整行包含一条语句, 无 End If.
            // (来源: wiki TeaScript Syntax - Shortcut if statement)
            patterns: [
                "If <cond> Then [{block}] [ElseIf <cond> Then [{block}] ...] [Else [{block}]] End If",
                "If <cond> Then <if-line-stmt>"
            ],
            dictionary: {
                // 单行 If 的 then 部分: 同行剩余的非空非注释内容
                // - 首字符不能是 '  (排除 "If x Then ' comment" 误识)
                // - 不允许换行 (避免吞下下一行)
                "if-line-stmt": {
                    name: "If Line Statement",
                    patterns: ["/[^'\\r\\n][^\\r\\n]*/"]
                }
            }
        },
        "for-loop": {
            name: "For Loop",
            patterns: ["For <cond> To <cond> [Step <cond>] [{block}] Next"]
        },
        "dow-loop": {
            name: "Do While Loop",
            patterns: ["Do /(While|Until)/ <cond> [{block}] Loop"]
        },
        "do-loop-w": {
            name: "Do Loop While",
            crossLine: true,
            patterns: ["Do [{block}] Loop /(While|Until)/ <cond>"]
        },
        "do-loop": {
            name: "Do Loop",
            crossLine: true,
            patterns: ["Do [{block}] Loop"]
        },
        "with-structure": {
            name: "With",
            patterns: ["With <var-open> {with-block} End With"],
            dictionary: {
                "var-open": {
                    name: "Var Opened",
                    patterns: ["<func-call>", "<func-call-val>", "<identifier>"],
                    onCompletion: (m) => {
                        GrammarMatchResult.shieldKeywordCompletion = true;
                        const context = m.matchedScope.state as TeaContext;
                        return {
                            items: createCompletionItemsForVar(context.getAllVariables(), m.startOffset)
                                .concat(createCompletionItemsForFunc(context.global.functions, m.startOffset)), isBreak: true
                        }
                    }
                }
            },
            onMatched: (match) => {
                //
            }
        },
        "select-structure": {
            name: "Select Structure",
            patterns: ["Select Case <cond> [{block}] [Case <cond> [{block}] ...] [Case Else [{block}]] End Select"]
        },

        // ------------------------------------------- 点操作
        "dot-op": {
            name: "Dot Operation",
            patterns: [".<field>"],
            dictionary: {
                "field": {
                    name: "Field",
                    patterns: [
                        "<identifier>",
                        "<func-call>"
                    ]
                }
            },
            onHover: (match) => {
                const name = getMatchedProps(match.matchedPattern, "field");
                const context = match.matchedScope?.state as TeaContext;
                if (!name || !context) return Promise.resolve({ contents: [""] });

                const o = context.getVariable(name);
                return Promise.resolve({ contents: [`${o ? o.toString() : ""}`] });
            }
        }

    },
    scopeRepository: {
        "block": {
            name: "Block",
            begin: [""],
            end: [
                "Next",
                "End If",
                "ElseIf",
                "Else",
                "End Script",
                "End With",
                "Loop",
                "End Select",
                "Case Else",
                "Case"
            ],

            patterns: [
                includePattern("var-declare"),
                includePattern("func-definition"),
                includePattern("func-call-prefix"),
                includePattern("if-structure"),
                includePattern("for-loop"),
                includePattern("dow-loop"),
                includePattern("do-loop-w"),
                includePattern("with-structure"),
                includePattern("do-loop"),
                includePattern("select-structure"),
                {
                    name: "Statement",
                    id: "statement",
                    patterns: ["<expression>"]
                },
                {
                    name: "No sense code",
                    patterns: ["<no-sense>"],
                    dictionary: {
                        "no-sense": {
                            // 修复点: 旧实现只匹配 \r\n, 在 Unix(LF) 行尾文件下完全失效
                            patterns: ["/[_a-zA-Z0-9]+\\r?\\n/"]
                        }
                    }
                }
            ],

            onMatched: (match) => {
                if (match.matchedPattern?.state instanceof TeaFunc) {
                    const func = match.matchedPattern?.state as TeaFunc;
                    match.state = func.functionContext;
                    return;
                }
                const newCtx = new TeaContext();
                const upper = (match.matchedScope?.state as TeaContext);
                if (upper) {
                    newCtx.global = upper.global;
                    upper.addContext(newCtx);
                }
                match.state = newCtx;
            },
            onCompletion: (match) => {
                isInBlock = true;
                GrammarMatchResult.shieldKeywordCompletion = match.text.trimEnd().endsWith('.');
                isShowExportedFunc = !GrammarMatchResult.shieldKeywordCompletion;
                if (match.matchedPattern.patternName !== "no-sense")
                    return { items: [], isBreak: false };
                const context = (match.matchedScope.state as TeaContext);
                if (!context) return { items: [], isBreak: false };

                return { items: teaBuiltinTypesCompletion, isBreak: false };
            }
        },
        "with-block": {
            name: "With Block",
            begin: [""],
            end: [
                "End With",
            ],

            patterns: [
                includePattern("var-declare"),
                includePattern("func-definition"),
                includePattern("func-call-prefix"),
                includePattern("if-structure"),
                includePattern("for-loop"),
                includePattern("dow-loop"),
                includePattern("do-loop-w"),
                includePattern("with-structure"),
                includePattern("do-loop"),
                includePattern("select-structure"),
                {
                    name: "Statement",
                    id: "statement",
                    patterns: ["<expression>"]
                },
                {
                    name: "No sense code",
                    patterns: ["<no-sense>"],
                    dictionary: {
                        "no-sense": {
                            patterns: ["/[_a-zA-Z0-9]+\\r?\\n/"]
                        }
                    }
                }
            ],

            onMatched: (match) => {
                const typeName = getMatchedProps(match.parent.matchedPattern, "var-open");
                const reg = /([_a-zA-Z][_a-zA-Z0-9]*)(\([.]*\))*/i;

                const result = reg.exec(typeName);
                match.state = new TeaContext();
                const context = match.matchedScope.state as TeaContext;
                context.addContext(match.state as TeaContext);
                const contextThis = match.state as TeaContext;

                if (!result)
                    return;

                let type: TeaType;
                if (result.length <= 2) {
                    const v = contextThis.getVariable(result[1]);
                    type = v ? v.type : null;
                }
                else {
                    const f = contextThis.getFunc(result[1]);
                    type = f ? f.type : null;
                }

                if (!type)
                    return;

                // 成员展开
                type.members.forEach(m => {
                    m.dotFlag = true;
                    contextThis.addVariable(m);
                });
            },
            onCompletion: (match) => {
                isInBlock = true;
                GrammarMatchResult.shieldKeywordCompletion = match.text.trimEnd().endsWith('.');
                isShowExportedFunc = !GrammarMatchResult.shieldKeywordCompletion;
                if (match.matchedPattern.patternName !== "no-sense")
                    return { items: [], isBreak: false };
                const context = (match.matchedScope.state as TeaContext);
                if (!context) return { items: [], isBreak: false };

                return { items: teaBuiltinTypesCompletion, isBreak: false };
            }
        }
    }
};

// ----------------------------------------------------------------
export default teaGrammarPattern;