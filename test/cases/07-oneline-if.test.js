// ================================================================
// 单行 If 语法测试: If <cond> Then <statement>
// ----------------------------------------------------------------
// 来源: TeaScript Wiki - "Shortcut if statement"
//   if condition then statement
// 该形态在真实脚本(Decoder.smt::TXT_GetCharSize 等)中频繁出现.
// 引擎需要正确把它解析为 if-structure 子树, 而不是回退到
// UnMatchedText/无意义代码 -- 否则该行的 statement 不会进入符号表,
// 后续补全/悬停/作用域都会失效.
// ================================================================
"use strict";

const assert = require("assert");
const { parse, loadModules } = require("../helpers");

const { teaContext } = loadModules();
const { exportFunc, globalValue } = teaContext;

/** 在匹配树中递归找到首个 patternName 为 target 的节点 */
function findByPatternName(m, target) {
    if (!m) return null;
    if (m.patternName === target) return m;
    const kids = m.children || m.allMatches || [];
    for (const c of kids) {
        const r = findByPatternName(c, target);
        if (r) return r;
    }
    return null;
}

/** 在匹配树中递归找到首个 ScopeMatchResult(可指定 scope.name 过滤) */
function findScope(m, scopeName) {
    if (!m) return null;
    const className = m.constructor && m.constructor.name;
    if ((className === "ScopeMatchResult" || className === "GrammarMatchResult")
        && (!scopeName || (m.scope && m.scope.name === scopeName))) {
        return m;
    }
    const kids = m.children || m.allMatches || [];
    for (const c of kids) {
        const r = findScope(c, scopeName);
        if (r) return r;
    }
    return null;
}

describe("单行 If: If <cond> Then <statement>", () => {

    it("最简形式: If x = 1 Then x = 2", () => {
        exportFunc.clear(); globalValue.clear();
        const { match } = parse("If x = 1 Then x = 2\n");
        assert.ok(match.matched);

        const ifNode = findByPatternName(match, "if-structure");
        assert.ok(ifNode, "应能识别为 if-structure");

        const stmt = findByPatternName(ifNode, "if-line-stmt");
        assert.ok(stmt, "if-structure 内部应有 if-line-stmt 子节点");
        assert.strictEqual(stmt.text.trim(), "x = 2");
    });

    it("带行尾注释: If x = 1 Then x = 2 ' comment", () => {
        exportFunc.clear(); globalValue.clear();
        const src = "If x = 1 Then x = 2 ' comment\n";
        const { match } = parse(src);
        const stmt = findByPatternName(match, "if-line-stmt");
        assert.ok(stmt, "应识别为单行 If");
        // statement 段允许吃到行尾注释, 但行末换行不能被吃下
        assert.ok(!stmt.text.includes("\n"), "if-line-stmt 不应跨行");
    });

    it("Then 后是关键字 Return: If id = 106 Then Return 6", () => {
        exportFunc.clear(); globalValue.clear();
        const src = `Export Script GetSize(id As Long, Return Long)
    If id = 106 Then Return 6
    Return 22
End Script
`;
        const { match } = parse(src);
        assert.ok(match.matched);

        // 找到所有 if-structure
        const found = [];
        (function walk(n) {
            if (!n) return;
            if (n.patternName === "if-structure") found.push(n);
            const kids = n.children || n.allMatches || [];
            kids.forEach(walk);
        })(match);

        assert.ok(found.length >= 1, "至少应有 1 个 if-structure 被识别");
        const stmts = found
            .map(s => findByPatternName(s, "if-line-stmt"))
            .filter(Boolean);
        assert.ok(stmts.some(s => /Return\s+6/.test(s.text)),
            `应有 If 单行的 then 部分包含 'Return 6', 实际: ${stmts.map(s => s.text).join(" | ")}`);

        // 函数本身能被注册
        const ctx = match.state;
        assert.ok(ctx.global.getFunc("GetSize"), "GetSize 函数应被注册");
    });

    it("多行 If 不会被误识别为单行(Then 行末为空白/注释)", () => {
        exportFunc.clear(); globalValue.clear();

        // 形态 1: Then 后只有换行
        const src1 = `If x = 1 Then
    y = 2
End If
`;
        const m1 = parse(src1).match;
        assert.ok(m1.matched);
        // 不应把 "y = 2" 错认为 if-line-stmt
        const stmt1 = findByPatternName(m1, "if-line-stmt");
        assert.strictEqual(stmt1, null, `多行 If 不应触发单行分支, 但匹配到 if-line-stmt: ${stmt1?.text}`);
        // 必须有 Block scope
        const block1 = findScope(m1, "Block");
        assert.ok(block1, "多行 If 应该有 Block scope 子节点");

        // 形态 2: Then 后接行尾注释
        const src2 = `If x = 1 Then ' comment
    y = 2
End If
`;
        const m2 = parse(src2).match;
        assert.ok(m2.matched);
        const stmt2 = findByPatternName(m2, "if-line-stmt");
        assert.strictEqual(stmt2, null, `多行 If(Then 后注释)不应触发单行分支, 但匹配到 if-line-stmt: ${stmt2?.text}`);
    });

    it("ElseIf / Else 多行结构仍正常工作(回归)", () => {
        exportFunc.clear(); globalValue.clear();
        const src = `If x = 1 Then
    y = 1
ElseIf x = 2 Then
    y = 2
Else
    y = 3
End If
`;
        const { match } = parse(src);
        assert.ok(match.matched);
        // 不应误判为单行
        const stmt = findByPatternName(match, "if-line-stmt");
        assert.strictEqual(stmt, null);
    });

    it("函数体内紧跟 N 个单行 If(Decoder.smt 风格)", () => {
        exportFunc.clear(); globalValue.clear();
        const src = `Export Script TXT_GetOffsetY(id As Long, Return Integer)
    If id = 103 Then Return 3
    If id = 113 Then Return 6
    If id = 112 Then Return 6
    If id = 106 Then Return 4
    Return 0
End Script
`;
        const { match } = parse(src);
        assert.ok(match.matched);

        // 4 个单行 If 都应被识别
        let count = 0;
        (function walk(n) {
            if (!n) return;
            if (n.patternName === "if-structure") count++;
            const kids = n.children || n.allMatches || [];
            kids.forEach(walk);
        })(match);
        assert.strictEqual(count, 4, `应识别出 4 个 if-structure, 实际 ${count}`);

        // 函数仍被正确注册
        const ctx = match.state;
        const fn = ctx.global.getFunc("TXT_GetOffsetY");
        assert.ok(fn);
        assert.strictEqual(fn.export, true);
    });

    it("单行 If 后紧跟普通赋值, 后续语句不会被吞", () => {
        exportFunc.clear(); globalValue.clear();
        const src = `Script foo()
    Dim x As Integer
    If x = 1 Then x = 2
    x = x + 1
    Dim y As Double = 3.14
End Script
`;
        const { match } = parse(src);
        assert.ok(match.matched);

        const ctx = match.state;
        const fn = ctx.global.getFunc("foo");
        assert.ok(fn);

        // 关键: 单行 If 后面的 Dim y As Double 不应该被吞
        const fnCtx = fn.functionContext;
        assert.ok(fnCtx, "函数应有 functionContext");
        assert.ok(fnCtx.getVariable("x"), "Dim x 应被注册");
        assert.ok(fnCtx.getVariable("y"), "Dim y(单行 If 之后)应该被注册, 否则说明引擎没正确推进");
    });
});
