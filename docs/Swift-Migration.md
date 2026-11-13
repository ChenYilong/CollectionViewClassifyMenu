# Swift migration of the core

The core library (the CocoaPods pod's sources: `CollectionViewClassifyMenu/Class/**/*.{h,m}` and
`TagCollectionView/TagCollectionView/{CYLTagView,Model/*,Views/*}.{h,m}`) is translated from Objective-C to Swift.

## Task log

- **Status:** in progress (started 2026-11-13, branch `feat/android-kotlin`). Requirements 1 and 2 done: the
  standard is `docs/Swift-Coding-Standard.md` (AGENTS.md, `docs/instructions.md` and `.agents/skills/cyl-swift/`
  point to it), and three Swift skills are installed (below). Requirement 3 (the translation) runs module by module.
- **Scope:** iOS only, mainly the core code of this project. Third-party libraries are out of scope. Change the
  example code only when necessary.
- **Requirements:**
  1. Write a Swift coding standard document first (`docs/Swift-Coding-Standard.md`), and update the instructions
     (`AGENTS.md`, `docs/instructions.md`) and skills (`.agents/skills/cyl-swift/` and the related skills) with it.
  2. If ready-made Swift skills exist online, copy and install them into this project (`.agents/skills/`, with source
     and license recorded).
  3. Following the standard and the Swift skills, translate all core code to Swift.
  4. Record the translation progress in this document.
  5. Done means no Objective-C code is left in the project's core. Code that cannot be translated to Swift but is made
     Swift-compatible with macros / keywords (`NS_SWIFT_NAME`, `NS_REFINED_FOR_SWIFT` and so on) also counts as
     translated.
  6. Score: no Objective-C code left is full marks. Score after every commit, check after every commit whether it is
     full marks, and continue until full marks.
- **Prompt (verbatim):**

  > 将下面的任务找一个合适的文档，标注 TODO：全英文写入：注意本操作仅仅设计iOS端，重点修改 本项目的Core核心层面代码。 不涉及第三方库，首先创建swift编码规范文档，更新instructions和skills相关文档。如果网络有现成的swift skills请直接复制安装到本项目中，按照swift编码规范以及swift相关skilla，将Core 核心层面代码全部转录为Swift代码，如果无必要不要修改example层代码。在该文档中记录swift翻译进度。以项目中不存在objc代码为准，如果无法翻译为swift以宏定义 关键字形式 进行兼容swift的也可以算作翻译成功。不存在objc代码为满分，每提交一次就打一次分。每提交一次检查是否满分。一直到满分为止。

- **Prompt (English):** find a suitable document and log this as a TODO, in English. This concerns iOS only and mainly
  the core code of this project, not third-party libraries. First create a Swift coding standard document and update
  the instructions and skills documents. If ready-made Swift skills exist online, copy and install them into this
  project. Following the Swift coding standard and the Swift skills, translate all core code to Swift; do not change
  the example code unless necessary. Record the translation progress in this document. The measure is that no
  Objective-C code exists in the project; code that cannot be translated but is made Swift-compatible through macros
  or keywords also counts as translated. No Objective-C code left is full marks. Score after every commit, check for
  full marks after every commit, and continue until full marks.

## Rule (2026-11-13): core quality first, examples last

- **Rule:** when the migration causes compile errors or test failures in an example, change the example's code first.
  Every example has the lowest weight; where an example needs no change, no compatibility is considered, and example
  code may be changed freely so that the core's code carries no baggage. Never lower the quality of the core's Swift
  code because of how an example uses it; the Swift coding standard decides (`docs/Swift-Coding-Standard.md`
  section 1, which replaced "compatibility first"). Recorded in AGENTS.md, `docs/instructions.md` and
  `.agents/skills/cyl-swift/`.
- **Consequence:** the API check becomes a report: an API change the standard asks for (idiomatic names, `T?` / `T`
  instead of `T!`, Swift collections and value types) is allowed, listed under "Swift API changes" below, with the
  baseline refreshed. The files migrated in step 2 kept the Objective-C shapes (`T!`, `NSMutableArray`, factory
  methods); they are cleaned up to the standard in a later step (TODO).
