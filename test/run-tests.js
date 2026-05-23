// ================================================================
// 轻量级零依赖测试运行器
// ----------------------------------------------------------------
// 设计原则:
//   - 不引入 mocha/jest 等运行时依赖, 启动快, 直接调试 LSP 内部 API
//   - 用 Node 内置 assert + 简易 describe/it 实现
//   - 测试用例约定: 文件名以 .test.js 结尾, 放在 test/cases/ 下
//   - 直接 require 服务端的编译产物 server/out/syntaxes/...
// ----------------------------------------------------------------
// 用法:
//   1) npm run compile  (确保 server/out 是新的)
//   2) node test/run-tests.js
//   3) 退出码非 0 表示存在失败
// ================================================================
"use strict";

const path = require("path");
const fs = require("fs");

// ---------------- 简易测试 DSL ----------------
const suites = [];
let currentSuite = null;

function describe(name, fn) {
    const suite = { name, tests: [] };
    suites.push(suite);
    const prev = currentSuite;
    currentSuite = suite;
    try {
        fn();
    }
    finally {
        currentSuite = prev;
    }
}

function it(name, fn) {
    if (!currentSuite) throw new Error(`'it("${name}")' 必须写在 describe(...) 内部`);
    currentSuite.tests.push({ name, fn });
}

global.describe = describe;
global.it = it;

// ---------------- 收集用例 ----------------
const casesDir = path.join(__dirname, "cases");
if (!fs.existsSync(casesDir)) {
    console.error(`[run-tests] 用例目录不存在: ${casesDir}`);
    process.exit(2);
}

const caseFiles = fs.readdirSync(casesDir)
    .filter(f => f.endsWith(".test.js"))
    .sort();

if (caseFiles.length === 0) {
    console.error(`[run-tests] 未找到任何 *.test.js`);
    process.exit(2);
}

console.log(`\n[run-tests] 共发现 ${caseFiles.length} 个测试文件\n`);

for (const f of caseFiles) {
    require(path.join(casesDir, f));
}

// ---------------- 执行 ----------------
const fmtMs = (ms) => `${ms.toFixed(1)}ms`;

let totalPass = 0;
let totalFail = 0;
const failures = [];

(async () => {
    const t0 = Date.now();

    for (const suite of suites) {
        console.log(`\x1b[1m▶ ${suite.name}\x1b[0m`);
        for (const test of suite.tests) {
            const ts = Date.now();
            try {
                const r = test.fn();
                if (r && typeof r.then === "function") await r;
                const dt = Date.now() - ts;
                console.log(`  \x1b[32m✓\x1b[0m ${test.name} \x1b[90m(${fmtMs(dt)})\x1b[0m`);
                totalPass++;
            }
            catch (ex) {
                const dt = Date.now() - ts;
                console.log(`  \x1b[31m✗\x1b[0m ${test.name} \x1b[90m(${fmtMs(dt)})\x1b[0m`);
                console.log(`    \x1b[31m${(ex && ex.stack) ? ex.stack.split("\n").slice(0, 6).join("\n    ") : ex}\x1b[0m`);
                failures.push({ suite: suite.name, test: test.name, ex });
                totalFail++;
            }
        }
    }

    const dt = Date.now() - t0;
    console.log("");
    console.log("==================================================");
    console.log(` 总计: ${totalPass + totalFail}  通过: \x1b[32m${totalPass}\x1b[0m  失败: \x1b[31m${totalFail}\x1b[0m  耗时: ${fmtMs(dt)}`);
    console.log("==================================================\n");

    process.exit(totalFail === 0 ? 0 : 1);
})();
