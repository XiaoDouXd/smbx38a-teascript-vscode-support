# TeaScript 语法定义 (`tea-grammar-pattern.ts`)

`server/src/syntaxes/tea-grammar-pattern.ts` 把 SMBX TeaScript 的语法以 [元语法引擎](./meta-grammar.md) 提供的声明式 DSL 表达出来，并挂载用于 IntelliSense 的回调。

## 一、整体结构

`teaGrammarPattern` 是一个 `LanguageGrammar`，主要由四块组成：

```ts
const teaGrammarPattern: LanguageGrammar = {
    explicitScopeExtreme: false,                  // 作用域允许隐式端点
    stringDelimiter: ["\""],
    pairMatch: [["(", ")"], ["[", "]"], ["{", "}"], ["\"", "\""]],
    ignore:  { patterns: ["/'[.]*/"] },           // 行注释 '...' 整行忽略
    onMatchedInit: (match) => { match.state = new TeaGlobalContext(); },

    patterns: [ /* 全局模板 */ ],
    patternRepository: { /* 各种命名模板 */ },
    scopeRepository:   { /* 各种命名作用域 */ }
};
```

`onMatchedInit` 在每次完整匹配开始时会创建一个新的 `TeaGlobalContext`，挂在顶层 `match.state` 上——它就是后续被各 `onMatched` 回调填充的"符号表根"。

## 二、全局入口

```ts
patterns: [{
    name: "Global", id: "global",
    patterns: [
        // 表达式 / 跳转
        "<expression>", "<func-call-prefix>", "<goto-call>",
        // 声明 / 定义
        "<var-declare>", "<func-definition>", "<goto-flag>",
        // 逻辑结构
        "<if-structure>", "<for-loop>", "<dow-loop>",
        "<do-loop-w>", "<do-loop>", "<with-structure>", "<select-structure>"
    ]
}]
```

每一行对应一类顶层语句。需要注意 **顺序很重要**：`OptionalPatternSet` 取首个命中的分支，所以更具体的模板应排在更宽泛的模板之前（比如 `func-call-val` 排在 `func-call` 之前）。

## 三、关键模板（`patternRepository`）

以下按"功能簇"分组阐述。

### 1. 变量声明 `var-declare`

```text
Dim <name> [, <name> ...] As <type> [= <expression>]
```

- `onMatched`：取出 `name` 与 `type`，向**当前作用域 context** 添加一条 `TeaVar`，并记录其声明位置（`pos = endOffset`），以便后续补全过滤"使用早于声明"的变量。
- `onCompletion`：返回内建类型补全（`teaBuiltinTypesCompletion`），让用户输入 `As` 后能选类型。

### 2. 表达式 `expression` / `expression-un-strict`

两套基本一致，区别在于 `strict` 标志：

```text
<expr-unit> [<operator> <expr-unit> ...]

expr-unit  = [<unary-operator> ...] <unit> [<postfix>]
unit       = <func-call-val> | <func-call> | <var> | <number>
            | <string>     | <dot-op>     | <bracket>
operator   = 一大串运算符 + Or/And/Mod 等关键字（正则）
```

- `onCompletion = onExpressionCompletion`：根据具体子模板返回不同补全：
  - 命中 `expr-unit` 且 text 为 `.` → 列出当前 context 中带 `dotFlag` 的成员；
  - 命中 `operator` 且以 `.` 结尾 → 取出 `.` 前的对象，沿匹配树拿到其 `TeaType`，列出成员；
  - 命中处于"输入到一半"的状态 → 通过 `getObjectType` 推断对象类型并列字段。

### 3. 函数定义 `func-definition`

```text
[Export] Script <name>([<func-params-declare>][, <func-params-declare>...][, Return <type>]) {block} End Script
[Export] Script <name>(Return <type>) {block} End Script
```

- `crossLine: true`：可跨行匹配。
- `onMatched`：
  1. 用 `name`、`type` 创建 `TeaFunc` 并加入全局 context；
  2. 如果以 `Export` 开头，记录到 `exportFunc: Map<uri, TeaFunc[]>`，供其它文件做跨文件补全；
  3. 创建一个新的 `TeaContext` 作为函数体上下文，并把它通过 `setFunctionContext` 与函数关联；
  4. 把函数对象挂到 `match.state`，以便嵌套的 `func-params-declare` 能找到它。
- `onCompletion`：当光标处在 `type` 子项时，返回内建类型补全。

### 4. 函数调用 `func-call` / `func-call-val` / `func-call-prefix`

| 模板 | 用于 |
| --- | --- |
| `func-call` | 普通函数调用 `name(<expression> [, ...])` |
| `func-call-val` | 内建的 `Val(...)` / `GVal(...)` / `Array(...)` 这一类**取值/数组**调用 |
| `func-call-prefix` | `Call name(...)` 形式（VBScript 风格） |