- **Status:** rule recorded (2026-11-13); applied from step 3 on.
- **Prompt (verbatim):**

  > 在文档中找到objc迁移swift相关文档，包含docs instructions skils 相关文档。全英文更新，追加规则：更新example 编译错误，规则为优先改example层代码，所有example权重为最低，无须example修改的考虑兼容性。任意修改example代码，全力保障core核心层代码没有包袱，负担。不要因为example层的用法而降低core swif代码质量。以swift编码规范为准。

- **Prompt (English):** find the Objective-C to Swift migration documents (docs, instructions, skills) and update them
  in English with an added rule: for example compile errors, change the example code first; all examples have the
  lowest weight; where an example needs no change, do not consider compatibility. Change example code as needed and
  make every effort to keep the core free of baggage and burden. Do not lower the quality of the core's Swift code
  because of how an example uses it; the Swift coding standard decides.

## Swift API changes

API changes the standard asks for (rule above). Each is reported by `scripts/swift-api-check.sh`, and the examples
and the core's tests are updated in the same commit.

| Step | Declaration | Change | Reason |
| --- | --- | --- | --- |

## Score

Score = (1 − Objective-C files left in the core / 76) × 100. Baseline: 76 Objective-C files (`.h` + `.m`, 11,592
lines) in the pod's source patterns.

| Date | Commit | Objective-C files left | Score |
| --- | --- | --- | --- |
| 2026-11-12 | baseline | 76 | 0 |
| 2026-11-13 | step 2 (the six roots and `CYLMenuKeys`) | 63 | 17.1 |

## Progress

| Module | Files | Status |
| --- | --- | --- |
| `CollectionViewClassifyMenu/Class` | 66 | in progress: 55 left (step 2: the roots) |
| `TagCollectionView/TagCollectionView` | 10 | in progress: 8 left (`CYLTagView` done) |

## Swift skills installed (requirement 2)

Copied unmodified into `.agents/skills/`, each with its `LICENSE` and a `SOURCE.md` (repository, path, commit):

| Skill | Source | License | Use |
| --- | --- | --- | --- |
| `swift-api-design-guidelines-skill` | [Erikote04/Swift-API-Design-Guidelines-Agent-Skill](https://github.com/Erikote04/Swift-API-Design-Guidelines-Agent-Skill) `36cdc1b` | MIT | names, labels, comments |
| `migration-patterns` | [rshankras/claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills) `skills/ios/migration-patterns` `f958982` | MIT | `objc-to-swift.md` |
| `swift-concurrency` | [AvdLee/Swift-Concurrency-Agent-Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) `3b1580d` | MIT | `@MainActor`, Sendable |

Not taken: arustydev's `convert-objc-swift` (AGPL-3.0, which would bind this repository's license).

## API check

