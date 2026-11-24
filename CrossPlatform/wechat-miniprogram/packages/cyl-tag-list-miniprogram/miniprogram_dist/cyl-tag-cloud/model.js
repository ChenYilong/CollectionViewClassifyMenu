/**
 * The model of `cyl-tag-cloud`: the core's CYLTagListView filled the android-tagview way (`addTag(_:)`,
 * `addTags(withTitles:)`, `CYLTag`), with the AndroidTagView container options (`colorTheme`, `allowsTapping`,
 * `removesItemsOnDelete`, `allowsReordering`, `defaultTagImage`, container border). It ports:
 *
 * - CYLMenuStyle and its presets `CYLMenuStyle()`, `.tagCloud()`, `.tagContainer()` (CYLMenuStyle.swift),
 *   CYLTagAppearance's defaults, and `displayedTitle(forTitle:)`;
 * - CYLTag and `style(basedOn:)` (CYLTag.swift), `CYLTag(configuration:)`;
 * - CYLTagColors and the color themes (CYLTagColors.swift);
 * - CYLTagButton's height, corner radius and delete indicator (CYLTagButton.swift);
 * - CYLTagListView's rows, selection and the tag list operations (CYLTagListView.swift).
 *
 * Colors are CSS strings. It has no `wx` calls, so it runs under Node in the tests.
 */

/** The iOS colors the samples use, as UIKit's light-mode values. */
const { iconImage } = require('./editing-icons.js');

/** The corner radius of a capsule: pass this constant, never the number 1000. 0 is square; no other value has a special meaning. */
const CYLTagCornerRadiusCapsule = 1000;
const NAMED_COLORS = {
  clear: 'rgba(0, 0, 0, 0)',
  white: '#FFFFFF',
  black: '#000000',
  gray: '#808080',
  systemBlue: '#007AFF',
  systemOrange: '#FF9500',
  systemPink: '#FF2D55',
  systemPurple: '#AF52DE',
  systemTeal: '#30B0C7',
  systemYellow: '#FFCC00',
  systemGray: '#8E8E93',
};

