# Screenshots

Screenshots from CI/CD and local builds that have no feature document of their own. Images live in `assets/`.
Rules: AGENTS.md, "CI/CD and Example screenshots" (labels: platform, OS version, simulator / emulator version, platform
SDK version, repository version or commit URL, time taken; clear originals). Stitching (2026-11-18): one column, two
when taller than a phone screen; header, panel captions and footer in their own bands (AGENTS.md; `.agents/skills/cyl-screenshots/SKILL.md`).

| Screenshot | Platform | Environment | Commit | Taken |
| --- | --- | --- | --- | --- |
| <img src="assets/ios-demo-tabbar-raised-plus.png" width="360" alt="iOS demo tab bar: Classify, the raised plus button (About), Filter"> Tab bar: one tab per feature, raised plus button | iOS | macOS 27.3, Xcode 27.2 (27B5028f), iPhone 17 Pro simulator, iOS 27.2 (24B8117), CYLTabBarController `53766de` | `feat/android-kotlin` (the commit adding this row) | 2026-11-12 19:20 NZDT |
| <img src="assets/ios-demo-classify-tab.png" width="300" alt="iOS demo Classify tab"> Classify tab: single-choice classify menu only | iOS | as above | as above | 2026-11-12 19:20 NZDT |
| <img src="assets/ios-demo-filter-tab.png" width="300" alt="iOS demo Filter tab"> Filter tab: the filter button, Reset filters, the 83 places of the demo data | iOS | as above | as above | 2026-11-12 19:25 NZDT |
| <img src="assets/ios-demo-filter-panel.png" width="300" alt="iOS demo filter panel"> Filter tab: the panel slides in from the left over most of the screen; Reset / Apply above the home indicator | iOS | as above | as above | 2026-11-12 19:20 NZDT |
| <img src="assets/android-filter-panel.png" width="300" alt="Android filter panel"> Android Filter tab (details in [android.md](android.md)) | Android | Android 15 (API 35) emulator `CYL_API35_arm64`, compileSdk 35 | `d12f101` | 2026-11-12 18:35 NZDT |

## iOS: every example screen (2026-11-17)

- **Platform:** iOS, `Example/CYLMenuExample` (Swift) and the pure Swift `Example-Swift/CYLTagEditorExample` (`swift-*`).
- **Environment:** macOS 27.3, Xcode 27.2, simulator "CYL ClassifyMenu iOS" (iPhone 17 Pro, iOS 27.2), clean status bar.
- **Commit:** `333b349` (`feat/harmony`), CYLTabBarController / CYLAnimatedItem pinned at `57a527e`.
- **Taken:** 2026-11-17 22:30–22:55 NZDT with `scripts/example-screenshots.sh "CYL ClassifyMenu iOS"` (one launch per
  screen, `-CYLExampleScreen <screen>`); `product@zh-Hans` retaken at 22:53 (the first capture showed the previous app's
  last frame, fixed in the script).
- **Checked:** every animated icon draws (Lottie, PAG, Rive, SVGA, GIF), English and Traditional Chinese screens are
  translated, `style-title-uncentered` is the title-only style (no icons by design).

