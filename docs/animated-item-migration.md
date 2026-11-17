# CYLAnimatedItem migration: progress against the guide

The guide: CYLTabBarController's
[docs/Animated-Item.md](https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md)
(branch `feat/cross-platform-components`, read at `e3ebc242`, 2026-11-17). It asks this repository to make its icon + title
component, `CYLTagButton`, a subclass of the shared `CYLAnimatedItemView` (row "CollectionViewClassifyMenu" of "Migrating
the four repositories"), with the core depending on `CYLAnimatedItem` and on no animation engine; only the examples add
engines. Every icon + title view of this repository is already a `CYLTagButton` (`CYLIndexPathButton`,
`CYLRightImageButton`, the section headers, the search bar items of CYLSearchViewController), so one class carries the
migration on each platform.

Related logs: [component-architecture.md](component-architecture.md) (the task entries, newest at the end),
[issue-progress.md](issue-progress.md), [example-layer-fixes.md](example-layer-fixes.md).

## Task log

- **TODO → DONE (2026-11-17)**: report the progress against the guide and mark progress and TODOs in this repository.
  - **Prompt (verbatim)**: "告诉我 你遵循文档改造的进度，并在本仓库合适地方标注进度以及todo。这个文档是与动效组件相关的。告诉我 你遵循文档改造的进度https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md"
  - **Prompt (English)**: "Tell me your progress following the document's migration, and mark the progress and TODOs in a suitable place in
    this repository. The document is about the animation component."
  - **Result**: this document (the table, the score and the TODO list below), linked from `component-architecture.md` and
    `issue-progress.md`.

## Score

**Score: 84** (21 of 25 rows done, row 17 half done; a row counts only when it is done and verified as far as this environment allows).

| Date | Score | Note |
|:---|:---|:---|
| 2026-11-18 | 84 | Row 22: Flutter and React Native Android builds; the publish step no longer deletes the library |
| 2026-11-17 | 80 | Row 13 verified on a Mac (library 0 warnings, 152 tests pass); row 12 compiles with Xcode 27 but not in CI (Xcode 26) |
| 2026-11-17 | 76 | Row 20: WeChat DevTools check, the missing-tags bug fixed; row 17: HarmonyOS build and host tests |
| 2026-11-17 | 72 | First assessment, at `d979073` (pins `57a527e`; CYLTabBarController PR #815 open) |

## Progress by guide item

| # | Guide item | Platform | Status | Evidence / what is left |
|:---|:---|:---|:---|:---|
| 1 | `CYLTagButton` subclasses `CYLAnimatedItemView` | iOS | Done | `CYLTagButton.swift:44` (`1813025`) |
| 2 | Delete `CYLTagAnimationEngine` (run-time engine lookup) | iOS | Done | no occurrence left in the sources |
| 3 | Icon, title and animation properties are the inherited ones | iOS | Done | `1813025`; Objective-C sees them through redeclarations (`d3efc5f`) |
| 4 | Delete indicator → `accessoryView` / `accessoryPlacement` | iOS | Done | `CYLTagButton.swift:260`, `:320` |
| 5 | Per-state look in `itemStateDidChange` | iOS | Done | `CYLTagButton.swift:578` |
| 6 | Static measuring stays in the subclass (`width(forTitle:…)`) | iOS | Done | kept in `CYLTagButton` |
| 7 | Podspec depends on `CYLAnimatedItem` only, no engine | iOS | Done | `CollectionViewClassifyMenu.podspec:46`; `pod lib lint` green (CI on `71562ca`) |
| 8 | Examples add `CYLAnimatedItem/<Type>` by `:git` + `:commit` | iOS | Done | `Example/Podfile` (LottieObjectiveC, PAG, Rive, SVGA, GIF), `CYL_ANIMATED_ITEM` = `57a527e` |
| 9 | `import CYLAnimatedItem`, never CYLTabBarController, in the core | iOS | Done | `CYLTagButton.swift:24` (`@_exported`; falls back to `CYLTabBarController` only under SwiftPM, row 11) |
| 10 | Several engines: the example reports which are linked (multi-engine section) | iOS | Done | `CYLTagAnimationDemoViewController.engineReportLines()` (`b4d0e51`), test `testEveryLinkedEngineIsRegisteredAndListed` |
| 11 | Swift Package Manager: a separate `CYLAnimatedItem` product | iOS | TODO (upstream) | the guide's TODO 9: upstream SwiftPM still compiles the component into the `CYLTabBarController` product; owner's decision: "CocoaPods/Gradle now, SPM later" |
| 12 | Static-library demo app (`CollectionViewClassifyMenu.xcodeproj`) compiles | iOS | TODO | still "cannot inherit from class 'CYLClassifyMenuViewController' because it has overridable members that could not be loaded" (`CYLMainViewController.swift:20`) with the pins at `c8132d26` (run 44053520441 on `b4ed4cd`; swift, tag, example tests, library build and `pod lib lint` pass in the same run). Ruled out: the pins (pod install fetched `c8132d26`); CYLTabBarController's umbrella header importing the quoted `"CYLAnimatedItem/CYLAnimatedItemView.h"` (fixed upstream in `c8132d26`, no change); `@_exported import CYLAnimatedItem` (`b15b822`); the demo's own `import CYLAnimatedItem` (`880d9b1`); `:modular_headers => true` (`27c0394`); a bridging header (none). The `use_frameworks!` example with the same core passes. **Diagnostic (CI, `32b210e` + run 44069768349 on `0f1897c`)**: with deserialization recovery off the compiler stops at "Could not deserialize type for 'filterHeaderView(_:didTapMoreButton:)' / Caused by: Could not deserialize type for 'CYLRightImageButton'" (a class of this library, a `CYLTagButton` subclass); the deeper cause was cut off by the script's filter, fixed so the next menu run prints the whole chain. **Next (on a Mac, or from that chain)**: build the demo once with `OTHER_SWIFT_FLAGS='$(inherited) -Xfrontend -disable-deserialization-recovery'`, so the compiler names the member and the cross-reference it cannot load (suspects: `filterHeaderView(_:didTapMoreButton:)` and other members typed with a `CYLTagButton` subclass, whose superclass is `CYLAnimatedItem.CYLAnimatedItemView`) |
| 13 | Full iOS CI green (menu, example, swift tests, screenshots) | iOS | Done (local Mac) | 2026-11-17 at `0583e1d`: menu 32 / 0, tag 6 / 0, example 92 / 0, swift 22 / 0 failures; engine report screenshot `assets/ios-animation-engine-report.png` (test), `assets/ios-animations-live.png` (app). CI run still to confirm |
| 14 | `CYLTagButton` subclasses `CYLAnimatedItemView`, `onItemStateChanged`, `accessoryPlacement` | Android | Done | `android/merged/library/.../CYLTagButton.kt:44`, `:261`, `:364` |
| 15 | Depend on `cyltabbarcontroller-animateditem`, `:cylanimateditem` substitution by commit | Android | Done | `library/build.gradle.kts:41`, `settings.gradle.kts:69` |
| 16 | Tag button on `CYLAnimatedItemView` (`cylanimateditem`, `file:` at the pinned commit) | HarmonyOS | Done (code) | `1a8a80b` (other session): vendored `harmony/cylanimateditem`, engines moved to the example |
| 17 | HarmonyOS build and device check | HarmonyOS | Done (build, host tests); device check TODO | Windows with DevEco Studio 6.0.1 (2026-11-17, after `1a8a80b`): `harmony/scripts/build.sh` OK, `unit-test.sh` 58 / 58, `accessibility-check.py` OK, `check-native-strings.py` OK, `harmony_parity.py --check` OK (the 12 `CYLTagButton` members inherited from `CYLAnimatedItemView` removed from `parity-map.json`; the test's missing `$rawfile('icon.png')` fixed). The emulator check waits for disk space (the emulator needs about 20 GB free) |
| 18 | Tags on `cyl-animated-item` (copied at the pinned commit), engines as abstract nodes | Mini Program | Done | `62fce9b` (other session); `npm test` |
| 19 | GIF stills and one-pass play, `embedded`, `autoplay` in the mini program tags | Mini Program | TODO (upstream merge) | needs CYLTabBarController [PR #815](https://github.com/ChenYilong/CYLTabBarController/pull/815) (this session: `fe1978e0`, `3602ae67`, `ca6219a9`, `b51ac0ae`, `dc142479`; `npm test` 36); at `57a527e` a GIF tag loops with no stills and Play all cannot restart it |
| 20 | WeChat DevTools / device check | Mini Program | Done (DevTools); two bugs found, one fixed | WeChat DevTools 2.02.2609250 on Windows (2026-11-17), Build npm OK. (1) **Fixed**: no tag list rendered anywhere (product, reviews, Animations): DevTools' unused-file filter (`ignoreDevUnusedFiles`) dropped `cyl-animated-item/cyl_animated_item_model.js` ("module … is not defined", then "Component is not found in path …/cyl-tag-list"); `cyl-tag-list.js` and `cyl-tag-button.js` required it as `…_model.js` while the component requires `./cyl_animated_item_model`; both now use the extension-less path and the tags render (`assets/miniprogram-devtools-tags-missing.jpg`, `assets/miniprogram-devtools-tags-after-fix.jpg`). (2) **Root cause found, fixed upstream**: the animated icons drew far past their 20 px slot because CYLTabBarController's engine components (`cyl-lottie`, `cyl-pag`, `cyl-rive`, `cyl-svga`) fixed their `:host` at 100 × 100 px; with only that changed to fill the box, every icon sits in its tag (`assets/miniprogram-devtools-engines-overflow.jpg` before, `assets/miniprogram-devtools-engines-fill-fixed.jpg` after; `embedded` was not needed). Fix: CYLTabBarController [PR #817](https://github.com/ChenYilong/CYLTabBarController/pull/817) (bug log B7); merged; fixed here by the pin to `4635ef7b` (DevTools, `assets/miniprogram-devtools-tags-4635ef7b.jpg`: every icon in its tag, no example change). (3) **Fixed here**: `cyl-tag-list/model.js` had its own engine table without SVGA, so an SVGA tag (`…svga.bin`) got no animation URL and no icon; it now asks `cyl-animated-item`'s `cylAnimatedItemType()` (found by the CYLSearchViewController session). Re-vendored `cyl-animated-item` at `7b764c73` (B6: `*.svga.bin`, `animationType`, data URI placeholder) |
| 21 | Example Podfiles name `CYLAnimatedItem` (+ engines) | Flutter, React Native (iOS) | Done | `flutter/cyl_tag_list/example/ios/Podfile:40`, React Native example Podfile (`modular_headers`, `27c0394`) |
| 22 | Android source builds compile `:cylanimateditem` | Flutter, React Native (Android) | Done | Mac, 2026-11-18 at `0f1897c`: `flutter build apk --debug` (Flutter 3.47.9) and the React Native example's `gradlew :app:assembleDebug` (JDK 17) build against `com.cyl:classifymenu` + `cyltabbarcontroller-animateditem` from the merged library's `build/repo`; both APKs contain `com.cyl.classifymenu.CYLTagButton` and `CYLAnimatedItemView`. Fixed on the way: `publishAnimatedItemToBuildRepository` deleted `com/cyl/classifymenu` from `build/repo` (Gradle removes a copy task's stale outputs on its first run), so the hosts could not resolve the library; it now runs before the library's publication |
| 23 | License notice in every published package | All | Done | `scripts/check-licenses.sh` OK (vendored `cyl-animated-item` / `cylanimateditem` keep their LICENSE) |
| 24 | Pins: newest CYLTabBarController commit, by `:commit` | All | Done | `57a527e` everywhere; `scripts/cyl-tabbar-latest-commit.sh` now lists PR #815's tip (unmerged, CI only warns): move to its merge commit |
| 25 | No regression: Play all, speed, loop on every animation screen | All | Done (iOS, Android) | docs/example-demo-rules.md; mini program GIF waits for row 19; **mini program Rive section TODO (bug B20, below)**: some Rive tags play once, then neither loop nor Play all plays them |

## TODO (in order)

1. **CI**: since `53e3ea7` a started iOS run always finishes (`cancel-in-progress: false`); row 12 waits for the upstream umbrella-header fix and a pin move; then rows 12 and 13 (demo app, menu / example / swift
   tests, screenshots of the engine report screen into `docs/assets/`).
2. **Upstream merge of PR #815** (owner): then pins → the merge commit in this repository and CYLSearchViewController, and
   the mini program tags pass `gif-first-frame` / `gif-last-frame` / `gif-duration`, `embedded`, `autoplay` (row 19;
   agreed to be done by the CollectionViewClassifyMenu/CYLSearchViewController session).
3. **SwiftPM** (row 11): when CYLTabBarController ships a `CYLAnimatedItem` product, depend on it instead of
   `CYLTabBarController` in `Package.swift`.
4. **Toolchain checks**: HarmonyOS build and host tests done on Windows (row 17); its emulator check, WeChat DevTools
   (row 20) and the Flutter and React Native Android builds (row 22, no Flutter / Java / Gradle on that machine) remain.
5. **CYLTabBarController component APIs requested** (AGENTS.md "Bugs: record, screenshot, fix in CYLTabBarController's
   animated item"):
   - HarmonyOS `CYLAnimatedItemView`: an icon color for static bitmap icons (an alpha-preserving `ColorFilter`, as iOS
     template images). Meanwhile `CYLTagButton` (this repository's core) draws and tints its static icon itself
     (`64c6bc3`, emulator-verified with the `ColorFilter` object); it moves to the component's API once CYLTabBarController [PR #816](https://github.com/ChenYilong/CYLTabBarController/pull/816) (`CYLAnimatedItemView.iconColor`) is merged and the vendored `harmony/cylanimateditem` moves to that commit.
     Bug record: Y2 in `harmony-screenshot-issues.md`, screenshots `assets/harmonyos-y2-retest-icon-still-orange.jpeg`
     (before) and `assets/harmonyos-y2-fixed-white-icon.jpeg` (after).
   - Mini program `cyl-animated-item`: an embedded size (no 44 px minimum height or padding) and engine views that keep to
     the icon box; tracked as row 19 / CYLTabBarController PR #815 (`assets/miniprogram-devtools-tags-after-fix.jpg`).
6. **TODO, bug B20: Rive tags in the mini program play once, then stay static** (reported by the owner, 2026-11-18;
   recorded in CYLTabBarController `docs/Animated-Item.md` B20, [PR #820](https://github.com/ChenYilong/CYLTabBarController/pull/820)).
   Where: the mini program's Animations page (`pages/animations/animations`), section "Rive · pod 'CYLTabBarController/Rive'".
   Seen: with loop on, some Rive tags play once and never repeat; after that, Play all does not play them either.
   Screenshot: TODO. The section is below the fold and WeChat DevTools' `automation_*` tools (needed to scroll) do not
   connect from this machine's CLI (they ask for `wechatide auth`); `simulator_screenshot` covers only the viewport.
   Cause, read in `cyl-rive`'s `cyl_playFromStart` (to confirm in DevTools), per tag of `pages/animations/demo.js`:
   - 首页 `house` (state machine, no input): there is nothing to set and a state machine is never restarted, so it
     plays once on load and Play all does nothing; 形状 `shapes` / 卡车 `truck` (`legacy`, an option `cyl-rive` does not
     read) take the same path when the file has a state machine;
   - 菜单 `menu_button` (`input: isOpen`, `duration: 0`): 0 keeps the input on; it turns true once and never back to
     false, so the next Play all sets true again and nothing changes;
   - 完成 `check` (`triggerInput: Check`): fired on each play, but no loop path;
   - 按钮 `button` (linear animation `active`): `time = 0` on play; repeats only if the file's own loop type does.
   Fix in CYLTabBarController's `cyl-rive` (AGENTS.md "Bugs: record, screenshot, fix in CYLTabBarController's animated
   item"), not in the example: restart a state machine without input (a new `StateMachineInstance`), turn a held input
   off before setting it again, give triggers and linear animations a loop; then update the pins.

## TODO (2026-11-17, macOS 27 + Xcode 27, `feat/harmony`): rows 12 and 13 on a Mac, simulator screenshots, bugs

- **Prompt (verbatim)**: "运行模拟器 截图测试 更新文档 记录bug 修复bug  阅读CYLAnimatedItem 相关的集成文档，continue fix todo iOS端代码与测试"
- **Prompt (English)**: "Run the simulator, take screenshots and test, update the docs, record bugs, fix bugs; read the
  CYLAnimatedItem integration documents and continue fixing the iOS TODOs, code and tests."
- **Plan**: row 12 (build `CollectionViewClassifyMenu.xcodeproj`'s demo app), row 13 (menu, tag, example, swift tests;
  engine report screenshot into `docs/assets/`), record and fix what fails. CYLTabBarController's own iOS TODOs of the
  guide are taken by other sessions (91: Lottie URLs and the CYLTabBarController podspec lint; fe: the CYLAnimatedItem
  podspec lint and its demo screenshot; ba: FlatDesign item and SwiftPM / Carthage products).
- **Bug found (2026-11-17)**: `CYLSearchCategoryScenarioTests.testSearchCategoriesUseABottomTabBarAndFillTheSearchBar`
  fails only on the "iPhone Duo" simulator (iOS 27): the category tab bar is laid out at the top (y = 0). It fails at every
  commit since the test was added (`a2efda2`), so not a regression of the API parity work (`07cc52b`), and passes on an
  iPhone 17 Pro. `scripts/simulator-id.sh` picked "iPhone Duo" as the first iPhone of the newest runtime; it now prefers
  a regular "iPhone <number>" model. The tab bar placement on that form factor is TODO.
- **Bug fixed (2026-11-17, `0583e1d`)**: the example's test screenshots showed empty places instead of the animated icons
  (Lottie, PAG, Rive, SVGA, GIF), although the running app draws them (`assets/ios-animations-live.png`): the capture ran
  before the icons' first frame was drawn. `CYLScreenshotCapturing.captureScreenshot` now runs the main run loop for 0.5 s
  first (`assets/ios-animation-engine-report.png`). `CYLAnimatedIconTests` 8 / 0.
- **Results (2026-11-17)**: row 13 Done on the local Mac; row 12 compiles with Xcode 27 locally but still fails in CI with Xcode 26 (menu 32, tag 6, example 92, swift 22 tests, 0
  failures, on the "CYL ClassifyMenu iOS" iPhone 17 Pro simulator). Still TODO: the iPhone Duo tab bar placement (above).
- **Screenshots (2026-11-17, `333b349`)**: all 54 iOS example screens in [screenshots.md](screenshots.md) ("iOS: every example
  screen"), `assets/ios-1117/`. Bug fixed: `scripts/example-screenshots.sh` captured the previous app's last frame for the
  first screen of a run (`product@zh-Hans` showed the animations screen); it now waits 10 s more for the first launch.

## TODO (2026-11-17, `feat/harmony`): raise the migration score from 80

- **Prompt (verbatim)**: "fix The migration score stays at 80 / 100."
- **Plan**: rows this Mac can close: 17 (HarmonyOS check on the emulator `CYL ClassifyMenu Test`), 22 (Flutter and React
  Native Android builds with their toolchains); 19 if CYLTabBarController PR #815 is merged; 11 and 12 depend on upstream
  (SwiftPM product) and CI (Xcode 26).
- **Progress (2026-11-18, `0f1897c`)**: row 22 Done (score 84). Row 17: the emulator boots but hdc never connects
  (127.0.0.1:5563 refuses, `hw.hdc.port=notset`), so the device check is still TODO. Row 19: the pins (`fe5c3ae`) include
  PR #815's merge (`faf535e`); the mini program tags still have to pass `gif-first-frame` / `gif-last-frame` /
  `gif-duration`, `embedded`, `autoplay` (mini program code, coordinated with the Windows session). Rows 11 and 12 wait on
  upstream SwiftPM and on CI (Xcode 26).
