---
title: Android (Kotlin) ports and the merged library
date: 2026-11-12
tags: [android, kotlin, tagview, api-parity]
---

# Android (Kotlin)

This document tracks the Android work in `android/`: Kotlin transcriptions of three Android tag libraries, the
library merged from them, its API table against the iOS core, and the Android ports of the iOS examples.

## DONE (2026-11-16): every tab on Android: opt in to every tab after CYLTabBarController added "More"

- **Context**: CYLTabBarController for Android now follows iOS (UIKit): with more than five view controllers (the
  plus button with its own page counts as one), the bar shows four tabs (three with the plus page) and "More"
  (CYLTabBarController commit `0c35409e`, its TODO A6 in `docs/Android-Library.md`). The report showed seven tabs; the merged example now has nine tabs and the plus button
  and should keep every tab in the
  bar, through CYLTabBarController's new Android-only API.
- **Prompt (verbatim)**: "continue fix todo • There's no CollectionViewClassifyMenu example under Example-Android, so
  I didn't add an opt-in there."
- **Result**: `android/merged/example/src/main/assets/cyl_merged_tabbar.json` sets `"CYLTabBarControllerShowsAllTabs": true`
  (the configuration key of `CYLTabBarController.cyl_showsAllTabs`); the tabs still scroll
  (`cyl_scrollMode = Scrollable`, which also shows every tab). `gradle.properties` pins CYLTabBarController to
  `0c35409e96d81b01150088ec0930f0b9a45204d3`, the newest commit over every branch (`scripts/cyl-tabbar-latest-commit.sh`).
  Merged into `feat/harmony` (pull request 21, 2026-11-17), where every pin then moved to `b5a02862` (docs only).
  Evidence: `gradle :example:assembleDebug` passes against both commits (Linux container, 2026-11-17); the example has no
  unit tests, and the configuration key is covered by CYLTabBarController's `CYLTabBarMoreTest`. **TODO**: an emulator screenshot of the
  whole bar (no Android emulator in the Linux container).

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
  `CYLRiveInputsTest`), and the Android pin moved to that commit. DONE (2026-11-15, all three iOS Podfiles pin CYLTabBarController `117be52c`, issue-progress.md); was TODO: the iOS Podfile pins (root `Podfile` at
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

## DONE (2026-11-12, logged as TODO the same day): replace the wording of the Tags tab and remove its keywords everywhere

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

## DONE (2026-11-16): the HarmonyOS example on an emulator, screenshots in the docs

- **Context:** the 22-demo HarmonyOS example (`harmony/entry`, from `feat/harmony`) had never run on an emulator; its
  verification rows B1–B22 were deferred. The shared emulator (`127.0.0.1:5557`) is used by other sessions.
- **Requirements:** a new emulator of our own; run the HarmonyOS code; update the screenshots in the docs.
- **Prompts (verbatim):** "run our HarmonyOS version code on an emulator and update screenshot in docs", then
  "新开模拟器run our HarmonyOS version code on an emulator and update screenshot in docs" (English: open a new
  emulator, run our HarmonyOS code on it and update the screenshots in the docs).
- **Result:** a new emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, HarmonyOS 6.0.1 image; created like `CYL
  TabBar Test`; a first boot from overlays copied off a running emulator hit a kernel panic, so the disks were made
  fresh). `harmony/scripts/build.sh`, then `harmony/scripts/screenshots.sh` (hdc pinned to the new emulator): 29
  screenshots in `docs/assets/harmonyos-*.jpeg`, listed in [screenshots.md](screenshots.md) with labels;
  [harmony-verification.md](harmony-verification.md): 20 rows DONE (B2–B8, B10, B13–B22, F2, G1), verified 15 → 35 /
  53.
- **Defects found (TODO, in harmony-verification.md):** B1 Chinese tab titles cut off; B9 menu linkage headers and
  tags render as stretched images; B11 animated tags missing in Chinese and dark mode (English works); B12 the PAG
  chip of the dictionary row is empty (`JPAGImageView` fails to load).

## DONE (2026-11-16): CYLTabBarController's tab bar in the ArkTS example

- **Context:** `harmony/entry` uses ArkUI `Tabs` with emoji icons; AGENTS.md wants every example's tab bar from
  CYLTabBarController, made from a configuration file, with a raised plus button that selects a page of its own (the
  React Native HarmonyOS shell already does it).
- **Requirements:** CYLTabBarController's HarmonyOS library (pinned commit, fetched by a script), tabs and plus
  button from `rawfile/cyl_tabbar_configuration.json`, the Post page, localized titles, accessibility; no emulator.