| Screen | Screenshot |
|:---|:---|
| `animations-rive@zh-Hans` | <img src="assets/ios-1117/animations-rive@zh-Hans.png" width="200" alt="iOS animations-rive@zh-Hans"> |
| `animations-speed@zh-Hans` | <img src="assets/ios-1117/animations-speed@zh-Hans.png" width="200" alt="iOS animations-speed@zh-Hans"> |
| `animations-svga@zh-Hans` | <img src="assets/ios-1117/animations-svga@zh-Hans.png" width="200" alt="iOS animations-svga@zh-Hans"> |
| `animations@en` | <img src="assets/ios-1117/animations@en.png" width="200" alt="iOS animations@en"> |
| `animations@zh-Hans` | <img src="assets/ios-1117/animations@zh-Hans.png" width="200" alt="iOS animations@zh-Hans"> |
| `config@zh-Hans` | <img src="assets/ios-1117/config@zh-Hans.png" width="200" alt="iOS config@zh-Hans"> |
| `plus-discover-expanded@en` | <img src="assets/ios-1117/plus-discover-expanded@en.png" width="200" alt="iOS plus-discover-expanded@en"> |
| `plus-discover-expanded@zh-Hans` | <img src="assets/ios-1117/plus-discover-expanded@zh-Hans.png" width="200" alt="iOS plus-discover-expanded@zh-Hans"> |
| `plus-discover-refreshed@zh-Hans` | <img src="assets/ios-1117/plus-discover-refreshed@zh-Hans.png" width="200" alt="iOS plus-discover-refreshed@zh-Hans"> |
| `plus-discover@en` | <img src="assets/ios-1117/plus-discover@en.png" width="200" alt="iOS plus-discover@en"> |
| `plus-discover@zh-Hans` | <img src="assets/ios-1117/plus-discover@zh-Hans.png" width="200" alt="iOS plus-discover@zh-Hans"> |
| `plus-discover@zh-Hant` | <img src="assets/ios-1117/plus-discover@zh-Hant.png" width="200" alt="iOS plus-discover@zh-Hant"> |
| `plus-menu-filtered@en` | <img src="assets/ios-1117/plus-menu-filtered@en.png" width="200" alt="iOS plus-menu-filtered@en"> |
| `plus-menu-filtered@zh-Hans` | <img src="assets/ios-1117/plus-menu-filtered@zh-Hans.png" width="200" alt="iOS plus-menu-filtered@zh-Hans"> |
| `plus-menu@zh-Hans` | <img src="assets/ios-1117/plus-menu@zh-Hans.png" width="200" alt="iOS plus-menu@zh-Hans"> |
| `plus-reviews-db@zh-Hans` | <img src="assets/ios-1117/plus-reviews-db@zh-Hans.png" width="200" alt="iOS plus-reviews-db@zh-Hans"> |
| `plus@en` | <img src="assets/ios-1117/plus@en.png" width="200" alt="iOS plus@en"> |
| `plus@zh-Hans` | <img src="assets/ios-1117/plus@zh-Hans.png" width="200" alt="iOS plus@zh-Hans"> |
| `product@en` | <img src="assets/ios-1117/product@en.png" width="200" alt="iOS product@en"> |
| `product@zh-Hans` | <img src="assets/ios-1117/product@zh-Hans.png" width="200" alt="iOS product@zh-Hans"> |
| `reviews-expanded@en` | <img src="assets/ios-1117/reviews-expanded@en.png" width="200" alt="iOS reviews-expanded@en"> |
| `reviews-expanded@zh-Hans` | <img src="assets/ios-1117/reviews-expanded@zh-Hans.png" width="200" alt="iOS reviews-expanded@zh-Hans"> |
| `reviews-multi@zh-Hans` | <img src="assets/ios-1117/reviews-multi@zh-Hans.png" width="200" alt="iOS reviews-multi@zh-Hans"> |
| `reviews-network@zh-Hans` | <img src="assets/ios-1117/reviews-network@zh-Hans.png" width="200" alt="iOS reviews-network@zh-Hans"> |
| `reviews@zh-Hans` | <img src="assets/ios-1117/reviews@zh-Hans.png" width="200" alt="iOS reviews@zh-Hans"> |
| `search-gossip@zh-Hans` | <img src="assets/ios-1117/search-gossip@zh-Hans.png" width="200" alt="iOS search-gossip@zh-Hans"> |
| `search-home@zh-Hans` | <img src="assets/ios-1117/search-home@zh-Hans.png" width="200" alt="iOS search-home@zh-Hans"> |
| `search-jobs@en` | <img src="assets/ios-1117/search-jobs@en.png" width="200" alt="iOS search-jobs@en"> |
| `search-jobs@zh-Hans` | <img src="assets/ios-1117/search-jobs@zh-Hans.png" width="200" alt="iOS search-jobs@zh-Hans"> |
| `search@zh-Hans` | <img src="assets/ios-1117/search@zh-Hans.png" width="200" alt="iOS search@zh-Hans"> |
| `search@zh-Hant` | <img src="assets/ios-1117/search@zh-Hant.png" width="200" alt="iOS search@zh-Hant"> |
| `style-custom@zh-Hans` | <img src="assets/ios-1117/style-custom@zh-Hans.png" width="200" alt="iOS style-custom@zh-Hans"> |
| `style-gif@zh-Hans` | <img src="assets/ios-1117/style-gif@zh-Hans.png" width="200" alt="iOS style-gif@zh-Hans"> |
| `style-icon-only@zh-Hans` | <img src="assets/ios-1117/style-icon-only@zh-Hans.png" width="200" alt="iOS style-icon-only@zh-Hans"> |
| `style-lottie@zh-Hans` | <img src="assets/ios-1117/style-lottie@zh-Hans.png" width="200" alt="iOS style-lottie@zh-Hans"> |
| `style-pag@zh-Hans` | <img src="assets/ios-1117/style-pag@zh-Hans.png" width="200" alt="iOS style-pag@zh-Hans"> |
| `style-rive@zh-Hans` | <img src="assets/ios-1117/style-rive@zh-Hans.png" width="200" alt="iOS style-rive@zh-Hans"> |
| `style-svga@zh-Hans` | <img src="assets/ios-1117/style-svga@zh-Hans.png" width="200" alt="iOS style-svga@zh-Hans"> |
| `style-title-uncentered@zh-Hans` | <img src="assets/ios-1117/style-title-uncentered@zh-Hans.png" width="200" alt="iOS style-title-uncentered@zh-Hans"> |
| `style@en` | <img src="assets/ios-1117/style@en.png" width="200" alt="iOS style@en"> |
| `style@zh-Hans` | <img src="assets/ios-1117/style@zh-Hans.png" width="200" alt="iOS style@zh-Hans"> |
| `swift-editor-bottom@zh-Hans` | <img src="assets/ios-1117/swift-editor-bottom@zh-Hans.png" width="200" alt="iOS swift-editor-bottom@zh-Hans"> |
| `swift-editor-created@zh-Hans` | <img src="assets/ios-1117/swift-editor-created@zh-Hans.png" width="200" alt="iOS swift-editor-created@zh-Hans"> |
| `swift-editor-new@zh-Hans` | <img src="assets/ios-1117/swift-editor-new@zh-Hans.png" width="200" alt="iOS swift-editor-new@zh-Hans"> |
| `swift-editor-search@en` | <img src="assets/ios-1117/swift-editor-search@en.png" width="200" alt="iOS swift-editor-search@en"> |
| `swift-editor-search@zh-Hans` | <img src="assets/ios-1117/swift-editor-search@zh-Hans.png" width="200" alt="iOS swift-editor-search@zh-Hans"> |
| `swift-editor@en` | <img src="assets/ios-1117/swift-editor@en.png" width="200" alt="iOS swift-editor@en"> |
| `swift-editor@zh-Hans` | <img src="assets/ios-1117/swift-editor@zh-Hans.png" width="200" alt="iOS swift-editor@zh-Hans"> |
| `swift-remark@zh-Hans` | <img src="assets/ios-1117/swift-remark@zh-Hans.png" width="200" alt="iOS swift-remark@zh-Hans"> |
| `swift-styles-config@en` | <img src="assets/ios-1117/swift-styles-config@en.png" width="200" alt="iOS swift-styles-config@en"> |
| `swift-styles-config@zh-Hans` | <img src="assets/ios-1117/swift-styles-config@zh-Hans.png" width="200" alt="iOS swift-styles-config@zh-Hans"> |
| `swift-styles-expanded@zh-Hans` | <img src="assets/ios-1117/swift-styles-expanded@zh-Hans.png" width="200" alt="iOS swift-styles-expanded@zh-Hans"> |
| `swift-styles@en` | <img src="assets/ios-1117/swift-styles@en.png" width="200" alt="iOS swift-styles@en"> |
| `swift-styles@zh-Hans` | <img src="assets/ios-1117/swift-styles@zh-Hans.png" width="200" alt="iOS swift-styles@zh-Hans"> |

