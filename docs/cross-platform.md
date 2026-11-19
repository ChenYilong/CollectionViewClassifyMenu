# Cross-platform consistency

The examples of this project on every platform (iOS, Android, and later React Native, Flutter, HarmonyOS, Mini
Program) show the same screens with the same data and look the same as iOS, which is the reference.

## TODO summary: Android, React Native and Flutter (2026-11-16)

Every open `TODO` found in the cross-platform documents (`cross-platform.md`, `android.md`, `example-demo-rules.md`,
`issue-progress.md`). Column 2 starts as `TODO`; when an item is done, its `TODO` is replaced by the result. Score:
100 when no `TODO` is left (score = done / total × 100).

| Found (document, item) | Status |
| --- | --- |
| `cross-platform.md`, Flutter limit (3): the example does not use the shared database `cyl_places.sqlite` | DONE (stale note): the Classify menu tab reads the bundled `cyl_places.sqlite` (section "the Flutter example's classify menu on the shared database", `classify_menu_test.dart`: 83 places) |
| `cross-platform.md`, Flutter limit (5): the Dart tests only run on the iOS simulator | DONE (stale note): `tag_list_test.dart` and `classify_menu_test.dart` pass on iOS 27.0 and the Android 15 emulator (same section) |
| `cross-platform.md`, Flutter limit (4): Swift Package Manager is not supported (the plugin needs the pod) | DONE (2026-11-16): root `Package.swift` (the core; `CYLMenuResources.bundle` returns `Bundle.module` under SwiftPM) and `flutter/cyl_tag_list/ios/cyl_tag_list/Package.swift`; with `enable-swift-package-manager` and the core pod removed from the Podfile, the example builds (the app holds `CollectionViewClassifyMenu_CollectionViewClassifyMenu.bundle`) and `flutter test integration_test` passes on the iPhone 17 Pro simulator: `All tests passed!` (2 tests). The example stays on CocoaPods by default; `CYLTagView` (TagCollectionView) is CocoaPods only |
| `cross-platform.md`, tag cells: React Native and Flutter look the same as iOS ("no example here yet") | DONE: both host the native list (Swift / Kotlin), so their cells are the native cells; screenshots in the sections below |
| `cross-platform.md`, React Native "Still TODO" notes (Android view, Classify page, tests) | DONE (stale notes): steps 3, 4 and 5 are DONE further down in the same section |
| `android.md`, HarmonyOS step 2: Flutter on HarmonyOS NEXT | DONE (2026-11-16, below): both integration tests pass on the HarmonyOS emulator (`All tests passed!`), sharp text, Lottie icons, Play all / speed / Loop reach the ArkTS list, Classify on the shared database (83 places) |
| `android.md`, HarmonyOS step 3: React Native on HarmonyOS NEXT (after Flutter) | DONE (2026-11-16, below): `react-native/react-native-cyl-tag-list/harmony-example` (RNOH 0.86.1) shows the native ArkTS list with Lottie icons; speed, Loop and selection events checked on the emulator |
| `example-demo-rules.md`, playback controls in the Mini Program example | DONE (another session, 2026-11-15): `CrossPlatform/wechat-miniprogram`, pages/animations, Play all, speed slider, Loop switch |

- **Flutter on HarmonyOS, progress (2026-11-16):** the example builds (`flutter build hap --debug`, Flutter
  `3.41.9+ohos-1.0.2`, DevEco SDK HarmonyOS 6.0.1 / API 21) and runs on the Mate 70 Pro emulator
  `6.0.0.112(SP3DEVC00E112R4P11)`, with the native ArkTS `CYLTagListView` inside Flutter (macOS 27.3, branch
  `feat/android-kotlin` at the commit that adds this, 2026-11-16 11:07 emulator time):

  <img src="assets/flutter-harmonyos-animated-icons.png" width="360" alt="Flutter on HarmonyOS: Animated icons screen, native tag list">

  How: the public OpenHarmony 6.1 SDK (API 23, SHA-256 checked) also lacks `autoFillManager.ViewData`, so it does not
  help. The Flutter embedding calls those APIs and `CompetitionStrategy` / `Window.isInFreeWindowMode` only behind
  run-time API checks (26 and 24), so a build-mirror-only patch makes them compile on API 21 without changing what
  runs: `flutter/cyl_tag_list_ohos/tool/patch_embedding_api21.py` (autofill helper), plus two one-line casts in
  `EmbeddingNodeController.ets` and `FlutterManager.ets` (`(0 as ESObject)`, `(mainWindow as ESObject)`). The
  generated `example/ohos` project (not in the repository) lists `harmony/classifymenu` as a module and a dependency.
  Fixed in the plugin: `Params` is imported from `@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView`.
  Fixed after the first run (same day):
  1. **Squashed, blurry text:** the plugin's ArkTS root was only as tall as its content, and the platform view
     draws the root's surface into its whole Flutter rectangle; the root now fills the view (`Scroll`, content
     height still reported).
  2. **No Lottie icons:** Flutter assets are rawfiles under `flutter_assets/`; the Dart plugin maps
     `asset:<key>` to `asset:flutter_assets/<key>`, and the core reads an `asset:` value as a full rawfile path first
     (then by its last component, as before).
  3. **Playback controls:** `playAll`, `setSpeed`, `setLoops` and `state` now drive the core's
     `CYLTagListController`, `animationSpeed` and `animationLoops` (they were no-ops).
  4. **Shared database:** the OpenHarmony sqflite port stores the file where `relationalStore` puts it, so the
     copied `cyl_places.sqlite` was not the file it opened (`no such table: places`); the example copies the bundled
     database to the file SQLite reports (`PRAGMA database_list`) when `places` is missing.
  5. **Speed type:** ArkTS has one number type, so `state()` returned `4` for `4.0`; the Dart controller returns a
     double on every platform.
  Tests: `flutter test integration_test -d 127.0.0.1:5557` (the mirror's Flutter tool accepts unsigned HAPs when
  `CYL_ALLOW_UNSIGNED=1`, a two-line mirror-only patch of `hvigor.dart` and `project.dart`):
  `classify_menu_test.dart` and `tag_list_test.dart`, `All tests passed!`. Screenshots (12:05 and 12:14 emulator
  time):

  <img src="assets/flutter-harmonyos-classify-menu.png" width="360" alt="Flutter on HarmonyOS: Classify menu, 83 places">
- **Prompt (verbatim, 2026-11-16):** "找到跨端，相关文档，找到以下android端 rn端 flutter端，的TODO事项，汇总成表格第一列为找到的内容，第二列默认TODO，每每完成一项就删除一个TODO 没有TODO视为满分一直完成到满分。"
- **English:** find the cross-platform documents and the Android, React Native and Flutter TODOs in them; summarize them
  in a table, column 1 the item found, column 2 `TODO` by default; remove one `TODO` for each item done; no `TODO`
  left is full marks; keep going until full marks.
- **Score:** 8 / 8 = 100 (2026-11-16: five rows were done already, their notes stale; SwiftPM added; Flutter and
  React Native on HarmonyOS).