- **Prompt (verbatim):** "continue"
- **Result:** `harmony/entry/src/main/ets/pages/Index.ets` builds `CYLTabBarController` (`cyltabbar`, CYLTabBarController
  `19cbf801`, fetched into `harmony/.deps/` by `harmony/scripts/fetch-cyltabbar.sh`) from
  `rawfile/cyl_tabbar_configuration.json`: Tags, Classify (SVG icons, as the React Native HarmonyOS shell) and the
  raised Post button from `CYLTabBarControllerPlusButton`, which selects the new Post page. Titles come from the
  string resources (`tab_tags`, `tab_classify`, `tab_post`, `plus_page`; four locales); the tab bar sits above the
  system gesture bar; the library carries its own accessibility (labels, selected state). The ArkUI `Tabs` and the
  emoji icons are gone.
- **Evidence:** `assembleHap` of the example and of its UI-test HAP: BUILD SUCCESSFUL; unit tests `Tests run: 6, Pass:
  6`; `scripts/harmonyos-l10n-check.py`: OK. Not run on the emulator (this round has no emulator), so no new screenshot.
- **Branch sync (2026-11-16):** this change was made on `feat/android-kotlin`'s two-tab ArkTS example. `feat/harmony`
  (PR #20) replaced that example with the 22-demo port (ArkUI `Tabs`: Shell, Menu, Samples), so the sync keeps its
  `harmony/` folder as it is. TODO: CYLTabBarController's tab bar in that example (configuration file, raised Post
  button, `harmony/scripts/fetch-cyltabbar.sh` of `83d18b9` as the starting point), agreed with its owner first.

## DONE (2026-11-16): HarmonyOS score sheet, accessibility and localization

- **Context:** the HarmonyOS port (`harmony/classifymenu`, `harmony/entry`, the Flutter and React Native HarmonyOS
  shells) has no score sheet of the iOS API; its strings are partly literals in code; screen-reader support is
  partial. The emulator is not to be used for this round.
