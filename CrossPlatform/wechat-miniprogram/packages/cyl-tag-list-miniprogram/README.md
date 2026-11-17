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

### Animated icons

The package links no animation engine. To play Lottie, Rive, PAG or GIF icons, register the files and engines your app
ships, and hand cyl-tag-list the component that plays them as the abstract node `cyl-animation-icon`:

```js
// app.js
require('cyl-tag-list-miniprogram/cyl-tag-list/animations.js').configure({
  registry: { lottie: { /* key: { data() } */ }, gif: {}, rive: {}, pag: {} },
  engines: { lottie: true },
});
```

```xml
<cyl-tag-list generic:cyl-animation-icon="my-animation-icon" configuration="{{configuration}}" />
```

The icon component takes `animation`, `options`, `size`, `height`, `speed`, `loops`, `selected`, `restingProgress`,
`disabled` and has a `play()` method. The example's `components/cyl-lottie-icon` plays all four engines with
CYLTabBarController's cyl-lottie, cyl-rive and cyl-pag.
