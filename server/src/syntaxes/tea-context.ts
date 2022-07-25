// ================================================================
// 设计描述 smbx teascript 上下文信息的数据结构
// ================================================================

import { type } from 'os';
import { CompletionItem, CompletionItemKind, Position } from 'vscode-languageserver';
import { matchGrammar, MatchResult } from './meta-grammar';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const linq = require('linq');

// ---------------------------------------------------------------- 一些类型的枚举
const numTypes = ["Integer", "Double", "Byte", "Long"];
const txtTypes = ["String"];
const otherTypes = ["Boolean", "Void"];
const keywords = [
    "If", "Else", "ElseIf", "End", "Select",
    "Case", "With", "Export", "Script", "GoTo",
    "GoSub", "Dim", "As", "Next", "For", "Do", "Loop", "While",
    "Step", "Call"
];

const teaBuildinTypes = numTypes.concat(txtTypes, otherTypes);
const teaBuildinTypesCompletion: CompletionItem[]
    = teaBuildinTypes.map(type => {
        return {
            label: type,
            kind: CompletionItemKind.Struct
        };
    });
const teaBuildinKeywordCompletion: CompletionItem[]
    = keywords.map(word => {
        return {
            label: word,
            kind: CompletionItemKind.Keyword
        };
    });

// ---------------------------------------------------------------- 语法结构描述
/** 类型描述 */
class TeaType {
    /** 类型名 */
    name: string;
    /** 成员名 */
    members: TeaVar[];
    /** 是否有序 */
    orderedMenber = false;
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
     * 获取成员
     * @param name 成员名
     */
    getMember(name: string): TeaVar {
        return linq.from(this.members)
            .where((member: TeaVar) => member.name === name)
            .firstOrDefault();
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

    /**
     * @param type 变量类型
     * @param name 变量名
     */
    constructor(type: TeaType, name: string) {
        this.type = type;
        this.name = name;
    }
    toString() {
        return `${this.description ? this.description + ": " : ''}${this.name} As ${this.type.name}`;
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

    /**
     * @param type 返回类型
     * @param name 函数名
     * @param params 参数列表
     */
    constructor(type: TeaType, name: string, params: TeaVar[] = []) {
        this.type = type;
        this.name = name;
        this.parameters = params;
    }
    /**
     * 添加参数
     * @param param 变量描述类
     */
    addParameter(param: TeaVar) {
        this.parameters.push(param);
        if (this.functionContext)
            this.functionContext.addVariable(param);
    }
    /**
     * 设置函数覆盖的上下文
     * @param context 上下文描述类
     */
    setFunctionContext(context: TeaContext) {
        this.functionContext = context;
        this.functionContext.global.addContext(context);
        this.parameters.forEach(param => context.addVariable(param));
    }
    toString() {
        return `${this.description ? this.description + ": \n" : ''}${this.export == false ? "" : "Export"} Script ${this.name}(\n${this.parameters.map(param => param.toString()).join(", \n")} ${this.type.name === "Void" ? "" : `, \nn. 返回: Return ${this.type.name}`}\n)`;
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


    /**
     * 添加子上下文
     * @param context 待添加的子上下文
     */
    addContext(context: TeaContext) {
        this.contexts.push(context);
        context.upper = this;
        context.global = this.global;
    }
    /**
     * 添加变量
     * @param variable 待添加的变量
     */
    addVariable(variable: TeaVar) {
        this.variables.push(variable);
        variable.context = this;
    }
    /**
     * 获取变量
     * @param name 变量名
     * @returns 变量描述类
     */
    getVariable(name: string): TeaVar {
        const v = linq.from(this.variables).where((variable: TeaVar) => variable.name === name).firstOrDefault();
        if (!v) {
            return this.upper ? this.upper.getVariable(name) : null;
        }
        return v;
    }
    /**
     * 获取类型
     * @param name 类型名
     * @returns 类型描述类
     */
    getType(name: string): TeaType {
        const reg = new RegExp(/(Integer|Double|Byte|Long|String)/, "i");

        const match = reg.exec(name);
        if (match) {
            return new TeaType(match[1]);
        }
        else if (teaBuildinTypes.indexOf(name) >= 0)
            return new TeaType(name);

        const t = linq.from(this.global.declaredTypes).where((t: TeaType) => t.name === name).firstOrDefault();
        return t ? t : new TeaType(`${name}?`);
    }
    getFunc(name: string): TeaFunc {
        return this.global.getFunc(name);
    }
    /**
     * 获取所有变量
     * @returns 一个{变量名, 变量描述类}字典
     */
    protected internalGetAllVariables(): Map<string, TeaVar> {
        let varMap = new Map<string, TeaVar>();
        if (this.upper)
            varMap = this.upper.internalGetAllVariables();
        for (let i = 0; i < this.variables.length; i++) {
            varMap.set(this.variables[i].name, this.variables[i]);
        }
        return varMap;
    }
    /**
     * 获取所有变量
     * @returns 变量描述类组
     */
    getAllVariables(): TeaVar[] {
        const varMap = this.internalGetAllVariables();
        const varList: TeaVar[] = [];
        for (const v of varMap.values()) {
            varList.push(v);
        }
        return varList;
    }
}
/** 全局上下文描述类 */
class TeaGlobalContext extends TeaContext {

    protected static smbxBuildinVar: TeaVar[];
    protected static smbxBuildinType: TeaType[];
    static smbxBuildinFunc: TeaFunc[];
    private static _buildinLoaded = false;

    /** 类型声明 */
    declaredTypes: TeaType[] = [];
    /** 函数声明 */
    functions: TeaFunc[] = [];

    constructor() {
        super();
        this.upper = null;
        this.declaredTypes = teaBuildinTypes.map(t => new TeaType(t));
        this.global = this;
    }
    /**
     * 添加子上下文
     * @param context 待添加的上下文
     */
    addContext(context: TeaContext) {
        super.addContext(context);
    }
    /**
     * 添加类型
     * @param type 类型描述类
     */
    addCustomType(type: TeaType) {
        this.declaredTypes.push(type);
    }
    /**
     * 添加函数
     * @param func 函数描述类
     */
    addFunction(func: TeaFunc) {
        this.functions.push(func);
    }
    /**
     * 获取所有变量
     * @returns 一个{变量名, 变量描述类}字典
     */
    protected internalGetAllVariables(): Map<string, TeaVar> {
        const varMap = new Map<string, TeaVar>();
        for (let i = 0; i < TeaGlobalContext.smbxBuildinVar.length; i++) {
            varMap.set(TeaGlobalContext.smbxBuildinVar[i].name, TeaGlobalContext.smbxBuildinVar[i]);
        }
        for (let i = 0; i < this.variables.length; i++) {
            varMap.set(this.variables[i].name, this.variables[i]);
        }
        return varMap;
    }
    /**
     * 获取变量
     * @param name 变量名
     * @returns 变量描述类
     */
    getVariable(name: string): TeaVar {
        let v = linq.from(this.variables).where((variable: TeaVar) => variable.name === name).firstOrDefault();
        if (!v) {
            v = linq.from(TeaGlobalContext.smbxBuildinVar).where((variable: TeaVar) => variable.name.toLocaleLowerCase() === name.toLocaleLowerCase()).firstOrDefault();
            if (!v)
                return null;
        }
        return v;
    }
    /**
     * 获取类型
     * @param name 类型名
     * @returns 类型描述类
     */
    getType(name: string): TeaType {
        const reg = new RegExp(/(Integer|Double|Byte|Long|String)/, "i");

        const match = reg.exec(name);
        if (match) {
            return new TeaType(match[1]);
        }
        else if (teaBuildinTypes.indexOf(name) >= 0)
            return new TeaType(name);

        let t = linq.from(this.global.declaredTypes).where((t: TeaType) => t.name.toLocaleLowerCase() === name.toLocaleLowerCase()).firstOrDefault();
        if (!t) {
            t = linq.from(TeaGlobalContext.smbxBuildinType).where((t: TeaType) => t.name.toLocaleLowerCase() === name.toLocaleLowerCase()).firstOrDefault();
        }
        return t ? t : new TeaType(`${name}?`);
    }
    /** 获得函数 */
    getFunc(name: string): TeaFunc {
        let v = linq.from(this.functions).where((func: TeaFunc) => func.name.toLocaleLowerCase() === name.toLocaleLowerCase()).firstOrDefault();
        if (!v)
            v = linq.from(TeaGlobalContext.smbxBuildinFunc).where((func: TeaFunc) => func.name.toLocaleLowerCase() === name.toLocaleLowerCase()).firstOrDefault();

        return v ? v : null;
    }
    static loadBuildinContext(declare: TeaBuildinContextDeclare) {
        if (TeaGlobalContext._buildinLoaded)
            return;

        const tyMap: Map<string, TeaType> = new Map();
        // 加载内建类型等
        if (declare.types) {
            TeaGlobalContext.smbxBuildinType = [];

            declare.types.forEach((t) => {

                const m: TeaVar[] = [];
                t.field.forEach((f) => {
                    let tSave = tyMap.get(f.type);
                    if (tSave) {
                        const v = new TeaVar(tSave, f.name);
                        m.push(v);
                        v.description = f.description;
                    }
                    else {
                        tSave = new TeaType(f.type);
                        tyMap.set(tSave.name, tSave);
                        const v = new TeaVar(tSave, f.name);
                        m.push(v);
                        v.description = f.description;
                    }

                });

                const ty = new TeaType(t.name, m);
                TeaGlobalContext.smbxBuildinType.push(ty);
                tyMap.set(ty.name, ty);
            });
        }
        if (declare.funcs) {
            TeaGlobalContext.smbxBuildinFunc = [];
            declare.funcs.forEach((f) => {
                const t = tyMap.get(f.type);
                if (t) {
                    const func = new TeaFunc(t, f.name);
                    TeaGlobalContext.smbxBuildinFunc.push(func);
                    let i = 0;
                    f.params.forEach((p) => {
                        const t = tyMap.get(p.type);
                        if (t) {
                            const param = new TeaVar(t, `-${p.name}-`);
                            param.description = p.description;
                            if (param.description)
                                param.description = `${++i}. ` + param.description;
                            func.addParameter(param);
                        }
                        else {
                            const tSave = new TeaType(p.type);
                            tyMap.set(tSave.name, tSave);
                            const param = new TeaVar(tSave, `-${p.name}-`);
                            param.description = p.description;
                            if (param.description)
                                param.description = `${++i}. ` + param.description;
                            func.addParameter(param);
                        }
                    });
                    func.description = f.description;
                }
                else {
                    const tSave = new TeaType(f.type);
                    tyMap.set(tSave.name, tSave);
                    const func = new TeaFunc(tSave, f.name);
                    TeaGlobalContext.smbxBuildinFunc.push(func);
                    let i = 0;
                    f.params.forEach((p) => {
                        const t = tyMap.get(p.type);
                        if (t) {
                            const param = new TeaVar(t, `-${p.name}-`);
                            param.description = p.description;
                            if (param.description)
                                param.description = `${++i}. ` + param.description;
                            func.addParameter(param);
                        }
                        else {
                            const tSaveParam = new TeaType(p.type);
                            tyMap.set(tSaveParam.name, tSaveParam);
                            const param = new TeaVar(tSaveParam, `-${p.name}-`);
                            param.description = p.description;
                            if (param.description)
                                param.description = `${++i}. ` + param.description;
                            func.addParameter(param);
                        }
                    });
                    func.description = f.description;
                }
            });
        }
        if (declare.vars) {
            TeaGlobalContext.smbxBuildinVar = [];
            declare.vars.forEach((v) => {
                const t = tyMap.get(v.type);
                if (t) {
                    const va = new TeaVar(t, v.name);
                    va.description = v.description;
                    TeaGlobalContext.smbxBuildinVar.push(va);
                }
                else {
                    const tSave = new TeaType(v.type);
                    tyMap.set(tSave.name, tSave);
                    const va = new TeaVar(tSave, v.name);
                    va.description = v.description;
                    TeaGlobalContext.smbxBuildinVar.push(va);
                }
            });
        }

        TeaGlobalContext._buildinLoaded = true;
    }
}

// ---------------------------------------------------------------- 内建函数和类型的声明

class TeaBuildinTypeFieldDeclare {
    /** 字段名 */
    name: string;
    /** 字段类型 */
    type: string;
    /** 详情 */
    description?: string;
}
class TeaBuildinTypeDeclare {
    /** 类型名 */
    name: string;
    /** 类型字段 */
    field: TeaBuildinTypeFieldDeclare[];
}
class TeaBuildinFuncDeclare {
    /** 函数名 */
    name: string;
    /** 类型名 */
    type: string;
    /** 参数名 */
    params: TeaBuildinVarDeclare[];

    /** 函数详情 */
    description?: string;
}
class TeaBuildinVarDeclare {
    name: string;
    type: string;
    description?: string;
}
class TeaBuildinContextDeclare {
    /** 内建类型 */
    types: TeaBuildinTypeDeclare[];
    /** 内建变量 */
    vars: TeaBuildinVarDeclare[];
    /** 内建函数 */
    funcs: TeaBuildinFuncDeclare[];
}

// ---------------------------------------------------------------- 分析和封装方法
/**
 * 为变量列表创建智能补全消息
 * @param varList 变量列表
 * @returns 
 */
function createCompletionItemsForVar(varList: TeaVar[], startOffset = Number.MAX_VALUE): CompletionItem[] {
    return varList.map(v => {
        if (v.pos <= startOffset && !v.dotFlag)
            return {
                label: v.name,
                kind: CompletionItemKind.Variable,
                detail: v.toString()
            };
    });
}
/**
 * 为函数列表智能补全消息
 * @param funcList 函数列表
 * @returns 
 */
function createCompletionItemsForFunc(funcList: TeaFunc[], startOffset = Number.MAX_VALUE): CompletionItem[] {
    return funcList.map(func => {
        if (func.pos < startOffset)
            return {
                label: func.name,
                kind: CompletionItemKind.Function,
                detail: func.toString()
            };
    }).concat(TeaGlobalContext.smbxBuildinFunc.map(func => {
        return {
            label: func.name,
            kind: CompletionItemKind.Function,
            detail: func.toString()
        };
    }));
}
/**
 * 为成员变量创建智能补全消息
 * @param fields 成员
 * @returns 
 */
function createCompletionItemsForMembers(fields: TeaVar[]): CompletionItem[] {
    return fields.map(field => {
        return {
            label: field.name,
            kind: CompletionItemKind.Field,
            detail: field.toString()
        };
    });
}
/**
 * 创建智能补全消息
 * @param labels 标签表
 * @param kind 类型
 * @returns 
 */
function createCompletionItems(labels: string[], kind: CompletionItemKind): CompletionItem[] {
    return labels.map(label => {
        return {
            label: label,
            kind: kind
        };
    });
}

// ----------------------------------------------------------------
export {
    teaBuildinTypes,
    teaBuildinTypesCompletion,
    teaBuildinKeywordCompletion,
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

    TeaBuildinContextDeclare
};