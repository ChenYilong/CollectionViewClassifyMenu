# HarmonyOS NEXT: CYLTagListView

- `classifymenu/`: the ArkTS library (HAR): `CYLTagListView`, its JSON configuration, animated icons,
  `animationSpeed`, `animationLoops` and `CYLTagListController.playAll()`. A tag's animated icon is
  CYLTabBarController's shared component `CYLAnimatedItemView` (`CYLTagAnimatedIcon`); the library depends on no
  animation library.
- `cylanimateditem/`: that component, an unmodified copy of CYLTabBarController's
  `CrossPlatform/harmonyos-cyltabbar/cylanimateditem` at commit `57a527e` (its own MIT license;
  `cylanimateditem/VENDORED.md`), registered in `build-profile.json5` and depended on with `file:` until it is published
  to ohpm.
- `cylanimateditem_lottie/`, `cylanimateditem_pag/`, `cylanimateditem_rive/`: CYLTabBarController's engine modules for Lottie
  (`@ohos/lottie` 2.0.38), PAG (`@tencent/libpag` 4.4.31) and Rive (`@ohos/rive` 1.0.4), vendored like `cylanimateditem`
  (which plays GIF and SVGA itself). Every player and engine fix lives there, in CYLTabBarController. `oh-package.json5`
  overrides `@tencent/libpag` to 4.4.31 (the PAG module accepts `^4.4.31`), so the HAP carries one libpag.
- `entry/`: the example (Tags with the playback controls, Classify on the shared `cyl_places.sqlite`). It registers the five
  engines (`cylRegisterExampleAnimationEngines()` in `entry/src/main/ets/animation/CYLExampleAnimationViews.ets`) and has
  no players of its own: every tag icon plays through `CYLAnimatedItemView`'s default engine view.
- `CYLTagAppearance.cornerRadius` is a plain number of points, limited to half the tag height (as on iOS and Android):
  `0` is square corners, a value of half the height or more (for example `1000`) is a capsule; `CYLTagCornerRadiusSquare`
  is removed. The presets keep their looks (`tagCloud()` uses `1000`; `filterTag()` and `sectionTitle()` use `0`).
- Build, tests and screenshots: `docs/android.md` (HarmonyOS NEXT).

## TODO: CYLAnimatedItemView migration (2026-11-17)

- Not compiled yet (no DevEco Studio / hvigor where it was written): build `classifymenu`, `cylanimateditem` and
  `entry` with `hvigorw assembleHap`, then check the animation screen on the emulator (every engine plays, Play all,
  speed, loop, the static image while loading and the placeholder for a type nobody registered).
- `CYLTagAnimatedIcon` disables the component (`enabled(false)`) so that the tag keeps its tap, long press and drag over
  the icon; confirm on a device that drag-to-reorder still starts on the icon.
- `CYLAnimatedItemView` draws a square icon and cannot draw a pixel map or a system symbol as the static image, and
  cannot play inline Lottie JSON (`cylAnimatedItemTypeOf` reads the extension); such tags show the placeholder.
- The React Native (`react-native/react-native-cyl-tag-list/harmony-example`) and Flutter (`flutter/cyl_tag_list_ohos`)
  HarmonyOS shells build `harmony/classifymenu` from source: they must register the `cylanimateditem` module too, and
  register engines and an animation builder to play animations.
- Publishing `@cyl/classifymenu` to ohpm needs `cylanimateditem` published first (the `file:` dependency).

## Bundled animation files

`entry/src/main/resources/rawfile/tab_*.json` are unmodified copies of CYLTabBarController's Lottie tab icons
(<https://github.com/ChenYilong/CYLTabBarController>, commit `4934a0c`, path
`Example/Classes/Other/LottieResources/`; license: CYLTabBarController's MIT license), the same files as the
Flutter and React Native examples.

| File | SHA-256 |
| --- | --- |
| `tab_home_animate.json` | `1cd3f6bcf2c87d38dd86ca1485fd6c9b7c645983241e1017bc4bca0bed9165b7` |
| `tab_me_animate.json` | `a1cc33e064d953af7c567f2fea2f45cc7374d8e35f52855066f83767c976dd6b` |
| `tab_message_animate.json` | `740dce5ae56b9b45902ca58e739e212724541d40dbb666f949a9e363402116db` |
| `tab_search_animate.json` | `81080fc0dc59c37d23b0c59c03a8fe42d63c8c29a93a5facc74c7d75fc345d37` |

`entry/src/main/resources/rawfile/svga/*.svga` are unmodified copies of CYLTabBarController's SVGA tab icons; source,
license (Apache License 2.0, via kongpf8848/Animation) and SHA-256 in `entry/src/main/resources/rawfile/svga/NOTICE.md`.

## Section card, header divider and tint (the default look changed)

A tag list now shows each section's tags on a rounded card by default (`sectionStyle` `insetGrouped`). If you never set
`backgroundColor`, the list background becomes the grouped background (#F2F2F7; black in dark mode). The header divider is
**off** by default. The header band (`headerBackgroundColor`) is off by default too.

Properties of `CYLMenuStyle` (`list.style`), or keys of the configuration's `style`:

- Remove the card: `style.sectionStyle = CYLSectionStyle.plain` (configuration `"sectionStyle": "plain"`).
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

```ts
import { CYLMenuStyle, CYLSectionStyle, CYLHeaderSeparatorStyle, CYLTagBackgroundStyle } from '@cyl/classifymenu';

const style: CYLMenuStyle = new CYLMenuStyle();
style.sectionStyle = CYLSectionStyle.plain;                 // remove the card (the old look)
style.headerSeparatorStyle = CYLHeaderSeparatorStyle.line;  // show the divider (off by default)
style.headerBackgroundColor = '#FFEFEFF4';                  // optional band
style.sectionBackgroundStyle = CYLTagBackgroundStyle.liquidGlass;
style.tintColor = '#FF007AFF';
```

Colors are ResourceColor values (a string '#AARRGGBB' or a `$r` resource); insets are `CYLEdgeInsets(top, left, bottom, right)` in vp.

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
