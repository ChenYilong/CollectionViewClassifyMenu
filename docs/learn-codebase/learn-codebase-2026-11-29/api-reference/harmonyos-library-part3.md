# harmonyos: library (part 3 of 4)

## harmony/classifymenu/src/main/ets/core/CYLMenuResources.ets

The core's resources, as iOS `CYLMenuResources`: its images (the pod's Images.xcassets, copied to the HAR's media)
and its strings in English, Simplified and Traditional Chinese (CYLCoreStrings.ets, generated from the pod's
CYLClassifyMenu.strings). The language is `preferredLanguage` when set, else the system's, else English.

- `const IMAGES: Map<string, Resource> = new Map<string, Resource>([` (L12)
  The images of the pod's asset catalog by name ($r needs a literal, so each one is listed).

- `export class CYLMenuResources` (L60)

- `static preferredLanguage: string | undefined = undefined;` (L62)
  A language of `availableLanguages` used instead of the system's; undefined for the system's.

- `static readonly bundle: string = 'classifymenu';` (L65)
  The name of the resource bundle on iOS; on HarmonyOS the resources live in the classifymenu HAR.

- `static image(name: string): Resource | undefined` (L68)
  An image of the core by its asset name ("cyl_more", "cyl_fold_chevron", ...), or undefined.

- `static get availableLanguages(): string[]` (L73)
  The languages the core has strings for, sorted.

- `static get currentLanguage(): string` (L79)
  The preferred language when set, else the system language, else English.

- `static localizedString(key: string, language?: string): string` (L85)
  The string of `key` in the current language.

- `export function CYLMenuLocalizedString(key: string): string` (L99)
  `CYLMenuLocalizedString(_:)`: the core string of `key` in the current language.

## harmony/classifymenu/src/main/ets/core/CYLMenuStyle.ets

The look of a tag list, as iOS `CYLMenuStyle`: the tags in each state (`CYLTagAppearance`), the delete indicator,
the touch ripple, titles, rows, icons, layout spacing, section headers, fold controls and the More button. Lengths
are vp, font sizes fp, colors '#AARRGGBB'. `copy()` is NSCopying.

- `export enum CYLTagImagePlacement` (L16)
  The icon before or after the title, or above (`top`) or below (`bottom`) it, both centered.

- `export function CYLTagImagePlacementIsVertical(placement: CYLTagImagePlacement): boolean` (L26)
  True for `top` and `bottom`: the icon and the title are stacked.

- `export enum CYLTagContentAlignment` (L33)
  The icon and title centered in the tag, or at its leading edge.

- `export enum CYLTagBackgroundStyle` (L42)
  What a tag's background is made of: the solid color of each state's appearance (`flat`, the default), or a Liquid Glass
  background (`liquidGlass`: the blur imitation of CYLTabBarController's glass, tinted with the state's background color).

- `export enum CYLTagRowAlignment` (L50)
  Where a row of tags sits in the list's width.

- `export enum CYLTagDeleteIndicatorPlacement` (L59)
  The delete indicator after or before the title.

- `export interface CYLTitleTextAttributes` (L67)
  The font and text color of a state (`titleTextAttributes(for:)`).

- `export enum CYLSectionStyle` (L76)
  How a section's tags sit in the list: `insetGrouped` (the default) inside a rounded card (UITableView's inset grouped look),
  the header above it; `plain` (the opt-out) on the list's background.

- `export enum CYLHeaderSeparatorStyle` (L84)
  The line at the bottom of a section header: `none` (the default) or a `line`.

- `export class CYLSectionStyleMetrics` (L92)
  The named lengths of the section style, vp.

- `static readonly cardCornerRadius: number = 10;` (L94)
  The corner radius of a section card.

- `static readonly cardPadding: number = 12;` (L96)
  The padding between a section card and its tags.

- `static readonly headerBandPadding: number = 12;` (L98)
  The padding between a header band and its title, leading and trailing.

- `static readonly separatorThickness: number = 0.5;` (L100)
  The thickness of the header divider: one hairline.

- `static readonly headerBoardTitlePadding: number = 8;` (L105)
  The padding around a header's title lines under `insetGrouped` with no divider (4 above, 4 below), where the header is
  sized to its text instead of the fixed `headerHeight`.

- `static readonly headerBoardSpacing: number = 4;` (L107)
  The space between that header's bottom and the board (the section card), instead of the section's top inset.

- `static readonly defaultHeaderHeight: number = 36;` (L109)
  The default `headerHeight`: the fixed header band of the plain style and of a header with a divider.

- `export const CYLTintLuminanceThreshold: number = 0.179;` (L116)
  The relative luminance (WCAG, 0...1) above which a background counts as light, so that the default tint on it is black:
  0.179 is where black and white have the same contrast ratio against it.

- `export const CYLDefaultHeaderFontSize: number = 17;` (L121)
  The default `headerFont` size: the system table header look (17 pt / dp / vp), not a caption.

- `export const CYLDefaultHeaderFontWeight: FontWeight = FontWeight.Bold;` (L127)
  The default `headerFont` weight, the semibold of the iOS header (600). `FontWeight` has no 600: Medium is 500 and Bold
  700, and the core takes Bold, the heavier neighbour, so that the title reads as a header and not as body text.

- `export class CYLSectionStyleColors` (L133)
  The colors of the section style: each one follows the color mode (`resources/base` and `resources/dark`). A style whose
  color is undefined resolves to them; an app can also set one itself, for example `headerBand` on `headerBackgroundColor`.

- `static readonly systemTint: ResourceColor = $r('sys.color.font_primary');` (L135)
  The system's primary font color (`sys.color.font_primary`): black in light mode, white in dark mode.

- `static readonly card: ResourceColor = $r('app.color.cyl_section_card');` (L137)
  The section card: white; #1C1C1E in dark mode.

- `static readonly headerBand: ResourceColor = $r('app.color.cyl_section_header_band');` (L139)
  The header band: #EFEFF4; #2C2C2E in dark mode.

- `static readonly listBackground: ResourceColor = $r('app.color.cyl_list_background');` (L141)
  The list background of a list whose `backgroundColor` was never set: the system background, white; black in dark mode.

- `static readonly groupedBackground: ResourceColor = $r('app.color.cyl_section_grouped_background');` (L143)
  The list background under `insetGrouped`: #F2F2F7; black in dark mode.

- `static readonly separator: ResourceColor = $r('app.color.cyl_section_separator');` (L145)
  The header divider: the system separator color.

- `static readonly glassTint: ResourceColor = Color.Transparent;` (L151)
  What a Liquid Glass card with no `sectionBackgroundColor` hands to the glass: a transparent color, which
  `CYLAnimatedItemBackgroundModifier` reads as "no color", so the board draws the SAME frosted default tint and edge as a glass tag
  (one glass style for the tag and the board; it used to be a tint of its own).

- `const HAIRLINE: number = 0.5;` (L157)
  A tag border of one physical pixel (iOS: 1 / screen scale).

- `export class CYLTagTitleMaxLines` (L162)
  The line limits of a tag's title (`CYLMenuStyle.titleMaxLines`): named values, never a literal in a call site.

- `static readonly single: number = 1;` (L164)
  One line, the default: a title too wide for its tag is truncated.

- `static readonly unlimited: number = Number.MAX_SAFE_INTEGER;` (L166)
  No limit: a title wraps onto as many lines as it needs (the MAX of the line counts).

- `export class CYLHeaderTitleMaxLines` (L172)
  The line limits of a section header's title (`CYLMenuStyle.headerMaxLines`): named values, never a literal in a call site.

