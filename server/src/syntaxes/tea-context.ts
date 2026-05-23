// ================================================================
// 设计描述 smbx teascript 上下文信息的数据结构
// ================================================================

import { CompletionItem, CompletionItemKind, CompletionParams, InsertTextFormat, InsertTextMode } from 'vscode-languageserver';

// ---------------------------------------------------------------- 一些类型的枚举
const numTypes = ["Integer", "Double", "Byte", "Long", "Single"];
const txtTypes = ["String"];
const otherTypes = ["Boolean", "Void"];
const keywords = [
    "Then", "End",
    "Case", "GoTo",
    "GoSub", "As", "Next", "Loop", "While",
    "Step", "Continue", "Return", "Exit", "Until", "Call", "Mod", "ReDim"
];

function keywordComplex(_para: CompletionParams): CompletionItem[] {
    return [
        {
            label: "If",
            kind: CompletionItemKind.Snippet,
            insertText: "If $1 Then\n    \nEnd If",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet,
        },
        {
            label: "Else",
            kind: CompletionItemKind.Snippet,
            insertText: "Else\n    $1",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet,
        },
        {
            label: "ElseIf",
            kind: CompletionItemKind.Snippet,
            insertText: "ElseIf $1 Then\n    $2",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet,
        },
        {
            label: "GVal",
            kind: CompletionItemKind.Snippet,
            insertText: "GVal($1)",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet
        },
        {
            label: "Val",
            kind: CompletionItemKind.Snippet,
            insertText: "Val($1)",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet
        },
        {
            label: "Array",
            kind: CompletionItemKind.Snippet,
            insertText: "Array($1)",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet
        },
        {
            label: "Export",
            kind: CompletionItemKind.Snippet,
            insertText: "Export Script $1($2)\n    \nEnd Script",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet
        },
        {
            label: "Dim",
            kind: CompletionItemKind.Snippet,
            insertText: "Dim $1 As $2",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet
        },
        {
            label: "Script",
            kind: CompletionItemKind.Snippet,
            insertText: "Script $1()\n    \nEnd Script",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet
        },
        {
            label: "Select",
            kind: CompletionItemKind.Snippet,
            insertText: "Select Case $1\n    Case $2\nEnd Select",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet
        },
        {
            label: "Do",
            kind: CompletionItemKind.Snippet,
            insertText: "Do\n    $1\nLoop",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet
        },
        {
            label: "For",
            kind: CompletionItemKind.Snippet,
            insertText: "For $1 To $2 Step $3\n    $4\nNext",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet
        },
        {
            label: "With",
            kind: CompletionItemKind.Snippet,
            insertText: "With $1\n    $2\nEnd With",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet
        }
    ];
}

const teaBuiltinTypes = numTypes.concat(txtTypes, otherTypes);
const _teaBuiltinTypesLower = teaBuiltinTypes.map(t => t.toLocaleLowerCase());

const teaBuiltinTypesCompletion: CompletionItem[]
    = teaBuiltinTypes.map(type => {
        return {
            label: type,
            kind: CompletionItemKind.Struct
        };
    });

function teaBuiltinKeywordCompletion(pos: CompletionParams): CompletionItem[] {
    return keywordComplex(pos).concat(keywords.map(word => {
        return {
            label: word,
            kind: CompletionItemKind.Keyword,
            insertText: null,
            insertTextMode: InsertTextMode.adjustIndentation
        };
    }));
}

const exportFunc: Map<string, TeaFunc[]> = new Map<string, TeaFunc[]>();
const globalValue: Map<string, string[]> = new Map<string, string[]>();

/** 大小写不敏感的字符串比较 */
function ciEq(a: string | undefined | null, b: string | undefined | null): boolean {
    if (a == null || b == null) return false;
    return a.toLocaleLowerCase() === b.toLocaleLowerCase();
}

// ---------------------------------------------------------------- 语法结构描述
/** 类型描述 */
class TeaType {
    /** 类型名 */
    name: string;
    /** 成员名 */
    members: TeaVar[];
    /** 是否有序 */
    orderedMember = false;
    /** 域 */
    context: TeaContext;

    /**
     * @param name 类型名
     * @param members 所有成员变量
     */
    constructor(name: string, members: TeaVar[] = []) {
        this.name = name;
        this.members = members;
    }

