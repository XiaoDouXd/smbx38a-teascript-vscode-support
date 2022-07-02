// ================================================================
// 构建 smbx teascript 的语法模板
// ================================================================

import { 
    TeaContext, TeaVar, TeaFunc, 
    teaBuildinTypesCompletion, teaGlobalContext,
    createCompletionItemsForFunc,
    createCompletionItemsForVar
} from './tea-context';
import { getObjectType } from './tea-matchfunctions';
import { LanguageGrammar, GrammarPattern, getMatchedProps, includePattern } from './meta-grammar';
import { CompletionItemKind } from 'vscode-languageserver';

/** tea 语言的语法模板 */
const teaGrammarParttern: LanguageGrammar = {
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
            "/' * '/",
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
                "type": GrammarPattern.Identifier,
                "name": GrammarPattern.Identifier,
            },
            onMatched: (match) =>
            {
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
                            patterns: ["++", "--","\\[<expression>\\]"]
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
                if (match.patternName === "expr-unit")
                {
                    return createCompletionItemsForVar(context.getAllVariables())
                        .concat(createCompletionItemsForFunc(teaGlobalContext.functions));
                }
                else if (match.patternName === "operator")
                {
                    if (match.text === ".")
                    {
                        const context = match.matchedScope.state as TeaContext;
                        const prevIdx = match.parent.parent.children.indexOf(match.parent) - 1;
                        const prevMatch = match.parent.parent.children[prevIdx];
                        const type = getObjectType(prevMatch,context);
                        if (type.orderedMenber)
                        {
                            // 排序基数
                            const base = 1000;
                            return type.members.map((member, idx) =>
                            {
                                return {
                                    label: member.name,
                                    detail: member.toString(),
                                    sortText: (base + idx).toString(),
                                    kind: CompletionItemKind.Field
                                };
                            });
                        }
                        else
                        {
                            return type.members.map((member) =>
                            {
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
                "type": GrammarPattern.Identifier,
                "name": GrammarPattern.Identifier,
            },
            onMatched: (match)=>{
                const type = getMatchedProps(match, "type");
                const name = getMatchedProps(match, "name");
                const func = match.matchedPattern.state as TeaFunc;
                func.addParameter(new TeaVar(teaGlobalContext.getType(type), name));
            }
        },
        // 函数体定义
        "func-definition": {
            name: "Function Definition",
            patterns: ["[Export] Script <name>([<func-params-declare>][,<func-params-declare>...][,Return <type>]){block} End Script"],
            dictionary: {
                "type": GrammarPattern.Identifier,
                "name": GrammarPattern.Identifier,
            },
            crossLine: true,
            onMatched: (match)=>{
                const type = getMatchedProps(match, "type");
                const name = getMatchedProps(match, "name");
                const func = new TeaFunc(teaGlobalContext.getType(type), name);
                teaGlobalContext.addFunction(func);
                match.state = func;
            },
            onCompletion: (match) =>
            {
                if (match.patternName === "type")
                {
                    return teaBuildinTypesCompletion;
                }
                return [];
            }
        },

        // ------------------------------------------- 调用定义
        // Call 修饰的函数调用
        "func-call-prefix": {
            name: "Function Call Prefix",
            patterns: ["Call <identifier>(<expression> [, <expression> ...])"]
        },
        // 变量函数调用
        "func-call-val": {
            name: "Function Call Var",
            patterns: ["<name>(<var-name>)"],
            dictionary: {
                "name": {
                    patterns: [
                        "Array", "Val", "GVal"
                    ],
                },
                "var-name": GrammarPattern.Identifier
            }
        },
        // 函数调用
        "func-call": {
            name: "Function Call",
            patterns: ["<name>(<expression> [, <expression> ...])"],
            dictionary: {
                "name": {
                    patterns: [
                        "<identifier>"
                    ],
                    ignore: /(Array|Val|GVal)/g
                }
            }
        }
    },
    scopeRepository: {
        "block": {
            name : "block",
            begin: "",
            end: "",
            patterns: [
                includePattern("varDeclare"),
                {
                    name: "Statement",
                    id:"statement",
                    patterns: ["<expression>"]
                },
                {
                    name: "If",
                    id:"if-structure",
                    patterns: ["If [<expression>] Then {block} [<elseif-block> ...] [<else-block>] End If"]
                },
                {
                    name: "For Loop",
                    id:"for-structure",
                    patterns: ["For <val> {block} next"]
                }
            ]
        }
    }
};

// ----------------------------------------------------------------
export default teaGrammarParttern;