- **Requirements:** (1) a HarmonyOS score sheet for this project: every public iOS core symbol with its ArkTS
  counterpart, the rest marked "TODO: N/A on HarmonyOS" with a reason; (2) accessibility (screen reader, visual
  assistance) in all HarmonyOS code; (3) internationalization and localization through resource files (copied from
  CYLTabBarController's format, filtered to the texts this project uses); (4) record in English, in the instructions
  documents and the related skills (create them if missing): all code supports accessibility and localization; add it
  first where missing; automated UI tests locate controls, tap and run multi-step flows through accessibility first.
- **Prompt (verbatim):** "continue 在不需要模拟器的前提下开始代码开发。继续完成鸿蒙评分表。marking the rest "TODO: N/A on HarmonyOS" with a reason. 适配视觉辅助 盲人辅助 为鸿蒙代码 。 适配国际化本地化，本地化文件可以从CYLTabBarController中复制一份过来。筛选本项目用到的文字。并将下面的内容规则写入instructions相关文件并写入skills相关文件，如果相关文件不存在就新建文件确保成功。全英文写入：本项目全部代码已经支持适配视觉辅助 盲人辅助 为鸿蒙代码 。 适配国际化本地化，本地化文件。如果发现不支持请先支持，然后在自动化UI测试过程中，优先使用刚刚提到的功能进行UI控件定位。触发点击事件，或者触发复杂流程，连续操作等。"
- **Prompt (English):** continue, starting code development without the emulator: continue the HarmonyOS score sheet,
  marking the rest "TODO: N/A on HarmonyOS" with a reason; add visual and screen-reader accessibility to the HarmonyOS
  code; add internationalization and localization (localization files may be copied from CYLTabBarController, keeping
  the texts this project uses); write the rule above in English into the instructions and skills files, creating them
  if missing.
- **Decision (user, 2026-11-16):** a new score sheet for this project (not CYLTabBarController's
  `HarmonyOS-Parity.md`, which another session owns).
- **Result (no emulator used, as asked):**
  1. **Score sheet:** [harmonyos-api.md](harmonyos-api.md), generated by `scripts/harmonyos-api.py` from
     `scripts/harmonyos-api-map.json` over the 709 iOS symbols of `android-api.md`: 73 implemented, 636 "TODO: N/A on
     HarmonyOS" with a reason (UIKit/Foundation categories and UICollectionView internals, the older XIB screens,
     image tags no HarmonyOS example shows, options outside the ArkTS configuration subset); no plain TODO: 100.
  2. **Accessibility:** the core's fold control reads "<section> More/Less" with a hint and is at least 44 vp; tags
     get a hint when selectable (they already had label and selected state; the Lottie icon is decorative); the
     ArkTS example's tab items are one element each with their selected state, its emoji hidden; Reset and Filter
     have hints and 44 vp, and Filter says "conditions set" instead of the dot; each place row is one element with
     the rating and price in words.
  3. **Localization:** the core module has `resources/{base,en_US,zh_CN,zh_TW}` (keys `cyl_menu_*` from the iOS
     table) and the lookup `CYLMenuResources` / `CYLMenuLocalizedString`; the example's literals moved into its
     resources (four locales), with `tab_home`, `tab_messages`, `tab_me` and `tab_post` copied from CYLTabBarController's
     HarmonyOS example (`entry/src/main/resources`, only the keys this project uses); the React Native HarmonyOS shell
     uses those names too and pins CYLTabBarController `19cbf801` (its branch's own accessibility and localization).
  4. **Rules:** AGENTS.md "Accessibility and localization on HarmonyOS (and every platform)", `docs/instructions.md`,
     the new `harmony/instructions.md`, and the skills `cyl-accessibility` and `cyl-localization` (appended).
  5. **UI tests:** `entry/src/ohosTest/ets/test/ExampleUi.test.ets` now finds controls by localized text
     (`ON.text`) and accessibility description (`ON.description`), read from the resources, for taps and the
     multi-step Classify flow; types only for the slider and switch.
- **Evidence:** `assembleHap` of the ArkTS example and of its UI-test HAP: BUILD SUCCESSFUL; unit tests `Tests run: 6,
  Pass: 6`; the React Native HarmonyOS shell: BUILD SUCCESSFUL; `python3 scripts/harmonyos-l10n-check.py`: OK.
  Not run: the UI tests themselves (they need the emulator).

## DONE (2026-11-16, logged as TODO 2026-11-12): HarmonyOS NEXT support for Android and the cross-platform components

- **Status:** DONE 2026-11-16: step 1 (ArkTS library and example), step 2 (Flutter) and step 3 (React Native),
  details and evidence in `cross-platform.md` (TODO summary). Started 2026-11-15 (the earlier tasks were done). Tools found on this Mac: DevEco Studio with the
  HarmonyOS 6.0.1 SDK (API 21), `hdc`, hvigor and the Mate 70 Pro emulator (unsigned HAPs install). Not installed:
  the OpenHarmony fork of Flutter (`gitcode.com/openharmony-tpc/flutter_flutter`, reachable). Plan, in order:
  1. `harmony/` library (HAR, ArkTS): a port of `CYLTagListView` with the same JSON configuration as the Flutter and
     React Native components; unit tests; an example HAP with the Tags and Classify tabs, run on the emulator.
  2. Flutter: install the OpenHarmony fork, add an `ohos` platform to `flutter/cyl_tag_list` that hosts the HAR as a
     platform view; run the example's integration tests on the emulator.
  3. React Native: only after step 2 passes (React Native for OpenHarmony, `react-native-openharmony`).
- **Step 1: DONE (2026-11-15).** `harmony/` (build mirror `/tmp/xpr/harmony`; the exFAT volume breaks builds):
  - `classifymenu` (HAR, ArkTS): `CYLTagListView` reads the shared JSON configuration (`selectionMode`,
    `defaultVisibleRows`, `style.normal` / `style.selected`, `sections`, `selected`, `exclusive` items such as 全部);
    left-aligned tags that wrap, a long tag starts a new line and is shortened only to a line's width; fold control
    per section; single and multiple selection; `onTagTap`, `onSelectionChange`; ids `CYLTagListItem-<s>-<i>`.
  - `entry` (example, bundle `com.cyl.classifymenu.example`): bottom tabs Tags and Classify. Classify reads the shared
    `cyl_places.sqlite` (83 places, copied from rawfile once; `relationalStore`), the classify menu (single), a Filter
    sheet (regions, dishes, each led by an exclusive 全部), Reset, the summary line and the places; selections saved
    in the database (`menu.classify`, `menu.filter`), like the React Native example.
  - Build: `DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk` and DevEco's node running
    `tools/hvigor/bin/hvigorw.js assembleHap --no-daemon` (unsigned HAP); tests `hvigorw.js test -p module=entry`.
  - **Evidence:** local unit tests (hypium, `entry/src/test/LocalUnit.test.ets`): `Tests run: 5, Failure: 0, Pass: 5`.
    On the emulator: unfold, select Home ("Tapped Home"), Classify 83 places → 川菜 3 → filter 广州 1 place.
  - **Animated icons: DONE (2026-11-15).** The core draws an item's `animation` (`asset:<file>`, a rawfile; or JSON
    text) with `@ohos/lottie` 2.0.38 (`CYLLottieIcon`), sized by `style.imageSize`; `animationSpeed`,
    `animationLoops` and `CYLTagListController.playAll()` (from progress 0) act at once on icons that are playing.
    The Tags tab has the speed slider (0.25x–4x, step 0.25, value shown), the Loop switch and Play all, labeled for
    the screen reader and localized (`base`, `zh_CN` string resources). Unit tests: `Tests run: 6, Pass: 6`. On the
    emulator: 2×, Loop on, two consecutive screenshots differ (the icons play). Screenshot (same environment as
    below, 2026-11-15 05:53 emulator time):

    <img src="assets/harmonyos-animation-playback-controls.jpeg" width="360" alt="Earlier HarmonyOS example (replaced by the port): speed 2x, loop on, Lottie icons">

  - **UI tests as a script: DONE (2026-11-16).** `harmony/scripts/ui-test.sh` builds the example and its
    instrumented test, installs both on the running emulator and runs `aa test`; it fails unless every test passes.
    `entry/src/ohosTest/ets/test/ExampleUi.test.ets` (`@kit.TestKit` `Driver`, by id and text, no coordinates
    except the slider's drag): unfold, tap a tag ("Tapped …"), loop switch toggles, slider dragged to 4× (read from
    its localized accessibility description), Play all; Classify: Reset → `全部: 83 places`, 川菜 filters, Reset →
    83 again. Found while writing it: the speed label is hidden from the screen reader, so tests read the slider's
    description; tag ids repeat across tabs, so the Classify page has the id `classifyPage`. Result on the emulator
    (same environment as below): `Tests run: 3, Failure: 0, Error: 0, Pass: 3`.
    Original TODO prompt (verbatim): "continue".
  - **Note (2026-11-16):** the screenshots in this step (and the playback-controls one above) show the **earlier
    two-tab HarmonyOS example** (Tags / Classify), which the 22-demo port replaced (`harmony.md`). They are kept as
    the history of step 1; the current example's screenshots come from `harmony/scripts/screenshots.sh`
    (`docs/harmony-verification.md` rows B, `docs/harmony-screenshot-issues.md` C1).
  - **Screenshots:** HarmonyOS 6.0.1 SDK (API 21), Mate 70 Pro emulator `6.0.0.112(SP3DEVC00E112R4P11)`, DevEco
    Studio hvigor 6.21.2, macOS 27.3, branch `feat/android-kotlin` at the commit that adds them, 2026-11-15 09:48 NZDT.
    Top to bottom: Tags unfolded with Home selected; Classify with 川菜 and the 广州 filter; the Filter sheet.

  <img src="assets/harmonyos-tags.jpeg" width="360" alt="Earlier HarmonyOS example (replaced by the port): Tags tab, unfolded, Home selected">

  <img src="assets/harmonyos-classify-filtered.jpeg" width="360" alt="Earlier HarmonyOS example (replaced by the port): Classify, 川菜 and 广州, 1 place">

  <img src="assets/harmonyos-filter.jpeg" width="360" alt="Earlier HarmonyOS example (replaced by the port): Filter sheet with regions and dishes">

