/**
 * The example's strings: the iOS example's CYLMenuExample.bundle (data/strings.js, exported by
 * scripts/export-miniprogram-data.py), keyed by the Chinese source text, as `CYLExampleLocalizedString` reads them.
 * The language is the one set with setLanguage() (e.g. from a launch query `lang=en`, like iOS's
 * `-CYLExampleLanguage en`), else WeChat's language; a key missing from a language is its Chinese source text.
 */
const TABLES = require('../data/strings.js');
// The language lives in the tag list library, so the tags' own strings follow the example's language.
const locale = require('cyl-tag-list-miniprogram/locale.js');

const { setLanguage, language, tableFor, format, tc } = locale;

/** The string for `key` (its Chinese source text) in the current language, with `args` filled in. */
function t(key, ...args) {
  const table = TABLES[language()] || {};
  const text = Object.prototype.hasOwnProperty.call(table, key) ? table[key] : key;
  return args.length ? format(text, args) : text;
}

module.exports = { t, tc, setLanguage, language, tableFor, format };
