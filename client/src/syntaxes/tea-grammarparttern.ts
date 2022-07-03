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
        ["\"", "\""],
        ["'", "'"]
    ],
    ignore: {
        patterns: [
            "'*"
        ]
    },

    // ------------------------------------------- 语法定义
    // 全局的语法模板
    patterns: [
        {
            name: "Global",
            id: "global",
            patterns: [
                "<var-declare>",
                "<func-definition>",
                "<expression>",

            ]
        }
    ],
    patternRepository: {
        // 变量定义
        "var-declare": {
            name: "Var Declare",
            crossLine: true,
            patterns: [
                "Dim <name> [= <expression>] [, <name> [= <expression>] ...] As <type>"
            ],
            dictionary: {
                "type": GrammarPatternDeclare.Identifier,
                "name": GrammarPatternDeclare.Identifier,
            },
            onMatched: (match) => {
                const type = match.getMatch("type")[0].text;
                const name = match.getMatch("name")[0].text;
                const context = match.matchedScope.state as TeaContext;
                // context.addVariable(new TeaVar(context.getType(type), name));
            },
        },
        // 表达式定义
        "expression": {
            name: "Expression",
            patterns: [
                "<expr-unit> [<operator> <expr-unit> ...]"
            ],
            strict: true,
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
                                "<bracket>",
                            ]
                        },
                        "unary-operator": {
                            name: "Unary Operator",
                            patterns: ["!", "+", "-", "~", "++",
                                "--", "*", "&", " Not ", " And ",
                                " Or ", " Xor ", " Eqv ", " Imp "]
                        },
                        "postfix": {
                            name: "Postfix Operator",
                            patterns: ["++", "--", "\\[<expression>\\]"]
                        }
                    }
                },
                "operator": {
                    name: "Operator",
                    patterns: ["/(((\\+|-|\\*|\\/|%|=|&|\\||\\^|<<|>>)=?)|(<|>|<=|>=|==|\\!=|\\|\\||&&)|(\\.|\\?|\\:|~|,))/"]
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
                // const func = match.matchedPattern.state as TeaFunc;
                // func.addParameter(new TeaVar(func.functionContext.getType(type), name));
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
                // const func = new TeaFunc(context.getType(type), name);
                // context.addFunction(func);
                // match.state = func;
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
                "<func-call-val>", "identifier"
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
        }
    },
    scopeRepository: {
        "block": {
            name: "Block",
            begin: [""],
            end: ["End If", "ElseIf", "Else", "End Script", "End With", "Next", "Loop", "End Select"],

            patterns: [
                includePattern("var-declare"),
                {
                    name: "Statement",
                    id: "statement",
                    patterns: ["<expression>"]
                },
                {
                    name: "If",
                    id: "if-structure",
                    patterns: ["If <expression> Then {block} [ElseIf <expression> Then {block} ...] [Else {block}] End If"]
                },
                {
                    name: "For Loop",
                    id: "for-loop",
                    patterns: ["For <func-call-val>=<expression> To <expression> [Step <number>] {block} next"],
                },
                {
                    name: "Do While Loop",
                    id: "dow-loop",
                    patterns: ["Do /(While|Until)/ {block} Loop"]
                },
                {
                    name: "Do Loop While",
                    id: "do-loop",
                    patterns: ["Do {block} Loop /(While|Until)/"]
                },
                {
                    name: "With",
                    id: "with-structure",
                    patterns: ["With <func-call-val> {block} End With"]
                }
            ],
        }
    }
};

// ----------------------------------------------------------------
export default teaGrammarParttern;