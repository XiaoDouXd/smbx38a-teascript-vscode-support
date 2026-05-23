// ================================================================
// 通用工具函数
// ================================================================
"use strict";

const path = require("path");

const OUT_ROOT = path.join(__dirname, "..", "server", "out", "syntaxes");

// 延迟加载, 保证 server 已编译
function loadModules() {
    const { TextDocument } = require(path.join(__dirname, "..", "server", "node_modules", "vscode-languageserver-textdocument"));
    const meta = require(path.join(OUT_ROOT, "meta-grammar.js"));
    const teaContext = require(path.join(OUT_ROOT, "tea-context.js"));
    const teaGrammarPattern = require(path.join(OUT_ROOT, "tea-grammar-pattern.js")).default;
    const teaBuiltinContext = require(path.join(OUT_ROOT, "tea-builtin-context.js")).default;
    teaContext.TeaGlobalContext.loadBuiltinContext(teaBuiltinContext);
    return { TextDocument, meta, teaContext, teaGrammarPattern };
}

// 单例的 compiledTeaGrammar
let _compiled = null;
function getCompiledGrammar() {
    if (!_compiled) {
        const { meta, teaGrammarPattern } = loadModules();
        _compiled = meta.compileGrammar(teaGrammarPattern);
    }
    return _compiled;
}

function makeDoc(text) {
    const { TextDocument } = loadModules();
    return TextDocument.create("file:///test.smt", "smbxtea", 1, text);
}

function parse(text) {
    const { meta } = loadModules();
    const doc = makeDoc(text);
    const grammar = getCompiledGrammar();
    return { doc, match: meta.matchGrammar(grammar, doc) };
}

module.exports = {
    loadModules,
    getCompiledGrammar,
    makeDoc,
    parse,
};
