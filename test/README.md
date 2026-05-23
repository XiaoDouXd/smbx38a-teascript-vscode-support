# test/

零依赖的轻量测试框架, 用于验证 LSP 服务端 (`server/`) 的语法引擎、符号表、补全/悬停等行为。

## 设计原则

1. **零依赖**: 不引入 mocha/jest/chai 等运行时, 只用 Node 内置 `assert` + 自实现的 `describe/it`。
2. **直接复用编译产物**: `require('../server/out/syntaxes/...')`, 不重复维护 TS 编译流程。
3. **不打进 vsix**: 通过 `.vscodeignore` 排除 `test/` 目录与 `.ai/`、`.src-docs/` 文档目录。

## 用法

```bash
# 必须先编译, 因为测试 require 的是 server/out/*.js
npm run compile

# 运行所有 *.test.js
node test/run-tests.js

# 或一步到位:
npm test
```

退出码 `0` 表示全部通过, 非零表示存在失败。

## 目录结构

```
test/
├── README.md
├── run-tests.js                   # 测试运行器(自实现 describe/it)
├── helpers.js                     # 加载模块 / 构造 TextDocument 的工具
├── cases/
│   ├── 01-tea-context.test.js     # 单元: 符号表/类型/作用域基础
│   ├── 02-meta-grammar.test.js    # 单元: 元语法引擎 + doc-text 缓存
│   ├── 03-grammar-correct.test.js # 集成: 正确脚本(Dim/Script/Val/If/With/...)
│   ├── 04-grammar-error.test.js   # 集成: 错误脚本不应让引擎崩溃
│   ├── 05-performance.test.js     # 性能基准: 500 / 2000 / 5000 行
│   ├── 06-real-world.test.js      # 真实工程脚本回归(test/example/ 下的 .smt)
│   └── 07-oneline-if.test.js      # 单行 If: If <cond> Then <statement>
└── example/                       # 真实生产环境 .smt 脚本(用于 06 用例)
    ├── Textbox.smt                # ~2456 行, 50 个 Export Script
    ├── textbox_utils.smt
    ├── cumath_utils.smt           # 91 个 Export Script
    └── ... (共 13 个真实文件)
```

## test/example/ 真实脚本

`test/example/` 下放着若干真实生产环境使用的 `.smt` 脚本(SMBX38A 的脚本系统),
覆盖了从 96 行到 ~2500 行 / 91 KB 的不同规模; 测试用例 06-real-world.test.js 会:

1. 解析每个文件并校验性能(行数 -> 上限毫秒数)
2. 拿每个文件的"首/末/总数 Export Script"作为基准快照, 防止引擎漏识或多识函数
3. 验证 wind-line.smt(没有 Export Script 的入口脚本)的顶层 Dim 变量被记入符号表
4. 验证 exportFunc(uri) 跨文件缓存正常

如果以后要新增 example 文件:

1. 把新 `.smt` 放进 `test/example/`
2. 在 06-real-world.test.js 的 `ANCHOR_EXPORTS` 中追加期望快照
3. `npm test` 会自动收录

## 编写新用例

新建 `cases/xx-feature.test.js`:

```js
"use strict";
const assert = require("assert");
const { parse } = require("../helpers");

describe("我的特性", () => {
    it("应该能正确解析 ...", () => {
        const { match } = parse("Dim x As Integer\n");
        assert.ok(match.matched);
    });
});
```

文件名以 `.test.js` 结尾会自动被 `run-tests.js` 收集。
