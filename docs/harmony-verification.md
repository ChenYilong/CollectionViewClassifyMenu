---
title: HarmonyOS verification score
date: 2026-11-16
tags: [harmonyos, arkts, verification, score]
---

# HarmonyOS verification score

[harmony.md](harmony.md) scores API and demo **parity**: it reached 807 / 807 when every iOS API and demo had a
HarmonyOS counterpart, but nothing had run on a device then ("compile only"). This document defines the **full-marks
standard** of the HarmonyOS port: the port is finished only when every row below is `DONE` (or `N/A` with its
reason). Each row is one point. A row that needs the emulator is `DONE` only with evidence from the emulator (a
screenshot in `docs/assets/`, or a passing `harmony/scripts/ui-test.sh` run); compiling is not enough.

## Task log

- **TODO → in progress (2026-11-16).** Prompt, verbatim: 「鸿蒙模拟器正在安装，大概一小时后安装成功，请现在立即开始鸿蒙端的开发工作。阅读本地的鸿蒙功能相关文档，搜索鸿蒙相关关键词，找到TODO以及打分表。制作满分标准。如果没有就新建打分表。一直完成到满分为止。」
  (EN: the HarmonyOS emulator is installing and should be ready in about an hour; start the HarmonyOS work now.
  Read the local HarmonyOS documents, search HarmonyOS keywords, find the TODOs and the score table. Define the
  full-marks standard; create a score table if there is none. Keep working until full marks.)
