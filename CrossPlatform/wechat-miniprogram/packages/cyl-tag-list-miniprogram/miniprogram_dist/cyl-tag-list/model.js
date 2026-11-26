/**
 * The model of the Mini Program `cyl-tag-list` component: the configuration dictionary of the core's
 * `CYLTagListView(configuration:)` (the keys of CYLTagListView+CYLConfiguration.swift, read by the same rules: strings
 * work for every value), the selection rules of `CYLTagListView.handleTap(at:)` / `applySelection(of:)`, the folding of
 * `defaultVisibleRows` and the layout of one tag (`CYLTagButton.layoutSubviews`, `width(forTitle:…)`) turned into CSS.
 * It has no `wx` calls, so it runs under Node in the tests.
 *
 * An item is addressed by its key "<section>-<item>", the format of `selectedItems` on every platform.
 */
const symbols = require('./symbols.js');
const locale = require('../locale.js');
const { cylAnimatedItemType, cylAnimatedItemSource } = require('../cyl-animated-item/cyl_animated_item_model');
// The rule for Liquid Glass of CYLTabBarController's cyl-animated-item (the same as iOS CYLAnimatedItemView.isLiquidGlassActive()).
const {
  cylAnimatedItemBackground, cylAnimatedItemCornerRadiusCapsule, cylAnimatedItemLiquidGlassContentInset, cylAnimatedItemLiquidGlassIsActive
} = require('../cyl-animated-item/cyl_animated_item_model');

// MARK: - Values (CYLConfigurationValue)

/** UIColor names a configuration may use ("systemBlue" or "systemBlueColor"), with their light-mode values. */
const NAMED_COLORS = {
  systemBlue: '#007AFF', systemGreen: '#34C759', systemIndigo: '#5856D6', systemOrange: '#FF9500',
  systemPink: '#FF2D55', systemPurple: '#AF52DE', systemRed: '#FF3B30', systemTeal: '#30B0C7',
  systemYellow: '#FFCC00', systemGray: '#8E8E93', systemBrown: '#A2845E', systemCyan: '#32ADE6',
  systemMint: '#00C7BE', label: '#000000', secondaryLabel: 'rgba(60, 60, 67, 0.6)', separator: 'rgba(60, 60, 67, 0.29)',
  black: '#000000', white: '#FFFFFF', gray: '#808080', darkGray: '#555555', lightGray: '#AAAAAA', red: '#FF0000',
  green: '#00FF00', blue: '#0000FF', orange: '#FF8000', yellow: '#FFFF00', purple: '#800080', clear: 'rgba(0, 0, 0, 0)',
};

/** A CSS color from "#RGB", "#RRGGBB", "#RRGGBBAA" (as `UIColor.cylMenuColor(from:)`), rgb()/rgba() or a UIColor name; null otherwise. */
function color(value) {
  if (typeof value !== 'string') return null;
  const text = value.trim();
  if (text.startsWith('#')) {
    let hex = text.slice(1);
    if (hex.length === 3) hex = hex.split('').map((c) => c + c).join('');
    if (!/^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(hex)) return null;
    if (hex.length === 6) return `#${hex.toUpperCase()}`;
    const [r, g, b, a] = [0, 2, 4, 6].map((i) => parseInt(hex.slice(i, i + 2), 16));
    return `rgba(${r}, ${g}, ${b}, ${Number((a / 255).toFixed(3))})`;
  }
  if (/^rgba?\(/i.test(text)) return text;
  const name = text.replace(/Color$/, '');
  return NAMED_COLORS[name] || null;
}

/** A number from a number or a string ("true"/"yes"/"on" are 1, as `CYLConfigurationValue.number`); null otherwise. */
function numberValue(value) {
  if (typeof value === 'number') return Number.isFinite(value) ? value : null;
  if (typeof value === 'boolean') return value ? 1 : 0;
  if (typeof value !== 'string') return null;
  const text = value.trim().toLowerCase();
  if (['true', 'yes', 'on'].includes(text)) return 1;
  if (['false', 'no', 'off'].includes(text)) return 0;
  if (text === '') return null;
  const n = Number(text);
  return Number.isFinite(n) ? n : null;
}

function boolValue(value) {
  const n = numberValue(value);
  return n === null ? null : n !== 0;
}

/** `count` numbers from an array or a string such as "{1, 2}" or "[1, 2]"; null otherwise. */
function numbers(value, count) {
  let parts;
  if (Array.isArray(value)) parts = value;
  else if (typeof value === 'string') parts = value.replace(/[{}[\]]/g, '').split(',');
  else return null;
  if (parts.length !== count) return null;
  const result = parts.map(numberValue);
  return result.some((n) => n === null) ? null : result;
}

/** "{top, left, bottom, right}", [t, l, b, r] or {top, left, bottom, right} → insets; null otherwise. */
function insetsValue(value) {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return {
      top: numberValue(value.top) || 0, left: numberValue(value.left) || 0,
      bottom: numberValue(value.bottom) || 0, right: numberValue(value.right) || 0,
    };
  }
  const n = numbers(value, 4);
  return n ? { top: n[0], left: n[1], bottom: n[2], right: n[3] } : null;
}

/** "{w, h}", [w, h], {width, height} or one number (a square) → {width, height}; null otherwise. */
function sizeValue(value) {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return { width: numberValue(value.width) || 0, height: numberValue(value.height) || 0 };
  }
  const side = numberValue(value);
  if (side !== null) return { width: side, height: side };
  const n = numbers(value, 2);
  return n ? { width: n[0], height: n[1] } : null;
}

/** "{horizontal, vertical}", [h, v] or {horizontal, vertical} → an offset; null otherwise. */
function offsetValue(value) {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return { horizontal: numberValue(value.horizontal) || 0, vertical: numberValue(value.vertical) || 0 };
  }
  const n = numbers(value, 2);
  return n ? { horizontal: n[0], vertical: n[1] } : null;
}

// The default section header font: the system table header look, 17 semibold (docs/tag-section-style.md).
const HEADER_FONT_SIZE = 17;
const HEADER_FONT_WEIGHT = 'semibold';

const FONT_WEIGHTS = {
  ultralight: 100, thin: 200, light: 300, regular: 400, medium: 500, semibold: 600, bold: 700, heavy: 800, black: 900,
};

/** A font from a number (the system font of that size) or {size, weight, italic, name} (`CYLConfigurationValue.font`). */
function fontValue(value) {
  const size = numberValue(value);
  if (size !== null) return { size, weight: 'regular', italic: false };
  if (!value || typeof value !== 'object') return null;
  const pointSize = numberValue(value.size) || 14;
  const weight = typeof value.weight === 'string' && FONT_WEIGHTS[value.weight.toLowerCase()] ? value.weight.toLowerCase() : 'regular';
  return { size: pointSize, weight, italic: boolValue(value.italic) === true, name: typeof value.name === 'string' ? value.name : '' };
}

/** The iOS name of a system font, as `UIFont.fontName` reports it (".SFUI-Semibold", ".SFUI-RegularItalic"). */
function fontName(font) {
  const weight = font.weight.charAt(0).toUpperCase() + font.weight.slice(1);
  return font.name || `.SFUI-${weight}${font.italic ? 'Italic' : ''}`;
}

/** "{18, 18}" (the core's CGSize string) or 18 → 18 (the width). */
function imageSize(value) {
  const size = sizeValue(value);
  return size ? size.width : DEFAULT_STYLE.imageSize;
}

/** "{top, left, bottom, right}" (the core's UIEdgeInsets string), [t, l, b, r] or {top, left, bottom, right}. */
function insets(value, fallback) {
  if (value && typeof value === 'object' && !Array.isArray(value)) return insetsValue(value);
  return insetsValue(value) || { ...fallback };
}

// MARK: - Style (CYLMenuStyle, CYLTagAppearance)

/** UIColor(white: 0.25) and the other gray levels of the core's defaults. */
const DEFAULT_TEXT_COLOR = '#404040';
const APP_TINT_COLOR = '#2AB9A0';
/**
 * A tag's background is never transparent (nor white on the white list, which looks the same): the default fill is
 * UIKit's systemGray6, and a configured clear / transparent / zero-alpha background falls back to it.
 */
const DEFAULT_TAG_BACKGROUND = '#F2F2F7';
/**
 * The line limits of a tag's title (style key `titleMaxLines`): named values, never a literal at a call site.
 * `single` is the default (a title too wide is truncated); `unlimited` shows every line.
 */
const TITLE_MAX_LINES = { single: 1, unlimited: Number.MAX_SAFE_INTEGER };
/**
 * The line limits of a section header's title (style key `headerMaxLines`), the same named values as a tag's title:
 * `single` (the default) keeps the one-line header with an ellipsis; a larger number or `unlimited` wraps the title and
 * the header's height becomes a minimum.
 */
const HEADER_TITLE_MAX_LINES = { single: 1, unlimited: Number.MAX_SAFE_INTEGER };
/** The padding above and below a header title that may wrap (px): half of the 12 the header height adds to a line. */
const HEADER_WRAP_VERTICAL_PADDING = 6;

/**
 * The reading direction of the list (style key `direction`): `ltr` is the default, `rtl` mirrors the section views
 * (CSS `direction: rtl` on the list and the leading / trailing distances of the layout). `auto` should follow the system
 * language, but this component has no language-direction helper yet, so `auto` is `ltr`.
 */
const DIRECTIONS = { ltr: 'ltr', rtl: 'rtl', auto: 'auto' };
const DEFAULT_DIRECTION = DIRECTIONS.ltr;

/**
 * The fold / More control's font (px): the mini program's text scales with the system font size, so the control's font is
 * `min(size, FOLD_CONTROL_MAX_FONT_SIZE)`: unchanged below the cap, never larger than it. 13 is the header and footer control's size.
 */
const FOLD_CONTROL_FONT_SIZE = 13;
const FOLD_CONTROL_MAX_FONT_SIZE = 20;

/**
 * The header room model (docs/tag-section-style.md). INNER WIDTH is the header's content box (the tag column: the list width
 * minus the header edges). Every two adjacent header views are HEADER_ITEM_SPACING px apart (the fold control's margin on its
 * leading side; 12 is what the control's padding was, so the default look is unchanged). The fold control is at most
 * HEADER_FOLD_ALONE_MAX_FRACTION of the inner width, or HEADER_FOLD_SHARED_MAX_FRACTION when More, a clear button or an
 * accessory also shows (this component's header has none of those, so the alone value applies). The section title takes what
 * is left, never less than HEADER_TITLE_MIN_EM of the header font (and at least HEADER_TITLE_MIN_WIDTH_PX).
 */
const HEADER_ITEM_SPACING = 12;
const HEADER_FOLD_ALONE_MAX_FRACTION = 0.4;
const HEADER_FOLD_SHARED_MAX_FRACTION = 0.3;
const HEADER_TITLE_MIN_EM = 1;
const HEADER_TITLE_MIN_WIDTH_PX = 1;
/** The percent of a fraction, for CSS (rounded so that 0.3 gives 30, not 30.000000000000004). */
const PERCENT_PER_FRACTION = 100;
const PERCENT_PRECISION = 1000;

/**
 * Dark mode, as iOS's dynamic defaults: a tag's fill is the secondary system background (#1C1C1E), its title the primary
 * label (white), and the list's own texts and icons (header title, fold controls) one tint, `UIColor.label` (black in
 * light mode, white in dark mode). A color a configuration sets wins in both modes.
 */
