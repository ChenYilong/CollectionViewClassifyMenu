# miniprogram: examples (part 2 of 2)

## CrossPlatform/wechat-miniprogram/miniprogram/pages/styles/demo.js

- `const model = require('cyl-tag-list-miniprogram/cyl-tag-list/model.js');` (L7)
  The state of the Styles tab without `wx` calls (node tests): CYLTagStyleDemoViewController's actions, their values
  and the preview's configuration. The style is kept as the core's style dictionary (CYLMenuStyleKey /
  CYLTagAppearanceKey keys), applied to the preview as `tagListView.style = style` is on iOS; the values the table
  shows are read from the effective style (model.mergeStyle), as iOS reads them from the CYLMenuStyle.

- `const ACTION_IDENTIFIERS = [` (L10)
  Identifiers of the actions, in table order.

- `const ACTION_TITLES =` (L31)
  The localization keys of the action titles.

- `const PAGES =` (L70)
  The rows that open another screen (pushed with wx.navigateTo).

- `const PALETTE = ['#FF9500', '#AF52DE', '#30B0C7', '#FF2D55', '#5856D6', '#34C759'];` (L80)
  A fixed palette, so that screenshots are stable: systemOrange, systemPurple, systemTeal, systemPink, systemIndigo, systemGreen.

- `function lightColorAtStep(step)` (L87)
  The palette color with an alpha of 0.15 ("#RRGGBBAA").

- `function whiteAtStep(step)` (L92)
  UIColor(white: 1 - 0.15 * (step % 3)).

- `function demoStyle()` (L100)
  CYLTagStyleDemoViewController.demoStyle().

- `const SAMPLES = [` (L116)
  Title key, icon and selected icon of the preview's tags (reloadItems).

- `const ANIMATION_FILES =` (L126)
  The demo's animated icons, from CYLTabBarController's examples (Lottie, GIF, Rive, SVGA) and libpag/pag-ios (PAG).

- `function effectiveStyle(state, options)` (L152)
  The effective style (CYLMenuStyle) of the demo's style dictionary.

- `function performAction(state, identifier)` (L160)
  Performs an action as a tap on its row does. Returns {navigate} for the rows that open another screen, {play: true}
  after an animation library is chosen (the selected tags play their icons), or {}.

- `function valueForAction(state, identifier, options)` (L263)
  The value a row shows next to its title.

- `function animationForIndex(state, index)` (L291)
  The animation file of the tag at `index` for the current library, with its Rive options (animationURL(forIndex:)).

- `function configuration(state, t = (s) => s)` (L305)
  The preview's configuration (reloadItems + applyStyle): one section without a header, multiple selection.

- `function table(state, t = (s) => s, options)` (L328)
  The table: sections with their header and rows (identifier, title, value).

## CrossPlatform/wechat-miniprogram/miniprogram/pages/styles/styles.js

- `const { t } = require('../../utils/i18n.js');` (L7)
  样式 (tab): CYLTagStyleDemoViewController, 1:1. At the top the tag preview (CYLTagListView, multiple selection, no
  section header, not scrolling), a hairline, then an inset grouped table in which every row changes one style
  parameter (or opens another screen) and shows its current value; a tap applies it at once. The actions and their
  values are in demo.js.

- `apply(callback)` (L34)
  reloadItems + applyStyle: the preview and the table's values.

## CrossPlatform/wechat-miniprogram/miniprogram/pages/styles/styles.wxss

The preview on top (white), a hairline (UIColor.separator), then the inset grouped table filling the rest.

## CrossPlatform/wechat-miniprogram/miniprogram/pages/tag-cloud/data.js

- `const { t } = require('../../utils/i18n.js');` (L5)
  The data of the tag cloud demo (CYLTagCloudDemoViewController): the upper list created the android-tagview way
  (the continents, a detailed tag, the styled tags) and the configuration of the lower list. No `wx` calls.

- `const CONTINENTS = ['Asia', 'Africa', 'North America', 'South America', 'Antarctica', 'Europe', 'Australia'];` (L9)
  The continents of android-tagview's sample.

- `function detailedTag()` (L12)
  android-tagview's "add a tag in details": every look property of its Tag.

