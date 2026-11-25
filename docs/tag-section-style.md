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

## Decision of the owner, later the same day: the card and the header divider are the DEFAULT look

The owner wants the rounded section card and the header divider with no setup: a tag list that sets nothing gets `sectionStyle =
insetGrouped` and `headerSeparatorStyle = line`. To remove them the app calls the API: `sectionStyle = plain` and
`headerSeparatorStyle = none` (configuration keys `"sectionStyle": "plain"`, `"headerSeparatorStyle": "none"`). The header band stays
off by default (`headerBackgroundColor` null). This replaces the "Default" column above for these two features; every other default is
unchanged.

Consequences, so nobody is surprised:

- This is a visible, breaking change of the default look on every platform (a new rounded white card behind each section's tags on a
  grouped background, a hairline under each header). Frame-based tests change with it; the gate "the default style gives the same frames
  as before" is replaced by "`plain` + `none` gives the same frames as before" (the snapshot tests of the first ports are kept and run
  with those two values).
- The default flips in a LAST step per platform, after the ports are verified with the old defaults, as one commit that: flips the
  defaults, sets `plain` / `none` in the tests and demos that must keep their old look, updates the screenshots that show a list,
  and writes the default in the integration docs (README of the repository, each package README: iOS, Android, HarmonyOS, mini program,
  React Native, Flutter) with the opt-out lines.
- A tag list inside a screen that already draws its own card (a tag bar in a toolbar, the classify menu, the multiple filter, the tab
  bar's popovers) must opt out; the library's own such screens are changed to `plain` in the same commit.

## Gates

Every platform: all existing tests pass unchanged, plus one test that the default style gives the same frames as before.
New tests: the card contains every tag frame; rows are counted at the reduced width; the header title x equals the tag leading x under
`insetGrouped`; the divider frame; right-to-left mirror; dark defaults; the configuration keys.

## Status

| Platform | State |
| --- | --- |
| HarmonyOS | Done in `harmony/classifymenu` (reference): `CYLMenuStyle` section style properties and configuration keys, `CYLTagListState.contentColumn` / `tagColumn` (one `columnAt` behind every measuring and layout pass), the card, band and divider frames on `CYLTagListSectionFrame`, drawn by `CYLTagListView`; colors in `resources/base` and `resources/dark` (`cyl_section_*`). Host tests 108/108 (96 before; 1 default-frames snapshot taken from the old code, 11 new). Seen on the HarmonyOS 6.0.1 x86_64 emulator, light and dark, in the "configuration" demo (`menu/map-configuration.json`: insetGrouped + divider). Not done: right-to-left (the state has no direction yet, rows and headers use physical left / right as before), the header band was only checked by host tests (not on the emulator). |
| Android | not started |
| Mini program | Done in `cyl-tag-list` (`CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/`): the same style keys, defaults and named constants in `model.js` (`SECTION_METRICS`, `SECTION_COLORS` light / dark carried by `defaultStyle(pixelRatio, dark)`); tags are laid out by CSS, so the geometry is two distances from the list's edges (`contentColumn`, then `tagColumn` narrowed by the card padding, `headerEdges`, `headerSeparator`; `columnAt` gives x and width), and `sectionLayout` derives the card, band and divider CSS (`cardStyle`, `headerStyle`, `headerLineStyle`, absent by default) from them. The DOM measuring of rows, fold state and content height follows the narrowed column by itself. The divider is 0.5 px (a physical pixel at 2x, one and a half at 3x). Node tests 209/209 (193 before, all passing after `node scripts/fetch-cyltabbar.js`; 1 default-layout snapshot taken from the old code, 15 new). The divider has the column's edges, the same as the card and the band (c5e54ba2). Not done: right-to-left; not seen in WeChat DevTools, only the model and CSS strings are tested. |
| iOS | not started (Mac) |
| React Native | typed keys, last |
