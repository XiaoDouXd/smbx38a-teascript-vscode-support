// ================================================================
// 单元测试: tea-context (符号表/类型/作用域基础结构)
// ================================================================
"use strict";

const assert = require("assert");
const { loadModules } = require("../helpers");

const { teaContext } = (() => {
    const m = loadModules();
    return { teaContext: m.teaContext };
})();

const { TeaType, TeaVar, TeaFunc, TeaContext, TeaGlobalContext, ciEq } = teaContext;

describe("tea-context: 基础数据结构", () => {

    it("TeaType.getMember 大小写不敏感", () => {
        const ty = new TeaType("MyObj");
        ty.addMember(new TeaVar(new TeaType("Double"), "Foo"));
        assert.strictEqual(ty.getMember("foo")?.name, "Foo");
        assert.strictEqual(ty.getMember("FOO")?.name, "Foo");
        assert.strictEqual(ty.getMember("bar"), null);
    });

    it("TeaContext.addContext 防止重复挂载", () => {
        const g = new TeaGlobalContext();
        const c = new TeaContext();
        g.addContext(c);
        g.addContext(c); // 重复
        assert.strictEqual(g.contexts.length, 1, "重复 addContext 不应该追加");
    });

    it("TeaContext.getVariable 大小写不敏感且沿父链回溯", () => {
        const g = new TeaGlobalContext();
        const child = new TeaContext();
        g.addContext(child);

        const v = new TeaVar(g.getType("Integer"), "MyVar");
        g.addVariable(v);

        assert.strictEqual(child.getVariable("myvar")?.name, "MyVar");
        assert.strictEqual(child.getVariable("MYVAR")?.name, "MyVar");
        assert.strictEqual(child.getVariable("nonexist"), null);
    });

    it("TeaContext.getType 命中已声明类型(应返回带 members 的实例, 不是空 stub)", () => {
        const g = new TeaGlobalContext();
        // 模拟用户自定义类型
        const ty = new TeaType("MyStruct");
        ty.addMember(new TeaVar(g.getType("Double"), "x"));
        g.addCustomType(ty);

        const found = g.getType("mystruct");
        assert.strictEqual(found.name, "MyStruct");
        assert.ok(Array.isArray(found.members));
        assert.strictEqual(found.members.length, 1);
        assert.strictEqual(found.members[0].name, "x");
    });

    it("TeaContext.getType 内建类型大小写归一化", () => {
        const g = new TeaGlobalContext();
        assert.strictEqual(g.getType("integer").name, "Integer");
        assert.strictEqual(g.getType("DOUBLE").name, "Double");
        assert.strictEqual(g.getType("string").name, "String");
    });

    it("TeaFunc.setFunctionContext 不会重复添加参数", () => {
        const g = new TeaGlobalContext();
        const f = new TeaFunc(g.getType("Double"), "myFunc");
        f.addParameter(new TeaVar(g.getType("Double"), "a"));
        f.addParameter(new TeaVar(g.getType("Double"), "b"));

        const ctx = new TeaContext();
        ctx.global = g;
        f.setFunctionContext(ctx);

        // 调多次也不应追加重复
        f.setFunctionContext(ctx);
        const aCount = ctx.variables.filter(v => v.name === "a").length;
        const bCount = ctx.variables.filter(v => v.name === "b").length;
        assert.strictEqual(aCount, 1, "参数 a 不应重复添加");
        assert.strictEqual(bCount, 1, "参数 b 不应重复添加");
    });

    it("TeaGlobalContext: builtin 函数/变量回退查找", () => {
        const g = new TeaGlobalContext();
        // SMBX 内建函数 Sleep 在 tea-builtin-context.ts 中是确定存在的
        const f = g.getFunc("Sleep");
        assert.ok(f, "应能查到内建函数 Sleep");
        // 大小写不敏感
        const f2 = g.getFunc("sleep");
        assert.ok(f2, "Sleep 查询应大小写不敏感");
    });

    it("ciEq: null/undefined 安全", () => {
        assert.strictEqual(ciEq(null, "x"), false);
        assert.strictEqual(ciEq("x", null), false);
        assert.strictEqual(ciEq(undefined, "x"), false);
        assert.strictEqual(ciEq("Abc", "abc"), true);
        assert.strictEqual(ciEq("Abc", "abd"), false);
    });
});
