# SMBX Teascript Intellisense — 项目分析文档

本目录由 AI 协助生成，用于沉淀对 `smbx-teascript-intellisense` 项目的整体分析、模块划分以及关键流程说明，方便后续的二次开发与问题排查。

## 项目简介

`smbx-teascript-intellisense` 是一个面向 SMBX38A（《Super Mario Bros. X》38A 版本）所使用的脚本语言 **TeaScript** 的 VSCode 扩展。其核心目标是为 `.smt` 脚本文件提供：

- 基础语法高亮（TextMate Grammar）
- 作用域划分与缩进/折叠规则
- 智能提示（基于 LSP 的 `completion` 与 `hover`）
- 变量、函数、内建类型/字段的语义识别

项目作者通过手写一套**元语法引擎（meta-grammar）** 来对源码做语法树式的递归匹配，再在匹配树上挂载补全/悬停回调，从而实现 IntelliSense 能力。

> 该项目同时也是作者作为 VSCode 语言插件开发的学习实践案例。

## 顶层目录结构

```
smbx-teascript-intellisense/
├── client/                       # LSP 客户端 (运行在 VSCode 扩展宿主中)
│   └── src/extension.ts          # 扩展入口，启动 Language Client
├── server/                       # LSP 服务端 (独立 Node 进程)
│   └── src/
│       ├── server.ts             # 服务端入口：注册 LSP 事件
│       └── syntaxes/             # 语法引擎核心
│           ├── meta-grammar.ts          # 通用的元语法/匹配引擎
│           ├── tea-grammar-pattern.ts   # TeaScript 的语法模板定义
│           ├── tea-context.ts           # 上下文与符号表（变量/函数/类型）
│           └── tea-builtin-context.ts   # SMBX 内建类型与函数预设
├── syntaxes/smbxtea.tmLanguage.json   # TextMate 语法（高亮）
├── snippets/smbxtea.json              # 代码片段（当前为空）
├── language-configuration.json        # 注释/括号/折叠/缩进规则
├── package.json                       # VSCode 扩展清单
├── tsconfig.json                      # TS 项目引用 (client + server)
└── res/                               # 图标、演示资源
```

## 文档索引

| 文档 | 主题 |
| --- | --- |
| [architecture.md](./architecture.md) | 整体架构、客户端/服务端分工、运行流程 |
| [meta-grammar.md](./meta-grammar.md) | 元语法引擎：模板类型、匹配算法、匹配结果 |
| [tea-grammar.md](./tea-grammar.md) | TeaScript 语法模板、关键模式、回调机制 |
| [tea-context.md](./tea-context.md) | 符号系统：`TeaType`/`TeaVar`/`TeaFunc`/`TeaContext` 与内建预设 |
| [lsp-and-extension.md](./lsp-and-extension.md) | LSP 通信、客户端启动、扩展贡献点 |
| [development.md](./development.md) | 构建、调试、打包发布与已知问题 |

## 阅读建议

1. 先看 [architecture.md](./architecture.md) 建立全局认知；
2. 再看 [meta-grammar.md](./meta-grammar.md) 理解通用匹配引擎；
3. 然后看 [tea-grammar.md](./tea-grammar.md) 与 [tea-context.md](./tea-context.md) 看具体语言如何在引擎之上落地；
4. 最后通过 [lsp-and-extension.md](./lsp-and-extension.md) 与 [development.md](./development.md) 上手开发。
