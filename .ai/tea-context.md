# 上下文与内建符号 (`tea-context.ts` & `tea-builtin-context.ts`)

这两个文件共同实现了"TeaScript 程序在解析期间的符号表"。

- `tea-context.ts`：抽象数据结构（类型 / 变量 / 函数 / 上下文）+ 内建关键字 + 补全 helper；
- `tea-builtin-context.ts`：SMBX 引擎自带的类型、字段、内建函数和变量的**静态数据**。

## 一、核心数据结构

```
TeaType ◄─── name, members[], orderedMember, context
   ▲
   └── TeaArray  (element[] 形式)

TeaVar  ── type, name, context, pos, description, dotFlag
TeaFunc ── type, name, parameters[], functionContext, export, pos, description

TeaContext ── upper, contexts[], variables[], global
   ▲
   └── TeaGlobalContext ── declaredTypes[], functions[]
                          + 静态 smbxBuiltinVar / smbxBuiltinType / smbxBuiltinFunc
```

### `TeaType`

- `members: TeaVar[]` 表示该类型上的字段；
- `orderedMember = true` 时补全列表会按声明顺序展示（用 `sortText` = `1000+idx` 实现）；
- `getMember(name)` 用 `linq` 在 members 中查询。

### `TeaArray`

`name = "<element>[]"` 的特殊 `TeaType`，元素类型懒查询 (`elementType` getter)。

### `TeaVar`

- `pos: number` 记录变量声明的偏移，用于"使用早于声明则不补全"的判断；
- `dotFlag: bool`：标记"必须以 `.` 前缀出现"，例如 `With` 块展开后的成员；
- `toString()` 输出形如 `description: name As Type`，直接被悬停 / 补全 detail 使用。

### `TeaFunc`

- `parameters: TeaVar[]`；调用 `addParameter` 时如果已经设置了 `functionContext`，会顺手把参数加入函数体上下文；
- `setFunctionContext(context)` 把函数体 context 挂到全局，并把参数注入；
- `toCompletionItem()` 直接产出补全项：`label = func.name`，`insertText = name($1)`，类型 `Function`。

### `TeaContext` / `TeaGlobalContext`

- 链式查找：`getVariable` 先查自身再递归到 `upper`；
- 全局上下文额外维护 `declaredTypes[]` 与 `functions[]`，并在查找 fallback 到 SMBX 内建符号；
- 可注意 **大小写处理**：用户定义的变量是大小写敏感的（`linq.where(name === ...)`），但内建变量/类型/函数是大小写不敏感的（`toLocaleLowerCase()`）。

`TeaGlobalContext.loadBuiltinContext(declare)` 是一次性初始化，幂等（通过 `_builtinLoaded` 保护）。它把 `tea-builtin-context.ts` 的纯数据转换为 `TeaType`/`TeaVar`/`TeaFunc` 实例。

## 二、内建关键字与代码片段

文件中定义了：

```ts
const numTypes   = ["Integer", "Double", "Byte", "Long"];
const txtTypes   = ["String"];
const otherTypes = ["Boolean", "Void"];
const keywords   = ["Then","End","Case","GoTo","GoSub","As","Next","Loop","While",
                    "Step","Continue","Return","Exit","Until","Call","Mod","ReDim"];
```

并提供两类导出：

| 导出 | 作用 |
| --- | --- |
| `teaBuiltinTypesCompletion` | 内建类型补全（`CompletionItemKind.Struct`） |
| `teaBuiltinKeywordCompletion(pos)` | 关键字 + 一系列**结构化代码片段** |

`keywordComplex` 给出多条 `CompletionItemKind.Snippet`，覆盖：

- `If / ElseIf / Else`（带 `Then` 与 `End If`）
- `Script / Export`（自动生成函数骨架）
- `Dim ... As ...`
- `Select ... End Select`
- `Do / For / With ... End With`
- `GVal / Val / Array`（光标定位到括号内）

