# Removed duplicate tag containers: what to use instead

Decided by the owner on 2026-11-25: the components below were second implementations of what `CYLTagListView` (`CYLTagListState` on
HarmonyOS, `cyl-tag-list` on the mini program) already does. They are removed at once, without a deprecated shim. This file is the
old -> new mapping for every caller. The image tag groups (`CYLImageTagGroupView`, `CYLImageTagView`, `cyl-tag-image`), the classify menu
and the multiple filter are **not** removed.

| Removed | Platform | Removed in | Use instead |
| --- | --- | --- | --- |
| `co.lujun.androidtagview.TagContainerLayout`, `TagView`, `android/AndroidTagView` | Android | `refactor/remove-duplicate-tag-containers` | `CYLTagListView` |
| `me.kaede.tagview.TagView`, `Tag`, `OnTagClickListener`, `OnTagDeleteListener`, `android/android-tagview` | Android | same | `CYLTagListView` + `CYLTag` |
| `CYLTagView` (TagCollectionView port: sections, More / Less header) | iOS (`TagCollectionView` project and the podspec files), Android, HarmonyOS | same | `CYLTagListView` with a `CYLMenuDataSource` and `CYLMenuFoldControl` |
| `CYLTagGroup`, `CYLTagModel`, `CYLTagCell`, `CYLTagHeaderCell` of that port | iOS, HarmonyOS | same | the data source (`titles`, `images`, ...) of the list |
| `cyl-tag-cloud` | mini program | `refactor/mini-program-tag-cloud-merge` | `cyl-tag-list` (package `cyl-tag-list-miniprogram` 0.2.0) |
| `unit-tests.sh tag` suite (TagCollectionView tests) | iOS | same as iOS | gone: `menu`, `example`, `swift` remain |

## API mapping

### AndroidTagView -> CYLTagListView (Android, also iOS `CYLTagListView`, HarmonyOS `CYLTagListState`)

| Old (`TagContainerLayout`) | New (`CYLTagListView`) |
| --- | --- |
| `setTags(List<String>)`, `addTag(text)`, `addTag(text, position)`, `removeTag(position)`, `removeAllTags()` | `setTags(...)`, `addTag(...)`, `insertTag(...)`, `removeTag(...)`, `removeAllTags()` (the tag methods of the list) |
| `setOnTagClickListener(TagView.OnTagClickListener)` (`onTagClick`, `onTagLongClick`, `onSelectedTagDrag`, `onTagCrossClick`) | the list's delegate (`menuDidSelectItemAtIndexPath`), long-press action (`CYLTagLongPressAction`, `longPressAction`) and cross / delete callbacks of the list |
| `setTheme(ColorFactory.PURE_CYAN ...)`, `colorTheme` | `CYLTagColorTheme` / `colorTheme` of the list |
| `setTagBackgroundColor`, `setTagTextColor`, `setTagBorderColor`, `setTagBorderWidth`, `setTagCornerRadius` | `CYLMenuStyle` (`appearanceForState`, `itemCornerRadius`, ...) or the per-tag `CYLTag` fields |
| `setTagTextSize`, `setTagMaxLength`, `setTagTextDirection`, `isTagSupportLettersRTL`, `tag_text_wrap` | `CYLMenuStyle.titleFont`, `titleMaxLines` (default 1; any number; the named constant for unlimited), the system layout direction |
| `setMaxLines`, `setVerticalInterval`, `setHorizontalInterval` | `CYLMenuStyle` spacing (`lineSpacing`, `interitemSpacing`) and the fold control (`CYLMenuFoldControl`) |
| `setEnableCross`, `setCrossColor`, `setDragEnable` | editing mode of the list (`isEditing`), the delete indicator and the reorder long-press action |

### `CYLTagView` (sections of tags with a More / Less header) -> `CYLTagListView`

| Old | New |
| --- | --- |
| `CYLTagView.groups` of `CYLTagGroup(groupName, items, isOpened)` | `CYLMenuDataSource` with sections (`menuTitleForSection...`, `menuTitlesForSection...`) |
| header button "More / Less" (`isShowHeader`, `tagHeaderCell(_:didToggleGroupInSection:)`) | `CYLMenuFoldControl` in the section header (`foldControl`, `isSectionExpanded` / `setExpanded`) |
| `defaultVisibleRows` of the group | `CYLMenuStyle.foldedRows` / the fold control's visible rows |
| `CYLTagView.reloadMenuData()` | `reloadMenuData()` of the list |

### `cyl-tag-cloud` -> `cyl-tag-list` (mini program, package 0.2.0, breaking)

| cyl-tag-cloud | cyl-tag-list |
| --- | --- |
| `usingComponents` path `.../cyl-tag-cloud/cyl-tag-cloud` | `.../cyl-tag-list/cyl-tag-list` |
| `<cyl-tag-cloud ...>` | `<cyl-tag-list ...>` with no `configuration`, or one without `sections` (flat tags are section 0) |
| `require('.../cyl-tag-cloud/model.js')`, `cache.js`, `editing-icons.js` | `.../cyl-tag-list/tag-model.js`, `cache.js`, `editing-icons.js` |
| `index.js` export `tagCloud` | `tagModel` |
| every property, method and event (`tagtap`, `taglongpress` {position, tag}, `foldchange` {canFold, expanded}, `selectionchange` {positions}, ...) | same names, defaults and payloads for flat tags |
| `setExpanded(expanded)` | same, or `setExpanded(0, expanded)` |
| long press: drag or report | same, now through the list's long-press action (`"reorder"` only where flat tags can move; `"callout"` shows a tag's `subtitle`) |
| (none) | `selectedItems()` / `setSelectedItems()` with keys `"0-<index>"` |

Dependency: `cyl-tag-list-miniprogram@^0.2.0` (consumers on `^0.1.0` do not pick it up). The package README has the same table
("Migration from cyl-tag-cloud").

Known gaps of this first merge (not hidden): flat tags are still drawn by the cloud's renderer, so they have no animated icons, and
they keep the cloud's own fold control and `foldchange` payload instead of the list's fold. Not yet looked at in WeChat DevTools.

## Who has to adapt

| Consumer | What to do |
| --- | --- |
| CYLSearchViewController (mini program `wechat-miniprogram-cylsearch`: `contactTags`, `contactTagEditor`, `discoverSearch`, `test/*.test.js`, a comment in `src/cyl-search/index.js`) | move `cyl-tag-cloud` to `cyl-tag-list`, depend on `cyl-tag-list-miniprogram@^0.2.0` |
| CYLTableViewPlaceHolder (vendors HarmonyOS `classifymenu` with `scripts/sync-harmonyos-classifymenu.sh`) | the next sync drops `CYLTagView`, `CYLTagGroup`, `CYLTagModel` from the module; nothing in the placeholder uses them (its example uses `CYLTagListView`) |
| Mac sessions (iOS) | the iOS side is not compiled here: build, run `menu`, `example`, `swift`, and check `scripts/swift-api-check.sh`; `scripts/swift-api-baseline.json` had the six removed types deleted by hand (3072 lines), regenerate it with the digester to be sure |
| Apps that call `CYLTagView`, `TagContainerLayout`, `me.kaede` `TagView` | use the table above |
