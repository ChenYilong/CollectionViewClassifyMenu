---
title: Android (Kotlin) ports and the merged library
date: 2026-11-12
tags: [android, kotlin, tagview, api-parity]
---

# Android (Kotlin)

This document tracks the Android work in `android/`: Kotlin transcriptions of three Android tag libraries, the
library merged from them, its API table against the iOS core, and the Android ports of the iOS examples.

## TODO (2026-11-12): Kotlin ports, merged library, API parity with iOS, iOS examples on Android

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
- [ ] Step 6: iOS examples ported, screenshots, README Android chapter. Progress: the demo app (Classify, Filter tabs)
  and the TagCollectionView demo (Tags tab) are ported; the tab bar scrolls (one tab per example); next: the Menu
  example (`Example/CYLMenuExample`), then the Tag editor (`Example-Swift`). Plan (2026-11-12):
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

- **Status:** TODO, after step 6 (tasks run in the order given).
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
