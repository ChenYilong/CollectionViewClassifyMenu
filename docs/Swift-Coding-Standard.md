# Swift 编码规范 / Swift coding standard

| 中文 | English |
|:---|:---|
| 本项目中 Swift 代码的规则：核心库在从 Objective-C 迁移到 Swift 期间及之后（`docs/Swift-Migration.md`）、示例以及测试。官方规则优先：[Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) 以及 Apple 关于 Swift / Objective-C 互操作的文档。本文档只记录本项目在这些规则之间所做的选择。 | The rules for Swift code in this project: the core library while and after it moves from Objective-C to Swift (`docs/Swift-Migration.md`), the examples and the tests. Official rules come first: the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) and Apple's documentation for Swift / Objective-C interoperability. This document only records this project's choices among them. |
| 适用的 skill（位于 `.agents/skills/`）： | Skills that apply (in `.agents/skills/`): |
| `swift-api-design-guidelines-skill`：命名、参数标签、文档注释（Swift API Design Guidelines）。 | `swift-api-design-guidelines-skill`: naming, argument labels, documentation comments (Swift API Design Guidelines). |
| `migration-patterns`（`objc-to-swift.md`）：Objective-C 惯用法到 Swift 的映射、渐进式迁移、`@objc`。 | `migration-patterns` (`objc-to-swift.md`): mapping Objective-C idioms to Swift, incremental migration, `@objc`. |
| `swift-concurrency`：actor、`@MainActor`、`Sendable`、Swift 6 语言模式。 | `swift-concurrency`: actors, `@MainActor`, `Sendable`, the Swift 6 language mode. |
| `cyl-swift`：本项目面向 Swift 的名称（`NS_SWIFT_NAME`、`cyl_` 方法）以及如何检查导入的名称。 | `cyl-swift`: this project's Swift-facing names (`NS_SWIFT_NAME`, `cyl_` methods) and how to check imported names. |
| `cyl-comments`：文档注释格式。 | `cyl-comments`: the documentation comment format. |

## 1. 核心库质量优先，示例适配 / 1. Core quality first; the examples adapt

