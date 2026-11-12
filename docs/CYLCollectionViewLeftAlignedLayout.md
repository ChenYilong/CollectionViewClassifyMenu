# CYLCollectionViewLeftAlignedLayout 优化

`CYLCollectionViewLeftAlignedLayout` (`CollectionViewClassifyMenu/Class/Other/Lib/CYLCollectionViewLeftAlignedLayout/`) began as a
copy of [mokagio/UICollectionViewLeftAlignedLayout](https://github.com/mokagio/UICollectionViewLeftAlignedLayout) (MIT). This page
tracks the upstream pull requests merged into it and every upstream issue, with the fix or the check that covers it. The Android
port (`android/merged/library/.../CYLCollectionViewLeftAlignedLayout.kt`) follows the same rules.

## Task log

- **Status:** DONE (2026-11-12, branch `feat/android-kotlin`). 25 / 25 rows, score 100.
- **Context:** while porting the tag list to Kotlin (`docs/android.md`, step 5), the layout is reworked. The user asked to merge
  four upstream pull requests and to handle every issue in the upstream issue list.
- **Requirements:**
  1. Merge PR #37, #31, #25 and #20 of mokagio/UICollectionViewLeftAlignedLayout.
  2. Handle every issue in its issue list.
  3. Track them here: column 1 is the issue (description and link), column 2 the TODO / result.
  4. Score: full marks when every row is fixed; keep fixing until full marks.
- **Prompt (verbatim):**

  > 在对 CYLCollectionViewLeftAlignedLayout  进行改造的过程中需要 merge以下代码 https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/37  https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/31 https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/25 https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/20/changes 并处理列表里提出了所有issue 加入合适文档的TODO 没有就新建CYLCollectionViewLeftAlignedLayout 优化。将第一列设为issue 描述与地址，第二列为TODO。全部修复完视为满分，修复满分为止

- **Prompt (English):** while reworking CYLCollectionViewLeftAlignedLayout, merge PR #37, #31, #25 and #20 of
  UICollectionViewLeftAlignedLayout and handle every issue in its list. Add the TODOs to a suitable document, or create
  "CYLCollectionViewLeftAlignedLayout 优化". Column 1: the issue's description and link; column 2: the TODO. Everything fixed is
  full marks; keep fixing until full marks.

## Score

Score = rows done / 25 rows (4 pull requests + 21 issues; #6 and #15 are questions, not scored) × 100.

| Date | Done | Score |
| --- | --- | --- |
| 2026-11-12 | 0 / 25 | 0 |
| 2026-11-12 | 25 / 25 | 100 |

## Evidence

- `scripts/unit-tests.sh menu`: 28 tests, 0 failures, including the 10 of `CYLCollectionViewLeftAlignedLayoutTests.m`
  and `CYLLeftAlignedLayoutSwiftTests.swift`.
- Android: `CYLCollectionViewLeftAlignedLayoutTest` (3 tests: full-width fractional rows, trailing inset, 2000 items),
  0 failures.
- `scripts/pod-lint.sh lib`: passed validation.

## Pull requests

| Pull request | TODO |
| --- | --- |
| [#37](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/37) Horizontal scrolling: rows are only left-aligned when the layout scrolls vertically. | Done: horizontal layouts return copies of the flow layout's frames (`cyl_alignsRows`). Test: `CYLCollectionViewLeftAlignedLayoutTests` `testHorizontalScrollingKeepsTheFlowLayoutFrames`. |
| [#31](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/31) Full-width cells on 3x devices: fractional `y` makes a cell look like it is on the previous row (`FLT_EPSILON`). | Done: rows are found by vertical centers with a tolerance (`CYLFramesShareRow`), not by any intersection. Test: `testFullWidthCellsWithFractionalHeightsStartTheirOwnRows`. |
| [#25](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/25) iOS 9 crash (#9): copy the attributes only on iOS 10+. | Done: iOS 15+ always copies (the iOS 9 branch is not needed). Test: `testSelfSizingCellsAppearAndSettle`, `testReturnedAttributesAreCopies`. |
| [#20](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/20) A cell as wide as the screen gets a wrong `x`. | Done: frames are clamped inside the section insets of the collection view (not the screen width). Test: `testFullWidthCellsWithFractionalHeightsStartTheirOwnRows`, `testCellsNeverPassTheTrailingInset`. |

## Issues

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
