# LSP 通信与扩展开发

本文聚焦"VSCode 扩展 + Language Server"的接线方式，以及如何在它们之上扩展功能。

## 一、扩展清单 (`package.json`)

```jsonc
{
    "name": "teascript-for-smbx38a",
    "publisher": "xiaodouxd",
    "engines": { "vscode": "^1.68.0" },
    "activationEvents": ["onLanguage:smbxtea"],
    "main": "./client/out/extension",
    "contributes": {
        "languages": [{ "id": "smbxtea", "extensions": [".smt"], "configuration": "./language-configuration.json" }],
        "grammars":  [{ "language": "smbxtea", "scopeName": "source.smt", "path": "./syntaxes/smbxtea.tmLanguage.json" }],
        "snippets":  [{ "language": "shaderlab", "path": "./snippets/smbxtea.json" }]
    }
}
```

注意：

1. `activationEvents` 只声明了 `onLanguage:smbxtea`，因此**仅打开 `.smt` 文件时**扩展才会激活。
2. `main` 指向的是 client 编译产物 `client/out/extension.js`。
3. `snippets` 当前为空，且语言 ID 写的是 `shaderlab`（疑似笔误），实际通过 LSP 推送代码片段。

## 二、客户端 (`client/src/extension.ts`)

```ts
export function activate(context: ExtensionContext) {
    const serverModule = context.asAbsolutePath(path.join('server', 'out', 'server.js'));
    const serverOptions: ServerOptions = {
        run:   { module: serverModule, transport: TransportKind.ipc },
        debug: { module: serverModule, transport: TransportKind.ipc, options: { execArgv: ['--nolazy', '--inspect=6009'] } }
    };
    const clientOptions: LanguageClientOptions = {
        documentSelector: [{ scheme: 'file', language: 'smbxtea' }],
        synchronize: { fileEvents: [workspace.createFileSystemWatcher('**/.clientrc')] }
    };
    client = new LanguageClient('smbxteaLanguageServer', 'SMBXTea Language Server', serverOptions, clientOptions);
    client.start();
}
```

要点：

- **传输层**：使用 IPC（进程间管道），而非 stdio/socket。
- **debug 模式**：启动参数 `--inspect=6009`，可直接用 VSCode "Attach to Server" 调试。
- **同步事件**：仅同步 `**/.clientrc` 文件变更（其实 TeaScript 用不到，遗留模板）。
- 客户端逻辑非常薄，**所有语言能力都在服务端**。

## 三、服务端 (`server/src/server.ts`)

### 3.1 启动 & 能力声明

```ts
const connection = createConnection(ProposedFeatures.all);
const documents  = new TextDocuments(TextDocument);

connection.onInitialize((params) => ({
    capabilities: {
        completionProvider: { triggerCharacters: ["."] },
        hoverProvider: true
    }
}));
```

声明了两类能力：

| 能力 | 行为 |
| --- | --- |
| `completionProvider` | 用户输入或显式触发 (`Ctrl+Space`)；触发字符 `.` 让点操作能即时弹出 |
| `hoverProvider` | 鼠标悬停显示 |

注释中还预留了未启用的 `signatureHelpProvider` / `documentFormattingProvider` / `documentHighlightProvider` 等扩展点。

### 3.2 文档生命周期

```ts
documents.onDidOpen(e => {
    documentList.set(e.document.uri, e.document);
    documentMatch.set(e.document.uri, matchGrammar(compiledTeaGrammar, e.document));
    getMatch(e.document.uri, true);
});

documents.onDidChangeContent(e => getMatch(e.document.uri, true));

documents.onDidClose(e => {
    exportFunc.delete(e.document.uri);
    globalValue.delete(e.document.uri);
    documentList.delete(e.document.uri);
    documentMatch.delete(e.document.uri);
});
```

