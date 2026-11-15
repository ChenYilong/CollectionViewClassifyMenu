/**
 * The data and rules of the search history and discover screen, 1:1 with the iOS example's CYLSearchDiscoverData and
 * CYLSearchDiscoverViewController, without `wx` calls (node --test):
 *
 * - the data of data/search/search-discover.js (exported from the iOS bundle's <language>.lproj/search-discover.json):
 *   the file of the current language, else the Simplified Chinese one;
 * - the first discover selection (`initialTopics`) and the More button's random one (`randomTopics`), with the same
 *   generators as the Swift code: SplitMix64 (CYLSeededRandomNumberGenerator), Swift's `shuffled(using:)` (Fisher-Yates
 *   from the front) and `next(upperBound:)` (Lemire's nearly divisionless method), so a seed gives the Swift order;
 * - searching (`search`: trimmed, moved to the front of the recent searches), the field's placeholder;
 * - the layout of the recent searches folded to two rows with the fold cell as the last tag, as the core's
 *   CYLTagListView lays out an inline (tail) fold control: rows(forWidths:contentWidth:) and
 *   numberOfVisibleItems(inSection:); and the two-per-row discover grid (CYLMenuStyle.gridStyle(itemsPerRow: 2)).
 */
const i18n = require('../../utils/i18n.js');

const { t, language } = i18n;
const FILES = require('../../data/search/search-discover.js');

/*
 * UInt64 arithmetic without BigInt (which a Mini Program's compiler may not take): a value is four 16-bit limbs,
 * least significant first, so every partial product stays exact in a double.
 */
function u64(hex) {
  const digits = hex.replace(/^0x/i, '').padStart(16, '0');
  return [3, 2, 1, 0].map((i) => parseInt(digits.slice(i * 4, i * 4 + 4), 16));
}

function u64FromNumber(value) {
  let n = Math.floor(Math.abs(Number(value) || 0));
  const limbs = [0, 0, 0, 0];
  for (let i = 0; i < 4 && n > 0; i += 1) {
    limbs[i] = n % 0x10000;
    n = Math.floor(n / 0x10000);
  }
  return limbs;
}

function add64(a, b) {
  const result = [0, 0, 0, 0];
  let carry = 0;
  for (let i = 0; i < 4; i += 1) {
    const sum = a[i] + b[i] + carry;
    result[i] = sum & 0xFFFF;
    carry = sum >>> 16;
  }
  return result;
}

function xor64(a, b) {
  return a.map((limb, i) => limb ^ b[i]);
}

function shr64(a, bits) {
  const result = [0, 0, 0, 0];
  for (let bit = 0; bit < 64 - bits; bit += 1) {
    const source = bit + bits;
    if ((a[source >> 4] >>> (source & 15)) & 1) result[bit >> 4] |= 1 << (bit & 15);
  }
  return result;
}

/** The full product of two values as eight 16-bit limbs (the low four are the product modulo 2^64). */
function mulFull(a, b) {
  const result = new Array(8).fill(0);
  for (let i = 0; i < 4; i += 1) {
    let carry = 0;
    for (let j = 0; j < 4; j += 1) {
      const value = result[i + j] + a[i] * b[j] + carry;
      result[i + j] = value % 0x10000;
      carry = Math.floor(value / 0x10000);
    }
    result[i + 4] += carry;
  }
  return result;
}

function mul64(a, b) {
  return mulFull(a, b).slice(0, 4);
}

/** The value of limbs as a Number (exact below 2^53). */
function limbsToNumber(limbs) {
  return limbs.reduceRight((value, limb) => value * 0x10000 + limb, 0);
}

/** A UInt64 as a hexadecimal string ("0x…", 16 digits), for tests. */
function u64Hex(limbs) {
  return `0x${limbs.slice().reverse().map((limb) => limb.toString(16).padStart(4, '0')).join('')}`;
}

const GOLDEN_GAMMA = u64('9E3779B97F4A7C15');
const MIX_1 = u64('BF58476D1CE4E5B9');
const MIX_2 = u64('94D049BB133111EB');

/** CYLSeededRandomNumberGenerator: SplitMix64. `next()` returns a UInt64 as four 16-bit limbs. */
class SeededRandomNumberGenerator {
  constructor(seed) {
    this.state = typeof seed === 'string' ? u64(seed) : u64FromNumber(seed);
  }

  next() {
    this.state = add64(this.state, GOLDEN_GAMMA);
    let z = this.state;
    z = mul64(xor64(z, shr64(z, 30)), MIX_1);
    z = mul64(xor64(z, shr64(z, 27)), MIX_2);
    return xor64(z, shr64(z, 31));
  }
}

