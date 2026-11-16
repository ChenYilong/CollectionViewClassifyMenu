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

**Score: 0 / 26 = 0 / 100** (updated with every fix).

## Task log

- **TODO (2026-11-16).** Prompt, verbatim: 「我已经更新了鸿蒙代码在模拟器上的截图 并更新了鸿蒙相关文档，请查看当前代码的运行截图，识别出截图中存在的问题 。给出issues猎鸟，每发现一个问题就新增一行，第二列写修复工作状态默认填TODO，给出打分机制，这个表格没有TODO 为满分，在没有模拟器的前提下修复issues，我会在你全部修复好后统一运行截图。每次修复一个issue就更新TODO为 TODO need 模拟器截图验证，更新所有TODO后视为满分。一直修复到满分为止。记录所有异常 不限于本仓库的异常，其他仓库的异常也一并列出。比如 tabbar 的badge为文字的时候，文字显示异常，NEW字样 无法一行显示，被换行了。疑似是badge大小未根据字体大小 字体做大小适配拉伸，怀疑是写死了badge的大小。需要根据label文字适配badge大小，参考android与I iOS端实现。 icon 与title y轴放点中心线未对齐。类似的issue也都要列出。」
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
| T1 | A text badge ("NEW") wraps to two lines ("NE" / "W"): the badge has a fixed size instead of growing with its text (Android and iOS: a pill at least as wide as it is high, width from the text) | TODO |
| T2 | The badge size changes with the tab bar style: small "8" in the classic bar, a large circle in Liquid Glass, a tiny one with the Ocean skin; it should follow the badge font only | TODO |
| T3 | Badges cover the icon (the purple "8" hides most of the Nearby icon in Liquid Glass and FlatDesign); the badge should sit at the icon's top-right corner, offset as on iOS | TODO |
| T4 | Icon and title are not on the same vertical center line (Nearby, Me: the icon is shifted from the title's center) | TODO |
| T5 | The "NEW" badge is faded (semi-transparent) in some styles: it takes the item's opacity / tint instead of keeping its own colors | TODO |
| T6 | Liquid Glass: the selected item's highlight is a square clipped by the capsule's rounded corner; it should follow the capsule's shape | TODO |
| T7 | Skinned plus button: in FlatDesign the skin image replaces the round plus button without its circle and spills over the bar, while the classic bar keeps the default "+"; the plus button should be skinned the same way in every style | TODO |
| T8 | FlatDesign with the Space skin is two-tone: the bar is light gray while the area below it (gesture bar) is dark navy | TODO |
| T9 | FlatDesign with a skin: titles are light blue on light gray, too little contrast | TODO |
| T10 | The list is not inset for the tab bar and the raised plus button: the last row ("设置 CYLFlatDesignTabBarItem 背景色") is hidden behind them | TODO |
| T11 | Untranslated English in the Chinese UI: "tabBarHidden = false; hidden, it comes back after 2 s", "cyl_tabBarMinimizeBehavior = Never; tap to choose, then scroll this list" | TODO |
| T12 | Navigation bar: the title "首页" sits lower than the bar buttons (扁平样式, 液态玻璃, 换肤); title and buttons are not vertically centered on one line | TODO |

### CollectionViewClassifyMenu (this repository)

| # | Issue | Status |
| --- | --- | --- |
| C1 | The HarmonyOS screenshots in `docs/assets` (`harmonyos-tags`, `harmonyos-classify-filtered`, `harmonyos-filter`, `harmonyos-animation-playback-controls`) show the old two-tab example, not the current 22-demo port; the docs present them as the current app | TODO |
| C2 | Old example: English UI ("Filter", "Regions", "Dishes", "OK", "Tapped Home") mixed with Chinese headers and items ("吃", "全部") in one screen | TODO |
| C3 | Old example: "广州: 1 places": no singular / plural ("1 place") | TODO |
| C4 | A fold arrow is shown on sections that have nothing to fold (every section of the classify menu and the Lottie section, with one row) | TODO |
| C5 | Result rows repeat the region: title "川菜 · 广州", subtitle "广州" (HarmonyOS, Flutter) | TODO |
| C6 | Filter sheet: the default selection ("全部" in each section) is not shown as selected | TODO |
| C7 | Filter sheet: the last row is cut off at the bottom, with no space above the OK button | TODO |
| C8 | Animated icons screen: the title "动画图标" and the controls are Chinese while the tags are English (one screen, two languages) | TODO |

### React Native and Flutter examples on HarmonyOS (this repository)

| # | Issue | Status |
| --- | --- | --- |
| R1 | React Native: the tab bar titles are Chinese ("标签", "发布", "分类") while the screen is English ("Speed", "Loop", "Play all") | TODO |
| R2 | React Native: the plus button's page is a bare placeholder ("加号按钮的页面") with no title or way to tell what it is for | TODO |
| R3 | React Native: the raised plus button's title "发布" sits lower than the other tab titles (not on one baseline) | TODO |
| F1 | Flutter: the screenshot shows the DEBUG banner (a debug build on screen) | TODO |
| F2 | Flutter: the result summary "全部 · 全部 · 全部 · 83" has no labels (iOS: "分类：… · 地区：… · 菜品：…"), and is Chinese in an English screen ("Classify menu", "Animated icons") | TODO |
| F3 | Flutter: no tag is shown as selected in the classify menu although the results are for "全部" | TODO |

## Score history

- 2026-11-16: table created, 26 issues, all `TODO`. 0 / 26.
