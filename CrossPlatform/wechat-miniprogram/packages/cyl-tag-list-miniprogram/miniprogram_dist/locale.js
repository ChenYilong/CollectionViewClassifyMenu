/**
 * The language of the tag views and the core library's strings (CollectionViewClassifyMenu/Resources/Localization/
 * *.lproj/CYLClassifyMenu.strings, exported to core-tables.js), read by `CYLMenuLocalizedString` on iOS.
 *
 * The language is the one set with setLanguage(), else WeChat's language. An app that has its own strings (as the
 * example's utils/i18n.js) reads and sets the language here, so the tags and the app always agree.
 */
const CORE_TABLES = require('./core-tables.js');

const STORAGE_KEY = 'cyl.language';
let current = null;

/** The table name for a WeChat or BCP 47 language: "en", "zh-Hant", or "zh-Hans" (the source). */
function tableFor(language) {
  const value = String(language || '').replace('_', '-').toLowerCase();
  if (value.startsWith('en')) return 'en';
  if (value === 'zh-tw' || value === 'zh-hk' || value === 'zh-mo' || value.startsWith('zh-hant')) return 'zh-Hant';
  return 'zh-Hans';
}

function systemLanguage() {
  try {
    if (typeof wx === 'undefined') return '';
    const stored = wx.getStorageSync(STORAGE_KEY);
    if (stored) return stored;
    const info = wx.getAppBaseInfo ? wx.getAppBaseInfo() : wx.getSystemInfoSync();
    return info.language || '';
  } catch (error) {
    return '';
  }
}

function language() {
  if (!current) current = tableFor(systemLanguage());
  return current;
}

/** Switches the language for this session (and, with `persist`, later launches). */
function setLanguage(value, persist = false) {
  current = tableFor(value);
  if (persist && typeof wx !== 'undefined') wx.setStorageSync(STORAGE_KEY, current);
  return current;
}

/**
 * Fills the iOS format specifiers in order: %@ %d %ld %lu %s %i, positional %1$@, and %% (a literal percent sign).
 */
function format(text, args) {
  let next = 0;
  return text.replace(/%(?:(\d+)\$)?(@|lu|ld|li|d|i|s|f|\.\d+f|%)/g, (match, position, kind) => {
    if (kind === '%') return '%';
    const index = position ? Number(position) - 1 : next++;
    const value = args[index];
    if (value === undefined) return match;
    if (/^\.\d+f$/.test(kind)) return Number(value).toFixed(Number(kind.slice(1, -1)));
    return String(value);
  });
}

/**
 * The core library's string for an identifier (e.g. "CYLMenuExpand" → 更多), as `CYLMenuLocalizedString`; the Chinese
 * (zh-Hans) one when the language has none.
 */
function tc(key, ...args) {
  const table = CORE_TABLES[language()] || {};
  const fallback = (CORE_TABLES['zh-Hans'] || {})[key];
  const text = table[key] != null ? table[key] : (fallback != null ? fallback : key);
  return args.length ? format(text, args) : text;
}

module.exports = { tc, setLanguage, language, tableFor, format, CORE_TABLES };