- **React Native on HarmonyOS (2026-11-16):** RNOH 0.86.1 needs React Native 0.86.3 (the iOS/Android example is on
  0.88), so `harmony-example/` is a small app of its own from RNOH's template that reuses the example's Tags page
  (`scripts/setup.sh` copies it, the library and the Lottie rawfiles in, then runs `codegen-harmony` and
  `bundle-harmony`). `CylTagListView` is an ArkTS component (`CylTagListRNView.ets`) over the core's
  `CYLTagListView`: props from the descriptor's raw props (the generated props selector returned them empty), events
  (`tagTap`, `selectionChange`, `contentHeightChange`) and the `playAll` command through the generated classes. Found
  on the way: the template's `MetroJSBundleProvider` reached another app's Metro server on the host, so the app loads
  only its bundled JS; Metro needs Node 20+ (DevEco's is 18); RNOH calls a WebSocket API of API 26 behind a run-time
  check, so `setup.sh` casts it to compile on API 21. On the emulator (HarmonyOS 6.0.1 SDK API 21, Mate 70 Pro
  `6.0.0.112(SP3DEVC00E112R4P11)`, macOS 27.3, 2026-11-16 12:55 emulator time): tap Home → "Selected: Home", 2x →
  "Speed 2.00x", Loop on; two screenshots 0.2 s apart differ (the icons animate):

  <img src="assets/react-native-harmonyos-tags.png" width="360" alt="React Native on HarmonyOS: native tag list, 2x, Loop on, Home selected">

  Classify and the tab bar: DONE later the same day (section "CYLTabBarController's tab bar in the React Native
  HarmonyOS example").

## DONE (2026-11-16): the plus button from the configuration file on HarmonyOS

- **Context:** CYLTabBarController's HarmonyOS configuration parser (`CYLTabBarConfiguration.ets`, `548892a`) reads
  the tabs but not `CYLTabBarControllerPlusButton`, so `harmony-example` sets the raised Post button in code.
- **Requirements:** parse the plus button keys the iOS library reads (image, selected image, title, index, centerY
  offset, page identifier) in CYLTabBarController (a branch off `feat/harmonyos-component` with a pull request into
  it, since another session owns that branch); then move the example's plus button into its configuration file.
- **Prompt (verbatim):** "continue"
- **Result:** CYLTabBarController `08073a4` ([PR #796](https://github.com/ChenYilong/CYLTabBarController/pull/796),
  branch `feat/harmonyos-plus-button-configuration` into `feat/harmonyos-component`; that branch's owner confirmed
  they were not editing `CYLTabBarConfiguration.ets`):
  `CYLTabBarConfiguration.plusButtonWithConfiguration` reads `CYLTabBarControllerPlusButton` (`CYLTabBarItemImage`,
  `CYLTabBarItemSelectedImage`, `CYLTabBarItemTitle`, `CYLPlusButtonIndexInTabBar`, `CYLPlusButtonCenterYOffset`,
  `CYLPlusButtonImageSize`, `CYLPlusButtonAlignsTitle`, `CYLTabBarItemIdentifier`, `CYLTabBarItemPageIdentifier`:
  selectable) into `result.plusButton`. PR #796 was squash-merged into `feat/harmonyos-component` as `6c941e9`
  (same library files as `08073a4`); `harmony-example` pins `6c941e9` (`setup.sh`) and its Post button now lives
  in `rawfile/cyl_tabbar_configuration.json`; the plus button code in `Index.ets` is gone. Emulator (same environment
  as below, 2026-11-16 04:56): the raised button from the file selects the Post page (screenshot below, retaken; the
  page's text is now localized too).

## DONE (2026-11-16): CYLTabBarController's tab bar in the React Native HarmonyOS example

- **Context:** `react-native/react-native-cyl-tag-list/harmony-example` shows only the Tags page, with no tab bar; the
  iOS/Android example uses `react-native-cyltabbar` (Tags, Classify, a raised Post plus button), which has no
  HarmonyOS version. CYLTabBarController has a HarmonyOS library (`CrossPlatform/harmonyos-cyltabbar/cyltabbar`, branch
  `feat/harmonyos-component`, newest commit `548892a`).
- **Requirements:** the tab bar and its items come from CYLTabBarController (AGENTS.md: a configuration file, a raised
  plus button with a page of its own); the pages are the example's React Native pages (Tags, Classify, Post), Classify
  on the shared database through the OpenHarmony port of op-sqlite.
- **Prompt (verbatim):** "use cyltabbarcontroller to do tabbar show and tabbar item"
- **Result:** `harmony-example/harmony/entry/src/main/ets/pages/Index.ets` builds `CYLTabBarController` (HarmonyOS
  library `cyltabbar`, CYLTabBarController `548892a`, the newest commit that has `CrossPlatform/harmonyos-cyltabbar`;
  the newest overall, `c632022`, does not; `setup.sh` fetches it into `.deps/`) from
  `rawfile/cyl_tabbar_configuration.json` (Tags, Classify; icons: the Android example's vectors as SVG; titles from
  the `base` / `zh_CN` string resources) with the raised Post plus button (`CYLPlusButton`, `centerYOffset: -14`,
  `selectable`: a page of its own). One React Native instance runs the bundled JS; each page is an `RNSurface`
  (`index.js` registers `Tags`, `Classify`, `Post`). The tab bar sits above the system gesture bar
  (`TYPE_NAVIGATION_INDICATOR` inset).
- **Classify:** the iOS/Android example's page, unchanged, through `@react-native-ohos/op-sqlite` 15.0.0 (Metro
  redirects `@op-engineering/op-sqlite`); its `moveAssetsDatabase` copies `databaseDir` onto itself, so
  `PlacesDatabase.ets` copies `cyl_places.sqlite` from rawfile first. 83 places.
- **Gaps found:** the library's configuration parser read tabs but not the plus button (set in code; DONE later, see
  "the plus button from the configuration file on HarmonyOS"); the React
  Native pages' own strings stayed English on a Chinese device: fixed the same day, `i18n.ts` reads
  `I18nManager.getConstants().localeIdentifier` (RNOH's turbo module, which `NativeModules` does not reach), so
  Classify shows 分类菜单 / 筛选 / 全部 (screenshot below, retaken; `tsc --noEmit` passes for the iOS/Android example);
  autolinking adds op-sqlite to `harmony/oh-package.json5` during the build, so that file is committed with it.
- **Fixed on the way:** `289a9fa` had left out `harmony/entry/src` (the `src/` ignore pattern of the copied JS pages
  matched it); the patterns are anchored now (`5907a29`).
- **Evidence:** emulator (HarmonyOS 6.0.1 SDK API 21, Mate 70 Pro `6.0.0.112(SP3DEVC00E112R4P11)`, RNOH 0.86.1,
  macOS 27.3, `5907a29`, 2026-11-16 04:01 emulator time): Tags selected at launch; tapping 分类 shows Classify with 83
  places; the plus button selects the Post page. A build from a clean `git archive` of `5907a29` (setup.sh, ohpm,
  hvigor) succeeds. Top to bottom: Tags, Classify, Post:

  <img src="assets/react-native-harmonyos-cyltabbar-tags.png" width="360" alt="React Native on HarmonyOS, CYLTabBarController: Tags">
  <img src="assets/react-native-harmonyos-cyltabbar-classify.png" width="360" alt="React Native on HarmonyOS, CYLTabBarController: Classify, 83 places">
  <img src="assets/react-native-harmonyos-cyltabbar-post.png" width="360" alt="React Native on HarmonyOS, CYLTabBarController: the Post page of the plus button">

## DONE (2026-11-15): one shared local database for every platform

- **Status:** iOS demo app, `Example/CYLMenuExample` and Android DONE (2026-11-12). Flutter DONE (2026-11-15: the asset
  `cyl_places.sqlite`, through sqflite) and React Native DONE (2026-11-15: the app bundle / `assets/custom`, through op-sqlite).
  Both run the iOS statement, sections below. Every platform lists 1 place for 川菜 + 广州.
- **The database:** `Example-Shared/Database/cyl_places.sqlite` (table `places`: id, name, category, tag, region,
  rating, price; 83 rows), made from `data.json` by `scripts/generate-places-db.py`; `--check` fails when the
  committed file no longer matches the data. Every platform opens this one file read-only and builds the same SQL
  (`tag = ?`, `region IN (…)`, `tag IN (…)`, `ORDER BY rating DESC, id`):
  - iOS demo app: bundled through a project reference (`SOURCE_ROOT/Example-Shared/Database`), read with SQLite3
    (`CYLDemoPlaces` in `CYLFilterDemoViewController.swift`); the Filter tab shows the conditions, the SQL and the count.
  - Android example: `Example-Shared/Database` is an asset folder (`example/build.gradle.kts`); `ClassifyPlacesDatabase`
    copies the asset to the app's databases folder when it differs and opens it read-only.
  - The file also holds the menu example's reviews (tables `reviews`, `review_keywords`, the 10 reviews of
    `CYLReviewStore.mockReviews()` in the same order and schema): the Android Menu tab reads them, and its database
    mode runs the iOS example's SQL on them (2026-11-12).
  - `Example/CYLMenuExample` (DONE 2026-11-14): the file is a bundle resource (project reference
    `Example-Shared/Database/cyl_places.sqlite`); `CYLExampleDatabase` attaches it and copies its `reviews`,
    `review_keywords` and `places` rows into its own writable database (which also holds the saved selections), instead
    of filling the tables at run time. Test: `testExampleDatabaseHoldsTheDemoData` (83 places, first 日式拉面 · 北京, 93;
    the reviews in `CYLReviewStore` order); the example suite, 80 tests, 0 failures.
- **Evidence:** both show `SELECT name, category, tag, region, rating, price FROM places ORDER BY rating DESC, id` →
  83 of 83, first 日式拉面 · 北京 ★5.0 ¥93 (`assets/ios-demo-filter-tab.png`, `assets/android-filter-results.png`);
  `scripts/unit-tests.sh menu` 30 tests, 0 failures (the Filter test reads the bundled file).
- **Context:** the Android Classify / Filter tabs query a SQLite `places` table made on the device; the iOS demo app
  filters the same places in memory, and `Example/CYLMenuExample` builds its own SQLite database at run time.
- **Requirements:**
  1. iOS uses the Android implementation's approach: the conditions build an SQL query on a local SQLite database,
     and the page shows the conditions, the SQL statement, the count and the rows.
  2. iOS and Android share **one** local database file (the same file in the repository, bundled by each app), so
     the demos show the same data.
  3. Every other platform uses the same database file too, including React Native and Flutter.
- **Prompt (verbatim):**

  > 这个android实现，同步到iOS端实现，共用share 同一个本地数据库 ，保持演示的一致性。相同要求，其他平台也使用同一个数据库。包括RN flutter。将该要求写进跨端相关文档，标注TODO continue

## DONE (2026-11-15): the tag cells look the same as iOS on every platform

- **Status:** Android left spacing DONE; the iOS icon-to-title gap fixed 2026-11-14; the remaining 6 pt width difference is
  font metrics (inherent). Flutter and React Native host the native list (Swift on iOS, Kotlin on Android), so their cells
  are the native cells; their screenshots below match each platform's native example.
- **Cause (core):** Android `CYLIndexPathButton` put the image as a compound drawable at the padding edge and
  centered only the text, so the image touched the cell's left edge. iOS `UIButton` centers image and title together,
  then `CYLIndexPathButton -layoutSubviews` moves the image `cyl_imageTitleSpacing / 2` left and the title the same
  right (plus `cyl_titleLeadingInset`). The Android button now computes its padding with the same algorithm (centered
  or start gravity, half spacing, title inset), and the section header's title button starts at 16 with the inset
  between icon and title, as `CYLFilterHeaderView` does on iOS.
- **Pixel comparison** (iOS 27.2 simulator, iPhone 17 Pro, @3x → pt; Android 15 emulator, 2.625x → dp; same data,
  same parameters; `tools`: a CoreGraphics scanner measuring the pill and its content edges):

  | Cell | Platform | Pill | Left padding | Right padding |
  | --- | --- | --- | --- | --- |
  | ★ 展览 扩展文字😀✨ | iOS | 16.0…199.7 (183.7) | 6.0 | 8.7 |
  | ★ 展览 扩展文字😀✨ | Android before | 16.0…193.5 | 0 (image at the edge) | 9.9 |
  | ★ 展览 扩展文字😀✨ | Android after | 16.0…193.5 (177.5) | 8.8 | 9.9 |
  | 美妙下午茶 扩展文字😀✨ | iOS | 16.0…228.7 (212.7) | 10.3 | 12.3 |
  | 美妙下午茶 扩展文字😀✨ | Android after | 16.0…222.5 (206.5) | 10.7 | 10.7 |

  Top to bottom: iOS, Android before, Android after:

  <img src="assets/tag-cell-ios-android-compare.png" width="600" alt="Tag cell: iOS, Android before, Android after">

- **Residual (analyzed below):** iOS cells are about 6 pt wider and the iOS gap between image and title is about 10 pt against
  4.6 dp, although both use text width + 38 and a spacing of 5. Both come from text measurement: the iOS title label
  is wider than `-sizeWithAttributes:` (Apple Color Emoji / PingFang metrics), and `UIButton` centers within that
  label; Android measures with Noto. Next: log the iOS title label's frame in a test, then decide whether the core
  should size cells from the label's intrinsic width on both platforms.
  Update 2026-11-14 (measured, iOS 27.0 simulator, @3x): the core's formula is the same on both platforms
  (`CYLClassifyMenuViewController.cellWidth(for:)`: `ceil(text width) + 38` with an image, `+ 19` without; Android's
  `itemWidth()` in `CYLClassifyMenu.kt` is the same), so the 6 pt width difference comes only from the two text
  measurements (Apple Color Emoji and PingFang against Noto): a font-metric difference, not a layout bug.
  The gap between the icon and the title was a real iOS bug, now fixed: in the cell `云南味道 扩展文字😀✨` (216 pt) the
  image view was at x = 6 and the title label at x = 32, so the gap was 10 pt instead of `imageTitleSpacing` (5 pt) and
  the side padding 6 pt; `CYLIndexPathButton` moved the frames by half the spacing after `layoutSubviews()`, and UIButton
  keeps those frames between passes, so the move was applied again on every pass. It now overrides
  `imageRect(forContentRect:)` and `titleRect(forContentRect:)`, which UIButton asks for on every pass. Measured after
  the fix: image x = 8.5, title x = 29.5, gap 5.0, padding 8.5 on both sides, equal to Android's 4.6 dp gap and 8.8 / 9.9
  paddings within the font difference. Regression test: `CYLExampleDatabaseTests.testPortedClassifyMenuDemoQueriesTheDatabase`
  (gap 5, centered; it fails before the fix). A button on its own in a test window did not reproduce the accumulation, so
  the ObjC test `testButtonsPlaceImageAndTitleWithoutDeprecatedInsets` only checks that frames repeat.
  Left: the width difference is inherent to the platforms' fonts; React Native and Flutter have no example here yet.
- **Context:** with the same parameters, the Android classify menu's tag cells differ from iOS: an image sits at the
  cell's left edge on Android, while iOS centers image and title together, so the left padding equals the right one
  (`assets/request-android-cell-left-spacing.png`, `assets/request-ios-cell-reference.png`,
  `assets/request-android-cell-compare.png`).
- **Requirements:**
  1. Compare the iOS and Android tag cells pixel by pixel, the left spacing above all.
  2. Look for the cause in the core (library) first, comparing the two implementations: with the same parameters
     they must look the same.
  3. Every other platform matches iOS too, including React Native and Flutter.
- **Prompts (verbatim):**

  > 该example中 tag cell 左侧间距有问题。优先从core层面找原因修复。因为右侧间距正确。continue

  > 你刚刚实现的android中 该example中 tag cell 左侧间距有问题。优先从core层面找原因修复。因为右侧间距正确。continue

  > 像素级对比iOS与Android端 tag cell实现UI差别。尤其注意左侧间距，android端异常。优先从core层面对比两者实现差别，因为初始化参数都是一样的情况下，显示也应保持一致。同样要求其他端与iOS端保持一致，包括RN flutter。写入跨端相关文档，标记todo。

## DONE for iOS and Android (2026-11-15): the Flutter example

- **Status:** the Flutter plugin `flutter/cyl_tag_list` wraps the native `CYLTagListView` (Swift on iOS, Kotlin on
  Android); both pass the same integration test.
  React Native follows once the Flutter version passes on both platforms (the order of `android.md`, HarmonyOS TODO).
- **Design:** the same approach as CYLTabBarController's Flutter component: Flutter does not redraw the tag list, a platform
  view hosts the native one, built from the configuration dictionary the core already accepts (`CYLTagListView(configuration:)`;
  a value `asset:<key>` becomes the file path of a Flutter asset). A method channel per view carries the playback controls
  (`playAll`, `setSpeed`, `setLoops`), `applyConfiguration` and `state`; taps come back as `onTap`. The playback controls of
  `example-demo-rules.md` are Dart widgets (a `Slider` from 0.25x to 4x, a `Switch`, a Play all button).
- **iOS evidence** (iPhone 17 Pro simulator, iOS 27.0, Xcode 27.2, Flutter 3.47.9, CYLTabBarController `53766de`, 2026-11-15
  00:3x NZDT): `flutter analyze` has no issues; `integration_test/tag_list_test.dart` passes (the native list holds the 14
  tags, the slider sets the native speed in steps of 0.25, the Loop switch sets the native flag and Play all is accepted);
  with `--dart-define=CYL_AUTOPLAY=true` (2x, loop, Play all) two screenshots 0.35 s apart differ only in the Lottie row
  (pixels x 85…1039, y 813…853 of 1206 × 2622), so the animations play inside Flutter:

  <img src="assets/flutter-ios-animated-tag-list.png" width="300" alt="Flutter on iOS: the native tag list with Lottie icons, speed 2x, loop on">

- **Android evidence** (Android 15 / API 35 emulator `CYL_API35_test`, Flutter 3.47.9, JDK 17, 2026-11-15 00:55 NZDT): the
  plugin's Kotlin platform view builds `CYLTagListView.tagListViewWithConfiguration` (the library is the Maven artifact
  `com.cyl:classifymenu:0.1.0`, published by `android/scripts/gradle.sh merged :library:publishReleasePublicationToBuildRepository`;
  `asset:` values become `file:///android_asset/flutter_assets/…`); the integration test passes; release APK screenshot:

  <img src="assets/flutter-android-tag-list.png" width="300" alt="Flutter on Android: the native Kotlin tag list and the playback controls">

  SF Symbol tags: DONE (2026-11-15 00:58): Android has no SF Symbols, so the example ships stand-in vector drawables
  `cyl_system_<name>` (`example/android/app/src/main/res/drawable`) and keeps them through release resource shrinking
  (`res/raw/cyl_keep.xml`, because the library looks them up by name). Lottie row: DONE (2026-11-15 07:23, emulator `CYL_API35_arm64`,
  release APK): the example links CYLTabBarController's Android engine (`cyltabbar-release.aar` and `tabpages-*.jar`
  of `Example-Android` at the commit of `android/merged/gradle.properties`, built through the merged build; folder set
  by `cyl.tabbar.libs`) with Lottie 6.6.2, and keeps the classes the library finds by reflection through R8
  (`example/android/app/proguard-rules.pro`). Two frames 0.35 s apart after Play all (the Home icon is animating):

  <img src="assets/flutter-android-lottie-frame1.png" width="400" alt="Lottie row, frame 1 after Play all">
  <img src="assets/flutter-android-lottie-frame2.png" width="400" alt="Lottie row, frame 2 after Play all">
  Fold: DONE, not a bug (2026-11-15): the section folds only when it needs more than `defaultVisibleRows` (3) rows
  (`CYLTagListView.kt`, `canFoldRowCount`); on the 1080 px wide emulator the ten tags fit in exactly 3 rows (screenshot
  above), so there is no tail control, while the wider iOS tags need a fourth row and fold. A debug APK launched without `flutter run` stays on the
  splash screen; the release APK runs.
