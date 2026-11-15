/**
 * The state of 分类菜单 + 多选筛选 · 数据库联动, without `wx`, 1:1 with the iOS example's
 * `CYLMenuLinkageViewController`: the classify menu (data.json via CYLDemoDataSource.classifyDataSource(), single
 * choice), the multiple filter (CYLDemoDataSource.filterDataSource(): 地区过滤 and 菜品过滤, each led by an exclusive
 * 全部, with CYLMultipleFilterController's selection rules), the statement of `query(forTag:regions:dishes:)` with its
 * `displayString()`, and the status lines of `showResults()`.
 */
const db = require('../../utils/places-db.js');
const CLASSIFY = require('../../data/classify-menu.js');

/** CYLDemoDataSource.regions(). */
const REGIONS = ['北京 🏙️ 扩展文字', '上海', '广州', '深圳'];

/** CYLDBManager.allTags(): every tag of data.json, once, in order. */
const ALL_TAGS = Array.from(new Set(CLASSIFY.flatMap((section) => section.items.map((item) => item.title))));

/** The filter's sections, each led by the exclusive 全部. */
const FILTER = [
  { title: '地区过滤', items: ['全部'].concat(REGIONS) },
  { title: '菜品过滤', items: ['全部'].concat(ALL_TAGS) },
];

/** The filter's default and reset selection: 全部 in every section. */
const DEFAULT_FILTER = FILTER.map((_, section) => `${section}-0`);

/** "北京 🏙️ 扩展文字" → "北京" (CYLDemoDataSource.shortTitle(forTitle:)). */
function shortTitle(title) {
  for (const suffix of [' 扩展文字😀✨', ' 🏙️ 扩展文字']) {
    if (title.endsWith(suffix)) return title.slice(0, -suffix.length);
  }
  return title;
}

function parse(key) {
  const parts = String(key).split('-').map(Number);
  return parts.length === 2 && parts.every(Number.isInteger) ? { section: parts[0], item: parts[1] } : null;
}

function contains(key, sections) {
  const p = parse(key);
  return !!p && !!sections[p.section] && p.item >= 0 && p.item < sections[p.section].items.length;
}

/** The tag of a classify key, or null. */
function classifyTitle(key) {
  if (!key || !contains(key, CLASSIFY)) return null;
  const p = parse(key);
  return CLASSIFY[p.section].items[p.item].title;
}

/** As a tap on the classify menu: the tag, or none when it is the selected one (selectClassifyItem(at:)). */
function toggleClassify(selected, key) {
  return selected === key ? null : key;
}

/**
 * CYLMultipleFilterController's tap: an exclusive item (全部) selects itself alone in its section; another item
 * toggles and clears the exclusive one; a section left empty falls back to its 全部.
 * @param {boolean[][]} selection per section
 */
function tapFilter(selection, section, item) {
  const next = selection.map((states) => states.slice());
  const states = next[section];
  if (item === 0) {
    next[section] = states.map((_, i) => i === 0);
  } else {
    states[item] = !states[item];
    states[0] = false;
    if (!states.includes(true)) states[0] = true;
  }
  return next;
}

/** Keys ("<section>-<item>") of a selection, and back. */
function keysOf(selection) {
  const keys = [];
  selection.forEach((states, section) => states.forEach((on, item) => { if (on) keys.push(`${section}-${item}`); }));
  return keys;
}

function selectionOf(keys) {
  const selection = FILTER.map((section) => section.items.map(() => false));
  keys.forEach((key) => {
    const p = parse(key);
    if (p && contains(key, FILTER)) selection[p.section][p.item] = true;
  });
  return selection;
}

/** Whether CYLMultipleFilterController accepts the keys (no 全部 together with another item of its section). */
function isValidFilterSelection(keys) {
  const exclusive = new Set();
  const others = new Set();
  for (const key of keys) {
    const p = parse(key);
    if (!p) return false;
    if (p.item === 0 ? (exclusive.has(p.section) || others.has(p.section)) : exclusive.has(p.section)) return false;
    (p.item === 0 ? exclusive : others).add(p.section);
  }
  return true;
}

/** Regions and dishes of a filter selection, without 全部 (applyFilterSelection(_:save:)). */
function conditionsOf(keys) {
  const regions = [];
  const dishes = [];
  keys.forEach((key) => {
    const p = parse(key);
    if (!p || p.item === 0 || !contains(key, FILTER)) return;
    (p.section === 0 ? regions : dishes).push(FILTER[p.section].items[p.item]);
  });
  return { regions, dishes };
}

/** query(forTag:regions:dishes:). */
function query(tag, regions, dishes) {
  const conditions = [];
  const args = [];
  if (tag) {
    conditions.push('tag = ?');
    args.push(tag);
  }
  [['region', regions], ['tag', dishes]].forEach(([column, values]) => {
    if (!values.length) return;
    conditions.push(`${column} IN (${values.map(() => '?').join(', ')})`);
    args.push(...values);
  });
  let sql = 'SELECT name, category, tag, region, rating, price FROM places';
  if (conditions.length) sql += ` WHERE ${conditions.join(' AND ')}`;
  return { sql: `${sql} ORDER BY rating DESC, id`, args };
}

/** CYLExampleSQLQuery.displayString(): the statement with its values in place, strings quoted. */
function displayString({ sql, args }) {
  const parts = sql.split('?');
  let result = '';
  parts.forEach((part, index) => {
    result += part;
    if (index + 1 >= parts.length) return;
    const value = index < args.length ? args[index] : null;
    if (typeof value === 'string') result += `'${value.replace(/'/g, "''")}'`;
    else if (typeof value === 'number') result += String(value);
    else result += 'NULL';
  });
  return result;
}

/** The rows of the statement: name, category, tag, region, rating, price, best rated first, then by id. */
function rows(tag, regions, dishes, all = db.ROWS) {
  return all
    .filter((row) => (!tag || row.tag === tag)
      && (!regions.length || regions.includes(row.region))
      && (!dishes.length || dishes.includes(row.tag)))
    .sort((a, b) => b.rating - a.rating || a.id - b.id)
    .map(({ id, name, category, tag: rowTag, region, rating, price }) => ({ id, name, category, tag: rowTag, region, rating, price }));
}

/**
 * The status lines and the result rows of showResults(), with `t` the strings lookup.
 * @returns {{status: string, rows: {id, title, detail}[], empty: string|null}}
 */
function results(t, tag, regions, dishes, total = db.ROWS.length) {
  const all = t('全部');
  const separator = t('、');
  const names = (values) => (values.length ? values.map(shortTitle).join(separator) : all);
  const q = query(tag, regions, dishes);
  const found = rows(tag, regions, dishes);
  const status = [
    t('分类：%@ · 地区：%@ · 菜品：%@', tag ? shortTitle(tag) : all, names(regions), names(dishes)),
    displayString(q),
    t('SQLite 返回 %lu 条（共 %ld 家）', found.length, total),
  ].join('\n');
  return {
    status,
    sql: displayString(q),
    empty: found.length ? null : t('没有符合条件的商家'),
    rows: found.map((row) => ({
      id: row.id,
      title: row.name,
      detail: `${row.category} · ${shortTitle(row.tag)} · ${shortTitle(row.region)} · ★${row.rating.toFixed(1)} · ¥${row.price}`,
    })),
  };
}

module.exports = {
  CLASSIFY, REGIONS, ALL_TAGS, FILTER, DEFAULT_FILTER, shortTitle, contains, classifyTitle, toggleClassify, tapFilter,
  keysOf, selectionOf, isValidFilterSelection, conditionsOf, query, displayString, rows, results,
};
