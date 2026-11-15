import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';

export interface Place {
  name: string;
  region: string;
  rating: number;
  price: number;
}

export interface PlacesQuery {
  sql: string;
  args: string[];
}

/** The filter's regions (the iOS example's `CYLDemoDataSource.regions()`). */
export const REGIONS: string[] = ['北京 🏙️ 扩展文字', '上海', '广州', '深圳'];

const NAME = 'cyl_places.sqlite';

/**
 * The statement of the iOS example's `CYLMenuLinkageViewController.query(forTag:regions:dishes:)`: the places of a tag
 * (every tag when null) in the regions with one of the dishes (every one when empty), best rated first; values bound.
 */
export function placesQuery(tag: string | null, regions: string[], dishes: string[]): PlacesQuery {
  const conditions: string[] = [];
  const args: string[] = [];
  if (tag !== null) {
    conditions.push('tag = ?');
    args.push(tag);
  }
  if (regions.length > 0) {
    conditions.push(`region IN (${regions.map(() => '?').join(', ')})`);
    args.push(...regions);
  }
  if (dishes.length > 0) {
    conditions.push(`tag IN (${dishes.map(() => '?').join(', ')})`);
    args.push(...dishes);
  }
  const where = conditions.length > 0 ? ` WHERE ${conditions.join(' AND ')}` : '';
  return { sql: `SELECT name, region, rating, price FROM places${where} ORDER BY rating DESC, id`, args: args };
}

/**
 * The places of the shared database (`cyl_places.sqlite`, the same rows on every platform, docs/cross-platform.md),
 * copied once from rawfile into the app's database folder, so the saved selections survive a relaunch.
 */
export class PlacesDatabase {
  private store: relationalStore.RdbStore;

  private constructor(store: relationalStore.RdbStore) {
    this.store = store;
  }

  static async open(context: common.UIAbilityContext): Promise<PlacesDatabase> {
    const folder = `${context.databaseDir}/rdb`;
    const path = `${folder}/${NAME}`;
    if (!fileIo.accessSync(path)) {
      if (!fileIo.accessSync(folder)) {
        fileIo.mkdirSync(folder, true);
      }
      const bytes = context.resourceManager.getRawFileContentSync(NAME);
      const file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      fileIo.writeSync(file.fd, bytes.buffer);
      fileIo.closeSync(file);
    }
    const store = await relationalStore.getRdbStore(context, { name: NAME, securityLevel: relationalStore.SecurityLevel.S1 });
    await store.executeSql('CREATE TABLE IF NOT EXISTS selections (scenario TEXT PRIMARY KEY, items TEXT NOT NULL)');
    return new PlacesDatabase(store);
  }

  private async strings(sql: string, column: string, args: string[] = []): Promise<string[]> {
    const set = await this.store.querySql(sql, args);
    const result: string[] = [];
    while (set.goToNextRow()) {
      result.push(set.getString(set.getColumnIndex(column)));
    }
    set.close();
    return result;
  }

  /** Every tag, in database order (the filter's dishes). */
  async tags(): Promise<string[]> {
    return this.strings('SELECT tag FROM places GROUP BY tag ORDER BY MIN(id)', 'tag');
  }

  /** The categories (吃喝玩逛) in the order of their first place, each with its tags in order. */
  async categories(): Promise<Map<string, string[]>> {
    const set = await this.store.querySql('SELECT category, tag FROM places GROUP BY category, tag ORDER BY MIN(id)');
    const result = new Map<string, string[]>();
    while (set.goToNextRow()) {
      const category = set.getString(set.getColumnIndex('category'));
      const tags = result.get(category) ?? [];
      tags.push(set.getString(set.getColumnIndex('tag')));
      result.set(category, tags);
    }
    set.close();
    return result;
  }

  /** The saved "section-item" selection of a scenario, or null when none was saved. */
  async savedSelection(scenario: string): Promise<string[] | null> {
    const rows = await this.strings('SELECT items FROM selections WHERE scenario = ?', 'items', [scenario]);
    if (rows.length === 0) {
      return null;
    }
    return rows[0] === '' ? [] : rows[0].split(',');
  }

  async saveSelection(scenario: string, items: string[]): Promise<void> {
    await this.store.executeSql('INSERT OR REPLACE INTO selections (scenario, items) VALUES (?, ?)', [scenario, items.join(',')]);
  }

  async places(tag: string | null, regions: string[], dishes: string[]): Promise<Place[]> {
    const query = placesQuery(tag, regions, dishes);
    const set = await this.store.querySql(query.sql, query.args);
    const result: Place[] = [];
    while (set.goToNextRow()) {
      result.push({
        name: set.getString(set.getColumnIndex('name')),
        region: set.getString(set.getColumnIndex('region')),
        rating: set.getDouble(set.getColumnIndex('rating')),
        price: set.getLong(set.getColumnIndex('price'))
      });
    }
    set.close();
    return result;
  }
}
