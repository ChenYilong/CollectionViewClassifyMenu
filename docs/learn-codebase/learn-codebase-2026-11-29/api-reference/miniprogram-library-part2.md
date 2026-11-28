# miniprogram: library (part 2 of 2)

## CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js

- `const symbols = require('./symbols.js');` (L10)
  The model of the Mini Program `cyl-tag-list` component: the configuration dictionary of the core's
  `CYLTagListView(configuration:)` (the keys of CYLTagListView+CYLConfiguration.swift, read by the same rules: strings
  work for every value), the selection rules of `CYLTagListView.handleTap(at:)` / `applySelection(of:)`, the folding of
  `defaultVisibleRows` and the layout of one tag (`CYLTagButton.layoutSubviews`, `width(forTitle:…)`) turned into CSS.
  It has no `wx` calls, so it runs under Node in the tests.
  An item is addressed by its key "<section>-<item>", the format of `selectedItems` on every platform.

- `const NAMED_COLORS =` (L22)
  UIColor names a configuration may use ("systemBlue" or "systemBlueColor"), with their light-mode values.

- `function color(value)` (L32)
  A CSS color from "#RGB", "#RRGGBB", "#RRGGBBAA" (as `UIColor.cylMenuColor(from:)`), rgb()/rgba() or a UIColor name; null otherwise.

- `function numberValue(value)` (L49)
  A number from a number or a string ("true"/"yes"/"on" are 1, as `CYLConfigurationValue.number`); null otherwise.

- `function numbers(value, count)` (L67)
  `count` numbers from an array or a string such as "{1, 2}" or "[1, 2]"; null otherwise.

- `function insetsValue(value)` (L78)
  "{top, left, bottom, right}", [t, l, b, r] or {top, left, bottom, right} → insets; null otherwise.

- `function sizeValue(value)` (L90)
  "{w, h}", [w, h], {width, height} or one number (a square) → {width, height}; null otherwise.

- `function offsetValue(value)` (L101)
  "{horizontal, vertical}", [h, v] or {horizontal, vertical} → an offset; null otherwise.

- `function fontValue(value)` (L118)
  A font from a number (the system font of that size) or {size, weight, italic, name} (`CYLConfigurationValue.font`).

- `function fontName(font)` (L128)
  The iOS name of a system font, as `UIFont.fontName` reports it (".SFUI-Semibold", ".SFUI-RegularItalic").