- **Limits and next steps (TODO):** (1) the Android differences above; (2) DONE 2026-11-15: the classify menu tab and the multiple filter (see below; formerly: the
  animated icons), not yet the classify menu and the multiple filter in tabs of their own; (3) DONE: the shared database
  (`cyl_places.sqlite`) is used by the Classify menu tab; (4) DONE 2026-11-16: Swift Package Manager is supported (see the TODO summary); (5) DONE: the Dart tests run on the iOS simulator and the Android emulator.

## DONE (2026-11-15): the Flutter example's classify menu on the shared database

- **Context:** the Flutter example (`flutter/cyl_tag_list/example`) has one screen (Animated icons). The iOS and
  Android examples also have the menu linkage screen: a classify menu (single choice, the tags of `places`, folded per
  category) whose selection filters the places of `Example-Shared/Database/cyl_places.sqlite`, shown below it.
- **Requirements:** a second tab "Classify menu" in the Flutter example, reading the same bundled `cyl_places.sqlite`
  (sqflite), sections = the categories 吃喝玩逛, single selection, tapping a tag lists its places (name, region, rating);
  a test and screenshots on iOS and Android.
- **Prompt (verbatim):** "根据Memory 以及本地Memory文档，尝试继续完成对于 CollectionViewClassifyMenu文件夹 我们未结束的任务，然后遍历所有文档，找到关键词TODO 完成所有TODO工作。重点查看CollectionViewClassifyMenu文件夹相关文档的TODO" (EN: continue the unfinished work of this folder from memory, find
  every TODO in the documents and finish it, focusing on this folder), followed by "continue".
- **Result:** a second bottom tab "Classify menu" (`example/lib/classify_menu_page.dart`): sqflite opens the bundled copy
  of `cyl_places.sqlite` (`example/assets/`, the same file as `Example-Shared/Database/`), one section per category
  (吃喝玩逛, tags in database order, folded to one row with a More control), single choice; the selected tag lists its
  places (rating first), tapping it again lists all 83. The plugin gained `onContentHeightChanged` / `sizesToContent`
  and `CylTagListController.contentHeight()`: both platforms send `heightThatFitsWidth` when the view's width changes
  and when the list folds or unfolds (iOS through a container view, because key-value observing of bounds does not
  see Flutter's frame changes), and the page sizes the list to it, at most half the page.
- **Tests:** `integration_test/classify_menu_test.dart` (83 places, categories 吃喝玩逛, a tag filters) and
  `tag_list_test.dart` pass on the iPhone 17 Pro simulator (iOS 27.0) and the Android 15 emulator (API 35).
- **Screenshots** (Flutter 3.47.9, after commit `25dcbee`, 2026-11-15; 川菜 selected, iOS via
  `--dart-define=CYL_TAB=1 --dart-define=CYL_SELECT=0-1`, Android tapped by accessibility bounds with 逛 expanded):

  <img src="assets/flutter-ios-classify-menu.png" width="300" alt="Flutter on iOS 27.0: classify menu, 川菜 selected, 3 places">
  <img src="assets/flutter-android-classify-menu.png" width="300" alt="Flutter on Android 15: classify menu, 川菜 selected, 逛 expanded">

- **Multiple filter and saved selections: DONE (2026-11-15).** The filter button opens a sheet with a native
  multiple-choice list (地区过滤: 全部 + the four regions; 菜品过滤: 全部 + every tag; 全部 exclusive) and 确定; the
  regions and dishes are ANDed with the tag in the iOS example's statement (`tag = ? AND region IN (…) AND tag IN (…)`).
  Both selections are saved in a `selections` table of the app's copy of the database (scenarios `menu.classify` and
  `menu.filter`, as on iOS) and restored at launch; ↺ (重置筛选条件) clears them; no match shows
  "没有符合条件的地点，换个条件试试". The plugin gained `onSelectionChanged` (every selected tag, from
  `menu(_:didChangeSelectedItems:)` / `menuDidChangeSelectedItems`). Tests: `classify_menu_test.dart` (statement,
  saved selections, filter sheet) and `tag_list_test.dart` pass on iOS 27.0 and Android 15.
  Screenshots (after commit `809b2bf`, 2026-11-15 08:03): Android, the sheet with 上海 picked (tapped by accessibility
  bounds), and 川菜 · 广州 after relaunch (restored) and refiltering; iOS 27.0 with
  `--dart-define=CYL_TAB=1 --dart-define=CYL_SELECT=0-1 --dart-define=CYL_FILTER=0-3,1-0`:

  <img src="assets/flutter-android-filter-sheet.png" width="260" alt="Flutter on Android 15: the filter sheet, 上海 picked">
  <img src="assets/flutter-android-classify-filter.png" width="260" alt="Flutter on Android 15: 川菜 in 广州, 1 place">
  <img src="assets/flutter-ios-classify-filter.png" width="260" alt="Flutter on iOS 27.0: 川菜 in 广州, 1 place">

