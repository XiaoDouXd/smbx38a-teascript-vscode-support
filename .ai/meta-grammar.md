# 元语法引擎 (`meta-grammar.ts`)

`server/src/syntaxes/meta-grammar.ts` 实现了一个自研的、**字符串模板驱动**的语法匹配引擎。整个 TeaScript 的智能感知，都建立在这个引擎之上。

> 阅读本文前，建议先大致浏览 `meta-grammar.ts`，本文聚焦讲解"概念"和"流程"。

## 一、核心概念

### 1. 语法声明（声明式 DSL）

最外层暴露 4 个声明类，使用者只需要"填表"：

| 类 | 作用 |
| --- | --- |
| `LanguageGrammar` | 一种语言的总入口：包含全局 `patterns`、`patternRepository`、`scopeRepository` 等 |
| `GrammarPatternDeclare` | 一条具体的语法模板（pattern） |
| `GrammarScopeDeclare` | 一个具有 begin/end 边界的"作用域"（scope） |
| `GlobalScopeDeclare` | 全局作用域，编译时由引擎自动构造 |

`GrammarPatternDeclare` 中可以挂 4 类回调：

```ts
onMatched?     // 模板被成功匹配时，可在 match.state 上挂语义对象
onCompletion?  // 在该模板节点上请求补全时
onHover?       // 在该模板节点上请求悬停时
onDiagnostic?  // 诊断（当前未启用）
```

### 2. 模板字符串语法

`GrammarPatternDeclare.patterns` 是一个字符串数组，引擎通过解析这些字符串构造模板。共有 4 种括号：

| 语法 | 含义 |
| --- | --- |
| `<name>` | 引用一个**已声明的模板**（局部 `dictionary` 优先于全局 `patternRepository`），还有内建 `<string>`、`<number>`、`<identifier>`、`< >` |
| `[ ... ]` | 可选片段，结尾加 `...` 表示**可重复** |
| `{ name }` | 引用一个**作用域**（来自 `scopes` 或 `scopeRepository`） |
| `/regex/` | 行内正则 |

例：

```ts
"Dim <name> [, <name> ...] As <type> [= <expression>]"
"If <cond> Then [{block}] [ElseIf <cond> Then [{block}] ...] [Else [{block}]] End If"
```

字符串中的空格起到"分词"的作用。`pattern.keepSpace = true` 时还会显式保留空格模板。

### 3. 模板原子（`PatternItem`）

引擎把声明编译为如下层级的原子类：

```
PatternItem (abstract)
├── EmptyPattern         空白匹配
├── RegExpPattern        正则匹配
│   ├── TextPattern      字面量（自动转义）
│   ├── StringPattern    "..." 字符串
│   ├── NumberPattern    数字
│   └── IdentifierPattern 标识符
├── AllPattern           "总是匹配"占位
├── NamedPattern         为子模板命名
└── OrderedPatternSet    依序组（按顺序匹配子模板）
    ├── OptionalPatternSet  可选组（任意一个匹配即可）
    ├── ScopePattern        作用域（带 begin/end 的特殊依序组）
    │   └── Grammar         整个语言（顶层 scope）
```

每个 `PatternItem` 实现统一接口：

```ts
abstract match(doc: TextDocument, startOffset: number): MatchResult;
```

返回的是 `MatchResult`（或其子类），形成"匹配结果树"。

### 4. 匹配结果树

| 类 | 含义 |
| --- | --- |
| `MatchResult` | 基类，记录起止偏移、匹配文本、父子节点、`state`（自由附加的语义对象） |
| `PatternMatchResult` | 模板匹配结果，可通过 `getMatch(name)` 取出命名子项 |
| `ScopeMatchResult` | 作用域匹配结果，记录 `beginMatch` / `endMatch` |
| `GrammarMatchResult` | 顶层匹配结果，承载补全/悬停的对外 API：`requestCompletion` / `requestHover` |
| `UnMatchedText` | 一段无法匹配的"碎文本"，但仍然挂在树上（用于增量补全的兜底） |
| `UnMatchedPattern` | "尝试过该模板但所有分支都失败"的兜底节点 |

`UnMatched*` 的存在是为了：**在用户尚未输入完整代码时**，仍然能从最近的失败匹配中推断出"用户可能想写什么"，从而提供合理补全。

## 二、编译过程：声明 → PatternItem 树

入口：

```ts
function compileGrammar(grammarDeclare: LanguageGrammar): Grammar
```

主要环节：

1. 遍历 `grammarDeclare.patterns`，对每条 `GrammarPatternDeclare` 调用 `compilePattern`。
2. `compilePattern` 把模板字符串数组打包为一个 `OptionalPatternSet`（任一分支命中即可）。
3. 对每条字符串调用 `analyzePatternItem`：
   - 状态机扫描字符串：在 `CollectWords`（普通文本）和 `MatchBracket`（括号内）之间切换；
   - 文本部分变成 `TextPattern`；
   - 括号部分递归调用 `analyzeBracketItem`，分别落到 `<name>`/`[...]`/`{name}`/`/re/` 四个分支；
   - 子模板按顺序串到 `OrderedPatternSet`。