- **Step 2: DONE (2026-11-16; the blocker below was worked around without the newer SDK, see `cross-platform.md`).** History (2026-11-15): `flutter/cyl_tag_list_ohos` (OhosView + ArkTS platform view on
  `harmony/classifymenu`, registered through `dartPluginClass`) and the `CylTagListView.platformViewBuilder` hook are
  written, not yet built. Blocker: Flutter `3.41.9+ohos-1.0.2`'s embedding needs a HarmonyOS SDK newer than the
  installed API 21 (`autoFillManager.AutoFillType` missing). Flutter `3.35.7+ohos-1.0.5` (`/tmp/xpr/fo35`) fails
  the same way (2026-11-15): the installed SDK declares only the API 12 autofill types, and both embeddings target
  `26.0.0`. DevEco Studio has no command-line SDK manager, so the newer HarmonyOS SDK (API 22+ / 26) must be
  installed in its SDK Manager by hand; then rebuild with `flutter build hap --debug` in the mirror. Mirror `/tmp/xpr/flo`;
  sqflite on HarmonyOS through `openharmony-sig/flutter_sqflite` `br_v2.4.2_ohos` in a mirror-only
  `pubspec_overrides.yaml`.
  Earlier note: When React Native or
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

## DONE (2026-11-13, logged as TODO 2026-11-12): open pull requests and issues of the three ported projects

- **Status:** DONE (2026-11-13): the 4 open pull requests are translated and merged; the issue tables (90 open
  issues), the fixes and the scores are in [android-upstream.md](android-upstream.md) (one document for the three
  projects instead of their API documents, so the scores add up in one place). Score: 90 / 90 = 100 (android-tagview 100, TagViewGroup 100, AndroidTagView 100); DONE 2026-11-13.
