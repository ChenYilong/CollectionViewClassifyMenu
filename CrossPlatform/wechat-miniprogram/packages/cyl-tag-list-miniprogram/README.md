# cyl-tag-list-miniprogram

CollectionViewClassifyMenu's tag list, tag cloud and image tag for WeChat Mini Programs, the counterpart of the iOS
`CYLTagListView` / `CYLTagCloudView` / `CYLImageTagView` (the example: `CrossPlatform/wechat-miniprogram`).

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
    "cyl-tag-cloud": "cyl-tag-list-miniprogram/cyl-tag-cloud/cyl-tag-cloud",
    "cyl-tag-image": "cyl-tag-list-miniprogram/cyl-tag-image/cyl-tag-image",
    "cyl-tag-button": "cyl-tag-list-miniprogram/cyl-tag-button/cyl-tag-button"
  }
}
```

```xml
<cyl-tag-list configuration="{{configuration}}" bind:tagtap="onTagTap" />
```

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