- Context: branch `feat/harmony` (worktree `C:\w\cvcm-b`, PR from `master`). Open TODOs found:
  `cross-platform.md` "TODO: run it" (nothing has run on an emulator; Rive state machine, PAG rawfile loading, GIF
  decoding, Lottie's last frame, classify menu and filter layout; Chinese texts only), `issue-progress.md` "TODO
  (2026-11-16): SVGA animated icons" (HarmonyOS included), `android.md` HarmonyOS NEXT step 2 (Flutter on
  HarmonyOS, blocked on a newer SDK; not part of this port's score).
- **DONE (2026-11-16): accessibility, localization, rules, accessibility-first UI tests.** Result: labels on every image, input and control (`scripts/accessibility-check.py` OK; root tabs with label and selected state; filter headers as one element); native string resources in base / en_US / zh_CN / zh_TW with the four tab titles copied from CYLTabBarController (`scripts/check-native-strings.py` OK); two bugs fixed that compared translated text (the disabled style tag, the review filter's 全部); 33 UI-test taps by localized accessibility label (`cylTapAccessible`); rules in AGENTS.md, `docs/instructions.md`, skills `cyl-harmonyos` (new), `cyl-accessibility`, `cyl-localization`. Prompt, verbatim: 「continue 在不需要模拟器的前提下开始代码开发。继续完成鸿蒙评分表。marking the rest "TODO: N/A on HarmonyOS" with a reason. 适配视觉辅助 盲人辅助 为鸿蒙代码 。 适配国际化本地化，本地化文件可以从CYLTabBarController中复制一份过来。筛选本项目用到的文字。并将下面的内容规则写入instructions相关文件并写入skills相关文件，如果相关文件不存在就新建文件确保成功。全英文写入：本项目全部代码已经支持适配视觉辅助 盲人辅助 为鸿蒙代码 。 适配国际化本地化，本地化文件。如果发现不支持请先支持，然后在自动化UI测试过程中，优先使用刚刚提到的功能进行UI控件定位。触发点击事件，或者触发复杂流程，连续操作等。」
  (EN: without the emulator: support visual and blind accessibility in the HarmonyOS code; support i18n / l10n, copying
  the localization files from CYLTabBarController and keeping the strings this project uses; write the rule into
  the instructions and skills files, in English: all code supports accessibility and localization (add it where
  missing), and automated UI tests locate controls through accessibility first, for taps, complex flows and
  sequences of actions.)
- Environment: Windows 11, DevEco Studio 6.0.1.251, SDK API 21; Mate 70 Pro emulator image installing.

## Score

**Score: 52 / 53 = 98.1 / 100 with the deferred rows counted as N/A (1 row has a defect found on the emulator:
B11, a regression after `849c2d8` and emulator crashes); verified on a device or the computer: 38 / 53 = 71.7 / 100.** Full marks = every row `DONE` / `N/A`. The 16 rows marked "TODO: N/A on HarmonyOS (deferred)" are not
impossible on HarmonyOS: they need a run on the emulator that has not happened yet (marked N/A at the maintainer's
request, 2026-11-16; the dedicated emulator `CYL ClassifyMenu Test` exists since then). Each one turns back into a check when an emulator runs (`ui-test.sh`,
`screenshots.sh`); 38 rows are verified: A1–A5 and H1–H8 on the computer, E1–E2, and B1–B10, B12–B22, F2 and G1 on the emulator
(2026-11-16).

### A. Build and code quality (5)

| # | Check | Status | Evidence |
| --- | --- | --- | --- |
| A1 | `harmony/scripts/build.sh`: the `classifymenu` HAR builds | DONE | BUILD SUCCESSFUL, 2026-11-16 |
| A2 | `harmony/scripts/build.sh`: the `entry` HAP builds | DONE | BUILD SUCCESSFUL, 2026-11-16 |
| A3 | The instrumented test HAP (`entry@ohosTest`) builds | DONE | BUILD SUCCESSFUL, 2026-11-16 |
| A4 | No ArkTS warning in our sources (library and example; third-party packages excluded) | DONE | 92 → 1. Model code measures through `CYLUIContext` (the components' `UIContext`: `getMeasureUtils()`, `px2vp`); `UIContext.animateTo`, `getPromptAction()`, `showAlertDialog`; `CYLAccessibilitySelectedModifier` sets `accessibilitySelected` only on API 13+; database calls in try/catch; unique back-button ids. The one left: `getContext()` in `CYLUIContext.hostContext`, the API 12–17 fallback (its replacement `UIContext.getHostContext()` exists from API 18, used there) |
| A5 | Local unit tests (`entry/src/test`) pass on this computer, no device: `harmony/scripts/unit-test.sh` (hvigor `test`) | DONE | 46 / 46 on 2026-11-16 (section H lists them by feature); 15 / 15 when added: tag list (6), SVGA decoder (5: engine by extension, movie params, images, sprites, frames with alpha / layout / transform / clip path / shapes / KEEP, progress → frame, SVGA 1.x and damaged files rejected), localization (4: language choice, iOS strings, `%@` / `%lu` formats, core in three languages); plus `scripts/svga-decoder-test.sh` on the six real `.svga` files |

### B. Every demo runs on the emulator, screenshot next to iOS (22)

One row per demo of [harmony.md](harmony.md) table 2. `DONE` = opened on the Mate 70 Pro emulator, behaves as the
iOS demo (texts, data, taps), screenshot `docs/assets/harmonyos-<demo>.png` linked in `screenshots.md`.

| # | Demo (HarmonyOS page) | Status |
| --- | --- | --- |
| B1 | Root tab bar (`pages/Index`) | DONE (2026-11-16, after `d6adba3`): the Chinese tab titles fit ("场景一：评价筛选", "场景二：搜索分类"), screenshot [root](assets/harmonyos-root.jpeg), [en-root](assets/harmonyos-en-root.jpeg), [dark-root](assets/harmonyos-dark-root.jpeg) |
| B2 | `CYLProductPage` | DONE (2026-11-16): renders on the emulator, screenshot [product](assets/harmonyos-product.jpeg) |
| B3 | `CYLReviewListPage` (memory, network, database) | DONE (2026-11-16): renders on the emulator, screenshot [reviews-memory](assets/harmonyos-reviews-memory.jpeg), [reviews-network](assets/harmonyos-reviews-network.jpeg), [reviews-database](assets/harmonyos-reviews-database.jpeg) |
| B4 | `CYLSearchHomePage` | DONE (2026-11-16): renders on the emulator, screenshot [search-home](assets/harmonyos-search-home.jpeg) |
| B5 | `CYLSearchCategoryPage` | DONE (2026-11-16): renders on the emulator, screenshot [search-category](assets/harmonyos-search-category.jpeg) |
| B6 | `CYLSearchCategoryPage.page()` (each category tab) | DONE (2026-11-16): renders on the emulator, screenshot [search-category-page](assets/harmonyos-search-category-page.jpeg) |
| B7 | `CYLSearchDiscoverPage` | DONE (2026-11-16): renders on the emulator, screenshot [search-discover](assets/harmonyos-search-discover.jpeg) |
| B8 | `CYLQueryScenariosPage` | DONE (2026-11-16): renders on the emulator, screenshot [query-scenarios](assets/harmonyos-query-scenarios.jpeg) |
| B9 | `CYLMenuLinkagePage` | DONE (2026-11-16, after `d6adba3`): headers show their icon and title, tags render normally, 83 results, screenshot [menu-linkage](assets/harmonyos-menu-linkage.jpeg); TODO: the filter icon in the title bar is nearly invisible (contrast 1.01 : 1, WCAG asks 3 : 1; `issue-progress.md`) |
| B10 | `CYLTagStylePage` | DONE (2026-11-16): renders on the emulator, screenshot [styles](assets/harmonyos-styles.jpeg), [zh-hant-styles](assets/harmonyos-zh-hant-styles.jpeg) |
| B11 | `CYLTagAnimationPage` | TODO (2026-11-16, after `849c2d8`, regression): in light mode the animated tags are now empty boxes without icons or titles ([animations](assets/harmonyos-animations.jpeg); they rendered before); opening the screen in dark mode, or scrolling it, crashed the emulator host twice (Emulator minidump; no app fault log left); earlier app crashes were in `libohos_rive.so` |
| B12 | `CYLTagConfigurationPage` | DONE (2026-11-16, after `d6adba3`): the icon-only item shows its heart, screenshot [configuration](assets/harmonyos-configuration.jpeg) |
| B13 | `CYLTagCloudDemoPage` | DONE (2026-11-16): renders on the emulator, screenshot [tag-cloud](assets/harmonyos-tag-cloud.jpeg) |
| B14 | `CYLTagCloudSamplePage` | DONE (2026-11-16): renders on the emulator, screenshot [tag-cloud-sample](assets/harmonyos-tag-cloud-sample.jpeg) |
| B15 | `CYLTagCloudSubPage` | DONE (2026-11-16): renders on the emulator, screenshot [tag-cloud-sub](assets/harmonyos-tag-cloud-sub.jpeg) |
| B16 | `CYLTagCloudListPage` | DONE (2026-11-16): renders on the emulator, screenshot [tag-cloud-list](assets/harmonyos-tag-cloud-list.jpeg) |
| B17 | `CYLTagCloudRecyclerPage` | DONE (2026-11-16): renders on the emulator, screenshot [tag-cloud-recycler](assets/harmonyos-tag-cloud-recycler.jpeg) |
| B18 | `CYLHotSearchPage` | DONE (2026-11-16): renders on the emulator, screenshot [hot-search](assets/harmonyos-hot-search.jpeg) |
| B19 | `CYLImageTagSamplePage` | DONE (2026-11-16): renders on the emulator, screenshot [image-tag-sample](assets/harmonyos-image-tag-sample.jpeg) |
| B20 | `CYLImageTagEditPage` | DONE (2026-11-16): renders on the emulator, screenshot [image-tag-edit](assets/harmonyos-image-tag-edit.jpeg) |
| B21 | `CYLImageTagListPage` | DONE (2026-11-16): renders on the emulator, screenshot [image-tag-list](assets/harmonyos-image-tag-list.jpeg) |
| B22 | `CYLTagContainerSamplePage` | DONE (2026-11-16): renders on the emulator, screenshot [tag-container](assets/harmonyos-tag-container.jpeg) |

### C. UI tests (6)

Instrumented tests in `harmony/entry/src/ohosTest`, one test file per feature (as the iOS example tests), finding
views by accessibility text or id; `DONE` = written and passing in `harmony/scripts/ui-test.sh` on the emulator.

| # | Feature | Status |
| --- | --- | --- |
| C1 | Tags: selection, folding, Play all (existing `ExampleUi.test.ets`) | TODO: N/A on HarmonyOS (deferred) — instrumented UI tests run only on a device; none on this machine. Ready: written and compiled (`entry/src/ohosTest`), run with `scripts/ui-test.sh` |
| C2 | Scenario 1: product → reviews, filter tags, memory / network / database sources | TODO: N/A on HarmonyOS (deferred) — instrumented UI tests run only on a device; none on this machine. Ready: written and compiled (`entry/src/ohosTest`), run with `scripts/ui-test.sh` |
| C3 | Scenario 2: search home, category tabs, discover (recent, 换一批) | TODO: N/A on HarmonyOS (deferred) — instrumented UI tests run only on a device; none on this machine. Ready: written and compiled (`entry/src/ohosTest`), run with `scripts/ui-test.sh` |
| C4 | Classify menu and multiple filter (`CYLMenuLinkagePage`), query scenarios | TODO: N/A on HarmonyOS (deferred) — instrumented UI tests run only on a device; none on this machine. Ready: written and compiled (`entry/src/ohosTest`), run with `scripts/ui-test.sh` |
| C5 | Styles, animations (speed, loop, Play all), configuration | TODO: N/A on HarmonyOS (deferred) — instrumented UI tests run only on a device; none on this machine. Ready: written and compiled (`entry/src/ohosTest`), run with `scripts/ui-test.sh` |
| C6 | Samples: tag cloud, hot search, image tags, tag containers | TODO: N/A on HarmonyOS (deferred) — instrumented UI tests run only on a device; none on this machine. Ready: written and compiled (`entry/src/ohosTest`), run with `scripts/ui-test.sh` |

### D. Animation engines on the emulator (5)

| # | Engine | Check | Status |
| --- | --- | --- | --- |
| D1 | Lottie (`@ohos/lottie`) | plays, speed, loop, Play all restarts at 0, last frame when selected on first load | TODO: N/A on HarmonyOS (deferred) — playback can only be seen on a device; none on this machine. Ready: engine code compiled, the timed player host-tested (H7) |
| D2 | PAG (`@tencent/libpag`) | loads from the rawfile folder, plays, speed, loop | TODO: N/A on HarmonyOS (deferred) — playback can only be seen on a device; none on this machine. Ready: engine code compiled, the timed player host-tested (H7) |
| D3 | Rive (`@ohos/rive`) | plays, state-machine options, loop; no speed (engine limit, stated in the page) | TODO: N/A on HarmonyOS (deferred) — playback can only be seen on a device; none on this machine. Ready: engine code compiled, the timed player host-tested (H7) |
| D4 | GIF (ImageKit frames) | decodes, plays, speed, loop | TODO: N/A on HarmonyOS (deferred) — playback can only be seen on a device; none on this machine. Ready: engine code compiled, the timed player host-tested (H7) |
| D5 | SVGA | the SVGA scenes mirror the Rive scenes (`issue-progress.md`, SVGA TODO) | TODO: N/A on HarmonyOS (deferred) — playback can only be seen on a device; none on this machine. Ready: engine code compiled, the timed player host-tested (H7). Code done: no ohpm SVGA player exists, so the library decodes SVGA 2.x itself (`components/svga/`: `CYLInflate` (RFC 1950/1951), `CYLSVGAMovie` (protobuf `MovieEntity`), drawn by `CYLSVGAIconView` on a Canvas: bitmaps with alpha, layout, transform, clip path; path / rect / ellipse shapes; no mattes or audio) and plays it with `CYLSVGAPlayer` (speed, loop, Play all, resting progress, last frame). `scripts/svga-decoder-test.sh`: all six example files inflate byte for byte as zlib and decode (frames, sprites, PNG bitmaps). Example: sections `svga` and `svga-dark` beside `rive` and `rive-icons` on the 动效 tab, and an SVGA choice beside Rive on the 样式 tab |

### E. Localization (3)

| # | Check | Status |
| --- | --- | --- |
| E1 | Core strings in `en`, `zh-Hans` (`zh_CN`) and `zh-Hant` (`zh_TW` / `zh_HK`), generated from the iOS core bundle | DONE: `CYLCoreStrings.ets` (en, zh-Hans, zh-Hant) by `export-core-strings.py`, `--check` OK |
| E2 | Example strings in the same three languages, from the iOS example bundle; no user-facing literal in `.ets` code | DONE: `CYLExampleStrings.ets` by `export-example-strings.py` (259 keys, en and zh-Hant; zh-Hans is the key), looked up by `CYLExampleLocalizedString`; ~220 literals and 18 templates now go through it (templates as the iOS `%@` / `%lu` keys with `cylFormat`). Left in Chinese, as on iOS: sample data (reviews, names, places, search tags, `地区过滤` / `菜品过滤` types). Titles that are also ids or map keys (root tabs, search categories, industries) stay keys and are localized where shown, so ids and the UI tests do not depend on the language. Native resources (system strings, CYLTabBarController's tab titles) in base / en_US / zh_CN / zh_TW, checked by `scripts/check-native-strings.py`; no translated text compared in code |
| E3 | The example follows the system language on the emulator (screenshot in English) | TODO: N/A on HarmonyOS (deferred) — needs a running emulator for the screenshot. Ready: `cylLanguage` launch option, `screenshots.sh` (`en-*`, `zh-hant-*`); lookup host-tested (H8, `LaunchOptions.test.ets`) |

### F. Accessibility and appearance (2)

| # | Check | Status |
| --- | --- | --- |
| F1 | Every control has an accessibility text; selected state announced (API 12 fallback for `accessibilitySelected`) | TODO: N/A on HarmonyOS (deferred) — the screen reader's output can only be checked on a device. Ready: labels on every tappable element, `CYLAccessibilitySelectedModifier` (API 13+); static check `scripts/accessibility-check.py` OK (2026-11-16) |
| F2 | Dark mode renders on the emulator (screenshot) | DONE (2026-11-16): dark mode renders, screenshot [dark-root](assets/harmonyos-dark-root.jpeg) (dark-animations shares B11's defect) |

### G. Documentation (2)

| # | Check | Status |
| --- | --- | --- |
| G1 | `screenshots.md` and `cross-platform.md` list the HarmonyOS screenshots of every demo | DONE (2026-11-16): [screenshots.md](screenshots.md) lists the 29 HarmonyOS screenshots |
| G2 | `harmony.md`, `cross-platform.md` and `README.md` state the verified state (no "compile only" left) | TODO: N/A on HarmonyOS (deferred) — documents the screenshots and verified state of rows B–F, which need the emulator first |

### H. Host unit tests per library feature (8)

One row per feature of the port (the features of [harmony.md](harmony.md)'s score history). `DONE` = tests of the
feature in `harmony/entry/src/test` pass in `harmony/scripts/unit-test.sh` (no device).

| # | Feature | Status | Tests |
| --- | --- | --- | --- |
| H1 | Menu data source, delegate, keys | DONE | `ClassifyAndFilter.test.ets` (a `CYLMenuDataSource` with exclusive items drives both menus; delegate taps and confirmations) |
| H2 | Style: `CYLMenuStyle`, colors, fonts | DONE | `StyleAndModels.test.ets` (color strings as iOS, states kept apart, deep copy, title length / reversal, font scale and its limit, named styles) |
| H3 | Tag models: `CYLTag`, `CYLTagModel`, `CYLTagGroup`, theme colors | DONE | `StyleAndModels.test.ets` |
| H4 | `CYLTagListState`: tags API, selection modes, layout, reordering, configuration | DONE | `TagListState.test.ets` (8), `ImageTagAndPlayer.test.ets` (JSON configuration), `LocalUnit.test.ets` (6) |
| H5 | Image tags: directions, geometry, partial lines, separation, title lists | DONE | `ImageTagAndPlayer.test.ets` (6; found and fixed: `partialLine` added a zero-length point when the progress ended on a corner) |
| H6 | Classify menu and multiple filter | DONE | `ClassifyAndFilter.test.ets` (6: folding to the default rows, layout inside the width, exclusive "全部", fallback, confirm / restore, conflicting selections rejected) |
| H7 | Animation players (timed player: progress, last frame, speed, loop, play from 0) | DONE | `ImageTagAndPlayer.test.ets` (`CYLSVGAPlayer`, the timed player shared with GIF and PAG) |
| H8 | SVGA decoder and localization | DONE | `SVGADecoder.test.ets` (5), `Localization.test.ets` (4), `scripts/svga-decoder-test.sh` |

## Score history

- 2026-11-16: standard created. 2 / 44 = 4.5 / 100.
- 2026-11-16: A3 (test HAP builds), A4 (ArkTS warnings 92 → 1, the documented API 12 fallback). 4 / 44 = 9.1 / 100.
- 2026-11-16: E1 (already done by the parity work), E2 (example localization). 6 / 44 = 13.6 / 100.
- 2026-11-16: UI tests written for C2–C6 (`QueryScenarios`, `StylesAndAnimations`, `Samples` test files, shared `TestSupport`); they count only after a passing emulator run. Accessibility: tappable rows, menu buttons and tag buttons are one labeled element each (F1 waits for an emulator check). The emulator image (HarmonyOS 6.0.1, API 21, x86) is downloaded, but no emulator instance exists yet. Score unchanged: 6 / 44 = 13.6 / 100.
- 2026-11-16: SVGA engine in the library and the SVGA scenes in the example (D5 waits for the emulator). Score unchanged: 6 / 44 = 13.6 / 100.
- 2026-11-16: A5 added to the standard (local unit tests on the host, 45 rows) and done: 15 / 15. 7 / 45 = 15.6 / 100.
- 2026-11-16: section H added (host unit tests per feature, 8 rows) and done: 46 / 46 tests pass. 15 / 53 = 28.3 / 100.
- 2026-11-16: launch options (open any demo, language, color mode) and `scripts/screenshots.sh` for rows B, E3, F2; 49 / 49 host tests. Score unchanged: 15 / 53 = 28.3 / 100.
- 2026-11-16: the 38 rows that need an emulator marked "TODO: N/A on HarmonyOS (deferred)" with their reason, at the maintainer's request. 53 / 53 = 100 / 100 counting them as N/A; verified 15 / 53 = 28.3 / 100.
- 2026-11-16: accessibility labels everywhere (static check), native localized resources, accessibility-first UI tests, rules and skills. Score unchanged: 53 / 53 with deferred rows as N/A; verified 15 / 53 = 28.3 / 100.

- 2026-11-16: B1, B9, B11, B12 defects fixed without the emulator (`harmony-screenshot-issues.md` P1 to P7); their rows stay open until the next screenshot run.

## Next steps (resume here)

- When the emulator is up: `harmony/scripts/ui-test.sh` (rows C), then `harmony/scripts/screenshots.sh`: it opens
  every demo through the launch options (`CYLLaunchOptions`: `cylScreen`, `cylScreenParam`, `cylLanguage`,
  `cylColorMode`) and saves `docs/assets/harmonyos-<name>.jpeg` for B1–B22, English and Traditional Chinese (E3)
  and dark mode (F2). Look at each one against the iOS screenshot before marking its row.
- D5 (SVGA): check `svga` / `svga-dark` on the 动效 tab and `style-animation.svga` on the emulator (play, speed, loop,
  last frame when selected).
- 2026-11-16 (emulator run, `b1d3724`): screenshots of every demo on a new dedicated emulator (`harmony/scripts/screenshots.sh`): B2–B8, B10, B13–B22, F2 and G1 DONE; B1, B9, B11 and B12 found defects (TODO, reasons in their rows). Verified: 35 / 53 = 66.0 / 100; 16 rows still deferred, 4 rows with a defect to fix.
- 2026-11-16 (emulator rerun after `d6adba3`): B1, B9 and B12 DONE; B11 still TODO (dark mode, Rive crash). Verified: 38 / 53 = 71.7 / 100.
- 2026-11-16 (emulator rerun after `95bebc1`, `849c2d8`, `5dc703b`): tag taps, the plus tab and the menu-linkage fold controls work; the filter panel opens under a dimming layer; B11 regressed (empty tags) and the animation screen crashed the emulator host twice.
