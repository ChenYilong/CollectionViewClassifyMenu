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

/** The color, or the default tag fill when it is missing, invalid or fully transparent. */
function opaqueBackground(value) {
  const text = typeof value === 'string' ? value.trim().toLowerCase() : '';
  const parsed = text === 'transparent' ? null : color(value);
  if (!parsed) return DEFAULT_TAG_BACKGROUND;
  const alpha = /^rgba\([^)]*,\s*([\d.]+)\s*\)$/i.exec(parsed);
  return alpha && Number(alpha[1]) === 0 ? DEFAULT_TAG_BACKGROUND : parsed;
}

function defaultAppearance(hairline) {
  return {
    backgroundColor: DEFAULT_TAG_BACKGROUND,
    textColor: DEFAULT_TEXT_COLOR,
    font: { size: 14, weight: 'regular', italic: false },
    iconColor: null,
    cornerRadius: 3,
    borderColor: null,
    borderWidth: 0,
    contentInsets: { top: 5, left: 10, bottom: 5, right: 10 },
    backgroundImage: '',
    hairline,
  };
}

/**
 * The core's `CYLMenuStyle()`: gray bordered tags (a hairline of UIColor(white: 0.82)), green selection with white
 * titles, light gray disabled tags; 14 × 14 icons, 4 between icon and title, 30 high tags, 10 between tags and lines,
 * section insets {10, 16, 10, 16}, 36 high headers with a gray 14 pt title.
 * @param {number} pixelRatio the screen scale, for the hairline (1 / scale)
 */