- `function imageSize(value)` (L134)
  "{18, 18}" (the core's CGSize string) or 18 → 18 (the width).

- `function insets(value, fallback)` (L140)
  "{top, left, bottom, right}" (the core's UIEdgeInsets string), [t, l, b, r] or {top, left, bottom, right}.

- `const DEFAULT_TEXT_COLOR = '#404040';` (L148)
  UIColor(white: 0.25) and the other gray levels of the core's defaults.

- `const DEFAULT_TAG_BACKGROUND = '#F2F2F7';` (L154)
  A tag's background is never transparent (nor white on the white list, which looks the same): the default fill is
  UIKit's systemGray6, and a configured clear / transparent / zero-alpha background falls back to it.

- `const TITLE_MAX_LINES = { single: 1, unlimited: Number.MAX_SAFE_INTEGER };` (L159)
  The line limits of a tag's title (style key `titleMaxLines`): named values, never a literal at a call site.
  `single` is the default (a title too wide is truncated); `unlimited` shows every line.

- `const HEADER_TITLE_MAX_LINES = { single: 1, unlimited: Number.MAX_SAFE_INTEGER };` (L165)
  The line limits of a section header's title (style key `headerMaxLines`), the same named values as a tag's title:
  `single` (the default) keeps the one-line header with an ellipsis; a larger number or `unlimited` wraps the title and
  the header's height becomes a minimum.

- `const HEADER_WRAP_VERTICAL_PADDING = 6;` (L167)
  The padding above and below a header title that may wrap (px): half of the 12 the header height adds to a line.

- `const DIRECTIONS = { ltr: 'ltr', rtl: 'rtl', auto: 'auto' };` (L174)
  The reading direction of the list (style key `direction`): `ltr` is the default, `rtl` mirrors the section views
  (CSS `direction: rtl` on the list and the leading / trailing distances of the layout). `auto` should follow the system
  language, but this component has no language-direction helper yet, so `auto` is `ltr`.

- `const FOLD_CONTROL_FONT_SIZE = 13;` (L181)
  The fold / More control's font (px): the mini program's text scales with the system font size, so the control's font is
  `min(size, FOLD_CONTROL_MAX_FONT_SIZE)`: unchanged below the cap, never larger than it. 13 is the header and footer control's size.

- `const HEADER_ITEM_SPACING = 8;` (L192)
  The header room model (docs/tag-section-style.md). INNER WIDTH is the header's content box (the tag column: the list width
  minus the header edges). Every two adjacent header views are HEADER_ITEM_SPACING px apart (the fold control's margin on its
  leading side; 8 matches the iOS 8 pt and Android 8 dp gap). The fold control is at most
  HEADER_FOLD_ALONE_MAX_FRACTION of the inner width, or HEADER_FOLD_SHARED_MAX_FRACTION when More, a clear button or an
  accessory also shows (this component's header has none of those, so the alone value applies). The section title takes what
  is left, never less than HEADER_TITLE_MIN_EM of the header font (and at least HEADER_TITLE_MIN_WIDTH_PX).

- `const SELECTED_GLASS_TINT_ALPHA = 1;` (L198)
  The tint alpha of a selected Liquid Glass tag (full colour) and the value that leaves the component's default alpha.

- `const PERCENT_PER_FRACTION = 100;` (L201)
  The percent of a fraction, for CSS (rounded so that 0.3 gives 30, not 30.000000000000004).

- `const DARK_TAG_BACKGROUND = '#1C1C1E';` (L209)
  Dark mode, as iOS's dynamic defaults: a tag's fill is the secondary system background (#1C1C1E), its title the primary
  label (white), and the list's own texts and icons (header title, fold controls) one tint, `UIColor.label` (black in
  light mode, white in dark mode). A color a configuration sets wins in both modes.

- `const SECTION_STYLES = { plain: 'plain', insetGrouped: 'insetGrouped' };` (L218)
  The section style (docs/tag-section-style.md): the names of style keys `sectionStyle` and `headerSeparatorStyle`, the named
  lengths (px) and the colors of each color mode. The default is the rounded card (`insetGrouped`), no band, no divider;
  `sectionStyle: 'plain'` reproduces the layout of before the card was the default.

- `const DEFAULT_SECTION_STYLE = SECTION_STYLES.insetGrouped;` (L220)
  The style of a list that sets nothing: the rounded section card. An app opts out with the style key `sectionStyle: 'plain'`.

- `const HEADER_BOARD_TITLE_PADDING = 8;` (L228)
  Under the board (insetGrouped) with no header divider the header is sized to its text (docs/tag-section-style.md, "The gap
  between the header and the board is short when there is no divider"): the title's line height plus this padding (px; half
  above, half below), and never less than the fold / More control, which CSS min-height gives for free.

- `const HEADER_BOARD_SPACING = 4;` (L230)
  The distance (px) from such a header's bottom to the board's top, instead of the section's top inset.

- `const SECTION_BACKGROUND_STYLES = { flat: 'flat', liquidGlass: 'liquidGlass' };` (L232)
  The card's background: the solid color, or the glass of cyl-animated-item's tags (style key `sectionBackgroundStyle`).

- `const SECTION_COLORS =` (L237)
  Card: white / #1C1C1E; header band: #EFEFF4 / #2C2C2E; grouped list background: #F2F2F7 / black; divider: the system separator;
  `listBackground`: the default list background (the system background: white in light mode, black in dark mode).

- `const TINT_LUMINANCE_THRESHOLD = 0.179;` (L253)
  The default tint of the built-in views that are not tags (header title, fold / More control: text, icon, arrow) is
  chosen against the opaque background really behind them, black or white by relative luminance (WCAG): the one
  threshold is where black and white text have the same contrast (about 0.179). Without such a background it is the
  system mode's (black in light, white in dark). Style key `tintColor` wins in both modes.

- `const OPAQUE_ALPHA = 1;` (L257)
  The alpha from which a background counts as opaque.

- `function tagBackground(value)` (L264)
  A background that may be transparent (style key `allowsTransparentBackground`): `transparent`, `clear` and zero alpha
  are kept as `transparent`; a missing or invalid color is still the default tag fill.

- `function opaqueBackground(value)` (L274)
  The color, or the default tag fill when it is missing, invalid or fully transparent.

- `function isExplicitBackground(value)` (L286)
  Whether a configured background is an explicit color of the app or a preset: a valid color that is not fully transparent.
  An unset, invalid, `transparent` or zero-alpha background falls back to the default fill, which is never explicit.

- `function namedValue(value, names)` (L320)
  The value of a name table (case-insensitive; the raw values 0 and 1 count), or null.

- `function mergeSectionStyle(style, c)` (L329)
  The section card, header band and header divider keys of `mergeStyle`.

- `function defaultStyle(pixelRatio = 2, dark = false)` (L361)
  The core's `CYLMenuStyle()`: gray bordered tags (a hairline of UIColor(white: 0.82)), green selection with white
  titles, light gray disabled tags; 14 × 14 icons, 4 between icon and title, 30 high tags, 10 between tags and lines,
  section insets {10, 16, 10, 16}, 36 high headers with a 17 pt semibold title.
  @param {number} pixelRatio the screen scale, for the hairline (1 / scale)
  @param {boolean} dark dark mode: the dark tag fill and title, the light tint of the list's texts and icons

- `function finishStyle(style)` (L435)
  The derived fields kept for the component's older readers (imageSize, fontSize, contentInsets…).

- `function applyAppearance(appearance, configuration, allowsTransparent = false)` (L457)
  `CYLTagAppearance.applyConfiguration(_:)`: missing keys keep their values; an invalid color restores the default. A
  transparent background becomes the default fill unless `allowsTransparent` (a tag on its own, such as a search bar
  item, may be transparent; a tag in a list may not).

- `function mergeStyle(configuration = {}, base = DEFAULT_STYLE)` (L501)
  `CYLMenuStyle.applyConfiguration(_:)` on a copy of `base`: the appearances first (normal, selected, disabled), then
  the style keys (imageTitleSpacing, itemHeight, itemsPerRow, interitemSpacing, lineSpacing, headerHeight,
  animationSpeed, layoutCentered, imagePlacement, contentAlignment, imageSize, animationSize, imageInsets,
  sectionInsets, titlePositionAdjustment, imagePositionAdjustment, backgroundColor, headerTextColor, foldControlColor,
  headerFont, highlightedBackgroundColor, tagContentInsets). `allowsTransparentBackground` (false by default) keeps a
  `transparent` / `clear` / zero-alpha tag background instead of the default fill, read before the appearances. `font` at the style level (an older key of this
  component) sets the font of every state.

- `function itemDictionary(item)` (L605)
  An item dictionary, or a plain value as its title ("Text only"), as `CYLTagListConfigurationSource.item(at:)`.

- `function usualFoldContent(position)` (L612)
  The content a fold control position has when none is given: the header controls show the icon and the title, the tail and the footer the icon only.

- `function normalize(configuration = {}, options = {})` (L648)
  The configuration with defaults: selectionMode ("none" | "single" | "multiple"), allowsEmptySelection (true, as in
  the core), showsSectionHeaders (true), defaultVisibleRows (0 = never fold), foldControl ({position: "none" |
  "headerTrailing" | "tail" | "footer", content: "title" | "icon" | "iconAndTitle" | "titleAndIconAlways"}), style and sections ([{title,
  style, items: [{title, image, selectedImage, animation, animationOptions, animationRestingProgress, exclusive,
  enabled, gifFirstFrame, gifLastFrame, gifDuration, autoplay}] }], a plain value being an item's title). `options.pixelRatio` sets the hairline of the default borders, `options.dark` the dark mode defaults (tag fill and title, the list's tint).

- `function longPressActions(value)` (L704)
  The long-press actions of a configuration's `longPressAction` (docs/tag-long-press-action.md): a name ("reorder",
  "callout", "report", "none") or an array of names, the first that can begin winning. The long press is still reported
  where no listed action takes it (an item without a subtitle), unless "none" is listed. null when absent or unknown:
  the default, which reports the long press (the list does not reorder; reordering is cyl-tag-cloud's).

- `function longPressDecision(actions, hasSubtitle, canReorder = false)` (L719)
  What a long press does: the first of `actions` that can begin (null: the default, "report"). "callout" needs a
  subtitle, "reorder" needs a list that reorders (`canReorder`, false here), "report" and "none" always begin.
  @returns {'callout'|'report'|'none'}

- `function sanitizeSelection(items, sections)` (L731)
  Drops keys that address no item, and duplicates; keeps the order. Keys are "s-i" strings or [s, i] pairs.

- `function tap(model, selectedItems, k)` (L757)
  The selection after tapping item `k` (`CYLTagListView.handleTap(at:)`): selecting an item removes, in its section,
  every other item in single mode, every other item when it is exclusive, and the exclusive items otherwise; tapping
  a selected item deselects it when empty selection is allowed or its section keeps another selected item.
  @returns {{selectedItems: string[], selected: boolean, changed: boolean}}

- `function rowsFromTops(tops)` (L783)
  The rows of a section from the measured top of each item (in item order): items with the same top share a row.
  @param {number[]} tops
  @returns {number[]} the row index of each item

- `function foldState(model, rows, expanded)` (L803)
  Whether a section can fold (`canFoldRowCount`: it needs more rows than defaultVisibleRows) and which items stay
  visible while it is folded.
  @param {number[]} rows the row index of each item, from rowsFromTops
  @returns {{canFold: boolean, visible: boolean[]}}

- `const FOLD_CONTENT_TITLE_AND_ICON = 'titleAndIcon';` (L812)
  The content "titleAndIcon" (configuration "titleAndIconAlways"): the title and the chevron in both states, "More ⌄" folded, "Less ⌃" expanded.

- `function longerFoldTitle(a, b)` (L815)
  The longer of the fold titles: a hidden sizer of it keeps the control as wide as its widest state, so it does not jump when toggled.

- `const ANIMATION_PREFIXES = [/^\/+/, /^(\.\.\/)+/, /^CYLMenuExample\.bundle\//, /^Animations\//];` (L826)
  Folders the iOS examples put before an animation file's path, and file name extensions of each engine.

- `function animationEngine(animation)` (L829)
  The engine of an animation file by its extension ("lottie", "gif", "pag", "rive"), or ''.

- `function animationKey(animation)` (L837)
  "../Animations/Lottie/x.json", "CYLMenuExample.bundle/Animations/Lottie/x.json" → "Lottie/x.json".

- `function resolveAnimation(animation, registry = {}, assets = {})` (L850)
  The registered file of a tag's animation (`registry` by its path without the iOS folders, or the older `assets` of
  "asset:<name>"), or null. No engine is checked here: the library links none, and the app's engine component (an
  abstract node of cyl-animated-item) reports `error` when it cannot play the file, which shows the image instead.
  @returns {{engine: string, key: string, entry: object}|null}