/** SystemRandomNumberGenerator's stand-in: 64 random bits from Math.random. */
class SystemRandomNumberGenerator {
  next() {
    return [0, 1, 2, 3].map(() => Math.floor(Math.random() * 0x10000));
  }
}

/**
 * RandomNumberGenerator.next(upperBound:) for UInt64 (Lemire's nearly divisionless method, as the Swift standard
 * library), for a bound below 2^32 (an array's count).
 */
function nextBelow(generator, upperBound) {
  const bound = Math.floor(upperBound);
  if (!(bound > 0 && bound < 0x100000000)) throw new RangeError('upperBound must be in 1..<2^32');
  const boundLimbs = u64FromNumber(bound);
  let product = mulFull(generator.next(), boundLimbs);
  // The low half compared exactly: it is below the bound only when its upper limbs are 0.
  const lowBelow = (limbs, value) => limbs[2] === 0 && limbs[3] === 0 && limbsToNumber(limbs.slice(0, 2)) < value;
  if (lowBelow(product.slice(0, 4), bound)) {
    // (0 &- upperBound) % upperBound = 2^64 mod upperBound.
    let threshold = 1;
    for (let i = 0; i < 64; i += 1) threshold = (threshold * 2) % bound;
    while (lowBelow(product.slice(0, 4), threshold)) {
      product = mulFull(generator.next(), boundLimbs);
    }
  }
  return limbsToNumber(product.slice(4, 8));
}

/** Array.shuffled(using:) as the Swift standard library shuffles: Fisher-Yates from the front. */
function shuffled(array, generator) {
  const result = array.slice();
  let amount = result.length;
  let current = 0;
  while (amount > 1) {
    const random = nextBelow(generator, amount);
    amount -= 1;
    const other = current + random;
    [result[current], result[other]] = [result[other], result[current]];
    current += 1;
  }
  return result;
}

/** CYLDiscoverTopic is Equatable: the same title and icon. */
function sameTopic(a, b) {
  return a.title === b.title && (a.icon || null) === (b.icon || null);
}

function contains(topics, topic) {
  return topics.some((other) => sameTopic(other, topic));
}

/** The demo's data when no file can be read: CYLSearchDiscoverData(version: 1, discoverCount: 6, …: []). */
const EMPTY = { version: 1, discoverCount: 6, recentSearches: [], discover: [] };

/** The file of a language ("en", "zh-Hant", "zh-Hans"; default the current one), else the Simplified Chinese one. */
function bundled(lang = language()) {
  const data = FILES[lang] || FILES['zh-Hans'];
  if (!data) return { ...EMPTY };
  return {
    version: data.version,
    discoverCount: data.discoverCount,
    recentSearches: data.recentSearches.slice(),
    discover: data.discover.map((topic) => ({ ...topic })),
  };
}

/** The first selection: the first `discoverCount` topics, so the first screen is always the same. */
function initialTopics(data) {
  return data.discover.slice(0, Math.max(0, data.discoverCount));
}

/** Another random selection of `discoverCount` topics; it differs from `current` whenever the pool allows. */
function randomTopics(data, current, generator) {
  const count = Math.min(Math.max(0, data.discoverCount), data.discover.length);
  const others = data.discover.filter((topic) => !contains(current, topic));
  // Prefer topics that are not shown now; fill up with the others when the pool is small.
  const picked = shuffled(others, generator).slice(0, count);
  if (picked.length < count) {
    const rest = shuffled(data.discover.filter((topic) => !contains(picked, topic)), generator);
    picked.push(...rest.slice(0, count - picked.length));
  }
  return picked;
}

/**
 * search(for:): the trimmed query moves to the front of the recent searches (`null` for an empty query: nothing
 * happens). @returns {{query: string, searches: string[]} | null}
 */
function search(searches, text) {
  const query = String(text || '').trim();
  if (!query) return null;
  return { query, searches: [query, ...searches.filter((value) => value !== query)] };
}

/** searchTapped(): the typed text, else the placeholder topic. */
function searchText(fieldText, placeholder) {
  return fieldText ? fieldText : placeholder || '';
}

/** The field's placeholder: the first discover topic, else 搜索. */
function placeholder(topics) {
  return topics.length ? topics[0].title : t('搜索');
}