const DARK_TAG_BACKGROUND = '#1C1C1E';
const DARK_TEXT_COLOR = '#FFFFFF';
const LIGHT_TINT = '#000000';

/**
 * The section style (docs/tag-section-style.md): the names of style keys `sectionStyle` and `headerSeparatorStyle`, the named
 * lengths (px) and the colors of each color mode. The default is the rounded card (`insetGrouped`), no band, no divider;
 * `sectionStyle: 'plain'` reproduces the layout of before the card was the default.
 */
const SECTION_STYLES = { plain: 'plain', insetGrouped: 'insetGrouped' };
/** The style of a list that sets nothing: the rounded section card. An app opts out with the style key `sectionStyle: 'plain'`. */
const DEFAULT_SECTION_STYLE = SECTION_STYLES.insetGrouped;
const HEADER_SEPARATOR_STYLES = { none: 'none', line: 'line' };
const SECTION_METRICS = { cardCornerRadius: 10, cardPadding: 12, headerBandPadding: 12, separatorThickness: 0.5 };
/**
 * Under the board (insetGrouped) with no header divider the header is sized to its text (docs/tag-section-style.md, "The gap
 * between the header and the board is short when there is no divider"): the title's line height plus this padding (px; half
 * above, half below), and never less than the fold / More control, which CSS min-height gives for free.
 */
const HEADER_BOARD_TITLE_PADDING = 8;
/** The distance (px) from such a header's bottom to the board's top, instead of the section's top inset. */
const HEADER_BOARD_SPACING = 4;
/** The card's background: the solid color, or the glass of cyl-animated-item's tags (style key `sectionBackgroundStyle`). */
const SECTION_BACKGROUND_STYLES = { flat: 'flat', liquidGlass: 'liquidGlass' };
/**
 * Card: white / #1C1C1E; header band: #EFEFF4 / #2C2C2E; grouped list background: #F2F2F7 / black; divider: the system separator;
 * `listBackground`: the default list background (the system background: white in light mode, black in dark mode).
 */
const SECTION_COLORS = {
  light: {
    card: '#FFFFFF', headerBand: '#EFEFF4', groupedBackground: '#F2F2F7', listBackground: '#FFFFFF', separator: 'rgba(60, 60, 67, 0.29)',
  },
  dark: {
    card: '#1C1C1E', headerBand: '#2C2C2E', groupedBackground: '#000000', listBackground: '#000000', separator: 'rgba(84, 84, 88, 0.6)',
  },
};
const ZERO_INSETS = { top: 0, left: 0, bottom: 0, right: 0 };

/**
 * The default tint of the built-in views that are not tags (header title, fold / More control: text, icon, arrow) is
 * chosen against the opaque background really behind them, black or white by relative luminance (WCAG): the one
 * threshold is where black and white text have the same contrast (about 0.179). Without such a background it is the
 * system mode's (black in light, white in dark). Style key `tintColor` wins in both modes.
 */
const TINT_LUMINANCE_THRESHOLD = 0.179;
const TINT_ON_LIGHT = '#000000';
const TINT_ON_DARK = '#FFFFFF';
/** The alpha from which a background counts as opaque. */
const OPAQUE_ALPHA = 1;
const RGB_MAX = 255;

/**
 * A background that may be transparent (style key `allowsTransparentBackground`): `transparent`, `clear` and zero alpha
 * are kept as `transparent`; a missing or invalid color is still the default tag fill.
 */
function tagBackground(value) {
  const text = typeof value === 'string' ? value.trim().toLowerCase() : '';
  if (text === 'transparent') return 'transparent';
  const parsed = color(value);
  if (!parsed) return DEFAULT_TAG_BACKGROUND;
  const alpha = /^rgba\([^)]*,\s*([\d.]+)\s*\)$/i.exec(parsed);
  return alpha && Number(alpha[1]) === 0 ? 'transparent' : parsed;
}

/** The color, or the default tag fill when it is missing, invalid or fully transparent. */
function opaqueBackground(value) {
  const text = typeof value === 'string' ? value.trim().toLowerCase() : '';
  const parsed = text === 'transparent' ? null : color(value);
  if (!parsed) return DEFAULT_TAG_BACKGROUND;
  const alpha = /^rgba\([^)]*,\s*([\d.]+)\s*\)$/i.exec(parsed);
  return alpha && Number(alpha[1]) === 0 ? DEFAULT_TAG_BACKGROUND : parsed;
}

/**
 * Whether a configured background is an explicit color of the app or a preset: a valid color that is not fully transparent.
 * An unset, invalid, `transparent` or zero-alpha background falls back to the default fill, which is never explicit.
 */
function isExplicitBackground(value) {
  const text = typeof value === 'string' ? value.trim().toLowerCase() : '';
  const parsed = text === 'transparent' ? null : color(value);
  if (!parsed) return false;
  const alpha = /^rgba\([^)]*,\s*([\d.]+)\s*\)$/i.exec(parsed);
  return !(alpha && Number(alpha[1]) === 0);
}

function defaultAppearance(hairline, dark = false) {
  return {
    backgroundColor: dark ? DARK_TAG_BACKGROUND : DEFAULT_TAG_BACKGROUND,
    // True when the state's background is the app's / a preset's color (the selected tint is): under Liquid Glass only an explicit
    // background is handed to the glass, an unset one leaves the component's default frosted tint (docs/tag-liquid-glass.md).
    backgroundExplicit: false,
    textColor: dark ? DARK_TEXT_COLOR : DEFAULT_TEXT_COLOR,
    font: { size: 14, weight: 'regular', italic: false },
    iconColor: null,
    cornerRadius: cylAnimatedItemCornerRadiusCapsule,
    borderColor: null,
    borderWidth: 0,
    // True when the app / a configuration / a preset set the border color (width): under drawn Liquid Glass only an explicit border is
    // handed to the glass, the built-in default border is dropped so the shared glass rim shows (docs/tag-liquid-glass.md).
    borderColorExplicit: false,
    borderWidthExplicit: false,
    contentInsets: { top: 5, left: 10, bottom: 5, right: 10 },
    backgroundImage: '',
    hairline,
  };
}

/** The value of a name table (case-insensitive; the raw values 0 and 1 count), or null. */
function namedValue(value, names) {
  const text = String(value).toLowerCase();
  const found = Object.keys(names).find((k) => k.toLowerCase() === text);
  if (found) return names[found];
  const raw = Object.values(names)[Number(text)];
  return Number.isInteger(Number(text)) && text.trim() !== '' && raw ? raw : null;
}

/** The section card, header band and header divider keys of `mergeStyle`. */
function mergeSectionStyle(style, c) {
  const sectionStyle = namedValue(c.sectionStyle, SECTION_STYLES);
  if (sectionStyle) style.sectionStyle = sectionStyle;
  // As `backgroundStyle`: 'flat' or 'liquidGlass' (case-insensitive, or 0 / 1); anything else keeps the style.
  const cardBackground = namedValue(c.sectionBackgroundStyle, SECTION_BACKGROUND_STYLES);
  if (cardBackground) style.sectionBackgroundStyle = cardBackground;
  const separatorStyle = namedValue(c.headerSeparatorStyle, HEADER_SEPARATOR_STYLES);
  if (separatorStyle) style.headerSeparatorStyle = separatorStyle;
  ['sectionBackgroundColor', 'headerBackgroundColor', 'headerSeparatorColor', 'tintColor'].forEach((k) => {
    const value = color(c[k]);
    if (value) style[k] = value;
  });
  ['sectionCornerRadius', 'headerCornerRadius', 'headerSeparatorThickness'].forEach((k) => {
    const n = numberValue(c[k]);
    if (n !== null) style[k] = Math.max(0, n);
  });
  // The horizontal inset of the content column inside the board: a negative value is 0, anything unparsable stays unset.
  const boardInsetValue = numberValue(c.sectionBoardInset);
  if (boardInsetValue !== null) style.sectionBoardInset = Math.max(0, boardInsetValue);
  ['sectionContentInsets', 'headerContentInsets', 'headerSeparatorInsets'].forEach((k) => {
    const value = insetsValue(c[k]);
    if (value) style[k] = value;
  });
}

/**
 * The core's `CYLMenuStyle()`: gray bordered tags (a hairline of UIColor(white: 0.82)), green selection with white
 * titles, light gray disabled tags; 14 × 14 icons, 4 between icon and title, 30 high tags, 10 between tags and lines,
 * section insets {10, 16, 10, 16}, 36 high headers with a 17 pt semibold title.
 * @param {number} pixelRatio the screen scale, for the hairline (1 / scale)
 * @param {boolean} dark dark mode: the dark tag fill and title, the light tint of the list's texts and icons
 */
function defaultStyle(pixelRatio = 2, dark = false) {
  const hairline = 1 / Math.max(1, pixelRatio || 1);
  const normal = { ...defaultAppearance(hairline, dark), borderColor: '#D1D1D1', borderWidth: hairline };
  const selected = {
    ...defaultAppearance(hairline, dark), backgroundColor: APP_TINT_COLOR, backgroundExplicit: true, textColor: '#FFFFFF', borderColor: APP_TINT_COLOR,
    borderWidth: hairline,
  };
  const disabled = { ...defaultAppearance(hairline, dark), textColor: '#B3B3B3', borderColor: '#E0E0E0', borderWidth: hairline };
  return finishStyle({
    normal, selected, disabled,
    imageTitleSpacing: 4,
    itemHeight: 30,
    titleMaxLines: TITLE_MAX_LINES.single,
    itemsPerRow: 0,
    interitemSpacing: 10,
    lineSpacing: 10,
    headerHeight: 36,
    // True once a configuration sets `headerHeight`: a header sized to its text takes it as its minimum only then.
    headerHeightSet: false,
    animationSpeed: 1,
    layoutCentered: true,
    imagePlacement: 'leading',
    contentAlignment: 'center',
    // 'flat', or 'liquidGlass' (a glass background where cyl-animated-item's rule is active, flat elsewhere); the smallest tag, points.
    backgroundStyle: 'flat',
    minimumTagSizeWH: { width: 0, height: 0 },
    imageSizeWH: { width: 14, height: 14 },
    animationSizeWH: { width: 0, height: 0 },
    imageInsets: { top: 0, left: 0, bottom: 0, right: 0 },
    sectionInsets: { top: 10, left: 16, bottom: 10, right: 16 },
    titlePositionAdjustment: { horizontal: 0, vertical: 0 },
    imagePositionAdjustment: { horizontal: 0, vertical: 0 },
    backgroundColor: '#FFFFFF',
    // True once a configuration sets `backgroundColor`: under insetGrouped an unset one is the grouped background.
    backgroundColorSet: false,
    // The section style (null colors resolve to `sectionPalette`, which follows the color mode).
    sectionPalette: { ...(dark ? SECTION_COLORS.dark : SECTION_COLORS.light), dark: !!dark },
    // The rounded section card is the default look (docs/tag-section-style.md); `plain` is the opt-out.
    sectionStyle: DEFAULT_SECTION_STYLE,
    sectionBackgroundColor: null,
    sectionBackgroundStyle: SECTION_BACKGROUND_STYLES.flat,
    sectionCornerRadius: SECTION_METRICS.cardCornerRadius,
    sectionContentInsets: {
      top: SECTION_METRICS.cardPadding, left: SECTION_METRICS.cardPadding,
      bottom: SECTION_METRICS.cardPadding, right: SECTION_METRICS.cardPadding,
    },
    // The horizontal inset of the content column inside the board; null = the default (sectionContentInsets' left / right, 12).
    sectionBoardInset: null,
    headerBackgroundColor: null,
    headerCornerRadius: 0,
    headerContentInsets: { top: 0, left: SECTION_METRICS.headerBandPadding, bottom: 0, right: SECTION_METRICS.headerBandPadding },
    headerSeparatorStyle: HEADER_SEPARATOR_STYLES.none,
    headerSeparatorColor: null,
    headerSeparatorThickness: SECTION_METRICS.separatorThickness,
    headerSeparatorInsets: null,
    // Nullable tint of every built-in non-tag view; null resolves against what is behind them (resolveTint).
    tintColor: null,
    // True once a configuration sets the color itself: it then wins over the tint.
    headerTextColorSet: false,
    foldControlColorSet: false,
    headerTextColor: dark ? DARK_TEXT_COLOR : LIGHT_TINT,
    foldControlColor: dark ? DARK_TEXT_COLOR : LIGHT_TINT,
    headerFont: { size: HEADER_FONT_SIZE, weight: HEADER_FONT_WEIGHT, italic: false },
    headerHorizontalInset: 16,
    // The most lines a section header's title may take (HEADER_TITLE_MAX_LINES): one line with an ellipsis by default.
    headerMaxLines: HEADER_TITLE_MAX_LINES.single,
    // 'ltr' (default), 'rtl' or 'auto' (which is 'ltr' here, see DIRECTIONS).
    direction: DEFAULT_DIRECTION,
    highlightedBackgroundColor: null,
    allowsTransparentBackground: false,
  });
}

