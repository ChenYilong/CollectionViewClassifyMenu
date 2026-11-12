---
title: Android (Kotlin) ports and the merged library
date: 2026-11-12
tags: [android, kotlin, tagview, api-parity]
---

# Android (Kotlin)

This document tracks the Android work in `android/`: Kotlin transcriptions of three Android tag libraries, the
library merged from them, its API table against the iOS core, and the Android ports of the iOS examples.

## DONE (2026-11-13, logged as TODO 2026-11-12): Kotlin ports, merged library, API parity with iOS, iOS examples on Android

### Context

- Branch `feat/android-kotlin`, created from `claude/intelligent-curie-1etnx5` (PR #15 waits for CI there).
- Sources (cloned read-only for reference; not committed):
  - [kaedea/android-tagview](https://github.com/kaedea/android-tagview) at `b546a5f` (2016-06-15), Apache-2.0,
    Java, 6 library files + 4 sample activities.
  - [shellljx/TagViewGroup](https://github.com/shellljx/TagViewGroup) at `befcd9b` (2019-03-09), **GPL-3.0**,
    Java. Decision (user, 2026-11-12): do not transcribe its code; reimplement its public API and behavior in
    Kotlin, credit it as the API reference, so `android/` keeps this repository's license.
  - [whilu/AndroidTagView](https://github.com/whilu/AndroidTagView) at `75a3bba` (2019-03-16), Apache-2.0, Java,
    4 library files + 1 sample activity.
- CYLTabBarController's Android library: `CYLTabBarController/Example-Android/cyltabbar` (namespace
  `com.cyl.tabbar`, depends on `:tabpages`), AGP 8.7.3, Kotlin 2.0.21. The repository root is not a Gradle build
  and has no JitPack configuration, so a Maven coordinate by commit is not available. Plan: `android/merged`
  pins the commit in `gradle.properties`; `settings.gradle.kts` clones CYLTabBarController at that commit into a
  cache and includes its `Example-Android` build; it falls back to the local sibling folder when the clone fails.
- Toolchain: JDK 17 (`~/develop/jdk/jdk-17.0.21+9/Contents/Home`), Android SDK `~/Library/Android/sdk`,
  Gradle 9.3.1. Gradle fails on this exFAT volume (`._*` files), so builds run in a mirror under `/tmp`.
- Only Android code and docs change: no iOS code is modified.

### Requirements

1. `android/` with one folder per repository (`android-tagview`, `TagViewGroup`, `AndroidTagView`) and a fourth,
   `merged`.
2. Transcribe each project into its folder, all in Kotlin (library and sample).
3. Merge the three into one project in `merged`: keep every public API, one example app. The example uses
   CYLTabBarController's Android tab bar, one tab bar item per example; depend on CYLTabBarController's newest
   commit by commit reference (Gradle or Maven), else a local path.
4. A table in `docs/` of every public iOS API, with the matching public API of `merged` in the second column.
5. Add the APIs missing from `merged`; mark rows not aligned with `TODO`; full marks when every iOS API is
   aligned; re-score in this document each time `merged` gains an API, until full marks.
6. Port every iOS example to `merged` (a translation; the iOS code is not changed), using the Android APIs of
   the table. Take screenshots, update this document and the Android chapter of the README.

### Prompt (verbatim)

> 注意本任务仅仅修改android代码，不要改iOS代码。在本项目中新建文件夹命名为 android ，下面的代码 每一个仓库 创建一个文件夹，并创建第四个文件夹命名为merged https://github.com/kaedea/android-tagview   https://github.com/shellljx/TagViewGroup     https://github.com/whilu/AndroidTagView 第二步骤：分别将这三个项目在各自文件夹中做代码转录，全部翻译为kotlin语言。第三步骤：将以上三个文件夹里的kotlin代码合并为一个项目，保留所有api接口，并将example合并为一个。使用CYLTabBarController 的android端作为展示的功能划分，采用gradle或者maven指向CYLTabBarController 最新提交，找到gradle或者maven使用commit引用的方式集成，如果不行就采用本地路径引用。一个example一个tabbaritem区分。第四步骤：在docs在合适的文档或创建文档，列出iOS端所有的公开api，第二列 ，列出找到的在该merged文件夹下所有的公开api的对应项。第五步，将缺失merged文件夹缺失的API对齐。在该表格未对齐的地方标注TODO如果iOS端和android能完全对齐所有api就是满分，merged文件夹每次新增一个api就在该文档中打分，一直达到满分。第六步骤：将iOS端的example全部移植到merged文件夹，注意是翻译，不要改iOS代码。使用上面提到的表格中android的api实现。并截图更新文档，readme 在android章节。

English: Change only Android code, not iOS code. Create a folder `android` in this project, one folder per
repository below, and a fourth named `merged` (kaedea/android-tagview, shellljx/TagViewGroup, whilu/AndroidTagView).
Step 2: transcribe each project into its folder, all translated to Kotlin. Step 3: merge the Kotlin code of the
three folders into one project, keep all API interfaces, and merge the examples into one; use CYLTabBarController's
Android side for the feature split, point Gradle or Maven at CYLTabBarController's newest commit (by commit
reference, else a local path); one tab bar item per example. Step 4: in a suitable or new document in docs, list
every public iOS API and, in the second column, the matching public API found in `merged`. Step 5: align the APIs
missing from `merged`; mark unaligned rows with TODO; full marks when iOS and Android align completely; score the
document each time `merged` gains an API, until full marks. Step 6: port all iOS examples to `merged` (translate,
do not change iOS code), using the Android APIs of the table; take screenshots, update the docs and the README's
Android chapter.

### Status

- [x] Step 1: folders (`android/android-tagview`, `android/TagViewGroup`, `android/AndroidTagView`; `merged` next)
- [x] Step 2 (2026-11-12): Kotlin transcriptions of android-tagview (`13ba988`) and AndroidTagView (`643ba99`),
  the TagViewGroup API reimplementation (`b510e7d`). Each folder builds its sample (`assembleDebug`); the three
  samples run on the API 35 emulator (screenshots below). Samples opt out of Android 15's edge-to-edge
  enforcement (`values-v35`), as their original target SDKs never drew under the system bars.
- [x] Step 3 (2026-11-12): `android/merged`. The `library` module keeps every public API of the three libraries in
  their own packages (`me.kaede.tagview`, `co.lujun.androidtagview`, `com.licrafter.tagview`), copied by
  `android/scripts/sync_merged_sources.py` (only the `R` import changes; `--check` reports drift). The `example`
  app is a CYLTabBarController built from `assets/cyl_merged_tabbar.json`: tabs TagView, TagContainer, TagViewGroup,
  About, pages registered by page ID, and a plus button (New) whose page is the TagViewGroup editor.
  CYLTabBarController by commit: `gradle.properties` pins `cyl.tabbar.commit` (now `1fddee2`, the newest commit on
  any branch); `settings.gradle.kts` checks that commit out (sparse, blobless clone into `.cyltabbar/`) and includes
  its `Example-Android` build in place of `io.github.chenyilong:cyltabbarcontroller`; when the clone fails it uses the
  local folder `cyl.tabbar.localPath`. Verified on the API 35 emulator (screenshots below).
- [x] Step 4 (2026-11-12): [android-api.md](android-api.md) lists all 678 public symbols of the iOS headers
  (classes, protocols, categories, properties, methods, enum values, constants, functions, typedefs, macros) with
  their Android counterpart, generated by `android/scripts/ios_public_api.py` from the headers and
  `android/merged/api-map.json` (`--check` reports a stale table). First alignment: the picture tags
  (`CYLImageTagGroupView` and friends) map to the TagViewGroup API.
- [x] Step 5: missing APIs: 709 / 709 aligned, full marks (score history below; 29 library unit tests)
- [x] Step 6 (DONE 2026-11-13): iOS examples ported, screenshots, README Android chapter (README "Android / Android 版（Kotlin）", one stitched image of key details, labeled; `assets/android-key-screens.png`). Progress: the demo app (Classify, Filter tabs)
  the TagCollectionView demo (Tags tab) and the Tag editor (`Example-Swift`, Editor tab: Edit tags with the editor
  sheet, Fold styles with the configuration files) are ported; the tab bar scrolls (one tab per example). Menu example
  (`Example/CYLMenuExample`, Menu tab, DONE): the tab holds a home list with one row per part of the iOS
  example's tab bar. Scenario 1 (review filter) is DONE: the product screen (keywords, two rows) and the review list
  (several filters, "全部" exclusive, chevron fold, In memory / Network / Database modes, the request URL and the SQL
  shown), reading the reviews from the shared database. Scenario 2 (search categories) is DONE: the search home, and
  the category screen with a search field in the bar and a nested CYLTabBarController at the bottom (people, feeds,
  gossip, jobs; jobs with the job category sidebar and the industry menu); a tag fills the search field; the app's
  tab bar hides while a screen is pushed (`hidesBottomBarWhenPushed`). Fix on the way: the kaede `TagView` gave its
  tags the view ids 1, 2, 3…, so the nested tab bar's page container (found by id) landed inside a tag; the ids are
  generated now (merged library and `android-tagview`). Styles is DONE: the preview tags and every action of the iOS
  screen (icon and title colors, font, spacing, sizes, insets, position adjustments, content, layoutCentered,
  selected image, background, border, corner radius, margin, animation speed, reset), and animated icons through
  CYLTabBarController's engine (lottie-android, libpag and rive-android added to the example; GIF needs none):
  Lottie, GIF and PAG play. Core fix on the way: `CYLTagButton` took an asset URL (`file:///android_asset/…`) for a
  missing file and never animated it. The rows that open other screens (configuration, tag cloud, the three Android
  samples) waited for the plus page (DONE below). Rive (was TODO, DONE with Animations below). Note: PAG needs GPU rendering on the
  emulator (`-gpu host`); with `swiftshader_indirect` its icons stay empty and frames take seconds. Animations is DONE:
  the configuration-dictionary tag list of the iOS screen (Lottie plain / with image assets / green, PAG, Rive,
  icons.riv on dark tags, GIF, static images), "Play all", the speed button (1x, 2x, 0.5x) and the tapped tag in the
  status line; the asset catalog's PNGs (TabBarIcon, LottieImages) are synced into generated drawables at build time
  (no copies committed). Fixes on the way: (1) core, `CYLTagButton` measured its children as UNSPECIFIED and only laid
  them out, so the engine's Rive view (a RiveAnimationView at MATCH_PARENT inside a FrameLayout) stayed 0 × 0: this
  was why Rive icons were empty; it now measures each child at its frame. (2) core, Lottie files with image assets
  crashed ("You must set an images folder"): the tag button gives Lottie views an image delegate that loads the
  drawable of the same name, as Lottie on iOS loads images by name. (3) CYLTabBarController, deselecting a Rive tag
  whose state machine has no "active" input crashed on rive-android's render thread: fixed upstream in
  [CYLTabBarController PR #790](https://github.com/ChenYilong/CYLTabBarController/pull/790) (`4639a0c`, test
  `CYLRiveInputsTest`), and the Android pin moved to that commit. TODO: the iOS Podfile pins (root `Podfile` at
  `53766de`; `Example/` and `Example-Swift/` at `0e69250`, see issue-progress.md) are not moved to `4639a0c` in this
  Android-only task. The plus page (the iOS example's plus button page, a fifth row "Filters" in the Menu home, since
  the merged app's plus button belongs to the TagViewGroup editor) is DONE: the query scenarios list (the review
  filter in its three modes, the menu linkage, search discover, and the tables with their row counts) and the menu
  linkage are DONE: the classify menu (single choice) and the multiple-choice filter on one screen, both building
  the `places` SQL on the shared database, the choices saved in a `selections` table (an app-local
  `cyl_selections.sqlite`, because the shared file is read-only) and restored when the screen opens again. Search
  discover is DONE: no navigation bar; a search field with image search and Search; recent searches folded to two rows
  (the chevron as the last tag, a clear button); discover two per row with ellipses, localized "hot" pictures and a More
  button ("Refresh topics") that picks others at random (`search-discover.json` of the iOS bundle); hold-to-ask. Core
  addition on the way: `CYLOriginalImageDrawable` / `Drawable.cyl_imageWithRenderingModeAlwaysOriginal()`, the
  counterpart of `UIImageRenderingModeAlwaysOriginal`: tags tint their icons with `iconColor` (as iOS tints template
  images), and a wrapped image keeps its colors (the "hot" picture was a black block). Tag cloud and configuration
  are DONE (the last rows of Styles): the tag cloud in code (`addTagsWithTitles`, `addTag`, `addTags`, click and
  delete handlers) and from `CYLTagListViewTags`; the configuration file (`animated-tags.json`) and dictionary tag
  lists. The three Android library samples (Swift copies on iOS) select the original libraries' tabs (TagView,
  ViewGroup, Container). Core fixes on the way: paths relative to a configuration file ("../Animations/…") resolve
  their ".." (the assets cannot), and "system:<name>" images other than the core's three are the app's drawables
  `cyl_system_<name>` (Android has no SF Symbols; the example provides the ones it uses). The Menu example is DONE.
  The README Android chapter is written (step 6 DONE). Plan (2026-11-12):
  1. Tabs of the merged example, one per example: TagView, TagContainer, TagViewGroup (the three Android originals),
     Menu (`Example/CYLMenuExample`: review filter, search categories, styles, animations, and its plus page, the
     query scenarios), Tag editor (`Example-Swift/CYLTagEditorExample`), Classify demo (the demo app of
     `CollectionViewClassifyMenu.xcodeproj`: `CYLClassifyMenuViewController`, `CYLMultipleFilterController`).
  2. The plus button is raised (its top above the tab bar), per the raised plus button rule.
  3. Translate each Swift screen to Kotlin using only the Android APIs of `docs/android-api.md`; example strings in
     the example's own resources (its lookup helper), not in the library's.
  4. Emulator screenshots per screen (cropped key details, stitched vertically), labeled with platform, Android and
     emulator versions, SDK, commit and time, in `docs/android.md`; then the README Android chapter.

Cross-platform rules (one shared database, the same look as iOS): [cross-platform.md](cross-platform.md).

## TODO (2026-11-12): replace the wording of the Tags tab and remove its keywords everywhere

- **Status:** DONE (this commit).
- **Context:** the Tags tab (the TagCollectionView demo) showed sample data copied from the iOS demo, with an
  inappropriate tag and placeholder text (random letters in section titles and tags), screenshot
  `assets/request-tags-tab-wording.png`. The same words are in `TagCollectionView/TagCollectionView/CYLTagDemoViewController.swift`
  and in commented-out code of `CYLTagView.m`; the shared database does not contain them.
- **Requirements:** replace the wording shown in the screenshot; search the whole project for its keywords and
  delete them from documents, code and the local database; record it here with the screenshot.
- **Result:** the iOS demo (`CYLTagDemoViewController.swift`) and the Android Tags tab use neutral sample data
  (sections 日常安排 / 周末活动, everyday tags); the commented-out sample data in `CYLTagView.m` is removed;
  `git grep` finds none of the keywords in code, documents or data; the shared database never had them. The old Tags
  tab screenshot is replaced (`assets/android-tags-tab.png`).
- **Prompt (verbatim):**

  > 替换截图中的文案，并全项目搜索图片中的关键词，从文档，代码，本地数据库中删除。并在文档中加入android相关文档中附带截图 标注为TODO continue

## TODO (2026-11-12): HarmonyOS NEXT support for Android and the cross-platform components

- **Status:** TODO. Not started: the earlier tasks run first, in the order they were given. When React Native or
  Flutter examples are added, show the classify menu and the multiple filter in tabs of their own, as the iOS and
  Android examples do (request of 2026-11-12, `issue-progress.md`).
- **Context:** the Android library and example (`android/merged`) and the cross-platform components (Flutter and React
  Native, as in CYLTabBarController's `CrossPlatform/`) should also run on HarmonyOS NEXT, which no longer runs
  Android apps.
- **Requirements:**
  1. Support and adapt the Android code and the cross-platform platforms (React Native, Flutter) to HarmonyOS NEXT.
  2. Flutter first; adapt React Native only after the Flutter version passes its tests.
- **Prompt (verbatim):**

  > 找到docs android相关文档写一个英文TODO：android 与跨端平台（REactNative flutter，先flutter，flutter测试通过后再适配 REactNative）支持适配 android 鸿蒙 NEXT系统。

- **Prompt (English):** find the Android document in docs and write an English TODO: support and adapt Android and the
  cross-platform platforms (React Native, Flutter; Flutter first, React Native only after the Flutter tests pass) to
  HarmonyOS NEXT.

## TODO (2026-11-12): open pull requests and issues of the three ported projects

- **Status:** in progress (2026-11-13): the 4 open pull requests are translated and merged; the issue tables (90 open
  issues), the fixes and the scores are in [android-upstream.md](android-upstream.md) (one document for the three
  projects instead of their API documents, so the scores add up in one place). Score: 19 / 90 (android-tagview 100, TagViewGroup 100).
- **Context:** the rule "Upstream projects (translations and ports)" (AGENTS.md, `.agents/skills/cyl-upstream/`). The
  three Kotlin ports translated the default branches of kaedea/android-tagview, shellljx/TagViewGroup and
  whilu/AndroidTagView only. The translations are done, so: translate each open pull request's change and merge it
  into `android/<project>` and `android/merged`; list each project's open issues (issue link, description, status
  `TODO`) in its API document (`android-tagview-api.md`, `tagviewgroup-api.md`, `androidtagview-api.md`); fix them on
  the translated code and score after each fix until 100. TagViewGroup is reimplemented (GPL-3.0): read its pull
  requests and issues as behavior only, copy no code.

## Score history

Aligned iOS symbols / all iOS symbols in [android-api.md](android-api.md), out of 100; one row per change of
`android/merged` that adds Android APIs.

| Commit | Change | Aligned | Score |
| --- | --- | --- | --- |
| step 4 | The TagViewGroup API counts for the picture tags | 56 / 678 | 8.3 |
| batch A | `com.cyl.classifymenu`: value types, `CYLMenuResources` (the iOS `.strings`), keys, parameters, `CYLTagColors`, `CYLTagAppearance`, `CYLMenuStyle`, `CYLTag`, `CYLTagDataSource`, `CYLMenuDataSource` / `CYLMenuDelegate`, `CYLMenuColorFromString`; 10 unit tests | 265 / 678 | 39.1 |
| batch B | Tag list views: `CYLTagButton`, `CYLTagFoldButton`, `CYLTagListCell`, `CYLTagFoldCell`, `CYLTagCreateCell`, `CYLMenuFoldControl`, the left-aligned layout, `CYLTagListView` (sections, folding, selection, tags, deletion, long press, reordering, accessibility) and `CYLTagListView+CYLConfiguration` (keys, JSON / plist files, `CYLMenuAnimationURLWithOptions`, style / appearance / fold control / tag configuration); 19 unit tests | 511 / 678 | 75.4 |
| batch C | Picture tags in `com.cyl.classifymenu` under the iOS names: `CYLImageTagDirection`, `CYLImageTag`, `CYLImageTagGroup`, `CYLImageTagLabel`, `CYLImageTagRippleView`, `CYLImageTagGroupView` (layout, lines, dot, ripple, keyed animations, show / hide, tap / long press / drag, accessibility element with move actions) and `CYLImageTagView` (groups kept apart, edit mode); the mapper now matches one-line enum entries and categories; 23 unit tests | 583 / 678 | 86.0 |
| batch D | The classify menu and the multiple filter: `CYLClassifyMenuViewController` and `CYLFilterBaseController` / `CYLMultipleFilterController` as Fragments, `CYLFilterHeaderView`, `CYLCollectionViewCell`, `CYLIndexPathButton`, `CYLRightImageButton`, `CYLFilterParamsTool`, `CYLFilterCollectionCell`, `CYLMultipleFilterHeaderView`; the categories as extension functions (`View` frame helpers, border, corners, overlay layers, capture; `Bitmap.cyl_blurredImageWithRadius`; `List` / `Map` descriptions; `TextView` button styles); the iOS images copied into the resource bundle; 27 unit tests | 678 / 678 | 100.0 |
| correction | The table missed the pod's other source pattern, `TagCollectionView/TagCollectionView` (`CYLTagView`, `CYLTagGroup`, `CYLTagModel`, `CYLTagCell`, `CYLTagHeaderCell`): 31 more symbols | 678 / 709 | 95.6 |
| TagCollectionView | Those five classes in Kotlin (`CYLTagView.kt`); the TagCollectionView demo is the merged example's Tags tab; 29 unit tests | 709 / 709 | 100.0 |

## Screenshots: Classify and Filter tabs (iOS demo app on Android)

The iOS demo app's two features have a tab each (one feature per tab item), both linked to the local SQLite `places`
table as the iOS example's menu linkage. The plus button is raised (its top above the tab bar). Stacked top to bottom.

- **Platform:** Android (Kotlin, `android/merged/example`).
- **Environment:** macOS 27.3, Android Emulator `CYL_API35_arm64` (sdk_gphone64_arm64, Android 15, API 35),
  compileSdk / targetSdk 35, AGP 8.7.3, Kotlin 2.0.21; CYLTabBarController for Android at `27a7c55`.
- **Repository:** branch `feat/android-kotlin`, the commit that adds this section (see `git log -- docs/assets/android-filter-panel.png`).
- **Taken:** 2026-11-12 18:35 NZDT (UTC+13).

| Screen | Screenshot |
| --- | --- |
| Tab bar: six tabs (TagView, Container, ViewGroup, Classify, Filter, About) and the raised plus button | <img src="assets/android-tabbar-raised-plus.png" width="360" alt="Tab bar with the raised plus button"> |
| Classify tab: single-choice classify menu; the selected tag (云南味道) queries SQLite, 3 of 83 places | <img src="assets/android-classify-tab.png" width="300" alt="Classify tab with linked results"> |
| Filter tab: the filter slides in from the left over most of the screen (北京 and 川菜 selected, Reset / Apply) | <img src="assets/android-filter-panel.png" width="300" alt="Multiple-choice filter panel"> |
| Tags tab: the TagCollectionView demo (`CYLTagView`); the tab bar scrolls, one tab per example | <img src="assets/android-tags-tab.png" width="300" alt="Tags tab"> |
| Editor tab: Edit remarks (the tag editor example's first screen) | <img src="assets/android-editor-remark.png" width="300" alt="Editor tab, remarks"> |
| Editor tab: the editor sheet (search, Recent, My Tags with Manage, several chosen) | <img src="assets/android-editor-sheet.png" width="300" alt="Editor sheet"> |
| Editor tab: Fold styles (every fold control and title style) | <img src="assets/android-editor-fold-styles.png" width="300" alt="Fold styles"> |
| Menu tab, scenario 1: the product screen, review keywords with counts from the shared database | <img src="assets/android-menu-product.png" width="300" alt="Product screen"> |
| Menu tab, scenario 1: the review list, In memory mode, "划算" selected: 3 of 10 | <img src="assets/android-menu-reviews-memory.png" width="300" alt="Review list, memory mode"> |
| Menu tab, scenario 1: Database mode: the filters as SQL on `reviews` / `review_keywords`, 3 matches | <img src="assets/android-menu-reviews-database.png" width="300" alt="Review list, database mode"> |
| Menu tab, scenario 1: Network mode: `GET /reviews?filter=photo&filter=keyword:划算`, the server returns 1 | <img src="assets/android-menu-reviews-network.png" width="300" alt="Review list, network mode"> |
| Menu tab, scenario 2: the category screen, People page, nested tab bar at the bottom (the app's tab bar hidden) | <img src="assets/android-menu-search-people.png" width="300" alt="Search categories, People"> |
| Menu tab, scenario 2: Jobs: the job category sidebar (Product), the industry menu (Finance); a tag filled the search field | <img src="assets/android-menu-search-jobs.png" width="300" alt="Search categories, Jobs"> |
| Menu tab, Styles: the preview tags (Home selected, Disabled) over the actions with their values | <img src="assets/android-menu-styles.png" width="300" alt="Styles screen"> |
| Menu tab, Styles, top to bottom: default; after icon color, title color, background, border, corner radius (0 = capsule); Lottie, GIF, PAG icons | <img src="assets/android-menu-styles-actions.png" width="300" alt="Styles actions and animated icons"> |
| Menu tab, Animations (top): Lottie, Lottie with image assets, green Lottie, PAG; first tag of each section selected | <img src="assets/android-menu-animations-lottie-pag.png" width="300" alt="Animations: Lottie and PAG"> |
| Menu tab, Animations (bottom): Rive (six files), icons.riv on dark tags (Search tapped), GIF, static images; speed 2x | <img src="assets/android-menu-animations-rive-gif.png" width="300" alt="Animations: Rive, GIF, images"> |
| Menu tab, plus page: the query scenarios and the tables (reviews 10, places 83, selections) | <img src="assets/android-menu-query-scenarios.png" width="300" alt="Query scenarios"> |
| Menu tab, menu linkage: 川菜 (classify) + 北京 (filter, modified icon) → SQL → 1 of 83 places; saved and restored | <img src="assets/android-menu-linkage.png" width="300" alt="Menu linkage"> |
| Menu tab, search discover: recent searches (two rows, chevron last), discover two per row with the "HOT" picture | <img src="assets/android-menu-search-discover.png" width="300" alt="Search discover"> |
| Menu tab, search discover after a search, the recent searches expanded and Refresh topics | <img src="assets/android-menu-search-discover-refreshed.png" width="300" alt="Search discover, refreshed"> |
| Menu tab, tag cloud: in code (continents, detailed tag, styled tags) and from CYLTagListViewTags; "Asia" tapped | <img src="assets/android-menu-tag-cloud.png" width="300" alt="Tag cloud"> |
| Menu tab, configuration: from animated-tags.json (Lottie, PAG, Rive, GIF, symbol, disabled) and from a dictionary | <img src="assets/android-menu-configuration.png" width="300" alt="Configuration"> |
| Filter tab after Apply: the icon shows a set filter; region IN (北京) AND tag IN (川菜), 1 of 83 places | <img src="assets/android-filter-results.png" width="360" alt="Filter results from SQLite"> |

## Screenshots

The merged example, top to bottom: the TagView, TagContainer, plus (New), TagViewGroup and About tabs.

<img src="assets/android-merged-tagview.png" width="300" alt="Merged example, TagView tab">

<img src="assets/android-merged-tagcontainer.png" width="300" alt="Merged example, TagContainer tab">

<img src="assets/android-merged-plus.png" width="300" alt="Merged example, the plus button's page">

<img src="assets/android-merged-tagviewgroup.png" width="300" alt="Merged example, TagViewGroup tab">

<img src="assets/android-merged-about.png" width="300" alt="Merged example, About tab">

Kotlin samples on the API 35 emulator, top to bottom: android-tagview, AndroidTagView, TagViewGroup.

<img src="assets/android-sample-android-tagview.png" width="300" alt="android-tagview sample in Kotlin">

<img src="assets/android-sample-androidtagview.png" width="300" alt="AndroidTagView sample in Kotlin">

<img src="assets/android-sample-tagviewgroup.png" width="300" alt="TagViewGroup sample in Kotlin">
