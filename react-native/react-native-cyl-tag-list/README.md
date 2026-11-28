# react-native-cyl-tag-list

CollectionViewClassifyMenu's CYLTagListView as a React Native Fabric view

## Installation


```sh
npm install react-native-cyl-tag-list
```


## Usage


```js
import { CylTagListView } from "react-native-cyl-tag-list";

// ...

<CylTagListView color="#32a852" />
```


## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)

## Long press, subtitles, folding and title lines

The configuration is the native list's configuration, so these keys work on iOS, Android and HarmonyOS (typed as
`CylTagListConfiguration`):

```tsx
<CylTagListView
  configuration={{
    longPressAction: CylTagLongPressActionName.callout, // a small callout with an arrow showing the item's subtitle
    defaultVisibleRows: 2, // a section with more rows folds behind More / Less; one with fewer shows no control
    foldControl: 'headerTrailing',
    style: { titleMaxLines: 3 }, // or CylTagTitleMaxLinesUnlimited; itemsPerRow left out: tags are content-wide
    sections: [{ title: 'Flows', items: [{ title: 'Switch states', subtitle: 'reloadData #3' }] }],
  }}
  onTagTap={(tag) => {}}
  onTagLongPress={(tag) => {}} // the `report` action (part of the default) and `handler` actions
/>
```

## Section card, header divider and tint (the default look changed)

A tag list now shows each section's tags on a rounded card by default (`sectionStyle` `insetGrouped`). If you never set
`backgroundColor`, the list background becomes the grouped background (#F2F2F7; black in dark mode). The header divider is
**off** by default. The header band (`headerBackgroundColor`) is off by default too.

The keys go in the configuration's `style` and are typed in `CylTagListConfiguration` (`CylSectionStyle`,
`CylSectionBackgroundStyle`, `CylHeaderSeparatorStyle`; colors are strings such as `'#EFEFF4'`, insets are
`[top, left, bottom, right]`, `{ top, left, bottom, right }` or `'{t, l, b, r}'`):

- Remove the card: `style: { sectionStyle: CylSectionStyle.plain }`.
- Show the header divider: `headerSeparatorStyle` `line`, optionally with `headerSeparatorColor`, `headerSeparatorThickness`
  (default 0.5) and `headerSeparatorInsets` (default 0: it spans the same left and right edges as the card and the band).
- Optional header band: `headerBackgroundColor`, with `headerCornerRadius` and `headerContentInsets`.
- The card: `sectionBackgroundColor`, `sectionCornerRadius` (default 10), `sectionContentInsets` (default 12), and
  `sectionBackgroundStyle` `flat` (default) or `liquidGlass` (falls back to flat where the platform cannot draw glass).
- `tintColor`: the one color of the built-in header title, icon and More / Less control. Left out, it is black or white,
  whichever is legible on the background behind them.
- Every new color adapts to light and dark mode by itself; a color you set wins in both modes.

### Migration: the default look changed

This is a breaking visual change: a list that sets nothing now shows the rounded card and the grouped background. To get the
old look, set `sectionStyle` to `plain`. Screenshots and tests that depend on pixel positions need updating.

```tsx
import { CylTagListView, CylSectionStyle, CylHeaderSeparatorStyle, CylSectionBackgroundStyle } from 'react-native-cyl-tag-list';

<CylTagListView
  style={{ height: 240 }}
  configuration={{
    style: {
      sectionStyle: CylSectionStyle.plain, // remove the card; leave it out for the default card
      headerSeparatorStyle: CylHeaderSeparatorStyle.line, // the divider is opt-in
      headerBackgroundColor: '#EFEFF4', // optional band
      sectionBackgroundStyle: CylSectionBackgroundStyle.liquidGlass, // flat by default
      tintColor: '#007AFF',
    },
    sections: [{ title: 'Reviews', items: [{ title: 'All' }, { title: 'Positive' }] }],
  }}
/>
```


## Header

The section header keys go in the configuration's `style` (typed in `CylTagListConfiguration`):

- `headerMaxLines`: the line limit of a section header title. Default single (1): one line, truncated, the header exactly
  `headerHeight` high. A number above 1 or `CylTagTitleMaxLinesUnlimited` wraps the title and the header grows taller.
- `headerHeight`: the header's height (default 36). On a card with no header divider and no `headerHeight` set, the header is
  sized to its text; a `headerHeight` you set is then the minimum.
- `sectionBoardInset`: how far the board (card, header band and divider) extends beyond the tag column on the leading and
  trailing sides. `0` makes the board's edges coincide with the tags' edges; left out, the board keeps the 12 of
  `sectionContentInsets`. `0` is a set value, so send it as `0`, not `undefined`.
- `headerTextColor`, `headerFont`, `foldControlColor`: the header title color and font and the More / Less color.
- Fold content: `foldControl: { position: 'headerTrailing', content: CylFoldControlContent.titleAndIconAlways }` shows the
  title and the chevron in both states ("More v" folded, "Less ^" expanded). `rotatesImageWhenExpanded` (default true) turns
  the icon 180 degrees when expanded; `false` keeps it still. `image` and `font` replace the chevron and the title font.
  An object `foldControl` without `content` shows the icon only; a bare position string picks the content that suits it (the
  footer shows the icon only, the tail too on Android, a header shows `iconAndTitle`).

## Glass rules

- A tag has no default border, glass tags included. A border shows only when `borderColor` / `borderWidth` is set (in
  `style.normal` / `selected` / `disabled`, or in an item's own `style`).
- The explicit color decides: a `textColor`, `iconColor`, `backgroundColor` or `borderColor` you set is used as given; the tag
  has no contrast code of its own.
- Dark-glass adaptation is done by the shared item, not the tag: on drawn dark glass it adapts explicit and built-in colors
  (title 4.5:1, icon 3:1 contrast). Light mode and flat tags never change. Details: `docs/tag-liquid-glass.md`.

## Native version

TODO: state the minimum native version that reads `headerMaxLines`, `headerHeight`, `sectionBoardInset` and
`rotatesImageWhenExpanded` (the CollectionViewClassifyMenu pod and the `com.cyl:classifymenu` AAR) once it is released. No
version is pinned here yet; until then an older native list ignores these keys.