4. 作用域 (`{name}`) 经 `compileScope` 处理，先编译 `begin`、再依次编译内部 `patterns`、最后编译 `end`，组成 `ScopePattern`。

> 整个过程中存在大量的递归嵌套，引擎依靠 `pattern.compiledPattern` 做"已编译缓存 + 防止递归爆栈"。

## 三、匹配过程：PatternItem 树 → MatchResult 树

入口：

```ts
function matchGrammar(grammar: Grammar, doc: TextDocument): GrammarMatchResult
```

`Grammar.match()` 的主循环大致如下：

```text
while (offset != end) {
  for sub in subPatterns:
      r = sub.match(doc, offset)
      if r.matched:
          add r as child, advance offset, break
  if 没有任何 subPattern 命中:
      记录为 UnMatchedText, 跳到下一行继续
  cleanSpace()
}
match.processSubMatches()
```

不同 `PatternItem` 在 `match()` 里实现了各自的策略：

- `OrderedPatternSet`：严格依序，对中途失败可选择"忽略可忽略段"或"立刻失败"。
- `OptionalPatternSet`：尝试每个分支，第一个命中的胜出；全部失败则返回 `UnMatchedPattern`，便于 IntelliSense 兜底。
- `ScopePattern`：先匹配 `begin`，循环匹配内部 patterns 直到匹配到 `end`；遇到无法匹配的内容，按 `skipMode` (`line` 或 `space`) 跳过。
- `Grammar`：顶层 scope，跳过空白（含注释 `//` `/* */`）后整体推进。

匹配完成后，`processSubMatches()` 会**回填父子链 + 触发 `onMatched` 回调**，把语义信息（如变量声明、函数签名）写入 `MatchResult.state`。

## 四、补全/悬停的查询流程

`GrammarMatchResult.requestCompletion(pos)`：

1. 用 `locateMatchAtPosition(pos)` 找到光标所在的最深节点 `match`；
2. 根据 `match` 的具体类型（`UnMatchedPattern` / `UnMatchedText` / `Scope` / `Grammar`）调用对应的 `onCompletion`；
3. **沿父链向上回溯**，依次询问 `matchedPattern` / `matchedScope` 的 `onCompletion`；
4. 在外层包装 `completionPostProcessing`：合并内建类型、关键字、其它文档导出的 `Export Script`，最后用 `linq.distinct(label)` 去重。

`GrammarMatchResult.requestHover(pos)` 与之类似，但只走父链找到第一个有 `onHover` 的节点即可。

两个布尔标志贯穿其中：

- `GrammarMatchResult.disable`：补全短路开关（某些回调希望"完全禁用补全"）。
- `GrammarMatchResult.shieldKeywordCompletion`：屏蔽内建关键字补全（例如点操作 `.` 后只列字段，不应列出 `If/For` 等）。

## 五、关键工具函数

```ts
includePattern(name)  // 生成 { patterns: [`<${name}>`] }，用于在 scope.patterns 中复用
namedPattern(name)    // 同上，但语义偏向"命名引用"
getMatchedProps(match, name, defaultValue)  // 从 PatternMatchResult / UnMatchedPattern 中按命名取出文本
```

## 六、设计上的细节与坑点

1. **大小写敏感**：`pattern.caseInsensitive` 默认 `true`，但匹配时仍是逐字对比 + 正则 `/i`。`tea-builtin-context.ts` 注释也提到"为不同大小写多写几遍"。
2. **隐式/显式作用域端点**：`LanguageGrammar.explicitScopeExtreme = false` 表示语言中作用域可以"无显式开始符号"（例如 `block` 作用域只看 end 列表）。
3. **`UnMatched*` 是 IntelliSense 的关键**：完整的代码大多能匹配，但用户**输入到一半时**几乎一定走 `UnMatchedPattern` 分支——因此回调里做兜底很重要。
4. **`linq` 依赖**：服务端引入了 `linq`，匹配树筛选大量使用 `linq.from(...).where(...)`，可读性不错但带来运行时开销。
5. **错误处理**：很多匹配方法直接 `try / catch (ex) console.error`，任何异常都不会把整个 LSP 打挂，但也容易吞错。

## 七、对外导出

```ts
export {
    LanguageGrammar,
    GrammarPatternDeclare,
    GrammarScopeDeclare,
    MatchResult,
    PatternMatchResult,
    ScopeMatchResult,
    UnMatchedPattern,
    GrammarMatchResult,

    includePattern,
    namedPattern,
    compileGrammar,
    matchGrammar,
    getMatchedProps
};
```

调用方（即 `tea-grammar-pattern.ts` 与 `server.ts`）只需关心**声明类 + 编译/匹配函数 + 取属性的 helper**。