/** The derived fields kept for the component's older readers (imageSize, fontSize, contentInsets…). */
function finishStyle(style) {
  style.imageSize = style.imageSizeWH.width;
  style.imageHeight = style.imageSizeWH.height;
  style.fontSize = style.normal.font.size;
  style.headerFontSize = style.headerFont.size;
  style.contentInsets = { ...style.normal.contentInsets };
  return style;
}

const DEFAULT_STYLE = defaultStyle(2);

function copyStyle(style) {
  return JSON.parse(JSON.stringify(style));
}

const APPEARANCE_STATES = ['normal', 'selected', 'disabled'];

/**
 * `CYLTagAppearance.applyConfiguration(_:)`: missing keys keep their values; an invalid color restores the default. A
 * transparent background becomes the default fill unless `allowsTransparent` (a tag on its own, such as a search bar
 * item, may be transparent; a tag in a list may not).
 */
function applyAppearance(appearance, configuration, allowsTransparent = false) {
  const has = (k) => Object.prototype.hasOwnProperty.call(configuration, k);
  if (has('backgroundColor')) {
    appearance.backgroundColor = allowsTransparent ? tagBackground(configuration.backgroundColor)
      : opaqueBackground(configuration.backgroundColor);
    appearance.backgroundExplicit = isExplicitBackground(configuration.backgroundColor);
  }
  if (has('textColor')) appearance.textColor = color(configuration.textColor) || DEFAULT_TEXT_COLOR;
  if (has('font')) appearance.font = fontValue(configuration.font) || { size: 14, weight: 'regular', italic: false };
  if (has('iconColor')) appearance.iconColor = color(configuration.iconColor);
  if (has('borderColor')) {
    appearance.borderColor = color(configuration.borderColor);
    appearance.borderColorExplicit = appearance.borderColor !== null;
  }
  const sanitized = (n) => (Number.isFinite(n) && n > 0 ? n : 0);
  const radius = numberValue(configuration.cornerRadius);
  if (radius !== null) appearance.cornerRadius = sanitized(radius);
  const width = numberValue(configuration.borderWidth);
  if (width !== null) {
    appearance.borderWidth = sanitized(width);
    appearance.borderWidthExplicit = true;
  }
  const margin = numberValue(configuration.margin);
  if (margin !== null) {
    appearance.contentInsets.left = sanitized(margin);
    appearance.contentInsets.right = sanitized(margin);
  }
  const contentInsets = insetsValue(configuration.contentInsets);
  if (contentInsets) appearance.contentInsets = contentInsets;
  if (has('backgroundImage')) appearance.backgroundImage = typeof configuration.backgroundImage === 'string' ? configuration.backgroundImage : '';
}

/**
 * `CYLMenuStyle.applyConfiguration(_:)` on a copy of `base`: the appearances first (normal, selected, disabled), then
 * the style keys (imageTitleSpacing, itemHeight, itemsPerRow, interitemSpacing, lineSpacing, headerHeight,
 * animationSpeed, layoutCentered, imagePlacement, contentAlignment, imageSize, animationSize, imageInsets,
 * sectionInsets, titlePositionAdjustment, imagePositionAdjustment, backgroundColor, headerTextColor, foldControlColor,
 * headerFont, highlightedBackgroundColor, tagContentInsets). `allowsTransparentBackground` (false by default) keeps a
 * `transparent` / `clear` / zero-alpha tag background instead of the default fill, read before the appearances. `font` at the style level (an older key of this
 * component) sets the font of every state.
 */
function mergeStyle(configuration = {}, base = DEFAULT_STYLE) {
  const style = copyStyle(base);
  const c = configuration || {};
  const transparent = boolValue(c.allowsTransparentBackground);
  if (transparent !== null) style.allowsTransparentBackground = transparent;
  APPEARANCE_STATES.forEach((state) => {
    if (c[state] && typeof c[state] === 'object') applyAppearance(style[state], c[state], style.allowsTransparentBackground);
  });
  if (c.font != null) {
    const font = fontValue(c.font);
    if (font) APPEARANCE_STATES.forEach((state) => { style[state].font = { ...font }; });
  }
  const num = (k, field = k, min = -Infinity) => {
    const n = numberValue(c[k]);
    if (n !== null) style[field] = Math.max(min, n);
  };
  num('imageTitleSpacing');
  num('itemHeight');
  // The most lines a title may take: a whole number of 1 or more, or "unlimited"; anything else is one line.
  if (c.titleMaxLines === 'unlimited') {
    style.titleMaxLines = TITLE_MAX_LINES.unlimited;
  } else if (c.titleMaxLines !== undefined) {
    const lines = numberValue(c.titleMaxLines);
    style.titleMaxLines = lines !== null && lines >= TITLE_MAX_LINES.single ? Math.floor(lines) : TITLE_MAX_LINES.single;
  }
  // The same rule for a section header's title (`headerMaxLines`).
  if (c.headerMaxLines === 'unlimited') {
    style.headerMaxLines = HEADER_TITLE_MAX_LINES.unlimited;
  } else if (c.headerMaxLines !== undefined) {
    const lines = numberValue(c.headerMaxLines);
    style.headerMaxLines = lines !== null && lines >= HEADER_TITLE_MAX_LINES.single ? Math.floor(lines) : HEADER_TITLE_MAX_LINES.single;
  }
  // 'ltr' | 'rtl' | 'auto' (case-insensitive); anything else keeps the style's.
  const direction = c.direction === undefined || c.direction === null ? null : namedValue(c.direction, DIRECTIONS);
  if (direction) style.direction = direction;
  num('itemsPerRow', 'itemsPerRow', 0);
  num('interitemSpacing');
  num('lineSpacing');
  num('headerHeight');
  if (numberValue(c.headerHeight) !== null) style.headerHeightSet = true;
  num('animationSpeed');
  num('headerHorizontalInset');
  const centered = boolValue(c.layoutCentered);
  if (centered !== null) style.layoutCentered = centered;
  const placement = String(c.imagePlacement || '').toLowerCase();
  if (['trailing', 'right', '1'].includes(placement)) style.imagePlacement = 'trailing';
  if (['leading', 'left', '0'].includes(placement)) style.imagePlacement = 'leading';
  if (['top', '2'].includes(placement)) style.imagePlacement = 'top';
  if (['bottom', '3'].includes(placement)) style.imagePlacement = 'bottom';
  const alignment = String(c.contentAlignment || '').toLowerCase();
  if (['leading', 'left', '1'].includes(alignment)) style.contentAlignment = 'leading';
  if (['center', '0'].includes(alignment)) style.contentAlignment = 'center';
  const backgroundStyle = String(c.backgroundStyle || '').toLowerCase();
  if (['liquidglass', '1'].includes(backgroundStyle)) style.backgroundStyle = 'liquidGlass';
  if (['flat', '0'].includes(backgroundStyle)) style.backgroundStyle = 'flat';
  const minimumTagSize = sizeValue(c.minimumTagSize);
  if (minimumTagSize) style.minimumTagSizeWH = minimumTagSize;
  const size = sizeValue(c.imageSize);
  if (size) style.imageSizeWH = size;
  const animationSize = sizeValue(c.animationSize);
  if (animationSize) style.animationSizeWH = animationSize;
  const imageInsets = insetsValue(c.imageInsets);
  if (imageInsets) style.imageInsets = imageInsets;
  if (c.sectionInsets != null) style.sectionInsets = insets(c.sectionInsets, style.sectionInsets);
  const titleOffset = offsetValue(c.titlePositionAdjustment);
  if (titleOffset) style.titlePositionAdjustment = titleOffset;
  const imageOffset = offsetValue(c.imagePositionAdjustment);
  if (imageOffset) style.imagePositionAdjustment = imageOffset;
  ['backgroundColor', 'headerTextColor', 'foldControlColor'].forEach((k) => {
    const value = color(c[k]);
    if (value) style[k] = value;
    if (value) style[`${k}Set`] = true;
  });
  mergeSectionStyle(style, c);
  if (Object.prototype.hasOwnProperty.call(c, 'highlightedBackgroundColor')) {
    style.highlightedBackgroundColor = color(c.highlightedBackgroundColor);
  }
  const headerFont = fontValue(c.headerFont);
  if (headerFont) style.headerFont = headerFont;
  if (c.tagContentInsets != null) {
    const value = insetsValue(c.tagContentInsets);
    if (value) APPEARANCE_STATES.forEach((state) => { style[state].contentInsets = { ...value }; });
  }
  return finishStyle(style);
}

// MARK: - Configuration

// The core's CYLMenuExpand / CYLMenuCollapse in Simplified Chinese (the fallback when no language table answers).
const CORE_TABLES = require('../core-tables.js');
const EXPAND_TITLE = CORE_TABLES['zh-Hans'].CYLMenuExpand;
const COLLAPSE_TITLE = CORE_TABLES['zh-Hans'].CYLMenuCollapse;

function key(section, item) {
  return `${section}-${item}`;
}

function parseKey(value) {
  const parts = Array.isArray(value) ? value.map(Number) : String(value).split('-').map(Number);
  if (parts.length !== 2 || parts.some((n) => !Number.isInteger(n) || n < 0)) return null;
  return { section: parts[0], item: parts[1] };
}

/** An item dictionary, or a plain value as its title ("Text only"), as `CYLTagListConfigurationSource.item(at:)`. */
function itemDictionary(item) {
  if (item && typeof item === 'object' && !Array.isArray(item)) return item;
  return { title: item == null ? '' : String(item) };
}

/** The fold control of `CYLMenuFoldControl(configuration:)`: a dictionary, or a position alone. */
/** The content a fold control position has when none is given: the header controls show the icon and the title, the tail and the footer the icon only. */
function usualFoldContent(position) {
  return position === 'footer' || position === 'tail' ? 'icon' : 'iconAndTitle';
}