- `static readonly single: number = 1;` (L174)
  One line, the default: a title too wide for its header is truncated.

- `static readonly unlimited: number = Number.MAX_SAFE_INTEGER;` (L176)
  No limit: a title wraps onto as many lines as it needs.

- `export enum CYLLayoutDirection` (L184)
  The layout direction of a list: `ltr` (the default) or `rtl`, which mirrors the section header (title, icon, fold /
  More control), the section insets, the header band, divider and card insets, and starts the rows of tags at the
  trailing edge.

- `export class CYLMenuStyle` (L189)

- `rippleDuration: number = 1;` (L211)
  Seconds.

- `imageFillsTagHeight: boolean = false;` (L235)
  True: a leading image (or animated icon) is a circle as tall as the tag, at its leading edge, and the title follows
  it (`imageSize`, `imageInsets` and the leading content inset do not apply to it); AndroidTagView's avatar. Default
  false.

- `editingIndicatorSpacing: number = 10;` (L240)
  The space between the two editing icons of a renamable tag in editing mode (the edit icon and the delete icon,
  `CYLTagButton.editingIndicatorsView`), vp. 10 by default; a negative value is 0.

- `editingIndicatorInsets: CYLEdgeInsets = new CYLEdgeInsets(0, 4, 0, 0);` (L245)
  The margins around the two editing icons as a whole: left from the title, right to the tag's padding, top and
  bottom within the tag, vp. Left 4 and right 0 by default; negative values are 0.

- `clearButtonImage?: CYLImage = undefined;` (L247)
  The image of a section header's clear button; undefined: the core's trash icon ("cyl_trash").

- `clearButtonColor?: ResourceColor = undefined;` (L249)
  The color of the clear button; undefined: `headerTextColor`.

- `get titleMaxLines(): number` (L258)
  The most lines a title may take: a title too wide for its tag wraps onto more lines, up to this number, and the tag
  grows taller; beyond it the title is truncated. Default `CYLTagTitleMaxLines.single` (1, one line, truncated).
  `CYLTagTitleMaxLines.unlimited` shows every line. The list measures the taller tag at the width it gets. The number
  is the app's choice; a value that is not a whole number of 1 or more is 1.

- `get titleWraps(): boolean` (L271)
  True: a title wraps onto as many lines as it needs (AndroidTagView's tag_text_wrap), the same as `titleMaxLines` =
  `CYLTagTitleMaxLines.unlimited`; false: one line. Default false.

- `elevation: number = 0;` (L282)
  A shadow under each tag, as Android's elevation in vp (AndroidTagView's tag_elevation): offset down by half of it
  and blurred by it. Default 0, no shadow.

- `deleteIndicatorImage?: CYLImage = undefined;` (L288)
  An image drawn as the delete indicator instead of `deleteIndicatorTitle` or the drawn cross (AndroidTagView's
  tag_cross drawable): a square as tall as a line of the indicator font, plus `deleteIndicatorPadding` on each side.
  Default undefined.

- `backgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.flat;` (L296)
  The tag background: `flat` (the default) is the solid color of each state's appearance; `liquidGlass` draws a glass
  background behind the content, tinted with the state's `backgroundColor` and clipped to the corner
  radius. Where the device draws no Liquid Glass the style is ignored (`resolvedBackgroundStyle()`).

- `minimumTagSize: CYLSize = CYLSize.ZERO;` (L301)
  The smallest size of a tag, vp: a tag narrower or shorter than it grows to it, its content staying where
  `contentAlignment` puts it. `CYLSize.ZERO` (the default) keeps the tag as large as its content and `itemHeight` make it.

- `resolvedBackgroundStyle(): CYLTagBackgroundStyle` (L307)
  The background style a tag really draws: `backgroundStyle`, flat where `CYLLiquidGlass.isActive()` (the rule of
  CYLTabBarController's `cylanimateditem`) is false; every other parameter is kept.

- `get backgroundColor(): ResourceColor` (L328)
  The list's background color: the system background by default (`CYLSectionStyleColors.listBackground`, a resource: white
  in light mode, black in dark mode). Under `insetGrouped` a list whose background the app never set shows the grouped
  background instead (`resolvedBackgroundColor()`). A color the app sets, a clear one included, wins in both modes.

- `get isBackgroundColorSet(): boolean` (L337)
  True when the app set `backgroundColor` (a clear color counts); false while the mode-following default applies.

- `sectionStyle: CYLSectionStyle = CYLSectionStyle.insetGrouped;` (L343)
  `insetGrouped` (the default: the section's tags inside a rounded card) or `plain` (the opt-out: no card).

- `sectionBackgroundColor?: ResourceColor = undefined;` (L345)
  The card's color; undefined resolves to `CYLSectionStyleColors.card`.

- `sectionBackgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.flat;` (L351)
  The card's background: `flat` (the default) is the solid color; `liquidGlass` is the core's Liquid Glass material
  (the tags' drawing) with the card's corners, tinted with `sectionBackgroundColor`, else `CYLSectionStyleColors.glassTint`.
  Where the device draws no glass the card is flat (`resolvedSectionBackgroundStyle()`); the frames never change.

- `sectionContentInsets: CYLEdgeInsets = new CYLEdgeInsets(CYLSectionStyleMetrics.cardPadding,` (L354)
  The padding inside the card around the tags (`insetGrouped`), vp.

- `get sectionBoardInset(): number | undefined` (L366)
  How far the board (card, header band, divider) extends beyond the tag column on the left and on the right
  (`insetGrouped`), vp: ONE value for both sides. The header title and the tags always share the tag column (the section
  column minus `sectionContentInsets` leading and trailing); this value never moves them. Undefined (the default)
  extends the board by those leading and trailing parts (12), so it spans the section column (the first version's
  look); a set value, 0 included, replaces them (top and bottom padding still come from `sectionContentInsets`). 0 makes
  the board hug the tags. A value above the default can push the board past the list's margin (accepted). A negative
  value is 0. Right to left mirrors.

- `headerBackgroundColor?: ResourceColor = undefined;` (L375)
  The header band's color; undefined: no band (today's look). `CYLSectionStyleColors.headerBand` is the usual one.

- `headerContentInsets: CYLEdgeInsets = new CYLEdgeInsets(0, CYLSectionStyleMetrics.headerBandPadding, 0,` (L378)
  A plain header's title and fold control inset from the band's edges (left and right), vp.

- `headerSeparatorColor?: ResourceColor = undefined;` (L382)
  The divider's color; undefined resolves to `CYLSectionStyleColors.separator`.

- `headerSeparatorInsets?: CYLEdgeInsets = undefined;` (L388)
  The divider's leading (left) and trailing (right) inset from the column's edges, vp; undefined: it starts at the
  column's leading edge (the card's and the band's edge) and ends at its trailing edge: all three share the same left and right.

- `get headerHeight(): number` (L399)
  The fixed header height, vp (default `CYLSectionStyleMetrics.defaultHeaderHeight`, 36): the minimum of every header,
  except under `insetGrouped` with no header divider, where the header is sized to its text and this is a minimum only
  when the app set it (`isHeaderHeightSet`).

- `get isHeaderHeightSet(): boolean` (L409)
  True when the app set `headerHeight` (the configuration key included); false while the default 36 applies.

- `get headerMaxLines(): number` (L419)
  The most lines a section header's title may take: default `CYLHeaderTitleMaxLines.single` (1, one line, truncated,
  as before). With more, a long title wraps and the header grows taller than `headerHeight` to hold the wrapped
  lines (`CYLHeaderTitleMaxLines.unlimited`: every line). A value that is not a whole number of 1 or more is 1.

