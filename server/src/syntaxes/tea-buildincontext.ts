// ================================================================
// smbx teascript 内建类型和函数的预设
// ================================================================

import { TeaBuildinContextDeclare } from './tea-context';

const teaBuildinContext: TeaBuildinContextDeclare = {
    // 内建类型
    types: [
        {
            name: "bgo-return",
            field: [
                { name: "X", type: "Double", description: "背景的横向坐标" },
                { name: "Y", type: "Double" },
                { name: "Xsp", type: "Double" },
                { name: "Ysp", type: "Double" },
                { name: "Forecolor", type: "String" },
                { name: "ID", type: "Integer" },
                { name: "permid", type: "Integer" },
                { name: "ExtX", type: "Double" },
                { name: "ExtY", type: "Double" },
                { name: "Zpos", type: "Double" },
                { name: "forecolor_r", type: "Byte" },
                { name: "forecolor_g", type: "Byte" },
                { name: "forecolor_b", type: "Byte" },
                { name: "forecolor_a", type: "Byte" },
            ]
        }
    ],

    // 内建变量
    vars: [],

    // 内建函数
    funcs: [
        { name: "BGO", type: "bgo-return", params: ["Integer"], description: "背景设置" },
    ]
};

export default teaBuildinContext;