// ================================================================
// 服务端初始化和事件响应设置
// ================================================================

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
    TextDocumentSyncKind,
} from 'vscode-languageserver/node';
import { TextDocument } from 'vscode-languageserver-textdocument';
import teaGrammarPattern from './syntaxes/tea-grammar-pattern';
import teaBuiltinContext from './syntaxes/tea-builtin-context';
import { TeaGlobalContext, exportFunc, globalValue } from './syntaxes/tea-context';
import { matchGrammar, compileGrammar, GrammarMatchResult } from './syntaxes/meta-grammar';

// ---------------------------------------------------------------- 初始化连接对象

// 初始化 LSP 连接对象
const connection = createConnection(ProposedFeatures.all);
const documentList = new Map<string, TextDocument>();
const documents: TextDocuments<TextDocument> = new TextDocuments(TextDocument);

// 编译语法模板（仅一次, 编译结果在所有文档间共享）
const compiledTeaGrammar = compileGrammar(teaGrammarPattern);
TeaGlobalContext.loadBuiltinContext(teaBuiltinContext);

// ---------------------------------------------------------------- 文档级缓存
/**
 * 每个文档持有一份缓存:
 *  - version:  文本版本号, 用于判断是否需要重新解析
 *  - match:    上一次解析得到的 GrammarMatchResult
 *  - parsing:  是否正在解析中(避免重入)
 *  - dirty:    解析过程中是否又有新的修改进来
 *  - timer:    防抖定时器
 */
interface DocumentCache {
    version: number;
    match: GrammarMatchResult | null;
    parsing: boolean;
    dirty: boolean;
    timer: NodeJS.Timeout | null;
}
const documentCache = new Map<string, DocumentCache>();

/** 防抖延迟(ms): 输入停止后才重新解析整篇文档 */
const DEBOUNCE_MS = 150;

function getCache(uri: string): DocumentCache {
    let c = documentCache.get(uri);
    if (!c) {
        c = { version: -1, match: null, parsing: false, dirty: false, timer: null };
        documentCache.set(uri, c);
    }
    return c;
}

/** 同步执行一次解析(用于补全/悬停立刻需要结果的场合) */
function parseSync(uri: string): GrammarMatchResult | null {
    const doc = documentList.get(uri);
    if (!doc) return null;
    const cache = getCache(uri);
    // 已是最新版本则复用
    if (cache.match && cache.version === doc.version) return cache.match;

    // 重新解析: 在解析之前清掉旧的跨文件符号
    exportFunc.delete(uri);
    globalValue.delete(uri);

    const m = matchGrammar(compiledTeaGrammar, doc);
    if (m) {
        m.lastMatch = cache.match;
        cache.match = m;
        cache.version = doc.version;
    }
    return cache.match;
}

/** 延迟解析: 短时间内的连续输入只触发一次解析 */
function scheduleParse(uri: string) {
    const cache = getCache(uri);
    if (cache.timer) clearTimeout(cache.timer);
    cache.timer = setTimeout(() => {
        cache.timer = null;
        try {
            parseSync(uri);
        }
        catch (ex) {
            connection.console.error(`parseSync failed: ${String(ex)}`);
        }
    }, DEBOUNCE_MS);
}

// ---------------------------------------------------------------- 初始化事件响应

connection.onInitialize((_params: InitializeParams) => {
    const result: InitializeResult = {
        capabilities: {
            textDocumentSync: TextDocumentSyncKind.Incremental,
            completionProvider: {
                triggerCharacters: ["."]
            },
            hoverProvider: true,
        },
    };
    return result;
});

connection.onInitialized(() => {
    connection.console.log("SMBX tea intellisense started.");
});

// -------------------------------------------------------------- 文档生命周期
documents.onDidOpen(e => {
    documentList.set(e.document.uri, e.document);
    // 打开时立刻同步解析一次(用户往往会立刻查看补全/悬停)
    parseSync(e.document.uri);
});

documents.onDidChangeContent(e => {
    documentList.set(e.document.uri, e.document);
    scheduleParse(e.document.uri);
});

documents.onDidClose(e => {
    const cache = documentCache.get(e.document.uri);
    if (cache?.timer) clearTimeout(cache.timer);
    exportFunc.delete(e.document.uri);
    globalValue.delete(e.document.uri);
    documentList.delete(e.document.uri);
    documentCache.delete(e.document.uri);
});

// -------------------------------------------------------------- 补全/悬停
connection.onCompletion((docPos: CompletionParams): CompletionItem[] => {
    try {
        const m = parseSync(docPos.textDocument.uri); // 强制同步, 保证结果与当前文档一致
        return m ? m.requestCompletion(docPos) : [];
    }
    catch (ex) {
        connection.console.error(`onCompletion error: ${String(ex)}`);
        return [];
    }
});

connection.onHover((params: HoverParams): Promise<Hover> | Hover => {
    try {
        const m = parseSync(params.textDocument.uri);
        return m ? m.requestHover(params.position) : { contents: [""] };
    }
    catch (ex) {
        connection.console.error(`onHover error: ${String(ex)}`);
        return { contents: [""] };
    }
});

// -------------------------------------------------------------- 启动
connection.listen();
documents.listen(connection);
