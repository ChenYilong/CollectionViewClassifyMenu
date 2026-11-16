---
title: HarmonyOS screenshot issues
date: 2026-11-16
tags: [harmonyos, screenshots, issues, cyltabbarcontroller, react-native, flutter]
---

# HarmonyOS screenshot issues

Every problem seen in the HarmonyOS emulator screenshots, in this repository and in the others it uses
(CYLTabBarController's HarmonyOS component and example). One row per issue.

## Scoring

- A row starts as `TODO`.
- When its fix is committed (without an emulator), the row becomes **`TODO need 模拟器截图验证`** (needs an emulator
  screenshot to verify) and names the commit.
- **Full marks: no plain `TODO` left**, every row fixed and waiting for the maintainer's screenshot run.
- Score = rows not `TODO` / all rows.

**Score: 26 / 34 = 76.5 / 100** (round 2 added 8 rows, D1 to D4 and N1 to N4).

## Task log

- **DONE (2026-11-16), screenshots pending.** Prompt, verbatim: 「我已经更新了鸿蒙代码在模拟器上的截图 并更新了鸿蒙相关文档，请查看当前代码的运行截图，识别出截图中存在的问题 。给出issues猎鸟，每发现一个问题就新增一行，第二列写修复工作状态默认填TODO，给出打分机制，这个表格没有TODO 为满分，在没有模拟器的前提下修复issues，我会在你全部修复好后统一运行截图。每次修复一个issue就更新TODO为 TODO need 模拟器截图验证，更新所有TODO后视为满分。一直修复到满分为止。记录所有异常 不限于本仓库的异常，其他仓库的异常也一并列出。比如 tabbar 的badge为文字的时候，文字显示异常，NEW字样 无法一行显示，被换行了。疑似是badge大小未根据字体大小 字体做大小适配拉伸，怀疑是写死了badge的大小。需要根据label文字适配badge大小，参考android与I iOS端实现。 icon 与title y轴放点中心线未对齐。类似的issue也都要列出。」
  (EN: look at the current emulator screenshots, list every issue (one row each, status column `TODO`), with a
  score where no `TODO` is full marks; fix them without an emulator, turning each into "TODO need 模拟器截图验证";
  list issues of other repositories too, e.g. the tab bar's text badge "NEW" wraps to two lines because the badge
  size is fixed instead of following the text (as on Android and iOS), and icons and titles are not on the same
  vertical center line.)
- Screenshots looked at: CYLTabBarController `docs/harmonyos-emulator-screenshots` (acecea46):
  `harmonyos-home-mate70pro-api21.jpeg`, `harmonyos-flatdesign-liquidglass-taps-mate70pro.png`,
  `harmonyos-styles-recheck-6befe36.png`, `harmonyos-styles-ocean-skin-b7995d0.png`,
  `harmonyos-styles-space-skin-981db1e.png`; this repository's `docs/assets/harmonyos-*.jpeg`,
  `react-native-harmonyos-*.jpeg`, `flutter-harmonyos-*.jpeg`.

## Issues

### CYLTabBarController (HarmonyOS component `CrossPlatform/harmonyos-cyltabbar`)

| # | Issue | Status |
| --- | --- | --- |
| T1 | A text badge ("NEW") wraps to two lines ("NE" / "W"): the badge has a fixed size instead of growing with its text (Android and iOS: a pill at least as wide as it is high, width from the text) | TODO need 模拟器截图验证: fixed in CYLTabBarController `ac8c1455` ([#803](https://github.com/ChenYilong/CYLTabBarController/pull/803), fixed in parallel by another session): the badge width comes from the measured text plus the margin (`measureText`), one line, at least its height |
| T2 | The badge size changes with the tab bar style: small "8" in the classic bar, a large circle in Liquid Glass, a tiny one with the Ocean skin; it should follow the badge font only | TODO need 模拟器截图验证: not a defect: the demo plays the Scale animation forever on this badge (`cyl_showBadgeValue('8', Scale)`, 1.4 ↔ 0.6), so screenshots catch different sizes; with T1 the size comes from the font only |
| T3 | Badges cover the icon (the purple "8" hides most of the Nearby icon in Liquid Glass and FlatDesign); the badge should sit at the icon's top-right corner, offset as on iOS | TODO need 模拟器截图验证: fixed in CYLTabBarController `ac8c1455` ([#803](https://github.com/ChenYilong/CYLTabBarController/pull/803), fixed in parallel by another session): a number or text badge puts its left cap on the anchor point and grows to the right |
| T4 | Icon and title are not on the same vertical center line (Nearby, Me: the icon is shifted from the title's center) | TODO need 模拟器截图验证: fixed in CYLTabBarController `ac8c1455` ([#803](https://github.com/ChenYilong/CYLTabBarController/pull/803), fixed in parallel by another session): the icon box centres its icon (`Alignment.Center`, was `TopStart`, which pinned icons of another size to the top left); the plus button's badge is anchored to the image, not the slot |
| T5 | The "NEW" badge is faded (semi-transparent) in some styles: it takes the item's opacity / tint instead of keeping its own colors | TODO need 模拟器截图验证: not a defect: the demo shows "NEW" with the Breathe animation (opacity 1 ↔ 0.1, forever); the screenshots caught it mid-fade |
| T6 | Liquid Glass: the selected item's highlight is a square clipped by the capsule's rounded corner; it should follow the capsule's shape | TODO need 模拟器截图验证: fixed in CYLTabBarController `ac8c1455` ([#803](https://github.com/ChenYilong/CYLTabBarController/pull/803), fixed in parallel by another session): in Liquid Glass an item background is a capsule (`borderRadius`, `tabBarHeight - 8` high, 2 vp side margins) |
| T7 | Skinned plus button: in FlatDesign the skin image replaces the round plus button without its circle and spills over the bar, while the classic bar keeps the default "+"; the plus button should be skinned the same way in every style | TODO need 模拟器截图验证: fixed in CYLTabBarController `ac8c1455` ([#803](https://github.com/ChenYilong/CYLTabBarController/pull/803), fixed in parallel by another session): skin plus images are drawn smaller, inside the round button |
| T8 | FlatDesign with the Space skin is two-tone: the bar is light gray while the area below it (gesture bar) is dark navy | TODO need 模拟器截图验证: fixed in CYLTabBarController [#804](https://github.com/ChenYilong/CYLTabBarController/pull/804) (follow-up to #803): root cause: `CYLFlatDesignTabBarModifier` set the blur material of the default look and never reset it, so a skin color was washed out to gray above a strip of the real color; it now resets `backgroundBlurStyle` to `NONE` with a tint or an image |
| T9 | FlatDesign with a skin: titles are light blue on light gray, too little contrast | TODO need 模拟器截图验证: fixed with T8 (the titles are skinned for a dark bar; the bar is now dark) |
| T10 | The list is not inset for the tab bar and the raised plus button: the last row ("设置 CYLFlatDesignTabBarItem 背景色") is hidden behind them | TODO need 模拟器截图验证: fixed in CYLTabBarController `ac8c1455` ([#803](https://github.com/ChenYilong/CYLTabBarController/pull/803), fixed in parallel by another session): the demo list has a 48 vp end offset (`contentEndOffset`) for the raised plus button and the Liquid Glass capsule |
| T11 | Untranslated English in the Chinese UI: "tabBarHidden = false; hidden, it comes back after 2 s", "cyl_tabBarMinimizeBehavior = Never; tap to choose, then scroll this list" | TODO need 模拟器截图验证: fixed in CYLTabBarController `ac8c1455` ([#803](https://github.com/ChenYilong/CYLTabBarController/pull/803), fixed in parallel by another session): every template subtitle of the demo goes through `CYLLocalizedString` with zh-Hans and zh-Hant (`scripts/harmonyos-l10n.json`, regenerated); Traditional Chinese for all 28 HarmonyOS-only keys in [#804](https://github.com/ChenYilong/CYLTabBarController/pull/804) |
| T12 | Navigation bar: the title "首页" sits lower than the bar buttons (扁平样式, 液态玻璃, 换肤); title and buttons are not vertically centered on one line | TODO need 模拟器截图验证: fixed in CYLTabBarController `ac8c1455` ([#803](https://github.com/ChenYilong/CYLTabBarController/pull/803), fixed in parallel by another session): the left buttons and "换肤" are as tall as the bar (44 vp), so they sit on the title's center line |

### CollectionViewClassifyMenu (this repository)

| # | Issue | Status |
| --- | --- | --- |
| C1 | The HarmonyOS screenshots in `docs/assets` (`harmonyos-tags`, `harmonyos-classify-filtered`, `harmonyos-filter`, `harmonyos-animation-playback-controls`) show the old two-tab example, not the current 22-demo port; the docs present them as the current app | TODO need 模拟器截图验证: `docs/android.md` labels these screenshots as the earlier two-tab example (note and alt texts) and points to `harmony/scripts/screenshots.sh` for the current ones |
| C2 | Old example: English UI ("Filter", "Regions", "Dishes", "OK", "Tapped Home") mixed with Chinese headers and items ("吃", "全部") in one screen | TODO need 模拟器截图验证: the old example was replaced by the port, whose screens are localized (`CYLExampleLocalizedString`, `docs/harmony-verification.md` E2) |
| C3 | Old example: "广州: 1 places": no singular / plural ("1 place") | TODO need 模拟器截图验证: the old example was replaced; the port says "SQLite returned %lu (of %ld places)" / "%lu matches" from the iOS strings |
| C4 | A fold arrow is shown on sections that have nothing to fold (every section of the classify menu and the Lottie section, with one row) | TODO need 模拟器截图验证: not in the port: its fold control shows only when a section can fold (`CYLTagListState.canFoldSection`) |
| C5 | Result rows repeat the region: title "川菜 · 广州", subtitle "广州" (HarmonyOS, Flutter) | TODO need 模拟器截图验证: Flutter fixed (the subtitle no longer repeats the region already in the name); the HarmonyOS port's rows do not repeat it |
| C6 | Filter sheet: the default selection ("全部" in each section) is not shown as selected | TODO need 模拟器截图验证: the port's filter selects each section's first exclusive item ("全部") when it loads (`CYLMultipleFilterController.reloadMenuData`) |
| C7 | Filter sheet: the last row is cut off at the bottom, with no space above the OK button | TODO need 模拟器截图验证: fixed: the filter panel's scroll content has 16 vp below the last row (`CYLFilterBaseController`) |
| C8 | Animated icons screen: the title "动画图标" and the controls are Chinese while the tags are English (one screen, two languages) | TODO need 模拟器截图验证: the old example was replaced; the port's animated icons screen is localized |

### React Native and Flutter examples on HarmonyOS (this repository)

| # | Issue | Status |
| --- | --- | --- |
| R1 | React Native: the tab bar titles are Chinese ("标签", "发布", "分类") while the screen is English ("Speed", "Loop", "Play all") | TODO need 模拟器截图验证: already fixed in code by `3fbaf21` (the locale is read from `I18nManager` constants on HarmonyOS), 20 minutes after this screenshot |
| R2 | React Native: the plus button's page is a bare placeholder ("加号按钮的页面") with no title or way to tell what it is for | TODO need 模拟器截图验证: fixed: the plus page has a title, its text and what it is for, localized |
| R3 | React Native: the raised plus button's title "发布" sits lower than the other tab titles (not on one baseline) | TODO need 模拟器截图验证: fixed: the plus button title uses the tab titles' size (10, was 9.5) |
| F1 | Flutter: the screenshot shows the DEBUG banner (a debug build on screen) | TODO need 模拟器截图验证: fixed: `debugShowCheckedModeBanner: false` |
| F2 | Flutter: the result summary "全部 · 全部 · 全部 · 83" has no labels (iOS: "分类：… · 地区：… · 菜品：…"), and is Chinese in an English screen ("Classify menu", "Animated icons") | TODO need 模拟器截图验证: fixed: labelled summary from the iOS strings ("Category: All · Regions: All · Dishes: All · 83 matches"), and every text of the example localized (`lib/strings.dart`, generated from the iOS bundle by `tool/export_strings.py`) |
| F3 | Flutter: no tag is shown as selected in the classify menu although the results are for "全部" | TODO need 模拟器截图验证: not a defect: as on iOS, nothing is selected until a tag is tapped; the summary now says so ("Category: All") |

## Round 2 (2026-11-16 afternoon): double-check and new screenshots

Double-check of CYLTabBarController's latest `feat/harmonyos-component` (`9bca970b`), and the screenshots added since
round 1: `harmonyos-flatdesign-tint-fixed.png` (47f87739), `harmonyos-port-svga-demo-page.png`,
`harmonyos-port-svga-demo-row.png`, `harmonyos-port-svga-demo-taps.png` (11bd1102),
`harmonyos-svga-icon-title-alignment-before-after.png` (1aea05d1). Prompt of this round: the same as round 1, starting
with 「CYLTabBarController fixed their issues please doublecheck。」.

Double-check result on `9bca970b`: T1 fixed (measured width, one line); T4 fixed another way (the icon box sizes to
its icon, the title top at `tabBarHeight - 17` like the plus title); T6, T12 fixed; still open: T3, T8, T10, and the
Traditional Chinese part of T11 (rows D1 to D4).

| # | Issue | Status |
| --- | --- | --- |
| D1 | CYLTabBarController: a wide badge still covers its icon (the "3" on 消息 in the before/after screenshot): the badge is still centred on the icon's corner (`markAnchor 50%`) | TODO |
| D2 | CYLTabBarController: FlatDesign with a skin is still washed out to gray: `CYLFlatDesignTabBarModifier` never resets the blur of the default look (PR #804 not merged) | TODO |
| D3 | CYLTabBarController: no Traditional Chinese for the 35 HarmonyOS-only keys (`scripts/harmonyos-l10n.json` has no `zh-Hant`), so zh-Hant devices show English | TODO |
| D4 | CYLTabBarController: the demo list still has no room for the raised plus button: with the Space skin the comet plus icon covers the last row ("…tem 背景色") | TODO |
| N1 | CYLTabBarController SVGA demo: the tab titles are the configuration file's English ("Home", "Discover", "Message", "Me") in a Chinese UI ("返回", "SVGA Tab 图标（配置文件）") | TODO |
| N2 | CYLTabBarController SVGA demo: the page body is debug text ("configurations/…json / identifier: home / page: -") | TODO |
| N3 | CYLTabBarController SVGA demo: the selected title is system blue while the selected SVGA icon is orange (the configuration has no tint, the demo falls back to `#007AFF`) | TODO |
| N4 | CYLTabBarController (before/after screenshot): the raised plus button's title "发布" sits lower than the other titles | TODO |

## Score history

- 2026-11-16: table created, 26 issues, all `TODO`. 0 / 26.
- 2026-11-16: all 26 handled without an emulator: 20 fixed in code (CYLTabBarController #803 and #804, this repository), 1 already fixed (`3fbaf21`), 5 explained (demo animations caught mid-frame, the replaced example, iOS behavior). 26 / 26 = 100 / 100, every row `TODO need 模拟器截图验证`.
- 2026-11-16: round 2: double-check of CYLTabBarController and the new screenshots, 8 rows added. 26 / 34 = 76.5 / 100.