`scripts/swift-api-check.sh` builds the pod, dumps its API with `swift-api-digester` and compares it with
`scripts/swift-api-baseline.json`, dumped from the Objective-C core on 2026-11-13 (40 classes, 617 functions and
properties; the module map is flattened because the digester skips CocoaPods' per-header submodules). It must report
no breakage after every migration commit.

## Order

Top-down: a file migrates once no Objective-C file left in the core imports it. Swift calls the Objective-C
headers still in the umbrella without any glue, while Objective-C calling Swift would need the generated
`-Swift.h` and `@objc`-only APIs (no macros, no inline functions), so the dependency direction decides the order
(the import graph of 2026-11-13):

1. Roots, imported by no other core file: `NSArray+CYLLog`, `NSDictionary+CYLLog`, `CYLMultipleFilterController`,
   `CYLClassifyMenuViewController`, `CYLImageTagView`, `CYLTagView`.
2. What they alone import: `CYLFilterBaseController`, `CYLCollectionViewCell`, `CYLFilterHeaderView`,
   `CYLImageTagGroupView`, `CYLTagCell`, `CYLTagHeaderCell`, `CYLTagGroup`…
3. Then their dependencies, down to the shared leaves (`CYLMenuResources`, `CYLParameterConfiguration`,
   `CYLMenuDataSource`, `CYLCollectionViewLeftAlignedLayout`), which go last.
4. `CYLTag` and `CYLTagListView` (+ `CYLConfiguration`) import each other: they migrate in one commit.

## Transition files

- `CollectionViewClassifyMenu/Class/CollectionViewClassifyMenu.h`: the generated `CollectionViewClassifyMenu-Swift.h`
  of a mixed module imports `<CollectionViewClassifyMenu/CollectionViewClassifyMenu.h>` as the underlying module's
  umbrella header, but CocoaPods generates `CollectionViewClassifyMenu-umbrella.h`; without this forwarding header
  every client of the pod failed to scan the module (2026-11-13, all four test suites). It goes with the last
  Objective-C header and is not counted in the score.

## Objective-C API changes

- `kDataSourceSectionKey`, `kDataSourceCellTextKey`, `kDataSourceCellPictureKey`: Swift global constants now (the
  Swift API is unchanged), which Objective-C cannot see; Objective-C reads `CYLMenuKeys.dataSourceSectionKey`,
  `.dataSourceCellTextKey` and `.dataSourceCellPictureKey`. The only Objective-C caller was the core's own test
  (`CYLCollectionViewClassifyMenuLayoutTests.m`), updated.
- Private state the core's Objective-C tests read through key-value coding keeps its names and Foundation types as
  `@objc private` members (`CYLClassifyMenuViewController`: `dataSource`, `expandSectionArray`, `collectionView`,
  `firstRowCellCountArray`, `collectionHeaderMoreBtnHideBoolArray`, `rowsCountPerSection`,
  `cellsCountArrayPerRowInSections`; `CYLMultipleFilterController`: `filterParamsTool`).

## API check details

The baseline is the Objective-C core's API. Once the module has Swift, `swift-api-digester` dumps only the Swift
declarations of a mixed module, so the check dumps the two parts separately (a copy of the framework without the Swift
module for the Objective-C part, `-swift-only` for the Swift part), merges them and compares the merged dump with the
baseline (`-input-paths`). Differences that come from dumping Swift instead of Objective-C are filtered: conformances
inherited from UIKit / Foundation (a Swift dump does not repeat them), `@preconcurrency` (added to UIKit subclasses),
Clang's builtin type aliases, and Objective-C names (a Swift-only dump does not record them). The Objective-C names are
checked instead against the generated `CollectionViewClassifyMenu-Swift.h`: every class, protocol and selector of a
migrated type must be there (inherited initializers excepted). Verified on 2026-11-13 by renaming
`reloadMenuData()`: the check reported the Swift rename and the missing `reloadMenuData` selector.

## Steps

| Date | Commit | Files migrated | Objective-C files left | Score | API check | Tests |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-11-13 | `79b521f` | (standard, skills, API check) | 76 | 0 | baseline | baseline run |
| 2026-11-13 | step 2 | the roots: `NSArray+CYLLog`, `NSDictionary+CYLLog`, `CYLMultipleFilterController`, `CYLClassifyMenuViewController` (+ `CYLMenuKeys.h`), `CYLImageTagView`, `CYLTagView` (13 files) | 63 | 17.1 | unchanged | menu 30/30, tag 6/6, swift 19/19, example 79/80 (the baseline's failure) |

Baseline of the test suites (2026-11-13, clean worktree at `79b521f`, before any Swift): menu 30/30, tag 6/6, swift
19/19, example 79/80. The failing example test, `CYLSearchCategoryScenarioTests
testSearchCategoriesUseABottomTabBarAndFillTheSearchBar` (the nested tab bar's frame is zero), fails before the
migration too; it is not caused by it and is tracked separately.

Lessons of step 2, applied from now on:

- A `UIView` / `UIViewController` subclass that declares its own designated initializers loses the inherited `init()`;
  add `public convenience init()` calling `init(frame: .zero)` / `init(nibName: nil, bundle: nil)`, which is what
  Objective-C's `-init` did.
- Objective-C messages to nil were no-ops: views created in `viewDidLoad` are optionals with optional chaining, so a
  property set before the view exists still does nothing instead of crashing.
- Private state and private methods the core's Objective-C tests reach (key-value coding, selectors) keep their names
  as `@objc private` members.
- `pod install` reorders the example projects' `project.pbxproj`; restore them and apply only
  `scripts/swift-migrate-pbxproj.py`.

Helpers: `scripts/swift-api-show.py <Type>` prints a type's API from the baseline (names, types, open, Objective-C
names) to match; `scripts/swift-migrate-pbxproj.py [--project …] <Name>…` turns a migrated file's references in the
projects that list core files into `.swift`.