/** The hot icon of a language (discover-hot.png of the same .lproj) and its size in points (zh 18 × 18, en 30 × 18). */
function hotIcon(lang = language()) {
  const name = FILES[lang] ? lang : 'zh-Hans';
  return { src: `/images/search/discover-hot-${name}.png`, width: name === 'en' ? 30 : 18, height: 18 };
}

/** The recent searches' look (recentStyle()) and the discover grid's (discoverStyle()), in points. */
const RECENT_STYLE = {
  itemHeight: 36, margin: 14, fontSize: 17, interitemSpacing: 12, lineSpacing: 12,
  sectionInsets: { top: 4, left: 16, bottom: 24, right: 16 },
  defaultVisibleRows: 2,
  // The inline fold cell: the margins and the 16 pt chevron (CYLTagFoldButton: iconSide 12 + 4).
  foldIconSize: 16,
};
const DISCOVER_STYLE = {
  itemsPerRow: 2, itemHeight: 36, fontSize: 17, interitemSpacing: 24, lineSpacing: 16, imageTitleSpacing: 6,
  sectionInsets: { top: 4, left: 16, bottom: 16, right: 16 },
};
const HEADER = { height: 44, fontSize: 20, horizontalInset: 16 };

function foldCellWidth(style = RECENT_STYLE) {
  return style.margin * 2 + style.foldIconSize;
}

/** rows(forWidths:contentWidth:): the item count of each row of the flow layout. */
function flowRows(widths, contentWidth, spacing) {
  const rows = [];
  let used = 0;
  let count = 0;
  widths.forEach((width) => {
    if (count > 0 && used + spacing + width > contentWidth) {
      rows.push(count);
      used = 0;
      count = 0;
    }
    used += (count > 0 ? spacing : 0) + width;
    count += 1;
  });
  if (count > 0) rows.push(count);
  return rows;
}

/**
 * numberOfVisibleItems(inSection:) of a section with an inline fold cell while folded: the items of the first
 * `visibleRows` rows, minus those of the last one the fold cell needs the room of (at least one stays).
 */
function foldedVisibleCount(widths, contentWidth, spacing, foldWidth, visibleRows) {
  const rows = flowRows(widths, contentWidth, spacing);
  let visible = 0;
  let lastRowCount = 0;
  rows.slice(0, visibleRows).forEach((count) => {
    lastRowCount = count;
    visible += count;
  });
  visible = Math.min(visible, widths.length);
  if (lastRowCount > 0) {
    let used = 0;
    for (let item = visible - lastRowCount; item < visible; item += 1) {
      used += (item > visible - lastRowCount ? spacing : 0) + widths[item];
    }
    while (lastRowCount > 1 && used + spacing + foldWidth > contentWidth) {
      used -= widths[visible - 1] + spacing;
      lastRowCount -= 1;
      visible -= 1;
    }
  }
  return visible;
}

/**
 * The recent searches as rows: each row a list of cells, {item} for a search, {fold: true} for the fold cell. The
 * section folds when its items need more than `visibleRows` rows (canFold(rowCount:)); folded, the fold cell ends the
 * last visible row; expanded, it follows the last item (and may start a row of its own).
 * @param {number[]} widths each tag's width (title + margins), as measured
 * @returns {{canFold: boolean, expanded: boolean, visibleCount: number, rows: Array<Array<{item?: number, fold?: boolean}>>}}
 */
function recentLayout(widths, options) {
  const contentWidth = options.contentWidth;
  const spacing = options.spacing != null ? options.spacing : RECENT_STYLE.interitemSpacing;
  const foldWidth = options.foldWidth != null ? options.foldWidth : foldCellWidth();
  const visibleRows = options.visibleRows != null ? options.visibleRows : RECENT_STYLE.defaultVisibleRows;
  // widths(forContentWidth:): a tag is at most as wide as the content.
  const capped = widths.map((width) => Math.min(width, contentWidth));
  const canFold = visibleRows > 0 && flowRows(capped, contentWidth, spacing).length > visibleRows;
  const expanded = canFold && !!options.expanded;
  const visibleCount = canFold && !expanded
    ? foldedVisibleCount(capped, contentWidth, spacing, foldWidth, visibleRows)
    : capped.length;
  const cells = capped.slice(0, visibleCount).map((width, item) => ({ item, width }));
  if (canFold) cells.push({ fold: true, width: foldWidth });
  const rows = [];
  let start = 0;
  flowRows(cells.map((cell) => cell.width), contentWidth, spacing).forEach((count) => {
    rows.push(cells.slice(start, start + count).map(({ item, fold }) => (fold ? { fold: true } : { item })));
    start += count;
  });
  return { canFold, expanded, visibleCount, rows };
}

