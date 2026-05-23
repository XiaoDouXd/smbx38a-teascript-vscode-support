// ================================================================
// 真实工程脚本回归测试
// ----------------------------------------------------------------
// 作者: 把若干生产环境中实际使用的 .smt 脚本 (test/example/) 纳入测试,
// 既覆盖大型脚本(Textbox.smt 2456 行 / 91KB)的解析鲁棒性,
// 也用每个文件首尾的 Export Script 名作为锚点,
// 检测引擎是否真的把符号收进了符号表(而不是仅仅"没崩溃").
// ================================================================
"use strict";

const fs = require("fs");
const path = require("path");
const assert = require("assert");
const { parse, loadModules } = require("../helpers");

const { teaContext } = loadModules();
const { exportFunc, globalValue } = teaContext;

const EXAMPLE_DIR = path.join(__dirname, "..", "example");

/**
 * 期望表: 文件名 -> { first, last, count }
 *   - first/last: 解析后 functions 列表中(经引擎 onMatched 注册的)
 *                 首/末位 export 函数名, 用作首尾锚点验证
 *   - count: 解析后 export 函数总数
 *
 * 这些数值是从 test/example/ 下真实文件解析得到的"基准快照".
 * 如果引擎将来漏识或多识 export, 这里会立即报错.
 */
const ANCHOR_EXPORTS = {
    "bmp_utils.smt":            { first: "BmpNewStoreSrcId",        last: "BmpOffsetAnim",                count: 32 },
    "cumath_utils.smt":         { first: "CUMath_MAX_SAFE_INTEGER", last: "CUMath_GetVecRetY",            count: 91 },
    "Decoder.smt":              { first: "D",                       last: "TXT_GetOffsetY",               count: 15 },
    "line_utils.smt":           { first: "libLine_destoryLibLine",  last: "libLine_getLineVertCount",     count: 19 },
    "model_slices.smt":         { first: "CreateModelBitmap",       last: "HideModel",                    count: 5  },
    "pool_utils.smt":           { first: "PoolUtils_Init",          last: "PoolUtils_ItrUsageInstance",   count: 9  },
    "shadow2d.smt":             { first: "Shadow2D_CalcNorm",       last: "Shadow2D_HalfCircle_WithAtten",count: 16 },
    "Textbox.smt":              { first: "TextboxEvent_OnNext",     last: "TextboxLite_Submit",           count: 50 },
    "TextboxLiteUtil.smt":      { first: "TextboxLite_StoreTargetId", last: "TextboxLite_Submit",         count: 11 },
    "TextboxLowLevelUtil.smt":  { first: "TextboxLowLevel_LoadString", last: "TextboxLowLevel_SetAlign",  count: 22 },
    "TextboxMsg.smt":           { first: "TextboxEvent_OnNext",     last: "Textbox_SetAvatarImm",         count: 13 },
    "textbox_utils.smt":        { first: "TextboxEvent_OnNext",     last: "TextboxLite_Submit",           count: 50 },
    // wind-line.smt 没有 Export Script
    "wind-line.smt":            null,
};

// 收集所有 .smt 文件
const files = fs.existsSync(EXAMPLE_DIR)
    ? fs.readdirSync(EXAMPLE_DIR).filter(f => f.endsWith(".smt")).sort()
    : [];

// 性能阈值: 行数 -> 上限毫秒数
function perfBudget(lines) {
    if (lines < 300) return 200;
    if (lines < 800) return 500;
    if (lines < 1500) return 1500;
    return 4000;
}

describe("真实工程脚本: test/example/ 解析回归", function () {

    // 保险, 文件不存在时不静默跳过
    it("test/example/ 目录存在且包含 .smt 文件", () => {
        assert.ok(fs.existsSync(EXAMPLE_DIR), `期望存在 ${EXAMPLE_DIR}`);
        assert.ok(files.length > 0, "test/example/ 下应有 .smt 文件");
    });

    for (const f of files) {
        it(`解析 ${f} 不抛异常 + 性能达标`, () => {
            exportFunc.clear();
            globalValue.clear();

            const filePath = path.join(EXAMPLE_DIR, f);
            const src = fs.readFileSync(filePath, "utf8");
            const lines = src.split(/\r?\n/).length;

            const t0 = Date.now();
            let match;
            assert.doesNotThrow(() => {
                match = parse(src).match;
            });
            const dt = Date.now() - t0;

            assert.ok(match, `解析 ${f} 应返回 match 结果`);
            assert.ok(match.matched, `解析 ${f} 顶层应 matched`);

            const budget = perfBudget(lines);
            assert.ok(
                dt < budget,
                `${f} (${lines} 行) 解析应 <${budget}ms, 实际 ${dt}ms`
            );
        });
    }

    for (const f of files) {
        const expect = ANCHOR_EXPORTS[f];
        if (expect === null) continue;             // 显式声明无 Export 锚点
        if (expect === undefined) continue;        // 未注册的文件不强校验

        it(`${f}: Export Script 首/末/总数与基准快照一致`, () => {
            exportFunc.clear();
            globalValue.clear();

            const src = fs.readFileSync(path.join(EXAMPLE_DIR, f), "utf8");
            const { match } = parse(src);
            const ctx = match.state;
            assert.ok(ctx, "应有顶层 TeaGlobalContext");

            const allExports = ctx.global.functions
                .filter(fn => fn.export)
                .map(fn => fn.name);

            assert.strictEqual(
                allExports.length, expect.count,
                `${f}: Export 数量应为 ${expect.count}, 实际 ${allExports.length}`
            );
            assert.strictEqual(
                allExports[0], expect.first,
                `${f}: 首个 Export 应为 ${expect.first}, 实际 ${allExports[0]}`
            );
            assert.strictEqual(
                allExports[allExports.length - 1], expect.last,
                `${f}: 末个 Export 应为 ${expect.last}, 实际 ${allExports[allExports.length - 1]}`
            );

            // 锚点函数的 export 标志应正确
            const firstFn = ctx.global.getFunc(expect.first);
            const lastFn = ctx.global.getFunc(expect.last);
            assert.ok(firstFn && firstFn.export, `${expect.first} 应被标记为 export`);
            assert.ok(lastFn && lastFn.export, `${expect.last} 应被标记为 export`);
        });
    }

    it("wind-line.smt: 顶层 Dim 全局变量被注册到符号表", () => {
        exportFunc.clear();
        globalValue.clear();

        const src = fs.readFileSync(path.join(EXAMPLE_DIR, "wind-line.smt"), "utf8");
        const { match } = parse(src);
        const ctx = match.state;
        // 文件第 7-15 行有大量 Dim, 抽几个查
        for (const name of ["bitmapStartIdx", "lineCount", "vertCount", "screenPosX"]) {
            assert.ok(ctx.getVariable(name), `wind-line.smt: 应能查到 Dim ${name}`);
        }
    });

    it("跨文件: Textbox.smt 中 Export 函数同时被记入 exportFunc(uri) 缓存", () => {
        exportFunc.clear();
        globalValue.clear();

        const src = fs.readFileSync(path.join(EXAMPLE_DIR, "Textbox.smt"), "utf8");
        parse(src);

        const all = [];
        exportFunc.forEach(v => v.forEach(fn => all.push(fn.name)));
        assert.ok(all.includes("TextboxEvent_OnNext"),
            `exportFunc 中应含 TextboxEvent_OnNext, 实际前 5 个: ${all.slice(0, 5).join(",")}`);
        assert.ok(all.length >= 30,
            `Textbox.smt 一共 ~50 个 export, exportFunc 至少应有 30 个, 实际 ${all.length}`);
    });
});