- **Context:** the rule "Upstream projects (translations and ports)" (AGENTS.md, `.agents/skills/cyl-upstream/`). The
  three Kotlin ports translated the default branches of kaedea/android-tagview, shellljx/TagViewGroup and
  whilu/AndroidTagView only. The translations are done, so: translate each open pull request's change and merge it
  into `android/<project>` and `android/merged`; list each project's open issues (issue link, description, status
  `TODO`) in its API document (`android-tagview-api.md`, `tagviewgroup-api.md`, `androidtagview-api.md`); fix them on
  the translated code and score after each fix until 100. TagViewGroup is reimplemented (GPL-3.0): read its pull
  requests and issues as behavior only, copy no code.

## DONE (2026-11-13, logged as TODO the same day): Android bug: a long tag is shortened instead of starting a new line (Container tab)

- **Context:** in the merged example's Container tab (first container), the tag "Welcome to use AndroidTagView!" is
  drawn as "Welcome to use Andro…" after "Html" on the same line, although on a line of its own it would show in
  full (the same for "你好，这是一个TAG。你好，这是一个TAG。"). Bug of the Android core (`co.lujun.androidtagview`).
- **Expected (the iOS strategy, `CYLTagListView` -cyl_widthsForContentWidth: and the left-aligned layout):** a tag
  is as wide as its whole text, at most one line's width. When it does not fit in the space left on the current
  line, it starts a new line. When it is wider than a whole line, it still starts a new line, as the first tag of
  that line, and only then is its text shortened with an ellipsis to the line's width. A tag never stays after
  other tags in a shortened form when a new line would show more of it.
- **Kept:** one line of text per tag by default; wrapping only when the caller asks for it (`tag_text_wrap`). An
  explicit maximum length (`tag_max_length` set by the caller) still shortens the text with an ellipsis.
- **Cause:** the default character limit (23, `tag_max_length` unset) shortened every longer text before the line
  was chosen, so the shortened tag fitted after "Html".
- **Fix:** the default is no character limit; the width of the whole text decides the line; a tag wider than a
  line starts a new line and is shortened to the line's width.
- **Status:** DONE. `TagContainerLayout` (standalone port and merged library): `tag_max_length` defaults to 0 (no
  limit; `setTagMaxLength(0)` removes a limit); the line-break and maximum-width logic of the tag layout round
  (`71adee9`) then places a tag that does not fit after the others at the start of a new line. Tests
  `longTagStartsANewLineInsteadOfBeingShortened` and `tagWiderThanALineStartsANewLineThenIsShortened`; library tests
  69, 0 failures.
- **Screenshot (before, top; after, bottom):** Android, merged example, Container tab, first container; macOS 27.3,
  Android Emulator `CYL_API35_arm64` (Android 15, API 35), compileSdk / targetSdk 35, AGP 8.7.3, Kotlin 2.0.21;
  branch `feat/android-kotlin`, before at `71adee9`, after at the commit that adds this image
  (`git log -- docs/assets/android-androidtagview-line-break-before-after.png`); taken 2026-11-13 11:56 and 14:14
  NZDT. "Welcome to use AndroidTagView!" now starts a new line in full; the Chinese tag, wider than a line, starts its
  own line and ends with "…" at the line's width.

<img src="assets/android-androidtagview-line-break-before-after.png" width="540" alt="Before: Welcome tag shortened after Html; after: on a new line in full">
- **User prompt (verbatim, 2026-11-13, with the Container tab screenshot):**

> 全英文记录：图中演示，tag含有welcome字样的cell应该另外新起一行以保证文字能够最大可能展示完整而非使用省略符号。标记为android端bug，标记todo参考iOS端实现策略，换行策略，修复core核心层面代码以修复该bug，找到android端相关文档标记TODO。

> 还是保留默认一样的逻辑，如非用户指定接口允许换行还是一行。允许超出一行的所限制的允许最大输入，末尾显示省略号是可以接受的。本次主要修复的是。在一行的限制下，明知本cell在追加到已经存在的cell后面无法完全显示，或者单独的cell即使占据一行也无法显示的情况下依然不换行占据第一个cell，而是选择追加到已经存在的cell后面，导致更多内容被设置为省略号。参考我刚刚的描述，重新执行下面的指令：全英文记录：图中演示，tag含有welcome字样的cell应该另外新起一行以保证文字能够最大可能展示完整而非使用省略符号。标记为android端bug，标记todo参考iOS端实现策略，换行策略，修复core核心层面代码以修复该bug，找到android端相关文档标记TODO。

- **English:** keep the default: one line per tag unless the caller enables wrapping; an ellipsis at the end is
  acceptable for text longer than one line allows. The bug: within the one-line limit, a tag that cannot be shown in
  full after the tags already on the line, or that cannot be shown in full even on a line of its own, is appended
  after the existing tags instead of starting a new line as its first tag, so more of its text becomes an ellipsis.
  The "Welcome" tag in the screenshot must start a new line to show as much text as possible. Android bug; follow
  the iOS line-break strategy; fix it in the core; mark it TODO in the Android document.

