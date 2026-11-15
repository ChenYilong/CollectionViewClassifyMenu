/**
 * The saved selections of the classify menu and the filter: the `selections` table (scenario TEXT PRIMARY KEY, items
 * TEXT) of the iOS, Android and Flutter examples, kept in the Mini Program's local storage under one key per
 * scenario. The items are "<section>-<item>" keys joined by commas, as in that table.
 */
const CLASSIFY_SCENARIO = 'menu.classify';
const FILTER_SCENARIO = 'menu.filter';
const PREFIX = 'cyl.selections.';

/** The storage functions of `wx`, replaceable in tests. */
function defaultStorage() {
  return {
    get: (k) => wx.getStorageSync(k),
    set: (k, v) => wx.setStorageSync(k, v),
  };
}

/** The saved items of `scenario`, or null when none were saved. */
function load(scenario, storage = defaultStorage()) {
  const value = storage.get(PREFIX + scenario);
  if (typeof value !== 'string') return null;
  return value === '' ? [] : value.split(',');
}

function save(scenario, items, storage = defaultStorage()) {
  storage.set(PREFIX + scenario, items.join(','));
}

/** Every scenario with a saved selection (the rows of the selections table). */
function savedScenarios(storage = defaultStorage(), keys = null) {
  const all = keys || (typeof wx !== 'undefined' ? wx.getStorageInfoSync().keys : []);
  return all.filter((k) => k.startsWith(PREFIX) && typeof storage.get(k) === 'string').map((k) => k.slice(PREFIX.length));
}

module.exports = { CLASSIFY_SCENARIO, FILTER_SCENARIO, PREFIX, load, save, savedScenarios };
