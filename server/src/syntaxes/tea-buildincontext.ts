// ================================================================
// smbx teascript 内建类型和函数的预设
// ================================================================

import { TeaBuildinContextDeclare } from './tea-context';

// ---------------------------------------------------------------- 内建变量和类型
// 因为一些特殊原因, 基本变量和关键字的声明放在 tea-context.ts 中
// 如有需要请移步查看

// 因为在设计模板时
// 所做的所有匹配都是大小写敏感的
// 所以同样的函数和变量可以用不同的大小写模式多写几个

/** 内建变量声明 */
const teaBuildinContext: TeaBuildinContextDeclare = {
    // 内建类型
    types: [
        {
            name: "-bgo-return-",
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
        },
        {
            name: "-bgp-return-",
            field: [
                { name: "splitcount", type: "Integer", description: "表示大背景贴图素材被分割的次数" },
                { name: "splitter", type: "String", description: "一个包含大背景贴图素材的分割点的纵坐标数据的字符串, 由一串用逗号所分割的的整数组成" },
                { name: "zsp", type: "String", description: "一个包含大背景贴图素材的不同的分割部分的偏移常数数据的字符串，由一串用逗号所分割的的浮点数组成" },
                { name: "movesp", type: "String", description: "一个包含大背景贴图素材的不同的分割部分的移动速度数据（单位：像素/帧）的字符串，由一串用逗号所分割的的浮点数组成" },
                { name: "offset", type: "String", description: "一个包含大背景贴图素材的不同的分割部分的偏移量数据的字符串，由一串用逗号所分割的的浮点数组成" },
            ]
        },
        {
            name: "-bitmap-return-",
            field: [
                { name: "destx", type: "Double", description: "Bitmap 在屏幕上的 X 坐标" },
                { name: "desty", type: "Double", description: "Bitmap 在屏幕上的 Y 坐标" },
                { name: "scalex", type: "Double", description: "X 轴缩放比例" },
                { name: "scaley", type: "Double", description: "Y 轴缩放比例" },
                { name: "rotating", type: "Double", description: "Bitmap 的旋转角度" },
                { name: "hide", type: "Double", description: "是否隐藏" },
                { name: "zpos", type: "Double", description: "z-index 坐标" },
                { name: "color", type: "Double", description: "颜色参数, 建议用 forecolor" },
                { name: "blendMode", type: "Double", description: "混合模式" },
                { name: "attscreen", type: "Double", description: "是否为固定屏幕坐标" },
                { name: "scrx", type: "Double", description: "裁剪源文件的开始点 X 坐标" },
                { name: "scry", type: "Double", description: "裁剪源文件的开始点 Y 坐标" },
                { name: "scrwidth", type: "Byte", description: "裁剪源文件的宽度" },
                { name: "scrheight", type: "Byte", description: "裁剪源文件的高度" },
                { name: "rotatx", type: "Double", description: "缩放或旋转中心点 X 坐标" },
                { name: "rotaty", type: "Double", description: "缩放或旋转中心点 Y 坐标" },
                { name: "scrid", type: "Double", description: "原图 NPC ID" },
            ]
        },
        {
            name: "-block-return-",
            field: [
                { name: "x", type: "Double", description: "砖块的横坐标" },
                { name: "y", type: "Double", description: "砖块的纵坐标" },
                { name: "xsp", type: "Double", description: "砖块的横向速度" },
                { name: "ysp", type: "Double", description: "砖块的纵向速度" },
                { name: "id", type: "Double", description: "砖块的 ID" },
                { name: "permid", type: "Double", description: "砖块的永久 ID" },
                { name: "state", type: "Double", description: "若设置为1, 砖块将进入被敲击的状态; 若设为其它值则会破碎" },
                { name: "hide", type: "Double", description: "表示砖块是否可见" },
                { name: "advset", type: "Double", description: "砖块内所包含的物品" },
                { name: "pcollision", type: "Double", description: "玩家与砖块之间的碰撞判定类型" },
                { name: "ncollision", type: "Double", description: "NPC 与砖块之间的碰撞判定类型" },
                { name: "forecolor", type: "Double", description: "砖块的颜色" },
                { name: "haswing", type: "Byte", description: "决定砖块是否拥有特殊类型" },
                { name: "extX", type: "Byte", description: "砖块所使用的拓展素材的横向位置" },
                { name: "extY", type: "Double", description: "砖块所使用的拓展素材的纵向位置" },
                { name: "width", type: "Double", description: "砖块的判定宽度" },
                { name: "height", type: "Double", description: "砖块的判定高度" },
                { name: "Onscreenevent", type: "Double", description: "砖块出现在屏幕中时触发的事件的名称" },
                { name: "Hitevent", type: "Double", description: "表示砖块被敲击时触发的事件的名称" },
                { name: "forecolor_r", type: "Double", description: "砖块的 rgba 前景色中的红色通道的数值" },
                { name: "forecolor_g", type: "Double", description: "砖块的 rgba 前景色中的绿色通道的数值" },
                { name: "forecolor_b", type: "Double", description: "砖块的 rgba 前景色中的蓝色通道的数值" },
                { name: "forecolor_a", type: "Double", description: "砖块的 rgba 前景色中的透明通道的数值" },
            ]
        },
        {
            name: "-char-return-",
            field: [
                { name: "x", type: "Double", description: "X 坐标" },
                { name: "y", type: "Double", description: "Y 坐标" },
                { name: "xsp", type: "Double", description: "横向速度" },
                { name: "ysp", type: "Double", description: "纵向速度" },
                { name: "id", type: "Double", description: "玩家的 ID" },
                { name: "status", type: "Double", description: "玩家的形态" },
                { name: "itemslot", type: "Double", description: "玩家所携带的物品" },
                { name: "itemrsrv", type: "Double", description: "玩家的道具箱的物品" },
                { name: "invtime", type: "Double", description: "玩家的无敌时间" },
                { name: "hitpoint", type: "Double", description: "玩家的生命值" },
                { name: "facing", type: "Double", description: "玩家的方向" },
                { name: "bombcnt", type: "Byte", description: "玩家携带的炸弹数量" },
                { name: "keycnt", type: "Byte", description: "玩家携带的钥匙数量" },
                { name: "fluddcap", type: "Double", description: "FLUDD 的水的数量" },
                { name: "brightness", type: "Double", description: "光照系统" },
                { name: "fwidth", type: "Double", description: "玩家的宽度碰撞箱" },
                { name: "fheight", type: "Double", description: "玩家的高度碰撞箱" },
                { name: "flytime", type: "Double", description: "玩家的飞行时间" },
                { name: "ynpcid", type: "Double", description: "当玩家操纵耀西时被耀西吞下去的 NPC" },
                { name: "sjumping", type: "Double", description: "玩家是否在旋转跳跃状态" },
                { name: "grabbing", type: "Double", description: "返回玩家所拿取的 NPC 的 PermID" },
                { name: "walljumptimer", type: "Double", description: "Determines whether the player is sliding against a wall if wall jumping is enabled." },
                { name: "icetimer", type: "Double", description: "玩家被冻住的时间" },
                { name: "pulling", type: "Double", description: "玩家是否处在挖掘或抓取 NPC 的状态" },
                { name: "sliding", type: "Double", description: "玩家是否在滑行" },
                { name: "weapon", type: "Double", description: "调整玩家在发射子弹套装时发射子弹的 NPC" },
                { name: "alive", type: "Double", description: "玩家是否存活" },
                { name: "climbing", type: "Byte", description: "玩家是否在攀爬" },
                { name: "forecolor", type: "Byte", description: "玩家的 Sprite 显示前景色" },
                { name: "forecolor_r", type: "Double", description: "前景色的红色色度值" },
                { name: "forecolor_g", type: "Double", description: "前景色的绿色色度值" },
                { name: "forecolor_b", type: "Double", description: "前景色的蓝色色度值" },
                { name: "forecolor_a", type: "Double", description: "前景色的透明度值" },
                { name: "inwater", type: "Double", description: "玩家是否在流场中" },
                { name: "stand", type: "Double", description: "玩家是否在站立" },
                { name: "warping", type: "Double", description: "玩家是否正在传送" },
                { name: "scriptid", type: "Double", description: "未知效果, 强制使用会报错" },
                { name: "jmpchance", type: "Double", description: "玩家是否可以跳跃" },
                { name: "nomove", type: "Byte", description: "设置玩家是否能通过操作移动" },
                { name: "section", type: "Byte", description: "玩家当前所在的场景 ID" },
            ]
        },
        {
            name: "-effect-return-",
            field: [
                { name: "x", type: "Double", description: "横向坐标" },
                { name: "y", type: "Double", description: "纵向坐标" },
                { name: "xsp", type: "Double", description: "横向速度" },
                { name: "ysp", type: "Double", description: "纵向速度" },
                { name: "id", type: "Integer", description: "表示 Effect 的 ID" },
                { name: "extx", type: "Integer", description: "Effect 图像位于 GFX 扩展坐标系的X坐标" },
                { name: "exty", type: "Integer", description: "Effect 图像位于 GFX 扩展坐标系的Y坐标" },
                { name: "zpos", type: "Integer", description: "z-index 坐标" },
            ]
        },
        {
            name: "-liquid-return-",
            field: [
                { name: "x", type: "Double", description: "横向坐标" },
                { name: "y", type: "Double", description: "纵向坐标" },
                { name: "xsp", type: "Double", description: "横向速度" },
                { name: "ysp", type: "Double", description: "纵向速度" },
                { name: "fidr", type: "Integer", description: "力场方向" },
                { name: "fval", type: "Integer", description: "力场的加速度" },
                { name: "fmax", type: "Integer", description: "力场的最大速度" },
            ]
        },
        {
            name: "-lvltimer-return-",
            field: [
                { name: "x", type: "Double", description: "X 坐标" },
                { name: "y", type: "Double", description: "Y 坐标" },
                { name: "type", type: "Double", description: "计时模式" },
                { name: "show", type: "Double", description: "是否显示计时器" },
                { name: "color", type: "Integer", description: "颜色" },
                { name: "count", type: "Integer", description: "当前时间数" },
                { name: "intv", type: "Integer", description: "计时间隔" },
            ]
        },
        {
            name: "-npc-return-",
            field: [
                { name: "x", type: "Double", description: "X 坐标" },
                { name: "y", type: "Double", description: "Y 坐标" },
                { name: "xsp", type: "Double", description: "横向速度" },
                { name: "ysp", type: "Double", description: "纵向速度" },
                { name: "prX", type: "Double", description: "NPC 的初始位置的横向坐标" },
                { name: "prY", type: "Double", description: "NPC 的初始位置的纵向坐标" },
                { name: "id", type: "Integer", description: "NPC 的 ID" },
                { name: "addvx", type: "Double", description: "NPC 的横向平台加速度" },
                { name: "addvy", type: "Double", description: "NPC 的纵向平台加速度" },
                { name: "friendly", type: "Double", description: "NPC 是否为友好状态" },
                { name: "facing", type: "Double", description: "NPC 的方向" },
                { name: "noMove", type: "Byte", description: "NPC 是否为不移动状态" },
                { name: "curframe", type: "Integer", description: "NPC 当前播放的动画帧的编号" },
                { name: "health", type: "Integer", description: "NPC 当前的血量" },
                { name: "advSet", type: "Integer", description: "附加数据" },
                { name: "permid", type: "Double", description: "NPC 的永久 ID" },
                { name: "alive", type: "Byte", description: "NPC 是否处于存活状态" },
                { name: "name", type: "String", description: "NPC 的附加名称" },
                { name: "ivala", type: "Integer", description: "自定义变量 A" },
                { name: "ivalb", type: "Integer", description: "自定义变量 B" },
                { name: "ivalc", type: "Integer", description: "自定义变量 C" },
                { name: "width", type: "Integer", description: "NPC 的判定宽度" },
                { name: "height", type: "Integer", description: "NPC 的判定高度" },
                { name: "bkupx", type: "Double", description: "NPC 的备用横坐标" },
                { name: "bkupy", type: "Double", description: "NPC 的备用纵坐标" },
                { name: "curtimer", type: "Double", description: "NPC 的自定义计时器" },
                { name: "scount", type: "Double", description: "(弃用的)表示在同一位置有多少个 NPC" },
                { name: "zpos", type: "Double", description: "表示 NPC 的 z 坐标" },
                { name: "inwater", type: "Double", description: "表示 NPC 是否处于水中" },
                { name: "forecolor", type: "Integer", description: "前景色" },
                { name: "hide", type: "Double", description: "表示 NPC 是否为隐藏状态" },
                { name: "extx", type: "Double", description: "NPC 所使用的拓展素材的横向位置" },
                { name: "exty", type: "Double", description: "NPC 所使用的拓展素材的纵向位置" },
                { name: "forecolor_r", type: "Double", description: "NPC 的 rgba 前景色中的红色通道的数值" },
                { name: "forecolor_g", type: "Integer", description: "NPC 的 rgba 前景色中的绿色通道的数值" },
                { name: "forecolor_b", type: "Integer", description: "NPC 的 rgba 前景色中的蓝色通道的数值" },
                { name: "forecolor_a", type: "Integer", description: "NPC 的 rgba 前景色中的透明通道的数值" },
                { name: "stand", type: "Integer", description: "NPC 是否处于站立状态" },
                { name: "langle", type: "Double", description: "暂不了解其实际用途" },
                { name: "stimer", type: "Double", description: "暂不了解其实际用途, 若设置为正数则该参数的数值每帧会减少 1, 直到为 0" },
                { name: "target", type: "Double", description: "NPC 的目标" },
                { name: "dtcplayer", type: "Byte", description: "NPC 是否可以和玩家互动" },
                { name: "dtcliquid", type: "Byte", description: "NPC 是否可以和流场互动" },
                { name: "dtcself", type: "Double", description: "NPC 是否可以和其它 NPC 互动" },
                { name: "extset", type: "Double", description: "NPC 的外部设置" },
                { name: "talkevent", type: "String", description: "和 NPC 谈话时所触发的事件的名称" },
                { name: "deathevent", type: "String", description: "NPC 死亡时所触发的事件的名称" },
                { name: "touchevent", type: "String", description: "玩家和 NPC 接触时所触发的事件的名称" },
                { name: "activeevent", type: "String", description: "NPC 进入屏幕时所触发的事件的名称" },
                { name: "nextframeevent", type: "String", description: "NPC 的动画帧播放到下一帧时所触发的事件的名称" },
                { name: "grabedevent", type: "String", description: "NPC 被玩家抓取时所触发的事件的名称" },
                { name: "layerclearedevent", type: "String", description: "NPC 所在的图层内的对象全部被清除时所触发的事件的名称" },
                { name: "haswing", type: "String", description: "NPC是否拥有翅膀" },
            ]
        },
        {
            name: "-text-return-",
            field: [
                { name: "x", type: "Double", description: "X坐标" },
                { name: "y", type: "Double", description: "Y坐标" },
                { name: "text", type: "String", description: "文本内容" },
                { name: "hide", type: "Double", description: "是否隐藏" },
                { name: "zpos", type: "Double", description: "z-index 坐标" },
                { name: "color", type: "Double", description: "颜色参数" },
                { name: "width", type: "Double", description: "单行字符数" },
                { name: "foreground", type: "Double", description: "等同 hide" },
                { name: "height", type: "Double" },
            ]
        },
        {
            name: "-warp-return-",
            field: [
                { name: "x", type: "Double", description: "该传送点的入口在X坐标的位置" },
                { name: "y", type: "Double", description: "该传送点的入口在Y坐标的位置" },
                { name: "ex", type: "Double", description: "该传送点的出口在X坐标的位置" },
                { name: "ey", type: "Double", description: "该传送点的出口在Y坐标的位置" },
                { name: "xsp", type: "Double", description: "The X-axis speed of the warp. Also affects entrance effect." },
                { name: "ysp", type: "Double", description: "The Y-axis speed of the warp. Also affects entrance effect." },
                { name: "cannon", type: "Double", description: "如果为0, 则为正常传送点; 如果为非0自然数, 则该传送点具有发射的性质, 代表发射的飞行帧数" },
                { name: "starCnt", type: "Double", description: "该传送点需要多少星星才能进入" },
                { name: "starMsg", type: "String", description: "玩家尝试进入该传送点并达不到星星需求时的提示信息" },
                { name: "locked", type: "Double", description: "如果为 1, 则该传送点需要钥匙进入" },
                { name: "bomb", type: "Double", description: "如果为 1, 则该传送点需要炸弹爆炸进入" },
                { name: "noYoshi", type: "Double", description: "如果为 1, 则该传送点将禁止耀西从 Exit 出现" },
                { name: "canPick", type: "Byte", description: "如果为 1, 则该传送点将允许玩家携带物品一起进入" },
                { name: "mini", type: "Byte", description: "如果为 1, 则该传送点将只能允许迷你形态进入" },
                { name: "twoWay", type: "Double", description: "如果为 1, 则该传送点将允许双通" },
                { name: "warpevent", type: "Double", description: "该传送点的执行事件名" },
                { name: "levelname", type: "Double", description: "传送之后进入的某个关卡" },
                { name: "levelwarp", type: "Double", description: "传送之后进入的某个关卡对应的传送ID" },
            ]
        },
    ],

    // 内建变量
    vars: [
        { name: "param1", type: "Sysvar", description: "系统变量 1" },
        { name: "param2", type: "Sysvar", description: "系统变量 2" },
        { name: "param3", type: "Sysvar", description: "系统变量 3" },

        { name: "nCount", type: "Sysvar", description: "现存 NPC 数量" },
        { name: "bCount", type: "Sysvar", description: "现存砖块数量" },
        { name: "bgoCount", type: "Sysvar", description: "现存BGO数量" },
        // 没录完
    ],

    // 内建函数
    funcs: [
        { name: "BGO", type: "-bgo-return-", params: [{ type: "Integer", name: "id", description: "玩家的id" }], description: "背景设置" },
        { name: "BGP", type: "-bgp-return-", params: [{ type: "Integer", name: "id", description: "玩家的id" }], description: "背景分割设置" },
        { name: "Bitmap", type: "-bitmap-return-", params: [{ type: "Integer", name: "id", description: "玩家的id" }], description: "位图设置" },
        { name: "Block", type: "-block-return-", params: [{ type: "Integer", name: "id", description: "玩家的id" }], description: "砖块设置" },
        { name: "Char", type: "-char-return-", params: [{ type: "Integer", name: "id", description: "玩家的id" }], description: "角色属性设置" },
        { name: "Effect", type: "-effect-return-", params: [{ type: "Integer", name: "id", description: "玩家的id" }], description: "调整 Effect 的属性" },
        { name: "Liquid", type: "-liquid-return-", params: [{ type: "Integer", name: "id", description: "玩家的id" }], description: "调整流场的属性" },
        { name: "Lvltimer", type: "-lvltimer-return-", params: [{ type: "Integer", name: "id", description: "玩家的id" }], description: "调整时间系统的属性" },
        { name: "NPC", type: "-npc-return-", params: [{ type: "Integer", name: "id", description: "玩家的id" }], description: "调整 NPC 的属性" },
        { name: "Text", type: "-text-return-", params: [{ type: "Integer", name: "id", description: "玩家的id" }], description: "调整文本的属性" },
        { name: "Warp", type: "-warp-return-", params: [{ type: "Integer", name: "id", description: "玩家的id" }], description: "传送设置" },

        {
            name: "BSet", type: "Void", params: [
                { type: "Integer", name: "class" },
                { type: "Integer", name: "id" },
                { type: "Integer", name: "flagId" },
                { type: "Integer", name: "param1" },
                { type: "Integer", name: "param2" },
                { type: "Integer", name: "param3" },
            ], description: "设置一些 NPC 属性"
        },
        {
            name: "Sysval", type: "Integer", params: [
                { type: "Sysvar", name: "name" }
            ], description: "系统变量"
        },
        {
            name: "Playnote", type: "Void", params: [{ type: "Integer", name: "command", description: "形如: Volume * 65536 + Flip * 256 + 144 + Channel" }]
        },
        {
            name: "TCreate", type: "Void", params: [{ type: "String", name: "eventName", description: "要触发的事件名" }, { type: "Integer", name: "delay", description: "延迟的帧数" }],
            description: "创建事件"
        },
        {
            name: "TClear", type: "Void", params: [{ type: "Integer", name: "flag", description: "清除类型" }, { type: "String", name: "eventName", description: "要删除的事件名" }],
            description: "删除事件"
        },
        {
            name: "TCreateEX", type: "Void", params: [
                { type: "String", name: "name", description: "要执行的脚本" },
                { type: "String", name: "delay", description: "等待帧" },
                { type: "Sysvar", name: "param1", description: "传递给 param1 的值" },
                { type: "Sysvar", name: "param2", description: "传递给 param2 的值" },
                { type: "Sysvar", name: "param3", description: "传递给 param3 的值" },
            ],
            description: "执行脚本"
        },
        {
            name: "AudioSet", type: "Void", params: [
                { type: "Integer", name: "flag", description: "决定该函数起什么效果的参数" },
                { type: "Integer", name: "sid/fadem", description: "根据 flag 的值该参数的用途会有变化" },
                { type: "Integer", name: "par/0" },
                { type: "String", name: "filepath" }
            ],
            description: "音效/音乐播放"
        },
        {
            name: "HUDSet", type: "Void", params: [
                { type: "String", name: "command", description: "决定该函数的用途" },
                { type: "Double", name: "p0" },
                { type: "Double", name: "p1" },
                { type: "Double", name: "p2" },
                { type: "Double", name: "p3" },
                { type: "Double", name: "p4" },
                { type: "Double", name: "p5" },
                { type: "Double", name: "p6" },
                { type: "Double", name: "p7" },
                { type: "Double", name: "p8" },
                { type: "Double", name: "p9" }
            ],
            description: "堪称糟糕的设计 无法确定该函数的用途"
        },
        {
            name: "TXTCreate", type: "Void", params: [
                { type: "Integer", name: "id", description: "文本对象的唯一 id" },
                { type: "Double", name: "x", description: "文本对象的 x 坐标" },
                { type: "Double", name: "y", description: "文本对象的 y 坐标" },
                { type: "Byte", name: "sasc", description: "文本对象开始字符的 ASCII 码" },
                { type: "Byte", name: "easc", description: "文本对象末尾字符的 ASCII 码" },
                { type: "Integer", name: "cdata", description: "保留参数 设置为 0" },
                { type: "Integer", name: "lnum", description: "文本对象单行字符数" },
                { type: "Integer", name: "fontid", description: "用作字体的 npcId" },
                { type: "Integer", name: "flag", description: "1-以关卡坐标为基准 2-以屏幕坐标为基准" },
                { type: "String", name: "text", description: "文本内容" }
            ],
            description: "创建文本"
        },
        {
            name: "BMPCreate", type: "Void", params: [
                { type: "Integer", name: "id", description: "位图唯一 id" },
                { type: "Integer", name: "picid", description: "作为图源的 npcId" },
                { type: "Integer", name: "flag", description: "坐标系基准(0 或 1)" },
                { type: "Integer", name: "visible", description: "可见性(0 或 1)" },
                { type: "Double", name: "x", description: "x 坐标" },
                { type: "Double", name: "y", description: "y 坐标" },
                { type: "Double", name: "sx", description: "图源坐上角点 x 坐标" },
                { type: "Double", name: "sy", description: "图源坐上角点 y 坐标" },
                { type: "Double", name: "sw", description: "裁切后位图宽度" },
                { type: "Double", name: "sh", description: "裁切后位图高度" },
                { type: "Double", name: "dx", description: "所显示位图 x 坐标" },
                { type: "Double", name: "dy", description: "所显示位图 y 坐标" },
                { type: "Double", name: "scx", description: "横向拉伸比" },
                { type: "Double", name: "scy", description: "纵向拉伸比" },
                { type: "Double", name: "pcx", description: "变换中心 x 坐标" },
                { type: "Double", name: "pcy", description: "变换中心 y 坐标" },
                { type: "Double", name: "angle", description: "旋转角" },
                { type: "Integer", name: "color", description: "颜色" },
            ],
            description: "创建位图"
        },
        {
            name: "BErase", type: "Void", params: [
                { type: "Integer", name: "flag", description: "决定该函数的用途" },
                { type: "Integer", name: "id", description: "要释放的对象 id" }
            ],
            description: "释放对象"
        },
        {
            name: "FXCreate", type: "Void", params: [
                { type: "Integer", name: "id", description: "特效 id" },
                { type: "Double", name: "x", description: "x 坐标" },
                { type: "Double", name: "y", description: "y 坐标" },
                { type: "Double", name: "sx", description: "x 速度" },
                { type: "Double", name: "sy", description: "y 速度" },
                { type: "Integer", name: "f", description: "帧数" },
                { type: "Double", name: "fs", description: "帧率" },
                { type: "Double", name: "fc", description: "y 扩展帧" },
                { type: "Boolean", name: "notg", description: "是否禁用重力" },
                { type: "Double", name: "advset" }
            ],
            description: "创建特效"
        },
        {
            name: "LMove", type: "Void", params: [
                { type: "String", name: "name", description: "图层名" },
                { type: "Double", name: "px", description: "x 参数" },
                { type: "Double", name: "py", description: "y 参数" },
                { type: "Integer", name: "flag", description: "移动样式" },
            ],
            description: "图层移动"
        },
        {
            name: "LSet", type: "Void", params: [
                { type: "String", name: "name", description: "图层名" },
                { type: "Integer", name: "flag", description: "图层是否隐藏(0 或 1)" },
                { type: "Boolean", name: "advset", description: "是否显示烟雾特效" }
            ],
            description: "图层可视"
        },
        {
            name: "LSpin", type: "Void", params: [
                { type: "String", name: "name", description: "图层名" },
                { type: "Double", name: "cx", description: "旋转中心 x 坐标" },
                { type: "Double", name: "cy", description: "旋转中心 y 坐标" },
                { type: "Integer", name: "aspeed", description: "旋转速度" },
            ],
            description: "图层移动"
        },
        {
            name: "ItrCreate", type: "Void", params: [
                { type: "Integer", name: "type", description: "遍历的对象类型" },
                { type: "Integer", name: "id", description: "id 过滤" },
                { type: "Integer", name: "x", description: "起始 x 坐标" },
                { type: "Integer", name: "y", description: "起始 y 坐标" },
            ],
            description: "创建迭代器"
        },
        {
            name: "ItrNext", type: "-object-", params: [
                { type: "Integer", name: "id", description: "读取的迭代器 id" }
            ],
            description: "获取迭代器的下一个值 若迭代结束则返回 0"
        },
        {
            name: "NCreate", type: "Integer", params: [
                { type: "Integer", name: "id", description: "npc id" },
                { type: "Double", name: "x", description: "x 坐标" },
                { type: "Double", name: "y", description: "y 坐标" },
                { type: "Double", name: "sx", description: "x 速度" },
                { type: "Double", name: "sy", description: "y 速度" },
                { type: "Double", name: "advset" },
                { type: "Integer", name: "cdata" },
            ],
            description: "创建 npc 并返回 npc permID"
        },
        {
            name: "NCreateGroup", type: "Void", params: [
                { type: "Integer", name: "id", description: "npc id" },
                { type: "Double", name: "x", description: "区域 x 坐标" },
                { type: "Double", name: "y", description: "区域 y 坐标" },
                { type: "Double", name: "RadiusCir", description: "区域半径" },
                { type: "Double", name: "AngleCir", description: "被生成的 NPC 位在圆上的位置" },
                { type: "Integer", name: "NPCcount", description: "要生成的 NPC 的数量" },
                { type: "Double", name: "Angle", description: "Seems to be related to a spawn angle" },
                { type: "Double", name: "spx", description: "x 速度" },
                { type: "Double", name: "spy", description: "y 速度" },
                { type: "Double", name: "Advanced", description: "每个NPC的 advanced 值" },
            ],
            description: "批量创建"
        },
        {
            name: "NKill", type: "Void", params: [
                { type: "Integer", name: "index", description: "删除样式" },
                { type: "Double", name: "rx", description: "矩形 x 坐标" },
                { type: "Double", name: "ry", description: "矩形 y 坐标" },
                { type: "Double", name: "rw", description: "矩形宽度" },
                { type: "Double", name: "rh", description: "矩形高度" },
                { type: "Integer", name: "id", description: "npc id" },
                { type: "Boolean", name: "effect", description: "显示死亡效果" },
                { type: "Double", name: "score", description: "计分" },
            ],
            description: "杀死 npc"
        },


        // --------------------------------------------------------------------------------
        {
            name: "SysShowMSG", type: "Void", params: [
                { type: "String", name: "Msg", description: "信息" },
                { type: "Integer", name: "type", description: "类型" },
                { type: "String", name: "Title", description: "标题" },
            ],
            description: "信息弹窗"
        },
        {
            name: "SysShowInput", type: "Void", params: [
                { type: "String", name: "Msg", description: "信息" },
                { type: "String", name: "Title", description: "标题" },
            ],
            description: "输入弹窗"
        },
        {
            name: "SpEvent", type: "Void", params: [
                { type: "Integer", name: "id" }
            ],
            description: "触发特殊事件"
        },
        {
            name: "KeyPress", type: "Integer", params: [
                { type: "Integer", name: "key-code" }
            ],
            description: "当对应 id 的按键按下去后 返回 -1"
        },
        {
            name: "EXEScript", type: "Void", params: [
                { type: "String", name: "name" }
            ],
            description: "执行脚本"
        },
        {
            name: "Sleep", type: "Void", params: [
                { type: "Integer", name: "delay" }
            ],
            description: "中断"
        },
        {
            name: "SCSet", type: "Void", params: [
                { type: "String", name: "name", description: "关卡名" },
                { type: "Integer", name: "scID" },
                { type: "Integer", name: "flag", description: "过滤器" }
            ],
            description: "星币值获取"
        },
        {
            name: "Debug", type: "Void", params: [
                { type: "String", name: "logs" }
            ],
            description: "输出调试信息"
        },
        {
            name: "rgba", type: "Integer", params: [
                { type: "Byte", name: "r" },
                { type: "Byte", name: "g" },
                { type: "Byte", name: "b" },
                { type: "Byte", name: "a" }
            ]
        },
        {
            name: "ShaderSet", type: "Void", params: [

            ]
        }
    ]
};

export default teaBuildinContext;