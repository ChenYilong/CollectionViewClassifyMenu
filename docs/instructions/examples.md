# Example demo rules

Tag: `examples`. The full rules of this tag. [AGENTS.md](../../AGENTS.md) keeps the short form under the heading
`[examples] Example demo rules`; read this file when a task touches the tag. Moved from AGENTS.md word for word on 2026-11-22, when
AGENTS.md was limited to 200 lines; section names are unchanged, so a reference such as AGENTS.md "Example demo rules" now
means the section of that name here.


## Example demo rules

- **Animation playback controls.** Every example screen that shows animations (Lottie, PAG, Rive, GIF, symbol
  effects), on every platform (iOS, Android, React Native, Flutter, Mini Program, HarmonyOS), offers three controls
  that combine and act in real time: **Play all** (restart every animation from progress 0, once), a **speed slider**
  and a **loop switch**. Change the core library (and CYLTabBarController's animation engine) when an engine lacks
  the speed or loop API; never work around it in the example. Details, status per platform and the TODO:
  `docs/example-demo-rules.md`. The same rule, with the library-side notes, is in CYLTabBarController's
  `docs/Tab-Icon-Animation-Quick-Start.md` ("Playback controls in the animation examples").


## Sectioned lists in demos use the tag list

- **Rule (owner's request, 2026-11-25).** When an example (demo) screen needs a list with section groups, such as a
  table view with sections, a list with section headers or an inset-grouped list, build it with
  CollectionViewClassifyMenu's tag list (`CYLTagListView`, `CYLTagListState` on HarmonyOS) instead of the platform's own
  grouped list. Use the tag list's section style:
  - One tag list; one section per group; the section title is the section header.
  - A tag shows only the **main title and the icon**. The secondary line (detail, subtitle) is not drawn in the tag.
  - **Colourful page, library plate.** The page behind the list is colourful (a gradient or an image, set in one shared place per example). The library draws the plate itself, one Liquid Glass card per section (sectionStyle insetGrouped, the default, with sectionBackgroundStyle = liquidGlass); the example draws no plate.
  - **Headers and icon colours.** Long headers use headerMaxLines 2 (a named constant); icon colours are static colours passed through the item style (menuStyleForItem + setIconColor), template images, never .alwaysOriginal.
  - **The tail fold control is itself a Liquid Glass tag**, icon only (the same tag background style as the other tags).
  - **Fold with the tail control, icon only.** Sections that have more rows than `defaultVisibleRows` fold with the core's **tail**
    fold control: the last tag of the section is the expand / collapse button and shows only the chevron icon, no More / Less text
    (`foldControl` position `tail`, content `icon`; JSON `"foldControl": {"position": "tail", "content": "icon"}`). Never use the
    header trailing More / Less control in an example.
  - Other positions and contents (`footer`, `headerTrailing`, `title`, `iconAndTitle`) stay available in the core; only the fold-styles demo screen
    (`CYLFoldStylesViewController`) shows them, because that screen exists to demo every variant. (Replaces the earlier rule "More / Less, header trailing", 2026-11-25.)
  - A tap on a tag does exactly what a tap on the replaced cell did (open the screen, select the row). The tag does not
    stay selected unless the cell did.
  - A **long press** on a tag shows the secondary line in a small floating callout with an arrow, through the tag list's
    long-press action API: data source `menuSubtitleForItem` (item key `subtitle`, `CYLTag.subtitle`) and
    `longPressAction` `"callout"` / `CYLTagLongPressActions.callout` (contract:
    [docs/tag-long-press-action.md](../tag-long-press-action.md)). Do not draw a popup in the example.
  - A title that does not fit one line wraps through the style's `titleMaxLines` (default 1; any number; every line
    shown with the named constant `CYLTagTitleMaxLinesUnlimited`, never a literal such as 0 or 999). The tag list leaves
    the number to the app; an example picks its own (the placeholder example uses 3).
  - If the tag list lacks an API the example needs, add it to CollectionViewClassifyMenu first (core first, every
    platform, documented), then use it from the example.
- **After such a change, re-test the contact-list long-press reordering.** Reordering is the tag list's built-in
  `reorder` long-press action; it must behave exactly as before (host tests, ui-test and a look on the emulator).
- Where the example lives in another repository, that repository vendors the library at a pinned commit (see
  [dependencies.md](dependencies.md)); update the pin instead of copying the code by hand.

## Search bars

- A search bar never covers any view, at any time: not the view controller's view, not a sibling, not a background
  view, not a bar item, in every state (scrolling, editing, Cancel shown) and at every Dynamic Type size. A screen
  whose navigation bar holds the search bar removes `.top` from `edgesForExtendedLayout`; a `CYLSearchBarView` is
  laid out against the safe area beside the content, and a colored area behind the status bar ends where the bar
  begins. `CYLSearchBarPlacementTests` checks every screen with a search bar through `CYLViewOverlapInspecting`;
  add a test there for each new one.


## Tab bars

- Tab bars are always at the bottom of the screen, including tab bars nested in
  a screen (such as scenario 2's category tabs); never move a tab bar to the top.
- A screen pushed from a tab sets `hidesBottomBarWhenPushed = YES`, so the
  parent tab bar is hidden after the push.
- Do not set a tab's root view controller `title`; set `navigationItem.title`,
  otherwise it replaces the tab item's title.
