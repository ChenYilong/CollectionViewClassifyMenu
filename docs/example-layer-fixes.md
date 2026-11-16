# Example-layer fixes

Rule (AGENTS.md "Fix issues in the core first"): an issue is fixed in the core, the code published to a package registry
(CocoaPods / Swift package, Maven / Gradle, npm, pub.dev, ohpm, the mini program packages). A fix in the example layer is
the worst option. Every example-layer fix is listed here with the reason it is not in the core; a core defect is fixed in
the example only after the user agreed.

Columns: issue (row of its progress table), commit, files, why not in the core.

## Example-only defects (the defect is in example code or data)

| Issue | Commit | Files | Why not in the core |
| --- | --- | --- | --- |
| C5: menu-linkage result rows repeat the dish and region | `a2f8561` | `harmony/entry/.../CYLMenuLinkagePage.ets` | The result rows are the example's own SQLite demo data and text; the core has no result list. |
| P1: root tab titles touch each other | `a2f8561` | `harmony/entry/.../pages/Index.ets` | The root tab bar is the example app's own `Tabs`, not a core component. |
| E1 / E3 / E6: screenshots open the wrong tab, catch the launcher, or are taken before the tags draw | `a2f8561`, `a065745` | `harmony/entry/.../pages/Index.ets`, `EntryAbility.ets`, `harmony/scripts/screenshots.sh` | Launch options and the screenshot script are example tooling; the core is not involved. |
| E4 / E5 / E8: Chinese section titles, tag titles, segment and keyword chips in English | `89261f4`, `a065745`, `d59bd20` | `harmony/entry/.../CYLTagAnimationPage.ets`, `CYLReviewStore.ets`, `CYLReviewListPage.ets`, `data/CYLExampleStrings.ets` | The texts are example data (demo configuration and reviews); the core localizes its own strings and shows what the app gives it. |
| Y3: the menu-linkage filter button is nearly invisible | `a791539`, `32cbe81` | `harmony/entry/.../CYLMenuLinkagePage.ets` | The button is drawn by the example page (iOS: the example's bar button), only its images come from the core. |
| E2 / Z3 / Z4 / Z6: the root page, tab bar and animation page stay light in dark mode | `30f18b4`, `3417e7e`, `9c8048a`, `8529951` | `harmony/entry/.../CYLProductPage.ets`, `pages/Index.ets`, `CYLTagAnimationPage.ets`, `DemoNav.ets`, `resources/*/element/color.json` | The page backgrounds, bars and labels are example views with fixed light colors. |

## Core defects fixed in the example (core follow-up needed)

These were fixed in the example before the rule; each has a core cause. Status: TODO, to be moved into the core (ask
the user first if the core cannot take it).

| Issue | Commit | Files | Core cause | Why the example fix was used |
| --- | --- | --- | --- | --- |
| Y2: the selected chip's icon is orange on orange | `32cbe81` | `harmony/entry/.../CYLReviewStore.ets`, `CYLReviewListPage.ets`, `resources/base/media/a_*_selected.png` | The core's icon tint (`fillColor`) only recolors SVG / symbol images, not bitmaps, so `setIconColor(_, SELECTED)` does nothing for PNG icons (iOS tints template images). | The core tint was tried first (`bf7ed6a`) and did not work for PNGs; white copies were the quick fix. Core fix: tint bitmaps too (`colorFilter`, alpha-preserving), as iOS template rendering. |
| E7: the review chips stay light gray in dark mode | `2b5a9bc` | `harmony/entry/.../CYLProductPage.ets` | `CYLMenuStyle` takes fixed color strings, so tag colors cannot follow the color mode (iOS: dynamic `UIColor`). | The example picks dark colors when the page appears. Core fix: accept color-mode-aware colors (resources, or a light / dark pair). |
| Z2: scrolled tags draw over the page title | `3417e7e`, `32cbe81` | `harmony/entry/.../CYLTagAnimationPage.ets` (clip, zIndex) | `CYLTagListView` is meant to clip its content; `.clip(true)` on its `Scroll` (`3417e7e`) did not stop the overdraw, the page-level clip did. | The cause inside the core is not found yet. Core fix: find why the list's own clip does not apply and fix it there, then remove the page workaround. |
