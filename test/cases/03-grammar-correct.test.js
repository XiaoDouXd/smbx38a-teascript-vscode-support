// ================================================================
// 集成测试: 综合 TeaScript 用例(正确脚本)
// 验证语法树/作用域/导出函数/全局变量等是否能被正确识别
// ================================================================
"use strict";

const assert = require("assert");
const { loadModules, parse } = require("../helpers");

const { teaContext } = loadModules();
const { exportFunc, globalValue } = teaContext;

describe("integration(正确): Dim 单变量声明", () => {

    it("Dim x As Integer  --> 全局符号表中能查到 x", () => {
        // 每次解析都会触发 onMatchedInit 重建 TeaGlobalContext, 因此清掉跨文件缓存
        exportFunc.clear();
        globalValue.clear();

        const { match } = parse("Dim x As Integer\n");
        const ctx = match.state;
        assert.ok(ctx, "顶层 state 应是 TeaGlobalContext");
        const v = ctx.getVariable("x");
        assert.ok(v, "Dim x As Integer 后 x 应可查到");
        assert.strictEqual(v.type.name, "Integer");
    });

    it("Dim a, b, c As Integer  --> 三个变量都进入符号表(回归测试)", () => {
        exportFunc.clear();
        globalValue.clear();

        const { match } = parse("Dim a, b, c As Integer\n");
        const ctx = match.state;
        assert.ok(ctx.getVariable("a"), "a 应可查到");
        assert.ok(ctx.getVariable("b"), "b 应可查到");
        assert.ok(ctx.getVariable("c"), "c 应可查到");
    });

    it("大小写不敏感的变量查询", () => {
        exportFunc.clear();
        globalValue.clear();
        const { match } = parse("Dim MyVar As Double\n");
        const ctx = match.state;
        assert.ok(ctx.getVariable("myvar"));
        assert.ok(ctx.getVariable("MYVAR"));
        assert.ok(ctx.getVariable("MyVar"));
    });
});

describe("integration(正确): Script / Export Script 函数定义", () => {

    it("普通 Script 函数: 函数名出现在 functions 列表里", () => {
        exportFunc.clear();
        globalValue.clear();

        const src = [
            "Script foo()",
            "    Dim a As Integer",
            "End Script",
            ""
        ].join("\n");
        const { match } = parse(src);
        const ctx = match.state;

        const f = ctx.global.getFunc("foo");
        assert.ok(f, "Script foo() 应被注册");
        assert.strictEqual(f.export, false);
    });

    it("Export Script: 同时被记录到 exportFunc(uri)", () => {
        exportFunc.clear();
        globalValue.clear();

        const src = [
            "Export Script bar(x As Double, Return Double)",
            "    Return x",
            "End Script",
            ""
        ].join("\n");
        const { match } = parse(src);
        const ctx = match.state;

        const f = ctx.global.getFunc("bar");
        assert.ok(f, "Export Script bar 应被注册");
        assert.strictEqual(f.export, true);

        // 工程内通过 uri 缓存
        const allExported = [];
        exportFunc.forEach(v => v.forEach(fn => allExported.push(fn.name)));
        assert.ok(allExported.includes("bar"), `exportFunc 应包含 bar, 实际: ${allExported}`);
    });

    it("函数参数没有被重复注入(回归测试)", () => {
        exportFunc.clear();
        globalValue.clear();

        const src = [
            "Script baz(a As Double, b As Double, Return Double)",
            "    Return a + b",
            "End Script",
            ""
        ].join("\n");
        const { match } = parse(src);
        const ctx = match.state;
        const f = ctx.global.getFunc("baz");
        assert.ok(f);
        // 重复注入会让 functionContext.variables 出现 2 个 a / 2 个 b
        const aCount = f.functionContext.variables.filter(v => v.name === "a").length;
        const bCount = f.functionContext.variables.filter(v => v.name === "b").length;
        assert.strictEqual(aCount, 1, "参数 a 不应重复");
        assert.strictEqual(bCount, 1, "参数 b 不应重复");
    });
});

describe("integration(正确): Val(...) / GVal(...) 全局变量收集", () => {

    it("Val(score) --> globalValue 中有 score", () => {
        exportFunc.clear();
        globalValue.clear();

        const src = "Val(score) = 10\n";
        parse(src);
        const all = [];
        globalValue.forEach(v => v.forEach(s => all.push(s)));
        assert.ok(all.includes("score"), `globalValue 应包含 score, 实际: ${all}`);
    });

    it("同一变量名重复出现, 不会在 globalValue 里产生重复(回归)", () => {
        exportFunc.clear();
        globalValue.clear();

        const src = [
            "Val(score) = 1",
            "Val(score) = 2",
            "Val(score) = 3",
            ""
        ].join("\n");
        parse(src);
        let count = 0;
        globalValue.forEach(v => v.forEach(s => { if (s === "score") count++; }));
        assert.strictEqual(count, 1, `score 在 globalValue 中应仅出现 1 次, 实际 ${count} 次`);
    });
});

describe("integration(正确): If/For/With 流程结构", () => {

    it("简单 If 块能被解析", () => {
        const src = [
            "Dim x As Integer = 0",
            "If x = 0 Then",
            "    x = 1",
            "End If",
            ""
        ].join("\n");
        const { match } = parse(src);
        assert.strictEqual(match.matched, true, "整体匹配应该成功");
    });

    it("For 循环 + Step 能被解析", () => {
        const src = [
            "Dim i As Integer",
            "For i = 0 To 8 Step 2",
            "    Call sleep(1)",
            "Next",
            ""
        ].join("\n");
        const { match } = parse(src);
        assert.strictEqual(match.matched, true);
    });

    it("With 块能被解析", () => {
        const src = [
            "With NPC(1)",
            "    .x = 100",
            "    .y = 200",
            "End With",
            ""
        ].join("\n");
        const { match } = parse(src);
        assert.strictEqual(match.matched, true);
    });
});
