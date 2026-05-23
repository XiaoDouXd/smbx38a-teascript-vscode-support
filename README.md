# vscode 语言插件编写学习，以 teascript 为例

这是一个 vscode 语言插件编写的学习案例，目标是搭建一个更方便的 teascript 编码工具。关于 teascript 的编码文档，可以移步[此处(Wiki)](https://wiki.smbx.world/wiki/Category:TeaScript.vbs)。

## 功能清单

### 视觉
- [x] 基本语法高亮（TextMate）
- [x] 划分作用域
- [x] 常用代码片段（`snippets/smbxtea.json`）
- [x] 折叠规则（基于 `language-configuration.json`）
- [x] 缩进规则

### 智能
- [x] 补全建议（变量、函数、类型、关键字、跨文件 Export 函数、`With` 块字段）
- [x] 悬停提示
- [ ] 智能校验（暂未启用诊断通道）

## 性能与稳健性

- 服务端解析支持 **150ms 防抖** + **按 `doc.version` 缓存**，避免每个键盘事件触发全量重解析。
- `meta-grammar` 引擎引入 **doc 文本缓存**，用 `WeakMap` 在一次匹配中复用整篇文本，将 2000+ 行脚本的解析从"明显卡顿"优化到 **< 0.5s**（基准见 `test/cases/05-performance.test.js`）。
- 移除 `linq` 在热点路径上的包装开销，改用原生 `find/filter/reduce`。
- 修复了一系列作用域 / 大小写 / 着色 / 提示 bug（详见 `test/` 中的回归用例）。

## 开发与测试

```bash
npm install     # 一次性把根目录、client、server 的依赖装好
npm run compile # tsc -b 一次性构建 client + server
npm run watch   # 监听式增量构建

npm test        # 编译后跑 test/run-tests.js, 退出码 0 即全绿
```

## 打包发布

```bash
npm run package        # 测试 + 编译 + 打成 .vsix 放到 ./res/
npm run package:fast   # 跳过测试, 只编译 + 打包(快速迭代用)
```

打包脚本(`scripts/package-vsix.js`) 会:

1. 默认先跑全部测试用例确保质量
2. 调用 `vsce package` 生成 `.vsix`
3. 自动归档到 `./res/teascript-for-smbx38a-<version>.vsix`
4. 打印路径与体积

> 需要先全局安装 `vsce`: `npm i -g @vscode/vsce`

仓库内的 `.ai/` 是 AI 协助生成的项目分析文档，`.src-docs/` 是 SMBX 38A wiki 镜像；二者连同 `test/`、`scripts/` 均通过 `.vscodeignore` 排除，不会进入 `.vsix` 包。