- `const BACKGROUND_IMAGE = 'linear-gradient(to right, ${model.NAMED_COLORS.systemPurple}, ${model.NAMED_COLORS.systemTeal})';` (L27)
  A horizontal gradient, as android-tagview's custom background drawable (systemPurple to systemTeal).

- `function styledTags()` (L30)
  Tags that show the rest of android-tagview's Tag: deletable, a larger text, a background image, a delete icon.

- `function codeList()` (L59)
  The upper list: `CYLTagListView()` with lineSpacing 5, interitemSpacing 3, tagContentInsets {3, 10, 3, 10}.

- `function mapConfiguration()` (L70)
  The configuration of the lower list: the same kinds of tags, as strings and dictionaries.

- `const SYMBOLS = { 'system:globe': '/images/samples/globe.png' };` (L85)
  SF Symbols of the configuration as the example's images.

- `function mapList()` (L88)
  The lower list built from its configuration (`CYLTagListView(configuration:)`).

## CrossPlatform/wechat-miniprogram/miniprogram/pages/tag-cloud/tag-cloud.js

- `const { t } = require('../../utils/i18n.js');` (L6)
  标签云（android-tagview）, 1:1 with the iOS example's `CYLTagCloudDemoViewController`: a list created the
  android-tagview way (init, spacing, then addTags(withTitles:) / addTag(_:)), the same kinds of tags from a
  configuration dictionary, and a caption that reports taps and deletions. Pushed from the Styles tab.

- `onCodeTap(event)` (L36)
  tagClickHandler of the upper list (the lower list has none).

- `onDelete(event)` (L42)
  tagDeleteHandler of both lists.

## CrossPlatform/wechat-miniprogram/miniprogram/pages/tag-cloud/tag-cloud.wxss

systemGroupedBackground; a vertical stack 12 pt below the top, 8 pt apart: footnote captions in the secondary
label color inset by 16 pt, the lists full width.

## CrossPlatform/wechat-miniprogram/miniprogram/styles/android-sample.wxss

