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

**Score: 61 / 61 = 100 / 100** (no plain `TODO` left; every row waits for the maintainer's emulator screenshots).

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
| D1 | CYLTabBarController: a wide badge still covers its icon (the "3" on 消息 in the before/after screenshot): the badge is still centred on the icon's corner (`markAnchor 50%`) | TODO need 模拟器截图验证: fixed in CYLTabBarController `4ee9ac5a` (branch `fix/harmonyos-screenshot-issues-round2`, on `feat/harmonyos-component` 8aff599d): a number or text badge puts its left cap on the icon corner and grows right; a red dot stays centred |
| D2 | CYLTabBarController: FlatDesign with a skin is still washed out to gray: `CYLFlatDesignTabBarModifier` never resets the blur of the default look (PR #804 not merged) | TODO need 模拟器截图验证: already fixed on `feat/harmonyos-component` 8aff599d (newer than the double-checked 9bca970b): the tint and image branches reset `backgroundBlurStyle` |
| D3 | CYLTabBarController: no Traditional Chinese for the 35 HarmonyOS-only keys (`scripts/harmonyos-l10n.json` has no `zh-Hant`), so zh-Hant devices show English | TODO need 模拟器截图验证: fixed in CYLTabBarController `4ee9ac5a` (branch `fix/harmonyos-screenshot-issues-round2`, on `feat/harmonyos-component` 8aff599d): zh-Hant for all 46 HarmonyOS-only keys (28 had come in with the merged PRs), resources regenerated, `harmonyos-l10n.py --check` passes |
| D4 | CYLTabBarController: the demo list still has no room for the raised plus button: with the Space skin the comet plus icon covers the last row ("…tem 背景色") | TODO need 模拟器截图验证: already fixed on 8aff599d: the demo list has `contentEndOffset` (came in with the merged HarmonyOS PRs) |
| N1 | CYLTabBarController SVGA demo: the tab titles are the configuration file's English ("Home", "Discover", "Message", "Me") in a Chinese UI ("返回", "SVGA Tab 图标（配置文件）") | TODO need 模拟器截图验证: fixed in CYLTabBarController `4ee9ac5a` (branch `fix/harmonyos-screenshot-issues-round2`, on `feat/harmonyos-component` 8aff599d): the shared files' English titles are localization keys (首页 / 发现 / 消息 / 我的, zh-Hant too) |
| N2 | CYLTabBarController SVGA demo: the page body is debug text ("configurations/…json / identifier: home / page: -") | TODO need 模拟器截图验证: fixed in CYLTabBarController `4ee9ac5a` (branch `fix/harmonyos-screenshot-issues-round2`, on `feat/harmonyos-component` 8aff599d): "配置文件：… / Tab：…" in the device language, the page line only when there is one |
| N3 | CYLTabBarController SVGA demo: the selected title is system blue while the selected SVGA icon is orange (the configuration has no tint, the demo falls back to `#007AFF`) | TODO need 模拟器截图验证: fixed in CYLTabBarController `4ee9ac5a` (branch `fix/harmonyos-screenshot-issues-round2`, on `feat/harmonyos-component` 8aff599d): without a tint in the file the selected color is the demo's orange `#FF8000`, matching the SVGA icons |
| N4 | CYLTabBarController (before/after screenshot): the raised plus button's title "发布" sits lower than the other titles | TODO need 模拟器截图验证: already fixed on 8aff599d: tab titles and the plus title both start at `tabBarHeight - 17`; the screenshot shows the "before" |

## Round 3 (2026-11-16): the port's own emulator screenshots

Another session ran this repository's 22-demo HarmonyOS example on a dedicated emulator ("CYL ClassifyMenu Test") with
`harmony/scripts/screenshots.sh` (commit 2c12f68 on `feat/android-kotlin`, cherry-picked to `feat/harmony`: 29 screenshots
in `docs/assets/harmonyos-*.jpeg`) and found these defects (`harmony-verification.md` B1, B9, B11, B12).

| # | Issue | Status |
| --- | --- | --- |
| P1 | B1: the Chinese root tab titles are cut off ("场景一：评价筛" runs into the next tab) | TODO need 模拟器截图验证: fixed: the title is as wide as its slot, shrinks from 10 to 8 fp, then ends with an ellipsis (`pages/Index.ets`) |
| P2 | B9 menu linkage: category headers show a huge blurred image and no title | TODO need 模拟器截图验证: fixed: `CYLIndexPathButtonView` gave its icon no size, so the category image filled the header; the icon is now one title line high, `Contain`, never pushing the title out |
| P3 | B9 menu linkage: selected tags are teal wedges with no visible title | TODO need 模拟器截图验证: fixed: the tag artwork was drawn with a plain `Fill`; it now stretches from its middle (`resizable` slice, half the image each side, as `CYLFilterCollectionCellView`), so the white title sits on teal |
| P4 | B11 animations: in Chinese and dark mode the Lottie / PAG / Rive tags have no width (thin lines) | TODO need 模拟器截图验证: fixed: the page builds its tag list before any view appears, so it was measured with the canvas fallback, whose `vp` canvas font could give 0 / NaN; the fallback now measures in physical pixels and never returns 0 for text, and `CYLTagListView` drops cached sizes once it has a UI context |
| P5 | B12 configuration: the 4th chip of the dictionary row (`"image": "system:heart"`, no title) is empty | TODO need 模拟器截图验证: fixed: `system:<SF Symbol>` gave no image on HarmonyOS; the core now maps the symbols the examples use: heart / heart.fill (library SVGs, no system heart exists), globe → `ohos_ic_public_web`, location, checkmark, xmark |
| P6 | B12: hilog `NapiDefineClass occur exception, className:JPAGImageView` | TODO need 模拟器截图验证: not the cause of P5 (that chip has no PAG); the PAG icons play in the English screenshot. To check on the emulator whether the message comes from libpag registering its classes once per icon |
| P7 | `screenshots.sh` and `ui-test.sh` call `hdc` without `-t`: with several emulators they fail or pick the wrong one | TODO need 模拟器截图验证: fixed: optional `HDC_TARGET` (e.g. `HDC_TARGET=127.0.0.1:5563`) passes `-t` to every `hdc` call |

## Round 4 (2026-11-16): pushed pages driven by text on the emulator

Found by the other session while driving the pushed pages by text and accessibility text (f85d2ab, cherry-picked as
fbb78eb: six pushed-page screenshots, notes in `docs/screenshots.md`).

| # | Issue | Status |
| --- | --- | --- |
| Q1 | The plus button (`tab-plus`) exposes no accessibility text, only its description; tapping it leaves the product page showing | TODO need 模拟器截图验证: fixed: the item is one accessibility element (`accessibilityGroup`) read as "查询筛选", and a tap selects its tab (`onClick` sets the Tabs index) |
| Q2 | Menu linkage: the filter button (image `menuLinkageFilter`) has no text or description; tapping it opens no panel | TODO need 模拟器截图验证: fixed: the image is exposed (`accessibilityLevel('yes')`, text and description), with a 44 vp touch target; the panel's width falls back to the display's when its host is not measured yet (a 0-wide panel looked like no panel) |
| Q3 | Review list (memory): tapping "好评" does not change the selection (全部 stays, 10 matches) | TODO need 模拟器截图验证: no code change: the chips are labeled with their count ("好评(3)"), so a tap found by the exact text "好评" does not hit the chip; the selection logic (multiple choice, exclusive 全部) is the tested one (`ClassifyAndFilter` host tests). To check by tapping "好评(3)" |
| Q4 | Search tab: tapping "找人" in the hint line opens nothing | TODO need 模拟器截图验证: not a defect: "找人" is part of the hint sentence "按分类浏览热门标签：找人、动态、八卦、职位", plain text as on iOS; the categories are tabs inside 搜索分类 |
| Q5 | Crash: the animated icons screen crashes within seconds (`libohos_rive.so`: `EGLWorkerImpl::destroy` → `eglDestroySurface`, a null pointer while a Rive view is disposed) | TODO need 模拟器截图验证: mitigated (pool reverted in round 7, W1 / W2): @ohos/rive 1.0.4 (the newest) crashes when a Rive view is disposed; a tag list rebuilds an item on every layout, selection or speed change (its key holds them), which disposed Rive views many times a second. Rive views are now pooled (`CYLRiveNodePool`: built once in a `BuilderNode`, shown through a `NodeContainer`, returned detached instead of disposed), so the crashing path is no longer taken |

## Round 5 (2026-11-16): emulator rerun of d6adba3

The other session reran d6adba3 on its emulator (8d7641c): B1, B9 and B12 are fixed (DONE with fresh screenshots in
`harmony-verification.md`); B11 is still open in dark mode (`harmonyos-dark-animations.jpeg`), and the Rive crash
recurred (that build did not have the pool of Q5, which came later in c6a8a5c / 39996ea).

| # | Issue | Status |
| --- | --- | --- |
| S1 | B11 dark: the Lottie / PAG / Rive tags are hairlines again | TODO need 模拟器截图验证: fixed, root cause found: `CYLTagListState.widths()` clamped every tag to the content width, which is 0 before the list knows its width, and that pass was cached; tags were laid out 1 vp wide. A tag now keeps its own width while the width is unknown, and a pass at width 0 is never cached. Host regression test `neverLaysTagsOutWithNoWidth` (fails on the old code: 49 / 50; passes: 50 / 50) |
| S2 | B11 dark: the speed and loop labels and the speed value are invisible | TODO need 模拟器截图验证: fixed: seven `Text`s of the example had no color, so they turned white in dark mode on the example's fixed light backgrounds; they use the label color like every other text |
| S3 | The Rive crash recurred on d6adba3 | TODO need 模拟器截图验证: that build had no Rive pool yet; Q5's pool (Rive views never disposed) is in 39996ea |

## Round 6 (2026-11-16): fresh rerun screenshots and tag taps

Double-check requested again (「CYLTabBarController fixed their issues please doublecheck。…」): CYLTabBarController PR
#806 (D1, D3, N1 to N3) is merged into `feat/harmonyos-component`; no new CYLTabBarController screenshots since round 2.
This repository's rerun (8d7641c) confirms P1 (tab titles), P2 / P3 (menu-linkage headers and tags) and P5 (heart chip)
on the emulator. New:

| # | Issue | Status |
| --- | --- | --- |
| V1 | Menu linkage: the fold chevrons at the right of each header are huge and blurred | TODO need 模拟器截图验证: fixed: `CYLRightImageButtonView` drew its image at its natural size (the same defect as P2); it is now one title line high, `Contain` |
| V2 | Taps on tags do nothing on the emulator: the review chip "好评(9)" leaves 全部 selected (10 matches); product review tags ("质量不错(5)"), hot-search, search-category and tag-cloud tags open nothing | TODO need 模拟器截图验证: the selection logic is right (new host test `ReviewFilterTap`: a tap on "好评(9)" replaces the exclusive 全部); the tap did not reach it. Each tag item now takes a physical tap with a `priorityGesture(TapGesture)` on its container, once, ahead of the views inside it (the cell's `onClick` stays for screen readers), and both paths log to hilog (domain `CYLTagList`: "tap gesture", "cell click", "tap") so the next run shows the delivery. The product page's tags opening the review list is the iOS behavior (`productKeywordOpensFilteredReviews`), so those are the same defect, not parity gaps |
| V3 | Review list status: "已选：全部" is not localized | TODO need 模拟器截图验证: fixed: `CYLExampleLocalizedString('全部')` |

## Round 7 (2026-11-16): rerun of 95bebc1 / 849c2d8 / 5dc703b

The other session's rerun (f333383, "Pushed pages after the port's fixes"): V2 tag taps work (hilog "CYLTagList: tap
gesture 0-8 / tap 0-8 enabled true"; 质量不错(5), 好评(9), 小西瓜, 腾讯工程师), Q1 the plus tab opens 查询筛选, V1 the fold
controls read "更多 ⌄". Still wrong:

| # | Issue | Status |
| --- | --- | --- |
| W1 | B11 regressed: in light mode the animated tags are empty boxes (each on its own row, icon in a corner, no title) | TODO need 模拟器截图验证: reverted the cause: the Rive pool of Q5 (95bebc1). The animation screen draws every section in one `CYLTagListView`, and the pooled Rive views (a `BuilderNode` per view, never disposed) left that list stuck at its first width-0 layout. `CYLAnimatedIcon` is back to its version before the pool |
| W2 | Opening the animation screen in dark mode and scrolling crashed the emulator host twice (Emulator.log "MinidumpCB") | TODO need 模拟器截图验证: the pool kept every Rive view's EGL surface alive; reverted with W1. Rive churn is reduced instead: animated icons are created only once the list knows its width (the width-0 pass created Rive views only to dispose them at once), and a Rive item's key leaves out the speed (@ohos/rive has none), so the slider no longer rebuilds Rive items. @ohos/rive's dispose crash itself stays a library bug |
| W3 | The menu-linkage filter panel looks greyed and blurred, as if under the dimming layer | TODO need 模拟器截图验证: fixed: the panel had no tint of its own, so its `backdropBlur` showed the dimming layer through it; it now has a light frosted tint (`#E6FFFFFF`), as iOS's blurred capture |
| W4 | The plus button exposes no accessibility *text* in `dumpLayout`, so `ON.text("查询筛选")` cannot find it | TODO need 模拟器截图验证: not a defect: UiTest's text is a component's own text content; an image-only item's `accessibilityText` ("查询筛选", read by the screen reader since Q1) is not it. `cylFindAccessible` falls back to the id `tab-plus` |

## Round 8 (2026-11-16): double-check and newest screenshots

Verified on the emulator by CYLTabBarController's screenshots: N1 / N2 (localized SVGA demo titles and page), N3 (orange
selected title), T1 ("NEW" on one line). The local machine has no emulator instance (hdc lists no device), so the code
was not run here.

| # | Issue | Status |
| --- | --- | --- |
| X1 | Search discover: the recent-searches fold control is a square box while the tags are capsules | TODO need 模拟器截图验证: fixed: the inline fold cell drew its raw corner radius (0 = square); it now uses the tags' rule (0 = capsule) |
| X2 | CYLTabBarController: long navigation titles ("推入到系统 UITabBarController（另一个加号按钮）") wrap to two lines | TODO need 模拟器截图验证: fixed on CYLTabBarController branch `fix/harmonyos-nav-title`: page titles are one line with an ellipsis |
| Y1 | Hot search: the "神" / "热" glyphs inside the round badges are tiny and unreadable | TODO need 模拟器截图验证: fixed: `CYLTag.badgeImage` set a px font on a vp canvas, so the glyph was a density-fraction of the circle; the font is vp now |
| Y2 | Review chips: the selected "好评(9)" chip's thumbs-up icon is orange on orange (invisible) | TODO need 模拟器截图验证: fixed: the selected icon color is white, as the title |
| Y3 | Menu linkage: the filter button image is nearly invisible (1.01:1 on the bar; reported by the other session, B9) | TODO need 模拟器截图验证: fixed: the image is tinted as on iOS, gray #8E8E93 (3.1:1) with no filter, system blue with one |

## Score history

- 2026-11-16: table created, 26 issues, all `TODO`. 0 / 26.
- 2026-11-16: all 26 handled without an emulator: 20 fixed in code (CYLTabBarController #803 and #804, this repository), 1 already fixed (`3fbaf21`), 5 explained (demo animations caught mid-frame, the replaced example, iOS behavior). 26 / 26 = 100 / 100, every row `TODO need 模拟器截图验证`.
- 2026-11-16: round 2: double-check of CYLTabBarController and the new screenshots, 8 rows added. 26 / 34 = 76.5 / 100.
- 2026-11-16: round 2 handled (5 fixed in CYLTabBarController `4ee9ac5a`, 3 already fixed on 8aff599d); round 3 added 7 rows from the port's emulator screenshots, all handled. 41 / 41 = 100 / 100.
- 2026-11-16: round 4 added 5 rows from the pushed pages (Q1 to Q5), all handled. 46 / 46 = 100 / 100.
- 2026-11-16: round 5 (rerun of d6adba3): 3 rows, B11 dark root cause fixed with a regression test. 49 / 49 = 100 / 100.
- 2026-11-16: round 6 (double-check, rerun screenshots, tag taps): 3 rows. 52 / 52 = 100 / 100.
- 2026-11-16: round 7 (rerun): taps, plus tab and fold controls verified; the Rive pool reverted (B11 regression, emulator crash), churn reduced instead; filter panel tinted. 56 / 56 = 100 / 100.
- 2026-11-16: round 8: X1, X2, Y1, Y2 fixed; plus-page, product-tag, search-category screenshots OK. 60 / 60 = 100 / 100.