## DONE (2026-11-13, logged as TODO the same day): merge the open pull requests into this branch, keep one pull request

- **Context / requirements:** merge every open pull request of this repository into `feat/android-kotlin` and
  close it after merging; commit local uncommitted work to this branch; keep one pull request (#16) and one active
  branch (`feat/android-kotlin`).
- **Status:** DONE. PR #17 (`fix/android-tag-title-ellipsis`, tag titles end with "…") merged in `d33907b`
  (conflict in `CYLTagButton.place` resolved: children measured EXACTLY at their frame) and shown as merged; its
  remote branch deleted. Another session's branch `docs/animation-playback-controls` (the same animation controls
  rule, written in parallel) merged in `8c81478` and folded into `docs/example-demo-rules.md`; its remote branch
  deleted. Open pull requests now: #16 only; remote branches: `master`, `feat/android-kotlin` and `ci-screenshots`
  (CI's screenshot storage, kept). The local branches of those two pull requests stay checked out in the other
  session's worktrees (git cannot delete a checked-out branch); their commits are all in this branch. No local
  uncommitted code was left (four empty `*-pr.diff` files removed).
- **User prompt (verbatim, 2026-11-13):**

> 合并所有处于open 状态的pr到本分支，或者本地所有未提交的代码到本分支 continue
> 合并所有处于open 状态的pr到本分支，合并后close pr，或者本地所有未提交的代码到本分支 。仅保留一个pr，一个活跃分支为本分支 continue

## DONE (2026-11-14): fold control positions renamed, as on iOS

- **Context:** the decision recorded in `docs/component-architecture.md` ("rename the fold control positions"):
  `none`, `footer`, `headerLeading`, `headerTrailing`, `tail`, implemented on iOS and Android in the same commit
  (step 8 of `docs/Swift-Migration.md`).
- **Result:** `CYLMenuFoldControlPosition.NONE`, `FOOTER`, `HEADER_TRAILING`, `HEADER_LEADING`, `TAIL` (were
  `CYLMenuFoldControlPositionNone`, `…Bottom`, `…TopTrailing`, `…TopLeading`, `…Inline`); configuration strings
  `"footer"`, `"headerTrailing"` / `"headerRight"`, `"headerLeading"` / `"headerLeft"`, `"tail"`; the library, its tests,
  the example screens and `api-map.json` updated. `scripts/gradle.sh merged :library:testDebugUnitTest
  :example:compileDebugKotlin`: BUILD SUCCESSFUL.

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
| `07cc52b` | Android -> iOS table ([android-ios-api.md](android-ios-api.md)): 89.4 -> 611 / 611; new iOS core APIs (section expansion and visible counts, ripple and panel state, appearance resets, app tint, `kTagCollectionView*`, accessibility identifier lookup) | 611 / 611 (Android -> iOS) | 100.0 |
| `56174a3` | `ios_public_api.py` reads the Swift sources (the Objective-C headers were deleted by the Swift migration, so the old 709 / 709 was stale): 585 / 731 = 80.0; renamed symbols mapped (old Objective-C keys kept as aliases), protocol conformance left out | 731 / 731 | 100.0 |
| correction | Android -> iOS: the generator stopped using the stale Objective-C keys of `api-map.json` and same-name matches of Objective-C spellings; iOS names now come from the Swift signatures | 568 / 611 (Android -> iOS) | 93.0 |
| `a3c2e1f` | `UIView+CYLGeneral.swift` (Android `CYLGeneralExtensions.kt` frame, centering, border, corner, layer, tap and capture helpers), `CYLFilterParamsTool`, `CYLFilterBaseController.settingArray`, 13 hand mappings; tests `CYLGeneralHelpersTests` | 611 / 611 (Android -> iOS) | 100.0 |
| `a3c2e1f` | iOS -> Android, regenerated with the new Swift APIs | 761 / 761 | 100.0 |
| `f77cd48` | Android -> iOS: the Kotlin parser read classes with a multi-line primary constructor (`CYLTag`, …) as one-liners and skipped their members: 128 rows found, 6 misattributed rows gone; new iOS `CYLTag.resetColors()` | 733 / 733 (Android -> iOS) | 100.0 |
| `f77cd48` | iOS -> Android with `CYLTag.resetColors()` | 762 / 762 | 100.0 |
| `477323d` | iOS -> Android: `CYLTagListView`'s Objective-C names and the old factories (Objective-C only) | 766 / 766 | 100.0 |
| this commit | iOS -> Android: every iOS icon + title component is a `CYLTagButton`; its new looks and properties wait for the same refactor on Android | 763 / 771 | 99.0 |

## DONE (2026-11-17, `feat/harmony`): every tab of the merged example stays in the bar after CYLTabBarController's "More"

- Prompt (verbatim): "continue fix todo • There's no CollectionViewClassifyMenu example under Example-Android, so I didn't add an opt-in there. The Android example is on the feat/android-kotlin-b branch. Fetching it. merge to current branch"
- Context: CYLTabBarController `0c35409` (pinned since `f77cd48`) gives Android UIKit's "More" tab past five view
  controllers, with the Android-only opt-out `cyl_showsAllTabs` (configuration key `CYLTabBarControllerShowsAllTabs`).
  This project's Android example is `android/merged/example` (not `Example-Android`, which is CYLTabBarController's).
  Its tab bar has nine tabs.
