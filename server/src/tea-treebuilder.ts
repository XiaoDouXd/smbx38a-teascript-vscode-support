// ================================================================
// 用于测试上下文生成结果
// ================================================================

import { teaGlobalContext } from './tea-context';

function treeBuilder(): string
{
    // 函数定义
    let funcDef = "";
    teaGlobalContext.functions.forEach(func => {
        funcDef += `funcDef: ${func.name}\n`;
    });
    // 全域变量定义
    return funcDef;
}

export
{
    treeBuilder
};