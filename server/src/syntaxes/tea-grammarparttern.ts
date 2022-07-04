// ================================================================
// 构建 smbx teascript 的语法模板
// ================================================================

import {
    TeaContext, TeaVar, TeaFunc,
    teaBuildinTypesCompletion,
    createCompletionItemsForFunc,
    createCompletionItemsForVar,
    TeaGlobalContext
} from './tea-context';
import { getObjectType } from './tea-matchfunctions';
import { LanguageGrammar, GrammarPatternDeclare, getMatchedProps, includePattern } from './meta-grammar';
import { CompletionItemKind } from 'vscode-languageserver';

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
            "'*"
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
                context.addVariable(new TeaVar(context.getType(type), name));
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
            onCompletion: (match) => {
                const context = match.matchedScope.state as TeaContext;
                if (match.patternName === "expr-unit") {
                    return createCompletionItemsForVar(context.getAllVariables())
                        .concat(createCompletionItemsForFunc(context.global.functions));
                }
                else if (match.patternName === "operator") {
                    if (match.text === ".") {
                        const context = match.matchedScope.state as TeaContext;
                        const prevIdx = match.parent.parent.children.indexOf(match.parent) - 1;
                        const prevMatch = match.parent.parent.children[prevIdx];
                        const type = getObjectType(prevMatch, context);
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
            },
        },
        "expression-unstrict": {
            name: "Expression",
            patterns: [
                "<expr-unit> [<operator> <expr-unit> ...]"
            ],
            crossLine: true,
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
            onCompletion: (match) => {
                const context = match.matchedScope.state as TeaContext;
                if (match.patternName === "expr-unit") {
                    return createCompletionItemsForVar(context.getAllVariables())
                        .concat(createCompletionItemsForFunc(context.global.functions));
                }
                else if (match.patternName === "operator") {
                    if (match.text === ".") {
                        const context = match.matchedScope.state as TeaContext;
                        const prevIdx = match.parent.parent.children.indexOf(match.parent) - 1;
                        const prevMatch = match.parent.parent.children[prevIdx];
                        const type = getObjectType(prevMatch, context);
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
            },
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
            patterns: ["[Export] Script <name>([<func-params-declare>][,<func-params-declare>...][,Return <type>]) {block} End Script"],
            dictionary: {
                "type": GrammarPatternDeclare.Identifier,
                "name": GrammarPatternDeclare.Identifier,
            },
            crossLine: true,
            onMatched: (match) => {
                const type = getMatchedProps(match, "type");
                const name = getMatchedProps(match, "name");
                const context = match.matchedScope.state as TeaGlobalContext;
                const func = new TeaFunc(context.getType(type), name);
                context.addFunction(func);
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
                // match
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
            patterns: ["Call <identifier>(<expression> [, <expression> ...])"]
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
                // match
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
            patterns: ["For <func-call-val>=<expression> To <expression> [Step <expression>] [{block}] Next"],
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
            patterns: ["With <var-open> {block} End With"],
            dictionary: {
                "var-open": {
                    name: "Var Opened",
                    patterns: ["<func-call-val>", "<func-call>", "<identifier>"]
                }
            },
            onMatched: (match) => {
                const varOpen = getMatchedProps(match, "var-open");
            },
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
            }
        }
    },
    scopeRepository: {
        "block": {
            name: "Block",
            begin: [""],
            end: [
                "End If",
                "ElseIf",
                "Else",
                "End Script",
                "End With",
                "Next",
                "Loop",
                "End Select"
            ],

            patterns: [
                includePattern("var-declare"),
                includePattern("func-call-prefix"),
                includePattern("if-structure"),
                includePattern("for-loop"),
                includePattern("dow-loop"),
                includePattern("do-loopw"),
                includePattern("with-structure"),
                includePattern("do-loop"),
                {
                    name: "Statement",
                    id: "statement",
                    patterns: ["<expression>"]
                }
            ],

            onMatched: (match) => {
                match.state = new TeaContext();
                (match.matchedScope.state as TeaContext).addContext(match.state as TeaContext);
                if (match.matchedPattern.state instanceof TeaFunc) {
                    match.matchedPattern.state.setFunctionContext(match.state);
                }
            }
        }
    }
};

// ----------------------------------------------------------------
export default teaGrammarParttern;