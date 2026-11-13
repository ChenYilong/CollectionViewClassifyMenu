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
| 3 | `CYLCollectionViewCell.button`, `CYLFilterHeaderView.titleButton` / `.moreButton` | `T!` → `let … : T` | always present; read-only |
| 3 | `CYLCollectionViewCell.section` / `.row` | `UInt` → `Int` | Swift uses `Int` for indexes |
| 3 | `CYLTagCell.model`, `CYLTagHeaderCell.group` | `T!` → `T?` | nil before configuration |
| 3 | `CYLFilterBaseController.delegate`, `CYLFilterHeaderView.delegate`, `CYLTagHeaderCell.delegate` | `T!` → `T?` | weak references |
| 3 | `CYLFilterControllerDelegate`, `CYLFilterHeaderViewDelegate`, `CYLTagHeaderCellDelegate` | `@objc` protocols → Swift `AnyObject` protocols; `filterControllerDidComplete(_:)` required | only Swift adopts them |
| 3 | `filterHeaderViewDidTapMoreButton(_: Any!)` | → `filterHeaderView(_:didTapMoreButton:)` | names the sender and the button |
| 3 | `headerViewDidTapNameView(_:index:)` | → `tagHeaderCell(_:didToggleGroupInSection:)` | says what happened |
| 3 | `CYLFilterBaseController.show(in:)`, `confirmButtonClicked(_:)`, `restoreButtonClicked(_:)` | `UIView!` → `UIView`, `Any!` → `Any?` | nullability |
| 3 | `kCollectionViewToTopMargin` / `Left` / `Right` / `Bottomt` (globals) | → `CYLFilterBaseController.sectionInset` | one value, no globals, typo gone |
| 3 | `CYLFilterHeaderViewHeigt` (global) | → `CYLFilterHeaderView.defaultHeight` | typo, no globals |
| 3 | `CYLFilterBaseController.itemButtonClicked(_:)`, `.dataSource`, `.settingArray`; `CYLFilterHeaderView.moreButtonTapped(_:)` | removed | unused (an empty hook, never-read storage, a private action) |
| 3 | `init()` of `CYLCollectionViewCell`, `CYLFilterHeaderView`, `CYLTagCell`, `CYLTagHeaderCell` | removed | collection views create them with `init(frame:)` / nibs |
| 4 | `CYLImageTagDirection` | `NS_ENUM` → Swift `enum: Int, CaseIterable` (same cases and raw values) | Swift-only type |
| 4 | `CYLImageTagDirectionNext(_:)` (global function) | → `CYLImageTagDirection.next` | a property of the enum |
| 4 | `CYLImageTag`, `CYLImageTagGroup` | `NSObject` + `NSCopying` → Swift `final class`, `copy()` returns the type; `init(title:direction:link:userInfo:)` | no Objective-C users; typed copies |
| 4 | `CYLImageTagGroup.defaultDirections(forTagCount:)` | `UInt` → `Int`, `[NSNumber]` → `[CYLImageTagDirection]` | typed result |
| 4 | `CYLImageTagGroupDefault…`, `CYLImageTagGroupMaximumTagCount` (globals) | → `CYLImageTagGroupView.defaultCircleRadius` … `.maximumTagCount` (`Int`) | no globals |
| 4 | `CYLImageTagGroupKey…` strings and `animateValue(forKey:values:duration:completion:)` | → `CYLImageTagGroupView.AnimatableValue` and `animate(_:values:duration:completion:)` with `[CGFloat]`; `value(of:)` | typed keys, no key-value coding |
| 4 | `CYLImageTagItem`, data source, delegate | `@objc` protocols → Swift protocols (`CYLImageTagItem: UIView`); the delegate's methods have empty defaults; `numberOfTags(in:)`, `groupView(_:viewForTagAt:)` | Swift-only; guidelines |
| 4 | `isDraggable`, `isGroupHidden`, `tagViews`, `setPercentPosition(x:y:)` | Objective-C accessors dropped; `setPercentX(_:percentY:)` → `setPercentPosition(x:y:)` | guidelines |
| 4 | the dot's long-press accessibility action | shown while there is a delegate (it was: while the delegate implemented `groupViewDidLongPress:`, which `CYLImageTagView` always does) | Swift protocols with defaults cannot be asked which methods they implement |
| 4 | `CYLImageTagView` handlers, `groupConfiguration`, `removeTagGroup(at:)` | `UInt` → `Int`; `@objc` removed | Swift indexes; no Objective-C users |
| 5 | `CYLFilterParamsTool`, `kMultipleFilterSetting`, `kMultipleFilterSettingModified` | removed; `CYLMultipleFilterController` keeps `[[String]]` titles and `[[Bool]]` selection privately | legacy `NSCoding` storage and a Documents file name nothing used; the core's test checks `selectedIndexPaths()` instead |
| 5 | `UIButton.cyl_generalStyle()` / `cyl_homeStyle()` / `cyl_redStyle()` / `cyl_chengNiStyle()` | → `cylApply(_: CYLCollectionCellButtonStyle)` (`.general`, `.home`, `.red`, `.chengNi`) and `UIButton.cylImage(filledWith:)` | one method with a style; Swift names without underscores |
| 5 | `UIImage.cyl_blurredImage(withRadius:iterations:tintColor:)` | → `cylBlurred(radius:iterations:tintColor:)`, non-optional result, `Int` iterations | Swift names; returns the image itself when it cannot blur |
| 5 | `CYLTagGroup.itemArr` (`[Any]!`), `.width` / `.height` (`Float`), `.groupName` (`String!`), `firstRowCellCount(forContentWidth:)` (`UInt`), `.cellsCountArrayPerRowInSections` | → `items: [CYLTagModel]`, `CGFloat`, `String`, `Int`, `cellCountsPerRow: [Int]`; Objective-C names kept for the component's tests; `invalidateRowCounts()` added | typed, idiomatic |
| 5 | `CYLTagGroup.firstRowCount` | removed | computed once and never read |
| 5 | `kTagCollectionViewCellsHorizonMargin` and the four `kTagCollectionViewTo…Margin` globals | → `CYLTagView.cellSpacing`, `CYLTagView.sectionInset` | no globals, typo gone |
| 5 | `CYLFilterCollectionCell.titleButton` | `T!` → `let … : T` | always present |
| 5 | `init()` of `CYLFilterCollectionCell`, `CYLMultipleFilterHeaderView`, `CYLRightImageButton`; `CYLRightImageButton.init(type:)` | removed | created with `init(frame:)` / nibs |
| 6 | `CYLIndexPathButton.cyl_imageTitleSpacing` / `.cyl_titleLeadingInset` | → `imageTitleSpacing` / `titleLeadingInset` (Objective-C names `cyl_…` kept for the core's tests) | Swift names without underscores |
| 6 | `UIView (CYLGeneral)`: 21 frame, border, layer, target and capture helpers and the `LINE_COLOR…` macros | removed from the API; the three the core uses are internal (`cylAddLineLayer(frame:color:)`, `cylAddTapTarget(_:action:)`, `cylSnapshot(width:)`); frames are set directly | unused public API; plain UIKit is clearer |
| 6 | `CYLTagModel` | `+modelWithTitle:` → `init(title:)` (non-failable; Objective-C `-initWithTitle:`); `title: String`; `width` / `height`: `Float` → `CGFloat` (`@objc dynamic`, so subclasses can override the getters); `titleFont(for:)` / `updateSize(for:)` take `UITraitCollection?` | typed, idiomatic |
| 7 | `CYLTagListView` | `UInt` counts and indexes → `Int` (`defaultVisibleRows`, `maximumNumberOfRows`, `numberOfRows(inSection:)`, `insertTag(_:at:)`, `removeTag(at:)`…); `style`, `titleStyle`, `foldControl`: `T!` → `T` (setting copies; no `nil` reset); `init(fold:content:)` → `init(foldPosition:content:)`; `init(foldControl:title:titleImage:titlePosition:)` with defaults replaces the two-title variants; `defaultTitleStyle()` → class property `defaultTitleStyle`; `setTags(withTitles:colors:)` has `colors: = []`; `configuration(withContentsOfFile:)` → `configuration(contentsOfFile:)`. Objective-C names kept for the core's test: `-initWithFoldControl:`, `title`, `defaultVisibleRows`, `menuDataSource`, `-reloadMenuData`, `titleView`; KVC `collectionView` (tests' `CYLTagListProbe`) | Swift integers, non-optional values, labels |
| 7 | `CYLTag` | a final Swift class (not `NSObject`, typed `copy()`); one `init(identifier: = 0, title:, backgroundColor: = nil)` and `init(identifier: = 0, title:, backgroundColorHex:)` replace six initializers; `textSize`, `cornerRadius`, `borderWidth`, `deleteIndicatorSize`: `CGFloat?` (`nil` = the list's value) replace the sentinel `CYLTagUseListValue` (removed); `colors` non-optional; `badgeImage(withText:color:diameter:)` → `badgeImage(text:color:diameter:)`; `style(withBaseStyle:)` → `style(basedOn:)` | optionals instead of a sentinel, default arguments |
| 7 | `CYLTagDataSource` | `UInt` indexes → `Int`; `init(tags: = [])`; `baseStyle: CYLMenuStyle` (not `T!`) | Swift integers |
| 7 | configuration keys (90 `CYLTagListView…`, `CYLTagSection…`, `CYLTagItem…`, `CYLMenuStyle…`, `CYLTagAppearance…`, `CYLMenuFoldControlKey…` globals) | namespaced: `CYLTagListKey.sections`, `CYLTagSectionKey.items`, `CYLTagItemKey.title`, `CYLMenuStyleKey.normal`, `CYLTagAppearanceKey.cornerRadius`, `CYLMenuFoldControlKey.position`… (same string values) | no global constants; discoverable by type |
| 7 | `CYLMenuColorFromString()`, `CYLMenuAnimationURLWithOptions()` | → `UIColor.cylMenuColor(from:)`, `URL.cylAddingAnimationOptions(_:)` (non-optional URL; `[:]` returns the URL) | extensions instead of global functions |
| 7 | `CYLMenuConfigurationError` | an `NS_ERROR_ENUM` → a Swift `struct` (`CustomNSError`, `LocalizedError`) with the same domain `CYLMenuConfigurationErrorDomain`, `Code` raw values and a `message` | Swift error |
| 7 | accessibility identifiers (`CYLTagListTitleAccessibilityIdentifier`…, 6 globals) | `CYLTagListAccessibilityIdentifier.title`, `.foldControl`, `.item`, `.createItem`, `.moreButton`, `.deleteButton` (same strings); the core's Objective-C test compares the strings | namespaced constants |
| 7 | `CYLTagListCell`, `CYLTagCreateCell`, `CYLTagFoldCell`, `CYLTagFoldButton` | `deletable` → `isDeletable`; `configure(withTitle:…selected:enabled:)` → `configure(title:…isSelected:isEnabled:)`; `additionalAccessibilityActions: [UIAccessibilityCustomAction]` (not optional); `plusImage()` → `plusImage`; `style(with:)` → `outlinedStyle(from:)`; `configure(withName:style:enabled:)` → `configure(name:style:isEnabled:)`; `CYLTagFoldCell.configure(with:…)` → `configure(foldControl:…)`; KVC `button` / `foldButton` kept `@objc` | Swift names |
| 7 | `CYLMenuStyle (CYLConfiguration)`, `CYLMenuFoldControl (CYLConfiguration)`, `CYLTagAppearance (CYLConfiguration)` | Swift extensions; `CYLMenuFoldControl(configuration:)` is a failable `init?(configuration: Any)` (a `CYLMenuFoldControl` is assigned directly instead) | extensions |
| 8 | `CYLMenuFoldControlPosition` | cases renamed (`docs/component-architecture.md`): `.bottom` → `.footer`, `.topTrailing` → `.headerTrailing`, `.topLeading` → `.headerLeading`, `.inline` → `.tail` (Objective-C `CYLMenuFoldControlPositionFooter`…; Kotlin `FOOTER`, `HEADER_TRAILING`, `HEADER_LEADING`, `TAIL`, `NONE`); configuration strings `"footer"`, `"headerTrailing"` (`"headerRight"`), `"headerLeading"` (`"headerLeft"`), `"tail"`, the old strings dropped | names of the collection view's parts; leading / trailing hold in right-to-left layouts |
| 8 | `CYLMenuFoldControl` | `+foldControlWithPosition:content:` / `+noFoldControl` → `init(position: = .none, content: = .icon)` (Objective-C `-initWithPosition:content:`, used by the core's test); `title`, `collapseTitle`, `image`: `T!` → `T` (the defaults are returned until a value is set) | one initializer with defaults |

Examples updated in step 4: `Example/CYLMenuExample/CYLImageTagSample.swift` (typed default directions, `Int` group
index) and its tests (`direction.next`, `value(of: .linesProgress)`).

Examples updated in step 3: the demo app's `CYLFilterDemoViewController` (`filterControllerDidComplete(_:)` takes a
non-optional controller; the bar button calls `initLeftBarButtonItem()` instead of the delegate method with nil).

## Score

Score = (1 − Objective-C files left in the core / 76) × 100. Baseline: 76 Objective-C files (`.h` + `.m`, 11,592
lines) in the pod's source patterns.

| Date | Commit | Objective-C files left | Score |
| --- | --- | --- | --- |
| 2026-11-12 | baseline | 76 | 0 |
| 2026-11-13 | step 2 (the six roots and `CYLMenuKeys`) | 63 | 17.1 |
| 2026-11-13 | step 3 (cells, headers, filter base; idiomatic API) | 53 | 30.3 |
| 2026-11-13 | step 4 (`CYLImageTagGroupView`) | 51 | 32.9 |
| 2026-11-13 | step 5 (filter views, styles, blur, `CYLTagGroup`) | 37 | 51.3 |
| 2026-11-13 | step 6 (`CYLIndexPathButton`, `UIView+CYLGeneral`, `CYLTagModel`) | 31 | 59.2 |
| 2026-11-14 | step 7 (`CYLTag`, `CYLTagListView` + configuration, the tag cells and fold button, accessibility identifiers) | 16 | 78.9 |
| 2026-11-14 | step 8 (`CYLMenuFoldControl`, with the fold position rename) | 14 | 81.6 |

## Progress

| Module | Files | Status |
| --- | --- | --- |
| `CollectionViewClassifyMenu/Class` | 66 | in progress: 14 left (steps 2–8): `CYLMenuStyle`, `CYLTagAppearance`, `CYLTagColors`, `CYLTagButton`, the shared tools |
| `TagCollectionView/TagCollectionView` | 10 | DONE (step 6): 0 left |

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
4. `CYLTag` and `CYLTagListView` (+ `CYLConfiguration`) import each other: they migrate in one commit (step 7, with
   the cells and the accessibility header they alone import).

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

| 2026-11-13 | step 3 | `CYLCollectionViewCell`, `CYLFilterHeaderView`, `CYLFilterBaseController`, `CYLTagCell`, `CYLTagHeaderCell` (10 files), first step under "core quality first" | 53 | 30.3 | changes listed in "Swift API changes", baseline refreshed | menu 30/30, tag 6/6, swift 19/19, example 79/80 (the baseline's failure) |

| 2026-11-13 | step 4 | `CYLImageTagGroupView` (2 files, 1,152 lines) | 51 | 32.9 | changes listed in "Swift API changes", baseline refreshed | menu 30/30, tag 6/6, swift 19/19, example 79/80 (the baseline's failure) |

| 2026-11-13 | step 5 | `CYLRightImageButton`, `UIButton+CYLCollectionCellStyle`, `CYLFilterCollectionCell`, `CYLMultipleFilterHeaderView`, `UIImage+CYLBlur`, `CYLFilterParamsTool` (removed), `CYLTagGroup` (14 files) | 37 | 51.3 | changes listed in "Swift API changes", baseline refreshed | menu 30/30, tag 6/6, swift 19/19, example 79/80 (the baseline's failure) |

| 2026-11-13 | step 6 | `CYLIndexPathButton`, `UIView+CYLGeneral`, `CYLTagModel` (6 files) | 31 | 59.2 | changes listed in "Swift API changes", baseline refreshed | menu 30/30, tag 6/6, swift 19/19, example 79/80 (the baseline's failure) |

| 2026-11-14 | step 7 | `CYLTag`, `CYLTagListView`, `CYLTagListView+CYLConfiguration`, `CYLTagListCell`, `CYLTagCreateCell`, `CYLTagFoldCell`, `CYLTagFoldButton`, `CYLTagListAccessibility` (15 files, 4,770 lines of Objective-C) | 16 | 78.9 | changes listed in "Swift API changes", baseline refreshed | menu 30/30, tag 6/6, swift 19/19, example 80/80 |

| 2026-11-14 | step 8 | `CYLMenuFoldControl` (2 files) and the fold position rename on iOS and Android | 14 | 81.6 | changes listed in "Swift API changes", baseline refreshed | menu 30/30, tag 6/6, swift 19/19, example 80/80; Android library tests and example build pass |

Step 7 notes: the first swift run failed 2 title tests: Swift does not run a property's `didSet` when an initializer
of the declaring class sets it, so `init(foldControl:title:…)` never updated the title view; it now sets the properties
through a method. The tests ran on the iPhone 17 Pro simulator of iOS 27.0 (`scripts/simulator-id.sh` now also takes a
simulator ID): `xcodebuild` of Xcode 27.2 rejects the iOS 27.2 runtime's simulators as destinations, and the tests need
to run outside the command sandbox (the test runner's socket). The example suite's former failure
(`CYLSearchCategoryScenarioTests`) passes now. the fold position rename (`footer`, `headerLeading`, `headerTrailing`, `tail`,
`docs/component-architecture.md`) moves to step 8 with `CYLMenuFoldControl`, which defines the enum. The core's
Objective-C test compares the accessibility identifiers as strings (`"CYLTagListItem"`, `"CYLTagListFoldControl"`):
the Swift constants are not visible to Objective-C. Examples updated: the configuration keys and helpers (12 files),
`removeTag(at:)` with an `Int` (`CYLTagContainerSample`), `defaultTitleStyle`, `configuration(contentsOfFile:)`,
`style(basedOn:)`, `badgeImage(text:…)`, `cylAddingAnimationOptions(_:)`.

Step 6 moved one core test to Swift: Objective-C cannot subclass a Swift class, and
`testRowCalculationIsLinearAndInvalidatedWhenItemsChange` counts a tag's width reads through a subclass of
`CYLTagModel`; it is now `TagCollectionView/TagCollectionViewTests/CYLTagGroupRowTests.swift` (the other tag tests stay
in Objective-C).

Step 5's first test run stalled: another session tested CYLTabBarController on the same simulator at the same time; the
stuck run of this repository was stopped and the suites run again.

Note on `1e1df5a` (a docs commit): it also took the staged deletion of `CYLImageTagGroupView.h/.m` without the
Swift file, so that one commit does not build; step 4's commit, right after it, does. Published history is not
rewritten.

Examples updated in step 5: the demo app's Filter tab no longer migrates selections archived by versions before the
user-defaults storage (`CYLFilterParamsTool` archives); its test checks the validation of stored selections instead.

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