- Merge: `origin/feat/android-kotlin-b` (`b133525`) is already contained in `feat/harmony` (0 commits ahead), so
  there is nothing to merge.
- Duplicate: another session made the same change at the same time (`9719fb6`, the entry "every tab on Android" at
  the top of this document); the merge `cf587a8` kept one key, and that entry is the main record.
- Result: the example's tab bar is scrollable (`cyl_scrollMode = Scrollable`), which upstream already exempts from
  "More". The configuration file `example/src/main/assets/cyl_merged_tabbar.json` now also sets
  `"CYLTabBarControllerShowsAllTabs": true`, so the nine tabs stay in the bar whatever the scroll mode.
- Evidence: the JSON parses with the key read at the top level, as `CYLTabBarController.cyl_applyConfiguration` reads
  it at `0c35409`. Not built here (no Android SDK in this container, and no Android CI job). It needs a Gradle build and
  an emulator screenshot on a Mac.

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

## DONE (2026-11-19, `feat/harmony`): Android API and Android example ports to iOS, progress; a visible drag-to-reorder demo on iOS

- **Context:** `android-ios-api.md` scores the Android core API against iOS (736 / 736). No document tracks the
  Android example's screens against the iOS example. The iOS drag-to-reorder demo exists (`CYLTagContainerSample`,
  `allowsReordering`) but sits behind 样式 → AndroidTagView 示例, so the owner has not seen it.
- **Requirements:** report both progress figures from the docs; add a table of every Android example screen and its iOS
  counterpart (score, TODO rows); port what is missing; make drag-to-reorder an easy-to-find iOS example with a labeled
  screenshot; continue the remaining TODOs.
- **Prompt (verbatim):** "检查docs文档，找到android 的api 翻译到iOS端的进度。并且android 的example也翻译到iOS端的进度。我现在一直没看到iOS端演示拖拽tag重新排序的example。如果还有todo 继续完成"
- **Prompt (English):** "Check the docs: find the progress of translating the Android API to iOS, and of translating the
  Android example to iOS. I still have not seen an iOS example demonstrating dragging a tag to reorder. If TODOs remain,
  continue them."
- **Android API → iOS:** 736 / 736 public Android symbols have an iOS counterpart, **100 / 100**
  ([android-ios-api.md](android-ios-api.md), generated by `android/scripts/android_public_api.py`; reverse direction:
  [android-api.md](android-api.md)). Drag to reorder is part of it: `allowsReordering`, `reorderingSensitivity`,
  `isReordering`, `menuMoveItem(at:to:)`, `menu(_:didMoveItemAt:to:)`, `tagMoveHandler`.
- **Android example → iOS example:** every screen of the Android example (`android/merged/example`, one tab per page of
  `cyl_merged_tabbar.json`) has an iOS counterpart, **14 / 14 = 100 / 100** after the About row below. Most Android tabs
  are themselves ports of iOS screens; the Android-only content is the three upstream samples, ported to Swift in
  `Example/CYLMenuExample`:

  | Android page (tab id) | Source | iOS counterpart | Where on iOS |
  |---|---|---|---|
  | `KaedeTagViewFragment` (`kaede`) + ListView / RecyclerView / Sub activities | kaedea/android-tagview | `CYLTagCloudSampleViewController` + list / recycler / sub screens | 样式 → Android 标签库示例 → android-tagview 示例 |
  | `LujunTagContainerFragment` (`lujun`), 5 containers, drag | whilu/AndroidTagView | `CYLTagContainerSampleViewController` | 样式 → Android 标签库示例 → AndroidTagView 示例 |
  | Drag to reorder (first container of `lujun`) | whilu/AndroidTagView | **new** `CYLTagReorderDemoViewController` (`a4517a3c`) | 样式 → first row 拖拽标签重新排序 |
  | `LicrafterTagGroupFragment` (`licrafter`) + TagList activity | shellljx/TagViewGroup | `CYLImageTagSampleViewController`, `CYLImageTagListViewController` | 样式 → Android 标签库示例 → TagViewGroup 示例 |
  | `LicrafterTagEditFragment` (plus button `plus`) + `TagEditDialog` | shellljx/TagViewGroup | `CYLImageTagEditViewController` (创建标签 alert) | TagViewGroup 示例 → 编辑 |
  | `AboutFragment` (`about`) | this app | **new** `CYLAndroidSamplesAboutViewController` (`daaf8f95`) | 样式 → Android 标签库示例 → 关于 |
  | `ClassifyMainFragment` (`classify`) | iOS menu linkage | `CYLMenuLinkageViewController` | plus button → query scenarios → 菜单联动 |
  | `FilterDemoFragment` (`filter`) | iOS menu linkage + multiple filter | `CYLMenuLinkageViewController` (filter button) | same |
  | `TagCollectionDemoFragment` (`tagcollection`) | iOS `TagCollectionView` app | `TagCollectionView/` | its own app |
  | `TagEditorFragment` (`editor`) | iOS `Example-Swift` | `CYLTagEditorExample` | its own app |
  | `MenuFragment` (`menu`): reviews, search, styles, animations | iOS `Example/CYLMenuExample` | the four tabs of `CYLMenuExample` | tab bar |

