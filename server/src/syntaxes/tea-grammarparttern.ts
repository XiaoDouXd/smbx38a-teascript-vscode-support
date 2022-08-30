// ================================================================
// 构建 smbx teascript 的语法模板
// ================================================================

import {
    TeaContext, TeaVar, TeaFunc,
    teaBuildinTypesCompletion,
    createCompletionItemsForFunc,
    createCompletionItemsForVar,
    TeaGlobalContext,
    TeaType,
    teaBuildinKeywordCompletion
} from './tea-context';
import { LanguageGrammar, GrammarPatternDeclare, getMatchedProps, includePattern, MatchResult, PatternMatchResult, GrammarMatchResult } from './meta-grammar';
import { CompletionItemKind } from 'vscode-languageserver';

// ----------------------------------------------------------------

/** 获得对象类型 */
function getObjectType(match: MatchResult, context: TeaContext): TeaType {
    const reg = /([_a-zA-Z][_a-zA-Z0-9]*)(\([.]*\))*/;
    let name = "";

    if (match.children.length === 2) {
        if (match.children[0].text === ".") {
            const prevIdx = match.parent.children.indexOf(match) - 1;
            const prevMatch = match.parent.children[prevIdx];
            const t = getObjectType(prevMatch, context);
            const name = match.children[1].text;
            const result = reg.exec(name);
            return t.getMember(result[1]).type;
        }
        name = match.children[1].text;
    }
    else {
        name = match.text;
    }
    const result = reg.exec(name);

    if (!result)
        return null;

    if (result.length <= 2) {
        const v = context.getVariable(result[1]);
        return v ? v.type : null;
    }
    else {
        const f = context.getFunc(result[1]);
        return f ? f.type : null;
    }
}
/** 表达式匹配回调 */
function onExpressionMatch(match: MatchResult) {
    const context = match.matchedScope.state as TeaContext;
    if (match.patternName === "expr-unit") {
        if (match.text === ".") {
            GrammarMatchResult.shieldKeywordCompletion = true;
            return context.getAllVariables().map(v => {
                if (v.dotFlag)
                    return {
                        label: v.name,
                        kind: CompletionItemKind.Variable,
                        detail: v.toString()
                    };
            });
        }

        return createCompletionItemsForVar(context.getAllVariables(), match.startOffset)
            .concat(createCompletionItemsForFunc(context.global.functions, match.startOffset));
    }
    else if (match.patternName === "operator") {
        if (match.text === ".") {
            GrammarMatchResult.shieldKeywordCompletion = true;
            const context = match.matchedScope.state as TeaContext;
            const prevIdx = match.parent.parent.children.indexOf(match.parent) - 1;
            const prevMatch = match.parent.parent.children[prevIdx];
            const type = getObjectType(prevMatch, context);

            if (!type)
                return [];

            if (type.orderedMenber) {
                // 排序基数
                const base = 1000;
                return type.members.map((member, idx) => {
                    return {
                        label: member.name,
                        detail: member.toString(),
                        sortText: (base + idx).toString(),
                        kind: CompletionItemKind.Field
                    };
                });
            }
            else {
                return type.members.map((member) => {
                    return {
                        label: member.name,
                        detail: member.toString(),
                        kind: CompletionItemKind.Field
                    };
                });
            }
        }
    }
    return [];
}

// ----------------------------------------------------------------