/** "#RGB", "#RRGGBB", "#RRGGBBAA" (red, green, blue, alpha, as `UIColor.cylMenuColor(from:)`) or a UIColor name. */
function color(value) {
  if (value == null || value === '') return null;
  const text = String(value).trim();
  if (text.startsWith('#')) {
    let hex = text.slice(1);
    if (hex.length === 3) hex = hex.split('').map((c) => c + c).join('');
    if ((hex.length !== 6 && hex.length !== 8) || !/^[0-9a-fA-F]+$/.test(hex)) return null;
    const r = parseInt(hex.slice(0, 2), 16);
    const g = parseInt(hex.slice(2, 4), 16);
    const b = parseInt(hex.slice(4, 6), 16);
    if (hex.length === 6) return `rgb(${r}, ${g}, ${b})`;
    const a = parseInt(hex.slice(6, 8), 16) / 255;
    return `rgba(${r}, ${g}, ${b}, ${round(a)})`;
  }
  const name = text.endsWith('Color') ? text.slice(0, -5) : text;
  if (NAMED_COLORS[name]) return NAMED_COLORS[name];
  return /^(rgb|rgba|hsl)\(/.test(text) ? text : null;
}

function round(value) {
  return Math.round(value * 1000) / 1000;
}

/** `UIColor(white:alpha:)`. */
function white(level, alpha = 1) {
  const v = Math.round(level * 255);
  return alpha === 1 ? `rgb(${v}, ${v}, ${v})` : `rgba(${v}, ${v}, ${v}, ${round(alpha)})`;
}

/** `UIColor(red:green:blue:alpha:)` with components 0...1. */
function rgba(r, g, b, a = 1) {
  const c = (x) => Math.round(x * 255);
  return a === 1 ? `rgb(${c(r)}, ${c(g)}, ${c(b)})` : `rgba(${c(r)}, ${c(g)}, ${c(b)}, ${round(a)})`;
}

/** A CSS color with its alpha multiplied (`withAlphaComponent` keeps the RGB). */
function withAlpha(css, alpha) {
  const match = /rgba?\(\s*(\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)/.exec(css || '');
  if (!match) return css;
  return `rgba(${match[1]}, ${match[2]}, ${match[3]}, ${round(alpha)})`;
}

/** The hairline of `CYLMenuStyle()`'s borders: 1 / screen scale. */
const HAIRLINE = 0.5;

/** CYLTagAppearance's defaults. */
function appearance() {
  return {
    backgroundColor: '#F2F2F7', // never transparent nor white on the white list: systemGray6
    textColor: white(0.25),
    fontSize: 14,
    iconColor: null,
    cornerRadius: CYLTagCornerRadiusCapsule,
    borderColor: null,
    borderWidth: 0,
    contentInsets: { top: 5, left: 10, bottom: 5, right: 10 },
    backgroundImage: null,
  };
}

const STATES = ['normal', 'selected', 'disabled'];

/** `CYLMenuStyle()`: gray bordered tags, a green selection. */
function defaultStyle() {
  const tint = rgba(42 / 255, 185 / 255, 160 / 255);
  const style = {
    normal: { ...appearance(), borderColor: white(0.82), borderWidth: HAIRLINE },
    selected: { ...appearance(), backgroundColor: tint, textColor: '#FFFFFF', borderColor: tint, borderWidth: HAIRLINE },
    disabled: { ...appearance(), textColor: white(0.7), borderColor: white(0.88), borderWidth: HAIRLINE },
    highlightedBackgroundColor: null,
    deleteIndicatorTitle: '×',
    deleteIndicatorColor: null,
    deleteIndicatorFontSize: null,
    deleteIndicatorLineWidth: 0,
    deleteIndicatorWidth: 0,
    deleteIndicatorPadding: 0,
    deleteIndicatorPlacement: 'trailing',
    rippleColor: null,
    rippleAlpha: 0.2,
    rippleDuration: 1,
    maximumTitleLength: 0,
    reversesTitleCharacters: false,
    rowAlignment: 'leading',
    headerIndicatorColor: null,
    headerIndicatorSize: { width: 3, height: 16 },
    imageCornerRadius: 0,
    // A leading image as a circle as tall as the tag, at its leading edge (AndroidTagView's avatar).
    imageFillsTagHeight: false,
    // A title too wide for its row wraps and the tag grows taller (AndroidTagView's tag_text_wrap).
    titleWraps: false,
    // A shadow under each tag, as Android's elevation in px (tag_elevation): offset down by half, blurred by half.
    elevation: 0,
    // An image as the delete indicator instead of the title or the drawn cross (setCrossDrawable).
    deleteIndicatorImage: null,
    // The space between a renamable tag's two editing icons (the edit icon and the cross) while editing (iOS 3af1b7cd).
    editingIndicatorSpacing: 10,
    // The margins around the two editing icons: left from the title, right to the tag's padding.
    editingIndicatorInsets: { top: 0, left: 4, bottom: 0, right: 0 },
    // The section header's clear button: its image (null: the core's trash icon) and color (null: the header's).
    clearButtonImage: null,
    clearButtonColor: null,
    // Equal cells, this many per row (iOS `numberOfItemsPerRow`); 0: each tag as wide as its content.
    numberOfItemsPerRow: 0,
    imageTitleSpacing: 4,
    imageSize: 14,
    itemHeight: 30,
    interitemSpacing: 10,
    lineSpacing: 10,
    sectionInsets: { top: 10, left: 16, bottom: 10, right: 16 },
    backgroundColor: '#FFFFFF',
    headerHeight: 36,
    headerFontSize: 14,
    headerTextColor: NAMED_COLORS.gray,
    headerHorizontalInset: 16,
  };
  return style;
}

/** An independent copy. */
function copyStyle(style) {
  return JSON.parse(JSON.stringify(style));
}

/** Sets the content insets of every state (`CYLMenuStyle.tagContentInsets`). */
function setTagContentInsets(style, insets) {
  for (const state of STATES) style[state].contentInsets = { ...insets };
  return style;
}

/** Applies `change` to every state's appearance. */
function forAllAppearances(style, change) {
  for (const state of STATES) change(style[state], state);
  return style;
}

/**
 * `CYLMenuStyle.tagCloud()`: android-tagview's defaults: #00BFFF capsules with white 14 pt titles and no border,
 * #88363636 while pressed, 5 × 8 pt padding, 5 pt between tags and rows.
 */
function tagCloudStyle() {
  const style = defaultStyle();
  const blue = rgba(0, 0xBF / 255, 1);
  forAllAppearances(style, (a) => {
    a.backgroundColor = blue;
    a.textColor = '#FFFFFF';
    a.borderWidth = 0;
    a.borderColor = '#FFFFFF';
    a.cornerRadius = CYLTagCornerRadiusCapsule;
    a.fontSize = 14;
  });
  style.disabled.backgroundColor = withAlpha(blue, 0.4);
  style.highlightedBackgroundColor = rgba(0x36 / 255, 0x36 / 255, 0x36 / 255, 0x88 / 255);
  setTagContentInsets(style, { top: 5, left: 8, bottom: 5, right: 8 });
  style.interitemSpacing = 5;
  style.lineSpacing = 5;
  style.itemHeight = 0;
  style.backgroundColor = NAMED_COLORS.clear;
  return style;
}

/**
 * `CYLMenuStyle.wordPicker()` (选词填入, as WeChat's "涂抹选择填入词"): one character per cell, 9 equal cells per row,
 * light gray cells with small corners that turn mint green when selected, the character centered. Use it with
 * `setTagsWithCharactersOfText`, `selectionMode` 'multiple' and `allowsSmearSelection`; the picked text is
 * `selectedText()`.
 */
function wordPickerStyle() {
  const style = defaultStyle();
  style.numberOfItemsPerRow = 9;
  forAllAppearances(style, (a) => {
    a.fontSize = 18;
    a.fontWeight = 500;
    a.cornerRadius = 3;
    a.borderWidth = 0;
    a.borderColor = null;
    a.textColor = '#1C1C1E';
    a.backgroundColor = '#F2F2F7';
  });
  // Mint green (iOS 0.70 / 0.92 / 0.81).
  style.selected.backgroundColor = '#B3EBCF';
  style.disabled.textColor = 'rgba(60, 60, 67, 0.3)';
  setTagContentInsets(style, { top: 0, left: 0, bottom: 0, right: 0 });
  style.itemHeight = 40;
  style.interitemSpacing = 6;
  style.lineSpacing = 10;
  style.sectionInsets = { top: 12, left: 24, bottom: 12, right: 24 };
  style.backgroundColor = NAMED_COLORS.clear;
  return style;
}

/**
 * The characters of `text` as a reader sees them (graphemes): a code point with the marks, variation selectors, skin
 * tones and zero-width-joined parts that follow it.
 */
function characters(text) {
  const result = [];
  let joinNext = false;
  for (const ch of Array.from(String(text || ''))) {
    const cp = ch.codePointAt(0);
    const extend = (cp >= 0x0300 && cp <= 0x036F) || (cp >= 0xFE00 && cp <= 0xFE0F) || (cp >= 0x1F3FB && cp <= 0x1F3FF)
      || (cp >= 0xE0020 && cp <= 0xE007F) || cp === 0x20E3;
    if (result.length && (extend || joinNext || cp === 0x200D)) {
      result[result.length - 1] += ch;
      joinNext = cp === 0x200D;
    } else {
      result.push(ch);
      joinNext = false;
    }
  }
  return result;
}

/**
 * A smear (`allowsSmearSelection`): `base` with the positions from `anchor` to `end` selected (`selects`) or
 * deselected, skipping disabled tags; a new array, ascending.
 */
function smearSelection(base, anchor, end, selects, tags) {
  const result = new Set(base);
  for (let i = Math.min(anchor, end); i <= Math.max(anchor, end); i += 1) {
    if (!tags[i] || tags[i].isEnabled === false) continue;
    if (selects) result.add(i);
    else result.delete(i);
  }
  return Array.from(result).sort((a, b) => a - b);
}

/**
 * `CYLMenuStyle.tagContainer()`: AndroidTagView's defaults: #33F44336 capsules (radius 15) with a 0.5 pt #88F44336
 * border and #666666 14 pt titles, #33FF7669 while selected, 10 × 8 pt padding, titles cut after 23 characters, a
 * 1 pt black cross with 10 pt padding, an #EEEEEE ripple at alpha 128.
 */
function tagContainerStyle() {
  const style = defaultStyle();
  const red = [0xF4 / 255, 0x43 / 255, 0x36 / 255];
  forAllAppearances(style, (a) => {
    a.backgroundColor = rgba(...red, 0x33 / 255);
    a.borderColor = rgba(...red, 0x88 / 255);
    a.borderWidth = 0.5;
    a.textColor = white(0x66 / 255);
    a.cornerRadius = 15;
    a.fontSize = 14;
  });
  style.selected.backgroundColor = rgba(1, 0x76 / 255, 0x69 / 255, 0x33 / 255);
  style.disabled.textColor = white(0x66 / 255, 0.5);
  setTagContentInsets(style, { top: 8, left: 10, bottom: 8, right: 10 });
  style.interitemSpacing = 5;
  style.lineSpacing = 5;
  style.itemHeight = 0;
  style.maximumTitleLength = 23;
  style.deleteIndicatorLineWidth = 1;
  style.deleteIndicatorPadding = 10;
  style.deleteIndicatorColor = '#000000';
  style.rippleColor = white(0xEE / 255);
  style.rippleAlpha = 128 / 255;
  style.backgroundColor = NAMED_COLORS.clear;
  return style;
}

/** "{top, left, bottom, right}" (the core's UIEdgeInsets string) or [t, l, b, r]. */
function parseInsets(value) {
  const numbers = Array.isArray(value) ? value.map(Number) : (String(value).match(/-?[\d.]+/g) || []).map(Number);
  if (numbers.length !== 4 || numbers.some(Number.isNaN)) return null;
  return { top: numbers[0], left: numbers[1], bottom: numbers[2], right: numbers[3] };
}

/** A state dictionary (CYLTagAppearanceKey) over an appearance. */
function applyAppearanceConfiguration(target, dictionary) {
  if (!dictionary || typeof dictionary !== 'object') return;
  if (dictionary.backgroundColor != null) target.backgroundColor = color(dictionary.backgroundColor);
  if (dictionary.textColor != null) target.textColor = color(dictionary.textColor);
  if (dictionary.borderColor != null) target.borderColor = color(dictionary.borderColor);
  if (dictionary.borderWidth != null) target.borderWidth = Math.max(0, Number(dictionary.borderWidth) || 0);
  if (dictionary.cornerRadius != null) target.cornerRadius = Math.max(0, Number(dictionary.cornerRadius) || 0);
  if (dictionary.fontSize != null) target.fontSize = Number(dictionary.fontSize);
  if (dictionary.contentInsets != null) {
    const insets = parseInsets(dictionary.contentInsets);
    if (insets) target.contentInsets = insets;
  }
}

/**
 * A style dictionary (CYLMenuStyleKey: normal / selected / disabled, highlightedBackgroundColor, lineSpacing,
 * interitemSpacing, tagContentInsets, itemHeight, backgroundColor) applied over `base` (`CYLMenuStyle()` by default,
 * as `CYLMenuStyle(configuration:)`).
 */
function styleFromConfiguration(dictionary, base = defaultStyle()) {
  const style = copyStyle(base);
  if (!dictionary || typeof dictionary !== 'object') return style;
  for (const state of STATES) applyAppearanceConfiguration(style[state], dictionary[state]);
  if (dictionary.highlightedBackgroundColor != null) {
    style.highlightedBackgroundColor = color(dictionary.highlightedBackgroundColor);
  }
  for (const key of ['lineSpacing', 'interitemSpacing', 'itemHeight', 'imageTitleSpacing']) {
    if (dictionary[key] != null) style[key] = Number(dictionary[key]);
  }
  if (dictionary.imageSize != null) {
    const match = /-?[\d.]+/.exec(String(dictionary.imageSize));
    if (match) style.imageSize = Number(match[0]);
  }
  if (dictionary.tagContentInsets != null) {
    const insets = parseInsets(dictionary.tagContentInsets);
    if (insets) setTagContentInsets(style, insets);
  }
  if (dictionary.backgroundColor != null) style.backgroundColor = color(dictionary.backgroundColor);
  return style;
}

// MARK: - Tags (CYLTag)

/** A look value that is set: finite and not negative (`CYLTag.validValue`). */
function valid(value) {
  return typeof value === 'number' && Number.isFinite(value) && value >= 0 ? value : null;
}

/**
 * A tag (CYLTag): `{ identifier, title, image, isEnabled, isDeletable, badgeText, badgeColor,
 * badgeAccessibilityLabel, imageLabel, style, textColor, textSize, backgroundColor, highlightedBackgroundColor,
 * selectedBackgroundColor, backgroundImage, cornerRadius, borderWidth, borderColor, deleteIndicatorTitle,
 * deleteIndicatorColor, deleteIndicatorSize }`. Unset look values use the list's style.
 */
function makeTag(title, options = {}) {
  return { identifier: 0, title: String(title), isEnabled: true, isDeletable: false, ...options };
}

/** `CYLTag(configuration:)`: title, image, id, enabled, deletable, style (a dictionary over `CYLMenuStyle()`). */
function tagFromConfiguration(item) {
  if (item == null || typeof item !== 'object') return makeTag(String(item));
  const tag = makeTag(item.title != null ? String(item.title) : '', {
    identifier: Number(item.id != null ? item.id : item.identifier) || 0,
    isEnabled: item.enabled !== false,
    isDeletable: item.deletable === true,
  });
  if (item.image) tag.image = item.image;
  if (item.style && typeof item.style === 'object') tag.style = styleFromConfiguration(item.style);
  return tag;
}

/** `CYLTag.colors`: background, border, text and selected background at once. */
function setTagColors(tag, colors) {
  tag.backgroundColor = colors.backgroundColor || null;
  tag.borderColor = colors.borderColor || null;
  tag.textColor = colors.textColor || null;
  tag.selectedBackgroundColor = colors.selectedBackgroundColor || null;
  return tag;
}

/** `CYLTag.hasCustomStyle`. */
function hasCustomStyle(tag) {
  return !!(tag.style || tag.textColor || valid(tag.textSize) != null || tag.backgroundColor
    || tag.highlightedBackgroundColor || tag.selectedBackgroundColor || tag.backgroundImage
    || valid(tag.cornerRadius) != null || valid(tag.borderWidth) != null || tag.borderColor
    || tag.deleteIndicatorTitle || tag.deleteIndicatorColor || valid(tag.deleteIndicatorSize) != null);
}

/**
 * `CYLTag.style(basedOn:)`: a copy of the tag's style (or of `base`) with its look: the colors to the normal state, the
 * font, corner radius and border to every state.
 */
function tagStyle(tag, base) {
  const style = copyStyle(tag.style || base);
  const normal = style.normal;
  const cornerRadius = valid(tag.cornerRadius);
  const borderWidth = valid(tag.borderWidth);
  if (tag.textColor) normal.textColor = tag.textColor;
  if (tag.backgroundColor) normal.backgroundColor = tag.backgroundColor;
  if (tag.backgroundImage) normal.backgroundImage = tag.backgroundImage;
  if (tag.borderColor) {
    normal.borderColor = tag.borderColor;
    if (borderWidth == null && normal.borderWidth <= 0) normal.borderWidth = 1;
  }
  const fontSize = valid(tag.textSize) != null && tag.textSize > 0 ? tag.textSize : null;
  for (const state of STATES) {
    if (fontSize != null) style[state].fontSize = fontSize;
    if (cornerRadius != null) style[state].cornerRadius = cornerRadius;
    if (borderWidth != null) style[state].borderWidth = borderWidth;
  }
  if (tag.highlightedBackgroundColor) style.highlightedBackgroundColor = tag.highlightedBackgroundColor;
  if (tag.selectedBackgroundColor) style.selected.backgroundColor = tag.selectedBackgroundColor;
  if (tag.deleteIndicatorTitle) style.deleteIndicatorTitle = tag.deleteIndicatorTitle;
  if (tag.deleteIndicatorColor) style.deleteIndicatorColor = tag.deleteIndicatorColor;
  const size = valid(tag.deleteIndicatorSize);
  if (size != null && size > 0) style.deleteIndicatorFontSize = size;
  return style;
}

// MARK: - Color themes (CYLTagColors)

/** ColorFactory.COLORS: RED, LIGHTBLUE, AMBER, ORANGE, YELLOW, LIME, BLUE, INDIGO, LIGHTGREEN, GREY, DEEPPURPLE, TEAL, CYAN. */
const PALETTE = ['F44336', '03A9F4', 'FFC107', 'FF9800', 'FFEB3B', 'CDDC39', '2196F3', '3F51B5', '8BC34A', '9E9E9E',
  '673AB7', '009688', '00BCD4'];

function paletteColor(hex, alpha) {
  const n = parseInt(hex, 16);
  return `rgba(${(n >> 16) & 0xFF}, ${(n >> 8) & 0xFF}, ${n & 0xFF}, ${round(alpha)})`;
}

const GRAY_666666 = 'rgb(102, 102, 102)';
const GRAY_727272 = 'rgb(114, 114, 114)';

/** `CYLTagColors(paletteHex:textColor:selectedBackgroundColor:)`: a 0x33 background and a 0x88 border. */
function paletteColors(hex, textColor, selectedBackgroundColor) {
  return {
    backgroundColor: paletteColor(hex, 0x33 / 255),
    borderColor: paletteColor(hex, 0x88 / 255),
    textColor,
    selectedBackgroundColor,
  };
}

/** `CYLTagColors(theme:seed:)`: 'random' (the palette color at `seed`), 'pureCyan', 'pureTeal'; null for 'none'. */
function themeColors(theme, seed) {
  if (theme === 'random') {
    const count = PALETTE.length;
    return paletteColors(PALETTE[((seed % count) + count) % count], GRAY_666666, GRAY_727272);
  }
  if (theme === 'pureCyan') return paletteColors('00BCD4', GRAY_727272, GRAY_666666);
  if (theme === 'pureTeal') return paletteColors('009688', GRAY_727272, GRAY_666666);
  return null;
}

/** `CYLTagColors.styleByApplying(to:)`. */
function applyColors(colors, style) {
  const result = copyStyle(style);
  const { normal, selected } = result;
  if (colors.backgroundColor) normal.backgroundColor = colors.backgroundColor;
  if (colors.textColor) {
    normal.textColor = colors.textColor;
    selected.textColor = colors.textColor;
  }
  if (colors.borderColor) {
    normal.borderColor = colors.borderColor;
    selected.borderColor = colors.borderColor;
    if (normal.borderWidth <= 0) normal.borderWidth = 1;
  }
  if (colors.selectedBackgroundColor) selected.backgroundColor = colors.selectedBackgroundColor;
  return result;
}

/**
 * The style of the tag at `index` (`CYLTagListView.style(forItemAt:)`): the tag's own look over the list's style;
 * else the theme's colors over the list's style (seed: the position), else the list's style.
 */
function styleForItem(tag, index, listStyle, theme = 'none') {
  if (hasCustomStyle(tag)) return tagStyle(tag, listStyle);
  const colors = themeColors(theme, index);
  return colors ? applyColors(colors, listStyle) : listStyle;
}

// MARK: - Titles and metrics (CYLTagButton)

/**
 * `CYLMenuStyle.displayedTitle(forTitle:)`: cut to `maximumTitleLength` characters, the last three being "..."
 * (AndroidTagView's tag_max_length: 23 gives "Welcome to use Andro..."), reversed when asked.
 */
function displayedTitle(style, title) {
  let text = title == null ? '' : String(title);
  const max = style.maximumTitleLength;
  if (max > 0 && text.length > max) {
    // NSString lengths are UTF-16 units; a cut never splits a composed character (a surrogate pair).
    let end = Math.max(0, max - 3);
    const code = end > 0 ? text.charCodeAt(end - 1) : 0;
    if (code >= 0xD800 && code <= 0xDBFF) end += 1;
    text = `${text.slice(0, end)}...`;
  }
  if (style.reversesTitleCharacters && Array.from(text).length > 1) text = Array.from(text).reverse().join('');
  return text;
}

/** The line height of the system font (SF Pro: ascender + descender + leading ≈ 1.193 × the point size). */
function lineHeight(fontSize) {
  return fontSize * 1.1934;
}

/** `CYLTagButton.height(for:)`: `itemHeight`, or a line of the title font plus the top and bottom insets. */
function tagHeight(style) {
  return STATES.reduce((height, state) => {
    const a = style[state];
    return Math.max(height, Math.ceil(lineHeight(a.fontSize)) + a.contentInsets.top + a.contentInsets.bottom);
  }, style.itemHeight || 0);
}

/** The layer's corner radius in points: 0 is square, at most half the height (half the height or more is a capsule). */
function cornerRadius(radius, height) {
  return Math.min(Number.isFinite(radius) && radius > 0 ? radius : 0, height / 2);
}

/** The cap height of a font (about 0.7 of its size). */
function capHeight(fontSize) {
  return fontSize * 0.7;
}

/** The side of one editing icon: the title's cap height x 1.25 (iOS 3af1b7cd). */
function editingIconSide(fontSize) {
  return Math.ceil(capHeight(fontSize) * 1.25);
}

/** The delete indicator's area for a drawn cross: three quarters of a line plus the padding on both sides. */
function crossIndicatorWidth(style, state = 'normal') {
  if (style.deleteIndicatorWidth > 0) return style.deleteIndicatorWidth;
  const fontSize = style.deleteIndicatorFontSize || style[state].fontSize;
  return Math.ceil(lineHeight(fontSize) * 0.75) + 2 * style.deleteIndicatorPadding;
}

/** CYLTagListView's `rows(forWidths:contentWidth:)`: items per row, in a single pass. */
function rows(widths, contentWidth, spacing) {
  const result = [];
  let used = 0;
  let count = 0;
  for (const width of widths) {
    if (count > 0 && used + spacing + width > contentWidth) {
      result.push(count);
      used = 0;
      count = 0;
    }
    used += (count > 0 ? spacing : 0) + width;
    count += 1;
  }
  if (count > 0) result.push(count);
  return result;
}

// MARK: - The list's operations (CYLTagListView)

/** Moves an element (`CYLTagDataSource.moveTag(at:to:)`); out-of-range indexes are ignored. */
function moveItem(array, from, to) {
  const result = array.slice();
  if (from === to || from < 0 || to < 0 || from >= result.length || to >= result.length) return result;
  const [item] = result.splice(from, 1);
  result.splice(to, 0, item);
  return result;
}

/** Selected indexes at or after `from` move by `offset` (`shiftSelection(inSection:fromItem:by:)`). */
function shiftSelection(selection, from, offset) {
  return selection.map((index) => (index >= from ? index + offset : index));
}

/** An item was removed: it leaves the selection and the items after it move up (`removeSelection(at:)`). */
function removeSelection(selection, index) {
  return shiftSelection(selection.filter((i) => i !== index), index + 1, -1);
}

/** The selection moves with a moved item (`collectionView(_:moveItemAt:to:)`). */
function moveSelection(selection, from, to) {
  return selection.map((index) => {
    if (index === from) return to;
    if (from < to && index > from && index <= to) return index - 1;
    if (from > to && index >= to && index < from) return index + 1;
    return index;
  });
}

/**
 * `toggleSelection(at:)`: deselects a selected item, else selects it; in 'none' mode (where taps never select) it
 * adds any number of items, as AndroidTagView's long press; 'single' keeps one.
 */
function toggleSelection(selection, index, mode = 'none') {
  if (selection.includes(index)) return selection.filter((i) => i !== index);
  if (mode === 'single') return [index];
  return selection.concat(index).sort((a, b) => a - b);
}

/**
 * `handleTap(at:)` for one of the tags: in 'none' mode the tag is reported only; 'single' and 'multiple' select an
 * unselected tag (single: alone), deselect a selected one when `allowsEmptySelection` or others are selected.
 */
function tapSelection(selection, index, mode = 'none', allowsEmptySelection = true) {
  if (mode === 'none') return selection;
  if (selection.includes(index)) {
    return allowsEmptySelection || selection.length > 1 ? selection.filter((i) => i !== index) : selection;
  }
  return mode === 'single' ? [index] : selection.concat(index).sort((a, b) => a - b);
}

// MARK: - Rendering

function px(value) {
  return `${round(value)}px`;
}

/**
 * The render data of one tag: its box (height, insets, background, border as an inset shadow — a CALayer border is
 * drawn inside the bounds — corner radius), title, icon or badge, delete indicator (text or drawn cross) and its
 * accessibility label.
 */
function renderTag(tag, index, context) {
  const { listStyle, theme, selection = [], pressed = -1, defaultTagImage = '', dragging = -1, editing = false,
    renamable = false } = context;
  const style = styleForItem(tag, index, listStyle, theme);
  const enabled = tag.isEnabled !== false;
  const selected = selection.includes(index);
  const state = !enabled ? 'disabled' : (selected ? 'selected' : 'normal');
  const a = style[state];
  const height = tagHeight(style);
  const insets = a.contentInsets;
  const isPressed = pressed === index && enabled && !!style.highlightedBackgroundColor;
  const background = isPressed ? style.highlightedBackgroundColor : a.backgroundColor;
  const borderWidth = a.borderColor ? a.borderWidth : 0;
  const radius = cornerRadius(a.cornerRadius, height);
  const parts = [
    // A wrapping title (`titleWraps`) lets the tag grow taller than one line.
    style.titleWraps ? `min-height: ${px(height)}; height: auto` : `height: ${px(height)}`,
    `padding: ${px(insets.top)} ${px(insets.right)} ${px(insets.bottom)} ${px(insets.left)}`,
    `border-radius: ${px(radius)}`,
    `background-color: ${background || 'transparent'}`,
  ];
  if (style.numberOfItemsPerRow > 0) {
    // Equal cells (iOS `numberOfItemsPerRow`): the row's width less the spaces, shared out.
    const n = style.numberOfItemsPerRow;
    parts.push(`width: calc((100% - ${px((n - 1) * style.interitemSpacing)}) / ${n})`, 'flex: none');
  }
  if (a.backgroundImage && !isPressed) parts.push(`background-image: ${a.backgroundImage}`);
  if (dragging === index) parts.push('opacity: 0.8; transform: scale(1.08); z-index: 2');
  const shadows = [];
  if (borderWidth > 0) shadows.push(`inset 0 0 0 ${px(borderWidth)} ${a.borderColor}`);
  // `elevation`: a shadow under the tag; the tag stops clipping (the shadow is outside it).
  if (style.elevation > 0) {
    shadows.push(`0 ${px(style.elevation / 2)} ${px(style.elevation)} rgba(0, 0, 0, 0.25)`);
    parts.push('overflow: visible');
  }
  if (style.titleWraps) parts.push('white-space: normal');
  if (shadows.length) parts.push(`box-shadow: ${shadows.join(', ')}`);

  const spacing = style.imageTitleSpacing;
  // Editing (`isEditing`): every enabled tag shows its delete indicator, the cloud being one editable section.
  const deletable = (editing || !!tag.isDeletable) && enabled;
  const leading = style.deleteIndicatorPlacement === 'leading';
  let deleteIndicator = null;
  let editingIcons = null;
  if (deletable && renamable && editing) {
    // A renamable tag (iOS `CYLTagButton.showsRenameIndicator`): the edit icon then the cross, each slot the title's
    // cap height x 1.25 with the glyph filling it, `editingIndicatorSpacing` apart, `editingIndicatorInsets` around.
    const color = style.deleteIndicatorColor || a.textColor;
    const side = editingIconSide(a.fontSize);
    const m = style.editingIndicatorInsets || { top: 0, left: 4, bottom: 0, right: 0 };
    const gap = Math.max(0, style.editingIndicatorSpacing);
    const left = Math.max(0, m.left);
    const right = Math.max(0, m.right);
    const half = gap / 2;
    editingIcons = {
      // Each hit area runs the tag's full height; they meet halfway between the icons.
      renameStyle: `margin: -${px(insets.top)} 0 -${px(insets.bottom)} 0; padding: 0 ${px(half)} 0 ${px(spacing + left)}`,
      deleteStyle: `margin: -${px(insets.top)} -${px(insets.right)} -${px(insets.bottom)} 0; `
        + `padding: 0 ${px(insets.right + right)} 0 ${px(gap - half)}`,
      iconStyle: `width: ${px(side)}; height: ${px(side)}`,
      renameImage: iconImage('rename', color),
      deleteImage: iconImage('delete', color),
      width: spacing + left + 2 * side + gap + right,
    };
  } else if (deletable) {
    const indicatorColor = style.deleteIndicatorColor || a.textColor;
    // The hit area reaches the tag's edge and its full height (`deleteIndicatorHitFrame`).
    const hit = leading
      ? `margin: -${px(insets.top)} 0 -${px(insets.bottom)} -${px(insets.left)}; padding: 0 ${px(spacing)} 0 ${px(insets.left)}`
      : `margin: -${px(insets.top)} -${px(insets.right)} -${px(insets.bottom)} 0; padding: 0 ${px(insets.right)} 0 ${px(spacing)}`;
    if (style.deleteIndicatorImage) {
      // A square image as tall as a line of the indicator font, the padding only beside it, so a one-line tag keeps
      // it (on iOS it vanished while the padding was also taken above it).
      const size = style.deleteIndicatorFontSize || a.fontSize;
      const side = Math.ceil(lineHeight(size));
      deleteIndicator = {
        cross: false,
        image: style.deleteIndicatorImage,
        style: hit,
        boxStyle: `width: ${px(side + 2 * style.deleteIndicatorPadding)}`,
        imageStyle: `width: ${px(side)}; height: ${px(side)}`,
      };
    } else if (style.deleteIndicatorLineWidth > 0) {
      const width = crossIndicatorWidth(style, state);
      const side = Math.max(0, width - 2 * style.deleteIndicatorPadding);
      deleteIndicator = {
        cross: true,
        style: hit,
        boxStyle: `width: ${px(width)}`,
        lineStyle: `width: ${px(side * Math.SQRT2)}; height: ${px(style.deleteIndicatorLineWidth)}; `
          + `background-color: ${indicatorColor}`,
      };
    } else {
      const size = style.deleteIndicatorFontSize || a.fontSize;
      deleteIndicator = {
        cross: false,
        text: style.deleteIndicatorTitle,
        style: hit,
        boxStyle: `font-size: ${px(size)}; color: ${indicatorColor}`,
      };
    }
  }

  const imageSize = style.imageSize;
  let icon = null;
  const image = tag.image || defaultTagImage;
  const title = displayedTitle(style, tag.title);
  // The spacing only between an icon and a title.
  const iconMargin = title.length > 0 ? `margin-right: ${px(spacing)}` : '';
  if (image && style.imageFillsTagHeight) {
    // `CYLMenuStyle.imageFillsTagHeight`: a circle as tall as the tag at its leading edge (after a leading delete
    // indicator), reaching over the insets; the title follows it.
    const deleteFirst = !!deleteIndicator && leading;
    icon = {
      image,
      mode: 'aspectFill',
      style: `width: ${px(height)}; height: ${px(height)}; border-radius: ${px(height / 2)}; `
        + `margin: -${px(insets.top)} ${title.length > 0 ? px(spacing) : '0'} -${px(insets.bottom)} `
        + `${deleteFirst ? '0' : `-${px(insets.left)}`}`,
    };
  } else if (image) {
    const imageRadius = style.imageCornerRadius > 0 ? Math.min(style.imageCornerRadius, imageSize / 2) : 0;
    icon = {
      image,
      mode: imageRadius > 0 ? 'aspectFill' : 'aspectFit',
      style: `width: ${px(imageSize)}; height: ${px(imageSize)}; border-radius: ${px(imageRadius)}; ${iconMargin}`,
    };
  } else if (tag.badgeText) {
    // `CYLTag.badgeImage`: white bold text on a circle of the badge color (the title color by default).
    const diameter = imageSize > 0 ? imageSize : 16;
    icon = {
      badge: tag.badgeText,
      style: `width: ${px(diameter)}; height: ${px(diameter)}; font-size: ${px(diameter * 0.6)}; `
        + `background-color: ${tag.badgeColor || tag.textColor || NAMED_COLORS.systemBlue}; ${iconMargin}`,
    };
  }
  const value = tag.badgeAccessibilityLabel || tag.badgeText || tag.imageLabel || '';
  return {
    key: tag._key != null ? tag._key : index,
    index,
    title,
    hasTitle: title.length > 0,
    titleStyle: `font-size: ${px(a.fontSize)}; color: ${a.textColor}${a.fontWeight ? `; font-weight: ${a.fontWeight}` : ''}`
      + (style.titleWraps ? '; white-space: normal; word-break: break-word' : ''),
    style: parts.join('; '),
    icon,
    deleteIndicator,
    deleteFirst: !!deleteIndicator && leading,
    editingIcons,
    selected,
    enabled,
    rippleColor: style.rippleColor ? withAlpha(style.rippleColor, Math.min(1, Math.max(0, style.rippleAlpha))) : '',
    rippleDuration: style.rippleDuration > 0 ? style.rippleDuration : 1,
    accessibilityLabel: value ? `${tag.title}, ${value}` : String(tag.title),
  };
}

// Trailing, as AndroidTagView's container_gravity="right" (and iOS since 1d1f7904): each row's first tag at the trailing
// edge, the next ones before it, so the rows run reversed from the trailing edge.
const ROW_ALIGNMENT = { leading: 'flex-start', center: 'center', trailing: 'flex-start; flex-direction: row-reverse' };

/** The list's own render data: the background, the container border, the section insets and spacing, the header. */
/** The row of each item from the tops of their frames (a new row where the top moves by more than 1 px). */
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
 * Folding to `limit` rows with the fold control as the last tag (iOS `defaultVisibleRows` + `CYLMenuFoldControl`
 * position tail): from the items' frames (every item shown, `{left, top, right}`), the right edge of the row, the fold
 * control's width and the space between tags. While folded, the items after row `limit` are hidden, and so are the last
 * items of row `limit` that leave no room for the control after them. Returns `{canFold, visible}`.
 */
function foldVisibility({ rects = [], containerRight = 0, tailWidth = 0, spacing = 0, limit = 0, expanded = false }) {
  const rows = rowsFromTops(rects.map((rect) => rect.top));
  const rowCount = rows.length ? rows[rows.length - 1] + 1 : 0;
  const canFold = limit > 0 && rowCount > limit;
  const visible = rows.map((row) => !canFold || expanded || row < limit);
  if (!canFold || expanded) return { canFold, visible };
  let last = visible.lastIndexOf(true);
  while (last >= 0 && rows[last] === limit - 1 && rects[last].right + spacing + tailWidth > containerRight) {
    // The control goes where this item was, if it fits there.
    const start = rects[last].left;
    visible[last] = false;
    if (start + tailWidth <= containerRight) break;
    last -= 1;
  }
  return { canFold, visible };
}

function renderList(listStyle, options = {}) {
  const insets = listStyle.sectionInsets;
  const root = [`background-color: ${listStyle.backgroundColor || 'transparent'}`];
  if (options.containerBorderWidth > 0 && options.containerBorderColor) {
    root.push(`border: ${px(options.containerBorderWidth)} solid ${options.containerBorderColor}`);
  }
  if (options.containerCornerRadius > 0) root.push(`border-radius: ${px(options.containerCornerRadius)}`);
  const headerHeight = Math.max(listStyle.headerHeight, Math.ceil(lineHeight(listStyle.headerFontSize)) + 12);
  return {
    rootStyle: root.join('; '),
    bodyStyle: `padding: ${px(insets.top)} ${px(insets.right)} ${px(insets.bottom)} ${px(insets.left)}`,
    itemsStyle: `gap: ${px(listStyle.lineSpacing)} ${px(listStyle.interitemSpacing)}; `
      + `justify-content: ${ROW_ALIGNMENT[listStyle.rowAlignment] || 'flex-start'}`,
    headerStyle: `height: ${px(headerHeight)}; padding: 0 ${px(listStyle.headerHorizontalInset)}; `
      + `font-size: ${px(listStyle.headerFontSize)}; color: ${listStyle.headerTextColor}`,
    headerIndicatorStyle: listStyle.headerIndicatorColor
      ? `width: ${px(listStyle.headerIndicatorSize.width)}; height: ${px(listStyle.headerIndicatorSize.height)}; `
        + `background-color: ${listStyle.headerIndicatorColor}`
      : '',
  };
}

module.exports = {
  CYLTagCornerRadiusCapsule,
  NAMED_COLORS,
  PALETTE,
  color,
  white,
  rgba,
  withAlpha,
  defaultStyle,
  tagCloudStyle,
  tagContainerStyle,
  copyStyle,
  setTagContentInsets,
  forAllAppearances,
  styleFromConfiguration,
  parseInsets,
  makeTag,
  tagFromConfiguration,
  setTagColors,
  hasCustomStyle,
  tagStyle,
  themeColors,
  applyColors,
  styleForItem,
  displayedTitle,
  lineHeight,
  tagHeight,
  cornerRadius,
  crossIndicatorWidth,
  rows,
  moveItem,
  shiftSelection,
  removeSelection,
  moveSelection,
  toggleSelection,
  tapSelection,
  renderTag,
  renderList,
  capHeight,
  editingIconSide,
  rowsFromTops,
  foldVisibility,
  wordPickerStyle,
  characters,
  smearSelection,
};