What the Android sample ports share (CYLAndroidSampleSupport.swift): the filled buttons (UIButton.Configuration
.filled(), corner style small, body text that wraps, white title) and the text fields with a systemTeal bottom
line (Android's EditText), 44 pt high.

## CrossPlatform/wechat-miniprogram/miniprogram/utils/android-sample.js

- `const { t } = require('./i18n.js');` (L7)
  What the three Android sample ports share (CYLAndroidSampleSupport.swift): the toast's duration, the buttons'
  colors and the pictures of the TagViewGroup sample (images/samples/picture-<n>.jpg, drawn by
  scripts/draw-sample-images.py as `CYLAndroidSample.picture(_:)` draws them: a diagonal gradient and a large
  white symbol — shoes, a bag, a shirt). No `wx` calls.

- `const TOAST_DURATION = 2000;` (L10)
  Android's Toast.LENGTH_SHORT, as `CYLAndroidSample.toast`.

- `const TOAST_FADE = 250;` (L12)
  The toast's fade-out.

- `const COLORS = { systemPink: '#FF2D55', systemOrange: '#FF9500', systemGray: '#8E8E93', blue: '#00BFFF' };` (L15)
  The UIKit colors of the samples' buttons.

- `const PICTURES = [` (L18)
  The pictures: their file and the label VoiceOver reads (the image's accessibilityLabel).

- `function picture(index)` (L25)
  `CYLAndroidSample.picture(_:)`: `index` chooses the colors and the symbol.

## CrossPlatform/wechat-miniprogram/miniprogram/utils/i18n.js

- `const TABLES = require('../data/strings.js');` (L7)
  The example's strings: the iOS example's CYLMenuExample.bundle (data/strings.js, exported by
  scripts/export-miniprogram-data.py), keyed by the Chinese source text, as `CYLExampleLocalizedString` reads them.
  The language is the one set with setLanguage() (e.g. from a launch query `lang=en`, like iOS's
  `-CYLExampleLanguage en`), else WeChat's language; a key missing from a language is its Chinese source text.

- `function t(key, ...args)` (L14)
  The string for `key` (its Chinese source text) in the current language, with `args` filled in.

## CrossPlatform/wechat-miniprogram/miniprogram/utils/places-db.js

- `const ROWS = require('../data/places.js');` (L7)
  The places of the shared database (Example-Shared/Database/cyl_places.sqlite, docs/cross-platform.md), read from
  the module exported from that file (scripts/export-miniprogram-data.py), and the statement of the iOS example's
  `CYLMenuLinkageViewController.query(forTag:regions:dishes:)` run on them. A Mini Program has no SQLite, so this
  module builds the same SQL text (shown on the page) and applies the same conditions and order in JavaScript.

- `const REGIONS = ['北京 🏙️ 扩展文字', '上海', '广州', '深圳']; // NOLOCALIZE: source titles (the database matches them)` (L10)
  The filter's regions (the iOS example's `CYLDemoDataSource.regions()`).

- `function tags(rows = ROWS)` (L13)
  Every tag, in database order: `SELECT tag FROM places GROUP BY tag ORDER BY MIN(id)`.

- `function categories(rows = ROWS)` (L30)
  The categories (吃喝玩逛) in the order of their first place, each with its tags in order:
  `SELECT category, tag FROM places GROUP BY category, tag ORDER BY MIN(id)`.
  @returns {{title: string, tags: string[]}[]}

- `function statement({ tag = null, regions = [], dishes = [] } = {})` (L44)
  The statement and its arguments for a tag (every tag when null), regions and dishes (every one when empty).
  @returns {{sql: string, args: string[]}}

- `function places({ tag = null, regions = [], dishes = [] } = {}, rows = ROWS)` (L61)
  The places matching the statement, best rated first, then by id.

## CrossPlatform/wechat-miniprogram/miniprogram/utils/selections.js

- `const CLASSIFY_SCENARIO = 'menu.classify';` (L6)
  The saved selections of the classify menu and the filter: the `selections` table (scenario TEXT PRIMARY KEY, items
  TEXT) of the iOS, Android and Flutter examples, kept in the Mini Program's local storage under one key per
  scenario. The items are "<section>-<item>" keys joined by commas, as in that table.

- `function defaultStorage()` (L11)
  The storage functions of `wx`, replaceable in tests.

- `function load(scenario, storage = defaultStorage())` (L19)
  The saved items of `scenario`, or null when none were saved.

- `function savedScenarios(storage = defaultStorage(), keys = null)` (L30)
  Every scenario with a saved selection (the rows of the selections table).

## CrossPlatform/wechat-miniprogram/miniprogram/utils/tag-animations.js

- `const animations = require('cyl-tag-list-miniprogram/cyl-tag-list/animations.js');` (L19)
  The example's animation files, registered with the tag list library (cyl-tag-list-miniprogram), and the engines the
  example ships. The library draws every tag icon with CYLTabBarController's cyl-animated-item and links no engine:
  - **lottie**: CYLTabBarController's cyl-lottie (its lottie-miniprogram fork, in cyl_components);
  - **gif**: drawn by cyl-animated-item's <image> from the entry's `src` (a GIF plays on its own);
  - **rive**: CYLTabBarController's cyl-rive-miniprogram (the Rive runtime, 103 KB, and its WebAssembly, 573 KB, in
    cyl_components), playing the .riv.bin files of data/animations/rive with the tags' animationOptions;
  - **pag**: CYLTabBarController's cyl-pag-miniprogram (libpag 4.5.85, about 0.96 MB) and the fetched PAG files, in the
    "engines" subpackage (the main package's 2 MB would not hold it next to Rive), loaded asynchronously by the icon
    component (componentPlaceholder) and preloaded for the 动效 and 样式 tabs (app.json preloadRule);
  - **svga**: CYLTabBarController's cyl-svga-miniprogram (an SVGA 2.x player for the 2D canvas, about 75 KB) and the
    .svga.bin files of engines/svga, in the same subpackage.
  components/cyl-tag-animation-view plays Lottie, Rive, PAG and SVGA; the pages hand it to cyl-tag-list as the abstract
  nodes generic:cyl-lottie-view, generic:cyl-rive-view, generic:cyl-pag-view and generic:cyl-svga-view. Required by app.js, so the files are
  registered before any page shows a tag.

- `const ENGINES = Object.freeze({ lottie: true, gif: true, pag: true, rive: true, svga: true });` (L26)
  The engines the example ships (components/cyl-tag-animation-view, and <image> for GIF).

- `isAnimationEngineAvailable: Object.keys(ENGINES).some((name) => ENGINES[name]),` (L35)
  `CYLTagButton.isAnimationEngineAvailable` for the example: true, it ships engines.
