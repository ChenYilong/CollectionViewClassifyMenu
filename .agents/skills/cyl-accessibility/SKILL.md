---
name: cyl-accessibility
description: Accessibility rules, the core's accessibility API and checks for CollectionViewClassifyMenu and its examples (VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Dynamic Type, Reduce Motion, contrast).
---

# Accessibility

Adapted from CYLTabBarController's "Accessibility is required everywhere" (its `AGENTS.md`, newest commit over every
branch, see `cyl-dependency`). General practice: the copied `ios-accessibility`, `uikit-accessibility-auditor` and
`accessibility-audit` skills.

## What the core provides

| View | Element | Label | Traits | Identifier |
| --- | --- | --- | --- | --- |
| Tag cell (`CYLTagListCell`) | yes | the tag's title | button, + selected, + not enabled | `CYLTagListItem` (`CYLTagListItemAccessibilityIdentifier`) |
| "+ 新建标签" (`CYLTagCreateCell`) | yes | "新建标签" / "新建标签：<name>" (core strings) | button (never selected) | `CYLTagCreateItem` |
| Fold control (`CYLTagFoldButton`, header or bottom; `CYLTagFoldCell` for the inline position) | yes | "<section> 更多/收起" (core strings), hint `CYLMenuExpandHint` while folded | button | `CYLTagListFoldControl` |
| More button (`menuShowsMoreButtonInSection:`) | yes | the host's `menuAccessibilityLabelForMoreButtonInSection:` (say the action, e.g. "换一批"), else "<section> 更多操作" (core string `CYLMenuMoreActions`); also the Large Content Viewer title | button | `CYLTagListMoreButton` |
| A tag's icon with a meaning (such as the 热 icon) | no (part of the tag) | its `accessibilityLabel` is read as the tag's value | — | — |
| List title (`CYLTagListView.titleView`) | when it has a label | `title`, else the title image's `accessibilityLabel` | header | `CYLTagListTitle` |
| Section header label | yes | the section title | header | — |

- The identifiers are declared in `CYLTagListAccessibility.h` (Swift: `CYLTagListItemAccessibilityIdentifier`, …).
  They never change; labels stay localized.
- Hints: implement `-menuAccessibilityHintForItemAtIndexPath:` (Swift `menuAccessibilityHintForItem(at:)`) in the
  data source; the list applies it to the cell (for example "轻点两下删除此标签" in the tag editor's 管理 mode).
- An icon-only title is decorative until it has a label: set the title image's `accessibilityLabel` before handing
  it to the list (the Swift fold-styles demo does). A title that acts as a control (the remark screen's "标签 ›")
  sets `titleView.accessibilityTraits = [.header, .button]` and a hint.
- Fonts: `CYLMenuStyle` scales with Dynamic Type and Bold Text; the list remeasures when the text size changes
  (`testAccessibilityTextSizesScaleTagsWithoutOverlapOrOverflow`, `testMenuRemeasuresWhenTextSizeChanges`).
- Animations of the fold chevron and tag icons respect Reduce Motion.

## Rules for examples

- Every label, placeholder and hint comes from the example's lookup (`cyl-localization`), never a literal.
- Text fields have an `accessibilityLabel` even with a placeholder; titles are headers; custom buttons keep their
  text readable at every size (`UIFontMetrics…scaledFont(for:)` + `adjustsFontForContentSizeCategory`).
- Use semantic colors (`.label`, `.secondaryLabel`, `systemRed`) so Increase Contrast and dark mode work; do not use
  color alone for meaning (selected tags also get the selected trait).
- Announce results of actions that change the screen without moving focus
  (`UIAccessibility.post(notification: .announcement, …)`, as after "+ 新建标签").

## Checks

1. Tests find elements by identifier or label first (`views(withIdentifier:in:)` in the Swift tests,
   `testTagListViewsHaveStableAccessibilityIdentifiers` in the ObjC tests); coordinates only as a last resort,
   then file and fix the missing label.
2. Swift: `testEditorTagsAreAccessibilityElementsWithLabelsTraitsAndHints`,
   `testRemarkTitleIsAHeaderThatOpensTheEditor`, `testFoldStylesTitlesAndFoldControlsAreLabelled`,
   `testIconOnlyTitleWithoutALabelIsDecorative`.
3. On a Mac: Accessibility Inspector's audit on each screen, and VoiceOver through the remark → editor → 新建标签
   flow, then the fold-styles tab at the largest accessibility text size.

A change that adds a control or a text without accessibility is not done.