- `headerFont: CYLFont = new CYLFont(CYLDefaultHeaderFontSize, CYLDefaultHeaderFontWeight);` (L429)
  The section header title font; default `CYLDefaultHeaderFontSize` (17) in `CYLDefaultHeaderFontWeight` (semibold).

- `tintColor?: ResourceColor = undefined;` (L435)
  The one color of every built-in view that is not a tag (header title, section icon, fold / More control); undefined:
  black or white by the luminance of the background it is drawn on (`resolvedTintColor`). A color set on the title,
  the fold control or the More button itself wins over it for that view.

- `get headerTextColor(): ResourceColor` (L444)
  The section title's color: the system's primary font color (`sys.color.font_primary`, which follows dark mode, as
  `UIColor.label` does on iOS) until the app sets one; the color drawn by default is `resolvedHeaderTextColor`.

- `get foldControlColor(): ResourceColor` (L455)
  The fold controls' color: the list's one tint by default (see `headerTextColor`); a control's own color wins.

- `get moreButtonColor(): ResourceColor` (L469)
  The More button's color: the list's one tint by default (see `headerTextColor`).

- `get deleteIndicatorTitle(): string` (L502)
  The text of the delete indicator; an empty string restores "×".

- `get tagContentInsets(): CYLEdgeInsets` (L513)
  The content insets of every state; reads the normal state's.

- `appearance(state: number): CYLTagAppearance` (L528)
  The appearance of `state`: disabled wins over selected, which wins over normal.

- `setTitleTextAttributes(font: CYLFont | undefined, textColor: ResourceColor | undefined, state: number): void` (L541)
  Sets the font and text color of `state`; undefined restores the default.

- `titleTextAttributes(state: number): CYLTitleTextAttributes` (L558)
  The font and text color of `state`.

- `fillsTagHeight(iconSize: CYLSize): boolean` (L572)
  Whether an icon of this size is drawn by `imageFillsTagHeight` (a leading icon beside the title).

- `explicitIconColor(state: number): ResourceColor | undefined` (L581)
  The icon color the style set for `state` (`setIconColor`); undefined while it is unset, when the icon follows the text
  color (the built-in default). The tag hands the item only an explicit color; the item adapts it on dark glass.

- `displayedTitle(title: string | undefined): string` (L595)
  The title as the tag shows it: cut to `maximumTitleLength` characters, the last three being "..." (AndroidTagView's
  tag_max_length: 23 gives "Welcome to use Andro..."), and reversed character by
  character when `reversesTitleCharacters`. Characters are Unicode code points (iOS counts grapheme clusters).

- `titleFont(state: number, fontScale: number = 1, boldText: boolean = false): CYLFont` (L621)
  The title font of `state` at the system font scale `fontScale` (the trait collection on iOS).

- `deleteIndicatorFontFor(state: number, fontScale: number = 1, boldText: boolean = false): CYLFont` (L628)
  `deleteIndicatorFont`, else the title font.

- `headerFontFor(fontScale: number = 1, boldText: boolean = false): CYLFont` (L636)
  The header font at `fontScale`.

- `get isInsetGrouped(): boolean` (L641)
  True when the section style draws the cards.

- `resolvedBackgroundColor(): ResourceColor` (L649)
  The list background as drawn: the color the app set, else the grouped background under `insetGrouped`, else the system
  background (a resource that follows the mode).

