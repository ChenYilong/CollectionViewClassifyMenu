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

## Section card, header divider and tint (the default look changed)

A tag list now shows each section's tags on a rounded card by default (`sectionStyle` `insetGrouped`). If you never set
`backgroundColor`, the list background becomes the grouped background (#F2F2F7; black in dark mode). The header divider is
**off** by default. The header band (`headerBackgroundColor`) is off by default too.

The keys go in the configuration's `style`:

- Remove the card: `"sectionStyle": "plain"`.
- Show the header divider: `headerSeparatorStyle` `line`, optionally with `headerSeparatorColor`, `headerSeparatorThickness`
  (default 0.5) and `headerSeparatorInsets` (default 0: it spans the same left and right edges as the card and the band).
- Optional header band: `headerBackgroundColor`, with `headerCornerRadius` and `headerContentInsets`.
- The card: `sectionBackgroundColor`, `sectionCornerRadius` (default 10), `sectionContentInsets` (default 12), `sectionBoardInset` (how far the card, header band and divider extend beyond the tag column on both sides; unset = `sectionContentInsets` left / right, so the card spans the section column; 0 hugs the tags; a value above the default can push the card past the list margin; the tag column and the header title never move), and
  `sectionBackgroundStyle` `flat` (default) or `liquidGlass` (falls back to flat where the platform cannot draw glass).
- `tintColor`: the one color of the built-in header title, icon and More / Less control. Left out, it is black or white,
  whichever is legible on the background behind them.
- Every new color adapts to light and dark mode by itself; a color you set wins in both modes.
### Migration: the default look changed

This is a breaking visual change: a list that sets nothing now shows the rounded card and the grouped background. To get the
old look, set `sectionStyle` to `plain`. Screenshots and tests that depend on pixel positions need updating.

```js
Page({
  data: {
    configuration: {
      style: { sectionStyle: 'plain' },                       // the old look; leave `style` out for the card
      // style: { headerSeparatorStyle: 'line', tintColor: '#007AFF' },  // the divider is opt-in
      sections: [{ title: 'Reviews', items: [{ title: 'All' }, { title: 'Positive' }] }],
    },
  },
});
```

```json
{
  "style": {
    "sectionStyle": "plain",
    "headerSeparatorStyle": "line",
    "headerSeparatorColor": "#C6C6C8",
    "headerSeparatorThickness": 0.5,
    "headerSeparatorInsets": [0, 0, 0, 0],
    "headerBackgroundColor": "#EFEFF4",
    "sectionBackgroundStyle": "liquidGlass",
    "tintColor": "#007AFF"
  }
}
```

### Corner radius

A style's `normal` / `selected` / `disabled` `cornerRadius` (and a tag's `cornerRadius`) is a plain number of points,
limited to half the tag height, as on iOS and Android: `0` is square corners, a value of half the height or more (for
example `1000`) is a capsule. `CORNER_RADIUS_SQUARE` is removed, and `0` no longer means an automatic capsule. The
`tagCloudStyle()` preset keeps its capsules with `1000`; the default radius is `3`.

### Section card (the default look)

A list that sets nothing draws each section's tags in a rounded card (`sectionStyle: 'insetGrouped'`) on the grouped list
background (#F2F2F7, black in dark mode) with no header divider and no header band. To remove the card, set the style key
`sectionStyle` to `plain`:

```js
configuration: { style: { sectionStyle: 'plain' }, sections: [/* ... */] }
```

The header divider is not a default; it shows only when you ask for it: `style: { headerSeparatorStyle: 'line' }`. The card
(`sectionBackgroundColor`, `sectionCornerRadius`, `sectionContentInsets`, `sectionBackgroundStyle`), the header band
(`headerBackgroundColor`) and the divider keys are described in `docs/tag-section-style.md` of the repository.

### Fold control

`defaultVisibleRows` folds a section; `foldControl: { position, content, title, collapseTitle, color }` draws the control
(`position`: `headerTrailing`, `tail` or `footer`; the tail and the footer default to the chevron icon only, the header to
icon and title). `content`: `icon`, `title`, `iconAndTitle` (the aliases `iconandtitle` and `titleandicon` mean this one), and
`titleAndIconAlways`, which shows the title and the chevron in both states: "More v" folded, "Less ^" expanded (the collapse title
and the chevron turned 180 degrees). `title` and `collapseTitle` replace the localized texts. The control is as wide as its longer
title, so it does not jump when toggled. A control in the section header shows only on a section that can fold (an unfoldable
section has no control and no space for it); its font is capped (20 px) and its width is at most 40% of the header, where the
section title is truncated with an ellipsis. The gap between the section title and the header control is 8 px (iOS 8 pt,
Android 8 dp). `rotatesImageWhenExpanded` (default `true`) turns the chevron 180 degrees when the section is expanded; `false`
keeps it still.

### Section header keys

In the configuration's `style`: `headerHeight` (default 36 px; the fixed height of a one-line header, and only a minimum for a
header that wraps or is tight to the card) and `headerMaxLines` (default `1`, one line with an ellipsis; a number above 1 or
`"unlimited"` wraps the title and grows the header).

### Internal model fields

`borderColorExplicit`, `borderWidthExplicit`, `textColorExplicit` and `backgroundExplicit` in the normalized appearance
(`model.normalize(...).style.normal` and the other states) are internal: the configuration parser sets them when the app gave
that value, so the defaults that follow dark mode and glass apply only where the app set nothing. Do not put them in a
configuration; they are ignored there.

### Long-press callout

With `longPressAction: "callout"` an item's `subtitle` shows in a bubble above the tag, or below it when there is no room
above or the bubble would cover the section header. A tap, a fold, a rebuild or another long press hides it. The list has no
scroller of its own, so a scroll hides it only when the page tells the component: call `onScroll()` (or `dismissCallout()`)
from the scroller's `bindscroll` or from the page's `onPageScroll`.

```js
onScroll() { this.selectComponent('#tags').onScroll(); },
```

### Configuration keys the iOS list has and this component does not

Unsupported here (ignored): `scrollEnabled` (the component draws no scroller; the page's own `scroll-view` scrolls it),
`titleImage`, `titlePosition`, `deletable`, `deleteIndicatorTitle`, `deleteIndicatorColor`, `deleteIndicatorFont`,
`adjustsFontForContentSizeCategory`, `foldStyle` and `id`.

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

`cyl-tag-cloud` catches `touchmove` on its tags while editing, during a drag (`disablesScrollingWhileReordering`, on
by default) and during a word picker smear. In WeChat's render layer a catch binding only stops the event from
bubbling; it does not stop native scrolling, so the scroller that contains the cloud turns its own scrolling off while
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

A page that hosts the cloud directly can bind the same events on the cloud or on any ancestor view.

The page itself must not scroll: give it a fixed-height column (`height: 100vh`, `overflow: hidden`, the scroller
with `min-height: 0`) and `"disableScroll": true`, and let that one scroll view hold its `scroll-y`. WeChat's page-level
switches do not help from a component: `<page-meta page-style>` works only as the first node of a page (inside a
component it does nothing), and `wx.setPageStyle` is undocumented and changed nothing in DevTools (base library 3.6.6;
real drags, CYLSearchViewController `docs/CYLTabBarController-Integration.md`, fourth pass).