- 维护两张 Map：`documentList`（uri → TextDocument）、`documentMatch`（uri → 上一次匹配结果）。
- `getMatch(uri, isUpdate)`：增量场景下重新执行 `matchGrammar`，并把新结果挂到 `documentMatch`，同时把新结果的 `lastMatch` 指向旧结果（**当前未被任何地方使用**，预留给增量分析）。
- 文档变更时**没有节流/防抖**，每次按键都会重新整体匹配；对大文件性能可能不佳。

### 3.3 请求处理

```ts
connection.onCompletion((docPos) => {
    return getMatch(docPos.textDocument.uri)?.requestCompletion(docPos);
});

connection.onHover((params) => {
    return documentMatch.get(params.textDocument.uri)?.requestHover(params.position);
});
```

直接转发到 `GrammarMatchResult` 提供的方法。所有具体逻辑（沿父链回溯、合并候选、去重）都在 `meta-grammar.ts` 中实现。

### 3.4 启动监听

```ts
connection.listen();
documents.listen(connection);
```

## 四、贡献点详解

### 4.1 `language-configuration.json`

| 字段 | 内容 |
| --- | --- |
| `comments.lineComment` | `'`（VBScript 风格行注释） |
| `brackets` / `autoClosingPairs` / `surroundingPairs` | `[]`、`()`、`""` |
| `folding.markers` | 用正则识别 `Script/If/With/Do/For` 与对应的 `End/Loop/Next` |
| `indentationRules` | 同样基于正则，控制进入/退出缩进 |

> 折叠正则中存在**小瑕疵**：模式中带有 `[.]*` 这样的写法，按 RegExp 语法应是 `.*`（`[.]` 仅匹配字面 `.`）。这是历史遗留，目前对体验影响有限。

### 4.2 `syntaxes/smbxtea.tmLanguage.json`

这是**着色用**的 TextMate 语法（与服务端的 IntelliSense 是两套系统）：

- `keywords`：覆盖 `Script/If/Else/End/Dim/Export/...` 等控制流；
- `support.buildin`：`Array/GVal/Val/ReDim/Str/V`；
- `buildin_type`：`Integer/Double/Long/Byte/String/Boolean`；
- `comment`、`numeric`、`strings` 提供注释/数字/字符串着色；
- 用 `repository` + `include` 的方式做模式复用，同时大小写不敏感（每个字母都写成 `(I|i)`）。

如要新增高亮规则，可以编辑该文件并配合扩展宿主下的 `Developer: Reload Window` 重新加载。

## 五、与外部协议的契约

虽然项目用 `ProposedFeatures.all` 注册连接，但实际 client 与 server 之间的协议都是 LSP 标准消息，没有自定义请求/通知。这意味着：

- **可以替换客户端**：理论上可以接到其它支持 LSP 的编辑器（Vim coc、Neovim、Sublime LSP 等）。
- **依赖客户端的 IPC**：当前 server 使用 `transport: ipc`，跨编辑器迁移时需切换为 `stdio` 之类的传输。

## 六、扩展开发常见任务

### 6.1 新增 LSP 能力（如签名提示）

1. 在 `onInitialize` 的 `capabilities` 添加 `signatureHelpProvider: { triggerCharacters: ["("] }`；
2. 在 server 中新增 `connection.onSignatureHelp(...)`，根据 `documentMatch.get(uri)` 取出节点，结合 `TeaFunc.parameters` 生成 `SignatureInformation`；
3. 客户端不需要变更，VSCode 会自动消费该能力。

### 6.2 新增配置项

1. `package.json` `contributes.configuration` 添加属性；
2. 客户端在 `clientOptions.synchronize.configurationSection` 同步；
3. 服务端通过 `connection.onDidChangeConfiguration` 接收。

### 6.3 多文档分析

当前每个文档独立编译匹配，跨文档信息靠 `exportFunc` / `globalValue` 字符串集合。如果想做"工作区级别"的解析（例如调用关系），可以：

1. 在 `documents.onDidOpen` 时遍历 workspace 的所有 `.smt` 文件并预解析；
2. 维护 `Map<uri, GrammarMatchResult>` 的全量缓存；
3. 暴露自定义 LSP 请求，例如 `smbxtea/findReferences`。
