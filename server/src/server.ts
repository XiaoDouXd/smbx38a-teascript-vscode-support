// ================================================================
// 服务端初始化和事件响应设置
// ================================================================

import { configure, getLogger } from "log4js";
configure({
    appenders: {
        smbx_tea: {
            type: "dateFile",
            filename: "./xiaodou_logs/smbx_tea",
            pattern: "yyyy-MM-dd-hh.log",
            alwaysIncludePattern: true,
        },
    },
    categories: { default: { appenders: ["smbx_tea"], level: "debug" } }
});

const logger = getLogger("smbx_tea");

import {
    createConnection,
    TextDocuments,
    ProposedFeatures,
    InitializeParams,
    CompletionItem,
    InitializeResult,
    HoverParams,
    Hover,
    CompletionParams,
    WorkspaceFolder,
    WorkDoneProgress,
    CompletionItemKind,
} from 'vscode-languageserver/node';
import { TextDocument } from 'vscode-languageserver-textdocument';
import teaGrammarPattern from './syntaxes/tea-grammar-pattern';
import teaBuiltinContext from './syntaxes/tea-builtin-context';
import { TeaGlobalContext, exportFunc, globalValue } from './syntaxes/tea-context';
import { matchGrammar, compileGrammar, GrammarMatchResult } from './syntaxes/meta-grammar';
import linq = require("linq");

// ---------------------------------------------------------------- 初始化连接对象

// 初始化 LSP 连接对象
// 连接对象对客户端-服务端的信息交互进行了封装
// 协议中的所有的消息都有封装
const connection = createConnection(ProposedFeatures.all);
const documentList = new Map<string, TextDocument>();
const documents: TextDocuments<TextDocument> = new TextDocuments(TextDocument);

// 编译和初始化语法模板
const compiledTeaGrammar = compileGrammar(teaGrammarPattern);
TeaGlobalContext.loadBuiltinContext(teaBuiltinContext);
const documentMatch = new Map<string, GrammarMatchResult>();
function getMatch(uri: string, isUpdate: boolean = false): GrammarMatchResult {
    if (!documentList.has(uri))
        return null;
    if (isUpdate) {
        exportFunc.delete(uri);
        globalValue.delete(uri);
        documentMatch.set(uri, matchGrammar(compiledTeaGrammar, documentList.get(uri)));
    }
    return documentMatch.get(uri);
}

// 一些跨文件信息
const exportCompletionInfos: CompletionItem[] = [];

// ---------------------------------------------------------------- 初始化事件响应

// 服务端的声明周期从客户端发送 Initialize 请求开始
// 本部分主要用于设置客户端事件该如何响应

// 声明周期开始时会运行这个 onInitialize 函数
// 该函数主要用于告知客户端该服务端支持的特性
// 该信息用 capabilities: ServerCapabilities 类传递
// ServerCapabilities 主要包括了 Workspace 和 TextDocument 两个方面的API
connection.onInitialize((params: InitializeParams) => {
    // 明确声明插件支持的语言特性
    const result: InitializeResult = {
        capabilities: {
            // 增量处理
            // textDocumentSync: TextDocumentSyncKind.Incremental,

            // 代码补全
            completionProvider: {
                // resolveProvider: true,
                triggerCharacters: ["."]
            },

            // 悬停提示
            hoverProvider: true,
            // // 签名提示
            // signatureHelpProvider: {
            //   triggerCharacters: ["("],
            // },
            // // 格式化
            // documentFormattingProvider: true,
            // // 语言高亮
            // documentHighlightProvider: true,
        },
    };
    return result;
});

// 完成握手后 客户端会返回 initialized notification 事件
// 可以使用下面方法设置接收的响应
connection.onInitialized(() => {
    console.log("SMBX tea intellisense start.");
    connection.window.showInformationMessage('smbx38a teascript support start.');
});

// -------------------------------------------------------------- 设置工作区事件响应

// -------------------------------------------------------------- 设置文档事件响应
documents.onDidOpen(e => {
    documentList.set(e.document.uri, e.document);
    documentMatch.set(e.document.uri, matchGrammar(compiledTeaGrammar, e.document));
    getMatch(e.document.uri, true);
});

documents.onDidChangeContent(e => {
    exportCompletionInfos.length = 0;
    getMatch(e.document.uri, true);

    exportFunc.forEach((v, k) => {
        if (k == e.document.uri) return;
        v.forEach(i => {
            exportCompletionInfos.push(i.toCompletionItem())
        })
    })
    globalValue.forEach((v, k) => {
        v.forEach(i => {
            exportCompletionInfos.push({
                label: i,
                kind: CompletionItemKind.Field,
                detail: "GlobalVar 全局变量",
            })
        })
    })
});