- **Why the drag demo was not seen:** it existed (`CYLTagContainerSample`, first container, `allowsReordering`) but sat
  near the bottom of the 样式 tab, inside AndroidTagView 示例. Now the 样式 tab's first section, 拖拽排序（长按标签后拖动）,
  opens a screen with only that: ten tags, a hint, the order below them, Reset (`-CYLExampleScreen reorder`).
- **Core bug found and fixed (`a4517a3c`):** while a tag was dragged, every slot kept the width of the tag that had been
  there, so moved titles were cut ("Kot…", "Ark…", "S…"); `CYLTagListView` now sizes each slot for the tag shown in it
  until the measurements follow the drop (`measuredIndexPath(for:)`; test
  `testSlotsTakeTheWidthsOfTheTagsShownInThemDuringADrag`).
- **Tests:** example 96 / 0 (4 new), menu 32 / 0, tag 6 / 0, swift 22 / 0; a real drag on the simulator (axe: touch down,
  1 s hold, move, lift).
- **Evidence** (iOS 27.2, iPhone 17 Pro simulator, macOS 27.3, Xcode 27.2 (27B52), `a4517a3c`, 2026-11-19 06:36 NZDT):
  where to find it, then the drag:

  <img src="assets/ios-style-tab-reorder-entry.png" width="360" alt="iOS 样式 tab: the drag-to-reorder row first">
  <img src="assets/ios-tag-drag-reorder.png" width="600" alt="iOS drag to reorder: before, while dragging (titles whole), dropped">

- **TODOs still open elsewhere (not this task; owner):** (mini program Rive B20, the Menu `isOpen` and BUG 1 drift:
  done, `animated-item-migration.md` `074285a6`, `cross-platform.md`; only BUG 1 on a phone is left); Android `CYLRightImageButton` /
  `CYLMultipleFilterHeaderView` on `CYLTagButton` (`issue-progress.md`; Windows session); SVGA in the Android, Flutter,
  React Native and mini program examples (done 2026-11-19, `example-demo-rules.md`); `npm publish` of the mini program package (needs the
  maintainer's `npm login`); a VoiceOver / Switch Control check on a real device; the default tab bar height
  (`cross-platform.md`; CYLTabBarController).

## DONE (2026-11-19, `feat/harmony`): does Android's drag cut titles like iOS did before `a4517a3c`?

- **Task (from the Mac session's TODO audit, 248eaa1c):** iOS `a4517a3c` fixed tag titles cut ("Kot…") while a tag was
  dragged. Check whether Android's drag has the same issue. Score: **100 / 100** (pass 60).
- **Answer: no.** iOS showed the new order with the widths of the old one. Android's `CYLTagListView` drag translates
  only the dragged cell (the others stay where they are), and on the drop `moveItem` reloads the titles and the widths
  together (`reloadMenuData`: titles, then `measureIfNeeded` and `content.rebuild`). No cell ever shows one tag's title at
  another tag's width. The Android example's drag demo (`LujunTagContainerFragment`, `container_enable_drag`) uses
  `TagContainerLayout`, whose tags are views sized by their own text, so it cannot have the issue either.
- **Test (new):** `CYLTagReorderWidthTest` drags "Kotlin" onto "Go" in the iOS demo's ten tags (long press, ten move
  steps, drop). Every tag keeps its own title's width at each step, right after the drop and after the reload, and
  `tagMoveHandler` reports 1 → 9. Android library 87 / 0.
- **TODO (missing, not part of this check):** the Android example has no `CYLTagListView` drag demo (`allowsReordering`)
  like the iOS Style tab's first row `CYLTagReorderDemoViewController`; the existing Android drag demo is
  `TagContainerLayout`'s.