function foldControlValue(value) {
  const control = { position: 'none', content: 'title', title: '', collapseTitle: '', color: null };
  if (value == null) return control;
  const positions = {
    none: 'none', footer: 'footer', headertrailing: 'headerTrailing', headerright: 'headerTrailing',
    headerleading: 'headerLeading', headerleft: 'headerLeading', tail: 'tail',
  };
  // "iconAndTitle" and its alias "titleAndIcon" keep their meaning; "titleAndIconAlways" is the title-and-icon-always content.
  const contents = {
    iconandtitle: 'iconAndTitle', titleandicon: 'iconAndTitle', titleandiconalways: 'titleAndIcon', title: 'title', icon: 'icon',
  };
  const dictionary = typeof value === 'object' ? value : { position: value };
  const position = positions[String(dictionary.position || '').toLowerCase()];
  if (position) control.position = position;
  const content = contents[String(dictionary.content || '').toLowerCase()];
  if (content) control.content = content;
  else if (control.position !== 'none') control.content = usualFoldContent(control.position);
  if (typeof dictionary.title === 'string') control.title = dictionary.title;
  if (typeof dictionary.collapseTitle === 'string') control.collapseTitle = dictionary.collapseTitle;
  control.color = color(dictionary.color);
  return control;
}

/**
 * The configuration with defaults: selectionMode ("none" | "single" | "multiple"), allowsEmptySelection (true, as in
 * the core), showsSectionHeaders (true), defaultVisibleRows (0 = never fold), foldControl ({position: "none" |
 * "headerTrailing" | "tail" | "footer", content: "title" | "icon" | "iconAndTitle" | "titleAndIconAlways"}), style and sections ([{title,
 * style, items: [{title, image, selectedImage, animation, animationOptions, animationRestingProgress, exclusive,
 * enabled, gifFirstFrame, gifLastFrame, gifDuration, autoplay}] }], a plain value being an item's title). `options.pixelRatio` sets the hairline of the default borders, `options.dark` the dark mode defaults (tag fill and title, the list's tint).
 */
function normalize(configuration = {}, options = {}) {
  const c = configuration || {};
  const base = options.pixelRatio || options.dark ? defaultStyle(options.pixelRatio || 2, !!options.dark) : DEFAULT_STYLE;
  const style = mergeStyle(c.style, base);
  const sections = (Array.isArray(c.sections) ? c.sections : []).map((section, s) => ({
    index: s,
    title: section && section.title != null ? String(section.title) : '',
    // A section's style dictionary applies over the list's style (`menuStyle(forSection:)`).
    style: section && section.style && typeof section.style === 'object' ? mergeStyle(section.style, style) : style,
    items: ((section && section.items) || []).map((value, i) => {
      const item = itemDictionary(value);
      const resting = numberValue(item.animationRestingProgress);
      return {
        key: key(s, i),
        section: s,
        item: i,
        title: item.title != null ? String(item.title) : '',
        // A longer description, shown in a callout on a long press (longPressAction "callout").
        subtitle: item.subtitle != null ? String(item.subtitle) : '',
        image: typeof item.image === 'string' ? item.image : '',
        selectedImage: typeof item.selectedImage === 'string' ? item.selectedImage : '',
        animation: typeof item.animation === 'string' ? item.animation : '',
        animationOptions: item.animationOptions && typeof item.animationOptions === 'object' ? { ...item.animationOptions } : null,
        animationRestingProgress: resting === null ? 0 : Math.min(1, Math.max(0, resting)),
        exclusive: boolValue(item.exclusive) === true,
        enabled: boolValue(item.enabled) !== false,
        // A GIF's stills (PNG) and the length of one pass (ms): with stills it rests on them and plays one pass on
        // Play all. An icon rests (its resting frame) until it is tapped or played, as CYLTagButton on iOS and the
        // tab icons of CYLTabBarController (docs/Animated-Item.md); autoplay true plays it once when its file is ready.
        gifFirstFrame: typeof item.gifFirstFrame === 'string' ? item.gifFirstFrame : '',
        gifLastFrame: typeof item.gifLastFrame === 'string' ? item.gifLastFrame : '',
        gifDuration: numberValue(item.gifDuration) > 0 ? numberValue(item.gifDuration) : 0,
        autoplay: boolValue(item.autoplay) === true,
      };
    }),
  }));
  const modes = { none: 'none', single: 'single', multiple: 'multiple', 0: 'none', 1: 'single', 2: 'multiple' };
  return {
    selectionMode: modes[String(c.selectionMode).toLowerCase()] || 'none',
    allowsEmptySelection: boolValue(c.allowsEmptySelection) !== false,
    showsSectionHeaders: boolValue(c.showsSectionHeaders) !== false,
    defaultVisibleRows: Math.max(0, Math.floor(numberValue(c.defaultVisibleRows) || 0)),
    foldControl: foldControlValue(c.foldControl),
    longPressActions: longPressActions(c.longPressAction),
    style,
    sections,
    selectedItems: sanitizeSelection(c.selectedItems || [], sections),
  };
}

/**
 * The long-press actions of a configuration's `longPressAction` (docs/tag-long-press-action.md): a name ("reorder",
 * "callout", "report", "none") or an array of names, the first that can begin winning. The long press is still reported
 * where no listed action takes it (an item without a subtitle), unless "none" is listed. null when absent or unknown:
 * the default, which reports the long press (the list does not reorder; reordering is cyl-tag-cloud's).
 */
function longPressActions(value) {
  if (value === undefined || value === null) return null;
  const names = Array.isArray(value) ? value : [value];
  const known = ['reorder', 'callout', 'report', 'none'];
  if (!names.length || names.some((name) => !known.includes(name))) return null;
  const list = names.slice();
  if (!list.includes('none') && !list.includes('report')) list.push('report');
  return list;
}

/**
 * What a long press does: the first of `actions` that can begin (null: the default, "report"). "callout" needs a
 * subtitle, "reorder" needs a list that reorders (`canReorder`, false here), "report" and "none" always begin.
 * @returns {'callout'|'report'|'none'}
 */
function longPressDecision(actions, hasSubtitle, canReorder = false) {
  const list = actions || ['report'];
  for (const name of list) {
    if (name === 'callout' && hasSubtitle) return 'callout';
    // "reorder" does not begin here: this list does not reorder (cyl-tag-cloud does), so the next action takes the press.
    if (name === 'report') return 'report';
    if (name === 'none') return 'none';
  }
  return 'none';
}

/** Drops keys that address no item, and duplicates; keeps the order. Keys are "s-i" strings or [s, i] pairs. */
function sanitizeSelection(items, sections) {
  const result = [];
  (Array.isArray(items) ? items : []).forEach((value) => {
    const parsed = parseKey(value);
    if (!parsed) return;
    const section = sections[parsed.section];
    if (!section || !section.items[parsed.item]) return;
    const k = key(parsed.section, parsed.item);
    if (!result.includes(k)) result.push(k);
  });
  return result;
}

function itemAt(model, k) {
  const parsed = parseKey(k);
  if (!parsed) return null;
  const section = model.sections[parsed.section];
  return section ? section.items[parsed.item] || null : null;
}

/**
 * The selection after tapping item `k` (`CYLTagListView.handleTap(at:)`): selecting an item removes, in its section,
 * every other item in single mode, every other item when it is exclusive, and the exclusive items otherwise; tapping
 * a selected item deselects it when empty selection is allowed or its section keeps another selected item.
 * @returns {{selectedItems: string[], selected: boolean, changed: boolean}}
 */
function tap(model, selectedItems, k) {
  const target = itemAt(model, k);
  if (!target || !target.enabled) return { selectedItems, selected: false, changed: false };
  if (model.selectionMode === 'none') return { selectedItems, selected: true, changed: false };
  const sameSection = (other) => itemAt(model, other) && itemAt(model, other).section === target.section;
  if (selectedItems.includes(k)) {
    const inSection = selectedItems.filter(sameSection).length;
    if (model.allowsEmptySelection || inSection > 1) {
      return { selectedItems: selectedItems.filter((x) => x !== k), selected: false, changed: true };
    }
    return { selectedItems, selected: false, changed: false };
  }
  const kept = selectedItems.filter((other) => {
    if (!sameSection(other)) return true;
    return !(model.selectionMode === 'single' || target.exclusive || itemAt(model, other).exclusive);
  });
  return { selectedItems: [...kept, k], selected: true, changed: true };
}

// MARK: - Folding

/**
 * The rows of a section from the measured top of each item (in item order): items with the same top share a row.
 * @param {number[]} tops
 * @returns {number[]} the row index of each item
 */
function rowsFromTops(tops) {
  const rows = [];
  let row = -1;
  let lastTop = null;
  tops.forEach((top) => {
    if (lastTop === null || Math.abs(top - lastTop) > 1) {
      row += 1;
      lastTop = top;
    }
    rows.push(row);
  });
  return rows;
}

/**
 * Whether a section can fold (`canFoldRowCount`: it needs more rows than defaultVisibleRows) and which items stay
 * visible while it is folded.
 * @param {number[]} rows the row index of each item, from rowsFromTops
 * @returns {{canFold: boolean, visible: boolean[]}}
 */
function foldState(model, rows, expanded) {
  const limit = model.defaultVisibleRows;
  const rowCount = rows.length ? rows[rows.length - 1] + 1 : 0;
  const canFold = limit > 0 && rowCount > limit;
  const visible = rows.map((row) => !canFold || expanded || row < limit);
  return { canFold, visible };
}

/** The content "titleAndIcon" (configuration "titleAndIconAlways"): the title and the chevron in both states, "More ⌄" folded, "Less ⌃" expanded. */
const FOLD_CONTENT_TITLE_AND_ICON = 'titleAndIcon';

/** The longer of the fold titles: a hidden sizer of it keeps the control as wide as its widest state, so it does not jump when toggled. */
function longerFoldTitle(a, b) {
  return String(b).length > String(a).length ? String(b) : String(a);
}

function foldTitle(expanded) {
  return expanded ? COLLAPSE_TITLE : EXPAND_TITLE;
}

// MARK: - Animations

