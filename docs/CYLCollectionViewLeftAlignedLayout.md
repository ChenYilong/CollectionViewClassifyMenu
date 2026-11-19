# CYLCollectionViewLeftAlignedLayout 优化 / CYLCollectionViewLeftAlignedLayout optimization

| 中文 | English |
|:---|:---|
| `CYLCollectionViewLeftAlignedLayout`（`CollectionViewClassifyMenu/Class/Other/Lib/CYLCollectionViewLeftAlignedLayout/`）最初是 [mokagio/UICollectionViewLeftAlignedLayout](https://github.com/mokagio/UICollectionViewLeftAlignedLayout)（MIT）的副本。本页记录已合并进来的上游 PR 和上游的每个 issue，以及对应的修复或检查。Android 移植版（`android/merged/library/.../CYLCollectionViewLeftAlignedLayout.kt`）遵循相同的规则。 | `CYLCollectionViewLeftAlignedLayout` (`CollectionViewClassifyMenu/Class/Other/Lib/CYLCollectionViewLeftAlignedLayout/`) began as a copy of [mokagio/UICollectionViewLeftAlignedLayout](https://github.com/mokagio/UICollectionViewLeftAlignedLayout) (MIT). This page tracks the upstream pull requests merged into it and every upstream issue, with the fix or the check that covers it. The Android port (`android/merged/library/.../CYLCollectionViewLeftAlignedLayout.kt`) follows the same rules. |

## 任务记录 / Task log

| 中文 | English |
|:---|:---|
| **状态：** 已完成（2026-11-12，分支 `feat/android-kotlin`）。25 / 25 行，评分 100。 | **Status:** DONE (2026-11-12, branch `feat/android-kotlin`). 25 / 25 rows, score 100. |
| **背景：** 在将标签列表移植到 Kotlin（`docs/android.md`，第 5 步）时，对该布局进行了重构。用户要求合并四个上游 PR，并处理上游 issue 列表中的每个 issue。 | **Context:** while porting the tag list to Kotlin (`docs/android.md`, step 5), the layout is reworked. The user asked to merge four upstream pull requests and to handle every issue in the upstream issue list. |
| **需求：** | **Requirements:** |
| ↳ 1. 合并 mokagio/UICollectionViewLeftAlignedLayout 的 PR #37、#31、#25 和 #20。 | ↳ 1. Merge PR #37, #31, #25 and #20 of mokagio/UICollectionViewLeftAlignedLayout. |
| ↳ 2. 处理其 issue 列表中的每个 issue。 | ↳ 2. Handle every issue in its issue list. |
| ↳ 3. 在此处跟踪：第 1 列是 issue（描述和链接），第 2 列是待办 / 结果。 | ↳ 3. Track them here: column 1 is the issue (description and link), column 2 the TODO / result. |
| ↳ 4. 评分：每一行都修复即为满分；持续修复直到满分。 | ↳ 4. Score: full marks when every row is fixed; keep fixing until full marks. |
| **提示词（原文）：** | **Prompt (verbatim):** |

  > 在对 CYLCollectionViewLeftAlignedLayout  进行改造的过程中需要 merge以下代码 https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/37  https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/31 https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/25 https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/20/changes 并处理列表里提出了所有issue 加入合适文档的TODO 没有就新建CYLCollectionViewLeftAlignedLayout 优化。将第一列设为issue 描述与地址，第二列为TODO。全部修复完视为满分，修复满分为止

| 中文 | English |
|:---|:---|
| **提示词（英文）：** 重构 CYLCollectionViewLeftAlignedLayout 时，合并 UICollectionViewLeftAlignedLayout 的 PR #37、#31、#25 和 #20，并处理其列表中的每个 issue。把待办加入合适的文档，或创建“CYLCollectionViewLeftAlignedLayout 优化”。第 1 列：issue 的描述和链接；第 2 列：待办。全部修复即为满分；持续修复直到满分。 | **Prompt (English):** while reworking CYLCollectionViewLeftAlignedLayout, merge PR #37, #31, #25 and #20 of UICollectionViewLeftAlignedLayout and handle every issue in its list. Add the TODOs to a suitable document, or create "CYLCollectionViewLeftAlignedLayout optimization". Column 1: the issue's description and link; column 2: the TODO. Everything fixed is full marks; keep fixing until full marks. |

## 评分 / Score

| 中文 | English |
|:---|:---|
| 评分 = 已完成的行数 / 25 行（4 个 PR + 21 个 issue；#6 和 #15 是提问，不计分）× 100。 | Score = rows done / 25 rows (4 pull requests + 21 issues; #6 and #15 are questions, not scored) × 100. |

| 日期 | 已完成 | 评分 |
| --- | --- | --- |
| 2026-11-12 | 0 / 25 | 0 |
| 2026-11-12 | 25 / 25 | 100 |

| Date | Done | Score |
| --- | --- | --- |
| 2026-11-12 | 0 / 25 | 0 |
| 2026-11-12 | 25 / 25 | 100 |

## 验证依据 / Evidence

| 中文 | English |
|:---|:---|
| `scripts/unit-tests.sh menu`：28 个测试，0 个失败，其中包括 `CYLCollectionViewLeftAlignedLayoutTests.m` 和 `CYLLeftAlignedLayoutSwiftTests.swift` 的 10 个。 | `scripts/unit-tests.sh menu`: 28 tests, 0 failures, including the 10 of `CYLCollectionViewLeftAlignedLayoutTests.m` and `CYLLeftAlignedLayoutSwiftTests.swift`. |
| Android：`CYLCollectionViewLeftAlignedLayoutTest`（3 个测试：整行宽度的小数行、尾部边距、2000 个条目），0 个失败。 | Android: `CYLCollectionViewLeftAlignedLayoutTest` (3 tests: full-width fractional rows, trailing inset, 2000 items), 0 failures. |
| `scripts/pod-lint.sh lib`：验证通过。 | `scripts/pod-lint.sh lib`: passed validation. |

## PR 列表 / Pull requests

| 上游 PR | 待办 |
| --- | --- |
| [#37](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/37) 横向滚动：只有布局纵向滚动时，行才左对齐。 | 已完成：横向布局返回流式布局 frame 的副本（`cyl_alignsRows`）。测试：`CYLCollectionViewLeftAlignedLayoutTests` 的 `testHorizontalScrollingKeepsTheFlowLayoutFrames`。 |
| [#31](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/31) 3x 设备上的整行宽度单元格：小数 `y` 使单元格看起来在上一行（`FLT_EPSILON`）。 | 已完成：行通过带容差的垂直中心位置来判断（`CYLFramesShareRow`），而不是依据任何相交。测试：`testFullWidthCellsWithFractionalHeightsStartTheirOwnRows`。 |
| [#25](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/25) iOS 9 崩溃（#9）：仅在 iOS 10+ 上复制属性。 | 已完成：iOS 15+ 始终复制（不需要 iOS 9 分支）。测试：`testSelfSizingCellsAppearAndSettle`、`testReturnedAttributesAreCopies`。 |
| [#20](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/20) 与屏幕等宽的单元格得到错误的 `x`。 | 已完成：frame 被限制在集合视图的分区边距内（而不是屏幕宽度内）。测试：`testFullWidthCellsWithFractionalHeightsStartTheirOwnRows`、`testCellsNeverPassTheTrailingInset`。 |

| Pull request | TODO |
| --- | --- |
| [#37](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/37) Horizontal scrolling: rows are only left-aligned when the layout scrolls vertically. | Done: horizontal layouts return copies of the flow layout's frames (`cyl_alignsRows`). Test: `CYLCollectionViewLeftAlignedLayoutTests` `testHorizontalScrollingKeepsTheFlowLayoutFrames`. |
| [#31](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/31) Full-width cells on 3x devices: fractional `y` makes a cell look like it is on the previous row (`FLT_EPSILON`). | Done: rows are found by vertical centers with a tolerance (`CYLFramesShareRow`), not by any intersection. Test: `testFullWidthCellsWithFractionalHeightsStartTheirOwnRows`. |
| [#25](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/25) iOS 9 crash (#9): copy the attributes only on iOS 10+. | Done: iOS 15+ always copies (the iOS 9 branch is not needed). Test: `testSelfSizingCellsAppearAndSettle`, `testReturnedAttributesAreCopies`. |
| [#20](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/20) A cell as wide as the screen gets a wrong `x`. | Done: frames are clamped inside the section insets of the collection view (not the screen width). Test: `testFullWidthCellsWithFractionalHeightsStartTheirOwnRows`, `testCellsNeverPassTheTrailingInset`. |

## issue 列表 / Issues

| 上游 issue | 待办 |
| --- | --- |
| [#36](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/36) 添加隐私清单。 | 已完成：`CYLClassifyMenuResources` 包中的 `CollectionViewClassifyMenu/Resources/Privacy/PrivacyInfo.xcprivacy`（无跟踪、无数据、无需说明理由的 API；核心库不使用任何此类 API）。测试：`testThePodShipsAPrivacyManifest`；`pod-lint.sh lib` 通过。 |
| [#33](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/33) iOS 11.4：右侧分区边距被忽略。 | 已完成：没有 frame 超过 `width - inset.right`；过宽的条目会被限制。测试：`testCellsNeverPassTheTrailingInset`。 |
| [#32](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/32) 分区标题位置不正确。 | 已完成：页眉和页脚保持流式布局的 frame。测试：`testHeadersAndFootersKeepTheFlowLayoutFrames`。 |
| [#30](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/30) 横向滚动：每个 `x` 都变成 0。 | 已完成：与 PR #37 的修复相同。测试：`testHorizontalScrollingKeepsTheFlowLayoutFrames`（没有 x 为 0）。 |
| [#29](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/29) 2000 个条目：滚动缓慢并因内存退出。 | 已完成：不再递归，每个条目只遍历自己所在的行（`testLargeTagSetDoesNotRecursivelyRecomputePreviousItems`）。测试：`testTwoThousandItemsLayOutQuickly`（2000 个条目加一次完整滚动用时 0.17 秒）。 |
| [#28](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/28) podspec 指向旧版本。 | 已完成：我们的 podspec 从 `s.version` 取 tag，`scripts/pod-lint.sh check-tag <tag>` 会拒绝 tag 不一致的发布。 |
| [#27](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/27) 小数 `y` 的精度问题。 | 已完成：与 PR #31 的修复相同。测试：`testFullWidthCellsWithFractionalHeightsStartTheirOwnRows`。 |
| [#26](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/26) 由整行宽度单元格组成的分区布局错误。 | 已完成：与 PR #31 / #20 的修复相同。测试：`testFullWidthCellsWithFractionalHeightsStartTheirOwnRows`。 |
| [#22](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/22) 分区只有一个条目时，页眉下移（已由提出者关闭）。 | 已完成：只有一个条目的分区，其页眉保持在单元格上方。测试：`testHeadersAndFootersKeepTheFlowLayoutFrames`（分区 1 只有一个条目）。 |
| [#21](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/21) Swift 移植版。 | 已完成：头文件使用 `NS_ASSUME_NONNULL`；Swift 使用非可选类型。测试：`CYLLeftAlignedLayoutSwiftTests.testLayoutIsUsableFromSwift`。 |
| [#18](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/18) `estimatedItemSize`：不显示任何单元格。 | 已完成：自适应尺寸的单元格能够显示。测试：`testSelfSizingCellsAppearAndSettle`。 |
| [#17](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/17) 使用 `preferredLayoutAttributesFittingAttributes:` 时出现递归循环。 | 已完成：自适应尺寸的单元格能够稳定下来（没有循环）。测试：`testSelfSizingCellsAppearAndSettle`。 |
| [#16](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/16) 带分区页脚时崩溃。 | 已完成：矩形查询中的页脚不会崩溃。测试：`testHeadersAndFootersKeepTheFlowLayoutFrames`。 |
| [#13](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/13) 使用 Auto Layout 的单元格尺寸。 | 已完成：单元格采用各自（自适应）的宽度。测试：`testSelfSizingCellsAppearAndSettle`。 |
| [#11](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/11) 使用预估尺寸时读取 `collectionViewContentSize` 崩溃。 | 已完成：在自适应尺寸的单元格下可以读取 `collectionViewContentSize`。测试：`testSelfSizingCellsAppearAndSettle`。 |
| [#10](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/10) 首次滚动时卡顿。 | 已完成：与 #29 相同。测试：`testTwoThousandItemsLayOutQuickly`。 |
| [#9](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/9) 使用 `estimatedItemSize` 时出现 `EXC_BAD_ACCESS`。 | 已完成：与 PR #25 相同。测试：`testSelfSizingCellsAppearAndSettle`。 |
| [#8](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/8) 旋转后两个单元格得到相同的 frame。 | 已完成：没有缓存，宽度变化时布局会失效重算。测试：`testWidthChangeRecomputesEveryFrame`。 |
| [#7](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/7) 横向滚动：单元格重叠。 | 已完成：与 PR #37 相同。测试：`testHorizontalScrollingKeepsTheFlowLayoutFrames`（没有重叠）。 |
| [#4](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/4) “Cached frame mismatch” 警告。 | 已完成：返回的每个属性都是副本。测试：`testReturnedAttributesAreCopies`。 |
| [#2](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/2) 不同尺寸的单元格。 | 已完成：不同宽度和高度的单元格，支持每种行对齐方式。测试：`testCellsOfDifferentSizes`。 |
| [#6](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/6)、[#15](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/15) 提问 / 感谢，无缺陷。 | 无需修复（不计分）。 |

| Issue | TODO |
| --- | --- |
| [#36](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/36) Add a privacy manifest. | Done: `CollectionViewClassifyMenu/Resources/Privacy/PrivacyInfo.xcprivacy` in the `CYLClassifyMenuResources` bundle (no tracking, no data, no required-reason API; the core uses none). Test: `testThePodShipsAPrivacyManifest`; `pod-lint.sh lib` passes. |
| [#33](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/33) iOS 11.4: the right section inset is ignored. | Done: no frame passes `width - inset.right`; too-wide items are clamped. Test: `testCellsNeverPassTheTrailingInset`. |
| [#32](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/32) Section headers not positioned correctly. | Done: headers and footers keep the flow layout's frames. Test: `testHeadersAndFootersKeepTheFlowLayoutFrames`. |
| [#30](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/30) Horizontal scrolling: every `x` becomes 0. | Done: same fix as PR #37. Test: `testHorizontalScrollingKeepsTheFlowLayoutFrames` (no x of 0). |
| [#29](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/29) 2000 items: slow scrolling and memory exit. | Done: no recursion, each item walks only its row (`testLargeTagSetDoesNotRecursivelyRecomputePreviousItems`). Test: `testTwoThousandItemsLayOutQuickly` (0.17 s for 2000 items and a full scroll). |
| [#28](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/28) Podspec points to an old version. | Done: our podspec takes the tag from `s.version`, and `scripts/pod-lint.sh check-tag <tag>` refuses a release whose tag differs. |
| [#27](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/27) Accuracy problem of fractional `y`. | Done: same fix as PR #31. Test: `testFullWidthCellsWithFractionalHeightsStartTheirOwnRows`. |
| [#26](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/26) A section of full-width cells is laid out wrongly. | Done: same fix as PR #31 / #20. Test: `testFullWidthCellsWithFractionalHeightsStartTheirOwnRows`. |
| [#22](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/22) Header moves down when a section has one item (closed by the reporter). | Done: a one-item section's header stays above its cell. Test: `testHeadersAndFootersKeepTheFlowLayoutFrames` (section 1 has one item). |
| [#21](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/21) A Swift port. | Done: the header is `NS_ASSUME_NONNULL`; Swift uses non-optional types. Test: `CYLLeftAlignedLayoutSwiftTests.testLayoutIsUsableFromSwift`. |
| [#18](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/18) `estimatedItemSize`: no cells are shown. | Done: self-sizing cells are shown. Test: `testSelfSizingCellsAppearAndSettle`. |
| [#17](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/17) Recursive loop with `preferredLayoutAttributesFittingAttributes:`. | Done: self-sizing cells settle (no loop). Test: `testSelfSizingCellsAppearAndSettle`. |
| [#16](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/16) Crash with section footers. | Done: footers in a rect query do not crash. Test: `testHeadersAndFootersKeepTheFlowLayoutFrames`. |
| [#13](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/13) Cell sizing with Auto Layout. | Done: cells take their own (self-sized) widths. Test: `testSelfSizingCellsAppearAndSettle`. |
| [#11](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/11) Crash reading `collectionViewContentSize` with estimated sizes. | Done: `collectionViewContentSize` is read with self-sizing cells. Test: `testSelfSizingCellsAppearAndSettle`. |
| [#10](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/10) Stutters on the first scroll. | Done: same as #29. Test: `testTwoThousandItemsLayOutQuickly`. |
| [#9](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/9) `EXC_BAD_ACCESS` with `estimatedItemSize`. | Done: same as PR #25. Test: `testSelfSizingCellsAppearAndSettle`. |
| [#8](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/8) Two cells get the same frame after rotation. | Done: no cache, the layout is invalidated on a width change. Test: `testWidthChangeRecomputesEveryFrame`. |
| [#7](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/7) Horizontal scrolling: cells overlap. | Done: same as PR #37. Test: `testHorizontalScrollingKeepsTheFlowLayoutFrames` (no overlap). |
| [#4](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/4) "Cached frame mismatch" warning. | Done: every attribute returned is a copy. Test: `testReturnedAttributesAreCopies`. |
| [#2](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/2) Cells of different sizes. | Done: cells of different widths and heights, every row alignment. Test: `testCellsOfDifferentSizes`. |
| [#6](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/6), [#15](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/15) Questions / thanks, no defect. | Nothing to fix (not scored). |
