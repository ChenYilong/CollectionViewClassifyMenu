# HarmonyOS NEXT: CYLTagListView

- `classifymenu/`: the ArkTS library (HAR): `CYLTagListView`, its JSON configuration, animated icons,
  `animationSpeed`, `animationLoops` and `CYLTagListController.playAll()`. A tag's animated icon is
  CYLTabBarController's shared component `CYLAnimatedItemView` (`CYLTagAnimatedIcon`); the library depends on no
  animation library.
- `cylanimateditem/`: that component, an unmodified copy of CYLTabBarController's
  `CrossPlatform/harmonyos-cyltabbar/cylanimateditem` at commit `57a527e` (its own MIT license;
  `cylanimateditem/README.md`), registered in `build-profile.json5` and depended on with `file:` until it is published
  to ohpm.
- `entry/`: the example (Tags with the playback controls, Classify on the shared `cyl_places.sqlite`). It adds the
  animation libraries (Lottie `@ohos/lottie` 2.0.38, PAG `@tencent/libpag` 4.4.31, Rive `@ohos/rive` 1.0.4; GIF through
  ImageKit; SVGA 2.x through its own decoder in `entry/src/main/ets/animation/svga/`, checked without a device by
  `scripts/svga-decoder-test.sh`), registers them (`CYLAnimatedItemEngines.register(...)`) and supplies the views that
  play them (`CYLTagAnimationBuilder.register(...)`) in `entry/src/main/ets/animation/`.
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