/** The grid's item width (gridItemWidth(forContentWidth:itemsPerRow:)). */
function gridItemWidth(contentWidth, itemsPerRow = DISCOVER_STYLE.itemsPerRow, spacing = DISCOVER_STYLE.interitemSpacing) {
  return Math.max(1, Math.floor((contentWidth - spacing * (itemsPerRow - 1)) / itemsPerRow));
}

/** The topics in rows of `itemsPerRow`, each {index, title, hot}. */
function gridRows(topics, itemsPerRow = DISCOVER_STYLE.itemsPerRow) {
  const rows = [];
  topics.forEach((topic, index) => {
    if (index % itemsPerRow === 0) rows.push([]);
    rows[rows.length - 1].push({ index, title: topic.title, hot: topic.icon === 'hot' });
  });
  return rows;
}

/**
 * The core's own strings (CYLClassifyMenu.strings) for the fold cell: CYLMenuExpand / CYLMenuCollapse, through
 * i18n.tc() (the core's string table) when it has them, else these copies.
 */
const CORE_STRINGS = {
  'zh-Hans': { expand: '更多', collapse: '收起' },
  'zh-Hant': { expand: '更多', collapse: '收合' },
  en: { expand: 'More', collapse: 'Less' },
};

function foldTitle(expanded, lang = language()) {
  const key = expanded ? 'CYLMenuCollapse' : 'CYLMenuExpand';
  if (typeof i18n.tc === 'function' && lang === language()) {
    const text = i18n.tc(key);
    if (text && text !== key) return text;
  }
  const table = CORE_STRINGS[lang] || CORE_STRINGS['zh-Hans'];
  return expanded ? table.collapse : table.expand;
}

// MARK: - Search results

/**
 * The strings of the results view, which the iOS example does not have (its search only records the query): keyed by
 * the Chinese text, as the bundle's strings.
 */
const RESULT_STRINGS = {
  en: {
    '搜索结果': 'Results',
    '“%@” · %lu 条结果': '“%@” · %lu results',
    '没有找到“%@”的相关结果': 'No results for “%@”',
    '换个关键词试试，或者看看下面的发现': 'Try another keyword, or clear the search to browse Discover',
  },
  'zh-Hant': {
    '搜索结果': '搜尋結果',
    '“%@” · %lu 条结果': '「%@」 · %lu 條結果',
    '没有找到“%@”的相关结果': '沒有找到「%@」的相關結果',
    '换个关键词试试，或者看看下面的发现': '換個關鍵詞試試，或清除搜尋看看發現',
  },
};

function resultString(key, lang = language(), ...args) {
  const table = RESULT_STRINGS[lang] || {};
  return i18n.format(table[key] || key, args);
}

/**
 * The results of a search in the page's data: every discover topic and every sample search of the JSON file whose
 * title contains the query, ignoring case and surrounding spaces, topics first (their hot mark kept), each title once.
 * The user's own recent searches are not results (the query itself would always be found).
 * @returns {{title: string, hot: boolean, kind: 'topic'|'recent'}[]}
 */
function searchResults(data, text) {
  const query = String(text || '').trim().toLowerCase();
  if (!query) return [];
  const seen = new Set();
  const results = [];
  const add = (title, hot, kind) => {
    if (!title || seen.has(title) || !title.toLowerCase().includes(query)) return;
    seen.add(title);
    results.push({ title, hot, kind });
  };
  (data.discover || []).forEach((topic) => add(topic.title, topic.icon === 'hot', 'topic'));
  (data.recentSearches || []).forEach((value) => add(value, false, 'recent'));
  return results;
}

/** The texts of the results view for a query and its results. */
function resultTexts(query, results, lang = language()) {
  return {
    title: resultString('搜索结果', lang),
    summary: resultString('“%@” · %lu 条结果', lang, query, results.length),
    emptyTitle: resultString('没有找到“%@”的相关结果', lang, query),
    emptyHint: resultString('换个关键词试试，或者看看下面的发现', lang),
  };
}

module.exports = {
  SeededRandomNumberGenerator, SystemRandomNumberGenerator, nextBelow, shuffled, sameTopic, u64Hex,
  EMPTY, bundled, initialTopics, randomTopics, search, searchText, placeholder, hotIcon, searchResults, resultTexts,
  RECENT_STYLE, DISCOVER_STYLE, HEADER, foldCellWidth, flowRows, foldedVisibleCount, recentLayout,
  gridItemWidth, gridRows, foldTitle,
};
