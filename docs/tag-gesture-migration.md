# Moving the tag gestures into CYLAnimatedItemView and merging the tag cloud into the tag list

Owner's request (2026-11-25): (1) merge `cyl-tag-cloud` into `cyl-tag-list`, remove `cyl-tag-cloud`, on every platform (iOS, Android,
HarmonyOS, mini program, React Native, Flutter); (2) move the long-press gesture protocol and callbacks out of this repository's core
into `CYLAnimatedItemView` (CYLTabBarController), next to its tap API (add a tap API where there is none); this repository then
implements its existing API by calling `CYLAnimatedItemView`, and an app that wants a tap or a long press on an item does it through
the item view's API. Designed by the advisor; this file is the plan, the inventory and the stop points. Nothing below is built yet.

## Order (two migrations, never interleaved)

0. **Baseline (stop point).** About 10 unpushed ClassifyMenu commits (`feat/tag-long-press-action`), the dark-mode commit `6c9b393c`, a
   debug-guard branch and a placeholder branch that pins the unpushed `360ce0bf`. Push or PR them first (the owner decides). The long-press
   API stays ClassifyMenu's public, list-level API; this redesign only replaces its internals.
1. **Inventory** (below, read-only).
2. **CYLAnimatedItemView interaction API** (CYLTabBarController): `onTap(item)`, `onLongPress(item, press)` with a phase (began, changed,
   ended, cancelled), the location, the translation and `moved`; a `longPressAction` strategy (`canBegin` / `begin -> follows` / `changed` /
   `end` / `cancel`) with `longPressDuration`; the primitives `showCallout(text)` / `dismissCallout()` (the item knows its frame);
   built-ins `callout`, `handler`, `none`, `first`; the "a long-press release does not also tap" rule moves in; accessibility actions for tap
   and long press. **Opt-in:** with no handler and no action no recognizer is installed (tab bar buttons use this view; a new recognizer must
   not swallow tab-selection taps). Tests: a tab item without handlers behaves as before; CYLTabBarController's suites unchanged.
3. **ClassifyMenu over the item API.** Reordering stays in the list (it mutates the data source across items): the list installs a bridge
   action on each tag's item view that forwards the phases, with the location converted to list coordinates, to the list's
   `CYLTagLongPressAction`. Delete the per-platform gesture code (HarmonyOS `LongPressGesture` / `Pan`, Android `GestureDetector.onLongPress`,
   iOS collection-level `UILongPressGestureRecognizer`; on iOS `beginInteractiveMovement` still needs collection-view points: the riskiest
   path, Mac). Taps are a later, separate step (selection has keyboard and VoiceOver paths). **Gate:** every existing long-press and reorder
   test passes unchanged (HarmonyOS `TagLongPressAction` / `WordPicker` / `TagListState`, Android `CYLTagEditingDragTest` /
   `CYLTagLongPressActionTest`, mini program `tag-long-press-action`, iOS `CYLTagReorderDemoTests`).
4. **Re-pin once.** One CYLTabBarController commit with the item API and everything the current pins need. Today HarmonyOS is on `11fc94be`
   and the rest on `3f2a5b99`, which are not ancestors of each other: choose one commit that has all three lines (`merge-base --is-ancestor`)
   and re-pin every platform in one commit.
5. **Merge the tag cloud into the tag list.** Port in this order: tag methods, delete, rename, editing, smear / word picker, cache, events;
   switch examples and consumers; migrate the tag-cloud tests to `cyl-tag-list` (do not delete them). Removing the component is a stop point
   (consumers in other repositories: migrate in the same wave, or keep a deprecated shim for one release). React Native and Flutter only change
   their JS / Dart surface and examples.

CYLTabBarController belongs to other sessions (winsCYLTabBarController, Mac-CYLTabBarController 小程序开发, winsCYLSearchViewController with
the content-inset work): send them the contract and the files before editing, work in an own worktree, open a PR, never merge.

## Inventory (2026-11-25)

| Platform | What the "tag cloud" is | Is a tag an item view? | CYLAnimatedItemView tap API |
| --- | --- | --- | --- |
| iOS | Already `CYLTagListView` (the AndroidTagView methods, `colorTheme`, `TagContainer` names are in `CYLTagListView.swift` / `CYLMenuStyle.swift`). Merge looks done; confirm. | Yes: `CYLTagButton: CYLAnimatedItemView` | Yes: `CYLAnimatedItemView: UIControl` sends `touchUpInside`, `handleTap` |
| Android | Already `CYLTagListView` (`addTag` / `setTags` / `colorTheme`); `CYLTagView`, `CYLImageTagView` / `CYLImageTagGroupView` (image tags) are separate; `android/AndroidTagView` is the upstream copy and its sample | Yes: `CYLTagButton` is a `CYLAnimatedItemView` | Yes: `GestureDetector.onSingleTapUp` calls `performClick`, `gestureListener.onAccessoryTapped` |
| HarmonyOS | Already `CYLTagListState` (`addTag`, `setTagsWithTitles`, `colorTheme`); `CYLTagView`, `CYLImageTagGroupView` separate | **No**: the tag is an ArkUI `Stack`; `CYLAnimatedItemView` only draws the icon, the gestures are on the list's item `Stack` | **No tap API** (`onAnimationEnd` only): one has to be added |
| Mini program | A separate component, `cyl-tag-cloud` (about 2000 lines, 6 test files, 6 sample pages), next to `cyl-tag-list` | **No**: `cyl-animated-item` is only the icon inside the tag | To read in CYLTabBarController (`src/cyl-animated-item`) |
| React Native | Wraps the native tag list: nothing to merge | n/a | n/a |
| Flutter | Wraps the native tag list: nothing to merge | n/a | n/a |

Consumers outside ClassifyMenu: CYLSearchViewController (iOS, contact tags: uses the tag list), CYLTableViewPlaceHolder (vendors the HarmonyOS
`classifymenu` and the engine modules; its mini program part has to be checked before the component is removed), CYLTabBarController
(examples and tests of `CYLAnimatedItemView` only).

## Decisions only the owner can make

1. Push the baseline first (step 0)?
2. On HarmonyOS and the mini program the tag is not an item view: "move the gesture into the item view" means making the whole tag one
   (large), or giving the item view an interaction API that the tag's container wires to the same strategy. Which?
3. Remove `cyl-tag-cloud` at once, or keep a deprecated shim for one release?
