/**
 * The example's strings: the iOS example's CYLMenuExample.bundle (data/strings.js, exported by
 * scripts/export-miniprogram-data.py), keyed by the Chinese source text, as `CYLExampleLocalizedString` reads them.
 * The language is the one set with setLanguage() (e.g. from a launch query `lang=en`, like iOS's
 * `-CYLExampleLanguage en`), else WeChat's language; a key missing from a language is its Chinese source text.
 */
const TABLES = require('../data/strings.js');

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

/** The string for `key` (its Chinese source text) in the current language, with `args` filled in. */
function t(key, ...args) {
  const table = TABLES[language()] || {};
  const text = Object.prototype.hasOwnProperty.call(table, key) ? table[key] : key;
  return args.length ? format(text, args) : text;
}

module.exports = { t, setLanguage, language, tableFor, format };
