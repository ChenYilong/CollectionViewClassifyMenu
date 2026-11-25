# Tag list section style: card, header band and header divider

Status: contract (2026-11-25), designed by the advisor; HarmonyOS is the reference implementation, then Android, mini program, iOS
(Mac), React Native keys. Branch `feat/tag-section-style`.

## Why

A tag list that replaces a sectioned table view loses what makes a table view readable: the section header and the cells of the
section are not clearly separated. UITableView has `insetGrouped` (a rounded background around a section's cells), a header
background and separators. The tag list gets the same three things, as style properties with the same names as UITableView where
there is one. Every default reproduces today's look exactly (frames do not move by a pixel).

## API (on `CYLMenuStyle`, and as style keys of a configuration)

| Feature | Properties (key = name) | Default |
| --- | --- | --- |
| Section card | `sectionStyle`: `plain` or `insetGrouped`; `sectionBackgroundColor` (nullable); `sectionCornerRadius`; `sectionContentInsets` (padding inside the card) | `plain`. Color null resolves to the system card color (white; #1C1C1E in dark mode). Radius = named constant 10. Padding = named constant 12 |
| Header band | `headerBackgroundColor` (nullable); `headerCornerRadius`; `headerContentInsets` (leading / trailing) | null = no band (today's look). The named band color is #EFEFF4 (the TagCollectionView header) with a dark variant |
| Header divider | `headerSeparatorStyle`: `none` or `line`; `headerSeparatorColor` (nullable); `headerSeparatorThickness`; `headerSeparatorInsets` (leading / trailing) | `none`. Color null resolves to the system separator (light and dark). Thickness = named hairline constant 0.5 (a point / vp / dp; the placeholder example's divider). Both insets default to 0: the divider has the same left and right edges as the card and the header band (the column's edges), never the title's x |

Under `insetGrouped`, if the app never set the list's `backgroundColor`, it resolves to the grouped background (#F2F2F7; black in dark
mode). Nullable colors follow the dark-mode defaults pattern of `CYLMenuColor` / `CYLSystemColors` / `theme.js`.

## Geometry (one function per platform, used by every layout and measuring pass)

- `contentColumn(section)` = the list width minus `sectionInsets`, with leading / trailing so right-to-left mirrors.
- `plain`: tags, header band and divider span the column. Header title x is unchanged (`headerHorizontalInset`) unless a band is shown:
  then band leading + `headerContentInsets.leading`.
- `insetGrouped`: the card spans the column; the tags sit inside it, inset by `sectionContentInsets`; the header title and the fold
  control align with the tags' leading / trailing edge inside the card.
- The divider is drawn at the header's bottom edge (full column width by default), inside `headerHeight`: it adds no height. Heights, fold logic and `canFoldSection`
  never see it.
- The card padding narrows the width tags wrap in and adds top / bottom to the section's height: `widths`, `rowsFor`,
  `canFoldSection`, the content height and the layout all take the width from `contentColumn`.

## Not in this change

- No per-row separators between tags (tags flow in rows; the card and the header divider are the boundaries).
- An opaque card hides what is behind the list: with Liquid Glass tags choose a translucent `sectionBackgroundColor` or leave the
  style `plain`. With `insetGrouped` the header sits above the card, so a header divider is mostly redundant: the two are
  independent; an example uses one or the other.

## Decision of the owner (2026-11-25): keep every option, the integrator chooses

All three features stay independent switches, and any combination is allowed; the library picks none for the app:

- `sectionStyle` (plain / insetGrouped), the header band and the header divider combine freely. A divider under an `insetGrouped` header
  is allowed (it is only mostly redundant); an example or an app uses the one it prefers, or both.
- An opaque card over a background the Liquid Glass tags need hides the glass: choose a translucent `sectionBackgroundColor`, keep the
  style `plain`, or accept the look. The core never changes a color on its own because of the tag background style.

## Decision of the owner, later the same day (revised): the rounded card is the DEFAULT look; the divider is opt-in

The owner wants the rounded section card with no setup: a tag list that sets nothing gets `sectionStyle = insetGrouped`. To remove it the
app calls the API: `sectionStyle = plain` (configuration `"sectionStyle": "plain"`). The header divider is **not** a default: it
shows only when the app calls the API (`headerSeparatorStyle = line`, configuration `"headerSeparatorStyle": "line"`); the default stays
`none`. (An earlier version of this decision made the divider a default too; it was withdrawn.) The header band stays off by default
(`headerBackgroundColor` null). This replaces the "Default" column above for the card only; every other default is unchanged.

Consequences, so nobody is surprised:

- This is a visible, breaking change of the default look on every platform (a new rounded white card behind each section's tags on a
  grouped background). Frame-based tests change with it; the gate "the default style gives the same frames as before" is replaced by
  "`sectionStyle = plain` gives the same frames as before" (the snapshot tests of the first ports are kept and run with that value).
- The default flips in a LAST step per platform, after the ports are verified with the old default, as one commit that: flips the
  card default, sets `plain` in the tests and demos that must keep their old look, updates the screenshots that show a list, and writes
  the default in the integration docs (README of the repository, each package README: iOS, Android, HarmonyOS, mini program,
  React Native, Flutter) with the opt-out line and the opt-in line for the divider.
- A tag list inside a screen that already draws its own card (a tag bar in a toolbar, the classify menu, the multiple filter, the tab
  bar's popovers) must opt out; the library's own such screens are changed to `plain` in the same commit.

## The card's background style, and light / dark mode for every new view (owner, 2026-11-25)

- New property `sectionBackgroundStyle` (the same type as the tags' `backgroundStyle`: `flat` or `liquidGlass`; configuration key of the same
  name, values `"flat"` / `"liquidGlass"`). Default `flat`: the card is the solid `sectionBackgroundColor` (or the system card color). With
  `liquidGlass` the card is the core's Liquid Glass material (the same drawing as the glass tags, with the card's rounded corners),
  tinted with `sectionBackgroundColor` when it is set; where the platform cannot draw glass the core falls back to the flat card
  (never fake glass in the app). The header band stays flat. The two background styles are independent of the tags': flat tags in a
  glass card and glass tags in a flat card are both allowed.
- **Light and dark mode is part of every new view, in the core, with no app code:** the card (flat color and the glass tint, light and
  dark values), the header band, the header divider, the grouped list background under `insetGrouped`. A color the app sets wins in
  both modes; an unset color follows the mode, and changes when the mode changes while the list is shown (no reload by the app).
  Tests per platform: each unset color resolves to its light value in light mode and its dark value in dark mode, switching the mode
  updates a shown list, and a set color is kept in both modes.

## Built-in views have a default tint that is legible on what is behind them (owner, bug `mp-home-dark.png`, 2026-11-25)

The bug: in dark mode the list's own texts and icons (section header title, the More / Less control, the section icon) were drawn in the
dark-mode tint (white) directly on the host page; a host page that does not follow dark mode stays light, so the texts could not be read.
The list cannot see the host's background, so the library must make its built-in views legible by itself:

- New style property `tintColor` (nullable; configuration key `tintColor`): the one color of every built-in view that is not a tag:
  header title, section icon, fold / More control (text, icon, arrow). An app that sets it wins in both modes.
- The default tint (`tintColor` unset) is resolved against the background the built-in views are really drawn on, in this order:
  1. the opaque background the list paints itself: `backgroundColor` when the app set it, else the grouped background under
     `insetGrouped` (the default look): choose black or white by the background's luminance (the contrast rule, one named threshold);
  2. otherwise (a transparent list over the host page) the system mode: black in light, white in dark (what it did before).
  The header band, when shown, is part of the background the title is drawn on: the tint is resolved against the band color there.
- Because the card is the default look (see above) the default list background is the grouped background (#F2F2F7 / black), painted by
  the list, so the built-in views are legible with no setup. A transparent list (`plain` with a clear `backgroundColor`) over a host
  page that ignores dark mode is the host's choice: the app sets `tintColor` or its list `backgroundColor`.
- Tests per platform: tint on a light list background is dark and on a dark one light, whatever the system mode; unset + transparent
  follows the mode; a set `tintColor` wins; the band color is used when a band is shown; switching the mode re-resolves a shown list.

## The default list background follows light / dark mode (bug reported by the CYLTabBarController examples, 2026-11-25)

- The list's `backgroundColor` default was a fixed white on HarmonyOS, Android and the mini program: in dark mode headers and the
  More control ended up white on white. The default (`backgroundColor` never set) is now mode-aware: the system background (white in
  light mode, black in dark mode; iOS `systemBackground`); under `insetGrouped` it stays the grouped background (#F2F2F7 / black),
  as before. An app that sets `backgroundColor` (including a clear color) wins in both modes. The tint rule (resolve against the
  painted background) then gives black on white and white on black without any app code. No example needs a stopgap background.
- HarmonyOS: the fold / More chevron icon is tinted with the resolved tint like the text (its default did not follow dark mode when the
  list background was clear: dark on dark). Android's chevron was already fine.
- Tests per platform: the default (unset) background is the light value in light mode and the dark value in dark mode; a set color
  (clear or any) is kept in both; the tint on the default background is dark in light and light in dark; the chevron (Harmony) uses
  the tint.

## Gates

Every platform: all existing tests pass unchanged, plus one test that the default style gives the same frames as before.
New tests: the card contains every tag frame; rows are counted at the reduced width; the header title x equals the tag leading x under
`insetGrouped`; the divider frame; right-to-left mirror; dark defaults; the configuration keys.

## Status

| Platform | State |
| --- | --- |
| HarmonyOS | Done in `harmony/classifymenu` (reference): `CYLMenuStyle` section style properties and configuration keys, `CYLTagListState.contentColumn` / `tagColumn` (one `columnAt` behind every measuring and layout pass), the card, band and divider frames on `CYLTagListSectionFrame`, drawn by `CYLTagListView`; colors in `resources/base` and `resources/dark` (`cyl_section_*`). Host tests 108/108 (96 before; 1 default-frames snapshot taken from the old code, 11 new). Then `sectionBackgroundStyle` (`flat` default / `liquidGlass`, configuration key of the same name through the parser of `backgroundStyle`, kept by `copy()`): the card is drawn with `cylanimateditem`'s `CYLAnimatedItemBackgroundModifier` (the glass tags' drawing) with the card's corners and the tint `sectionBackgroundColor` else the resource `cyl_section_glass_tint` (translucent white; translucent #1C1C1E in dark); flat when `CYLLiquidGlass.isActive()` is false, frames identical in all cases. Light / dark audit: card, header band, divider, grouped background and glass tint are all `ResourceColor` resources (`resources/base` and `resources/dark`, `CYLSectionStyleColors`), none is a string; a color the app sets wins. Host tests 113/113 (5 new for the glass card and the color audit). Not verified: the glass card on the emulator, and the dark values at run time (host tests check that unset colors are the named resources and that set colors win; the light / dark values themselves are in the resource files). Seen on the HarmonyOS 6.0.1 x86_64 emulator, light and dark, in the "configuration" demo (`menu/map-configuration.json`: insetGrouped + divider). Then the default tint: `CYLMenuStyle.tintColor` (nullable, configuration key `tintColor`, kept by `copy()`) is the color of the header title, the section icon and the fold / More controls; unset it resolves (`resolvedTintColor(onBand)`) to black or white by the WCAG luminance of the background behind it (one constant, `CYLTintLuminanceThreshold` 0.179, in `CYLMenuColorLuminance` of `CYLMenuColor.ets`): the band color under a header band, else `resolvedBackgroundColor()` (the app's `backgroundColor`, the grouped background under `insetGrouped`, white for an untouched plain list as it is painted); a transparent background or a resource gives the system mode (`sys.color.font_primary`) as before. Limit: a `$r` resource cannot be read as a number in a host test or the style, so the library's own palette (grouped background, band) and any app resource use the mode-following system tint, which is right for the palette because it flips with the mode; only string / number colors are measured. `headerTextColor`, `foldControlColor` and `moreButtonColor` keep their getters and, once set, win over the tint (`resolvedHeaderTextColor` / `resolvedFoldControlColor` / `resolvedMoreButtonColor`); a control's own `color` still wins. The section icon is now drawn with `fillColor(tint)` (recolors SVG and symbol icons, not bitmaps). Host tests 118/118 (5 new). Not verified: on the emulator, light and dark. Not done: right-to-left (the state has no direction yet, rows and headers use physical left / right as before), the header band was only checked by host tests (not on the emulator). Then the default flip (branch `feat/tag-section-flip-har`, written statically, NOT yet built or run): `CYLMenuStyle.sectionStyle` now defaults to `insetGrouped` (the divider stays `none`, the band stays off, `sectionBackgroundStyle` stays `flat`); the opt-out is `sectionStyle = CYLSectionStyle.plain` / configuration `"sectionStyle": "plain"`. Opted out to keep their old look: the core factories `CYLMenuStyle.compactTagStyle()` (so `classifyMenuTag` and `filterTag`), `sectionTitle`, `tagCloud`, `wordPicker`, `tagContainer`, `gridStyle`; the demo styles `demoStyle` (style page), `reviewFilterStyle`, `maimaiStyle`, `recentStyle`, `CYLHotSearchPage.hotStyle`; `discoverStyle` (through `gridStyle`); `TagCloudDemo` (code list and its map configuration string); the rawfiles `menu/animated-tags.json` and `menu/animation-demo.json` (top-level `style`). Stay on the new default: `menu/map-configuration.json` (explicit `insetGrouped`), the pages with no style of their own (none left in the example). Host tests: `TagSectionStyle.test.ets` builds its lists with `plainStyle()` so `DEFAULT_FRAMES` stays valid (test renamed `thePlainOptOutGivesTheFramesOfBeforeTheSectionStyle`), plus new tests for the new default (card frames, divider / band off, grouped background rule, configuration key `plain`); `TagListTailFold.test.ets` sets `plain` (its row counts assume a 320 vp flat column). Other host tests and `ohosTest` (no geometry or color assertions) are unchanged. |
| Android | Done in `android/merged/library` (branch `feat/tag-section-style-and`): `CYLMenuStyle` section style properties, `CYLSectionStyleMetrics` / `CYLSectionStyleColors`, configuration keys (`CYLMenuStyleSection...`, `CYLMenuStyleHeader...`), `CYLTagListView.columnAt` / `contentColumn` / `tagColumn` behind every measuring and layout pass, section frames (`sectionFrame`) drawn by the content view; the divider spans the column; `sectionBackgroundStyle` glass card = `CYLAnimatedItemView` glass, flat where inactive; colors resolve per mode and again on a configuration change. Library tests 153 (129 before, 1 known failure unchanged: `animationSourceTextSplitsOptionsAsTheEngineDoes`). Then the default tint: `CYLMenuStyle.tintColor` (nullable Int, configuration key `tintColor`, kept by `copy()`) colors the header title, the section icon (`imageTintList`, so it recolors every icon drawable, bitmaps included) and the fold / More / clear controls; unset it resolves (`resolvedTintColor(context, onBand)`) to black or white by the WCAG luminance of the background behind it (one constant, `CYLTintLuminanceThreshold` 0.179, `CYLMenuColorLuminance` in `CYLMenuColor.kt`): the band color under a header band, else `resolvedBackgroundColor` (the list background the app set, the grouped background under `insetGrouped`, else the white the list paints by default); a transparent or translucent background gives the system mode (`CYLSystemColors.primary`) as before. `headerTextColor`, `foldControlColor`, `moreButtonColor` and `clearButtonColor` set by the app win over the tint; a set `tintColor` wins in both modes; `onConfigurationChanged` rebuilds the headers so a shown list re-resolves. Library tests 163 (10 new), 1 known failure unchanged. `CYLDarkModeDefaultsTest.inDarkModeTheOneTintIsLight...` now sets a transparent list background, because on the default white list the tint is black in dark mode too (the bug fixed). Not done: right-to-left for headers and the band (physical left / right as before), no device or emulator look, the glass card and the tint were only checked structurally. **Default flipped (branch `feat/tag-section-flip-and`, written statically, not yet run):** `CYLMenuStyle.sectionStyle` defaults to `insetGrouped` (divider none, band off, `sectionBackgroundStyle` flat; opt-out `sectionStyle = CYLSectionStyle.CYLSectionStylePlain` or configuration `"sectionStyle": "plain"`). Opt-outs written: (library) the complete-look factories `tagCloudStyle`, `tagContainerStyle`, `wordPicker`, `gridStyleWithNumberOfItemsPerRow`, `sectionTitle`, `classifyMenuTag`, `filterTag` (through the private `plainBaseStyle()`) and `CYLTagListView.defaultTitleStyle()`, so the classify menu and the multiple filter (they use those factories) stay flat; (library tests, through `CYLTagListView.usePlainSections()` / `CYLMenuStyle.plainSectionStyle()` in `CYLPlainSectionTestSupport.kt`) `CYLTagListDefaultFramesTest` (its snapshot is the `plain` look), `CYLTagListTailFoldTest`, `CYLTagEditingDragTest`, `CYLTagReorderWidthTest`, `CYLTagListEditingTest`, `CYLTagListRenamingTest`, `CYLTagLongPressActionTest` (their list builders), and `CYLTagSectionStyleTest` (every former default `CYLMenuStyle()` is now `plain()`; the tint tests keep their white background); (example) `reviewFilterStyle`, `recentStyle` (discover grid is plain through its factory), `maimaiStyle`, `demoStyle` of the tag style screen, the tag editor's `tagStyle`, the code list and the two configuration maps of the tag cloud screen, the animated tag screen's configuration, and the two lists loaded from shared configuration files (`animated-tags.json` of the tag cloud screen, `fold-styles.*` of the tag editor), through `plainSections()` in `example/.../ExampleSectionStyle.kt`; those two shared files are owned by the other platforms and were not edited, so the example opts out in code. New tests (`CYLTagSectionStyleTest`, `CYLTagListDefaultFramesTest`): the default is `insetGrouped` with a card frame and the padded column, `plain` equals the old snapshot, the divider and band stay off, a default list gets the grouped background and a tint that follows it in light and dark, the key `"plain"` parses (an empty configuration is the card), and every complete-look factory is plain. No gradle run on this branch: the owner runs the tests. |
| Mini program | Done in `cyl-tag-list` (`CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/`): the same style keys, defaults and named constants in `model.js` (`SECTION_METRICS`, `SECTION_COLORS` light / dark carried by `defaultStyle(pixelRatio, dark)`); tags are laid out by CSS, so the geometry is two distances from the list's edges (`contentColumn`, then `tagColumn` narrowed by the card padding, `headerEdges`, `headerSeparator`; `columnAt` gives x and width), and `sectionLayout` derives the card, band and divider CSS (`cardStyle`, `headerStyle`, `headerLineStyle`, absent by default) from them. The DOM measuring of rows, fold state and content height follows the narrowed column by itself. The divider is 0.5 px (a physical pixel at 2x, one and a half at 3x). Then `sectionBackgroundStyle` (`flat` default / `liquidGlass`, parsed like `backgroundStyle`, inherited by section style dictionaries): the card uses the glass of the glass tags (`cylAnimatedItemBackground`: blur 16 px, saturate 180 %, tint, top highlight, clipped to the card's corners) with the tint `sectionBackgroundColor` else `SECTION_COLORS.*.glassTint` (translucent white 0.5; translucent #1C1C1E 0.5 in dark); flat where `cylAnimatedItemLiquidGlassIsActive()` is false (the tags' rule); padding, tag column and every other CSS field are identical flat vs glass. Light / dark audit: card, glass tint (and the highlight strength), band, divider and grouped background are all resolved from `sectionPalette`, which `defaultStyle(pixelRatio, dark)` builds from the `dark` option; `cyl-tag-list.js` already rebuilds the model with `theme.isDark()` on `wx.onThemeChange`, so unset colors follow the system theme while shown; a color the app sets wins in both modes. Then `tintColor` (nullable style key; fixes `mp-home-dark.png`): `resolveTint(style, against)` gives the tint of the header title and the fold / More text, icon and arrow: `tintColor` when set, else black or white by the relative luminance of the opaque background behind them (one named threshold `TINT_LUMINANCE_THRESHOLD` = 0.179, where black and white have the same contrast): the header band's color for the title (and a fold control in the header) when a band shows, else the list's painted background (the app's `backgroundColor`, or the grouped background under insetGrouped), else the system mode (black light / white dark, as before, so the old defaults and the snapshot are unchanged). `headerTextColor` / `foldControlColor` / the fold control's own `color` that the app sets still win over the tint (`headerTextColorSet` / `foldControlColorSet`); `resolvedHeaderTextColor` and `resolvedFoldControlColor` feed `sectionLayout` and the component, which already rebuilds on a theme change. This list has no section icon. A fold control inside an insetGrouped card or below it is resolved against the list background, not the card color. Node tests 224/224 (193 before, all passing after `node scripts/fetch-cyltabbar.js`; 1 default-layout snapshot taken from the old code, 30 new). Not verified in WeChat DevTools: the contrast on the real home page. The divider has the column's edges, the same as the card and the band (c5e54ba2). Not done: right-to-left; not seen in WeChat DevTools, only the model and CSS strings are tested. **Default flipped (branch `feat/tag-section-flip-mp`):** `defaultStyle` sets `sectionStyle` = `DEFAULT_SECTION_STYLE` (`insetGrouped`: a list that sets nothing has the rounded card, the grouped list background, the divider `none`, the band off, `sectionBackgroundStyle` `flat`, and the default tint resolved against the grouped background); the opt-out is the style key `sectionStyle: 'plain'` (an unknown name keeps the default; a section's style dictionary can still override the list's). `plain` gives exactly the old strings (the fixture `test/fixtures/tag-section-default-layout.json` is kept and the snapshot test now sets `plain`). Opt-outs written (every other list keeps the new default): the review filter style `reviewFilterStyle` in `miniprogram/pages/reviews/list.js` (review page, and the product page preview, which builds on it), `maimaiStyle` in `miniprogram/pages/search-category/search-category-model.js` (the page draws the headers), `demoStyle` in `miniprogram/pages/styles/demo.js` (preview of flat glass tags); tests: the snapshot test (`tag-section-default-layout.test.js`) and the plain-look tests of `tag-section-style.test.js` (rows, heights, band, divider, fold, background, tint, through `plainOf`). Left on the new default on purpose: the animations screen and the configuration screen (sectioned showcases; the configuration file is byte for byte the iOS file), the cyl-tag-button (it never uses the section layout) and cyl-tag-cloud (own model, own default style, untouched). New tests: the default has `cardStyle` and narrows the column by the card padding, the divider default is `none`, `plain` has only the four old CSS fields, the default list background and tint resolve against the grouped background. Not run here (the owner runs all tests once). |
| iOS | not started (Mac) |
| React Native | Typed keys done in `react-native/react-native-cyl-tag-list/src/CylTagListConfiguration.ts` (`CylSectionStyle`, `CylSectionBackgroundStyle`, `CylHeaderSeparatorStyle`, `CylSectionStyleKeys`, exported from `index.tsx`; Jest tests written, not yet run). Integration docs (README of the repository and of each package) state the default (card on, divider off) and the opt-outs. |
