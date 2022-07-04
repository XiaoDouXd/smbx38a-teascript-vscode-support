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
                { name: "x", type: "Double", description: "背景的横向坐标" },
                { name: "y", type: "Double", description: "背景的纵向坐标" },
                { name: "xsp", type: "Double", description: "表示背景的横向速度" },
                { name: "ysp", type: "Double", description: "表示背景的纵向速度" },
                { name: "forecolor", type: "String", description: "表示背景的颜色, 使用 rgba 方式设置颜色" },
                { name: "id", type: "Integer", description: "表示背景的 ID" },
                { name: "permid", type: "Integer", description: "表示背景的永久 ID" },
                { name: "extX", type: "Double", description: "背景所使用的拓展素材的横向位置" },
                { name: "extY", type: "Double", description: "背景所使用的拓展素材的纵向位置" },
                { name: "zPos", type: "Double", description: "表示背景的 z 坐标" },
                { name: "forecolor_r", type: "Byte", description: "背景的 rgba 前景色中的红色通道的数值" },
                { name: "forecolor_g", type: "Byte", description: "背景的 rgba 前景色中的绿色通道的数值" },
                { name: "forecolor_b", type: "Byte", description: "背景的 rgba 前景色中的蓝色通道的数值" },
                { name: "forecolor_a", type: "Byte", description: "背景的 rgba 前景色中的透明通道的数值" },
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