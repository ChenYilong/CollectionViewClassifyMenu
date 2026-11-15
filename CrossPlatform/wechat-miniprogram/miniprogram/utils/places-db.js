/**
 * The places of the shared database (Example-Shared/Database/cyl_places.sqlite, docs/cross-platform.md), read from
 * the module exported from that file (scripts/export-miniprogram-data.py), and the statement of the iOS example's
 * `CYLMenuLinkageViewController.query(forTag:regions:dishes:)` run on them. A Mini Program has no SQLite, so this
 * module builds the same SQL text (shown on the page) and applies the same conditions and order in JavaScript.
 */
const ROWS = require('../data/places.js');

/** The filter's regions (the iOS example's `CYLDemoDataSource.regions()`). */
const REGIONS = ['北京 🏙️ 扩展文字', '上海', '广州', '深圳'];

/** Every tag, in database order: `SELECT tag FROM places GROUP BY tag ORDER BY MIN(id)`. */
function tags(rows = ROWS) {
  const seen = new Set();
  const result = [];
  rows.forEach((row) => {
    if (!seen.has(row.tag)) {
      seen.add(row.tag);
      result.push(row.tag);
    }
  });
  return result;
}

/**
 * The categories (吃喝玩逛) in the order of their first place, each with its tags in order:
 * `SELECT category, tag FROM places GROUP BY category, tag ORDER BY MIN(id)`.
 * @returns {{title: string, tags: string[]}[]}
 */
function categories(rows = ROWS) {
  const byTitle = new Map();
  rows.forEach((row) => {
    if (!byTitle.has(row.category)) byTitle.set(row.category, []);
    const list = byTitle.get(row.category);
    if (!list.includes(row.tag)) list.push(row.tag);
  });
  return Array.from(byTitle, ([title, list]) => ({ title, tags: list }));
}

/**
 * The statement and its arguments for a tag (every tag when null), regions and dishes (every one when empty).
 * @returns {{sql: string, args: string[]}}
 */
function statement({ tag = null, regions = [], dishes = [] } = {}) {
  const conditions = [];
  const args = [];
  if (tag != null) {
    conditions.push('tag = ?');
    args.push(tag);
  }
  [['region', regions], ['tag', dishes]].forEach(([column, values]) => {
    if (!values.length) return;
    conditions.push(`${column} IN (${values.map(() => '?').join(', ')})`);
    args.push(...values);
  });
  const where = conditions.length ? ` WHERE ${conditions.join(' AND ')}` : '';
  return { sql: `SELECT name, region, rating, price FROM places${where} ORDER BY rating DESC, id`, args };
}

/** The places matching the statement, best rated first, then by id. */
function places({ tag = null, regions = [], dishes = [] } = {}, rows = ROWS) {
  return rows
    .filter((row) => (tag == null || row.tag === tag)
      && (!regions.length || regions.includes(row.region))
      && (!dishes.length || dishes.includes(row.tag)))
    .sort((a, b) => b.rating - a.rating || a.id - b.id)
    .map(({ id, name, region, rating, price }) => ({ id, name, region, rating, price }));
}

module.exports = { ROWS, REGIONS, tags, categories, statement, places };