documents.onDidClose(e => {
    exportFunc.delete(e.document.uri);
    globalValue.delete(e.document.uri);
    documentList.delete(e.document.uri);
    documentMatch.delete(e.document.uri);
});

connection.onCompletion((docPos: CompletionParams): CompletionItem[] => {
    try {
        return getMatch(docPos.textDocument.uri)
            ?.requestCompletion(docPos)
            .concat(exportCompletionInfos);
    }
    catch (ex) {
        console.error(ex);
    }
});

// 悬停事件
connection.onHover((params: HoverParams): Promise<Hover> => {
    try {
        return documentMatch.get(params.textDocument.uri)?.requestHover(params.position);
    }
    catch (ex) {
        console.error(ex);
    }
});

// -------------------------------------------------------------- 开启事件监听
connection.listen();
documents.listen(connection);


// 增量错误诊断
// documents.onDidChangeContent((change) => {
//   const textDocument = change.document;

//   // 若出现了两个以上长度的大写字符
//   const text = textDocument.getText();
//   const pattern = /\b[A-Z]{2,}\b/g;
//   let m: RegExpExecArray | null;

//   let problems = 0;
//   const diagnostics: Diagnostic[] = [];
//   while ((m = pattern.exec(text))) {
//     problems++;
//     const diagnostic: Diagnostic = {
//       severity: DiagnosticSeverity.Warning,
//       range: {
//         start: textDocument.positionAt(m.index),
//         end: textDocument.positionAt(m.index + m[0].length),
//       },
//       message: `${m[0]} is all uppercase.`,
//       source: "Diagnostics Test",
//     };
//     diagnostics.push(diagnostic);
//   }

//   // 向 vsc 发送诊断
//   connection.sendDiagnostics({ uri: textDocument.uri, diagnostics });
// });

// 开启连接对象和文档对象监听事件


// // 悬停事件
// connection.onHover((params: HoverParams): Promise<Hover> => {
//   return Promise.resolve({
//     contents: ["..."],
//   });
// });

// // 文档格式化事件
// connection.onDocumentFormatting(
//   (params: DocumentFormattingParams): Promise<TextEdit[]> => {
//     const { textDocument } = params;
//     const doc = documents.get(textDocument.uri)!;
//     const text = doc.getText();
//     const pattern = /\b[A-Z]{3,}\b/g;
//     let match;
//     const res = [];
//     while ((match = pattern.exec(text))) {
//       res.push({
//         range: {
//           start: doc.positionAt(match.index),
//           end: doc.positionAt(match.index + match[0].length),
//         },
//         newText: match[0].replace(/(?<=[A-Z])[A-Z]+/, (r) => r.toLowerCase()),
//       });
//     }

//     return Promise.resolve(res);
//   }
// );

// // 文档字符高亮事件
// connection.onDocumentHighlight(
//   (params: DocumentHighlightParams): Promise<DocumentHighlight[]> => {
//     const { textDocument } = params;
//     const doc = documents.get(textDocument.uri)!;
//     const text = doc.getText();
//     const pattern = /\b\b/i;
//     const res: DocumentHighlight[] = [];
//     let match;
//     while ((match = pattern.exec(text))) {
//       res.push({
//         range: {
//           start: doc.positionAt(match.index),
//           end: doc.positionAt(match.index + match[0].length),
//         },
//         kind: DocumentHighlightKind.Write,
//       });
//     }
//     return Promise.resolve(res);
//   }
// );

// // 函数签名
// connection.onSignatureHelp(
//   (params: SignatureHelpParams): Promise<SignatureHelp> => {
//     return Promise.resolve({
//       signatures: [
//         {
//           label: "Signature Demo",
//           documentation: "human readable content",
//           parameters: [
//             {
//               label: "@p1 first param",
//               documentation: "content for first param",
//             },
//           ],
//         },
//       ],
//       activeSignature: 0,
//       activeParameter: 0,
//     });
//   }
// );

// // 代码补充详情
// connection.onCompletionResolve((item: CompletionItem): CompletionItem => {
//   console.log("request completion resolve");

//   if (item.data === 1) {
//     item.detail = "TypeScript is Awesome";
//     item.documentation = "...so on and so on";
//   } else if (item.data === 2) {
//     item.detail = "TypeScript is better then Javascript";
//     item.documentation = "...so on and so on";
//   }
//   return item;
// });