function defaultStyle(pixelRatio = 2) {
  const hairline = 1 / Math.max(1, pixelRatio || 1);
  const normal = { ...defaultAppearance(hairline), borderColor: '#D1D1D1', borderWidth: hairline };
  const selected = {
    ...defaultAppearance(hairline), backgroundColor: APP_TINT_COLOR, textColor: '#FFFFFF', borderColor: APP_TINT_COLOR,
    borderWidth: hairline,
  };
  const disabled = { ...defaultAppearance(hairline), textColor: '#B3B3B3', borderColor: '#E0E0E0', borderWidth: hairline };
  return finishStyle({
    normal, selected, disabled,
    imageTitleSpacing: 4,
    itemHeight: 30,
    itemsPerRow: 0,
    interitemSpacing: 10,
    lineSpacing: 10,
    headerHeight: 36,
    animationSpeed: 1,
    layoutCentered: true,
    imagePlacement: 'leading',
    contentAlignment: 'center',
    imageSizeWH: { width: 14, height: 14 },
    animationSizeWH: { width: 0, height: 0 },
    imageInsets: { top: 0, left: 0, bottom: 0, right: 0 },
    sectionInsets: { top: 10, left: 16, bottom: 10, right: 16 },
    titlePositionAdjustment: { horizontal: 0, vertical: 0 },
    imagePositionAdjustment: { horizontal: 0, vertical: 0 },
    backgroundColor: '#FFFFFF',
    headerTextColor: '#808080',
    foldControlColor: '#808080',
    headerFont: { size: 14, weight: 'regular', italic: false },
    headerHorizontalInset: 16,
    highlightedBackgroundColor: null,
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

/** `CYLTagAppearance.applyConfiguration(_:)`: missing keys keep their values; an invalid color restores the default. */
function applyAppearance(appearance, configuration) {
  const has = (k) => Object.prototype.hasOwnProperty.call(configuration, k);
  if (has('backgroundColor')) appearance.backgroundColor = opaqueBackground(configuration.backgroundColor);
  if (has('textColor')) appearance.textColor = color(configuration.textColor) || DEFAULT_TEXT_COLOR;
  if (has('font')) appearance.font = fontValue(configuration.font) || { size: 14, weight: 'regular', italic: false };
  if (has('iconColor')) appearance.iconColor = color(configuration.iconColor);
  if (has('borderColor')) appearance.borderColor = color(configuration.borderColor);
  const sanitized = (n) => (Number.isFinite(n) && n > 0 ? n : 0);
  const radius = numberValue(configuration.cornerRadius);
  if (radius !== null) appearance.cornerRadius = sanitized(radius);
  const width = numberValue(configuration.borderWidth);
  if (width !== null) appearance.borderWidth = sanitized(width);
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
 * headerFont, highlightedBackgroundColor, tagContentInsets). `font` at the style level (an older key of this
 * component) sets the font of every state.
 */
function mergeStyle(configuration = {}, base = DEFAULT_STYLE) {
  const style = copyStyle(base);
  const c = configuration || {};
  APPEARANCE_STATES.forEach((state) => {
    if (c[state] && typeof c[state] === 'object') applyAppearance(style[state], c[state]);
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
  num('itemsPerRow', 'itemsPerRow', 0);
  num('interitemSpacing');
  num('lineSpacing');
  num('headerHeight');
  num('animationSpeed');
  num('headerHorizontalInset');
  const centered = boolValue(c.layoutCentered);
  if (centered !== null) style.layoutCentered = centered;
  const placement = String(c.imagePlacement || '').toLowerCase();
  if (['trailing', 'right', '1'].includes(placement)) style.imagePlacement = 'trailing';
  if (['leading', 'left', '0'].includes(placement)) style.imagePlacement = 'leading';
  const alignment = String(c.contentAlignment || '').toLowerCase();
  if (['leading', 'left', '1'].includes(alignment)) style.contentAlignment = 'leading';
  if (['center', '0'].includes(alignment)) style.contentAlignment = 'center';
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
  });
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

const EXPAND_TITLE = '更多';
const COLLAPSE_TITLE = '收起';

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
function foldControlValue(value) {
  const control = { position: 'none', content: 'title', title: '', collapseTitle: '', color: null };
  if (value == null) return control;
  const positions = {
    none: 'none', footer: 'footer', headertrailing: 'headerTrailing', headerright: 'headerTrailing',
    headerleading: 'headerLeading', headerleft: 'headerLeading', tail: 'tail',
  };
  const contents = { iconandtitle: 'iconAndTitle', titleandicon: 'iconAndTitle', title: 'title', icon: 'icon' };
  const dictionary = typeof value === 'object' ? value : { position: value };
  const position = positions[String(dictionary.position || '').toLowerCase()];
  if (position) control.position = position;
  const content = contents[String(dictionary.content || '').toLowerCase()];
  if (content) control.content = content;
  else if (typeof value !== 'object') control.content = control.position === 'footer' ? 'icon' : 'iconAndTitle';
  if (typeof dictionary.title === 'string') control.title = dictionary.title;
  if (typeof dictionary.collapseTitle === 'string') control.collapseTitle = dictionary.collapseTitle;
  control.color = color(dictionary.color);
  return control;
}

/**
 * The configuration with defaults: selectionMode ("none" | "single" | "multiple"), allowsEmptySelection (true, as in
 * the core), showsSectionHeaders (true), defaultVisibleRows (0 = never fold), foldControl ({position: "none" |
 * "headerTrailing" | "tail" | "footer", content: "title" | "icon" | "iconAndTitle"}), style and sections ([{title,
 * style, items: [{title, image, selectedImage, animation, animationOptions, animationRestingProgress, exclusive,
 * enabled}] }], a plain value being an item's title). `options.pixelRatio` sets the hairline of the default borders.
 */
function normalize(configuration = {}, options = {}) {
  const c = configuration || {};
  const base = options.pixelRatio ? defaultStyle(options.pixelRatio) : DEFAULT_STYLE;
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
        image: typeof item.image === 'string' ? item.image : '',
        selectedImage: typeof item.selectedImage === 'string' ? item.selectedImage : '',
        animation: typeof item.animation === 'string' ? item.animation : '',
        animationOptions: item.animationOptions && typeof item.animationOptions === 'object' ? { ...item.animationOptions } : null,
        animationRestingProgress: resting === null ? 0 : Math.min(1, Math.max(0, resting)),
        exclusive: boolValue(item.exclusive) === true,
        enabled: boolValue(item.enabled) !== false,
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
    style,
    sections,
    selectedItems: sanitizeSelection(c.selectedItems || [], sections),
  };
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

function foldTitle(expanded) {
  return expanded ? COLLAPSE_TITLE : EXPAND_TITLE;
}

// MARK: - Animations

/** Folders the iOS examples put before an animation file's path, and file name extensions of each engine. */
const ANIMATION_PREFIXES = [/^\/+/, /^(\.\.\/)+/, /^CYLMenuExample\.bundle\//, /^Animations\//];
const ENGINES = { json: 'lottie', lottie: 'lottie', gif: 'gif', pag: 'pag', riv: 'rive' };

/** The engine of an animation file by its extension ("lottie", "gif", "pag", "rive"), or ''. */
function animationEngine(animation) {
  if (/^asset:/.test(animation || '')) return 'lottie';
  const path = String(animation || '').split('#')[0].split('?')[0];
  const match = /\.([a-z0-9]+)$/i.exec(path);
  return match ? ENGINES[match[1].toLowerCase()] || '' : '';
}

/** "../Animations/Lottie/x.json", "CYLMenuExample.bundle/Animations/Lottie/x.json" → "Lottie/x.json". */
function animationKey(animation) {
  let path = String(animation || '').split('#')[0];
  ANIMATION_PREFIXES.forEach((prefix) => { path = path.replace(prefix, ''); });
  return path;
}

/**
 * The animation a tag plays, as `CYLTagButton.reloadAnimationView()` makes it: its engine must be linked
 * (`engines[name]` true) and the file must exist (in `registry`, or in the older `assets` of "asset:<name>");
 * otherwise null, and the tag shows its image, as on iOS when CYLTabBarItemAnimationFactory has no animator for the file.
 * @returns {{engine: string, key: string, entry: object}|null}
 */
function resolveAnimation(animation, registry = {}, engines = {}, assets = {}) {
  if (!animation) return null;
  const asset = /^asset:(.+)$/.exec(animation);
  if (asset) {
    return engines.lottie && assets[asset[1]] ? { engine: 'lottie', key: animation, entry: { engine: 'lottie', data: () => assets[asset[1]] } } : null;
  }
  const engine = animationEngine(animation);
  if (!engine || !engines[engine]) return null;
  const k = animationKey(animation);
  const entry = registry[k];
  return entry && entry.engine === engine ? { engine, key: k, entry } : null;
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

/** Tag height (`CYLTagButton.height(for:)`): itemHeight, or more for a line of the title font and the insets. */
function tagHeight(style) {
  return APPEARANCE_STATES.reduce((height, state) => {
    const { font, contentInsets } = style[state];
    return Math.max(height, lineHeight(font.size) + contentInsets.top + contentInsets.bottom);
  }, style.itemHeight);
}

/** Corner radius: 0 is automatic (a capsule, as for CYLBadgeAppearance); CYLTagCornerRadiusSquare (0.001) is square. */
function cornerRadius(radius, height) {
  if (radius > 0) return radius <= 0.001 ? 0 : Math.min(radius, height / 2);
  return height / 2;
}

function fontCSS(font) {
  return `font-size: ${font.size}px; font-weight: ${FONT_WEIGHTS[font.weight] || 400}; font-style: ${font.italic ? 'italic' : 'normal'}`;
}

/**
 * What the icon slot of a tag shows in a state: the animation (its engine linked and its file present), else the
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
 * The CSS of one tag (`CYLTagButton.layoutSubviews` and `width(forTitle:iconSize:style:)`): a border-box whose
 * padding is the content insets with the border inside them, the widest insets of every state so that selecting a
 * tag does not resize it; the icon slot (imageSize, or animationSize for an animation) with imageInsets taken off its
 * size from the top left; icon and title centered with imageTitleSpacing between them, a lone icon or title centered
 * with layoutCentered or kept in place (after an empty icon slot) without it; the position adjustments as offsets.
 * @param {boolean} showsAnimation whether the icon slot holds an animation
 */
function tagLayout(style, item, state, icon, interitemSpacing, lineSpacing) {
  const appearance = style[state];
  const height = tagHeight(style);
  const border = appearance.borderColor ? appearance.borderWidth : 0;
  const left = Math.max(...APPEARANCE_STATES.map((s) => style[s].contentInsets.left));
  const right = Math.max(...APPEARANCE_STATES.map((s) => style[s].contentInsets.right));
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
  const justify = leading || (!style.layoutCentered && !(showsImage && showsTitle)) ? 'flex-start' : 'center';
  const background = appearance.backgroundImage
    ? `background-image: url("${appearance.backgroundImage}"); background-size: 100% 100%`
    : '';
  const cell = [
    `height: ${height}px`,
    `padding: 0 ${Math.max(0, right - border)}px 0 ${Math.max(0, left - border)}px`,
    `margin: 0 ${interitemSpacing}px ${lineSpacing}px 0`,
    fontCSS(appearance.font),
    `border-radius: ${cornerRadius(appearance.cornerRadius, height)}px`,
    `border-width: ${border}px`,
    `border-color: ${appearance.borderColor || 'transparent'}`,
    `color: ${appearance.textColor}`,
    `background-color: ${appearance.backgroundColor}`,
    `justify-content: ${justify}`,
    `flex-direction: ${style.imagePlacement === 'trailing' ? 'row-reverse' : 'row'}`,
    background,
  ].filter(Boolean).join('; ');
  const ii = style.imageInsets;
  const io = style.imagePositionAdjustment;
  const to = style.titlePositionAdjustment;
  const gap = style.imagePlacement === 'trailing' ? 'margin-left' : 'margin-right';
  return {
    height,
    cellStyle: cell,
    slotStyle: showsImage
      ? `width: ${slot.width}px; height: ${slot.height}px; ${gap}: ${spacing}px; left: ${io.horizontal}px; top: ${io.vertical}px`
      : '',
    iconWidth: Math.max(0, slot.width - ii.left - ii.right),
    iconHeight: Math.max(0, slot.height - ii.top - ii.bottom),
    // Only the size changes; x and y stay, as CYLFlatDesignTabBarItem.imageInsets.
    iconStyle: `width: ${Math.max(0, slot.width - ii.left - ii.right)}px; height: ${Math.max(0, slot.height - ii.top - ii.bottom)}px`,
    glyphSize: Math.floor(Math.min(slot.width, slot.height) * 0.74),
    spacerStyle: emptySlot ? `width: ${emptySlot}px` : '',
    titleStyle: `left: ${to.horizontal}px; top: ${to.vertical}px`,
    showsTitle,
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

/**
 * The CSS of a section: its insets (the last line's spacing taken off the bottom), the negative trailing margin
 * that absorbs the last tag's spacing, the header (headerHeight, headerFont, headerTextColor, headerHorizontalInset)
 * and the list's background.
 */
function sectionLayout(style) {
  const i = style.sectionInsets;
  const headerHeight = Math.max(style.headerHeight, lineHeight(style.headerFont.size) + 12);
  return {
    listStyle: `padding: ${i.top}px ${i.right}px ${Math.max(0, i.bottom - style.lineSpacing)}px ${i.left}px`,
    itemsStyle: `margin-right: -${style.interitemSpacing}px`,
    headerStyle: `height: ${headerHeight}px; padding: 0 ${style.headerHorizontalInset}px; ${fontCSS(style.headerFont)}; color: ${style.headerTextColor}`,
    backgroundStyle: `background-color: ${style.backgroundColor}`,
  };
}

/** The value text of an offset, a size and insets, as NSCoder.string(for:) writes them ("{0, -4}", "{16, 16}"). */
function coderString(value) {
  const n = (x) => String(Math.round(x * 1000) / 1000);
  if ('horizontal' in value) return `{${n(value.horizontal)}, ${n(value.vertical)}}`;
  if ('width' in value) return `{${n(value.width)}, ${n(value.height)}}`;
  return `{${n(value.top)}, ${n(value.left)}, ${n(value.bottom)}, ${n(value.right)}}`;
}

module.exports = {
  DEFAULT_STYLE, EXPAND_TITLE, COLLAPSE_TITLE, NAMED_COLORS, FONT_WEIGHTS,
  DEFAULT_TAG_BACKGROUND, opaqueBackground, key, parseKey, imageSize, insets, normalize, sanitizeSelection, itemAt, tap, rowsFromTops, foldState, foldTitle,
  color, numberValue, boolValue, sizeValue, offsetValue, insetsValue, fontValue, fontName, defaultStyle, mergeStyle,
  foldControlValue, animationEngine, animationKey, resolveAnimation, stateOf, iconColor, tagHeight, cornerRadius,
  iconContent, tagLayout, sizerFonts, sectionLayout, coderString, fontCSS,
};
