// ================================================================
// 构建 smbx teascript 的语法模板
// ================================================================

import { TeaContext, TeaVar, teaBuildinTypesCompletion } from './tea-context';
import { LanguageGrammar, GrammarPattern } from './meta-grammar';

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
        "varDeclare": {
            name: "Var Declare",
            crossLine: true,
            patterns: [
                "Dim <name> [= <expression>] [, <name> [= <expression>] ...] As <type>"
            ],
            dictionary: {
                "type": GrammarPattern.Identifier,
                "name": GrammarPattern.Identifier,
            },
            onMatched: (metch) =>
            {
                const type = metch.getMatch("type")[0].text;
                const name = metch.getMatch("name")[0].text;
                const context = metch.matchedScope.state as TeaContext;
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
        },
        // 函数参数声明
        "funcParamsDeclare": {
            name: "Params Declare",
            patterns: ["<name> As <type> [= <expression>]"],
            dictionary: {
                "type": GrammarPattern.Identifier,
                "name": GrammarPattern.Identifier,
            },
        },
        // 函数体定义
        "funcDefinition": {
            name: "Function Definition",
            patterns: ["[Export] Script <name>([<funcParamsDeclare>][,<funcParamsDeclare>...][,Return <type>]){block} End Script"],
            dictionary: {
                "type": GrammarPattern.Identifier,
                "name": GrammarPattern.Identifier,
            },
            crossLine: true,
            // onMatched: onFunctionMatch,
            onCompletion: (match) =>
            {
                if (match.patternName === "type")
                {
                    return teaBuildinTypesCompletion;
                }
                return [];
            }
        },
        // 函数调用定义
        "funcCall": {
            name: "Function Call",
            patterns: ["<identifier> (<expression> [, <expression> ...])"]
        }
    }
};

// ----------------------------------------------------------------
export default teaGrammarParttern;