- `static tintOn(background: ResourceColor | undefined): ResourceColor` (L661)
  The default tint (`tintColor` unset) of a built-in view drawn on `background`: black on a light one, white on a dark
  one (`CYLTintLuminanceThreshold`); the system mode (`systemTint`: black in light, white in dark) when the background
  is not known as a color: transparent, or a resource (the library's palette follows the mode as the system tint does).

- `resolvedTintColor(onBand: boolean = false): ResourceColor` (L674)
  The tint of the built-in views as drawn: `tintColor`, else the default against what is behind them: the band color
  when `onBand` (a header with a band) and a band is set, else the opaque background the list paints itself
  (`resolvedBackgroundColor()`: the app's `backgroundColor`, the grouped background under `insetGrouped`).

- `resolvedHeaderTextColor(onBand: boolean = false): ResourceColor` (L683)
  The section title's color as drawn: the one the app set, else the tint.

- `resolvedClearButtonColor(onBand: boolean = false): ResourceColor` (L688)
  The clear button's color as drawn: the one the app set, else the section title's color.

- `resolvedFoldControlColor(onBand: boolean = false): ResourceColor` (L693)
  The fold controls' color as drawn (a control's own color still wins): the one the app set, else the tint.

- `resolvedMoreButtonColor(onBand: boolean = false): ResourceColor` (L698)
  The More button's color as drawn: the one the app set, else the tint.

- `resolvedSectionBackgroundStyle(): CYLTagBackgroundStyle` (L703)
  The card's background style as drawn: `sectionBackgroundStyle`, flat where `CYLLiquidGlass.isActive()` is false.

- `resolvedSectionBackgroundColor(): ResourceColor` (L709)
  The card's color as drawn: for drawn glass the app's color, else "no color" (the tags' frosted default); else the solid color.

- `resolvedHeaderSeparatorColor(): ResourceColor` (L716)
  The divider's color as drawn.

- `copy(): CYLMenuStyle` (L723)
  NSCopying.

- `static defaultStyle(): CYLMenuStyle` (L804)
  The default style.

- `static classifyMenuTag(look: number = 3): CYLMenuStyle` (L833)
  `classifyMenuTag(_:)`: a tag of `CYLClassifyMenuViewController` in one of its looks, by the raw value of
  `CYLCollectionCellButtonStyle` (0 general, 1 home, 2 red, 3 chengNi, the default: a light green capsule that takes the
  app's tint while selected or pressed).

- `static filterTag(): CYLMenuStyle` (L876)
  `filterTag()`: a tag of the multiple-choice filter: the filter's slide images as the normal and selected
  backgrounds, green titles that turn white when selected.

- `static sectionTitle(fontSize: number = 15, textColor: ResourceColor = CYLColor.BLACK, leadingInset: number = 0): CYLMenuStyle` (L895)
  `sectionTitle(fontSize:textColor:leadingInset:)`: a header's section title: no background or border, the content at
  the leading edge after `leadingInset`, an icon 4 vp before the title.

- `static wordPicker(): CYLMenuStyle` (L943)
  `wordPicker()` (选词填入, as WeChat's "涂抹选择填入词"): one character per cell, 9 equal cells per row, light gray
  cells with small corners that turn mint green when selected, the character centered. Use it with
  `CYLTagListState.setTagsWithCharactersOfText`, multiple selection and `allowsSmearSelection`; the picked text is
  `selectedText`.

- `static tagContainer(): CYLMenuStyle` (L973)
  AndroidTagView's look: translucent red capsules, gray text, 23 characters at most.

- `static gridStyle(itemsPerRow: number): CYLMenuStyle` (L1004)
  Borderless items in `itemsPerRow` columns, the icon after the title.

## harmony/classifymenu/src/main/ets/core/CYLTag.ets

A tag of a tag list built from models, as iOS `CYLTag.swift`: `CYLTag` (a title with its own look) and
`CYLTagDataSource` (a one-section data source of tags, caching each tag's style over its `baseStyle`).

- `const SYSTEM_BLUE: string = '#FF007AFF';` (L19)
  `UIColor.systemBlue`, the badge color when the tag has neither a badge nor a text color.

- `const SYSTEM_RED: string = '#FFFF3B30';` (L21)
  `UIColor.systemRed`, the badge dot's color when the tag has no badge color (`CYLTagBadgeDefaultColor`).

- `const BADGE_DOT_DIAMETER: number = 8;` (L23)
  The diameter of a badge dot, vp.

- `const BADGE_IMAGE_TEXT_PADDING: number = 4;` (L25)
  The side padding of a badge image's text, vp.

- `const BADGE_IMAGE_FONT_RATIO: number = 0.6;` (L27)
  The badge text's font size as a share of the badge diameter.

- `const BADGE_DEFAULT_DIAMETER: number = 16;` (L29)
  The badge diameter when the style's image size is zero, vp.

- `export class CYLTag` (L31)

- `subtitle?: string;` (L35)
  A longer description, shown in a callout on a long press (`CYLTagLongPressActions.callout`).

- `animationURL?: string;` (L39)
  A Lottie animation: `asset:<rawfile path>` or the JSON text.

- `badgeText?: string;` (L43)
  A badge drawn as the tag's image when it has none (a count, "hot").

- `static withHex(identifier: number, title: string, backgroundColorHex: string | undefined): CYLTag` (L69)
  `init(identifier:title:backgroundColorHex:)`: the background from "#RRGGBB" or a UIColor name.

- `get style(): CYLMenuStyle | undefined` (L74)
  The tag's own style (copied when set); undefined for the list's.

- `get colors(): CYLTagColors` (L83)
  The four colors of the tag; setting it sets them.

- `resetColors(): void` (L88)
  `resetColors()`: the colors back to their defaults (the style's).

- `get hasCustomStyle(): boolean` (L100)
  Whether the tag changes anything of the list's style.

- `styleBasedOn(baseStyle: CYLMenuStyle): CYLMenuStyle` (L111)
  The tag's look over `baseStyle` (over its own `style` when set).

- `copy(): CYLTag` (L164)
  NSCopying.

- `static readonly badgeDotDiameter: number = BADGE_DOT_DIAMETER;` (L192)
  The diameter of a badge dot, vp: 8, as `CYLTagButton`'s dot (iOS `badgeDotDiameter`).

- `static readonly badgeImageTextPadding: number = BADGE_IMAGE_TEXT_PADDING;` (L194)
  The side padding of a badge image's text, vp: 4, as `CYLTagButton`'s corner badge (iOS `badgeImageTextPadding`).

- `static badgeDotImage(color: string, canvas: number): image.PixelMap` (L197)
  A badge dot: a filled `color` circle `badgeDotDiameter` vp wide (at most `canvas`), centered in a `canvas` square.

- `static badgeImageWidthForText(textWidth: number, diameter: number,` (L216)
  The width of a badge image: the diameter (a circle) for a short text, or `textWidth` and `badgeImageTextPadding` on
  both sides when that is more (a capsule; iOS `badgeImageWidth`: max(diameter, text + 2 * padding)). Pure, so that
  the math is testable without a canvas.

- `static badgeTextKeepsCircle(text: string): boolean` (L223)
  One character (a digit, a letter, a CJK character such as "热") always keeps the circle, as on iOS.

- `static badgeImage(text: string, color: string, diameter: number): image.PixelMap` (L233)
  A capsule of `color`, `diameter` vp high, with `text` in bold white at 60 % of the diameter (a circle when short).

- `export class CYLTagDataSource implements CYLMenuDataSource` (L270)
  A one-section data source of tags; each tag's style over `baseStyle` is cached until `invalidateStyles()`.

- `get baseStyle(): CYLMenuStyle` (L290)
  The style the tags' own looks apply over (copied when set).

- `menuImageForItem = (indexPath: CYLIndexPath): CYLImage | undefined =>` (L359)
  The tag's image; a tag with a badge and no image gets the badge drawn at the style's image size.

- `menuStyleForItem = (indexPath: CYLIndexPath): CYLMenuStyle | undefined =>` (L391)
  The cached style of a tag with its own look; undefined for the list's.

## harmony/classifymenu/src/main/ets/core/CYLTagAppearance.ets

The box and text of a tag in one state (normal, selected, disabled), as iOS `CYLTagAppearance`. Negative or
non-finite lengths become 0. The colors and the font are null_resettable: `reset…()` restores their default.

- `export class CYLTagAppearance` (L11)

- `static readonly defaultBackgroundColor: ResourceColor = $r('app.color.cyl_tag_background');` (L13)
  White in light mode, the secondary system background (#1C1C1E) in dark mode (a resource with a dark variant), as on iOS.

- `static readonly defaultTextColor: ResourceColor = $r('app.color.cyl_tag_text');` (L15)
  Dark gray in light mode, white (the primary label) in dark mode.

- `iconColor?: ResourceColor;` (L34)
  The icon tint; undefined uses `textColor`. Any `ResourceColor`, a theme color included.

- `get backgroundColor(): ResourceColor` (L40)
  The box; any `ResourceColor` (a '#AARRGGBB' string, a `Color`, a theme resource that follows the color mode).

- `get textColor(): ResourceColor` (L51)
  The title; any `ResourceColor`.

- `get explicitTextColor(): ResourceColor | undefined` (L64)
  The color set on `textColor` (setter, configuration key, preset); undefined when it was never set, was reset, or is the
  style's built-in default (`setDefaultTextColor`). On dark Liquid Glass only this color is adapted for contrast.

- `setDefaultTextColor(color: ResourceColor): void` (L69)
  Sets the built-in title color of the style: the effective color until the app sets one, never explicit.

- `inheritTextColor(source: CYLTagAppearance): void` (L75)
  Takes over `source`'s title color exactly: the effective color and whether it is explicit.

- `get explicitBackgroundColor(): ResourceColor | undefined` (L93)
  The color set on `backgroundColor`; undefined when it was never set or was reset (the built-in default applies, which
  is never stored). Under Liquid Glass only this color tints the glass: an unset background hands no color, so the
  glass keeps its frosted default tint (iOS `explicitBackgroundColor`).

- `get isBackgroundColorSet(): boolean` (L98)
  True when `backgroundColor` was set to a color (and not reset).

- `get borderColor(): ResourceColor | undefined` (L106)
  The border; undefined draws none. Any `ResourceColor`. Reads the effective color (the style's built-in default until the
  app sets one); under Liquid Glass only an explicit one is drawn (`explicitBorderColor`).

- `get explicitBorderColor(): ResourceColor | undefined` (L116)
  The color set on `borderColor`; undefined when it was never set, was reset, or was set to none.

- `get isBorderColorSet(): boolean` (L121)
  True when `borderColor` was set (setter, configuration key, preset), even to none; false for the built-in default.

- `get isBorderWidthSet(): boolean` (L126)
  True when `borderWidth` was set (setter, configuration key, preset); false for the built-in default.

- `get glassBorderColor(): ResourceColor | undefined` (L134)
  The border drawn under Liquid Glass: the EXPLICIT color decides (iOS `glassBorderColor`). An explicit color draws the
  border; nothing explicit (the built-in default, or a width set alone) draws none, so the shared glass rim shows.

- `get glassBorderWidth(): number` (L139)
  The width of the glass border: the effective width when `glassBorderColor` is defined, else 0 (iOS `glassBorderWidth`).

- `get isTextColorSet(): boolean` (L144)
  True when `textColor` was set to a color (and not reset or the style's built-in default; iOS `isTextColorSet`).

- `get explicitIconColor(): ResourceColor | undefined` (L149)
  The color set on `iconColor`; undefined when it is unset and the icon follows the title (iOS `explicitIconColor`).

- `get isIconColorSet(): boolean` (L154)
  True when `iconColor` was set to a color (and not reset; iOS `isIconColorSet`).

- `setDefaultBorder(color: ResourceColor | undefined, width: number): void` (L159)
  Sets the built-in border of the style: the effective border until the app sets one, never explicit.

- `inheritBorder(source: CYLTagAppearance): void` (L165)
  Takes over `source`'s border exactly: the values, which of them are explicit, and the built-in default.

- `get cornerRadius(): number` (L192)
  Corner radius in points: 0 is square corners, and a value of half the tag height or more is a capsule (the radius
  is limited to half the height, so a large value such as 1000 is a capsule for any tag). Negative or non-finite
  values are treated as 0. `CYLAnimatedItemCornerRadiusCapsule` by default.

- `get margin(): number` (L221)
  The larger of the left and right content insets; setting it sets both.

- `reset(): void` (L234)
  Restores every value to its default.

- `copy(): CYLTagAppearance` (L254)
  NSCopying.

## harmony/classifymenu/src/main/ets/core/CYLTagColors.ets

The four colors of a tag (background, border, text, selected background), as iOS `CYLTagColors`: AndroidTagView's
ColorFactory, from a theme, a random palette color, or your own.

- `export enum CYLTagColorTheme` (L9)
  AndroidTagView's `tag_theme`.

- `export class CYLTagColors` (L21)

- `static readonly backgroundAlpha: number = 0x33 / 255;` (L23)
  0x33 / 255.

- `static readonly borderAlpha: number = 0x88 / 255;` (L25)
  0x88 / 255.

- `static readonly paletteHexByName: Map<string, string> = new Map<string, string>(` (L27)
  ColorFactory's colors by name.

- `static fromPaletteHex(hex: string, textColor: string, selectedBackgroundColor: string): CYLTagColors` (L45)
  `hex` at 0x33 (background) and 0x88 (border).

- `static fromTheme(theme: CYLTagColorTheme, seed: number): CYLTagColors | undefined` (L51)
  The theme's colors (random: the palette color `seed`); undefined for none.

- `static random(): CYLTagColors` (L68)
  A random palette color.

- `styleByApplying(style?: CYLMenuStyle): CYLMenuStyle` (L73)
  A copy of `style` (the default style when undefined) with these colors; a border gets 1 vp when it had none.

## harmony/classifymenu/src/main/ets/core/CYLTagListCache.ets

The cache of a tag list's edited sections (iOS `CYLTagListCache.swift`), so an order changed in editing mode (a
drag), a deleted tag or an added one survives a relaunch: a database (`relationalStore`), the app's `preferences`
(NSUserDefaults on iOS) or a JSON file in the app's sandbox, behind one store.

- `export enum CYLTagListCachePolicy` (L12)
  `CYLTagListCachePolicy`: where the list keeps the titles of its edited sections (`cachePolicy`).

- `none = 0,` (L14)
  No cache (the default): edits live as long as the host's data.

- `database = 1,` (L16)
  A database of the app (`relationalStore`, `tags.db`).

- `userDefaults = 2,` (L18)
  The app's `preferences` (NSUserDefaults on iOS).

- `sandboxFile = 3` (L20)
  A JSON file in the app's sandbox (its files folder).

- `export interface CYLTagListCache` (L27)
  `CYLTagListCache`: a store of the ordered titles of a tag list's sections. The list makes the built-in store of its
  `cachePolicy`; implement this interface and set `cache` to use another store.

- `cachedTitles(section: string): string[] | undefined;` (L29)
  The titles saved for `section`, in order; undefined when nothing was saved for it.

- `saveTitles(titles: string[], section: string): void;` (L31)
  Saves `titles` (in this order) as the contents of `section`, replacing what was saved.

- `removeTitles(section: string): void;` (L33)
  Removes what was saved for `section`.

- `removeAllTitles(): void;` (L35)
  Removes every section of this cache.

- `cachedItems?: (section: string) => CYLTagListCacheItem[] | undefined;` (L37)
  `cachedItems(forSection:)`: the items saved for `section`, in order; undefined when none. Optional.

- `saveItems?: (items: CYLTagListCacheItem[], section: string) => void;` (L39)
  `saveItems(_:forSection:)`: saves `items` (in this order) as the contents of `section`. Optional.

- `export class CYLTagListCacheItem` (L46)
  `CYLTagListCacheItem`: one saved item of a tag list, its stable identifier (a database id; the title when the item
  has none) and its current title. A reorder or a rename keeps the identifier.

- `const CYL_ITEM_SEPARATOR: string = '\u001F';` (L61)
  The separator of an encoded "identifier<US>title" item (iOS `itemSeparator`).

- `const CYL_MEMORY: Map<string, Map<string, string[]>> = new Map<string, Map<string, string[]>>();` (L64)
  Every saved list: {list name: {section: titles}}. Shared by the stores of one process, as the storage is.

- `export class CYLTagListStore implements CYLTagListCache` (L73)
  `CYLTagListStore`: the built-in caches behind one class. `name` separates the caches of different lists (the database
  key, the preferences key or the file name). The app's context comes from the UI the list was shown in
  (`CYLUIContext`), or from `context`. Without a context (host unit tests) the titles live in memory for the process,
  as iOS keeps them in memory when its database cannot open. The database opens asynchronously: until it is open the
  store answers from memory, then it reads the saved rows once and writes through.

- `readonly policy: CYLTagListCachePolicy;` (L75)
  The policy of this store.

- `readonly name: string;` (L77)
  Separates the caches of different lists ("CYLTagListView" when empty).

- `static cache(policy: CYLTagListCachePolicy, name: string, context?: common.Context): CYLTagListStore | undefined` (L82)
  The store for `policy` and `name`; undefined for `CYLTagListCachePolicy.none`.

- `cachedItems = (section: string): CYLTagListCacheItem[] | undefined =>` (L128)
  `cachedItems(forSection:)`: the saved items; titles saved alone are their own identifiers.

- `saveItems = (items: CYLTagListCacheItem[], section: string): void =>` (L141)
  `saveItems(_:forSection:)`: the items in a companion section, the titles in the section itself.

- `export enum CYLTagListLoadPolicy` (L408)
  `CYLTagListLoadPolicy`: in what order `CYLTagListState.loadSectionsWithKeys` reads the cache and the remote source.
  Unlike a search suggestion cache, a tag list may be kept on a server and edited on several devices.

- `cacheThenNetwork = 0,` (L410)
  The cache at once, then the remote source; a successful download is saved and reported again (the default).

- `cacheFirst = 1,` (L412)
  The cache when it holds every section asked for; otherwise the remote source (the cache if that fails).

- `networkFirst = 2` (L414)
  The remote source; the cache only when the download fails.

- `export enum CYLTagListDataOrigin` (L418)
  `CYLTagListDataOrigin`: where the titles reported by `loadSectionsWithKeys` come from.

- `cache = 0,` (L420)
  The local cache (`cache`).

- `network = 1` (L422)
  The remote source (`remoteSource`).

- `export interface CYLTagListRemoteSource` (L430)
  `CYLTagListRemoteSource`: a server that keeps a tag list's sections, shared by the user's devices. The host implements
  it with its own networking; the list only asks it for sections (`loadSectionsWithKeys`). Uploading is the host's too:
  `menuDidFinishEditingWithTitles` / `editingFinishHandler` give it the edited sections.

- `fetchSectionsWithKeys(keys: string[], completion: (sections: Map<string, string[]> | undefined,` (L435)
  `fetchSections(withKeys:completion:)`: downloads the sections saved under `keys`; calls `completion` once with the
  titles by key (a missing key: nothing on the server) or an error.

- `fetchItemsWithKeys?: (keys: string[], completion: (items: Map<string, CYLTagListCacheItem[]> | undefined,` (L441)
  `fetchItems(withKeys:completion:)`: downloads the sections as items (stable identifier and title), for
  `loadItemsWithKeys`. Optional: without it, the titles are fetched and each title is its own identifier.

## harmony/classifymenu/src/main/ets/core/CYLTagListConfiguration.ets

The configuration keys and value readers of a tag list, as iOS `CYLTagListView+CYLConfiguration.swift`: a tag list
(and its style, fold control and tags) made from one dictionary, a JSON object. In code, values have their usual
types (a `CYLMenuStyle`, a `CYLMenuFoldControl`); in a file, strings work for every key (colors "#RRGGBB", insets
"{top, left, bottom, right}" or arrays, enum names...). The tag list part (`applyConfiguration`) is in
components/CYLTagListState.ets.

- `export type CYLConfiguration = Record<string, Object>;` (L20)
  A configuration dictionary: a parsed JSON object, or values of their own types set in code.

- `export class CYLTagListKey` (L25)
  The keys of a tag list configuration.

- `static readonly sections: string = 'sections';` (L27)
  An array of section dictionaries (`CYLTagSectionKey`).

- `static readonly style: string = 'style';` (L29)
  A `CYLMenuStyle`, or a dictionary of `CYLMenuStyleKey` keys.

- `static readonly selectionMode: string = 'selectionMode';` (L31)
  A `CYLMenuSelectionMode` raw value, or "none", "single", "multiple".

- `static readonly foldStyle: string = 'foldStyle';` (L33)
  A `CYLMenuFoldStyle` raw value, or "none", "headerButton", "footerChevron", "truncate".

- `static readonly longPressAction: string = 'longPressAction';` (L37)
  What a long press does: "reorder", "callout", "report" or "none", or an array of them (the first that can begin wins).

- `static readonly selectedItems: string = 'selectedItems';` (L41)
  An array of index paths ({section, item}), "section-item" strings or [section, item] arrays.

- `static readonly foldControl: string = 'foldControl';` (L43)
  A `CYLMenuFoldControl`, a position name, or a dictionary of `CYLMenuFoldControlKey` keys.

- `static readonly titlePosition: string = 'titlePosition';` (L46)
  A `CYLMenuTitlePosition` raw value, or "topLeading" ("leading", "left"), "topCenter" ("center").

- `static readonly titleStyle: string = 'titleStyle';` (L49)
  A `CYLMenuStyle`, or a dictionary applied over `CYLTagListState.defaultTitleStyle()`.

- `static readonly tags: string = 'tags';` (L51)
  An array of tags: strings (titles) or dictionaries of `CYLTagItemKey` keys.

- `export class CYLMenuFoldControlKey` (L55)
  The keys of a fold control configuration.

- `export class CYLTagSectionKey` (L67)
  The keys of a section dictionary.

- `static readonly items: string = 'items';` (L71)
  An array of item dictionaries, or of strings (titles).

- `static readonly style: string = 'style';` (L73)
  A `CYLMenuStyle`, or a dictionary applied over the list's style.

- `export class CYLTagItemKey` (L77)
  The keys of an item dictionary.

- `static readonly subtitle: string = 'subtitle';` (L80)
  A longer description, shown in a callout on a long press (`longPressAction` "callout").

- `static readonly animation: string = 'animation';` (L84)
  A Lottie animation: `asset:<rawfile path>`, or the JSON text.

- `static readonly animationOptions: string = 'animationOptions';` (L86)
  A dictionary of strings written into the animation URL (`cylAddingAnimationOptions`).

- `static readonly type: string = 'type';` (L91)
  A `CYLMenuItemType` raw value, or "tag" (default), "create" ("new").

- `export class CYLMenuStyleKey` (L98)
  The keys of a style dictionary.

- `static readonly titleMaxLines: string = 'titleMaxLines';` (L105)
  The most lines a title may take: a whole number, or "unlimited". Default 1.

- `static readonly headerMaxLines: string = 'headerMaxLines';` (L107)
  The most lines a section header's title may take: a whole number, or "unlimited". Default 1.

- `static readonly backgroundStyle: string = 'backgroundStyle';` (L125)
  A `CYLTagBackgroundStyle` raw value, or 'flat' / 'liquidGlass' (case-insensitive); anything else is flat.

- `static readonly minimumTagSize: string = 'minimumTagSize';` (L129)
  A size '{width, height}' in vp, or { width: 69, height: 29 }: `CYLMenuStyle.minimumTagSize`.

- `static readonly tintColor: string = 'tintColor';` (L135)
  The one color of the built-in views that are not tags (title, icon, fold / More control): `CYLMenuStyle.tintColor`.

- `static readonly sectionStyle: string = 'sectionStyle';` (L143)
  The section card: "plain" or "insetGrouped" (case-insensitive), or a `CYLSectionStyle` raw value.

- `static readonly sectionBackgroundStyle: string = 'sectionBackgroundStyle';` (L146)
  The card's background, as `backgroundStyle`: 'flat' or 'liquidGlass'; anything else is flat.

- `static readonly sectionBoardInset: string = 'sectionBoardInset';` (L150)
  The horizontal inset of the content column inside the board, one number for both sides; absent: the default 12.

- `static readonly headerBackgroundColor: string = 'headerBackgroundColor';` (L152)
  The header band's color; absent: no band.

- `static readonly headerSeparatorStyle: string = 'headerSeparatorStyle';` (L156)
  The header divider: "none" or "line" (case-insensitive), or a `CYLHeaderSeparatorStyle` raw value.

- `export class CYLTagAppearanceKey` (L163)
  The keys of an appearance dictionary.

- `export enum CYLMenuConfigurationErrorCode` (L179)
  Why a configuration file could not be read.

- `fileNotFound = 1,` (L181)
  No file at the path.

- `invalidContents = 2,` (L183)
  The file does not hold a dictionary.

- `unsupportedFormat = 3` (L185)
  The format is not JSON.

- `export class CYLMenuConfigurationError extends Error` (L188)

- `get errorUserInfo(): Record<string, string>` (L207)
  `NSLocalizedDescriptionKey`: the message.

- `const SF_SYMBOL_IMAGES: Map<string, Resource> = new Map<string, Resource>([` (L217)
  SF Symbols of the shared configurations and their nearest HarmonyOS system icons.

- `export class CYLConfigurationValue` (L227)

- `static color(value: Object | undefined | null): string | undefined` (L333)
  A '#AARRGGBB' color from a color string (`CYLMenuColorFromString`).

- `static font(value: Object | undefined | null): CYLFont | undefined` (L338)
  A font from a `CYLFont`, a size, or {size:, weight:} (weights map to the nearest ArkUI `FontWeight`).

- `static image(value: Object | undefined | null): CYLImage | undefined` (L371)
  An image: a `CYLImage` value, a core image name ("cyl_more"), or any other string as a path, a URL or a
  resource string. "system:<SF Symbol>": the nearest HarmonyOS system icon for the symbols the examples use
  (an icon-only item would otherwise be an empty chip), undefined for the others.

- `static rawValue(value: Object | undefined | null, names: Map<string, number>): number | undefined` (L390)
  An enum's raw value from a number or one of `names` (lowercased); undefined when it is neither.

- `static text(value: Object | undefined | null): string | undefined` (L406)
  A string value, or a number written as text.

- `export function cylAddingAnimationOptions(animation: string, options: CYLConfiguration): string` (L422)
  `URL.cylAddingAnimationOptions(_:)`: the animation with options in its fragment ("name=value&…", percent-encoded
  and sorted by name), as CYLTabBarController's CYLTabBarAnimationURLWithOptions(); the animation itself without
  options.

- `const FOLD_POSITIONS: Map<string, number> = new Map<string, number>([` (L442)
  Position names of a fold control.

- `export class CYLMenuConfiguration` (L479)

- `static applyToFoldControl(control: CYLMenuFoldControl, configuration: CYLConfiguration): void` (L481)
  `CYLMenuFoldControl.applyConfiguration(_:)`: missing keys keep their values.

- `static foldControl(configuration: Object | undefined | null): CYLMenuFoldControl | undefined` (L522)
  `CYLMenuFoldControl.init?(configuration:)`: from a dictionary, or from a position name or raw value alone (an icon
  in the footer, an icon and a title elsewhere); undefined for anything else.

- `static applyToAppearance(appearance: CYLTagAppearance, configuration: CYLConfiguration): void` (L547)
  `CYLTagAppearance.applyConfiguration(_:)`: missing keys keep their values; a key whose value is not a color, font
  or image restores the default (or clears an optional one).

- `static style(configuration: CYLConfiguration): CYLMenuStyle` (L593)
  `CYLMenuStyle.init(configuration:)`: a default style with the configuration's values.

- `static applyToStyle(style: CYLMenuStyle, configuration: CYLConfiguration): void` (L600)
  `CYLMenuStyle.applyConfiguration(_:)`: missing keys keep their values.

- `static tag(configuration: CYLConfiguration): CYLTag` (L804)
  `CYLTag.init(configuration:)`: title, image, selectedImage, animation, id, enabled, deletable, style.

## harmony/classifymenu/src/main/ets/core/CYLTagLongPressAction.ets

What a long press on an item does (CYLTagListView.longPressAction). The list owns the gesture; an action owns the
behavior: reordering, a callout with the item's subtitle, or the host's own code. The events (`menuDidLongPressItem`,
`tagLongPressHandler`) stay notifications: they are reported by the built-in actions and never change the behavior.
  list.longPressAction = CYLTagLongPressActions.first([CYLTagLongPressActions.reorder, CYLTagLongPressActions.callout]);
  list.longPressAction = CYLTagLongPressActions.handler((host, indexPath) => host.showCallout('My text', indexPath));
The default is `first([reorder, report])`: reordering where the list can reorder, else the long press is reported,
exactly as before this API existed.

- `export interface CYLTagLongPressHost` (L13)
  The list as an action sees it: the primitives the built-in and the custom actions are made of.

- `subtitleForItem(indexPath: CYLIndexPath): string | undefined;` (L15)
  The item's subtitle from the data source (`menuSubtitleForItem`), or undefined.

- `showCallout(text: string, indexPath: CYLIndexPath): void;` (L18)
  Shows a small callout with an arrow, pointing at the item, with `text`. Replaces a callout that is showing.

- `dismissCallout(): void;` (L21)
  Hides the callout.

- `canReorderItem(indexPath: CYLIndexPath): boolean;` (L24)
  Whether the list can reorder its items now (`allowsReordering` or editing, and a data source that moves items).

- `beginReordering(indexPath: CYLIndexPath): void;` (L27)
  Starts reordering with the item picked up (a selected item's drag is reported).

- `endReordering(destination: CYLIndexPath | undefined, moved: boolean): void;` (L33)
  Ends reordering: the data source moves the item to `destination` when `moved`; a press that did not move is
  reported as a long press.

- `cancelReordering(): void;` (L36)
  Ends reordering without moving anything.

- `reportLongPress(indexPath: CYLIndexPath): void;` (L39)
  Reports a long press: `menuDidLongPressItem`, then `tagLongPressHandler`.

- `export interface CYLTagLongPressAction` (L43)
  What a long press on an item does.

- `canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean;` (L45)
  Whether this action takes the press on this item (reorder: the list can reorder; callout: the item has a subtitle).

- `begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean;` (L48)
  The press was recognized. Returns true to follow the finger; `end` or `cancel` then arrive.

- `end?(host: CYLTagLongPressHost, destination: CYLIndexPath | undefined, moved: boolean): void;` (L51)
  The finger lifted over `destination` (undefined: outside the list); `moved` tells whether it left the item.

- `cancel?(host: CYLTagLongPressHost): void;` (L54)
  The gesture was cancelled.

- `export type CYLTagLongPressHandler = (host: CYLTagLongPressHost, indexPath: CYLIndexPath) => void;` (L58)
  A custom long-press behavior: a closure.

- `class CYLTagReorderAction implements CYLTagLongPressAction` (L60)

- `class CYLTagReportAction implements CYLTagLongPressAction` (L79)

- `class CYLTagCalloutAction implements CYLTagLongPressAction` (L90)

- `class CYLTagNoneAction implements CYLTagLongPressAction` (L106)

- `class CYLTagHandlerAction implements CYLTagLongPressAction` (L116)

- `class CYLTagFirstAction implements CYLTagLongPressAction` (L134)
  The first action of a list whose `canBegin` passes takes the press; it also receives the end and the cancel.

- `export class CYLTagLongPressActions` (L176)
  The built-in long-press actions, and the ways to combine them or write your own.

- `static readonly reorder: CYLTagLongPressAction = new CYLTagReorderAction();` (L178)
  Picks the item up to reorder it, where the list can reorder (the data source moves the item).

- `static readonly report: CYLTagLongPressAction = new CYLTagReportAction();` (L181)
  Only reports the long press (`menuDidLongPressItem`, `tagLongPressHandler`).

- `static readonly callout: CYLTagLongPressAction = new CYLTagCalloutAction();` (L184)
  Shows the item's subtitle in a callout with an arrow, where the item has one, and reports the long press.

- `static readonly none: CYLTagLongPressAction = new CYLTagNoneAction();` (L187)
  Does nothing (not even a report).

- `static handler(handler: CYLTagLongPressHandler): CYLTagLongPressAction` (L190)
  Runs `handler` instead of a built-in behavior; it can use the host's primitives, such as `showCallout`.

- `static first(actions: CYLTagLongPressAction[]): CYLTagLongPressAction` (L195)
  The first of `actions` that can begin takes the press, as "reorder where editable, a callout elsewhere".

- `static makeDefault(): CYLTagLongPressAction` (L200)
  The default of a list: `first([reorder, report])`, the behavior before this API existed.

## harmony/classifymenu/src/main/ets/core/CYLTagMetrics.ets

The font scale limit and the tag height of the core, as iOS `CYLTagMetrics`: titles scale with the system font
size up to `maximumFontScale`, and a tag is never shorter than its title line plus the vertical padding.

- `const VERTICAL_PADDING: number = 10;` (L8)
  The vertical padding of a tag around its title line (iOS `verticalPadding`).

- `const LINE_HEIGHT_RATIO: number = 1.2;` (L10)
  The line height of the system font per point of size (SF's `lineHeight` / `pointSize`).

- `export class CYLTagMetrics` (L12)

- `static readonly maximumFontScale: number = 2;` (L14)
  The largest font scale a tag title takes.

- `static readonly titleFontSize: number = 16;` (L16)
  The default title size, fp.

- `static scaledSystemFont(size: number, fontScale: number = 1): CYLFont` (L19)
  A system font of `size` scaled by `fontScale` (the system font scale), up to `maximumFontScale`.

- `static tagHeight(font: CYLFont, minimumHeight: number): number` (L24)
  The height of a tag with `font`: its line height plus the vertical padding, at least `minimumHeight`.

- `static titleFont(fontScale: number = 1): CYLFont` (L29)
  The default title font at `fontScale`.

## harmony/classifymenu/src/main/ets/core/CYLTagModel.ets

The tag models of the TagCollectionView demo, as iOS `CYLTagModel.swift` and `CYLTagGroup.swift`: a title sized
with the 17 pt system font (plus 50 vp of padding), and a group of them laid out in rows of `CYLTagView`'s width.

- `export const CYLTagViewSectionInset: CYLEdgeInsets = new CYLEdgeInsets(12, 16, 10, 16);` (L15)
  `CYLTagView.sectionInset`: the insets of the tag view's sections.

- `export const CYLTagViewCellSpacing: number = 12;` (L17)
  `CYLTagView.cellSpacing`: the spacing between tags and rows.

- `export const CYLTagDefaultListWidth: number = 360;` (L19)
  The width a group lays out in when it has none (iOS: the screen width), vp.

- `export class CYLTagModel` (L21)

- `static titleFont(fontScale: number = 1): CYLFont` (L49)
  The title font at the system font scale `fontScale`.

- `updateSize(fontScale: number = 1): void` (L54)
  Measures the title: its width plus the padding, and the tag height of the font.

- `export class CYLTagGroup` (L62)

- `get cellCountsPerRow(): number[]` (L81)
  The number of tags in each row at the group's width.

## harmony/classifymenu/src/main/ets/core/CYLTypes.ets

The ArkTS forms of the UIKit value types the iOS API uses. Lengths are vp and font sizes fp, as points on iOS.
Colors are '#AARRGGBB' strings, which ArkUI takes as a ResourceColor; the tag's colors (`CYLTagAppearance`,
`CYLTagButton`) also take any other `ResourceColor`, such as a theme color (`$r('sys.color.font_primary')`) that
follows the color mode.

- `export class CYLEdgeInsets` (L14)
  `UIEdgeInsets`.

- `export class CYLSize` (L37)
  `CGSize`.

- `export class CYLOffset` (L51)
  `UIOffset`.

- `export class CYLPoint` (L65)
  `CGPoint`.

- `export class CYLRect` (L78)
  `CGRect`.

- `export class CYLFont` (L107)
  `UIFont`: a size in fp and a weight.

- `bold(): CYLFont` (L123)
  The same font in bold (Bold Text).

- `static systemFont(size: number): CYLFont` (L134)
  `UIFont.systemFont(ofSize:)`.

- `static boldSystemFont(size: number): CYLFont` (L141)
  `UIFont.boldSystemFont(ofSize:)`.

- `export class CYLControlState` (L149)
  `UIControl.State`: bit flags, `NORMAL` being none of them.

- `export class CYLColor` (L168)
  Colors as '#AARRGGBB', the ArkTS form of `UIColor`.

- `static readonly APP_TINT: string = '#FF2AB9A0';` (L172)
  `CYLAppTintColor` (42, 185, 160).

- `static white(white: number, alpha: number = 1): string` (L181)
  `UIColor(white:alpha:)`.

- `static rgb(red: number, green: number, blue: number, alpha: number = 1): string` (L188)
  `UIColor(red:green:blue:alpha:)` with components 0...1.

- `static argb(alpha: number, red: number, green: number, blue: number): string` (L195)
  Bytes 0...255.

- `static withAlpha(color: string, alpha: number): string` (L202)
  `withAlphaComponent(_:)` of a '#AARRGGBB' or '#RRGGBB' color.

- `static readonly IDENTITY_FILTER: number[] = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];` (L208)
  The color filter that leaves an image unchanged.

- `static tintFilter(color: ResourceColor): number[]` (L217)
  The color filter (`Image.colorFilter`) that paints every pixel of an image in `color`, keeping the pixel's alpha:
  the template rendering of iOS (`UIImage.withRenderingMode(.alwaysTemplate)` tinted by `tintColor`), for bitmaps,
  which `fillColor` does not recolor (it only colors SVG and symbol images). It is the filter of the shared component,
  `cylIconColorFilter` of `CYLAnimatedItemView.iconColor` (CYLTabBarController PR #816), so the tag's own icon and the
  component's static image are tinted alike; the identity for a theme resource or a named color, which cannot be read.

- `static fromHex(hex: string | undefined, alpha: number = 1): string | undefined` (L224)
  A "RRGGBB" or "#RRGGBB" hex string with `alpha`, or undefined when it does not parse.

- `export type CYLImage = ResourceStr | image.PixelMap;` (L239)
  `UIImage`: a resource, a path, or a drawn pixel map (a badge).

- `export const CYLResourceTypeSymbol: number = 40000;` (L244)
  `ResourceType.SYMBOL`: the type of a system symbol resource (`$r('sys.symbol.camera')`), a HarmonyOS Symbol glyph.

- `export function CYLImageIsSymbol(image: CYLImage | undefined): boolean` (L250)
  Whether `image` is a system symbol (`$r('sys.symbol.camera')`): `SymbolGlyph` draws it, tinted with its font color;
  an `Image` does not draw it. Pixel images, rawfiles, paths and pixel maps are not symbols.

- `export function CYLColorKey(color: ResourceColor | undefined): string` (L262)
  A text that tells two colors apart, for render keys: the string itself, a number (a `Color` or ARGB value), or a
  resource's id; '' for undefined.

## harmony/classifymenu/src/main/ets/core/CYLUIContext.ets

- `export class CYLUIContext` (L13)
  The UI context the library's model code measures with.
  Model classes (tags, layouts) have no component and so no `getUIContext()`. The library's components call
  `CYLUIContext.remember(this.getUIContext())` when they appear. Until then, and in unit tests, sizes come from the default display's density and text from an
  offscreen canvas.

- `static remember(context: UIContext | undefined): void` (L19)
  Keeps `context` for later measurements.

- `static get hasContext(): boolean` (L28)
  Whether a UI context has been remembered (measurements before it use the canvas fallback).

- `static hostContext(ui?: UIContext): common.UIAbilityContext` (L36)
  The context of the ability that shows `ui` (or the remembered UI context): `getHostContext()` from API 18, the
  global `getContext()` on API 12 to 17, where the replacement does not exist yet.

- `static density(): number` (L51)
  The density of the default display (px per vp), 1 without a display.

- `static px2vp(px: number): number` (L63)
  Converts physical pixels to vp.

- `static vp2px(vp: number): number` (L73)
  Converts vp to physical pixels.

- `static measureTextWidth(options: MeasureOptions, fontSize: number, fontWeight: number | FontWeight | string = 400): number` (L83)
  The width of one line of `options.textContent`, in vp.

- `static measureTextSize(options: MeasureOptions, fontSize: number, fontWeight: number | FontWeight | string = 400,` (L96)
  The size of `options.textContent` wrapped at `options.constraintWidth`, in vp.