- `function isLoadablePath(animation)` (L865)
  True for a path the app can load as it is: an absolute package path or a URL ("/assets/a.json", "https://…").

- `function animationURL(animation, registry = {}, assets = {}, options = null, restingProgress = 0)` (L876)
  The `animation-url` cyl-animated-item plays for a tag (CYLTabBarController's shared icon + title component): the
  registered file's path ("Lottie/x.json", "Rive/house.riv", "pag-ios/0.pag", "asset:<name>.json", which the app's
  engine component resolves), a GIF's own file (drawn by `<image>`), or an absolute path or URL as it is; '' when there is
  no such file. The tag's `animationOptions` (Rive's stateMachine, input …) and a `restingProgress` above 0 follow
  after "#" as "key=value&…", which cyl-animated-item ignores when it finds the type.

- `function animationParameters(url)` (L893)
  The parameters after "#" of an `animationURL` ({stateMachine: 'State Machine', restingProgress: '1'}), for engines.

- `function stateOf(item, selected)` (L900)
  The state used for the appearance: disabled wins over selected (as on UIControl).

- `function glassTintAlpha(state)` (L906)
  The tint alpha a tag's glass is drawn with: a selected tag keeps its full colour, the others use the component's default (-1).

- `function iconColor(style, state)` (L914)
  The effective icon tint of a state (`CYLMenuStyle.iconColor(for:)`): iconColor, else the text color. Kept for callers of the model;
  the drawn colour is resolved by the item (`itemColorProperties`).

