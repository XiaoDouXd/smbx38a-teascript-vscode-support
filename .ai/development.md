# 开发、构建与发布

## 一、环境准备

| 工具 | 版本要求 |
| --- | --- |
| Node.js | 与 `@types/node@16.x` 对齐，建议 16.x 或更高 LTS |
| TypeScript | `^4.7.2`（已声明在 `devDependencies`） |
| VSCode | 测试目标 `^1.68.0` |
| `vsce` | 打包 `.vsix` 时按需全局安装：`npm i -g @vscode/vsce` |

## 二、安装依赖

根目录有自动子工程安装脚本：

```bash
npm install
# postinstall 会自动执行 cd client && npm install && cd ../server && npm install
```

> 项目使用 `npm` 维护三处 `package.json`（root / client / server），不要混用 `pnpm` / `yarn`，否则可能产生不一致的 `node_modules`。

## 三、构建

```bash
npm run compile      # tsc -b   一次性构建 client + server
npm run watch        # tsc -b -w 监听模式，本地开发推荐
```

构建产物：

- `client/out/extension.js` ← VSCode 扩展入口
- `server/out/server.js`    ← LSP 服务端入口

## 四、本地调试

VSCode 中调试该扩展的标准流程：

1. 打开仓库（`smbx-teascript.code-workspace` 是工作区文件，可直接双击打开）。
2. 启动 `npm run watch` 持续构建。
3. F5（或 `Run > Start Debugging`）启动 **Extension Host** 实例：会新开一个 VSCode 窗口，已加载该扩展。
4. 在新窗口中打开任意 `.smt` 文件即可触发激活。
5. 若要调试服务端：在调试面板中选择 `Attach to Server`（如果未配置可手动添加 9229/6009 端口的 attach 配置）。

> 本仓库目前未提供 `.vscode/launch.json`（git 状态显示工作树干净），如有需要可自行添加：
>
> ```jsonc
> {
>   "version": "0.2.0",
>   "configurations": [
>     {
>       "type": "extensionHost", "request": "launch", "name": "Run Extension",
>       "runtimeExecutable": "${execPath}", "args": ["--extensionDevelopmentPath=${workspaceFolder}"],
>       "outFiles": ["${workspaceFolder}/client/out/**/*.js", "${workspaceFolder}/server/out/**/*.js"],
>       "preLaunchTask": "npm: watch"
>     },
>     {
>       "type": "node", "request": "attach", "name": "Attach to Server",
>       "port": 6009, "restart": true,
>       "outFiles": ["${workspaceFolder}/server/out/**/*.js"]
>     }
>   ]
> }
> ```

## 五、TextMate 语法 / 语言配置调试

只修改 `syntaxes/*.tmLanguage.json` 或 `language-configuration.json` 时，不需要重启扩展，只需在 Extension Host 窗口执行命令 `Developer: Reload Window` (`Ctrl+R` / `Cmd+R`)。

## 六、打包发布

`package.json` 已声明 `vscode:prepublish`：

```json
"vscode:prepublish": "npm run compile"
```

发布步骤：

```bash
# 1. 打包成 vsix（不上传市场）
vsce package

# 2. 上传到 VSCode Marketplace（需要 publisher: xiaodouxd 的 PAT）
vsce publish
```

`res/` 目录已经放了几个历史版本的 `.vsix`，可以参考体积大小。

## 七、当前未实现 / 待办

参考 `README.md` 的功能列表，以及代码中残留的 TODO：

- [ ] 录入常用代码片段（`snippets/smbxtea.json` 当前为 `{}`）
- [ ] 配置折叠（已有简单 markers，但仍标注"暂无"）
- [ ] 完整缩进规则（同上）
- [ ] 智能校验 / 诊断（`server.ts` 末尾大量被注释的 `onDidChangeContent` 诊断示例，未启用）
- [ ] `goto-call` / `goto-flag` 解析（`tea-grammar-pattern.ts` 中明确注释 `ToDo`）
- [ ] 函数签名 `signatureHelpProvider`、文档格式化、文档高亮（`server.ts` 末尾被注释的 stub 提示了未来扩展方向）

## 八、性能 / 稳定性优化建议

1. **节流 `onDidChangeContent`**：当前逐键全量匹配，可加 debounce 或仅在空闲时刻重算（`setTimeout` 或 `setImmediate`）。
2. **增量解析**：`getMatch` 已经预留 `lastMatch` 字段，但尚未真正利用；可以基于"修改的文本范围"做局部失效。
3. **错误诊断**：把模板里 `try/catch` 吞掉的错误改为发送 `connection.console.error`，方便定位 Bug。
4. **大小写一致性**：用户符号大小写敏感而内建不敏感，导致跨文件 `Export Script` 大小写不一致时可能查不到，可以统一为不敏感。
5. **`linq` 依赖**：可以替换为原生 `Array` 操作，减小依赖。

## 九、目录速查

```
smbx-teascript-intellisense/
├── .ai/                              # 本套分析文档
├── client/
│   ├── src/extension.ts              # 客户端入口
│   ├── package.json                  # 依赖：vscode-languageclient
│   └── tsconfig.json
├── server/
│   ├── src/
│   │   ├── server.ts                 # 服务端入口
│   │   └── syntaxes/
│   │       ├── meta-grammar.ts       # 通用语法引擎
│   │       ├── tea-grammar-pattern.ts# TeaScript 语法
│   │       ├── tea-context.ts        # 符号系统 + 关键字 + 片段
│   │       └── tea-builtin-context.ts# SMBX 内建数据
│   ├── package.json                  # 依赖：vscode-languageserver, linq, log4js
│   └── tsconfig.json
├── language-configuration.json       # 注释/括号/缩进/折叠
├── syntaxes/smbxtea.tmLanguage.json  # 语法高亮
├── snippets/smbxtea.json             # （空）静态片段位
├── package.json                      # 扩展清单（contributes、main、scripts）
├── tsconfig.json                     # 项目引用：client + server
├── smbx-teascript.code-workspace     # 工作区文件
├── res/                              # 图标、demo 动图、历史 vsix
├── LICENSE
└── README.md
```