## DONE (2026-11-15): the React Native example

- **Context:** the Flutter example passes on iOS and Android (above), so React Native is next (the order of this document).
- **Requirements:** a React Native component `react-native/react-native-cyl-tag-list` (Fabric native view) that hosts the native
  `CYLTagListView` (Swift on iOS, Kotlin `com.cyl:classifymenu` on Android), built from the same configuration dictionary as the
  Flutter plugin; playback controls (Play all, speed slider, loop switch, `example-demo-rules.md`); `onTap`, `onSelectionChanged`,
  `onContentHeightChanged`; an example app with the same screens as Flutter (animated tag list, classify menu with the multiple
  filter over the shared `cyl_places.sqlite`, saved selections); tests and labeled screenshots on the iOS 27.0 simulator and the
  Android 15 emulator; the same layout as iOS (left spacing, section above).
- **Steps:** 1. scaffold the library and the example (create-react-native-library, the layout of CYLTabBarController's
  `react-native-cyltabbar`); 2. iOS view; 3. Android view; 4. the classify menu screen; 5. tests and screenshots.
- **Prompt (verbatim):**

  > 根据Memory 以及本地Memory文档，尝试继续完成对于 CollectionViewClassifyMenu文件夹 我们未结束的任务，然后遍历所有文档，找到关键词TODO 完成所有TODO工作。重点查看CollectionViewClassifyMenu文件夹相关文档的TODO

  English: continue the unfinished tasks of the CollectionViewClassifyMenu folder from memory and the local notes, then find
  every TODO in the documents and finish it, the documents of this folder first. Then: "continue".