/** Folders the iOS examples put before an animation file's path, and file name extensions of each engine. */
const ANIMATION_PREFIXES = [/^\/+/, /^(\.\.\/)+/, /^CYLMenuExample\.bundle\//, /^Animations\//];

/** The engine of an animation file by its extension ("lottie", "gif", "pag", "rive"), or ''. */
function animationEngine(animation) {
  if (/^asset:/.test(animation || '')) return 'lottie';
  // CYLTabBarController's cyl-animated-item decides the type (one list for both: it knows SVGA and skips a trailing
  // ".bin", the name a mini program package needs for SVGA / PAG / Rive files); the private table here had no SVGA.
  return cylAnimatedItemType(animation);
}

/** "../Animations/Lottie/x.json", "CYLMenuExample.bundle/Animations/Lottie/x.json" → "Lottie/x.json". */
function animationKey(animation) {
  // The engine's parser (cylAnimatedItemSource, the shared fixture source-options.json): the file before the first "#" or "?".
  let path = cylAnimatedItemSource(animation).file;
  ANIMATION_PREFIXES.forEach((prefix) => { path = path.replace(prefix, ''); });
  return path;
}

/**
 * The registered file of a tag's animation (`registry` by its path without the iOS folders, or the older `assets` of
 * "asset:<name>"), or null. No engine is checked here: the library links none, and the app's engine component (an
 * abstract node of cyl-animated-item) reports `error` when it cannot play the file, which shows the image instead.
 * @returns {{engine: string, key: string, entry: object}|null}
 */
function resolveAnimation(animation, registry = {}, assets = {}) {
  if (!animation) return null;
  const asset = /^asset:([^#?]+?)(?:\.json)?(?:[#?].*)?$/.exec(animation);
  if (asset) {
    const data = assets[asset[1]];
    return data ? { engine: 'lottie', key: `asset:${asset[1]}`, entry: { engine: 'lottie', data: () => data } } : null;
  }
  const engine = animationEngine(animation);
  if (!engine) return null;
  const k = animationKey(animation);
  const entry = registry[k];
  return entry && entry.engine === engine ? { engine, key: k, entry } : null;
}

/** True for a path the app can load as it is: an absolute package path or a URL ("/assets/a.json", "https://…"). */
function isLoadablePath(animation) {
  return /^\/[^/]/.test(animation) || /^[a-z][a-z0-9+.-]*:\/\//i.test(animation);
}

/**
 * The `animation-url` cyl-animated-item plays for a tag (CYLTabBarController's shared icon + title component): the
 * registered file's path ("Lottie/x.json", "Rive/house.riv", "pag-ios/0.pag", "asset:<name>.json", which the app's
 * engine component resolves), a GIF's own file (drawn by `<image>`), or an absolute path or URL as it is; '' when there is
 * no such file. The tag's `animationOptions` (Rive's stateMachine, input …) and a `restingProgress` above 0 follow
 * after "#" as "key=value&…", which cyl-animated-item ignores when it finds the type.
 */
function animationURL(animation, registry = {}, assets = {}, options = null, restingProgress = 0) {
  if (!animation) return '';
  const resolved = resolveAnimation(animation, registry, assets);
  let base = '';
  if (resolved && resolved.engine === 'gif') return resolved.entry.src || '';
  if (resolved) base = resolved.key.startsWith('asset:') ? `${resolved.key}.json` : resolved.key;
  else if (isLoadablePath(animation) && animationEngine(animation)) base = cylAnimatedItemSource(animation).file;
  if (!base) return '';
  if (animationEngine(base) === 'gif') return base;
  const parameters = { ...(options || {}) };
  if (Number(restingProgress) > 0) parameters.restingProgress = Math.min(1, Number(restingProgress));
  const pairs = Object.keys(parameters).filter((name) => parameters[name] != null && parameters[name] !== '')
    .map((name) => `${name}=${encodeURIComponent(parameters[name])}`);
  return pairs.length ? `${base}#${pairs.join('&')}` : base;
}

/** The parameters after "#" of an `animationURL` ({stateMachine: 'State Machine', restingProgress: '1'}), for engines. */
function animationParameters(url) {
  return cylAnimatedItemSource(url).options;
}

// MARK: - One tag (CYLTagButton)

/** The state used for the appearance: disabled wins over selected (as on UIControl). */
function stateOf(item, selected) {
  if (!item.enabled) return 'disabled';
  return selected ? 'selected' : 'normal';
}

/** The effective icon tint of a state (`CYLMenuStyle.iconColor(for:)`): iconColor, else the text color. */
function iconColor(style, state) {
  const appearance = style[state];
  return appearance.iconColor || appearance.textColor;
}

/** A CSS line height for a font size (UIFont.systemFont's lineHeight is about 1.19 times its size). */
function lineHeight(size) {
  return Math.ceil(size * 1.194);
}

/** True for the placements 'top' and 'bottom' (`CYLTagImagePlacement.top` / `.bottom`): icon and title stacked. */
function isVerticalPlacement(placement) {
  return placement === 'top' || placement === 'bottom';
}

/**
 * Tag height (`CYLTagButton.height(for:)`): itemHeight, or more for a line of the title font and the insets; with the
 * icon above or below the title, also the icon slot and imageTitleSpacing.
 */
function tagHeight(style) {
  const iconHeight = isVerticalPlacement(style.imagePlacement)
    ? Math.max(style.imageSizeWH.height, style.animationSizeWH.height) : 0;
  const stacked = iconHeight > 0 ? iconHeight + style.imageTitleSpacing : 0;
  return APPEARANCE_STATES.reduce((height, state) => {
    const { font, contentInsets } = style[state];
    return Math.max(height, lineHeight(font.size) + stacked + contentInsets.top + contentInsets.bottom);
  }, Math.max(style.itemHeight, style.minimumTagSizeWH.height));
}

/**
 * `CYLTagButton.height(forTitle:iconSize:style:traitCollection:)`: the height a tag needs for a title (or none) and an
 * icon of `iconSize` ({width: 0, height: 0} for none): the taller of the two side by side, or both and the spacing
 * when stacked; at least itemHeight.
 */
function tagHeightForTitle(style, title, iconSize) {
  const hasTitle = String(title || '') !== '';
  const icon = iconSize || { width: 0, height: 0 };
  return APPEARANCE_STATES.reduce((height, state) => {
    const { font, contentInsets } = style[state];
    const line = hasTitle ? lineHeight(font.size) : 0;
    const content = isVerticalPlacement(style.imagePlacement)
      ? line + icon.height + (hasTitle && icon.height > 0 ? style.imageTitleSpacing : 0)
      : Math.max(line, icon.height);
    return Math.max(height, Math.ceil(content + contentInsets.top + contentInsets.bottom));
  }, Math.max(style.itemHeight, style.minimumTagSizeWH.height));
}

/** The badge's color when none is given: UIColor.systemRed. */
const BADGE_DEFAULT_COLOR = '#FF3B30';

/**
 * The badge of a tag (`CYLTagButton.badgeValue` / `badgeColor`): null or undefined hides it, '' is an 8 px dot, any
 * other text a white bold 11 px capsule at least 16 px high, on `badgeColor` (system red by default). It sits on the
 * top trailing corner of the icon slot (or of the title): the center of its leading cap on the corner.
 * `badgeAccessibilityValue` is what a screen reader reads after the title: the text, or "New" (localized) for a dot.
 */
function badgeLayout(badgeValue, badgeColor) {
  if (badgeValue === null || badgeValue === undefined) {
    return { showsBadge: false, badgeText: '', badgeStyle: '', badgeAccessibilityValue: '' };
  }
  const text = String(badgeValue);
  const dot = text === '';
  const height = dot ? 8 : 16;
  const fill = color(badgeColor) || BADGE_DEFAULT_COLOR;
  const size = dot ? `width: ${height}px; height: ${height}px` : `min-width: ${height}px; height: ${height}px; padding: 0 4px`;
  return {
    showsBadge: true,
    badgeText: dot ? '' : text,
    badgeStyle: [
      'position: absolute', `left: calc(100% - ${height / 2}px)`, `top: -${height / 2}px`, size, 'box-sizing: border-box',
      `border-radius: ${height / 2}px`, `background-color: ${fill}`, 'color: #FFFFFF', 'font-size: 11px',
      'font-weight: 700', `line-height: ${height}px`, 'text-align: center', 'white-space: nowrap',
    ].join('; '),
    badgeAccessibilityValue: dot ? locale.tc('CYLTagBadgeDot') : text,
  };
}

/** Corner radius in points: 0 is square, at most half the height (half the height or more is a capsule). */
function cornerRadius(radius, height) {
  return Math.min(Number.isFinite(radius) && radius > 0 ? radius : 0, height / 2);
}

function fontCSS(font) {
  return `font-size: ${font.size}px; font-weight: ${FONT_WEIGHTS[font.weight] || 400}; font-style: ${font.italic ? 'italic' : 'normal'}`;
}

/**
 * What the icon slot of a tag shows in a state: the animation (a file to play, `animationURL`), else the
 * state's image (the selected image while selected, as CYLFlatDesignTabBarItem.selectedImage), an SF Symbol stand-in
 * tinted with the state's icon color, or nothing.
 * @returns {{kind: 'animation'|'image'|'glyph'|'none', src: string, glyph: string}}
 */
function iconContent(item, state, style, animation) {
  if (animation) return { kind: 'animation', src: '', glyph: '' };
  const image = state === 'selected' && item.selectedImage ? item.selectedImage : item.image;
  if (!image) return { kind: 'none', src: '', glyph: '' };
  const system = /^system:(.+)$/.exec(image);
  if (!system) return { kind: 'image', src: image, glyph: '' };
  const uri = symbols.symbolURI(system[1], iconColor(style, state));
  if (uri) return { kind: 'image', src: uri, glyph: '' };
  return { kind: 'glyph', src: '', glyph: symbols.glyph(system[1]) };
}

/**
 * What CYLTabBarController's cyl-animated-item draws in a tag's icon slot (the library has no animation code of its
 * own): `animationUrl` (`animationURL`, '' for none), `iconSrc`, the static image it shows until the engine is ready and
 * after it fails (the state's image, or a tinted symbol), and `iconEnabled` (an animation is dimmed while the tag is
 * disabled, an image keeps the state's colors). A symbol without an image (`iconKind` 'glyph') is drawn as text.
 */
function animatedIcon(item, state, style, url) {
  const icon = iconContent(item, state, style, url);
  const still = icon.kind === 'animation' ? iconContent(item, state, style, null) : icon;
  return {
    iconKind: icon.kind,
    glyph: icon.glyph,
    animationUrl: icon.kind === 'animation' ? url : '',
    iconSrc: still.kind === 'image' ? still.src : '',
    iconEnabled: icon.kind === 'animation' ? item.enabled !== false : true,
    gifFirstFrame: item.gifFirstFrame || '',
    gifLastFrame: item.gifLastFrame || '',
    gifDuration: item.gifDuration > 0 ? item.gifDuration : 1000,
    autoplay: item.autoplay === true,
  };
}

/**
 * The CSS of one tag (`CYLTagButton.layoutSubviews` and `width(forTitle:iconSize:style:)`): a border-box whose
 * padding is the content insets with the border inside them, the widest insets of every state so that selecting a
 * tag does not resize it; the icon slot (imageSize, or animationSize for an animation) with imageInsets taken off its
 * size from the top left; icon and title centered with imageTitleSpacing between them, a lone icon or title centered
 * with layoutCentered or kept in place (after an empty icon slot) without it; the position adjustments as offsets.
 * @param {boolean} showsAnimation whether the icon slot holds an animation
 * @param {number} [fixedHeight] the tag's height; `tagHeight(style)` (every tag of a list as high) by default
 */
function tagLayout(style, item, state, icon, interitemSpacing, lineSpacing, fixedHeight) {
  const appearance = style[state];
  const rtl = isRtl(style);
  const height = fixedHeight > 0 ? fixedHeight : tagHeight(style);
  // Under drawn glass only an explicit border is handed (an unset one is none: the glass rim applies); flat keeps the default border.
  const handedBorder = glassHandedBorder(style, appearance);
  const border = handedBorder.color ? handedBorder.width : 0;
  // Left and right at least the space the shape asks for between the border and the title: cyl-animated-item's
  // cylAnimatedItemLiquidGlassContentInset (14) on a drawn Liquid Glass tag, 0 on flat.
  const sideInset = style.backgroundStyle === 'liquidGlass' && cylAnimatedItemLiquidGlassIsActive() ? cylAnimatedItemLiquidGlassContentInset : 0;
  const left = Math.max(sideInset, ...APPEARANCE_STATES.map((s) => style[s].contentInsets.left));
  const right = Math.max(sideInset, ...APPEARANCE_STATES.map((s) => style[s].contentInsets.right));
  const showsImage = icon.kind !== 'none';
  const showsTitle = item.title !== '';
  const animated = icon.kind === 'animation';
  const slot = animated && (style.animationSizeWH.width > 0 || style.animationSizeWH.height > 0)
    ? style.animationSizeWH : style.imageSizeWH;
  const spacing = showsImage && showsTitle ? style.imageTitleSpacing : 0;
  const leading = style.contentAlignment === 'leading';
  // The title keeps its place after an empty icon slot when a lone title is not centered.
  const emptySlot = showsTitle && !showsImage && !style.layoutCentered && !leading
    ? style.imageSizeWH.width + style.imageTitleSpacing : 0;
  const vertical = isVerticalPlacement(style.imagePlacement);
  // Stacked: the group centered from top to bottom, each part centered (or at the leading margin) across.
  const justify = !vertical && (leading || (!style.layoutCentered && !(showsImage && showsTitle))) ? 'flex-start' : 'center';
  const directions = { trailing: 'row-reverse', top: 'column', bottom: 'column-reverse' };
  // The background, radius and border are cyl-animated-item's (the interface of CYLAnimatedItemView.itemBackgroundStyle…); the radius is
  // the appearance's, handed over as it is (the capsule constant by default): cyl-animated-item implements the capsule.
  const radius = appearance.cornerRadius;
  // Under drawn Liquid Glass an unset background hands no color ('': the glass component's default frosted tint, so a colorful
  // backdrop shows through); an explicit one (selected tint, preset, app color) keeps the alpha x 0.75 rule. Flat is unchanged.
  const handedColor = glassHandedColor(style, appearance);
  const itemBackground = cylAnimatedItemBackground(style.backgroundStyle, handedColor, radius, border, handedBorder.color,
    !!(style.sectionPalette && style.sectionPalette.dark), // the color mode picks the glass component's default tint
    state === 'selected' ? 1 : -1); // a selected Liquid Glass tag keeps its full color (tint alpha 1, still glass)
  const glass = itemBackground.glass;
  const background = appearance.backgroundImage
    ? `background-image: url("${appearance.backgroundImage}"); background-size: 100% 100%`
    : '';
  // A title that may wrap (titleMaxLines above 1) grows the tag: the height is a minimum and the text wraps.
  const wraps = style.titleMaxLines > TITLE_MAX_LINES.single;
  const cell = [
    wraps ? `min-height: ${height}px; white-space: normal; height: auto` : `height: ${height}px`,
    // Right to left: the leading inset is on the right, so the physical sides swap (the same for the spacing after a tag).
    `padding: 0 ${Math.max(0, (rtl ? left : right) - border)}px 0 ${Math.max(0, (rtl ? right : left) - border)}px`,
    rtl ? `margin: 0 0 ${lineSpacing}px ${interitemSpacing}px` : `margin: 0 ${interitemSpacing}px ${lineSpacing}px 0`,
    fontCSS(appearance.font),
    `border-width: ${border}px`,
    `border-color: ${handedBorder.color || 'transparent'}`,
    `color: ${appearance.textColor}`,
    itemBackground.css,
    style.minimumTagSizeWH.width > 0 ? `min-width: ${style.minimumTagSizeWH.width}px` : '',
    `justify-content: ${justify}`,
    `flex-direction: ${directions[style.imagePlacement] || 'row'}`,
    vertical ? `align-items: ${leading ? 'flex-start' : 'center'}` : '',
    background,
  ].filter(Boolean).join('; ');
  const ii = style.imageInsets;
  const io = style.imagePositionAdjustment;
  const to = style.titlePositionAdjustment;
  const gaps = { trailing: rtl ? 'margin-right' : 'margin-left', top: 'margin-bottom', bottom: 'margin-top' };
  const gap = gaps[style.imagePlacement] || (rtl ? 'margin-left' : 'margin-right');
  return {
    height,
    cellStyle: cell,
    // The title's own style: at most titleMaxLines lines, then an ellipsis (every line when unlimited).
    titleTextStyle: !wraps ? '' : style.titleMaxLines === TITLE_MAX_LINES.unlimited
      ? 'white-space: normal; overflow: visible; text-overflow: clip'
      : `white-space: normal; display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: ${style.titleMaxLines}; overflow: hidden; text-overflow: ellipsis`,
    glass,
    slotStyle: showsImage
      ? `width: ${slot.width}px; height: ${slot.height}px; ${gap}: ${spacing}px; left: ${io.horizontal}px; top: ${io.vertical}px`
      : '',
    iconWidth: Math.max(0, slot.width - ii.left - ii.right),
    iconHeight: Math.max(0, slot.height - ii.top - ii.bottom),
    // cyl-animated-item draws a square icon: the largest square of the icon frame, centered in it.
    iconSize: Math.max(0, Math.min(slot.width - ii.left - ii.right, slot.height - ii.top - ii.bottom)),
    // Only the size changes; x and y stay, as CYLFlatDesignTabBarItem.imageInsets.
    iconStyle: `width: ${Math.max(0, slot.width - ii.left - ii.right)}px; height: ${Math.max(0, slot.height - ii.top - ii.bottom)}px`,
    glyphSize: Math.floor(Math.min(slot.width, slot.height) * 0.74),
    spacerStyle: emptySlot && !vertical ? `width: ${emptySlot}px` : '',
    titleStyle: `left: ${to.horizontal}px; top: ${to.vertical}px`,
    showsTitle,
  };
}

/**
 * The view data of the standalone `cyl-tag-button` (the core's `CYLTagButton` on its own): `props` holds the iOS names
 * (title, image, selectedImage, animationSpeed, badgeValue, badgeColor, accessibilityLabel, selected, enabled, tagStyle),
 * `animationUrl` the file cyl-animated-item plays (`animationURL`, '' for none). The tag is `tagLayout` at its own height (`tagHeightForTitle`: no
 * room for a missing icon or title), with the badge and an accessibility label that reads `accessibilityLabel` (else the
 * title), then the badge.
 */
function tagButtonView(props, animationUrl, pixelRatio = 2, dark = false) {
  const style = mergeStyle((props && props.tagStyle) || {}, defaultStyle(pixelRatio, dark));
  const item = {
    title: String(props.title || ''),
    image: props.image || '',
    selectedImage: props.selectedImage || '',
    enabled: props.enabled !== false,
    gifFirstFrame: props.gifFirstFrame || '',
    gifLastFrame: props.gifLastFrame || '',
    gifDuration: Number(props.gifDuration) > 0 ? Number(props.gifDuration) : 0,
    autoplay: props.autoplay === true,
  };
  const state = stateOf(item, !!props.selected);
  const icon = iconContent(item, state, style, animationUrl);
  const animated = icon.kind === 'animation';
  const slot = animated && (style.animationSizeWH.width > 0 || style.animationSizeWH.height > 0)
    ? style.animationSizeWH : style.imageSizeWH;
  const height = tagHeightForTitle(style, item.title, icon.kind === 'none' ? null : slot);
  const tag = tagLayout(style, item, state, icon, 0, 0, height);
  const badge = badgeLayout(props.badgeValue, props.badgeColor);
  return {
    ...tag,
    ...badge,
    ...animatedIcon(item, state, style, animationUrl),
    title: item.title,
    speed: props.animationSpeed > 0 ? props.animationSpeed : style.animationSpeed,
    accessibilityLabel: [props.accessibilityLabel || item.title, badge.badgeAccessibilityValue].filter(Boolean).join(', '),
  };
}

/**
 * The fonts of the other states when they differ from this one's: the title is laid out with each of them (hidden) so
 * that the tag is as wide as its widest state, as `CYLTagButton.width(forTitle:…)` measures every state.
 */
function sizerFonts(style, state) {
  const own = fontCSS(style[state].font);
  const others = APPEARANCE_STATES.map((s) => fontCSS(style[s].font)).filter((css) => css !== own);
  return Array.from(new Set(others));
}

// MARK: - Section style geometry (docs/tag-section-style.md)
// A mini program lays tags out in CSS, so a column is two distances from the list's edges, { left, right }, and
// `columnAt` turns them into x and width at a list width. `contentColumn` is the one place the column comes from: the CSS
// of the card, the tags and the header, the header title's x and the divider all derive from it.

function isInsetGrouped(style) {
  return style.sectionStyle === SECTION_STYLES.insetGrouped;
}

/** True when the list reads right to left: the style's `direction` is `rtl` (`auto` is `ltr`, see DIRECTIONS). */
function isRtl(style) {
  return !!style && style.direction === DIRECTIONS.rtl;
}

/**
 * Insets as distances from the list's physical left and right edges. The style's left / right values are the leading /
 * trailing ones, so right to left swaps the sides (top and bottom stay); left to right returns the insets as they are.
 */
function physicalInsets(style, value) {
  return isRtl(style) ? { ...value, left: value.right, right: value.left } : value;
}

/**
 * The board's outward extension, the ONE place it is computed: how far the board (card, header band, divider) reaches past
 * the tag column on the left and the right. Unset `sectionBoardInset` (null) is the default, the leading / trailing parts of
 * `sectionContentInsets` (the board then spans the section column); a set value (0 included) overrides them on both sides,
 * 0 hugging the tags. A value above the default may push the board past the list margin. None without a board.
 * It never moves the tag column.
 */
function boardInset(style) {
  if (!isInsetGrouped(style)) return { left: 0, right: 0 };
  if (style.sectionBoardInset !== null && style.sectionBoardInset !== undefined) {
    return { left: style.sectionBoardInset, right: style.sectionBoardInset };
  }
  const insets = physicalInsets(style, style.sectionContentInsets);
  return { left: insets.left, right: insets.right };
}

/**
 * The card's padding around the tags under insetGrouped, else none: left / right are the board's extension (`boardInset`), top / bottom from
 * `sectionContentInsets`.
 */
function cardInsets(style) {
  if (!isInsetGrouped(style)) return ZERO_INSETS;
  const insets = physicalInsets(style, style.sectionContentInsets);
  const inset = boardInset(style);
  return { top: insets.top, bottom: insets.bottom, left: inset.left, right: inset.right };
}

/** The section's column: the list width minus `sectionInsets`, as distances from the list's left and right edges (leading / trailing mirrored). */
function contentColumn(style) {
  const insets = physicalInsets(style, style.sectionInsets);
  return { left: insets.left, right: insets.right };
}

/**
 * The ONE column the header title and the tags share: `contentColumn` minus the leading / trailing `sectionContentInsets`
 * under insetGrouped, else the section column. It never depends on `sectionBoardInset`. Rows, folding and height follow it.
 */
function tagColumn(style) {
  const column = contentColumn(style);
  if (!isInsetGrouped(style)) return column;
  const insets = physicalInsets(style, style.sectionContentInsets);
  return { left: column.left + insets.left, right: column.right + insets.right };
}

/**
 * The column of the board (card, header band, divider): the tag column extended outward by `boardInset` on both sides
 * (the section column by default, the tag column itself for 0). Without a board it is the section column. A distance
 * can be negative when the board passes the list's margin (accepted).
 */
function boardColumn(style) {
  if (!isInsetGrouped(style)) return contentColumn(style);
  const tags = tagColumn(style);
  const extension = boardInset(style);
  return { left: tags.left - extension.left, right: tags.right - extension.right };
}

/** A column's x and width at the list width `listWidth`. */
function columnAt(column, listWidth) {
  return { x: column.left, width: Math.max(0, listWidth - column.left - column.right) };
}

function hasHeaderBand(style) {
  return style.headerBackgroundColor !== null && style.headerBackgroundColor !== undefined;
}

/** True when the header spans the column (a band or a card) instead of the whole list width. */
function isStyledHeader(style) {
  return isInsetGrouped(style) || hasHeaderBand(style);
}

/**
 * The distances from the list's edges to the header's title and fold control: the tags' edges inside the board
 * (insetGrouped: the header and the taglist always align), the band's edges plus `headerContentInsets` (a plain header
 * with a band), else `headerHorizontalInset`.
 */
function headerEdges(style) {
  const column = contentColumn(style);
  if (isInsetGrouped(style)) return tagColumn(style);
  if (hasHeaderBand(style)) {
    const band = physicalInsets(style, style.headerContentInsets);
    return { left: column.left + band.left, right: column.right + band.right };
  }
  return { left: style.headerHorizontalInset, right: style.headerHorizontalInset };
}

/** The distances from the list's edges to the header element: the column when styled, else the whole list. */
function headerBox(style) {
  return isStyledHeader(style) ? boardColumn(style) : { left: 0, right: 0 };
}

/** True when the header is sized to its text and the board follows it closely: insetGrouped with no header divider. */
function isHeaderTightToBoard(style) {
  return isInsetGrouped(style) && style.headerSeparatorStyle !== HEADER_SEPARATOR_STYLES.line;
}

/** The distance from the header's bottom to the board's top: HEADER_BOARD_SPACING for a tight header, else the section's top inset. */
function headerBoardOffset(style, hasHeader = true) {
  return hasHeader && isHeaderTightToBoard(style) ? HEADER_BOARD_SPACING : style.sectionInsets.top;
}

/**
 * The header's height (a minimum for a tight header): headerHeight, at least the title's line and 12. A tight header
 * (isHeaderTightToBoard) is the title's line plus HEADER_BOARD_TITLE_PADDING, and `headerHeight` counts only when the app set it.
 */
function headerHeightOf(style) {
  const line = lineHeight(style.headerFont.size);
  if (isHeaderTightToBoard(style)) return Math.max(style.headerHeightSet ? style.headerHeight : 0, line + HEADER_BOARD_TITLE_PADDING);
  return Math.max(style.headerHeight, line + 12);
}

/**
 * The header divider as distances from the list's edges and its thickness, or null when there is none: it has the same left
 * and right edges as the card and the header band (the column's), never the title's x; `headerSeparatorInsets` (null by
 * default) insets it from the column. It sits at the header's bottom inside the header height, so it adds no height.
 */
function headerSeparator(style) {
  if (style.headerSeparatorStyle !== HEADER_SEPARATOR_STYLES.line || !(style.headerSeparatorThickness > 0)) return null;
  const column = boardColumn(style);
  // The divider's leading / trailing insets swap sides right to left.
  const own = style.headerSeparatorInsets ? physicalInsets(style, style.headerSeparatorInsets) : null;
  return {
    left: column.left + (own ? own.left : 0),
    right: column.right + (own ? own.right : 0),
    thickness: Math.min(style.headerSeparatorThickness, headerHeightOf(style)),
  };
}

/**
 * The list background as drawn: the app's `backgroundColor` (even transparent) when set, else the grouped background under
 * insetGrouped, else the system background (`listBackground`: white in light mode, black in dark mode).
 */
function resolvedBackgroundColor(style) {
  if (style.backgroundColorSet) return style.backgroundColor;
  return isInsetGrouped(style) ? style.sectionPalette.groupedBackground : style.sectionPalette.listBackground;
}

/**
 * The card's background as drawn: `sectionBackgroundStyle`, flat where cyl-animated-item's rule says no glass (the rule of
 * the glass tags). The frames never depend on it.
 */
function resolvedSectionBackgroundStyle(style) {
  return style.sectionBackgroundStyle === SECTION_BACKGROUND_STYLES.liquidGlass && cylAnimatedItemLiquidGlassIsActive()
    ? SECTION_BACKGROUND_STYLES.liquidGlass : SECTION_BACKGROUND_STYLES.flat;
}

/** The {r, g, b, a} of a CSS color of `color()` ('#RRGGBB', rgb(), rgba()), or null. */
function rgbaOf(text) {
  const hex = /^#([0-9a-fA-F]{6})$/.exec(text);
  if (hex) {
    const n = parseInt(hex[1], 16);
    return { r: Math.floor(n / 65536) % 256, g: Math.floor(n / 256) % 256, b: n % 256, a: OPAQUE_ALPHA };
  }
  const parts = /^rgba?\(([^)]*)\)$/i.exec(String(text).trim());
  const v = parts ? parts[1].split(',').map((x) => Number(x.trim())) : [];
  if (v.length < 3 || v.slice(0, 3).some((x) => !Number.isFinite(x))) return null;
  return { r: v[0], g: v[1], b: v[2], a: v.length > 3 && Number.isFinite(v[3]) ? v[3] : OPAQUE_ALPHA };
}

/** Relative luminance (WCAG) of an opaque color text, or null when it is missing, invalid or not opaque. */
function opaqueLuminance(text) {
  const c = text ? rgbaOf(text) : null;
  if (!c || c.a < OPAQUE_ALPHA) return null;
  return relativeLuminance(c.r / RGB_MAX, c.g / RGB_MAX, c.b / RGB_MAX);
}

// MARK: - Relative luminance (the legible tint)

const SRGB_LINEAR_CUTOFF = 0.03928;
const SRGB_LINEAR_SLOPE = 12.92;
const SRGB_GAMMA = 2.4;
const SRGB_OFFSET = 0.055;
const SRGB_SCALE = 1.055;
const LUMA_RED = 0.2126;
const LUMA_GREEN = 0.7152;
const LUMA_BLUE = 0.0722;

/** WCAG relative luminance of an sRGB color, components 0..1. */
function relativeLuminance(red, green, blue) {
  const channel = (s) => (s <= SRGB_LINEAR_CUTOFF ? s / SRGB_LINEAR_SLOPE : ((s + SRGB_OFFSET) / SRGB_SCALE) ** SRGB_GAMMA);
  return LUMA_RED * channel(red) + LUMA_GREEN * channel(green) + LUMA_BLUE * channel(blue);
}

/** Whether the tag's Liquid Glass background is really drawn (the predicate of the glass background of `tagLayout`). */
function isGlassDrawn(style) {
  return style.backgroundStyle === 'liquidGlass' && cylAnimatedItemLiquidGlassIsActive();
}

/**
 * The border handed to the glass: under drawn glass an unset color or width is none (null / 0, the shared glass rim applies; the
 * selected state's built-in app-tint border included), an explicit one is kept. Flat tags hand the appearance's border unchanged.
 * @returns {{color: (string|null), width: number}}
 */
function glassHandedBorder(style, appearance) {
  if (!isGlassDrawn(style)) return { color: appearance.borderColor, width: appearance.borderWidth };
  return {
    color: appearance.borderColorExplicit ? appearance.borderColor : null,
    // A width alone draws no border; with an explicit colour the width is the explicit one, else the default.
    width: appearance.borderColorExplicit ? appearance.borderWidth : 0,
  };
}

/**
 * The color handed to the glass: under drawn glass an unset background hands none (''), else the appearance's own color.
 * Flat tags hand it unchanged.
 */
function glassHandedColor(style, appearance) {
  return isGlassDrawn(style) && !appearance.backgroundExplicit ? '' : appearance.backgroundColor;
}

/** Black on a light opaque background, white on a dark one; null when the background is not opaque. */
function tintAgainst(background) {
  const luminance = opaqueLuminance(background);
  if (luminance === null) return null;
  return luminance > TINT_LUMINANCE_THRESHOLD ? TINT_ON_LIGHT : TINT_ON_DARK;
}

/** The background the list paints itself (always one: the app's, the grouped one or the system background). */
function paintedBackground(style) {
  return resolvedBackgroundColor(style);
}

/**
 * The tint of the built-in non-tag views: `tintColor` when set, else black / white against `against` (a header band's color,
 * where one shows), else against the list's painted background, else the system mode's (`sectionPalette.dark`).
 */
function resolveTint(style, against) {
  if (style.tintColor) return style.tintColor;
  return tintAgainst(against) || tintAgainst(paintedBackground(style))
    || (style.sectionPalette && style.sectionPalette.dark ? TINT_ON_DARK : TINT_ON_LIGHT);
}

/** The header title's color: the app's `headerTextColor`, else the tint (against the band when a band shows). */
function resolvedHeaderTextColor(style) {
  return style.headerTextColorSet ? style.headerTextColor : resolveTint(style, hasHeaderBand(style) ? style.headerBackgroundColor : null);
}

/** The fold / More control's color: the app's `foldControlColor`, else the tint (against the band for a control in the header). */
function resolvedFoldControlColor(style, inHeader = false) {
  if (style.foldControlColorSet) return style.foldControlColor;
  return resolveTint(style, inHeader && hasHeaderBand(style) ? style.headerBackgroundColor : null);
}

/**
 * The card's color as drawn: its own; for drawn glass '' when unset (no color: cyl-animated-item's default frosted tint, the same one a
 * glass tag with no background gets, so the board and the tags are one glass style); else the card color of the color mode.
 */
function resolvedSectionBackgroundColor(style) {
  const fallback = resolvedSectionBackgroundStyle(style) === SECTION_BACKGROUND_STYLES.liquidGlass
    ? '' : style.sectionPalette.card;
  return style.sectionBackgroundColor || fallback;
}

/** The card's background CSS: the solid color, or the glass of the tags (blur and tint, clipped to the card's corners). */
function sectionBackgroundCSS(style) {
  const color = resolvedSectionBackgroundColor(style);
  if (resolvedSectionBackgroundStyle(style) !== SECTION_BACKGROUND_STYLES.liquidGlass) return `background-color: ${color}`;
  const glass = cylAnimatedItemBackground(SECTION_BACKGROUND_STYLES.liquidGlass, color, style.sectionCornerRadius, 0, '',
    !!style.sectionPalette.dark, -1);
  // The card has its own radius, and the tags' content inset does not apply to it.
  return glass.css.replace(/border-radius:[^;]*;/, '').replace(/--cyl-item-inset:[^;]*;/, '');
}

/** The divider's color as drawn: its own, else the system separator of the color mode. */
function resolvedHeaderSeparatorColor(style) {
  return style.headerSeparatorColor || style.sectionPalette.separator;
}

/** The CSS of a header title that wraps: at most `maxLines` lines then an ellipsis (every line when unlimited), like a tag's title. */
function headerTitleCSS(maxLines) {
  return maxLines === HEADER_TITLE_MAX_LINES.unlimited
    ? 'white-space: normal; overflow: visible; text-overflow: clip'
    : `white-space: normal; display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: ${maxLines}; overflow: hidden; text-overflow: ellipsis`;
}

/** The header's INNER WIDTH at the list width `listWidth`: between the header edges (the tag column), never negative. */
function headerInnerWidth(style, listWidth) {
  const edges = headerEdges(style);
  return Math.max(0, listWidth - edges.left - edges.right);
}

/** The fold control's width cap as a fraction of the inner width: the shared one when More, clear or an accessory also shows. */
function headerFoldMaxFraction(shared = false) {
  return shared ? HEADER_FOLD_SHARED_MAX_FRACTION : HEADER_FOLD_ALONE_MAX_FRACTION;
}

/**
 * The fold control's width: its natural width in the WIDER of the collapsed and expanded states, capped at the fraction of the
 * inner width. One number for both states, so the title room does not change when the control is toggled. Pure.
 */
function headerFoldWidth(innerWidth, collapsedWidth, expandedWidth, shared = false) {
  return Math.min(Math.max(collapsedWidth, expandedWidth), headerFoldMaxFraction(shared) * innerWidth);
}

/**
 * The title's maximum width (px): the inner width minus the fixed parts present (`fixedWidths`, the fold control's width and any
 * other part's) minus HEADER_ITEM_SPACING for each of them, never below the title's minimum (HEADER_TITLE_MIN_EM of the header
 * font, at least HEADER_TITLE_MIN_WIDTH_PX). With no fixed part it is the inner width. The title wraps to `headerMaxLines` at
 * exactly this width; the CSS reaches the same width by giving the fixed parts `flex: none` and the title `flex: 0 1 auto` with
 * `min-width` of the minimum. Pure.
 */
function headerTitleMaxWidth(style, innerWidth, fixedWidths = []) {
  const minimum = Math.max(HEADER_TITLE_MIN_WIDTH_PX, HEADER_TITLE_MIN_EM * style.headerFont.size);
  const taken = fixedWidths.reduce((sum, width) => sum + width, 0) + HEADER_ITEM_SPACING * fixedWidths.length;
  return fixedWidths.length ? Math.max(minimum, innerWidth - taken) : innerWidth;
}

/** The number of lines a title of `textWidth` px takes at `room` px, at most `maxLines` (an even split of whole lines; at least one). */
function headerTitleLines(textWidth, room, maxLines) {
  return Math.min(maxLines, Math.max(1, Math.ceil(textWidth / Math.max(1, room))));
}

/**
 * The header's height for a title of `lines` lines: the fixed (or minimum) headerHeight for a one-line header, and for a wrapping
 * one (headerMaxLines above 1) the minimum or the lines plus the wrap padding, whichever is taller; the same numbers
 * `sectionLayout` writes into the CSS (`min-height`, `padding`).
 */
function headerHeightForLines(style, lines) {
  const minimum = headerHeightOf(style);
  if (!(style.headerMaxLines > HEADER_TITLE_MAX_LINES.single)) return minimum;
  const padding = isHeaderTightToBoard(style) ? HEADER_BOARD_TITLE_PADDING / 2 : HEADER_WRAP_VERTICAL_PADDING;
  return Math.max(minimum, lines * lineHeight(style.headerFont.size) + 2 * padding);
}

/**
 * The CSS of the fold control in a section header: it never shrinks (`flex: none`), is at most the fraction of the header's
 * content box, and sits HEADER_ITEM_SPACING from the title on its leading side (the physical side swaps right to left).
 * `options.rtl`, `options.shared` (More, clear or an accessory also shows).
 */
function foldHeaderWidthCSS(options = {}) {
  const percent = Math.round(headerFoldMaxFraction(options.shared) * PERCENT_PER_FRACTION * PERCENT_PRECISION) / PERCENT_PRECISION;
  const near = options.rtl ? 'right' : 'left';
  const far = options.rtl ? 'left' : 'right';
  return `flex: none; max-width: ${percent}%; margin-${near}: ${HEADER_ITEM_SPACING}px; margin-${far}: 0`;
}

/** The CSS font size of a fold / More control: `size` px, never above FOLD_CONTROL_MAX_FONT_SIZE (the system font size scales text up). */
function foldControlFontCSS(size = FOLD_CONTROL_FONT_SIZE) {
  return `font-size: min(${size}px, ${FOLD_CONTROL_MAX_FONT_SIZE}px)`;
}

/** The CSS appended to the list's own style: `direction: rtl` right to left, nothing (byte for byte as before) left to right. */
function directionCSS(style) {
  return isRtl(style) ? '; direction: rtl' : '';
}

/**
 * The CSS of a section: its insets (the last line's spacing taken off the bottom), the negative trailing margin
 * that absorbs the last tag's spacing, the header (headerHeight, headerFont, headerTextColor, headerHorizontalInset)
 * and the list's background. `options.hasHeader` (default true) is false for a section that shows no header (its board then
 * starts at the section's top inset). It adds `cardStyle` (the default, insetGrouped), a band in `headerStyle` and `headerLineStyle`
 * (the divider, opt-in); under `sectionStyle: 'plain'` there is no `cardStyle` and the rest is what it was before the card
 * became the default.
 */
function sectionLayout(style, options = {}) {
  const i = style.sectionInsets;
  const hasHeader = options.hasHeader !== false;
  const tight = isHeaderTightToBoard(style);
  // The column's distances from the physical left and right edges (the leading / trailing sides swapped right to left).
  const column = contentColumn(style);
  const rtl = isRtl(style);
  const headerHeight = headerHeightOf(style);
  // A header title that may wrap (headerMaxLines above 1) grows the header: the height is a minimum, with a little padding.
  const wraps = style.headerMaxLines > HEADER_TITLE_MAX_LINES.single;
  // A tight header (sized to its text) only has a minimum height: the fold control may be taller than the title.
  const heightProperty = wraps || tight ? 'min-height' : 'height';
  const wrapPadding = tight ? HEADER_BOARD_TITLE_PADDING / 2 : HEADER_WRAP_VERTICAL_PADDING;
  const verticalPadding = wraps ? `${wrapPadding}px` : '0';
  const layout = {
    listStyle: `padding: ${i.top}px ${column.right}px ${Math.max(0, i.bottom - style.lineSpacing)}px ${column.left}px`,
    // The negative margin that absorbs the last tag's spacing is on the side the tags' spacing is on.
    itemsStyle: `margin-${rtl ? 'left' : 'right'}: -${style.interitemSpacing}px`,
    headerStyle: `${heightProperty}: ${headerHeight}px; padding: ${verticalPadding} ${style.headerHorizontalInset}px; ${fontCSS(style.headerFont)}; color: ${resolvedHeaderTextColor(style)}`,
    backgroundStyle: `background-color: ${resolvedBackgroundColor(style)}`,
  };
  if (wraps) layout.headerTitleStyle = headerTitleCSS(style.headerMaxLines);
  if (isInsetGrouped(style)) {
    // The card holds the last line's spacing: the tags' bottom margin is taken off inside it, not off the list's padding.
    const card = cardInsets(style);
    layout.listStyle = `padding: ${headerBoardOffset(style, hasHeader)}px ${column.right}px ${i.bottom}px ${column.left}px`;
    layout.itemsStyle += `; margin-bottom: -${style.lineSpacing}px`;
    // The list's padding is the section column (never negative); a board wider or narrower than it is moved by the card's margin.
    const board = boardColumn(style);
    const shift = board.left !== column.left || board.right !== column.right
      ? `margin: 0 ${board.right - column.right}px 0 ${board.left - column.left}px; ` : '';
    layout.cardStyle = `${shift}padding: ${card.top}px ${card.right}px ${card.bottom}px ${card.left}px; border-radius: ${style.sectionCornerRadius}px; ${sectionBackgroundCSS(style)}`;
  }
  if (isStyledHeader(style)) {
    const edges = headerEdges(style);
    const box = headerBox(style);
    const band = hasHeaderBand(style)
      ? `; background-color: ${style.headerBackgroundColor}; border-radius: ${style.headerCornerRadius}px` : '';
    layout.headerStyle = `${heightProperty}: ${headerHeight}px; margin: 0 ${box.right}px 0 ${box.left}px; padding: ${verticalPadding} ${edges.right - box.right}px ${verticalPadding} ${edges.left - box.left}px; ${fontCSS(style.headerFont)}; color: ${resolvedHeaderTextColor(style)}${band}`;
  }
  const line = headerSeparator(style);
  if (line) {
    const box = headerBox(style);
    layout.headerLineStyle = `left: ${line.left - box.left}px; right: ${line.right - box.right}px; height: ${line.thickness}px; background-color: ${resolvedHeaderSeparatorColor(style)}`;
  }
  return layout;
}

/** The value text of an offset, a size and insets, as NSCoder.string(for:) writes them ("{0, -4}", "{16, 16}"). */
function coderString(value) {
  const n = (x) => String(Math.round(x * 1000) / 1000);
  if ('horizontal' in value) return `{${n(value.horizontal)}, ${n(value.vertical)}}`;
  if ('width' in value) return `{${n(value.width)}, ${n(value.height)}}`;
  return `{${n(value.top)}, ${n(value.left)}, ${n(value.bottom)}, ${n(value.right)}}`;
}

module.exports = {
  cylAnimatedItemCornerRadiusCapsule,
  DEFAULT_STYLE, EXPAND_TITLE, COLLAPSE_TITLE, NAMED_COLORS, FONT_WEIGHTS,
  DEFAULT_TAG_BACKGROUND, opaqueBackground, tagBackground, key, parseKey, imageSize, insets, normalize, sanitizeSelection, itemAt, tap, rowsFromTops, foldState, foldTitle,
  longPressActions, longPressDecision, TITLE_MAX_LINES,
  color, numberValue, boolValue, sizeValue, offsetValue, insetsValue, fontValue, fontName, defaultStyle, mergeStyle,
  foldControlValue, animationEngine, animationKey, resolveAnimation, animationURL, animationParameters, stateOf, iconColor, tagHeight, cornerRadius,
  isVerticalPlacement, tagHeightForTitle, badgeLayout, BADGE_DEFAULT_COLOR, tagButtonView,
  iconContent, animatedIcon, tagLayout, sizerFonts, sectionLayout, coderString, fontCSS, lineHeight,
  TINT_LUMINANCE_THRESHOLD, resolveTint, resolvedHeaderTextColor, resolvedFoldControlColor,
  SECTION_STYLES, DEFAULT_SECTION_STYLE, SECTION_BACKGROUND_STYLES, resolvedSectionBackgroundStyle, HEADER_SEPARATOR_STYLES, SECTION_METRICS, SECTION_COLORS, isInsetGrouped, boardInset, cardInsets, contentColumn, tagColumn, boardColumn,
  columnAt, headerEdges, headerHeightOf, headerSeparator, resolvedBackgroundColor, resolvedSectionBackgroundColor,
  resolvedHeaderSeparatorColor,
  HEADER_TITLE_MAX_LINES, HEADER_WRAP_VERTICAL_PADDING, HEADER_BOARD_TITLE_PADDING, HEADER_BOARD_SPACING, isHeaderTightToBoard, headerBoardOffset, DIRECTIONS, DEFAULT_DIRECTION, isRtl, directionCSS,
  FOLD_CONTROL_FONT_SIZE, FOLD_CONTROL_MAX_FONT_SIZE, foldControlFontCSS,
  HEADER_ITEM_SPACING, HEADER_FOLD_ALONE_MAX_FRACTION, HEADER_FOLD_SHARED_MAX_FRACTION, HEADER_TITLE_MIN_EM, HEADER_TITLE_MIN_WIDTH_PX,
  headerInnerWidth, headerFoldMaxFraction, headerFoldWidth, headerTitleMaxWidth, headerTitleLines, headerHeightForLines, foldHeaderWidthCSS,FOLD_CONTENT_TITLE_AND_ICON, longerFoldTitle,
};