`func-call-val` 还会把 `Val(...)` 中的标识符记录到 `globalValue: Map<uri, string[]>` —— 这是 SMBX 中"全局变量"的常见声明方式，记录后会作为 `Field` 补全提供给所有文档。

`func-call` 和 `func-call-prefix` 都注册了 `onHover`：在文档全局 context 里查找该函数的 `TeaFunc`，把 `func.toString()` 直接作为悬停提示返回。

### 5. 点操作 `dot-op`

```text
.<field>
field = <identifier> | <func-call>
```

`onHover` 在当前作用域中查 `TeaVar` 并展示其描述。注意它与 `expression` 的 `onCompletion` 协作完成"成员补全"。

### 6. 流程控制

| 模板 | 模式串 |
| --- | --- |
| `if-structure` | `If <cond> Then [{block}] [ElseIf <cond> Then [{block}] ...] [Else [{block}]] End If` |
| `for-loop` | `For <cond> To <cond> [Step <cond>] [{block}] Next` |
| `dow-loop` | `Do /(While|Until)/ <cond> [{block}] Loop` |
| `do-loop-w` | `Do [{block}] Loop /(While|Until)/ <cond>` |
| `do-loop` | `Do [{block}] Loop` |
| `with-structure` | `With <var-open> {with-block} End With` |
| `select-structure` | `Select Case <cond> [{block}] [Case <cond> [{block}] ...] [Case Else [{block}]] End Select` |

`with-structure` 比较特别：它会通过 `var-open` 的回调先把成员补全显示出来；进入 `with-block` 后，还会把 `With` 对象的所有字段（带 `dotFlag = true`）注入子上下文，让后续 `.字段` 自动可见。

### 7. goto 与 var

- `goto-call` / `goto-flag` 仅做语法识别，未实现"跳转目标解析"（源码注释了 `// ToDo`）。
- `var` 模板是个简单的 identifier 包装，并通过 `ignore: /(Do|do|Loop|loop|Else|else)/` 排除关键字误识。

## 四、关键作用域（`scopeRepository`）

### `block`

- `begin: [""]`，即"无显式开始"；
- `end` 列表枚举所有可能的结束词（`Next`、`End If`、`Loop`、`End Script`、`Case` 等）。
- 内部 `patterns` 列出 block 内允许出现的语句类型。
- `onMatched`：
  - 如果父匹配的 `state` 是 `TeaFunc`，则当前 block 的 context 就是 `func.functionContext`；
  - 否则新建 `TeaContext` 并挂到外层 context 上。
- `onCompletion`：根据光标位置决定是否屏蔽关键字、是否展示导出函数。

### `with-block`

与 `block` 相似，但额外做了"展开 `With` 对象成员"的处理：在 `onMatched` 中根据 `var-open` 推断类型，把所有 `members` 当作可见变量加入子 context，并把它们标记为 `dotFlag = true`，使其只在 `.` 之后出现。

## 五、IntelliSense 状态机

文件顶部维护了三个标志：

```ts
let isInDim          = false; // 当前是否处于 Dim 声明语境
let isInBlock        = false; // 当前是否在 block 作用域内
let isShowExportedFunc = true; // 是否展示其它文档的 Export 函数
```

通过 `GrammarMatchResult.initCallback` 在每次补全开始前重置；`completionPostProcessing` 则在匹配树遍历完成后做最终合并：

```ts
GrammarMatchResult.completionPostProcessing = (items, params) => {
    if (items.length <= 0) {
        items = items.concat(teaBuiltinKeywordCompletion(params));
        if (isShowExportedFunc) /* 合并其它文档 exportFunc */;
        return items;
    }
    if (isInDim && !isInBlock) return teaBuiltinKeywordCompletion(params);
    if (isShowExportedFunc) /* 合并其它文档 exportFunc */;
    return items;
};
```

> 这个全局可变状态是引擎里**最容易出 Bug 的地方**：补全是同步触发的，所以理论上单线程下没竞争，但任何新加的 `onCompletion` 都需要小心维护这些标志。

## 六、回调常用 API

模板回调里反复用到以下几个 helper：

```ts
match.matchedScope.state as TeaContext;        // 当前作用域的符号表
match.matchedPattern?.state as TeaFunc;        // 当前匹配模板挂的语义对象（如函数）
getMatchedProps(match, "name");                // 取命名子项文本
context.getVariable(name) / getFunc(name)      // 从符号表查询
```

## 七、扩展指南

如果想新增一个语法构造，例如 `Try ... Catch ... End Try`，建议步骤：

1. 在 `patternRepository` 中新增声明，写出模板字符串；
2. 在 `block` 作用域的 `patterns` 数组里 `includePattern("try-structure")`；
3. 在 `patterns: [...]` 顶层数组中也 include（如果允许出现在文件顶层）；
4. 视需要在 `scopeRepository` 里加新的子作用域；
5. 加 `onMatched` / `onCompletion` 提供 IntelliSense；
6. 在 `syntaxes/smbxtea.tmLanguage.json` 同步关键字以获得高亮。