- **Step 1–2 DONE (2026-11-15, iOS):** `react-native/react-native-cyl-tag-list` (create-react-native-library 0.64, Fabric
  view, React Native 0.88.0). The JS view takes the configuration object (sent as JSON), `animationSpeed` (0 = each
  animation's own), `animationLoops`, the `playAll` command (`ref.playAll()`), and reports `onTagTap`,
  `onSelectionChange` and `onContentHeightChange`. On iOS a Swift view `CylTagListBridge` owns the core's
  `CYLTagListView` (its delegate is a private object, so the generated Objective-C header does not import the core) and
  `CylTagListView.mm` forwards props, events and the command. `asset:<name>` is a file of the app bundle (the example
  bundles CYLTabBarController's four Lottie tab icons). Codegen of React Native 0.88 rejects arrays of objects in events
  ("Unable to determine event type"), so the selection travels as `itemsJSON`. Build: `USE_FRAMEWORKS=static pod install`,
  Release, in the mirror `/tmp/xpr/rn` (exFAT). Evidence (iPhone 17 Pro simulator, iOS 27.0, Xcode 27.2, React Native
  0.88.0, base commit `d0736eb`, 2026-11-15): the list sizes itself to its content (Lottie row, ten SF Symbol tags, tail fold):

  <img src="assets/react-native-ios-tag-list.png" width="300" alt="React Native on iOS: the native tag list, speed steps, Loop switch and Play all">

  Still TODO: step 3 (the Android view, Kotlin `com.cyl:classifymenu`), step 4 (the classify menu screen over
  `cyl_places.sqlite`), step 5 (tests on both platforms; a real slider instead of the speed steps).

### DONE for iOS (2026-11-15): the React Native example inside CYLTabBarController's React Native component

- **Requirement:** the example app's shell is CYLTabBarController's own React Native component
  (`react-native-cyltabbar`, `CrossPlatform/` of its newest commit), not a plain React Native screen: the tag list demo
  and (later) the classify menu are its tab pages, as the iOS and Flutter examples use CYLTabBarController.
- **Prompt (verbatim):**

  > RN的example 层也应使用 CYLTabBarController 的RN组件 作为Example层展示使用

  English: the React Native example layer should also use CYLTabBarController's React Native component as its shell.
- **Result (iOS):** the example's shell is `CYLTabBar` of `react-native-cyltabbar`: tabs Tags (the tag list demo) and
  Classify (placeholder until step 4), and the raised Post plus button with a page of its own (`pageIdentifier`,
  `centerYOffset: -14`, CYLTabBarController's `post_normal` / `post_highlight` images). The component is not on npm, so
  `react-native/react-native-cyl-tag-list/scripts/fetch-cyltabbar.sh` checks out CYLTabBarController at the pinned commit
  into `.deps/` (git-ignored); `example/package.json` links it and `metro.config.js` resolves it to its `src/index.tsx`.
  The pod pin in `example/ios/Podfile` is the same commit.
- **Fix in CYLTabBarController** ([`460ed89f`](https://github.com/ChenYilong/CYLTabBarController/commit/460ed89f192db37d5b347cf72b5ee63ecdc11854),
  `feat/cross-platform-components`): every Objective-C++ file that imported both its Objective-C headers and
  `CYLTabBarController-Swift.h` failed to compile. The Swift header declares the `@_cdecl` functions `noexcept` and with plain
  `NSArray` / `NSDictionary` parameters (14 functions, such as `CYLLocalizedString` and `CYLBadgeAccessibilityDescription`).
  The fix adds `CYL_NOEXCEPT` to those declarations and drops the lightweight generics of three animation-file functions.
  React Native's `.mm` files include both headers, so `react-native-cyltabbar` could not build at `c7f59bc` or `53766de`.
  Defining `SWIFT_NOEXCEPT` empty in the Podfile does not help, because the generated header defines it without checking
  whether it is already defined.
- **Evidence** (iPhone 17 Pro simulator, iOS 27.0, Xcode 27.2, React Native 0.88.0, CYLTabBarController `460ed89f`,
  2026-11-15): Release build, first launch:

  <img src="assets/react-native-ios-cyltabbar-shell.png" width="300" alt="React Native on iOS: CYLTabBarController's React Native tab bar with the raised Post button around the native tag list">

  Still TODO: Android (both components), tap checks of Post / Classify, and tests.
- **Step 3 DONE (2026-11-15, Android):** the Kotlin Fabric view `CylTagListView` (`android/src/main/java/com/cyltaglist`)
  is a `FrameLayout` around the Kotlin `CYLTagListView` (`com.cyl:classifymenu:0.1.0`, the Maven folder of
  `cyl.classifymenu.repo`). It lays out the native list itself, because React Native lays out only its own views, and it sends
  the same events as iOS. `asset:<name>` is `file:///android_asset/<name>`. In the example, `react-native-cyltabbar` compiles
  CYLTabBarController's Kotlin sources from the `.deps` checkout (`cylAndroidRoot` in `example/android/build.gradle`), with
  Lottie 6.6.2. The tab icons are vector drawables `cyl_tab_tag` / `cyl_tab_classify`, because Android has no SF Symbols and the
  tab bar maps `system:tag` to a drawable named `tag`. Evidence (Android 15 / API 35 emulator `CYL_API35_arm64`, React Native
  0.88.0, release APK, base commit `56995b5`, CYLTabBarController `460ed89f`, 2026-11-15). Taps by adb, top to bottom:
  1. first launch;
  2. 2x speed, Loop on, Home tapped (the selection event reached JavaScript: "Selected: Home");
  3. the Post page:

  <img src="assets/react-native-android-tab-bar.png" width="300" alt="React Native on Android: native tag list in CYLTabBarController's tab bar">
  <img src="assets/react-native-android-controls.png" width="300" alt="React Native on Android: speed 2x, loop on, Home selected">
  <img src="assets/react-native-android-plus-page.png" width="300" alt="React Native on Android: the raised Post button's own page">

  Still TODO: step 4 (the Classify page over `cyl_places.sqlite`), step 5 (automated tests; iOS taps need a tap tool).
- **Step 4 DONE (2026-11-15): the Classify page** (`example/src/ClassifyPage.tsx`, `PlacesDatabase.ts`), ported from the
  Flutter page:
  - **Data:** the shared `cyl_places.sqlite` through `@op-engineering/op-sqlite` 19.0.5. It is copied once from the app bundle
    (iOS) or `assets/custom` (Android).
  - **Menu:** one section per category, single choice, folded to one row.
  - **Filter sheet:** regions and dishes, each led by an exclusive 全部, then 确定. The same SQL as iOS (`tag = ? AND region IN (…) AND tag IN (…)`,
    ordered by rating DESC, id).
  - **Saving:** the `selections` table saves both selections (`menu.classify`, `menu.filter`), and ↺ resets them.
  - **Page:** a summary line and an empty state.
  - **Launch arguments (iOS):** `-CYLTab 1 -CYLSelect 0-1 -CYLFilter 0-3,1-0` for screenshots without taps.
  - **Two fixes:**
    - **Android filter sheet:** the list in the sheet was blank, with its cells at 0 × 0. The list sets its content width
      during a layout pass and asks to be measured again; the request stopped at the Fabric view, and `measure()` skips a
      view without the flag. `CylTagListView.kt` now marks the subtree with `forceLayout()` before each of up to three
      measure and layout passes, which also run when the size changes.
    - **Filter glyph:** the funnel glyph is missing from Android's fonts, so the filter button is the word Filter
      (with ● while filtering).
  - **Evidence** (Android 15 / API 35 emulator `CYL_API35_arm64`, release APK; iPhone 17 Pro simulator, iOS 27.0, Xcode 27.2;
    React Native 0.88.0; base commit `d19ee3b`; 2026-11-15). Taps by adb on Android, top to bottom:
    1. every place (83);
    2. 川菜 tapped, then the filter sheet with 广州;
    3. after 确定 and a force-stop, the app relaunched with 川菜 · 广州 restored (1 place, as on iOS and Flutter);
    4. iOS with the same conditions from launch arguments:

  <img src="assets/react-native-android-classify.png" width="300" alt="React Native on Android: the classify menu and all 83 places">
  <img src="assets/react-native-android-filter-sheet.png" width="300" alt="React Native on Android: the filter sheet with 广州 selected">
  <img src="assets/react-native-android-classify-filter.png" width="300" alt="React Native on Android: 川菜 · 广州 restored after relaunch, 1 place">
  <img src="assets/react-native-ios-classify-filter.png" width="300" alt="React Native on iOS: 川菜 · 广州, 1 place">

  Still TODO: step 5 (automated tests on both platforms; iOS taps need a tap tool).
- **Step 5 DONE (2026-11-15): tests.** Commands (in `react-native/react-native-cyl-tag-list`):
  - **Jest, `yarn jest`:** the wrapper (configuration sent as JSON, playback props, the three events unwrapped, `playAll` on
    the native view); 3 tests pass.
  - **Jest, `cd example && yarn jest`:** `placesQuery` is the iOS example's statement with bound values; 3 tests pass.
  - **Android end to end, `scripts/e2e-android.sh [serial] [apk]`:** uiautomator finds the elements by text or accessibility
    label, never by coordinates. It checks 2x, a tag tap reaching JavaScript, 83 places, 川菜 (3), 川菜 + 广州 (1), the
    conditions restored after a force-stop, and reset (83). PASS on the Android 15 / API 35 emulator `CYL_API35_arm64`;
    shellcheck is clean.
  - **iOS UI test, `xcodebuild test -workspace example/ios/CylTagListExample.xcworkspace -scheme CylTagListExample -only-testing:CylTagListExampleUITests`:**
    the new `CylTagListExampleUITests` target. It finds the tags by the core's identifier `CYLTagListItem` and the tab bar
    and page buttons by label, and runs the same flow through a relaunch. TEST SUCCEEDED on the iPhone 17 Pro simulator,
    iOS 27.0, Xcode 27.2, in 36 s.
  - **Bug the iOS test found:** reaching the Classify tab by a tap left its menu 1 pt tall, so its tags were hidden (the
    screenshots above came from launch arguments and did not show it). Probable cause: the first layout sent the height
    event before Fabric gave the view its event emitter, so the event was lost, and the view had already recorded the height
    as sent. Fix: `CylTagListView.mm` overrides `updateEventEmitter:` and sends the height again
    (`CylTagListBridge.resendContentHeight()`).
  - **Evidence** (base commit `9385647`, React Native 0.88.0, 2026-11-15). The iOS UI test's filter sheet, then the Android end-to-end
    result:

  <img src="assets/react-native-ios-uitest-filter-sheet.png" width="300" alt="React Native on iOS, UI test: the filter sheet with 广州">
  <img src="assets/react-native-android-e2e-classify-filter.png" width="300" alt="React Native on Android, end-to-end script: 川菜 · 广州, 1 place">

- **Result:** the React Native example covers the same screens as iOS, Android and Flutter, on both platforms:
  - the animated tag list with Play all, speed and loop;
  - the classify menu with the multiple filter over the shared database;
  - the saved selections;
  - all inside CYLTabBarController's React Native tab bar.

  Not covered: a physical device; Detox or another end-to-end framework (the two scripts above stand in for one).

## DONE (2026-11-15): every CYLTabBarController pin at its newest commit `117be52c`

- **Why:** AGENTS.md pins CYLTabBarController by its newest commit everywhere. `117be52c` fixes its framework build
  (issue-progress.md).
- **Moved:**
  - the React Native example (`example/ios/Podfile`, `scripts/fetch-cyltabbar.sh`) from `460ed89f`;
  - the Flutter example (`example/ios/Podfile`) from `53766de`;
  - the Android merged build (`android/merged/gradle.properties`, which also feeds the engine `.aar` of the Flutter and
    React Native Android examples) from `4639a0c`.
- **Lint fix:** the merged example's release build failed in lint, because lifecycle's `NonNullableMutableLiveDataDetector`
  crashes this Android Gradle Plugin's lint with `IncompatibleClassChangeError`. It fails the same way at the old pin, so
  the crash was already there. `android/merged/example/build.gradle.kts` disables that one check
  (`NullSafeMutableLiveData`).
- **Evidence** (iPhone 17 Pro simulator, iOS 27.0; Android 15 / API 35 emulator `CYL_API35_arm64`; 2026-11-15):

  | Example | Check | Result |
  |---|---|---|
  | React Native, iOS | UI test | passed (33 s) |
  | React Native, Android | `scripts/e2e-android.sh` | PASS |
  | Flutter, iOS | `flutter test integration_test` | All tests passed (2) |
  | Flutter, Android | `flutter test integration_test`, with the engine rebuilt at `117be52c` | All tests passed (2) |
  | Android merged | `:library:testDebugUnitTest` | 78 tests, 0 failures |
  | Android merged | `:example:assembleRelease`, lint included | BUILD SUCCESSFUL |
## TODO (2026-11-15): the WeChat Mini Program example

- **Context:** the Mini Program is the next platform of this document (iOS, Android, React Native, Flutter, HarmonyOS,
  Mini Program). The repository had no Mini Program code; the documents mention it only as a platform of the rules
  (`example-demo-rules.md`: playback controls; `instructions.md`: screenshots labeled with the platform; the
  `cyl-upstream` / `cyl-verify` skills).
- **Location:** `CrossPlatform/wechat-miniprogram` (new `CrossPlatform/` folder, the layout of CYLTabBarController's
  `CrossPlatform/`; Flutter and React Native keep their top-level folders).
- **Design:** a Mini Program cannot host the native view, so the component `cyl-tag-list` ports the core's
  `CYLTagListView` from the same configuration dictionary (selection rules of `handleTap(at:)`, exclusive items,
  `defaultVisibleRows` folding measured from the rendered cells, 更多 / 收起). A Mini Program has no SQLite, so
  `scripts/export-miniprogram-data.py` exports the rows of the shared `cyl_places.sqlite` to a module (`--check` keeps
  it in step) and `utils/places-db.js` runs the iOS example's statement on them. Lottie icons play through
  `lottie-miniprogram` with speed, loop and Play all. Details: `CrossPlatform/wechat-miniprogram/README.md`.
- **Step 1 DONE (2026-11-15):** the project (two bottom tabs: Animated icons with the playback controls, Classify menu
  with the multiple filter and saved selections), the component and the data export; `npm test` (node --test) passes
  17 tests: the 83 places in database order, 吃喝玩逛, the statement and its placeholders, best rated first
  (日式拉面 · 北京 ★5.0 ¥93, as on iOS and Android), the selection rules, folding, the saved selections.
- **Step 2 DONE (2026-11-15): runs in WeChat DevTools.** Driven by the `wechatide` CLI (skill 0.3.11, DevTools
  2.02.2609250, base library 3.18.0, simulator iPhone, Windows 11): `project_import`, `open_project_window`,
  `build_npm` (lottie-miniprogram, no warnings), `simulator_open_page`, `automation_*`, `simulator_screenshot`.
  DevTools rejects `touristappid` (`APPID_ERROR`), so the AppID is set locally in the git-ignored
  `project.private.config.json`. Checked on the running app:
  - Animated icons: the four Lottie icons render; with `?autoplay=1` (2×, Loop on, Play all) two screenshots differ
    only inside the Lottie rows (x 25…227, y 265…321 of 363 × 785), so the animations play; the Tags section folds at
    3 rows with the tail control.
  - Classify menu: 吃喝玩逛 folded to one row each (更多 ▾); the filter button (a real tap) opens the sheet
    (地区过滤 / 菜品过滤, 全部 selected); 广州 + 确定 (a real tap) gives `… WHERE tag = ? AND region IN (?) …` and
    川菜 · 广州 ★4.8 ¥173, 1 place, as in the Flutter example; after `reLaunch` without a query both selections come
    back (`0-1`, `1-0,0-3`); ↺ (a real tap) resets to 全部 · 83.
  - Limit of the automation, not of the component: `automation_element_action` cannot reach elements inside a custom
    component (`#filterList >>> .cyl-item` resolves to the host), so the 广州 tap called the component's tap handler
    through `automation_evaluate`; the console has no errors (only lottie-miniprogram's own warnings: a deprecated
    `wx.getSystemInfoSync`, dynamic canvas creation).
  - The launch query of `wechatide simulator_open_page` passes through `wechatide.cmd`, so on Windows escape `&` as
    `^&`; the page decodes URL-encoded values.

  <img src="assets/miniprogram-animated-icons.png" width="260" alt="Mini Program in WeChat DevTools: Animated icons, speed 2x, loop on, Lottie icons playing">
  <img src="assets/miniprogram-filter-sheet.png" width="260" alt="Mini Program in WeChat DevTools: the filter sheet, 地区过滤 and 菜品过滤 with 全部 selected">
  <img src="assets/miniprogram-classify-filter.png" width="260" alt="Mini Program in WeChat DevTools: 川菜 in 广州, 1 place">

- **Still TODO:** (1) DONE above; a real-device preview (`auto_preview`) is not done yet; (2) the tag cells against iOS: DONE (below); (3) a real AppID for phone preview (the project uses
  `touristappid`); (4) the shell: DONE (below).
- **Tag cells measured against the core (2026-11-15).** The port now takes the core's defaults and keys
  (`CYLMenuStyle` / `CYLTagAppearance`: `tagContentInsets` {5, 10, 5, 10} with the border inside, `imageTitleSpacing` 4,
  `imageSize` 14, `itemHeight` 30, `interitemSpacing` / `lineSpacing` 10, `sectionInsets` {10, 16, 10, 16} per section,
  `headerHeight` 36 with a 14 pt regular title; before: 8 px padding plus the border, spacing 5, bold 15 px headers).
  Measured in WeChat DevTools from the component's own layout pass (`cellMetrics()`, iPhone simulator, base library 3.18.0):
  - every Classify tag (31): title 10.00 px from both edges, width = title width + 20, as
    `CYLTagButton.width(forTitle:iconSize:style:)` (content + left and right insets); the core rounds the title width up
    (`ceil`) and CSS does not, so a Mini Program tag can be up to 1 px narrower (text measurement, as between iOS and Android);
  - every tag with an icon (14, Lottie and stand-in): title 32.00 px from the left (10 + 18 icon + 4) and 10.00 px from
    the right: icon and title centered together with the left padding equal to the right one, the iOS layout of
    `CYLIndexPathButton` (section "the tag cells look the same as iOS"). The emoji stand-ins first measured 38.72 px, because
    an emoji at an 18 px font is about 24.7 px wide; they now sit in the 18 × 18 icon slot.
  A pixel comparison with an iOS screenshot needs a Mac (not available on this machine).

- **Shell DONE (2026-11-15): CYLTabBarController's Mini Program tab bar.** The example's shell is `cyl-tab-bar` of
  CYLTabBarController's `cyl-tabbar-miniprogram` (`CrossPlatform/wechat-miniprogram-cyltabbar`, pinned at `117be52c` (first `460ed89f`; the Mini Program packages are the same at both), the
  React Native example's pin), as the iOS, Flutter and React Native examples use CYLTabBarController: a custom tab bar
  (`app.json` `"custom": true`, `miniprogram/custom-tab-bar/`) with the tabs Tags and Classify and the raised Post button
  with a page of its own between them (`CYLPlusButtonCenterYOffset` -14, the React Native example's `post_normal` /
  `post_highlight` images; drawn PNG tab icons, as a Mini Program has no SF Symbols). The package is not on npm, so
  `node scripts/fetch-cyltabbar.js` checks CYLTabBarController out into `.deps/` (sparse, git-ignored) and copies its `src/`
  to `miniprogram/cyl_components/` (git-ignored; outside `miniprogram_npm`, which Build npm rewrites); `--check` keeps it
  at the pin, and CI runs both. The filter sheet hides the bar while it is open (`cyl_setTabBarHidden`), which otherwise
  covered 确定. The example uses CYLTabBarController's AppID `wx5e29c9d33906f074` (技术清谈), set in the git-ignored
  `project.private.config.json`. Test: `tab-bar-configuration.test.js` reads the example's configuration through
  CYLTabBarController's own reader (Tags, Classify, the Post button with a page); `npm test`: 21 tests pass. In WeChat
  DevTools: `switchTab` to each page selects its tab (`selectedIdentifier` tags / classify / post), the tab bar's
  `select` event switches pages, the sheet opens and confirms with real taps and no console errors.

  <img src="assets/miniprogram-cyltabbar-tags.png" width="240" alt="Mini Program: Tags tab in CYLTabBarController's tab bar with the raised Post button">
  <img src="assets/miniprogram-cyltabbar-post.png" width="240" alt="Mini Program: the Post button's own page, Post selected">
  <img src="assets/miniprogram-cyltabbar-classify.png" width="240" alt="Mini Program: Classify tab selected">

- **Prompt (verbatim):**

  > 修复 Class 文件夹下资源文件名太长 导致 git 相关操作失败的问题。 资源文件 关键词搜 leftBarButton continue
  > 。基于新分支 开始下微信小程序开发。找到docs里面任何提及微信小程序的信息开始开发。找到crossplatorm 相关文件夹，没有就新建，新建或者更微信小程序开发。微信小程序开发者工具Skills ，根据文档

  English: fix the git failures caused by the over-long resource file names under `Class` (search "leftBarButton");
  then, on the new branch, start the WeChat Mini Program development from whatever the docs say about it, in the
  cross-platform folder (create it when missing), using the WeChat DevTools skill.
  Then (shell): "running on the CYLTabBarController AppID wx5e29c9d33906f074 continue".

### DONE (2026-11-15): the Mini Program example is a 1:1 port of the iOS example

- **Prompt (verbatim):** "小程序example层要一比一复刻 continue" (EN: the Mini Program example layer must be a 1:1 copy).
- **Structure:** the iOS example's root tab bar (`makeRootTabBarController`: 场景一：评价筛选, 场景二：搜索分类, the orange
  plus button opening 查询筛选, 样式, 动效) in CYLTabBarController's `cyl-tab-bar`, and one page per iOS screen (20 pages; the
  table in `CrossPlatform/wechat-miniprogram/README.md`). Every string is the iOS example's (`CYLMenuExample.bundle`) or
  the core's (`CYLClassifyMenu.strings`) through `t()` / `tc()`, in Simplified Chinese, Traditional Chinese and English.
- **Data:** the shared `cyl_places.sqlite` (places, the reviews and their keywords), `data.json` (the classify menu), the
  iOS bundle's search discover JSON, animation resources and configuration file, each exported by a script with `--check`.
  The statements are the iOS ones (`CYLMenuLinkageViewController.query`, `CYLReviewQuery`), shown with their values
  (`displayString()`); the plus-menu-filtered case gives the iOS screenshot's row (川菜 · 深圳 ★3.5 ¥226).
- **Components:** `cyl-tag-list` reads the core's style keys and defaults (`CYLMenuStyle`, appearances per state);
  `cyl-tag-cloud` and `cyl-tag-image` port the core's android-tagview list and image tag views; `cyl-tag-button`
  (2026-11-17) is `CYLTagButton` on its own (the icon above or below the title, the badge, `tagButtonView` in model.js,
  not yet opened in WeChat DevTools); animated icons use
  CYLTabBarController's `cyl-lottie-miniprogram` (its lottie-miniprogram fork: the npm 1.0.12 loaded the base64 image
  assets of the "image assets and placeholders" Lottie files but never drew them) and `<image>` for GIF.
- **Verified in WeChat DevTools** (base library 3.18.0, 2026-11-15): all 20 pages open with no console error; real taps
  on the scenario rows, 重置, the filter button, a filter tag and 确认筛选 (20 places in 广州); the 动效 tab matches
  `assets/ios-animation-playback-controls.png` section for section. `npm test`: 103 tests. Package: about 1.2 MB of the
  2 MB main package. A `*` selector in one WXSS file stopped every page from compiling (fixed; WXSS has no `*`).
- **Deviations a Mini Program imposes:** drawn stand-ins for SF Symbols; no SQLite (the statements run on exported rows);
  custom navigation bars where iOS has bar buttons or a title view (the classify filter button and 重置, the reviews
  segmented control, the search fields), placed before WeChat's capsule menu; no PAG or Rive engine (about 0.8 and
  0.7 MB, beyond the main package), so those tags degrade as iOS does without the engines; GIFs ignore the speed slider;
  no VoiceOver announcements or custom actions; UIMenu and three-field alerts become action sheets or page overlays.
  The automation of WeChat DevTools cannot tap inside custom components, so taps on tags were checked through the
  components' handlers and the unit tests.
  <img src="assets/miniprogram-1to1-scenarios.png" width="240" alt="Mini Program: 查询筛选, the plus button's page">
  <img src="assets/miniprogram-1to1-menu-linkage.png" width="240" alt="Mini Program: 菜单选择 · 数据库联动, 20 places in 广州">
  <img src="assets/miniprogram-1to1-animations.png" width="240" alt="Mini Program: 动效, the iOS animation sections">

