# CYLCollectionViewLeftAlignedLayout 优化

`CYLCollectionViewLeftAlignedLayout` (`CollectionViewClassifyMenu/Class/Other/Lib/CYLCollectionViewLeftAlignedLayout/`) began as a
copy of [mokagio/UICollectionViewLeftAlignedLayout](https://github.com/mokagio/UICollectionViewLeftAlignedLayout) (MIT). This page
tracks the upstream pull requests merged into it and every upstream issue, with the fix or the check that covers it. The Android
port (`android/merged/library/.../CYLCollectionViewLeftAlignedLayout.kt`) follows the same rules.

## Task log

- **Status:** TODO (started 2026-11-12, branch `feat/android-kotlin`).
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

Score = rows done / 24 rows (4 pull requests + 20 issues) × 100.

| Date | Done | Score |
| --- | --- | --- |
| 2026-11-12 | 0 / 24 | 0 |

## Pull requests

| Pull request | TODO |
| --- | --- |
| [#37](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/37) Horizontal scrolling: rows are only left-aligned when the layout scrolls vertically. | TODO: return the flow layout's own frames (copied) when `scrollDirection` is horizontal; test. |
| [#31](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/31) Full-width cells on 3x devices: fractional `y` makes a cell look like it is on the previous row (`FLT_EPSILON`). | TODO: decide rows by vertical overlap with a tolerance, not by any intersection; test with fractional heights. |
| [#25](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/25) iOS 9 crash (#9): copy the attributes only on iOS 10+. | TODO: the minimum is iOS 15, so attributes are always copied; test self-sizing (`estimatedItemSize`) does not crash. |
| [#20](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/pull/20) A cell as wide as the screen gets a wrong `x`. | TODO: clamp every frame inside the section insets of the collection view (not the screen); test. |

## Issues

| Issue | TODO |
| --- | --- |
| [#36](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/36) Add a privacy manifest. | TODO: add `PrivacyInfo.xcprivacy` to the pod (no tracking, no required-reason API). |
| [#33](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/33) iOS 11.4: the right section inset is ignored. | TODO: no frame passes `width - inset.right`; test. |
| [#32](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/32) Section headers not positioned correctly. | TODO: headers and footers keep the flow layout's frames; test several sections. |
| [#30](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/30) Horizontal scrolling: every `x` becomes 0. | TODO: same fix as #37; test. |
| [#29](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/29) 2000 items: slow scrolling and memory exit. | TODO: no recursion, work per row; test 2000 items within a time limit. |
| [#28](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/28) Podspec points to an old version. | TODO: check our podspec version and tag rule. |
| [#27](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/27) Accuracy problem of fractional `y`. | TODO: same fix as #31; test. |
| [#26](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/26) A section of full-width cells is laid out wrongly. | TODO: same fix as #31 / #20; test. |
| [#22](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/22) Header moves down when a section has one item (closed by the reporter). | TODO: test a one-item section's header. |
| [#21](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/21) A Swift port. | TODO: Swift-friendly API (nullability, Swift names); Swift use is covered by the Swift examples. |
| [#18](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/18) `estimatedItemSize`: no cells are shown. | TODO: test self-sizing cells appear. |
| [#17](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/17) Recursive loop with `preferredLayoutAttributesFittingAttributes:`. | TODO: test self-sizing cells finish layout. |
| [#16](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/16) Crash with section footers. | TODO: test headers and footers. |
| [#13](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/13) Cell sizing with Auto Layout. | TODO: same test as #18. |
| [#11](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/11) Crash reading `collectionViewContentSize` with estimated sizes. | TODO: test reading the content size with self-sizing cells. |
| [#10](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/10) Stutters on the first scroll. | TODO: same as #29. |
| [#9](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/9) `EXC_BAD_ACCESS` with `estimatedItemSize`. | TODO: same as #25. |
| [#8](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/8) Two cells get the same frame after rotation. | TODO: no cache, invalidate on width change; test a width change. |
| [#7](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/7) Horizontal scrolling: cells overlap. | TODO: same as #37. |
| [#4](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/4) "Cached frame mismatch" warning. | TODO: every attribute returned is a copy; test. |
| [#2](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/2) Cells of different sizes. | TODO: test cells of different widths and heights. |
| [#6](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/6), [#15](https://github.com/mokagio/UICollectionViewLeftAlignedLayout/issues/15) Questions / thanks, no defect. | Nothing to fix (not scored). |
