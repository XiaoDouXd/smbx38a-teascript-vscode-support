// ================================================================
// 性能基准: 大文件解析速度
//   2000 行规模脚本应在合理时间内解析完成
// ================================================================
"use strict";

const assert = require("assert");
const { parse, loadModules } = require("../helpers");

const { teaContext } = loadModules();
const { exportFunc, globalValue } = teaContext;

function genLargeScript(lines) {
    const out = [];
    for (let i = 0; i < lines; i++) {
        const mod = i % 6;
        switch (mod) {
            case 0: out.push(`Dim var${i} As Integer = ${i}`); break;
            case 1: out.push(`Val(g${i}) = ${i} + 1`); break;
            case 2: out.push(`If var${i - 2} > 0 Then`); break;
            case 3: out.push(`    Call sleep(1)`); break;
            case 4: out.push(`End If`); break;
            case 5: out.push(`' 注释 ${i}`); break;
        }
    }
    return out.join("\n") + "\n";
}

describe("性能基准: 大型脚本", () => {

    it("解析 500 行脚本 < 1500ms", () => {
        exportFunc.clear();
        globalValue.clear();

        const src = genLargeScript(500);
        const t0 = Date.now();
        const { match } = parse(src);
        const dt = Date.now() - t0;

        console.log(`        500 行: ${dt}ms`);
        assert.ok(match);
        assert.ok(dt < 1500, `500 行解析应 <1500ms, 实际 ${dt}ms`);
    });

    it("解析 2000 行脚本 < 8000ms", () => {
        exportFunc.clear();
        globalValue.clear();

        const src = genLargeScript(2000);
        const t0 = Date.now();
        const { match } = parse(src);
        const dt = Date.now() - t0;

        console.log(`        2000 行: ${dt}ms`);
        assert.ok(match);
        // 注意: 老版本(无 doc-text 缓存 + linq 包装)在 2000 行上耗时数十秒, 这里设 8 秒兜底
        assert.ok(dt < 8000, `2000 行解析应 <8000ms, 实际 ${dt}ms`);
    });

    it("解析 5000 行脚本 < 30000ms (软基准)", function () {
        exportFunc.clear();
        globalValue.clear();

        const src = genLargeScript(5000);
        const t0 = Date.now();
        const { match } = parse(src);
        const dt = Date.now() - t0;

        console.log(`        5000 行: ${dt}ms`);
        assert.ok(match);
        // 这是软基准, 主要为了在 PR 里看到性能曲线
        assert.ok(dt < 30000, `5000 行解析应 <30s, 实际 ${dt}ms`);
    });
});
