# cyl-tag-list-miniprogram

CollectionViewClassifyMenu's tag list and image tag for WeChat Mini Programs, the counterpart of the iOS
`CYLTagListView` / `CYLImageTagView` (the example: `CrossPlatform/wechat-miniprogram`).

## Install

```sh
npm install cyl-tag-list-miniprogram
```

Then in WeChat DevTools: **Tools → Build npm** (工具 → 构建 npm). It copies the package to `miniprogram_npm/`.

## Use

```json
{
  "usingComponents": {
    "cyl-tag-list": "cyl-tag-list-miniprogram/cyl-tag-list/cyl-tag-list",
    "cyl-tag-image": "cyl-tag-list-miniprogram/cyl-tag-image/cyl-tag-image",
    "cyl-tag-button": "cyl-tag-list-miniprogram/cyl-tag-button/cyl-tag-button"
  }
}
```

```xml
<cyl-tag-list configuration="{{configuration}}" bind:tagtap="onTagTap" />
```

### Flat tags

As `CYLTagListView` on iOS, Android and HarmonyOS, `cyl-tag-list` can also be filled with a flat array of tags (the
android-tagview way): when its `configuration` has no `sections`, it shows the `tags` property as one section
(section 0) and takes the tag methods through `selectComponent`: `addTag`, `addTags`, `insertTag`, `removeTag`,
`removeAllTags`, `replaceTags`, `getTags`, `selectedIndexes`, `toggleSelection`, `deselectAll`, editing
(`setEditing`, the add field, the cache), renaming, deleting, dragging, folding (`defaultVisibleRows`) and the word
picker (`setTagsWithCharactersOfText`, `selectedText`, `allowsSmearSelection`). The tags and their styles come from
`cyl-tag-list/tag-model.js` (`makeTag`, `defaultStyle()`, `tagCloudStyle()`, `tagContainerStyle()`,
`wordPickerStyle()`). `selectedItems()` / `setSelectedItems()` use the keys `"0-<index>"`; a tag's `subtitle` is
shown by the `longPressAction` "callout"; a long press drags a tag (the action "reorder") where the tags can move
(`allows-reordering`, or while editing).

```xml
<cyl-tag-list tags="{{tags}}" list-style="{{style}}" allows-reordering="{{true}}"
              bind:tagtap="onTagTap" bind:tagmove="onTagMove" />
```

### Corner radius

A style's `normal` / `selected` / `disabled` `cornerRadius` (and a tag's `cornerRadius`) is a plain number of points,
limited to half the tag height, as on iOS and Android: `0` is square corners, a value of half the height or more (for
example `1000`) is a capsule. `CORNER_RADIUS_SQUARE` is removed, and `0` no longer means an automatic capsule. The
`tagCloudStyle()` preset keeps its capsules with `1000`; the default radius is `3`.

### One tag on its own