| 中文 | English |
|:---|:---|
| **优先级（2026-11-13 的规则，取代“兼容优先”）：** 核心库的 Swift 代码遵循本规范和 Swift API Design Guidelines，不为示例保留任何负担。示例在项目所有代码中权重最低。 | **Priority (rule of 2026-11-13, replaces "compatibility first"):** the Swift code of the core follows this standard and the Swift API Design Guidelines, with no burden kept for the examples. The examples have the lowest weight of all code in the project. |
| 1. **迁移破坏了示例时，修改示例。** 示例（`Example/`、`Example-Swift/`、演示应用、`TagCollectionView` 示例及其测试）中的编译错误或测试失败，优先在示例代码中修复。核心库绝不因为某个示例在使用，就保留旧名称、隐式解包可选类型、Objective-C 风格的签名、`NSArray` / `NSDictionary` 类型、工厂方法或任何其他结构。 | 1. **When the migration breaks an example, change the example.** A compile error or a test failure in an example (`Example/`, `Example-Swift/`, the demo app, the `TagCollectionView` demo, their tests) is fixed in the example's code first. The core never keeps an old name, an implicitly unwrapped optional, an Objective-C-style signature, an `NSArray` / `NSDictionary` type, a factory method or any other construct only because an example uses it. |
| 2. **不为示例做兼容工作。** 示例无需改动时，不为兼容添加任何东西；需要改动时，就改示例。绝不为迁就示例的用法而降低核心库 Swift 代码的质量。 | 2. **No compatibility work for the examples.** Where an example needs no change, nothing is added for compatibility; where it does, the example changes. Never lower the quality of the core's Swift code to fit an example's usage. |
| 3. **Swift API 可以为变得地道而改变。** 名称、参数标签、可选性（用 `T?` / `T` 代替导入的 `T!`）、值类型和 Swift 集合都遵循指南。`scripts/swift-api-check.sh` 会对照 `scripts/swift-api-baseline.json` 报告每一处变更；变更被接受的条件是：本规范要求它、已列入 `docs/Swift-Migration.md`（“Swift API changes”），并且在同一次提交中刷新基线（`--baseline`）。规范没有要求的变更就是 bug。 | 3. **The Swift API may change to become idiomatic.** Names, argument labels, optionality (`T?` / `T` instead of the imported `T!`), value types and Swift collections follow the guidelines. `scripts/swift-api-check.sh` reports every change against `scripts/swift-api-baseline.json`; a change is accepted when this standard asks for it, listed in `docs/Swift-Migration.md` ("Swift API changes"), and the baseline is refreshed (`--baseline`) in the same commit. A change the standard does not ask for is a bug. |
| 4. **Objective-C 名称**（`@objc(CYLName)`、`@objc(selector:)`）仅在核心库自身的 Objective-C 测试、XIB 的 `customClass` 条目、selector 或键值编码需要时保留；除此之外，不会仅为兼容而向 Objective-C 暴露任何东西。核心库自身的测试不属于示例：要保持其通过，并随 API 一起更新。 | 4. **Objective-C names** (`@objc(CYLName)`, `@objc(selector:)`) are kept where the core's own Objective-C tests, XIB `customClass` entries, selectors or key-value coding need them; nothing else is exposed to Objective-C only for compatibility. The core's own tests are not examples: keep them passing, and update them with the API. |
| 5. **类型保留 `CYL` 前缀**（Objective-C 没有命名空间，且目前导入的 Swift 名称都带有该前缀）。仅限 Swift 的辅助类型（`private` / `fileprivate` / `internal`）不需要前缀。 | 5. **Types keep the `CYL` prefix** (Objective-C has no namespaces, and the Swift names imported so far have it). Swift-only helpers (`private` / `fileprivate` / `internal`) do not need the prefix. |
| 6. **Category 改为 extension**；核心库中仍被 Objective-C 代码调用的成员保留其 `cyl_` Objective-C 名称（`@objc(cyl_setWidth:)`）。Swift 名称遵循 Swift API Design Guidelines（下划线规则见 `cyl-swift`）。 | 6. **Categories become extensions**; a member that Objective-C code of the core still calls keeps its `cyl_` Objective-C name (`@objc(cyl_setWidth:)`). Swift names follow the Swift API Design Guidelines (`cyl-swift` for the underscore rule). |
| 7. **`NS_TYPED_ENUM` 字符串常量** 改为 `struct … : RawRepresentable, Hashable`（或 `extension NSNotification.Name` 形式），成员用 `static let`，Objective-C 用到的全局常量加 `@objc`。`NS_ENUM` 改为 `@objc public enum …: Int`，原始值不变；`NS_OPTIONS` 改为 `OptionSet`（Objective-C 需要时加上 `@objc` 访问）。`NS_ERROR_ENUM` 保留其错误域和错误码。 | 7. **`NS_TYPED_ENUM` string constants** become `struct … : RawRepresentable, Hashable` (or the `extension NSNotification.Name` form) with `static let` members, and `@objc` global constants where Objective-C used them. `NS_ENUM` becomes `@objc public enum …: Int` with the same raw values; `NS_OPTIONS` becomes an `OptionSet` (plus `@objc` access where Objective-C needs it). `NS_ERROR_ENUM` keeps its error domain and codes. |
| 8. **初始化方法：** Objective-C 的指定初始化方法变为指定 `init`；作为初始化方法导入的工厂方法仍是初始化方法（`convenience init`）；`NS_UNAVAILABLE` 变为 `@available(*, unavailable)`。 | 8. **Initializers:** an Objective-C designated initializer becomes a designated `init`; a factory method imported as an initializer stays one (`convenience init`); `NS_UNAVAILABLE` becomes `@available(*, unavailable)`. |
| 9. **Nib 和 storyboard 名称、无障碍标识符、本地化键和资源名称保持不变**（测试和 XIB 依赖它们）。由 XIB 创建的类保留 `@objc(CYLName)`，使 XIB 的 `customClass` 仍能解析（编辑 XIB 时还要设置 `customModule`）。 | 9. **Nib and storyboard names, accessibility identifiers, localization keys and resource names stay unchanged** (tests and XIBs depend on them). A class created from a XIB keeps `@objc(CYLName)` so the XIB's `customClass` still resolves (also set `customModule` when the XIB is edited). |

## 2. 文件与结构 / 2. Files and structure

| 中文 | English |
|:---|:---|
| 每个文件一个公开类型，以类型命名（`CYLTagButton.swift`）；其他类型的 extension 放在 `Type+Topic.swift`（`UIView+CYLGeneral.swift`）。注意文件系统不区分大小写（仅大小写不同的名称会覆盖已有文件）。 | One public type per file, named after the type (`CYLTagButton.swift`); extensions of another type in `Type+Topic.swift` (`UIView+CYLGeneral.swift`). Mind the case-insensitive file system (a name differing only in case overwrites a file). |
| 类型内部的顺序：嵌套类型、公开属性、初始化方法、公开方法、重写、私有辅助方法。用 `// MARK: - Topic` 分组。协议遵循放在 extension 中（`extension CYLTagListView: UICollectionViewDataSource`）。 | Order inside a type: nested types, public properties, initializers, public methods, overrides, private helpers. Group with `// MARK: - Topic`. Protocol conformances in extensions (`extension CYLTagListView: UICollectionViewDataSource`). |
| 文件整体迁移：删除 `.h` 和 `.m` 与添加 `.swift` 文件在同一次提交中完成，且 podspec 的 `source_files` 模式要覆盖 `swift`。 | A file migrates as a whole: the `.h` and `.m` are deleted in the same commit that adds the `.swift` file, and the podspec's `source_files` pattern covers `swift`. |
| 四个空格，每行最多 120 列，成员之间空一行，无行尾空白。 | Four spaces, lines at most 120 columns, one blank line between members, no trailing whitespace. |

