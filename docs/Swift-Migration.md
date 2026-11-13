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

## Score

Score = (1 − Objective-C files left in the core / 76) × 100. Baseline: 76 Objective-C files (`.h` + `.m`, 11,592
lines) in the pod's source patterns.

| Date | Commit | Objective-C files left | Score |
| --- | --- | --- | --- |
| 2026-11-12 | baseline | 76 | 0 |

## Progress

| Module | Files | Status |
| --- | --- | --- |
| `CollectionViewClassifyMenu/Class` | 66 | TODO |
| `TagCollectionView/TagCollectionView` | 10 | TODO |

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

Leaves first, so that every Swift file only depends on Swift or on Objective-C headers still in the umbrella:

1. `Other/Category` and `Other/Tool` (logging categories, keys, parameters, resources, data source protocol).
2. `Other/Lib/CYLCollectionViewLeftAlignedLayout`.
3. `ClassifyMenu/View` and `ClassifyMenu/Other`, then `CYLClassifyMenuViewController`.
4. `MultipleFilter` (views, categories, params tool, controllers).
5. `TagCollectionView/TagCollectionView` (models, cells, `CYLTagView`).
6. `ImageTag`.
7. `TagList` (appearance, colors, style, tag, buttons, cells, fold control, `CYLTagListView` and its configuration).
