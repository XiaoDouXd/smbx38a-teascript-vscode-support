#!/usr/bin/env node
// ================================================================
// 一键打包成 .vsix 并归档到 ./res 目录
// ----------------------------------------------------------------
// 用法:
//   npm run package           # 编译 + 打包 + 输出到 res/
//   npm run package -- --skip-compile   # 跳过编译(已编译过)
//   npm run package -- --skip-tests     # 跳过测试(默认会先跑测试保证质量)
//
// 行为:
//   1. 默认先 npm test (编译 + 全部测试用例) 确保质量
//   2. 调用 vsce package 生成 .vsix 到工作区根
//   3. 把生成的 .vsix 移动到 ./res/  (按 package.json 的 name + version 命名)
//   4. 打印产物路径与体积
// ================================================================

"use strict";

const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const ROOT = path.resolve(__dirname, "..");
const RES_DIR = path.join(ROOT, "res");

function readPkg() {
    return JSON.parse(fs.readFileSync(path.join(ROOT, "package.json"), "utf8"));
}

function run(cmd, args, opts = {}) {
    const display = `${cmd} ${args.join(" ")}`;
    console.log(`\n▶ ${display}`);
    const r = spawnSync(cmd, args, {
        stdio: "inherit",
        cwd: ROOT,
        shell: process.platform === "win32",   // Windows 下需要走 shell 解析 .cmd
        ...opts,
    });
    if (r.status !== 0) {
        console.error(`\n✗ 命令执行失败 (exit ${r.status}): ${display}`);
        process.exit(r.status ?? 1);
    }
}

function fmtSize(bytes) {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / 1024 / 1024).toFixed(2)} MB`;
}

function main() {
    const args = process.argv.slice(2);
    const skipCompile = args.includes("--skip-compile");
    const skipTests = args.includes("--skip-tests");

    const pkg = readPkg();
    const vsixName = `${pkg.name}-${pkg.version}.vsix`;
    const tmpVsix = path.join(ROOT, vsixName);
    const finalVsix = path.join(RES_DIR, vsixName);

    console.log(`╔══════════════════════════════════════════════════════════╗`);
    console.log(`║ 打包 ${pkg.displayName || pkg.name} v${pkg.version}`);
    console.log(`║ 目标: res/${vsixName}`);
    console.log(`╚══════════════════════════════════════════════════════════╝`);

    // 1. 测试 (含编译)
    if (!skipTests) {
        run("npm", ["test"]);
    }
    else if (!skipCompile) {
        run("npm", ["run", "compile"]);
    }
    else {
        console.log("\n(已跳过编译与测试, 假设产物已是最新)");
    }

    // 2. 确保 res/ 目录存在
    if (!fs.existsSync(RES_DIR)) {
        fs.mkdirSync(RES_DIR, { recursive: true });
    }

    // 3. 若已存在同名 vsix, 先删掉以免 vsce 报错或残留旧文件
    if (fs.existsSync(tmpVsix)) fs.unlinkSync(tmpVsix);
    if (fs.existsSync(finalVsix)) fs.unlinkSync(finalVsix);

    // 4. 调 vsce package
    //    --no-dependencies: 我们只发布 client/server 已编译产物, 不需要 vsce 重新跑 npm
    //    若你的 publisher token 缺失, vsce package 仍可用; vsce publish 才需要登录
    run("vsce", ["package", "--out", tmpVsix]);

    // 5. 移动到 res/
    if (!fs.existsSync(tmpVsix)) {
        console.error(`✗ 未找到生成的 ${tmpVsix}`);
        process.exit(1);
    }
    fs.renameSync(tmpVsix, finalVsix);

    const size = fs.statSync(finalVsix).size;
    console.log(`\n✓ 打包完成:`);
    console.log(`  路径: ${path.relative(ROOT, finalVsix).replace(/\\/g, "/")}`);
    console.log(`  体积: ${fmtSize(size)}`);
}

main();