## iOS: SVGA animated icons (2026-11-17)

SVGA wherever Rive is shown (`example-demo-rules.md`, "SVGA wherever Rive is shown"): the Animated icons screen's two
SVGA sections (CYLTabBarController's SVGA tab icons, then on `icons.riv`'s dark tags) and the Styles screen with the
SVGA action. Originals from the CI run, unchanged.

- **Platform:** iOS (`Example/CYLMenuExample`, Swift).
- **Environment:** GitHub Actions `macos-26-arm64`, Xcode 26.6, iPhone 17 Pro simulator (the iOS 26 runtime of that
  Xcode); CYLTabBarController `b5a02862` with `pod 'CYLTabBarController/SVGA'` (SVGAPlayerLite).
- **Repository:** [`a6cdd69`](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/a6cdd69), CI run
  [43992497583](https://github.com/ChenYilong/CollectionViewClassifyMenu/actions/runs/43992497583) (all 9 jobs passed),
  screenshots on `ci-screenshots` under `feat-harmony/2444bc8/`.
- **Taken:** 2026-11-17 01:36 UTC.

| Screen | Screenshot |
| --- | --- |
| Animated icons, `animations-svga`: "SVGA · pod 'CYLTabBarController/SVGA'" (首页 selected, 搜索, 消息, 我的) and "SVGA · 深色标签" (动态 selected, 列表, 首页) | <img src="assets/ios-animations-svga.png" width="300" alt="iOS Animated icons screen, SVGA sections"> |
| Styles, `style-svga`: the preview tags with the SVGA icons (home and profile, alternating; the disabled tag dimmed) | <img src="assets/ios-style-svga.png" width="300" alt="iOS Styles screen with SVGA icons"> |

## HarmonyOS: every demo (2026-11-16)

The 22-demo HarmonyOS example (`harmony/entry`) on a new dedicated emulator, taken by `harmony/scripts/screenshots.sh`
(launch options open each screen; `en-`, `zh-hant-` and `dark-` rows set the language or the color mode). Rows with a
defect are TODO in [harmony-verification.md](harmony-verification.md) (B1, B9, B11, B12). Stacked top to bottom.

| Screenshot | Platform | Environment | Commit | Taken |
| --- | --- | --- | --- | --- |
| <img src="assets/harmonyos-root.jpeg" width="300" alt="HarmonyOS root"> `root` — defect: the screen renders, but the Chinese tab titles are cut off ("场景一：评价筛", "场景二：搜索分"); English fits | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-en-root.jpeg" width="300" alt="HarmonyOS en-root"> `en-root` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-dark-root.jpeg" width="300" alt="HarmonyOS dark-root"> `dark-root` — defect: the screen renders, but the Chinese tab titles are cut off ("场景一：评价筛", "场景二：搜索分"); English fits | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-product.jpeg" width="300" alt="HarmonyOS product"> `product` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-reviews-memory.jpeg" width="300" alt="HarmonyOS reviews-memory"> `reviews-memory` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-reviews-network.jpeg" width="300" alt="HarmonyOS reviews-network"> `reviews-network` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-reviews-database.jpeg" width="300" alt="HarmonyOS reviews-database"> `reviews-database` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-search-home.jpeg" width="300" alt="HarmonyOS search-home"> `search-home` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-search-category.jpeg" width="300" alt="HarmonyOS search-category"> `search-category` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-search-category-page.jpeg" width="300" alt="HarmonyOS search-category-page"> `search-category-page` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-search-discover.jpeg" width="300" alt="HarmonyOS search-discover"> `search-discover` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-query-scenarios.jpeg" width="300" alt="HarmonyOS query-scenarios"> `query-scenarios` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-menu-linkage.jpeg" width="300" alt="HarmonyOS menu-linkage"> `menu-linkage` — defect: the category headers (吃喝玩逛) render as large blurred, stretched images instead of their titles, and several tags as teal wedges; the SQL and the 83 results are right | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-styles.jpeg" width="300" alt="HarmonyOS styles"> `styles` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-zh-hant-styles.jpeg" width="300" alt="HarmonyOS zh-hant-styles"> `zh-hant-styles` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-animations.jpeg" width="300" alt="HarmonyOS animations"> `animations` — defect: in Chinese (and dark mode) the Lottie, PAG and Rive rows show no tags, only empty rows; in English every animated tag renders | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-en-animations.jpeg" width="300" alt="HarmonyOS en-animations"> `en-animations` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-dark-animations.jpeg" width="300" alt="HarmonyOS dark-animations"> `dark-animations` — defect: in Chinese (and dark mode) the Lottie, PAG and Rive rows show no tags, only empty rows; in English every animated tag renders | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-configuration.jpeg" width="300" alt="HarmonyOS configuration"> `configuration` — defect: renders, but the fourth chip of the dictionary row is empty; the log shows `NapiDefineClass occur exception, className:JPAGImageView` (PAG) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-cloud.jpeg" width="300" alt="HarmonyOS tag-cloud"> `tag-cloud` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-cloud-sample.jpeg" width="300" alt="HarmonyOS tag-cloud-sample"> `tag-cloud-sample` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-cloud-sub.jpeg" width="300" alt="HarmonyOS tag-cloud-sub"> `tag-cloud-sub` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-cloud-list.jpeg" width="300" alt="HarmonyOS tag-cloud-list"> `tag-cloud-list` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-cloud-recycler.jpeg" width="300" alt="HarmonyOS tag-cloud-recycler"> `tag-cloud-recycler` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-hot-search.jpeg" width="300" alt="HarmonyOS hot-search"> `hot-search` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-image-tag-sample.jpeg" width="300" alt="HarmonyOS image-tag-sample"> `image-tag-sample` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-image-tag-edit.jpeg" width="300" alt="HarmonyOS image-tag-edit"> `image-tag-edit` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-image-tag-list.jpeg" width="300" alt="HarmonyOS image-tag-list"> `image-tag-list` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-container.jpeg" width="300" alt="HarmonyOS tag-container"> `tag-container` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `b1d3724` | 2026-11-16 14:36–14:41 NZDT |

## HarmonyOS: pushed pages (2026-11-16)

Reached by tapping controls found by their text or accessibility text (AGENTS.md, accessibility-first UI driving), from
the root tab bar or a demo opened by launch option. Stacked top to bottom.

| Screenshot | Platform | Environment | Commit | Taken |
| --- | --- | --- | --- | --- |
| <img src="assets/harmonyos-push-reviews-all.jpeg" width="300" alt="HarmonyOS reviews-all"> root → "查看更多评价" (See all reviews): the review list, memory mode | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `6081884` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-search-tab.jpeg" width="300" alt="HarmonyOS search-tab"> root → tab "场景二：搜索分类" (Scenario 2) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `6081884` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-styles-tab.jpeg" width="300" alt="HarmonyOS styles-tab"> root → tab "样式" (Styles) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `6081884` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-animations-tab.jpeg" width="300" alt="HarmonyOS animations-tab"> root → tab "动效" (Animations): the animated tags render in Chinese on this route | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `6081884` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-image-tag-list.jpeg" width="300" alt="HarmonyOS image-tag-list"> image tag sample → "标签列表" (Tag list) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `6081884` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-tag-cloud-list-view.jpeg" width="300" alt="HarmonyOS tag-cloud-list-view"> tag cloud sample → "列表视图" (List view) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `6081884` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-query-reviews-database.jpeg" width="300" alt="HarmonyOS query-reviews-database"> query scenarios → "评价筛选 · 数据库（SQLite）" (Review filter · database): the review list in database mode, its SQL shown | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `7c4c294` | 2026-11-16 15:07–15:09 NZDT |
| <img src="assets/harmonyos-push-query-menu-linkage.jpeg" width="300" alt="HarmonyOS query-menu-linkage"> query scenarios → "分类菜单 + 多选筛选 · 数据库联动" (Classify menu + multiple filter): the menu linkage page (retaken 10:36 after `5dc703b`: the fold arrows were oversized before) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `7c4c294` | 2026-11-16 15:07–15:09 NZDT |
| <img src="assets/harmonyos-push-query-search-discover.jpeg" width="300" alt="HarmonyOS query-search-discover"> query scenarios → "最近搜索 + 发现" (Recent searches + discover) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `7c4c294` | 2026-11-16 15:07–15:09 NZDT |
| <img src="assets/harmonyos-push-image-tag-create.jpeg" width="300" alt="HarmonyOS image-tag-create"> image tag sample → "创建标签" (Create tags): the edit page with its steps | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `7c4c294` | 2026-11-16 15:07–15:09 NZDT |
| <img src="assets/harmonyos-push-tag-cloud-recycler-view.jpeg" width="300" alt="HarmonyOS tag-cloud-recycler-view"> tag cloud sample → "回收视图" (RecyclerView example) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `7c4c294` | 2026-11-16 15:07–15:09 NZDT |
| <img src="assets/harmonyos-push-tag-cloud-result.jpeg" width="300" alt="HarmonyOS tag-cloud-result"> tag cloud sample → "页面返回结果" (Page result): the sub-page that returns a tag | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `7c4c294` | 2026-11-16 15:07–15:09 NZDT |

Not documented as pages, because the tap changed nothing on screen (reported to the port's owner, TODO): the plus
button (it exposes no accessibility text, only a description), the menu-linkage filter button (an image with neither
text nor description), the review filter "好评" (Good) and the search category "找人" (People).

Second batch (2026-11-16 15:07–15:09): the review filter, retried with its real label "好评(9)" (Good), still leaves
"全部" (All) selected with 10 matches (reported, TODO). Taps on a product review tag ("质量不错(5)"), a hot-search tag
("小西瓜"), a search-category tag ("腾讯工程师") and the tag-cloud "可删除" (Deletable) tag showed no new page; whether
the iOS example opens one there is not checked yet.

### Pushed pages after the port's fixes (2026-11-16 10:26–10:31 emulator time)

| Screenshot | Platform | Environment | Commit | Taken |
| --- | --- | --- | --- | --- |
| <img src="assets/harmonyos-push-plus-page.jpeg" width="300" alt="HarmonyOS plus-page"> root → the plus button: its page "查询筛选" (Query filter), after `95bebc1` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `bb9e562` | 2026-11-16 15:26–15:31 NZDT |
| <img src="assets/harmonyos-push-product-tag.jpeg" width="300" alt="HarmonyOS product-tag"> product → review tag "质量不错(5)": the review list filtered to it, 5 matches (after `5dc703b`, as iOS) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `bb9e562` | 2026-11-16 15:26–15:31 NZDT |
| <img src="assets/harmonyos-push-reviews-good.jpeg" width="300" alt="HarmonyOS reviews-good"> review list → "好评(9)" (Good): 9 matches (after `5dc703b`) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `bb9e562` | 2026-11-16 15:26–15:31 NZDT |
| <img src="assets/harmonyos-push-hot-search-tag.jpeg" width="300" alt="HarmonyOS hot-search-tag"> hot search → "小西瓜": the search field takes the tag (after `5dc703b`) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `bb9e562` | 2026-11-16 15:26–15:31 NZDT |
| <img src="assets/harmonyos-push-search-category-tag.jpeg" width="300" alt="HarmonyOS search-category-tag"> search category → "腾讯工程师": the search field takes the tag (after `5dc703b`) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `bb9e562` | 2026-11-16 15:26–15:31 NZDT |
| <img src="assets/harmonyos-push-menu-filter-sheet.jpeg" width="300" alt="HarmonyOS menu-filter-sheet"> menu linkage → filter button: the regions and dishes panel opens (after `95bebc1`), but under a gray dimming layer, so it looks blurred (TODO) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `bb9e562` | 2026-11-16 15:26–15:31 NZDT |

## TODO (2026-11-18, `feat/harmony`): screenshot stitching rules (layout, header, footer, labels)

- **Prompt (verbatim)**: "找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：找到截图相关规范，如果没有就新建保证写入成功，截图除了 优先选用竖版排列风格。优先两列，多行。且给拼接好的图增加header，footer，header，footer不能与截图区域重叠 覆盖，标注关键信息：关键信息也是英文，测试模拟器平台，模拟器系统版本，操作系统版本，ide 版本，以及测试目的等等。以附带的截图为例。提取截图的附带信息以及风格 完善我的描述规则。"
- **English**: find this project's instruction files and skill files (create them if missing) and write, in English only,
  the screenshot rules (create them if missing): stitched screenshots prefer a portrait layout, two columns and
  several rows; every stitched image gets a header and a footer that never overlap or cover the screenshot areas; they
  carry the key information in English: the simulator platform, the simulator OS version, the host OS version, the IDE
  version, the test purpose and so on. Use the attached screenshot (`assets/ios-rive-rest.png`) as the example: extract
  its information and style and complete the rules.
- **Plan**: AGENTS.md (the screenshot rules), docs/instructions.md, scripts/instructions.md, a new skill
  `.agents/skills/cyl-screenshots/SKILL.md` (linked from `cyl-verify`), and `scripts/stitch-screenshots.swift`, which
  lays the images out by these rules; redo the example with it.
- **Result (2026-11-18)**: DONE. Rules appended to AGENTS.md ("Screenshots: stitching layout, update", "Screenshots:
  header and footer"), `instructions.md` (this folder), `../scripts/instructions.md`; new skill
  `.agents/skills/cyl-screenshots/SKILL.md`, linked from `cyl-verify`; new tool `../scripts/stitch-screenshots.swift`.
  Example redone by the rules:

  ![iOS Rive icons rest until played, then play and loop: 2 x 2 grid with header and footer](assets/ios-rive-rest-then-play-grid.png)

## TODO (2026-11-18, `feat/harmony`): one column first, two columns when one column is taller than a phone screen

- **Prompt (verbatim)**: "更新截图规则，优选一列多行 如果一列拼接后长度超过普通手机的一屏幕 则两列多行"
- **English**: update the screenshot rules: prefer one column with several rows; if the one-column stitch is longer
  than one screen of an ordinary phone, use two columns with several rows.
- **Plan**: append the update to AGENTS.md, `instructions.md`, `../scripts/instructions.md` and the `cyl-screenshots`
  skill; `scripts/stitch-screenshots.swift` picks the columns by this rule by default (`--columns auto`).
- **Result (2026-11-18)**: DONE. AGENTS.md "Screenshots: columns, update", `instructions.md`, `../scripts/instructions.md`
  and the `cyl-screenshots` skill updated; `scripts/stitch-screenshots.swift` chooses one or two columns by the rule
  (`--columns auto`, the default). One column (two cropped panels, 1148 x 1081 px):

  ![iOS Rive icons at rest, one column with header and footer](assets/ios-rive-rest-one-column.png)

## TODO (2026-11-18, `feat/harmony`): remove the screenshot label check from CI

- **Prompt (verbatim)**: "Remove label CI screenshots from ci"
- **English**: remove the screenshot label check from CI.
- **Plan**: delete `.github/workflows/screenshot-labels.yml`; keep the check before every commit
  (`scripts/check-branch-pr.sh` runs `scripts/check-screenshots.py`); update AGENTS.md and the comments that say "in
  CI". CYLTabBarController did the same (`70064275`).
- **Result (2026-11-18)**: DONE. `.github/workflows/screenshot-labels.yml` removed; AGENTS.md "Checked before every
  commit" and the comments of `scripts/stitch-screenshots.py`, `.swift` and `check-screenshots.py` no longer mention
  CI. The check before every commit (`scripts/check-branch-pr.sh`) stays.
