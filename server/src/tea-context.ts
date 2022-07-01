// ================================================================
// 设计描述 smbx teascript 上下文信息的数据结构
// ================================================================

import linq from "linq";
import { type } from "os";
import { CompletionItem, CompletionItemKind } from "vscode-languageserver";

// ---------------------------------------------------------------- 一些类型的枚举
const numTypes = ["Integer", "Double", "Byte", "Long"];
const txtTypes = ["String", "Char"];
const otherTypes = ["Boolean", "Void"];
const keywords = [
    "If", "Else", "ElseIf", "End", "Select", 
    "Case", "With", "Export", "Script", "GoTo", 
    "GoSub"
];

/** 连接函数: 用于生成类型总表 */
function concat<T>(list: T[][]):T[]
{
    let result: T[] = [];
    list.forEach(subList => result = result.concat(subList));
    return result;
}
const teaBuildinTypes = numTypes.concat(txtTypes, otherTypes);
const teaBuildinTypesCompletion: CompletionItem[]
    = teaBuildinTypes.map( type => {
        return {
            label: type,
            kind: CompletionItemKind.Struct
        };
    });
const teaBuildinKeywordCompletion: CompletionItem[]
    = keywords.map( word => {
        return {
            label: word,
            kind: CompletionItemKind.Keyword
        };
    });

// ---------------------------------------------------------------- 语法结构描述
/** 上下文描述类 */
class TeaContext{
    /** 上一层(父)上下文 */
    upper: TeaContext;
    /** 下一层(子)上下文 */
    contexts: TeaContext[] = [];
    /** 上下文中的变量 */
    variables: TeaVar[] = [];
    
    /**
     * 添加子上下文
     * @param context 待添加的子上下文
     */
    addContext(context: TeaContext)
    {
        this.contexts.push(context);
        context.upper = this;
    }
    /**
     * 添加变量
     * @param variable 待添加的变量
     */
    addVariable(variable: TeaVar)
    {
        this.variables.push(variable);
        variable.context = this;
    }
    /**
     * 获取变量
     * @param name 变量名
     * @returns 变量描述类
     */
    getVariable(name: string): TeaVar
    {
        const v = linq.from(this.variables).where(variable => variable.name === name).firstOrDefault();
        if (!v)
        {
            return this.upper ? this.upper.getVariable(name) : null;
        }
        return v;
    }
    /**
     * 获取类型
     * @param name 类型名
     * @returns 类型描述类
     */
    getType(name: string): TeaType
    {
        const reg = /(Integer|Double|Byte|Long)/;
        const match = reg.exec(name);
        if (match)
        {
            return new TeaType(match[1]);
        }
        else if (teaBuildinTypes.indexOf(name) >= 0)
            return new TeaType(name);
        
        const t = linq.from(teaGlobalContext.declaredTypes).where(t => t.name === name).firstOrDefault();
        return t ? t : new TeaType(`${name}?`);
    }
    /**
     * 获取所有变量
     * @returns 一个{变量名, 变量描述类}字典
     */
    protected internalGetAllVariables(): Map<string, TeaVar>
    {
        let varMap = new Map<string, TeaVar>();
        if (this.upper)
            varMap = this.upper.internalGetAllVariables();
        for (let i = 0; i < this.variables.length; i++)
        {
            varMap.set(this.variables[i].name, this.variables[i]);
        }
        return varMap;
    }
    /**
     * 获取所有变量
     * @returns 变量描述类组
     */
    getAllVariables(): TeaVar[]
    {
        const varMap = this.internalGetAllVariables();
        const varList: TeaVar[] = [];
        for (const v of varMap.values()) {
            varList.push(v);
        }
        return varList;
    }
}
/** 全局上下文描述类 */
class TeaGlobalContext extends TeaContext
{
    /** 变量声明 */
    declaredTypes: TeaType[] = [];
    /** 函数声明 */
    functions: TeaFunc[] = [];

    constructor()
    {
        super();
        this.upper = null;
        this.declaredTypes = teaBuildinTypes.map(t => new TeaType(t));
    }
    /**
     * 添加子上下文
     * @param context 待添加的上下文
     */
    addContext(context: TeaContext)
    {
        super.addContext(context);
    }
    /**
     * 添加类型
     * @param type 类型描述类
     */
    addCustomType(type: TeaType)
    {
        this.declaredTypes.push(type);
    }
    /**
     * 添加函数
     * @param func 函数描述类
     */
    addFunction(func: TeaFunc)
    {
        this.functions.push(func);
    }
}
/** 脚本上下文 */
const teaGlobalContext = new TeaGlobalContext();
/** SMBX 全局上下文 */
const smbxGlobalContext = new TeaGlobalContext();
/** 内建函数 */
class BuildinFunc{
    
}
/** 内建变量 */
class BuildinVar{

}
/** 初始化全局上下文 */
function initSMBXGlobalContext(funcs: BuildinFunc, vars: BuildinVar)
{
    // 初始化
}

