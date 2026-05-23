# 整体架构

## 一、运行形态

VSCode 扩展遵循官方推荐的 **Language Server Protocol (LSP)** 双进程架构：

```
┌──────────────────────────┐      LSP / IPC       ┌────────────────────────────┐
│  VSCode Extension Host   │  ◄────────────────►  │   Language Server (Node)   │
│  - client/extension.ts   │                       │  - server/server.ts        │
│  - LanguageClient        │                       │  - meta-grammar 引擎        │
└──────────────────────────┘                       └────────────────────────────┘
       ▲                                                     ▲
       │ contributes (语法/语言/片段)                        │ 解析 / 补全 / 悬停
       │                                                     │
┌──────┴──────────────────────────────────────────────────────┴───────────────┐
│                              .smt 源码文件                                    │
└──────────────────────────────────────────────────────────────────────────────┘
```

- **客户端 (`client/`)**：仅负责把服务端拉起，并把语言绑定到 `language === 'smbxtea'`。
- **服务端 (`server/`)**：承载所有语言能力，通过 IPC 与客户端通信。

`package.json` 中以 `onLanguage:smbxtea` 触发激活，扩展主入口指向编译后的客户端：

```json
"main": "./client/out/extension",
"activationEvents": ["onLanguage:smbxtea"]
```

## 二、贡献点（contributes）

```jsonc
"languages": [{ "id": "smbxtea", "extensions": [".smt"], "configuration": "./language-configuration.json" }],
"grammars":  [{ "language": "smbxtea", "scopeName": "source.smt", "path": "./syntaxes/smbxtea.tmLanguage.json" }],
"snippets":  [{ "language": "shaderlab", "path": "./snippets/smbxtea.json" }]
```

要点：

1. **语言定义**：注册语言 `smbxtea` 与文件后缀 `.smt`，并加载注释、括号、折叠、缩进规则。
2. **语法高亮**：通过 TextMate 文法实现，高亮规则在 `syntaxes/smbxtea.tmLanguage.json`。
3. **片段（snippet）**：当前 `snippets/smbxtea.json` 为空文件，且配置中绑定到 `shaderlab`（疑似笔误，实际由服务端动态产出代码片段补全）。

## 三、目录与编译关系

`tsconfig.json` 使用 **TypeScript Project References**：

```jsonc
{
  "references": [{ "path": "./client" }, { "path": "./server" }]
}
```

- 根 `tsc -b` 会同时编译 `client/` 与 `server/`，输出到各自的 `out/` 目录。
- 二者各自维护 `package.json` 与 `node_modules`，根目录的 `postinstall` 会递归 `npm install`。

## 四、运行时数据流

下面是一次"用户在 `.smt` 文件中输入字符 → 拿到补全列表"的完整流程：

1. **VSCode** 检测到 `language=smbxtea` 文档发生变化，触发扩展激活。
2. **客户端** (`client/src/extension.ts`) 通过 `LanguageClient` 启动服务端 Node 进程，并以 IPC 通道连接：
   ```ts
   serverModule = path.join('server', 'out', 'server.js');
   client = new LanguageClient('smbxteaLanguageServer', ...);
   client.start();
   ```
3. **服务端** (`server/src/server.ts`) 在 `onInitialize` 中声明能力：
   - `completionProvider` （触发字符 `.`）
   - `hoverProvider`
4. 服务端在文档打开/变更时，使用 `compileGrammar(teaGrammarPattern)` 编译出语法模板，并对文档执行 `matchGrammar()`，得到一棵 `GrammarMatchResult`（语法匹配树）。
5. 当客户端请求 `textDocument/completion` 时：
   - 服务端在树中找到光标所在的最小匹配节点 `locateMatchAtPosition`；
   - 沿着父链回溯，依次调用各 `pattern.onCompletion` / `scope.onCompletion`；
   - 合并内建关键字、内建类型、其它文档导出的 `Export Script`，去重后返回。
6. `textDocument/hover` 类似，从匹配树定位节点后调用 `pattern.onHover` 返回 Markdown 内容。

## 五、模块职责一览

| 模块 | 职责 |
| --- | --- |
| `client/src/extension.ts` | 启动/停止 Language Client；声明文档选择器 |
| `server/src/server.ts` | LSP 事件路由：initialize / completion / hover / 文档生命周期 |
| `server/src/syntaxes/meta-grammar.ts` | 通用元语法引擎：`PatternItem` 体系、`compileGrammar`、`matchGrammar`、匹配结果树 |
| `server/src/syntaxes/tea-grammar-pattern.ts` | TeaScript 的 `LanguageGrammar` 声明（语法模式 + 各种 onMatched / onCompletion 回调） |
| `server/src/syntaxes/tea-context.ts` | TeaScript 的"运行时符号表"：类型/变量/函数/上下文 |
| `server/src/syntaxes/tea-builtin-context.ts` | SMBX 内建类型、变量、函数的静态声明数据 |
| `syntaxes/smbxtea.tmLanguage.json` | 语法高亮（TextMate） |
| `language-configuration.json` | 注释/括号/折叠/缩进规则 |

## 六、关键设计选择

1. **不依赖现成解析器**：作者没有使用 ANTLR / tree-sitter / chevrotain，而是自行实现一个"模板字符串 → PatternItem 树 → 在文本上做递归匹配"的小型引擎。这降低了运行时依赖，但对模式编写者要求较高。
2. **匹配树即语义载体**：`MatchResult` / `PatternMatchResult` / `ScopeMatchResult` 既是语法树，也承担了"上下文 (`state`) 持有者"的角色。补全 / 悬停回调通过遍历匹配树父链 + 持有的 `TeaContext` 完成符号查询。
3. **跨文档共享 `Export Script`**：`exportFunc: Map<uri, TeaFunc[]>` 和 `globalValue` 使得在 A 文件中 `Export Script Foo()` 后，B 文件能在补全里看到 `Foo`。
4. **TextMate 语法 + 服务端语义并行**：着色仍交给 TextMate，可避免重新实现高亮；语义层（IntelliSense）走 LSP。
