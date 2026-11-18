import { moveAssetsDatabase, open, type DB } from '@op-engineering/op-sqlite';

type Row = Record<string, unknown>;

/**
 * The places of the shared database (`cyl_places.sqlite`, the same rows on every platform, docs/cross-platform.md),
 * copied once from the app bundle (iOS) / assets/custom (Android), so the saved selections survive a relaunch.
 */
export class PlacesDatabase {
  private constructor(private readonly db: DB) {}

  static async open(): Promise<PlacesDatabase> {
    await moveAssetsDatabase({ filename: 'cyl_places.sqlite' });
    const db = open({ name: 'cyl_places.sqlite' });
    await db.execute('CREATE TABLE IF NOT EXISTS selections (scenario TEXT PRIMARY KEY, items TEXT NOT NULL)');
    return new PlacesDatabase(db);
  }

  /**
   * The filter's regions (the iOS example's `CYLDemoDataSource.regions()`).
   */
  static readonly regions = ['北京 🏙️ 扩展文字', '上海', '广州', '深圳']; // NOLOCALIZE: source titles (queries match them)

  private async rows(sql: string, args: unknown[] = []): Promise<Row[]> {
    return (await this.db.execute(sql, args as never[])).rows as Row[];
  }

  /**
   * Every tag, in database order (the filter's dishes).
   */
  async tags(): Promise<string[]> {
    return (await this.rows('SELECT tag FROM places GROUP BY tag ORDER BY MIN(id)')).map((r) => r.tag as string);
  }

  /**
   * The categories (吃喝玩逛) in the order of their first place, each with its tags in order.
   */
  async categories(): Promise<[string, string[]][]> {
    const result = new Map<string, string[]>();
    for (const r of await this.rows('SELECT category, tag FROM places GROUP BY category, tag ORDER BY MIN(id)')) {
      const category = r.category as string;
      result.set(category, [...(result.get(category) ?? []), r.tag as string]);
    }
    return [...result.entries()];
  }

  /**
   * The saved "section-item" selection of a scenario, or null when none was saved.
   */
  async savedSelection(scenario: string): Promise<string[] | null> {
    const rows = await this.rows('SELECT items FROM selections WHERE scenario = ?', [scenario]);
    if (rows.length === 0) return null;
    const items = rows[0]!.items as string;
    return items === '' ? [] : items.split(',');
  }

  async saveSelection(scenario: string, items: string[]): Promise<void> {
    await this.db.execute('INSERT OR REPLACE INTO selections (scenario, items) VALUES (?, ?)', [
      scenario,
      items.join(','),
    ]);
  }

  /**
   * The places of a tag (every tag when null) in the regions with one of the dishes (every one when empty), best rated
   * first: the statement of the iOS example's `CYLMenuLinkageViewController.query(forTag:regions:dishes:)`.
   */
  async places(tag: string | null, regions: string[], dishes: string[]): Promise<Row[]> {
    const query = placesQuery(tag, regions, dishes);
    return this.rows(query.sql, query.args);
  }
}

/**
 * The statement of the iOS example's `CYLMenuLinkageViewController.query(forTag:regions:dishes:)`: the places of a tag
 * (every tag when null) in the regions with one of the dishes (every one when empty), best rated first; values bound.
 */
export function placesQuery(tag: string | null, regions: string[], dishes: string[]): { sql: string; args: string[] } {
  const conditions: string[] = [];
  const args: string[] = [];
  if (tag != null) {
    conditions.push('tag = ?');
    args.push(tag);
  }
  for (const [column, values] of [
    ['region', regions],
    ['tag', dishes],
  ] as const) {
    if (values.length === 0) continue;
    conditions.push(`${column} IN (${values.map(() => '?').join(', ')})`);
    args.push(...values);
  }
  const where = conditions.length ? ` WHERE ${conditions.join(' AND ')}` : '';
  return { sql: `SELECT name, region, rating, price FROM places${where} ORDER BY rating DESC, id`, args };
}