/** 类型描述 */
class TeaType{
    /** 类型名 */
    name: string;
    /** 成员名 */
    members: TeaVar[];
    /** 是否有序 */
    orderedMenber = false;

    /**
     * @param name 类型名
     * @param members 所有成员变量
     */
    constructor(name: string, members: TeaVar[] = [])
    {
        this.name = name;
        this.members = members;
    }

    /** 
     * 添加成员
     * @param value 成员变量
     */
    addMember(value: TeaVar)
    {
        value.context = null;
        this.members.push(value);
    }
    /** 
     * 获取成员
     * @param name 成员名
     */
    getMember(name: string): TeaVar
    {
        return linq.from(this.members)
            .where(member => member.name === name)
            .firstOrDefault();
    }
}
/** 数组类型描述 */
class TeaArray extends TeaType
{
    elementTypeName: string;
    get elementType() { return teaGlobalContext.getType(this.elementTypeName); }
    constructor(element: string)
    {
        super(`${element}[]`);
        this.elementTypeName = element;
    }
}
/** 变量描述 */
class TeaVar{
    /** 变量类型 */
    type: TeaType;
    /** 变量名 */
    name: string;
    /** 变量所属上下文 */
    context: TeaContext;

    /**
     * @param type 变量类型
     * @param name 变量名
     */
    constructor(type: TeaType, name: string)
    {
        this.type = type;
        this.name = name;
    }
    toString()
    {
        return `Dim ${this.name} As ${this.type.name}`;
    }
}
/** 函数描述 */
class TeaFunc{
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

    /**
     * @param type 返回类型
     * @param name 函数名
     * @param params 参数列表
     */
    constructor(type: TeaType, name: string, params: TeaVar[] = [])
    {
        this.type = type;
        this.name = name;
        this.parameters = params;
    }
    /**
     * 添加参数
     * @param param 变量描述类
     */
    addParameter(param: TeaVar)
    {
        this.parameters.push(param);
        if (this.functionContext)
            this.functionContext.addVariable(param);
    }
    /**
     * 设置函数覆盖的上下文
     * @param context 上下文描述类
     */
    setFunctionContext(context: TeaContext)
    {
        this.functionContext = context;
        teaGlobalContext.addContext(context);
        this.parameters.forEach(param => context.addVariable(param));
    }
    toString()
    {
        return `${this.export == false ? "" : "Export"} Script ${this.name}(${this.parameters.map(param => param.toString()).join(", ")} ${type.name === "Void" ? "" : `, Return ${type.name}`})`;
    }
}

// ---------------------------------------------------------------- 分析和封装方法
/**
 * 为变量列表创建智能补全消息
 * @param varList 变量列表
 * @returns 
 */
function createCompletionItemsForVar(varList: TeaVar[]): CompletionItem[]
{
    return varList.map(v =>
    {
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
function createCompletionItemsForFunc(funcList: TeaFunc[]): CompletionItem[]
{
    return funcList.map(func =>
    {
        return {
            label: func.name,
            kind: CompletionItemKind.Function,
            detail: func.toString()
        };
    });
}
/**
 * 为成员变量创建智能补全消息
 * @param fields 成员
 * @returns 
 */
function createCompletionItemsForMembers(fields: TeaVar[]): CompletionItem[]
{
    return fields.map(field =>
    {
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
function createCompletionItems(labels: string[], kind: CompletionItemKind): CompletionItem[]
{
    return labels.map(label =>
    {
        return {
            label: label,
            kind: kind
        };
    });
}

// ----------------------------------------------------------------
export
{
    teaBuildinTypes,
    teaBuildinTypesCompletion,
    teaBuildinKeywordCompletion,
    teaGlobalContext,
    TeaType,
    TeaVar,
    TeaContext,
    TeaFunc,
    TeaArray,
    createCompletionItemsForVar,
    createCompletionItemsForFunc,
    createCompletionItemsForMembers,
    createCompletionItems,
};