    /**
     * 添加成员
     * @param value 成员变量
     */
    addMember(value: TeaVar) {
        value.context = null;
        this.members.push(value);
    }

    /**
     * 获取成员(大小写不敏感)
     * @param name 成员名
     */
    getMember(name: string): TeaVar | null {
        if (!name) return null;
        return this.members.find(m => ciEq(m.name, name)) ?? null;
    }
}

/** 数组类型描述 */
class TeaArray extends TeaType {
    elementTypeName: string;

    get elementType() { return this.context.getType(this.elementTypeName); }

    constructor(element: string) {
        super(`${element}[]`);
        this.elementTypeName = element;
    }
}

/** 变量描述 */
class TeaVar {
    /** 变量类型 */
    type: TeaType;
    /** 变量名 */
    name: string;
    /** 变量所属上下文 */
    context: TeaContext;

    /** 定义位置 */
    pos = 0;

    /** 描述 */
    description?: string;
    /** 必要的点操作前缀 */
    dotFlag = false;

    constructor(type: TeaType, name: string) {
        this.type = type;
        this.name = name;
    }

    toString() {
        const tyName = this.type ? this.type.name : "Unknown";
        return `${this.description ? this.description + ": " : ''}${this.name} As ${tyName}`;
    }
}

/** 函数描述 */
class TeaFunc {
    /** 返回类型 */
    type: TeaType;
    /** 函数名 */
    name: string;
    /** 参数表 */
    parameters: TeaVar[] = [];
    /** 函数本体的上下文 */
    functionContext: TeaContext;
    /** 跨域函数 */
    export = false;

    /** 描述 */
    description?: string;

    /** 声明位置 */
    pos = 0;

    constructor(type: TeaType, name: string, params: TeaVar[] = []) {
        this.type = type;
        this.name = name;
        this.parameters = params;
    }

    /**
     * 添加参数
     */
    addParameter(param: TeaVar) {
        this.parameters.push(param);
        // 已有 context 则同步注入(避免后续 setFunctionContext 重复)
        if (this.functionContext && !this.functionContext.variables.includes(param)) {
            this.functionContext.addVariable(param);
        }
    }

    /**
     * 设置函数覆盖的上下文
     *
     * 修复点: 旧实现会做 global.addContext(context), 而调用方
     * 又会单独 context.addContext(con), 导致 functionContext 同时
     * 挂在两个父节点上, 并使参数被重复添加. 这里只负责注入参数,
     * 父子关系交由调用方维护.
     */
    setFunctionContext(context: TeaContext) {
        this.functionContext = context;
        this.parameters.forEach(param => {
            if (!context.variables.includes(param))
                context.addVariable(param);
        });
    }

    toString() {
        const ret = this.type && this.type.name !== "Void"
            ? `, \nn. 返回: Return ${this.type.name}` : "";
        return `${this.description ? this.description + ": \n" : ''}${this.export ? "Export " : ""}Script ${this.name}(\n${this.parameters.map(p => p.toString()).join(", \n")}${ret}\n)`;
    }

    toCompletionItem(): CompletionItem {
        return {
            label: this.name,
            kind: CompletionItemKind.Function,
            detail: this.toString(),
            insertText: this.name + "($1)",
            insertTextMode: InsertTextMode.adjustIndentation,
            insertTextFormat: InsertTextFormat.Snippet
        };
    }
}

/** 上下文描述类 */
class TeaContext {
    /** 上一层(父)上下文 */
    upper: TeaContext;
    /** 下一层(子)上下文 */
    contexts: TeaContext[] = [];
    /** 上下文中的变量 */
    variables: TeaVar[] = [];
    /** 全局上下文 */
    global: TeaGlobalContext;

    addContext(context: TeaContext) {
        // 防止重复挂载
        if (this.contexts.includes(context)) return;
        this.contexts.push(context);
        context.upper = this;
        context.global = this.global;
    }

    addVariable(variable: TeaVar) {
        this.variables.push(variable);
        variable.context = this;
    }

    /**
     * 获取变量(大小写不敏感, 沿父链回溯)
     */
    getVariable(name: string): TeaVar | null {
        if (!name) return null;
        const v = this.variables.find(va => ciEq(va.name, name));
        if (v) return v;
        return this.upper ? this.upper.getVariable(name) : null;
    }