/** tea 语言的语法模板 */
const teaGrammarParttern: LanguageGrammar = {
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
                // ---------- 声明和定义
                "<var-declare>",
                "<func-definition>",
                "<goto-flag>",

                // ---------- 逻辑结构
                "<if-structure>",
                "<for-loop>",
                "<dow-loop>",
                "<do-loopw>",
                "<do-loop>",
                "<with-structure>",
                "<select-structure>",

                // ---------- 表达式和跳转
                "<expression>",
                "<func-call-prefix>",
                "<goto-call>",
            ]
        }
    ],
    patternRepository: {
        // 变量定义
        "var-declare": {
            name: "Var Declare",
            crossLine: true,
            patterns: [
                "Dim <name> [, <name> ...] As <type>"
            ],
            dictionary: {
                "type": GrammarPatternDeclare.Identifier,
                "name": GrammarPatternDeclare.Identifier,
            },
            onMatched: (match) => {
                const type = match.getMatch("type")[0].text;
                const name = match.getMatch("name")[0].text;
                const context = match.matchedScope.state as TeaContext;
                const va = new TeaVar(context.getType(type), name);
                va.pos = match.endOffset;
                context.addVariable(va);
            },
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
                        "/(((\\+|-|\\*|\\/|%|=|&|\\||\\^|<>|<<|>>|<|>|<=|>=|==)=?)|(\\.|\\?|~|,)|(And|Or|Xor|Eqv|Imp|and|or|xor|eqv|imp))/"
                    ]
                }
            },
            onCompletion: onExpressionMatch,
        },
        "expression-unstrict": {
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
            onCompletion: onExpressionMatch
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
                const func = match.matchedPattern.state as TeaFunc;
                func.addParameter(new TeaVar(func.functionContext.getType(type), name));
            }
        },
        // 函数体定义
        "func-definition": {
            name: "Function Definition",
            patterns: ["[Export] Script <name>([<func-params-declare>][, <func-params-declare>...][, Return <type>]) {block} End Script"],
            dictionary: {
                "type": GrammarPatternDeclare.Identifier,
                "name": GrammarPatternDeclare.Identifier,
            },
            crossLine: true,
            onMatched: (match) => {
                const type = getMatchedProps(match, "type");
                const name = getMatchedProps(match, "name");

                const context = match.matchedScope.state as TeaContext;
                const func = new TeaFunc(context.getType(type), name);
                func.pos = match.startOffset;
                context.global.addFunction(func);

                const con = new TeaContext();
                context.addContext(con);
                func.setFunctionContext(con);

                match.state = func;
            },
            onCompletion: (match) => {
                if (match.patternName === "type") {
                    return teaBuildinTypesCompletion;
                }
                return [];
            }
        },
        // 对象调用
        "object": {
            name: "Objcet",
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
                const name = match.text;
                const context = match.matchedScope.state as TeaContext;
                if (!context)
                    return Promise.resolve({ contents: [""], });

                const o = context.global.getFunc(name);
                return Promise.resolve({ contents: [`${o ? o : ""}`], });
            }
        },
        // 变量函数调用
        "func-call-val": {
            name: "Function Call Var",
            patterns: ["<name>(<expression>)"],
            dictionary: {
                "name": {
                    patterns: [
                        "Array", "Val", "GVal"
                    ],
                },
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
                    ignore: /(Array|Val|GVal)/g
                }
            },
            onHover: (match) => {
                const name = getMatchedProps(match.matchedPattern, "name");
                const context = match.matchedScope.state as TeaContext;
                if (!context)
                    return Promise.resolve({ contents: [""], });

                const o = context.global.getFunc(name);
                return Promise.resolve({ contents: [`${o ? o : ""}`], });
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
            name: "Condiction",
            patterns: ["<expression-unstrict>"]
        },
        "if-structure": {
            name: "If Structure",
            patterns: ["If <cond> Then [{block}] [ElseIf <cond> Then [{block}] ...] [Else [{block}]] End If"]
        },
        "for-loop": {
            name: "For Loop",
            patterns: ["For <cond> To <cond> [Step <cond>] [{block}] Next"]
        },
        "dow-loop": {
            name: "Do While Loop",
            patterns: ["Do /(While|Until)/ <cond> [{block}] Loop"]
        },
        "do-loopw": {
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
                    patterns: ["<func-call-val>", "<func-call>", "<identifier>"]
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
                const context = match.matchedScope.state as TeaContext;
                if (!context)
                    return Promise.resolve({ contents: [""], });

                const o = context.getVariable(name);
                return Promise.resolve({ contents: [`${o ? o : ""}`], });
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
                includePattern("do-loopw"),
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
                            patterns: ["/[_a-zA-Z0-9]+\\r\\n/"]
                        }
                    }
                }
            ],

            onMatched: (match) => {
                if (match.matchedPattern.state instanceof TeaFunc) {
                    const func = match.matchedPattern.state as TeaFunc;
                    match.state = func.functionContext;
                    return;
                }
                match.state = new TeaContext();
                (match.matchedScope.state as TeaContext).addContext(match.state as TeaContext);
            },
            onCompletion: (match) => {
                if (match.matchedPattern.patternName !== "no-sense")
                    return [];
                const context = (match.matchedScope.state as TeaContext);
                if (!context) return [];

                return teaBuildinTypesCompletion
                    .concat(teaBuildinKeywordCompletion);
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
                includePattern("do-loopw"),
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
                            patterns: ["/[_a-zA-Z0-9]+\\r\\n/"]
                        }
                    }
                }
            ],

            onMatched: (match) => {
                const typeName = getMatchedProps(match.parent.matchedPattern, "var-open");
                const reg = /([_a-zA-Z][_a-zA-Z0-9]*)(\([.]*\))*/;

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
                if (match.matchedPattern.patternName !== "no-sense")
                    return [];
                const context = (match.matchedScope.state as TeaContext);
                if (!context) return [];

                return teaBuildinTypesCompletion
                    .concat(teaBuildinKeywordCompletion);
            }
        }
    }
};

// ----------------------------------------------------------------
export default teaGrammarParttern;