> 这是**真正给用户使用的代码片段**——`snippets/smbxtea.json` 是空的，所以片段全部由服务端动态推送。

## 三、跨文件共享

```ts
const exportFunc:  Map<string, TeaFunc[]> = new Map();
const globalValue: Map<string, string[]>  = new Map();
```

- `exportFunc[uri]` 存某个文档中的 `Export Script`；
- `globalValue[uri]` 存某个文档中通过 `Val(...)` / `GVal(...)` 出现的全局变量名。

服务端在文档关闭时会清理：

```ts
documents.onDidClose(e => {
    exportFunc.delete(e.document.uri);
    globalValue.delete(e.document.uri);
    ...
});
```

补全合并发生在 `tea-grammar-pattern.ts` 的 `completionPostProcessing` 里：从所有 **其它** uri 的 `exportFunc` 收集 `CompletionItem`，让你在 A 文件能看到 B 文件 `Export` 的函数。

## 四、内建数据 (`tea-builtin-context.ts`)

文件结构：

```ts
const teaBuiltinContext: TeaBuiltinContextDeclare = {
    types: [
        { name: "-bgo-return-",   field: [...] },
        { name: "-bgp-return-",   field: [...] },
        { name: "-bitmap-return-",field: [...] },
        { name: "-block-return-", field: [...] },
        { name: "-char-return-",  field: [...] },
        ...
    ],
    vars:  [ ... ],
    funcs: [ ... ]
};
```

### 类型命名约定

`-xxx-return-` 形式表示"某个内建函数返回的隐式结构体"。例如 `-bgo-return-` 描述背景对象的字段：`x`、`y`、`xsp`、`ysp`、`forecolor`、`id`、`permid` 等等。每个字段都带：

```ts
{ name: "x", type: "Double", description: "背景的横向坐标" }
```

- 这些字段最终在补全列表中以 `CompletionItemKind.Field` 出现，detail 是 `description: name As type`，便于显示中文注释。

### 字段类型

字段 `type` 都是字符串，加载时如果在 builtin types 中找到则复用；找不到则现场用 `TeaType(t)` 构造一个新类型。这意味着**字段的类型不一定立刻指向真实类型对象**，但只要后续 `getType(name)` 能补回去就够用。

### 加载流程

`TeaGlobalContext.loadBuiltinContext()` 用单层 Map 缓存以便复用类型实例：

```text
对每个 declare.types[i]:
    new TeaType(name, [TeaVar(field.type, field.name) ...])
    缓存到 tyMap

对每个 declare.funcs[i]:
    根据 type 找/建 TeaType
    new TeaFunc(type, name)
    对每个 param: addParameter，并把参数名前后加 "-" (如 -idx-)
        (这种命名方式让参数不会与用户变量冲突，仅用于 toString 展示)

对每个 declare.vars[i]:
    new TeaVar(type, name)
```

加载完成后，`TeaGlobalContext.smbxBuiltinFunc/Var/Type` 即可被 `getFunc/getVariable/getType` 在 fallback 时查到。

## 五、辅助函数

```ts
createCompletionItemsForVar(varList, startOffset)        // 仅返回 pos <= startOffset 且 dotFlag=false 的变量
createCompletionItemsForFunc(funcList, startOffset)      // 用户函数 + builtin 函数
createCompletionItemsForMembers(fields)                  // 列出某类型的字段
createCompletionItems(labels, kind)                      // 通用 helper
```

## 六、扩展点

- **新增内建函数/变量**：直接编辑 `tea-builtin-context.ts` 的 `vars/funcs/types`，重新构建即可（无需改引擎）。
- **新增关键字**：编辑 `tea-context.ts` 中的 `keywords` 数组；如要改造 snippet，编辑 `keywordComplex`。
- **新增类型字段**：在对应 `-xxx-return-` 的 `field` 中添加条目。
- **大小写策略调整**：当前用户定义符号是大小写敏感的，如需统一不敏感，需要修改 `TeaContext.getVariable / getType / getFunc` 的对比方式。