- `function itemColorProperties(style, state)` (L929)
  The item properties cyl-animated-item resolves a tag's colours by (the twin of CYLTagButton handing colours to CYLAnimatedItemView):
  the background style, the tint handed to the glass (explicit background or '') and its alpha, the colour mode of the style, and the
  COLOUR CHANNELS of the state. An explicit title colour (or an explicit icon colour; the icon follows an explicit title colour) goes
  through `subclass...Color`; the effective colour of an unset one goes through `builtIn...Color`. The tag never writes the integrator's
  `titleColor` / `iconTint` and has no contrast code: the item's resolvers decide precedence and dark-glass adaptation.

- `function resolvedTextColor(style, state)` (L948)
  The tag's title colour as drawn: the item's resolved title colour of the state.

- `function resolvedIconColor(style, state)` (L953)
  The icon tint as drawn (baked into a `system:` symbol): the item's resolved icon colour of the state.

- `function iconColorData(item, state, style, icon)` (L972)
  The icon colour the tag hands to the cyl-animated-item that draws a NON-system image or an animation, and the colour of a glyph
  fallback. The item is NOT given the glass properties (it would draw a second glass inside the tag's own); instead the colour is
  resolved here by the item's own resolver with the tag's glass state (`itemColorProperties`), so it is already lifted on drawn dark
  Liquid Glass (icon 3:1), and unchanged on flat, light and disabled. An explicit colour goes through the state's `subclass...IconColor`
  channel (it tints a static image), an unset one through `builtIn...IconColor` (it never tints a still, only a one-colour animation).
  A baked `system:` symbol already carries its colour and gets no channel. The keys are the item's property names.
  @returns {object} the six channel properties and `glyphColor` ('' unless the icon is a glyph fallback)

- `function tailFoldColors(style, explicitColor)` (L992)
  The title and icon colours of the TAIL fold tag (a drawn glass tag like any other): the fold colour is explicit when the app set it
  (`explicitColor`, else the style's `foldControlColor` when set), else the tint (built-in); both go through the item's resolvers with
  the tag's glass state, so on drawn dark glass they are lifted (title 4.5, icon 3) and elsewhere unchanged. Header and footer folds
  are flat and keep `resolvedFoldControlColor`.
  @returns {{titleColor: string, iconColor: string}}

- `function lineHeight(size)` (L1006)
  A CSS line height for a font size (UIFont.systemFont's lineHeight is about 1.19 times its size).

- `function isVerticalPlacement(placement)` (L1011)
  True for the placements 'top' and 'bottom' (`CYLTagImagePlacement.top` / `.bottom`): icon and title stacked.

- `function tagHeight(style)` (L1019)
  Tag height (`CYLTagButton.height(for:)`): itemHeight, or more for a line of the title font and the insets; with the
  icon above or below the title, also the icon slot and imageTitleSpacing.

- `function tagHeightForTitle(style, title, iconSize)` (L1034)
  `CYLTagButton.height(forTitle:iconSize:style:traitCollection:)`: the height a tag needs for a title (or none) and an
  icon of `iconSize` ({width: 0, height: 0} for none): the taller of the two side by side, or both and the spacing
  when stacked; at least itemHeight.

- `const BADGE_DEFAULT_COLOR = '#FF3B30';` (L1048)
  The badge's color when none is given: UIColor.systemRed.

- `function badgeLayout(badgeValue, badgeColor)` (L1056)
  The badge of a tag (`CYLTagButton.badgeValue` / `badgeColor`): null or undefined hides it, '' is an 8 px dot, any
  other text a white bold 11 px capsule at least 16 px high, on `badgeColor` (system red by default). It sits on the
  top trailing corner of the icon slot (or of the title): the center of its leading cap on the corner.
  `badgeAccessibilityValue` is what a screen reader reads after the title: the text, or "New" (localized) for a dot.

- `function cornerRadius(radius, height)` (L1078)
  Corner radius in points: 0 is square, at most half the height (half the height or more is a capsule).

- `function iconContent(item, state, style, animation)` (L1092)
  What the icon slot of a tag shows in a state: the animation (a file to play, `animationURL`), else the
  state's image (the selected image while selected, as CYLFlatDesignTabBarItem.selectedImage), an SF Symbol stand-in
  tinted with the state's icon color, or nothing.
  @returns {{kind: 'animation'|'image'|'glyph'|'none', src: string, glyph: string}}

- `function animatedIcon(item, state, style, url)` (L1109)
  What CYLTabBarController's cyl-animated-item draws in a tag's icon slot (the library has no animation code of its
  own): `animationUrl` (`animationURL`, '' for none), `iconSrc`, the static image it shows until the engine is ready and
  after it fails (the state's image, or a tinted symbol), and `iconEnabled` (an animation is dimmed while the tag is
  disabled, an image keeps the state's colors). A symbol without an image (`iconKind` 'glyph') is drawn as text.

- `function tagLayout(style, item, state, icon, interitemSpacing, lineSpacing, fixedHeight)` (L1134)
  The CSS of one tag (`CYLTagButton.layoutSubviews` and `width(forTitle:iconSize:style:)`): a border-box whose
  padding is the content insets with the border inside them, the widest insets of every state so that selecting a
  tag does not resize it; the icon slot (imageSize, or animationSize for an animation) with imageInsets taken off its
  size from the top left; icon and title centered with imageTitleSpacing between them, a lone icon or title centered
  with layoutCentered or kept in place (after an empty icon slot) without it; the position adjustments as offsets.
  @param {boolean} showsAnimation whether the icon slot holds an animation
  @param {number} [fixedHeight] the tag's height; `tagHeight(style)` (every tag of a list as high) by default

- `function tagButtonView(props, animationUrl, pixelRatio = 2, dark = false)` (L1227)
  The view data of the standalone `cyl-tag-button` (the core's `CYLTagButton` on its own): `props` holds the iOS names
  (title, image, selectedImage, animationSpeed, badgeValue, badgeColor, accessibilityLabel, selected, enabled, tagStyle),
  `animationUrl` the file cyl-animated-item plays (`animationURL`, '' for none). The tag is `tagLayout` at its own height (`tagHeightForTitle`: no
  room for a missing icon or title), with the badge and an accessibility label that reads `accessibilityLabel` (else the
  title), then the badge.

- `function sizerFonts(style, state)` (L1261)
  The fonts of the other states when they differ from this one's: the title is laid out with each of them (hidden) so
  that the tag is as wide as its widest state, as `CYLTagButton.width(forTitle:…)` measures every state.

- `function isRtl(style)` (L1277)
  True when the list reads right to left: the style's `direction` is `rtl` (`auto` is `ltr`, see DIRECTIONS).

- `function physicalInsets(style, value)` (L1285)
  Insets as distances from the list's physical left and right edges. The style's left / right values are the leading /
  trailing ones, so right to left swaps the sides (top and bottom stay); left to right returns the insets as they are.

- `function boardInset(style)` (L1296)
  The board's outward extension, the ONE place it is computed: how far the board (card, header band, divider) reaches past
  the tag column on the left and the right. Unset `sectionBoardInset` (null) is the default, the leading / trailing parts of
  `sectionContentInsets` (the board then spans the section column); a set value (0 included) overrides them on both sides,
  0 hugging the tags. A value above the default may push the board past the list margin. None without a board.
  It never moves the tag column.

- `function cardInsets(style)` (L1309)
  The card's padding around the tags under insetGrouped, else none: left / right are the board's extension (`boardInset`), top / bottom from
  `sectionContentInsets`.

- `function contentColumn(style)` (L1317)
  The section's column: the list width minus `sectionInsets`, as distances from the list's left and right edges (leading / trailing mirrored).

- `function tagColumn(style)` (L1326)
  The ONE column the header title and the tags share: `contentColumn` minus the leading / trailing `sectionContentInsets`
  under insetGrouped, else the section column. It never depends on `sectionBoardInset`. Rows, folding and height follow it.

- `function boardColumn(style)` (L1338)
  The column of the board (card, header band, divider): the tag column extended outward by `boardInset` on both sides
  (the section column by default, the tag column itself for 0). Without a board it is the section column. A distance
  can be negative when the board passes the list's margin (accepted).

- `function columnAt(column, listWidth)` (L1346)
  A column's x and width at the list width `listWidth`.

- `function isStyledHeader(style)` (L1355)
  True when the header spans the column (a band or a card) instead of the whole list width.

- `function headerEdges(style)` (L1364)
  The distances from the list's edges to the header's title and fold control: the tags' edges inside the board
  (insetGrouped: the header and the taglist always align), the band's edges plus `headerContentInsets` (a plain header
  with a band), else `headerHorizontalInset`.

- `function headerBox(style)` (L1375)
  The distances from the list's edges to the header element: the column when styled, else the whole list.

- `function isHeaderTightToBoard(style)` (L1380)
  True when the header is sized to its text and the board follows it closely: insetGrouped with no header divider.

- `function headerBoardOffset(style, hasHeader = true)` (L1385)
  The distance from the header's bottom to the board's top: HEADER_BOARD_SPACING for a tight header, else the section's top inset.

- `function headerHeightOf(style)` (L1393)
  The header's height (a minimum for a tight header): headerHeight, at least the title's line and 12. A tight header
  (isHeaderTightToBoard) is the title's line plus HEADER_BOARD_TITLE_PADDING, and `headerHeight` counts only when the app set it.

- `function headerSeparator(style)` (L1404)
  The header divider as distances from the list's edges and its thickness, or null when there is none: it has the same left
  and right edges as the card and the header band (the column's), never the title's x; `headerSeparatorInsets` (null by
  default) insets it from the column. It sits at the header's bottom inside the header height, so it adds no height.

- `function resolvedBackgroundColor(style)` (L1420)
  The list background as drawn: the app's `backgroundColor` (even transparent) when set, else the grouped background under
  insetGrouped, else the system background (`listBackground`: white in light mode, black in dark mode).

- `function resolvedSectionBackgroundStyle(style)` (L1429)
  The card's background as drawn: `sectionBackgroundStyle`, flat where cyl-animated-item's rule says no glass (the rule of
  the glass tags). The frames never depend on it.

- `function rgbaOf(text)` (L1435)
  The {r, g, b, a} of a CSS color of `color()` ('#RRGGBB', rgb(), rgba()), or null.

- `function opaqueLuminance(text)` (L1448)
  Relative luminance (WCAG) of an opaque color text, or null when it is missing, invalid or not opaque.

- `function relativeLuminance(red, green, blue)` (L1466)
  WCAG relative luminance of an sRGB color, components 0..1.

- `function isGlassDrawn(style)` (L1472)
  Whether the tag's Liquid Glass background is really drawn (the predicate of the glass background of `tagLayout`).

- `function glassHandedBorder(style, appearance)` (L1481)
  The border handed to the glass: under drawn glass an unset color or width is none (null / 0, the shared glass rim applies; the
  selected state's built-in app-tint border included), an explicit one is kept. Flat tags hand the appearance's border unchanged.
  @returns {{color: (string|null), width: number}}

- `function glassHandedColor(style, appearance)` (L1494)
  The color handed to the glass: under drawn glass an unset background hands none (''), else the appearance's own color.
  Flat tags hand it unchanged.

- `function tintAgainst(background)` (L1499)
  Black on a light opaque background, white on a dark one; null when the background is not opaque.

- `function paintedBackground(style)` (L1506)
  The background the list paints itself (always one: the app's, the grouped one or the system background).

- `function resolveTint(style, against)` (L1514)
  The tint of the built-in non-tag views: `tintColor` when set, else black / white against `against` (a header band's color,
  where one shows), else against the list's painted background, else the system mode's (`sectionPalette.dark`).

- `function resolvedHeaderTextColor(style)` (L1521)
  The header title's color: the app's `headerTextColor`, else the tint (against the band when a band shows).

- `function resolvedFoldControlColor(style, inHeader = false)` (L1526)
  The fold / More control's color: the app's `foldControlColor`, else the tint (against the band for a control in the header).

- `function resolvedSectionBackgroundColor(style)` (L1535)
  The card's color as drawn: its own; for drawn glass '' when unset (no color: cyl-animated-item's default frosted tint, the same one a
  glass tag with no background gets, so the board and the tags are one glass style); else the card color of the color mode.

- `function sectionBackgroundCSS(style)` (L1542)
  The card's background CSS: the solid color, or the glass of the tags (blur and tint, clipped to the card's corners).

- `function resolvedHeaderSeparatorColor(style)` (L1552)
  The divider's color as drawn: its own, else the system separator of the color mode.

- `function headerTitleCSS(maxLines)` (L1557)
  The CSS of a header title that wraps: at most `maxLines` lines then an ellipsis (every line when unlimited), like a tag's title.

- `function headerInnerWidth(style, listWidth)` (L1564)
  The header's INNER WIDTH at the list width `listWidth`: between the header edges (the tag column), never negative.

- `function headerFoldMaxFraction(shared = false)` (L1570)
  The fold control's width cap as a fraction of the inner width: the shared one when More, clear or an accessory also shows.

- `function headerFoldWidth(innerWidth, collapsedWidth, expandedWidth, shared = false)` (L1578)
  The fold control's width: its natural width in the WIDER of the collapsed and expanded states, capped at the fraction of the
  inner width. One number for both states, so the title room does not change when the control is toggled. Pure.

- `function headerTitleMaxWidth(style, innerWidth, fixedWidths = [])` (L1589)
  The title's maximum width (px): the inner width minus the fixed parts present (`fixedWidths`, the fold control's width and any
  other part's) minus HEADER_ITEM_SPACING for each of them, never below the title's minimum (HEADER_TITLE_MIN_EM of the header
  font, at least HEADER_TITLE_MIN_WIDTH_PX). With no fixed part it is the inner width. The title wraps to `headerMaxLines` at
  exactly this width; the CSS reaches the same width by giving the fixed parts `flex: none` and the title `flex: 0 1 auto` with
  `min-width` of the minimum. Pure.

- `function headerTitleLines(textWidth, room, maxLines)` (L1596)
  The number of lines a title of `textWidth` px takes at `room` px, at most `maxLines` (an even split of whole lines; at least one).

- `function headerHeightForLines(style, lines)` (L1605)
  The header's height for a title of `lines` lines: the fixed (or minimum) headerHeight for a one-line header, and for a wrapping
  one (headerMaxLines above 1) the minimum or the lines plus the wrap padding, whichever is taller; the same numbers
  `sectionLayout` writes into the CSS (`min-height`, `padding`).

- `function foldHeaderWidthCSS(options = {})` (L1617)
  The CSS of the fold control in a section header: it never shrinks (`flex: none`), is at most the fraction of the header's
  content box, and sits HEADER_ITEM_SPACING from the title on its leading side (the physical side swaps right to left).
  `options.rtl`, `options.shared` (More, clear or an accessory also shows).

- `function foldControlFontCSS(size = FOLD_CONTROL_FONT_SIZE)` (L1625)
  The CSS font size of a fold / More control: `size` px, never above FOLD_CONTROL_MAX_FONT_SIZE (the system font size scales text up).

- `function directionCSS(style)` (L1630)
  The CSS appended to the list's own style: `direction: rtl` right to left, nothing (byte for byte as before) left to right.

- `function sectionLayout(style, options = {})` (L1642)
  The CSS of a section: its insets (the last line's spacing taken off the bottom), the negative trailing margin
  that absorbs the last tag's spacing, the header (headerHeight, headerFont, headerTextColor, headerHorizontalInset)
  and the list's background. `options.hasHeader` (default true) is false for a section that shows no header (its board then
  starts at the section's top inset). It adds `cardStyle` (the default, insetGrouped), a band in `headerStyle` and `headerLineStyle`
  (the divider, opt-in); under `sectionStyle: 'plain'` there is no `cardStyle` and the rest is what it was before the card
  became the default.

- `function coderString(value)` (L1691)
  The value text of an offset, a size and insets, as NSCoder.string(for:) writes them ("{0, -4}", "{16, 16}").

- `const CALLOUT_GAP = 8;` (L1699)
  The gap between the callout bubble and the tag (the wxss translateY of .cyl-callout) and the room it needs above the tag.

- `function calloutPlacesBelow(target, height, header, bottomLimit = Infinity)` (L1709)
  Whether the callout goes below the tag (the core's `CYLTagLongPressAction.placesBelow`). Above first; below when there is
  no room above (the tag's top is under CALLOUT_MIN_ROOM_ABOVE) or when the bubble would cover `header` (the section header
  above a first-row tag) and it fits below; above when neither side is free of the header and below does not fit. Pure:
  `target` and `header` are {top, bottom} in one coordinate space; `header` may be null; `bottomLimit` may be omitted
  (no limit).

## CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/symbols.js

- `const STROKE = 'fill="none" stroke="C" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"';` (L8)
  Stand-ins for the SF Symbols the examples use (`image: "system:<name>"`), drawn as SVG so that they are tinted like
  template images (`iconColor` of the state, else its text color), as `UIImage(systemName:)` is on iOS. A Mini Program
  has no SF Symbols; these are simple 24 × 24 drawings of the same shapes. Names without a drawing fall back to an
  emoji (GLYPHS), as before. No `wx` calls: the tests run it under Node.

- `const DRAWINGS =` (L20)
  name -> the SVG content, "C" standing for the color.

- `const GLYPHS =` (L48)
  Emoji stand-ins for the names without a drawing (they keep their own colors).

- `function base64(text)` (L56)
  Base64 of an ASCII string (a Mini Program has no btoa).

- `function symbolURI(name, color)` (L74)
  The symbol tinted with `color` as an SVG data URI, or '' when there is no drawing for it.

## CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/theme.js

- `function isDark()` (L6)
  The system color mode of the Mini Program (`theme` of wx.getAppBaseInfo(), 'light' or 'dark') and a way to follow its
  changes, so the list's defaults (the tag fill and title, the one tint of the header and fold controls) follow dark mode
  as iOS's dynamic colors do.

- `function onChange(callback)` (L16)
  Calls `callback(dark)` when the system theme changes; returns the function that stops it.

## CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist/index.js

cyl-tag-list-miniprogram: the tag list, the tag cloud and the image tag of CollectionViewClassifyMenu for WeChat
Mini Programs. The components are used by path (usingComponents):
  "cyl-tag-list":  "cyl-tag-list-miniprogram/cyl-tag-list/cyl-tag-list"
  "cyl-tag-cloud": "cyl-tag-list-miniprogram/cyl-tag-cloud/cyl-tag-cloud"
  "cyl-tag-image": "cyl-tag-list-miniprogram/cyl-tag-image/cyl-tag-image"
  "cyl-tag-button": "cyl-tag-list-miniprogram/cyl-tag-button/cyl-tag-button" (one tag on its own: icon, title, badge)
This module gathers their models and settings for scripts.

## CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist/locale.js

- `const CORE_TABLES = require('./core-tables.js');` (L8)
  The language of the tag views and the core library's strings (CollectionViewClassifyMenu/Resources/Localization/
  *.lproj/CYLClassifyMenu.strings, exported to core-tables.js), read by `CYLMenuLocalizedString` on iOS.
  The language is the one set with setLanguage(), else WeChat's language. An app that has its own strings (as the
  example's utils/i18n.js) reads and sets the language here, so the tags and the app always agree.

- `function tableFor(language)` (L14)
  The table name for a WeChat or BCP 47 language: "en", "zh-Hant", or "zh-Hans" (the source).

- `function setLanguage(value, persist = false)` (L39)
  Switches the language for this session (and, with `persist`, later launches).

- `function format(text, args)` (L48)
  Fills the iOS format specifiers in order: %@ %d %ld %lu %s %i, positional %1$@, and %% (a literal percent sign).

- `function tc(key, ...args)` (L64)
  The core library's string for an identifier (e.g. "CYLMenuExpand" → 更多), as `CYLMenuLocalizedString`; the Chinese
  (zh-Hans) one when the language has none.