    /**
     * 获取类型
     *
     * 修复点: 旧实现遇到内建类型名时总是 new TeaType(name),
     * 这导致 members 永远为空, 使 'Dim x As Integer' 后访问 x. 没有补全.
     * 新实现优先在 declaredTypes 和 builtin types 中查找, 找到才复用其 members.
     */
    getType(name: string): TeaType {
        if (!name) return new TeaType("?");

        // 优先在 global.declaredTypes 中找
        if (this.global) {
            const declared = this.global.declaredTypes.find(t => ciEq(t.name, name));
            if (declared) return declared;
        }

        // 内建类型(大小写不敏感)
        if (_teaBuiltinTypesLower.indexOf(name.toLocaleLowerCase()) >= 0) {
            // 内建类型没有 members, 不需要复用实例, 给一个标准化的实例即可
            const canonical = teaBuiltinTypes[_teaBuiltinTypesLower.indexOf(name.toLocaleLowerCase())];
            return new TeaType(canonical);
        }

        // 还要找内建结构(如 -npc-return-)
        if (this.global) {
            const builtin = TeaGlobalContext.smbxBuiltinType?.find(t => ciEq(t.name, name));
            if (builtin) return builtin;
        }

        return new TeaType(`${name}?`);
    }

    getFunc(name: string): TeaFunc | null {
        return this.global ? this.global.getFunc(name) : null;
    }

    protected internalGetAllVariables(): Map<string, TeaVar> {
        let varMap = new Map<string, TeaVar>();
        if (this.upper)
            varMap = this.upper.internalGetAllVariables();
        for (let i = 0; i < this.variables.length; i++) {
            varMap.set(this.variables[i].name, this.variables[i]);
        }
        return varMap;
    }

    getAllVariables(): TeaVar[] {
        const varMap = this.internalGetAllVariables();
        const varList: TeaVar[] = [];
        for (const v of varMap.values()) varList.push(v);
        return varList;
    }
}

/** 全局上下文描述类 */
class TeaGlobalContext extends TeaContext {

    static smbxBuiltinVar: TeaVar[] = [];
    static smbxBuiltinType: TeaType[] = [];
    static smbxBuiltinFunc: TeaFunc[] = [];
    private static _builtinLoaded = false;

    /** 类型声明 */
    declaredTypes: TeaType[] = [];
    /** 函数声明 */
    functions: TeaFunc[] = [];

    constructor() {
        super();
        this.upper = null;
        this.declaredTypes = teaBuiltinTypes.map(t => new TeaType(t));
        this.global = this;
    }

    addCustomType(type: TeaType) { this.declaredTypes.push(type); }
    addFunction(func: TeaFunc) { this.functions.push(func); }

    protected internalGetAllVariables(): Map<string, TeaVar> {
        const varMap = new Map<string, TeaVar>();
        for (const v of TeaGlobalContext.smbxBuiltinVar) varMap.set(v.name, v);
        for (const v of this.variables) varMap.set(v.name, v);
        return varMap;
    }

    /**
     * 获取变量(大小写不敏感)
     */
    getVariable(name: string): TeaVar | null {
        if (!name) return null;
        const v = this.variables.find(va => ciEq(va.name, name));
        if (v) return v;
        return TeaGlobalContext.smbxBuiltinVar.find(va => ciEq(va.name, name)) ?? null;
    }

    /** 获得函数 */
    getFunc(name: string): TeaFunc | null {
        if (!name) return null;
        const u = this.functions.find(f => ciEq(f.name, name));
        if (u) return u;
        return TeaGlobalContext.smbxBuiltinFunc.find(f => ciEq(f.name, name)) ?? null;
    }