`cyl-tag-button` is the iOS `CYLTagButton` on its own (a search bar item, a toolbar button, a placeholder's icon): an
icon or an animated icon before, after, above or below a title (`tagStyle.imagePlacement`: `leading`, `trailing`,
`top`, `bottom`), in a `CYLMenuStyle` box (`tagStyle` takes the keys of a configuration's style), with a badge
(`badge-value`: `null` hides it, `''` shows a dot, any other text a capsule; `badge-color`, system red by default).
A tag's background is never transparent by default (a clear tag on a white list looks like plain text, so `transparent`
and zero alpha become the default fill); a tag on its own that sits on a colored surface, such as a search bar item,
sets `allowsTransparentBackground: true` in its `tagStyle` to keep `transparent`.

```xml
<!-- buttonStyle: { imagePlacement: 'top', imageSize: '{24, 24}' } in the page's data -->
<cyl-tag-button title="Messages" image="system:message" badge-value="3" tag-style="{{buttonStyle}}" bind:tagtap="onTap" />
<!-- clearStyle: { allowsTransparentBackground: true, normal: { backgroundColor: 'transparent', borderWidth: 0 } } -->
<cyl-tag-button image="system:camera" tag-style="{{clearStyle}}" />
```

The models are plain JavaScript (no `wx` calls), e.g. `require('cyl-tag-list-miniprogram/cyl-tag-list/model.js')`.

### Language

The tags' own strings (delete, more / less, image tag hints) follow WeChat's language, or the one set with
`require('cyl-tag-list-miniprogram/locale.js').setLanguage('en')` (`zh-Hans`, `zh-Hant`, `en`).

### Icons and animated icons

Every tag icon (an image, a tinted symbol or an animation) is drawn by CYLTabBarController's shared icon + title
component, `cyl-animated-item` (the `CYLAnimatedItemView` of iOS and Android), shipped in this package at
`cyl-animated-item/` together with the default of its abstract nodes, `cyl-animation-placeholder/`. It is not on npm
yet, so it is taken from CYLTabBarController at a pinned commit (`COMMIT` in each folder) with its MIT license
(`LICENSE` in each folder); the example's `scripts/fetch-cyltabbar.js` updates and checks the copy.

The package links no animation engine. An app that plays animations gives cyl-tag-list (or cyl-tag-button) its engine
components through the abstract nodes `cyl-lottie-view`, `cyl-pag-view`, `cyl-rive-view` and `cyl-svga-view`, which
are forwarded to cyl-animated-item; a GIF is drawn by `<image>` and needs none. An engine component takes `path`,
`loop`, `speed`, `autoplay` and `resting-frame`, sends `ready` once it draws the file and `error` when it cannot, and
has `cyl_playFromStart()` (played on a tap and by `playAll()` / `playItems()` / `playAnimation()`). Until `ready`, and
after `error` or without an engine, the tag shows its image, or cyl-animated-item's placeholder without one.

Register where the files are, so that a configuration can name them as the iOS example does:

```js
// app.js
require('cyl-tag-list-miniprogram/cyl-tag-list/animations.js').configure({
  registry: {
    'Lottie/home.json': { engine: 'lottie', data: () => require('./data/home.js') },
    'GIF/star.gif': { engine: 'gif', src: '/data/star.gif' },
    'Rive/house.riv': { engine: 'rive', src: '/data/house.riv.bin' },
  },
});
```

```xml
<cyl-tag-list generic:cyl-lottie-view="my-lottie-view" generic:cyl-rive-view="my-rive-view"
              configuration="{{configuration}}" />
```

The engine component gets the registered path (`Lottie/home.json`, `Rive/house.riv`), finds the file with
`animations.resolve(path)`, and reads the tag's `animationOptions` and a `restingProgress` above 0 after `#`
(`animations.parameters(path)`). A GIF gets its registered `src`; an absolute path or URL in a configuration is passed
as it is. The example's `components/cyl-tag-animation-view` plays Lottie, Rive and PAG with CYLTabBarController's
cyl-lottie, cyl-rive and cyl-pag.

## Scrolling while dragging or smearing

`cyl-tag-list` catches `touchmove` on its flat tags while editing, during a drag (`disablesScrollingWhileReordering`, on
by default) and during a word picker smear. In WeChat's render layer a catch binding only stops the event from
bubbling; it does not stop native scrolling, so the scroller that contains the list turns its own scrolling off while
a gesture is active.

`reorderingchange` {reordering} and `smearingchange` {smearing} bubble and are composed (`{ bubbles: true, composed:
true }`), so the container that scrolls can hear them as an ancestor, through a slot, without the page wiring anything:
a container component (such as CYLSearchViewController's core content page) binds them on its own scroller and sets
`scroll-y` off while either is true. Do not let a page with `min-height: 100vh` and taller content be the scroller
(nothing holds a scrolling page); give it `"disableScroll": true`.

```xml
<!-- inside the container component's own template -->
<scroll-view scroll-y="{{!gestureActive}}" bind:reorderingchange="onGesture" bind:smearingchange="onGesture">
  <slot />
</scroll-view>
```

A page that hosts the list directly can bind the same events on the list or on any ancestor view.

The page itself must not scroll: give it a fixed-height column (`height: 100vh`, `overflow: hidden`, the scroller
with `min-height: 0`) and `"disableScroll": true`, and let that one scroll view hold its `scroll-y`. WeChat's page-level
switches do not help from a component: `<page-meta page-style>` works only as the first node of a page (inside a
component it does nothing), and `wx.setPageStyle` is undocumented and changed nothing in DevTools (base library 3.6.6;
real drags, CYLSearchViewController `docs/CYLTabBarController-Integration.md`, fourth pass).

## Migration from cyl-tag-cloud (0.2.0)

Version 0.2.0 removes the component `cyl-tag-cloud`: `cyl-tag-list` takes its flat tags, with the same properties,
methods and events (there is no alias). Change the component path and the tag name; the rest stays.

| cyl-tag-cloud (0.1.x) | cyl-tag-list (0.2.0) |
| --- | --- |
| `"cyl-tag-cloud": "cyl-tag-list-miniprogram/cyl-tag-cloud/cyl-tag-cloud"` | `"cyl-tag-list": "cyl-tag-list-miniprogram/cyl-tag-list/cyl-tag-list"` |
| `<cyl-tag-cloud tags="…" list-style="…" …>` | `<cyl-tag-list tags="…" list-style="…" …>` (no `configuration`, or one without `sections`) |
| `require('…/cyl-tag-cloud/model.js')` | `require('…/cyl-tag-list/tag-model.js')` |
| `require('…/cyl-tag-cloud/cache.js')`, `…/editing-icons.js` | `require('…/cyl-tag-list/cache.js')`, `…/cyl-tag-list/editing-icons.js` |
| `require('cyl-tag-list-miniprogram').tagCloud` | `require('cyl-tag-list-miniprogram').tagModel` |
| properties `tags`, `list-style`, `color-theme`, `allows-tapping`, `removes-items-on-delete`, `allows-reordering`, `selection-mode`, `allows-empty-selection`, `default-tag-image`, `container-border-*`, `shows-section-headers`, `section-title`, `editing`, `shows-add-item-view-while-editing`, `cache-policy`, `cache-name`, `load-policy`, `supports-renaming-items`, `renames-on-title-tap-while-editing`, `shows-clear-button`, `default-visible-rows`, `allows-smear-selection`, `disables-scrolling-while-reordering`, `fold-control-content`, `fold-control-color` | the same names, same defaults |
| events `tagtap`, `tagdelete`, `taglongpress` {position, tag}, `tagmove`, `selectedtagdrag`, `reorderingchange`, `smearingchange`, `selectionchange` {positions}, `foldchange` {canFold, expanded}, `editingchange`, `editingfinish`, `requestnewitem`, `tagrename`, `clearbuttontap`, `contentchange` | the same names and payloads for flat tags (a list built from `sections` keeps its own payloads) |
| methods `getTags`, `addTag`, `addTags`, `insertTag`, `removeTag`, `removeAllTags`, `replaceTags`, `selectedIndexes`, `toggleSelection`, `deselectAll`, `setTagsWithCharactersOfText`, `selectedText`, `selectItemsFrom`, `isEditing`, `setEditing`, `cachedTitles`, `saveToCache`, `cachedItems`, `editableSectionTitles`, `editableSectionItems`, `loadSections`, `loadItems`, `setRemoteSource`, `renamingIndex`, `setRenameRequestHandler`, `isRenamable`, `beginRenaming`, `cancelRenaming`, `finishRenaming`, `submitNewItem`, `isExpanded` | the same names |
| `setExpanded(expanded)` | `setExpanded(expanded)` or the list's `setExpanded(0, expanded)`; `isSectionExpanded(0)` |
| a long press: drag where `allows-reordering` / editing, else `taglongpress` | the same, now through the list's long-press actions: the default of flat tags is `["reorder", "report"]`; `long-press-action` ("callout", "report", "none", or an array) changes it, and "callout" shows a tag's `subtitle` |
| (none) | `selectedItems()` / `setSelectedItems(keys)` with the keys `"0-<index>"` |