## 3. 语言 / 3. Language

| 中文 | English |
|:---|:---|
| **API 的访问控制必须显式：** 应用会继承或重写的类及成员用 `open`（Objective-C 中所有 public 的类都是 `open`，因为 Objective-C 类可以被继承，除非其文档中标明为 final）；API 的其余部分用 `public`；其他一切用 `internal`（隐式）或 `private`。内部类加 `final`。 | **Access control is explicit for the API:** `open` for classes and members that apps subclass or override (every class that was public in Objective-C is `open`, as Objective-C classes could be subclassed, unless it is marked final in its documentation); `public` for the rest of the API; `internal` (implicit) or `private` for everything else. `final` on internal classes. |
| **用可选类型代替可空性：** `nullable` → `T?`，`nonnull` → `T`；没有可空性标注的 Objective-C 属性（导入为 `T!`）要采用其真实类型（总有值时为 `T`，否则为 `T?`），而不是 `T!`。`T!` 仅用于 `@IBOutlet`。除 pod 资源包中随附的资源外，不得强制解包（并附带消息：`guard let … else { preconditionFailure("…") }`）。 | **Optionals instead of nullability:** `nullable` → `T?`, `nonnull` → `T`; an Objective-C property without nullability (imported as `T!`) gets the type it really has (`T` when it always has a value, `T?` otherwise), not `T!`. `T!` only for `@IBOutlet`s. No force unwraps except for resources shipped in the pod's bundle (with a message: `guard let … else { preconditionFailure("…") }`). |
| **Objective-C 仅在内部使用不可变模型的地方用值类型；** Objective-C 调用方使用的公开模型保持为 `NSObject` 类（Objective-C 类有 `NSCopying` 时同样遵循）。 | **Value types where Objective-C used immutable models only internally**; public models that Objective-C callers use stay `NSObject` classes (with `NSCopying` when the Objective-C class had it). |
| **错误：** Objective-C 的 `NSError **` 方法改为 `throws`（导入的 Swift 形式本来就是如此）；错误沿用现有的 `NSError` 错误域和错误码。 | **Errors:** Objective-C `NSError **` methods become `throws` (the imported Swift form already was); errors are the existing `NSError` domain and codes. |
| **集合：** `[T]`、`[K: V]`、`Set<T>`；仅当 Objective-C 调用方需要引用语义或 KVC 时才用 `NSArray` / `NSDictionary`。 | **Collections:** `[T]`, `[K: V]`, `Set<T>`; `NSArray` / `NSDictionary` only where Objective-C callers need the reference semantics or KVC. |
| **闭包** 取代 block；捕获 `self` 的逃逸闭包使用 `[weak self]`。 | **Closures** replace blocks; escaping closures that capture `self` use `[weak self]`. |
| **常量：** 在所属类型中用 `static let`；魔法数字要起名字。 | **Constants:** `static let` in the owning type; magic numbers get a name. |
| **运行时查找** 用于让核心库不产生依赖的场景（CYLTabBarController 的 `CYLTabBarConfigurationParser`，通过 `NSClassFromString` 和 selector 查找），仍保持运行时查找，封装在一个带有文档化 selector 的小类型中。动效引擎不再通过查找获得：`CYLTagButton` 继承 `CYLAnimatedItemView`，只有应用中包含引擎 subspec 时才会播放动效。 | **Runtime lookups** that keep the core free of a dependency (CYLTabBarController's `CYLTabBarConfigurationParser`, found with `NSClassFromString` and selectors) stay runtime lookups, wrapped in one small type with documented selectors. The animation engine is no longer looked up: `CYLTagButton` subclasses `CYLAnimatedItemView`, which plays animations only when an engine subspec is in the app. |
| **不新增依赖。** 核心库链接 UIKit、Accelerate 以及 CYLTabBarController 的 `CYLAnimatedItem` 组件（不含引擎，不含标签栏）。 | **No new dependencies.** The core links UIKit, Accelerate and CYLTabBarController's `CYLAnimatedItem` component (no engine, no tab bar). |

## 4. 并发 / 4. Concurrency

| 中文 | English |
|:---|:---|
| pod 使用 Swift 5 语言模式（`swift_version`），每个面向 UIKit 的类型（UIKit 自身的类已是如此）以及操作视图的函数都加 `@MainActor`。严格并发检查（`complete`）在核心库中必须保持无错误；警告要修复，不得压制。 | Swift 5 language mode for the pod (`swift_version`), with `@MainActor` on every UIKit-facing type (UIKit's own classes already are) and on functions that touch views. Strict concurrency checking (`complete`) must stay free of errors in the core; warnings are fixed, not silenced. |
| 不要用 `DispatchQueue.main.async` 来绕开隔离：应对类型本身做隔离。动效和布局回调保持在主 actor 上。 | No `DispatchQueue.main.async` hops to work around isolation: isolate the type instead. Animation and layout callbacks stay on the main actor. |
| 任何异步内容（`Task`、`async` API、`Sendable` 模型）都遵循 `swift-concurrency`。 | Follow `swift-concurrency` for anything asynchronous (`Task`, `async` APIs, `Sendable` models). |

## 5. 文档注释 / 5. Documentation comments

| 中文 | English |
|:---|:---|
| 每个 `public` / `open` 声明都有块形式的文档注释，三行或更多，位于声明上方（AGENTS.md 的“Code and naming”，`cyl-comments`）： | Every `public` / `open` declaration has a documentation comment in the block form, three lines or more, above the declaration (AGENTS.md "Code and naming", `cyl-comments`): |

  ```swift
  /**
   * What it does, and what callers must know.
   */
  ```

| 中文 | English |
|:---|:---|
| 文字沿用 Objective-C 头文件中的内容，并在 Swift 改变语义处更新（非可选类型不写“`nil`”）。`- Parameter`、`- Returns`、`- Throws` 使用 Swift 的 Markup。`//` 注释仅用于实现说明。 | The text is carried over from the Objective-C header and updated where Swift changes it (no "`nil`" for a non-optional). `- Parameter`, `- Returns`, `- Throws` use Swift's Markup. `//` comments are for implementation notes only. |

## 6. 本地化、资源、无障碍 / 6. Localization, resources, accessibility

| 中文 | English |
|:---|:---|
| 字符串通过 `CYLMenuLocalizedString(_:)` 获取，它读取 `CYLClassifyMenuResources.bundle`；其他地方不使用 `NSLocalizedString`，也不直接读取 bundle（AGENTS.md 的“Internationalization and localization”）。 | Strings through `CYLMenuLocalizedString(_:)`, which reads `CYLClassifyMenuResources.bundle`; no `NSLocalizedString` and no bundle reads elsewhere (AGENTS.md "Internationalization and localization"). |
| 资源与以前一样，从 pod 的资源包加载（`Bundle(for: CYLMenuResources.self)` → `.bundle`）。 | Resources load from the pod's resource bundle (`Bundle(for: CYLMenuResources.self)` → the `.bundle`), as before. |
| 无障碍行为、标签、特征、标识符和 Dynamic Type 与 Objective-C 中完全一致（AGENTS.md 的“Accessibility”）。 | Accessibility behavior, labels, traits, identifiers and Dynamic Type stay exactly as in Objective-C (AGENTS.md "Accessibility"). |

## 7. 每次迁移提交后的验证 / 7. Verification after every migration commit

| 中文 | English |
|:---|:---|
| 1. `scripts/swift-api-check.sh`：报告的每处变更都是本规范要求的，已列入 `docs/Swift-Migration.md`，且基线已刷新；示例已更新为新 API。 | 1. `scripts/swift-api-check.sh`: every reported change is one this standard asks for, listed in `docs/Swift-Migration.md`, with the baseline refreshed; the examples are updated to the new API. |
| 2. `scripts/unit-tests.sh menu`、`tag`、`example` 和 `swift`：所有测试套件通过（核心库的 Objective-C 测试通过 `@import CollectionViewClassifyMenu;` 导入模块）。 | 2. `scripts/unit-tests.sh menu`, `tag`, `example` and `swift`: every suite passes (the core's Objective-C tests import the module with `@import CollectionViewClassifyMenu;`). |
| 3. `scripts/library-warnings.sh`：没有新增警告。 | 3. `scripts/library-warnings.sh`: no new warnings. |

4. `pod lib lint` (`scripts/pod-lint.sh`).
| 中文 | English |
|:---|:---|
| 5. 更新 `docs/Swift-Migration.md` 中的评分和进度表。 | 5. Update the score and the progress table in `docs/Swift-Migration.md`. |