    static loadBuiltinContext(declare: TeaBuiltinContextDeclare) {
        if (TeaGlobalContext._builtinLoaded) return;

        const tyMap: Map<string, TeaType> = new Map();
        const ensureType = (name: string): TeaType => {
            let t = tyMap.get(name);
            if (!t) {
                t = new TeaType(name);
                tyMap.set(name, t);
            }
            return t;
        };

        if (declare.types) {
            TeaGlobalContext.smbxBuiltinType = [];
            declare.types.forEach((t) => {
                const m: TeaVar[] = [];
                t.field.forEach((f) => {
                    const tSave = ensureType(f.type);
                    const v = new TeaVar(tSave, f.name);
                    v.description = f.description;
                    m.push(v);
                });
                const ty = new TeaType(t.name, m);
                TeaGlobalContext.smbxBuiltinType.push(ty);
                tyMap.set(ty.name, ty);
            });
        }
        if (declare.funcs) {
            TeaGlobalContext.smbxBuiltinFunc = [];
            declare.funcs.forEach((f) => {
                const t = ensureType(f.type);
                const func = new TeaFunc(t, f.name);
                let i = 0;
                f.params.forEach((p) => {
                    const pt = ensureType(p.type);
                    const param = new TeaVar(pt, `-${p.name}-`);
                    if (p.description) param.description = `${++i}. ` + p.description;
                    func.addParameter(param);
                });
                func.description = f.description;
                TeaGlobalContext.smbxBuiltinFunc.push(func);
            });
        }
        if (declare.vars) {
            TeaGlobalContext.smbxBuiltinVar = [];
            declare.vars.forEach((v) => {
                const t = ensureType(v.type);
                const va = new TeaVar(t, v.name);
                va.description = v.description;
                TeaGlobalContext.smbxBuiltinVar.push(va);
            });
        }

        TeaGlobalContext._builtinLoaded = true;
    }
}

// ---------------------------------------------------------------- 内建函数和类型的声明

class TeaBuiltinTypeFieldDeclare {
    name: string;
    type: string;
    description?: string;
}

class TeaBuiltinTypeDeclare {
    name: string;
    field: TeaBuiltinTypeFieldDeclare[];
}

class TeaBuiltinFuncDeclare {
    name: string;
    type: string;
    params: TeaBuiltinVarDeclare[];
    description?: string;
}

class TeaBuiltinVarDeclare {
    name: string;
    type: string;
    description?: string;
}

class TeaBuiltinContextDeclare {
    types: TeaBuiltinTypeDeclare[];
    vars: TeaBuiltinVarDeclare[];
    funcs: TeaBuiltinFuncDeclare[];
}

// ---------------------------------------------------------------- 分析和封装方法
/**
 * 为变量列表创建智能补全消息
 */
function createCompletionItemsForVar(varList: TeaVar[], startOffset = Number.MAX_VALUE): CompletionItem[] {
    const result: CompletionItem[] = [];
    for (const v of varList) {
        if (!v) continue;
        if (v.dotFlag) continue;
        if (v.pos > startOffset) continue;
        result.push({
            label: v.name,
            kind: CompletionItemKind.Variable,
            detail: v.toString()
        });
    }
    return result;
}

/**
 * 为函数列表智能补全消息
 */
function createCompletionItemsForFunc(funcList: TeaFunc[], startOffset = Number.MAX_VALUE): CompletionItem[] {
    const result: CompletionItem[] = [];
    for (const f of funcList) {
        if (!f) continue;
        if (f.pos > startOffset) continue;
        result.push(f.toCompletionItem());
    }
    for (const f of (TeaGlobalContext.smbxBuiltinFunc ?? [])) {
        result.push(f.toCompletionItem());
    }
    return result;
}

/**
 * 为成员变量创建智能补全消息
 */
function createCompletionItemsForMembers(fields: TeaVar[]): CompletionItem[] {
    return fields.map(field => ({
        label: field.name,
        kind: CompletionItemKind.Field,
        detail: field.toString()
    }));
}

function createCompletionItems(labels: string[], kind: CompletionItemKind): CompletionItem[] {
    return labels.map(label => ({ label, kind }));
}

// ----------------------------------------------------------------
export {
    teaBuiltinTypes,
    teaBuiltinTypesCompletion,
    teaBuiltinKeywordCompletion,
    TeaType,
    TeaVar,
    TeaFunc,
    TeaArray,
    TeaContext,
    TeaGlobalContext,
    createCompletionItemsForVar,
    createCompletionItemsForFunc,
    createCompletionItemsForMembers,
    createCompletionItems,
    exportFunc,
    globalValue,
    ciEq,

    TeaBuiltinContextDeclare
};