- **Phone preview (2026-11-15):** `wechatide auto_preview` pushed the build (978,336 bytes, one package) to the developer's WeChat; checking it on the phone is left to the developer. **Still TODO:** pixel comparisons with iOS screenshots on a Mac. DONE: the `cyl-tag-cloud` property
  warnings (null for unset options; the tag container sample now passes defaults).

### TODO (2026-11-15): Mini Program bugs in the 动效 (Animations) tab

- **Prompt (verbatim):**

  > 文档中记录bug 标记todo tabbar item中的Animations 每当播放动画时 尤其是打开loop开关，滚动上下之后，icon 会漂移，标记bug。同时rive动画图标无法显示

  English: record these bugs in the documents, marked TODO: in the Animations tab, whenever animations play, above all
  with the Loop switch on, the icons drift after scrolling up and down; and the Rive animated icons do not show.
- **BUG 1 (TODO): animated icons drift after scrolling while they play.** Reported on the Animations tab
  (`pages/animations`, iOS `CYLTagAnimationDemoViewController`): play the animations (Play all), especially with Loop
  on, then scroll the list up and down: the icons move away from their tags. Expected, as on iOS: every icon stays in
  its tag while it plays and while the list scrolls. Leads to check:
  - each animated icon is a `cyl-lottie-icon` placed with `position: absolute; left: 0; top: 0` inside its tag
    (`components/cyl-tag-list/cyl-tag-list.wxml`) and draws on a `<canvas type="2d">` inside the page's `scroll-view`;
  - with Loop on the canvases redraw every frame (lottie's `requestAnimationFrame` of the latest canvas, in
    CYLTabBarController's `cyl-lottie-miniprogram`), so a canvas that lags its tag during scrolling shows the most;
  - reproduce on a phone (the build pushed with `auto_preview`) and in WeChat DevTools, compare the canvas's
    `boundingClientRect` with its tag's while scrolling, and try the canvas in normal flow (no absolute position).
- **BUG 2 (TODO): the Rive animated icons do not show.** The Rive section (and the Rive tags of 样式 and the
  configuration demo) shows titles only, while iOS shows the Rive icons. Cause: the Mini Program links no Rive engine
  (`components/cyl-tag-list/animations.js`, `ENGINES = { …, rive: false }`): CYLTabBarController's
  `cyl-rive-miniprogram` (the Rive runtime plus its WebAssembly, about 0.7 MB) was left out to keep the 2 MB main
  package, and a tag whose engine is missing falls back to its image, or to its title when it has none. Fix to do:
  link `cyl-rive-miniprogram` (install it with `scripts/fetch-cyltabbar.js`, register its component, copy
  `rive.wasm.br` where the package expects it, set `rive: true`), within the size limit (the package is 978 KB
  now; move heavy resources to a subpackage if needed); the same applies to PAG.
- **Status (2026-11-15):** BUG 2 FIXED and seen in WeChat DevTools: Rive is linked (`cyl-rive-miniprogram` installed by
  `scripts/fetch-cyltabbar.js`, the .riv files exported as `data/animations/rive/*.riv.bin`, the tags' animationOptions
  passed in the path's fragment); both Rive sections draw their icons. BUG 1: FIXED, seen in WeChat DevTools (Loop on, Play all,
  four scrolls while every icon loops: Lottie, PAG and Rive icons stay in their tags): Lottie icons now play in CYLTabBarController's `cyl-lottie` (in DevTools an image of
  the canvas, as `cyl-rive`, which did not drift), and the Animations page scrolls the page itself with a sticky
  header instead of a nested `scroll-view`. Left: the same check on a phone.

### Mini Program bugs (2026-11-15): search results, tab bar selection, transparent tags

