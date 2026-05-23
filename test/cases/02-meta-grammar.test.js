// ================================================================
// 单元测试: meta-grammar (元语法引擎核心)
// ================================================================
"use strict";

const assert = require("assert");
const { loadModules, parse } = require("../helpers");

const { meta } = loadModules();

describe("meta-grammar: 编译/匹配基础", () => {

    it("compileGrammar 不抛异常并产出 Grammar 实例", () => {
        const { teaGrammarPattern } = loadModules();
        const compiled = meta.compileGrammar(teaGrammarPattern);
        assert.ok(compiled, "compileGrammar 必须返回 Grammar");
        assert.strictEqual(typeof compiled.match, "function");
    });

    it("matchGrammar 对空文档不会抛异常", () => {
        const { match } = parse("");
        assert.ok(match, "空文档也应返回 GrammarMatchResult");
        assert.strictEqual(match.matched, true);
    });

    it("locateMatchAtPosition 对越界位置返回自身或最近节点", () => {
        const { doc, match } = parse("Dim x As Integer\n");
        // 越界位置
        const beyond = doc.positionAt(doc.getText().length + 100);
        const r = match.locateMatchAtPosition(beyond);
        assert.ok(r, "越界位置应返回非空匹配");
    });
});

describe("meta-grammar: doc 文本缓存", () => {

    it("doc.getText 调用次数远小于行数 * pattern 数(性能保证)", () => {
        const { TextDocument } = loadModules();
        let getCount = 0;

        // 用 100 行脚本进行测试: 没有缓存的实现下,
        // getText() (无参数) 会被每个 PatternItem.match 调用一次, 数千次起.
        const lines = [];
        for (let i = 0; i < 100; i++) lines.push(`Dim a${i} As Integer = ${i}`);
        const text = lines.join("\n") + "\n";

        const realDoc = TextDocument.create("file:///t.smt", "smbxtea", 1, text);
        const proxy = new Proxy(realDoc, {
            get(target, prop) {
                if (prop === "getText") {
                    return function (...args) {
                        // 仅统计 "无参数" 调用 -- 它们才会返回完整文本, 是性能热点
                        if (args.length === 0) getCount++;
                        return target.getText(...args);
                    };
                }
                return Reflect.get(target, prop);
            }
        });

        const grammar = meta.compileGrammar(loadModules().teaGrammarPattern);
        meta.matchGrammar(grammar, proxy);

        // 一份 100 行脚本若每个模板都调一次 doc.getText() 会触发数百~数千次,
        // 缓存命中后应仅在版本变化时调用 1 次.
        assert.ok(
            getCount < 5,
            `100 行下 doc.getText() 全文调用应 <5 次(缓存命中), 实际 ${getCount} 次`
        );
    });
});
