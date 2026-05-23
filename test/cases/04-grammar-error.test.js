// ================================================================
// 集成测试: 错误/边角脚本 - 不应让引擎崩溃
// ================================================================
"use strict";

const assert = require("assert");
const { parse, loadModules } = require("../helpers");

const { teaContext } = loadModules();
const { exportFunc, globalValue } = teaContext;

describe("integration(错误): 不完整代码不应抛异常", () => {

    function expectNoThrow(name, src) {
        it(name, () => {
            exportFunc.clear();
            globalValue.clear();
            assert.doesNotThrow(() => {
                const { match } = parse(src);
                // 即便不能完全 matched, 也至少返回 GrammarMatchResult 实例
                assert.ok(match);
            });
        });
    }

    expectNoThrow("半开口的 If(没 End If)", "If x = 1 Then\n    x = 2\n");
    expectNoThrow("半开口的 Script(没 End Script)", "Script foo()\n    Dim a As Integer\n");
    expectNoThrow("半开口的 With", "With NPC(1)\n    .x = 1\n");
    expectNoThrow("仅有 Dim 关键字", "Dim\n");
    expectNoThrow("非法 Dim 缺少 As", "Dim x Integer\n");
    expectNoThrow("Dot 操作但前面没有对象", ".foo = 1\n");
    expectNoThrow("空字符串", "");
    expectNoThrow("纯注释", "' 这是一行注释\n' 这又是一行\n");
    expectNoThrow("纯空白", "\n\n   \n\t\n");
    expectNoThrow("非法关键字组合", "End End End End\n");
    expectNoThrow("半截字符串", "Dim s As String = \"unterminated\n");
});

describe("integration(错误): 用户输入到一半的常见状态(IntelliSense 兜底)", () => {

    function expectMatchExists(name, src, line, character) {
        it(name, () => {
            exportFunc.clear();
            globalValue.clear();
            const { match } = parse(src);
            const r = match.locateMatchAtPosition({ line, character });
            assert.ok(r, "光标位置应能定位到一个匹配节点");
        });
    }

    // 用户在 With 块内输入 `.` 等待补全
    expectMatchExists(
        "With 块内 . 之后能定位匹配节点",
        "With NPC(1)\n    .\nEnd With\n",
        1, 5
    );

    // 用户在脚本中输入 Dim 等待补全
    expectMatchExists(
        "Dim<空格> 之后能定位匹配节点",
        "Dim ",
        0, 4
    );

    expectMatchExists(
        "If <cond>  待补全 Then",
        "If x = 1 ",
        0, 9
    );
});