- **Prompt (verbatim):**

  > 新增三个bug到 docs文档，第一个输入搜索，点开搜索按钮 不仅要更新搜索被选项，还要显示点击搜索后应该展示的搜索结果，如果搜索结果为空应该展示空的占位图。tabbar item点击事件异常 有时候 页面切换了，但tabbaritem没更新。图中都有tag的背景色都不能是透明。修改tag 默认背景色禁止透明色。continue

  English: add three bugs to the docs: (1) typing a search and tapping 搜索 must not only update the recent searches but
  also show the search results, and an empty placeholder when there are none; (2) the tab bar item tap is unreliable:
  sometimes the page changes but the tab bar item does not; (3) no tag in the screenshots may have a transparent
  background: change the tags' default background so that it is never transparent.

  <img src="assets/request-miniprogram-search-discover-transparent-tags.png" width="220" alt="Request: search discover after 搜索, white tags, no results">
  <img src="assets/request-miniprogram-tab-bar-out-of-sync.png" width="220" alt="Request: 脉脉搜索 shown while the 样式 tab is selected">
  <img src="assets/request-miniprogram-review-filter-tags.png" width="300" alt="Request: the review filter tags">

- **BUG 1, DONE: search results and the empty placeholder** (`pages/search-discover`). 搜索, the keyboard's search
  key, a recent search or a topic now also shows the results: the discover topics and sample searches of the page's
  JSON (the current language) containing the query, ignoring case; the user's own recent searches are not results
  (the query would always find itself). No match shows the placeholder (a magnifying glass, 没有找到“%@”的相关结果, a
  hint); clearing the field shows 最近搜索 and 发现 again. iOS records the query only, so these strings are the
  Mini Program's (en, zh-Hant in `discover-model.js`). Checked in WeChat DevTools (English): typed "test" + a real tap
  on 搜索 lists "VoiceOver test checklist"; "咖啡" shows the placeholder. Test: `search-discover.test.js`.
- **BUG 2, DONE: the tab bar item did not follow the page.** Every tab page has its own custom tab bar; a tap selects
  inside `cyl-tab-bar` without changing the wrapper's `selectedIdentifier`, and `syncWithRoute` skipped the update
  when that stale value already named the page, so a bar whose tab had been tapped kept the tapped tab after coming
  back (the screenshot: 脉脉搜索 with 样式 selected). `syncWithRoute` now always calls `cyl_selectIdentifier`, and a
  failed `switchTab` selects the current page's tab again. Checked in DevTools: 样式 selected on search-home's bar,
  switch to 样式 and back: the bar shows 搜索分类.
- **BUG 3, DONE: tag backgrounds are never transparent.** `cyl-tag-list`'s default normal and disabled backgrounds
  are UIKit's systemGray6 `#F2F2F7` instead of white (white tags on the white list looked transparent), and a
  configured clear / transparent / zero-alpha background falls back to it (`opaqueBackground`); `cyl-tag-cloud`'s
  default, the search discover pills and the search page's tags too. The review filter keeps its own `#F5F5F5`
  (`reviewFilterStyle`), opaque. Tests: `tag-list-style.test.js`, `tag-cloud-model.test.js`.

  <img src="assets/miniprogram-search-empty-placeholder.png" width="220" alt="Mini Program: no results, the placeholder">
  <img src="assets/miniprogram-search-discover-opaque-tags.png" width="220" alt="Mini Program: recent searches with an opaque fill">

### Mini Program bug (2026-11-15): PAG animations do not show

- **Prompt (verbatim):** "新增bug 记录，pag 动画显示异常。请解决后继续" (EN: record a new bug: the PAG animations display
  wrongly; fix it, then continue).
- **Cause:** the PAG tags (the 动效 tab's PAG section, the PAG choice of 样式, the configuration demo) showed titles only:
  no PAG engine was linked, because libpag (about 0.96 MB with its WebAssembly) did not fit the 2 MB main package next
  to Rive, and the PAG files are not in the repository (iOS fetches them too).
- **Fix, DONE:** CYLTabBarController's `cyl-pag-miniprogram` (libpag 4.5.85) and the PAG files go to the `engines`
  code subpackage (`app.json` `subpackages`, preloaded for 动效 and 样式 by `preloadRule`); the icon component uses
  `cyl-pag` through async subpackage loading (`componentPlaceholder`: a view until it arrives). The files come from
  `scripts/fetch-animation-resources.py PAGResources` (pinned, SHA-256 checked, as for iOS) and
  `scripts/fetch-cyltabbar.js` copies them as `engines/pag/*.pag.bin` (git-ignored); the registry lists the pinned names
  of `pag-resources.json`; CI fetches them before `--check`. Seen in WeChat DevTools: the PAG section matches
  `assets/ios-animation-playback-controls.png` (Home, Health, Posts, Me, 动效一, 动效二), playing and looping.

  <img src="assets/miniprogram-animations-pag-rive-loop.png" width="240" alt="Mini Program: Lottie, PAG and Rive icons looping, in their tags after scrolling">

### TODO (2026-11-15): the Mini Program tag list as an npm library (cyl- prefix)

- **Prompt (verbatim):** "在跨端相关文档中标记TODO：小程序封装成库 cyl- 开头的小程序库，用 npm 打包加「构建 npm」实际验证过。提醒我的话先运行 ! npm login。"
  (EN: mark a TODO in the cross-platform documents: package the Mini Program as a library named with the cyl- prefix,
  packed with npm and actually verified with WeChat DevTools' "Build npm"; remind the user to run `npm login` first.)
- **Requirements:** (1) a Mini Program npm package with the `cyl-` prefix (e.g. `cyl-tag-list-miniprogram`, like
  CYLTabBarController's `cyl-tabbar-miniprogram`) holding `components/cyl-tag-list` (model, symbols, animations,
  `cyl-lottie-icon`), `cyl-tag-cloud` and `cyl-tag-image`, with a `miniprogram` field and the Lottie / Rive / PAG
  engines as dependencies or optional packages; (2) `npm pack`, then install the tarball in the example and run
  WeChat DevTools' Build npm (`wechatide build_npm`), and check the example's pages use the built package from
  `miniprogram_npm`; (3) publish with `npm publish` after `npm login` (the maintainer runs `! npm login` first);
  (4) README with install, Build npm and usage.
- **Steps 1, 2 and 4 DONE (2026-11-16); step 3 (publish) TODO.**
  - **Package:** `CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram` (0.1.0, MIT like
    `react-native-cyl-tag-list`): `miniprogram_dist/` holds `cyl-tag-list` (model, symbols, animations),
    `cyl-tag-cloud`, `cyl-tag-image`, `locale.js` (the language and `tc()`), `core-strings.js`, `core-tables.js`
    (now written there by `scripts/export-miniprogram-data.py`) and `index.js`; `"miniprogram": "miniprogram_dist"`,
    and `exports` maps `cyl-tag-list-miniprogram/<file>` to the same files under Node, so the unit tests and the Mini
    Program require the same paths.
  - **Engines stay in the app, deviating from requirement (1):** the package links no animation engine.
    CYLTabBarController's cyl-lottie / cyl-rive / cyl-pag are not on npm, and cyl-pag must live in the example's
    `engines` subpackage for the 2 MB main package. Instead, `animations.js` takes the app's files and engines through
    `configure({registry, assets, engines})`, done by the example's `utils/tag-animations.js` from `app.js`, and
    `cyl-tag-list` declares the abstract node `cyl-animation-icon` (`componentGenerics`, default: an empty slot). The
    example's pages pass `generic:cyl-animation-icon="cyl-lottie-icon"`, and `components/cyl-lottie-icon` stays in
    the example.
  - **Example:** depends on the package with `file:packages/cyl-tag-list-miniprogram` (the example's own package is
    now `cyl-tag-list-miniprogram-example`). `project.config.json` sets `packNpmManually` with `packNpmRelationList`
    (`./package.json` → `./miniprogram/`), and `miniprogram_npm/` stays git-ignored. Every page and test requires
    `cyl-tag-list-miniprogram/...`, and `utils/i18n.js` reads the language from the library's `locale.js`, so the
    tags and the example agree.
  - **Verified:** `node scripts/verify-package.js` runs `npm pack` (`cyl-tag-list-miniprogram-0.1.0.tgz`, 26 files,
    42 193 bytes), checks the tarball holds exactly `package.json`, `README.md` and `miniprogram_dist/`, then installs
    the tarball (a copy, not the link) and compares every file with its source. WeChat DevTools' Build npm
    (`wechatide build_npm`) then built `miniprogram_npm/cyl-tag-list-miniprogram` (24 files, no warnings, 1.4 s). On
    the simulator, these pages render from it: Animations (engine "linked", Lottie and PAG icons through the
    generic), TagViewGroup (image tags) and TagView Sample (tag cloud). The console shows no errors. `npm test`: 105
    pass, both with the link and with the installed tarball. CI (`miniprogram.yml`) now runs `npm install` and
    `verify-package.js`.
  - **Publish (TODO):** the maintainer runs `! npm login`, then `npm publish` in `packages/cyl-tag-list-miniprogram`
    (`npm whoami` on 2026-11-16: not logged in).

## HarmonyOS port (2026-11-16)

- **Prompt (verbatim):** "合并pr 新建pr 开始鸿蒙端开发，在新建跨端文档，标注鸿蒙系统版本，新建表格，列出iOS版本存在的API， 在新建表格列出iOS端example 层所有演示，每个表格的第二列为鸿蒙对应实现，默认填TODO 鸿蒙系统软件开发过程中需要实时打分，两个表格一起打分。移除所有todo为满分。每每完成一个功能移除一个todo，一直到满分为止。"
  (EN: merge the PR, open a new PR, start the HarmonyOS work. In a new cross-platform document, state the HarmonyOS
  version. Add one table of the iOS API and one of every iOS example demo, each with the HarmonyOS counterpart in
  column two, TODO by default. Score both tables together, live: full marks means no TODO left. Remove one TODO per
  finished feature until full marks.)
- **Document:** [harmony.md](harmony.md), generated by `harmony/scripts/harmony_parity.py` from the Swift core and
  `harmony/parity-map.json` (`--check` keeps it in step, `--todo` lists what is left).
- **Result (2026-11-16): 100 / 100** in [harmony.md](harmony.md): 785 API rows (13 `init?(coder:)` and 4
  accessibility-action rows N/A, each with its reason) and 22 / 22 demos. Built on Windows with
  `harmony/scripts/build.sh` (HAR and HAP, two BUILD SUCCESSFUL); engines: `@ohos/lottie` 2.0.38,
  `@tencent/libpag` 4.4.31 (newest for API 12), `@ohos/rive` 1.0.4, GIF through ImageKit.
- **TODO: run it** (full-marks standard and score: [harmony-verification.md](harmony-verification.md)). Nothing has run on a device or emulator yet (no emulator image on this machine). To do on the
  Mate 70 Pro emulator: `harmony/scripts/ui-test.sh`, screenshots of every screen next to iOS
  (`screenshots.md`), and the checks the ports listed: Rive state-machine options, PAG loading from a rawfile
  folder, GIF decoding, Lottie's last frame on first load, the classify menu and filter panel layout. Known
  differences: Chinese texts only (no en / zh-Hant switch in the example yet), SF Symbol images have no
  HarmonyOS counterpart, Rive has no playback speed.

## DONE (2026-11-19, `feat/harmony`): the Flutter example's Android tab bar from CYLTabBarController's Flutter plugin

- **Context:** `flutter/cyl_tag_list/example/lib/main.dart` switches its two pages (动效图标, 菜单) with Material's
  `NavigationBar`. CYLTabBarController ships a Flutter plugin, `CrossPlatform/flutter_cyltabbar` (widget `CYLTabBar`,
  the native Android tab bar as a platform view), at the commit every platform pins, `b376c278`.
- **Requirements:** on Android the example's tab bar is `CYLTabBar` from `flutter_cyltabbar` (pinned at the same
  CYLTabBarController commit as the other pins); the pages stay the example's; other platforms keep what they have
  unless the change needs them too. Checked on the Android emulator with a labeled screenshot.
- **Prompt (verbatim):** "本项目 flutter android 端的tabbar请改用引用CYLTabBarController的flutter端实现"
- **Prompt (English):** "In this project, make the Flutter Android tab bar use CYLTabBarController's Flutter
  implementation."
- **Result (`12171ec8`):** on Android `HomePage` builds `CYLTabBar` (`flutter_cyltabbar`, a git dependency of
  `example/pubspec.yaml` at `b376c278`, `path: CrossPlatform/flutter_cyltabbar`) with the example's Lottie tab icons
  (`file:///android_asset/flutter_assets/assets/tab_*_animate.json`); `onTabSelect` switches the `IndexedStack`. iOS and
  HarmonyOS keep Material's `NavigationBar`. `MainActivity` is a `FlutterFragmentActivity` (the plugin needs one). The
  plugin compiles CYLTabBarController's Android library from its checkout, so the `cyl.tabbar.libs` aar folder is gone;
  `cylAnimatedItemProvided=true` keeps one copy of the animated item (it comes with `com.cyl:classifymenu`).
- **New pin:** the pubspec `ref:` is a CYLTabBarController pin; `scripts/cyl-tabbar-latest-commit.sh --check`, AGENTS.md
  and the `cyl-dependency` skill now include it.
- **Tests:** `flutter analyze` clean; integration tests 2 / 2 on the Android emulator and 2 / 2 on the iPhone 17 Pro
  simulator (iOS 27.2); iOS builds with the plugin's pod. `integration_test` cannot tap a native view, so on Android the
  classify menu test opens the app on the Menu tab (`ExampleApp(initialTab:)`); a real tap was checked with adb.
- **Rive tags at rest:** on this emulator (API 35 arm64, software GLES) the Rive row is empty on some launches with or
  without this change (before: 2 of 3 launches drew it, after: 2 of 3; release build of `12171ec8`: 3 of 3); Play all
  always draws it.
- **Evidence** (Android 15 API 35 emulator `CYL_API35_arm64`, 1080 × 2400, 420 dpi, macOS 27.3, Flutter 3.47.9,
  CYLTabBarController `b376c278`, 2026-11-19 06:19 NZDT): launch, then a tap on the Menu tab:

  <img src="assets/flutter-android-cyltabbar.png" width="600" alt="Flutter on Android: CYLTabBar at launch and after a tap on the Menu tab">

## TODO (2026-11-19, `feat/harmony`): the default tab bar height is the system one, on every platform

- **Context:** compared on the Android emulator, the Flutter example's system bar (Material 3 `NavigationBar`) is
  80 dp tall and CYLTabBar 49 dp (`CYLConstants.CYLTabBarHeight = 49f`, the iOS UITabBar 49 pt reused), 31 dp shorter.
  CYLTabBarController's defaults (its session, 2026-11-19): iOS UITabBar (already the system height), Android 49 dp
  (system 80 dp), HarmonyOS 49 vp (system `Tabs` 56 vp), mini program 50 px; React Native and Flutter inherit the native
  value.
- **Requirements:** with no custom height, the tab bar's default height is the platform's system tab bar height, on
  every platform; a custom height still wins. The core is CYLTabBarController (owned by the
  "Mac-CYLTabBarController文件夹" session, task logged in its `9b0a5084`); this project moves every pin to the commit
  that brings it and checks the Flutter Android example again.
- **Prompt (verbatim):** "对比两个：cyltabbar与系统tabbar高度差异，如有必要在cyltabbar中的core代码实现。用户如果没有自定义，那么默认高度为系统tabbar高度。该默认行为适用于所有平台"
- **Prompt (English):** "Compare the two: the height difference between the CYL tab bar and the system tab bar; if
  needed, implement it in CYLTabBarController's core. When the user sets nothing, the default height is the system tab
  bar height. This default applies to every platform."
- **Measurement** (Android 15 API 35 emulator, 1080 × 2400, 420 dpi, bottom gesture inset 63 px = 24 dp; top edges by a
  pixel scan: 2127 px before, 2208 px after):

  <img src="assets/flutter-android-tabbar-height.png" width="400" alt="Tab bar height on Android: Material 3 NavigationBar 80 dp vs CYLTabBar 49 dp">
- **Blocked (2026-11-19):** waiting for CYLTabBarController. Its session queued the height change after its Swift
  migration and asked to keep every pin at `b376c278` until it sends the commit.

## TODO (2026-11-19, `feat/harmony`): every TODO below 100 to 100; Mini Program CI red since `b1500779`

- **Context:** relayed by the "Mac-CYLSearchViewController文件夹" session to every session active today. A sweep of
  docs/ on this branch found: (1) the Mini Program CI fails on every commit since `b1500779` with "Out of date (run
  scripts/export-miniprogram-data.py): strings.js": the iOS drag-to-reorder demo added example strings that the
  generated `miniprogram/data/strings.js` did not get; (2) stale TODO notes in `rive.md` and `component-architecture.md`
  that later work already closed; (3) `android-api.md` 791 / 792: the row `CYLTagButton (CYLCollectionCellStyle)` has no
  counterpart in `android/merged/api-map.json` (its method row does: `CYLTagButton.cylApply`).
