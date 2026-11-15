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
- Environment: Windows 11, DevEco Studio 6.0.1.251, SDK API 21; Mate 70 Pro emulator image installing.

## Score

**Score: see the tables; recomputed at every change.** Full marks = every row `DONE` / `N/A`.

### A. Build and code quality (4)

| # | Check | Status | Evidence |
| --- | --- | --- | --- |
| A1 | `harmony/scripts/build.sh`: the `classifymenu` HAR builds | DONE | BUILD SUCCESSFUL, 2026-11-16 |
| A2 | `harmony/scripts/build.sh`: the `entry` HAP builds | DONE | BUILD SUCCESSFUL, 2026-11-16 |
| A3 | The instrumented test HAP (`entry@ohosTest`) builds | DONE | BUILD SUCCESSFUL, 2026-11-16 |
| A4 | No ArkTS warning in our sources (library and example; third-party packages excluded) | DONE | 92 → 1. Model code measures through `CYLUIContext` (the components' `UIContext`: `getMeasureUtils()`, `px2vp`); `UIContext.animateTo`, `getPromptAction()`, `showAlertDialog`; `CYLAccessibilitySelectedModifier` sets `accessibilitySelected` only on API 13+; database calls in try/catch; unique back-button ids. The one left: `getContext()` in `CYLUIContext.hostContext`, the API 12–17 fallback (its replacement `UIContext.getHostContext()` exists from API 18, used there) |

### B. Every demo runs on the emulator, screenshot next to iOS (22)

One row per demo of [harmony.md](harmony.md) table 2. `DONE` = opened on the Mate 70 Pro emulator, behaves as the
iOS demo (texts, data, taps), screenshot `docs/assets/harmonyos-<demo>.png` linked in `screenshots.md`.

| # | Demo (HarmonyOS page) | Status |
| --- | --- | --- |
| B1 | Root tab bar (`pages/Index`) | TODO |
| B2 | `CYLProductPage` | TODO |
| B3 | `CYLReviewListPage` (memory, network, database) | TODO |
| B4 | `CYLSearchHomePage` | TODO |
| B5 | `CYLSearchCategoryPage` | TODO |
| B6 | `CYLSearchCategoryPage.page()` (each category tab) | TODO |
| B7 | `CYLSearchDiscoverPage` | TODO |
| B8 | `CYLQueryScenariosPage` | TODO |
| B9 | `CYLMenuLinkagePage` | TODO |
| B10 | `CYLTagStylePage` | TODO |
| B11 | `CYLTagAnimationPage` | TODO |
| B12 | `CYLTagConfigurationPage` | TODO |
| B13 | `CYLTagCloudDemoPage` | TODO |
| B14 | `CYLTagCloudSamplePage` | TODO |
| B15 | `CYLTagCloudSubPage` | TODO |
| B16 | `CYLTagCloudListPage` | TODO |
| B17 | `CYLTagCloudRecyclerPage` | TODO |
| B18 | `CYLHotSearchPage` | TODO |
| B19 | `CYLImageTagSamplePage` | TODO |
| B20 | `CYLImageTagEditPage` | TODO |
| B21 | `CYLImageTagListPage` | TODO |
| B22 | `CYLTagContainerSamplePage` | TODO |

### C. UI tests (6)

Instrumented tests in `harmony/entry/src/ohosTest`, one test file per feature (as the iOS example tests), finding
views by accessibility text or id; `DONE` = written and passing in `harmony/scripts/ui-test.sh` on the emulator.

| # | Feature | Status |
| --- | --- | --- |
| C1 | Tags: selection, folding, Play all (existing `ExampleUi.test.ets`) | TODO |
| C2 | Scenario 1: product → reviews, filter tags, memory / network / database sources | TODO |
| C3 | Scenario 2: search home, category tabs, discover (recent, 换一批) | TODO |
| C4 | Classify menu and multiple filter (`CYLMenuLinkagePage`), query scenarios | TODO |
| C5 | Styles, animations (speed, loop, Play all), configuration | TODO |
| C6 | Samples: tag cloud, hot search, image tags, tag containers | TODO |

### D. Animation engines on the emulator (5)

| # | Engine | Check | Status |
| --- | --- | --- | --- |
| D1 | Lottie (`@ohos/lottie`) | plays, speed, loop, Play all restarts at 0, last frame when selected on first load | TODO |
| D2 | PAG (`@tencent/libpag`) | loads from the rawfile folder, plays, speed, loop | TODO |
| D3 | Rive (`@ohos/rive`) | plays, state-machine options, loop; no speed (engine limit, stated in the page) | TODO |
| D4 | GIF (ImageKit frames) | decodes, plays, speed, loop | TODO |
| D5 | SVGA | the SVGA scenes mirror the Rive scenes (`issue-progress.md`, SVGA TODO) | TODO |

### E. Localization (3)

| # | Check | Status |
| --- | --- | --- |
| E1 | Core strings in `en`, `zh-Hans` (`zh_CN`) and `zh-Hant` (`zh_TW` / `zh_HK`), generated from the iOS core bundle | TODO |
| E2 | Example strings in the same three languages, from the iOS example bundle; no user-facing literal in `.ets` code | TODO |
| E3 | The example follows the system language on the emulator (screenshot in English) | TODO |

### F. Accessibility and appearance (2)

| # | Check | Status |
| --- | --- | --- |
| F1 | Every control has an accessibility text; selected state announced (API 12 fallback for `accessibilitySelected`) | TODO |
| F2 | Dark mode renders on the emulator (screenshot) | TODO |

### G. Documentation (2)

| # | Check | Status |
| --- | --- | --- |
| G1 | `screenshots.md` and `cross-platform.md` list the HarmonyOS screenshots of every demo | TODO |
| G2 | `harmony.md`, `cross-platform.md` and `README.md` state the verified state (no "compile only" left) | TODO |

## Score history

- 2026-11-16: standard created. 2 / 44 = 4.5 / 100.
- 2026-11-16: A3 (test HAP builds), A4 (ArkTS warnings 92 → 1, the documented API 12 fallback). 4 / 44 = 9.1 / 100.

## Next steps (resume here)

- E2, in progress (2026-11-16): the example has 410 distinct Chinese literals (scan: `py -3 C:\w\scan_han.py .`);
  about 200 are sample data (reviews, names, places), which iOS also leaves untranslated. Plan: add
  `harmony/scripts/export-example-strings.py`, which generates `CYLExampleStrings.ets` from
  `Example/CYLMenuExample/CYLMenuExample.bundle/*.lproj/Localizable.strings` (iOS keys are the Chinese text; formats
  use `%@` / `%ld`). Then add `CYLExampleLocalizedString(key)` (language matching as in `CYLMenuResources`), wrap
  every key literal, and turn the template strings into the iOS format keys through `cylFormat`. Keep `.id()` values
  language-independent, because the UI tests depend on them.
- When the emulator is up: `harmony/scripts/ui-test.sh` (set `DEVECO` to the Windows path), then B1–B22
  screenshots, C, D, F2.
- D5 (SVGA): no ohpm SVGA package exists (`@ohos/svgaplayer` and others return 404). It needs an ArkTS player
  (zlib + protobuf + Canvas), after the iOS core has SVGA.