- **Requirements:** regenerate `strings.js` and turn the Mini Program CI green; mark the closed notes DONE with their
  evidence; hand the Android row to the session that owns `android/` (Windows); write down what is blocked and why.
- **Prompt (verbatim):** "向所有今天还在活跃session…继续完成TODO 完成评分不到100的任务，一直到满分为止"
- **Prompt (English):** "To every session still active today: continue the TODOs; finish every task whose score is below
  100, until it reaches full marks."
- **DONE (2026-11-19):** (1) `d846709c` regenerates `strings.js`; the Mini Program CI passes again at `d846709c` and
  `bc4e4545` (failed on every commit from `b1500779` to `e4a69356`). (2) Closed notes marked DONE in `rive.md` and
  `component-architecture.md` (`d846709c`). (3) The Windows session mapped the Android row in `9e9180d7`:
  `android-api.md` 792 / 792 = 100, `android-ios-api.md` 736 / 736 = 100. Still open, owned elsewhere or blocked: the
  default tab bar height (waits for CYLTabBarController), Android `CYLRightImageButton` / `CYLMultipleFilterHeaderView`
  on `CYLTagButton` and the Android drag demo (Windows session), checks on a real HarmonyOS device, a real iPhone
  (VoiceOver) and a phone (mini program BUG 1), and `npm publish` (needs the owner's npm login).

### DONE (2026-11-19, `feat/harmony`, Windows session): HarmonyOS and the mini program follow the iOS `25cb2ed0` tag rules, 100/100

- **Context:** the Mac session's `25cb2ed0` changed three things in the iOS core, all to match AndroidTagView: the new
  `CYLMenuStyle.imageFillsTagHeight` (a leading image drawn as a circle as tall as the tag, at its leading edge);
  `maximumTitleLength` now keeps `max − 3` characters plus "..." (23 gives "Welcome to use Andro...", where it used to keep
  `max` plus "..."); `CYLTagRowAlignment.trailing` now starts each row at the trailing edge with its first tag
  (`container_gravity="right"`), where it used to keep the left-to-right order and only align the row right. Android
  already behaved so.
- **HarmonyOS** (`harmony/classifymenu`): `CYLMenuStyle.imageFillsTagHeight` and `fillsTagHeight(iconSize)`;
  `CYLTagButtonMetrics.width` / `heightForTitle` and `CYLTagButton.layOutTagHeightImage` as on iOS; `displayedTitle` keeps
  `max − 3`; trailing rows mirrored in `CYLCollectionViewLeftAlignedLayout` and `CYLTagListState`. Host tests 63 / 63 (new
  `imageFillsTheTagHeightAtTheLeadingEdge`, the truncation test updated), `harmony/scripts/build.sh` OK, `docs/harmony.md`
  839 / 839.
- **Mini program** (`cyl-tag-cloud`, the AndroidTagView port): `imageFillsTagHeight` (the icon as tall as the tag, over the
  insets), `max − 3` truncation, trailing rows as `flex-direction: row-reverse`; the Container sample's first container
  uses the avatar style, as iOS's `CYLTagContainerSample` does. `npm test` 147 pass; WeChat DevTools:

  <img src="assets/miniprogram-container-android-parity.png" width="500" alt="Mini program Container sample: trailing rows, title cap, avatars as tall as the tag">

- **Android drag demo withdrawn:** `CYLTagReorderScreen` (copy of the removed iOS `CYLTagReorderDemoViewController`) is
  reverted; the drag example on every platform is the Container sample (`docs/android.md`).

- **Still blocked (2026-11-19, re-checked):** CYLTabBarController's newest commit `5744917d` has the task logged
  (`9b0a5084`) but no default-height change yet; nothing to pin. The pins follow when it lands.

