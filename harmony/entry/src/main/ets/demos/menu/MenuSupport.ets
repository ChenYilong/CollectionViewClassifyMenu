import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
import { hilog } from '@kit.PerformanceAnalysisKit';
/**
 * Shared parts of group B's screens: the example database (`CYLExampleDatabase`: places, row counts, saved
 * selections), the original demo's data sources (`CYLDemoDataSource`), a plain host data source
 * (`CYLExampleMenuSource`) and the inset grouped table look of the iOS screens.
 */
import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { CYLImage, CYLIndexPath, CYLMenuDataSource, CYLMenuResources, CYLMenuStyle } from '@cyl/classifymenu';
import { PlacesDatabase } from '../../data/PlacesDatabase';
import { CYL_DEMO_SECTIONS, CYLDemoItem, CYLDemoSection } from './data/CYLDemoData';

// MARK: - Database

/** A row of `SELECT name, category, tag, region, rating, price FROM places`. */
export interface CYLPlaceRow {
  name: string;
  category: string;
  tag: string;
  region: string;
  rating: number;
  price: number;
}

/** `CYLExampleSQLQuery`: a statement and its bound values. */
export class CYLExampleSQLQuery {
  readonly sql: string;
  readonly args: string[];

  constructor(sql: string, args: string[]) {
    this.sql = sql;
    this.args = args;
  }

  /** The statement with its values inlined (strings quoted), for display. */
  displayString(): string {
    const parts = this.sql.split('?');
    let result = '';
    parts.forEach((part: string, index: number) => {
      result += part;
      if (index + 1 < parts.length) {
        result += index < this.args.length ? `'${this.args[index].split('\'').join('\'\'')}'` : 'NULL';
      }
    });
    return result;
  }
}

/** `CYLExampleDatabase.shared()`: the shared places database (data/PlacesDatabase.ets) and its tables. */
export class CYLExampleDatabase {
  private static instance: Promise<CYLExampleDatabase> | undefined = undefined;
  /** Told when a demo saves a selection (the scenario list's database section changes). */
  static listeners: (() => void)[] = [];
  readonly places: PlacesDatabase;
  private store: relationalStore.RdbStore;

  private constructor(places: PlacesDatabase, store: relationalStore.RdbStore) {
    this.places = places;
    this.store = store;
  }

  static shared(context: common.UIAbilityContext): Promise<CYLExampleDatabase> {
    if (CYLExampleDatabase.instance === undefined) {
      CYLExampleDatabase.instance = (async (): Promise<CYLExampleDatabase> => {
        const places = await PlacesDatabase.open(context);
        const store = await relationalStore.getRdbStore(context,
          { name: 'cyl_places.sqlite', securityLevel: relationalStore.SecurityLevel.S1 });
        return new CYLExampleDatabase(places, store);
      })();
    }
    return CYLExampleDatabase.instance;
  }

  static addListener(listener: () => void): () => void {
    CYLExampleDatabase.listeners.push(listener);
    return () => {
      CYLExampleDatabase.listeners = CYLExampleDatabase.listeners.filter((l: () => void) => l !== listener);
    };
  }

  /** The rows of a table ("selections": every saved index path, as the iOS table has one row per path). */
  async count(table: string): Promise<number> {
    try {
      if (table === 'selections') {
        const set = await this.store.querySql('SELECT items FROM selections');
        let total = 0;
        while (set.goToNextRow()) {
          const items = set.getString(set.getColumnIndex('items'));
          total += items === '' ? 0 : items.split(',').length;
        }
        set.close();
        return total;
      }
      const set = await this.store.querySql(`SELECT COUNT(*) AS n FROM ${table}`);
      const n = set.goToFirstRow() ? set.getLong(set.getColumnIndex('n')) : 0;
      set.close();
      return n;
    } catch (error) {
      hilog.error(0x0000, 'CYLExampleDatabase', '%{public}s', JSON.stringify(error));
      throw error as Error;
    }
  }

  async rows(query: CYLExampleSQLQuery): Promise<CYLPlaceRow[]> {
    try {
      const set = await this.store.querySql(query.sql, query.args);
      const result: CYLPlaceRow[] = [];
      while (set.goToNextRow()) {
        result.push({
          name: set.getString(set.getColumnIndex('name')),
          category: set.getString(set.getColumnIndex('category')),
          tag: set.getString(set.getColumnIndex('tag')),
          region: set.getString(set.getColumnIndex('region')),
          rating: set.getDouble(set.getColumnIndex('rating')),
          price: set.getLong(set.getColumnIndex('price'))
        });
      }
      set.close();
      return result;
    } catch (error) {
      hilog.error(0x0000, 'CYLExampleDatabase', '%{public}s', JSON.stringify(error));
      throw error as Error;
    }
  }

  async savedSelection(scenario: string): Promise<CYLIndexPath[] | null> {
    const keys = await this.places.savedSelection(scenario);
    if (keys === null) {
      return null;
    }
    return keys.map((k: string): CYLIndexPath => {
      const parts = k.split('-');
      return { section: Number(parts[0]), item: Number(parts[1]) };
    });
  }

  async saveSelection(paths: CYLIndexPath[], scenario: string): Promise<void> {
    await this.places.saveSelection(scenario, paths.map((p: CYLIndexPath) => `${p.section}-${p.item}`));
    CYLExampleDatabase.listeners.forEach((l: () => void) => l());
  }
}

// MARK: - The original demo's data sources

/** `CYLDemoDataSource`: the classify menu (data.json) or the filter (regions and dishes, each led by "全部"). */
export class CYLDemoDataSource implements CYLMenuDataSource {
  readonly sections: CYLDemoSection[];
  readonly hasExclusiveFirstItem: boolean;
  menuImageForItem?: (indexPath: CYLIndexPath) => CYLImage | undefined;
  menuImageForSection?: (section: number) => CYLImage | undefined;
  menuItemIsExclusive?: (indexPath: CYLIndexPath) => boolean;

  private constructor(sections: CYLDemoSection[], hasExclusiveFirstItem: boolean) {
    this.sections = sections;
    this.hasExclusiveFirstItem = hasExclusiveFirstItem;
    this.menuImageForItem = (indexPath: CYLIndexPath): CYLImage | undefined =>
    this.sections[indexPath.section].items[indexPath.item].picture ? CYLMenuResources.image('home_btn_shrink') : undefined;
    this.menuImageForSection = (section: number): CYLImage | undefined =>
    this.hasExclusiveFirstItem ? undefined : CYLMenuResources.image('home_btn_cosmetic');
    this.menuItemIsExclusive = (indexPath: CYLIndexPath): boolean => this.hasExclusiveFirstItem && indexPath.item === 0;
  }

  static classifyDataSource(): CYLDemoDataSource {
    return new CYLDemoDataSource(CYL_DEMO_SECTIONS, false);
  }

  static filterDataSource(): CYLDemoDataSource {
    const all: CYLDemoItem = { title: CYLExampleLocalizedString('全部'), picture: false };
    const plain = (title: string): CYLDemoItem => ({ title: title, picture: false });
    const foods: CYLDemoItem[] = [all].concat(CYLDemoDataSource.allTags().map(plain));
    const regions: CYLDemoItem[] = [all].concat(CYLDemoDataSource.regions().map(plain));
    return new CYLDemoDataSource([{ type: '地区过滤', items: regions }, { type: '菜品过滤', items: foods }], true);
  }

  /** `CYLDBManager.allTags()`: every item title of data.json, in order. */
  static allTags(): string[] {
    const tags: string[] = [];
    CYL_DEMO_SECTIONS.forEach((s: CYLDemoSection) => s.items.forEach((i: CYLDemoItem) => tags.push(i.title)));
    return tags;
  }

  static regions(): string[] {
    return ['北京 🏙️ 扩展文字', '上海', '广州', '深圳']; // NOLOCALIZE: source titles (the database matches them)
  }

  /** The title without the long sample suffix ("北京 🏙️ 扩展文字" → "北京"). */
  static shortTitle(title: string): string {
    const suffixes = [' 扩展文字😀✨', ' 🏙️ 扩展文字']; // NOLOCALIZE: source suffixes
    for (const suffix of suffixes) {
      if (title.endsWith(suffix)) {
        return title.substring(0, title.length - suffix.length);
      }
    }
    return title;
  }

  /** The sample suffix of the long titles ("川菜 扩展文字😀✨"), a word of its own in the tables. */
  static readonly sampleSuffixWord: string = '扩展文字';

  /**
   * `localizedTitle(_:)`: a source title in the app's language, the name and the sample suffix each looked up
   * ("川菜 扩展文字😀✨" → "Sichuan extended text😀✨"). The source titles stay as data (the database matches them).
   */
  static localizedTitle(title: string): string {
    const short = CYLDemoDataSource.shortTitle(title);
    if (short === title) {
      return CYLExampleLocalizedString(title);
    }
    const word = CYLDemoDataSource.sampleSuffixWord;
    return CYLExampleLocalizedString(short) + title.substring(short.length).replace(word, CYLExampleLocalizedString(word));
  }

  /** `localizedShortTitle(_:)`: a source title without the sample suffix, in the app's language ("北京 🏙️ 扩展文字" → "Beijing"). */
  static localizedShortTitle(title: string): string {
    return CYLExampleLocalizedString(CYLDemoDataSource.shortTitle(title));
  }

  /** The source title of an item, as data.json and the places database hold it (for queries). */
  sourceTitle(indexPath: CYLIndexPath): string {
    return this.sections[indexPath.section].items[indexPath.item].title;
  }

  numberOfSectionsInMenu(): number {
    return this.sections.length;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.sections[section].items.length;
  }

  menuTitleForSection(section: number): string {
    return CYLExampleLocalizedString(this.sections[section].type);
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return CYLDemoDataSource.localizedTitle(this.sourceTitle(indexPath));
  }
}

// MARK: - CYLExampleMenuSource

/** `CYLExampleMenuItem`. */
export class CYLExampleMenuItem {
  title: string;
  image: CYLImage | undefined = undefined;
  selectedImage: CYLImage | undefined = undefined;
  animationURL: string | undefined = undefined;
  restingProgress: number | undefined = undefined;
  isEnabled: boolean = true;
  isExclusive: boolean = false;

  constructor(title: string) {
    this.title = title;
  }
}

/** `CYLExampleMenuSection` (with an optional style over the list's, as `CYLTagSectionKey.style`). */
export class CYLExampleMenuSection {
  title: string;
  items: CYLExampleMenuItem[];
  style: CYLMenuStyle | undefined = undefined;

  constructor(title: string, items: CYLExampleMenuItem[]) {
    this.title = title;
    this.items = items;
  }
}

/** `CYLExampleMenuSource`: a host-owned data source built from plain arrays. */
export class CYLExampleMenuSource implements CYLMenuDataSource {
  sections: CYLExampleMenuSection[];
  menuImageForItem?: (indexPath: CYLIndexPath) => CYLImage | undefined;
  menuSelectedImageForItem?: (indexPath: CYLIndexPath) => CYLImage | undefined;
  menuAnimationURLForItem?: (indexPath: CYLIndexPath) => string | undefined;
  menuAnimationRestingProgressForItem?: (indexPath: CYLIndexPath) => number | undefined;
  menuStyleForSection?: (section: number) => CYLMenuStyle | undefined;
  menuItemIsEnabled?: (indexPath: CYLIndexPath) => boolean;
  menuItemIsExclusive?: (indexPath: CYLIndexPath) => boolean;

  constructor(sections: CYLExampleMenuSection[]) {
    this.sections = sections;
    this.menuImageForItem = (p: CYLIndexPath) => this.item(p).image;
    this.menuSelectedImageForItem = (p: CYLIndexPath) => this.item(p).selectedImage;
    this.menuAnimationURLForItem = (p: CYLIndexPath) => this.item(p).animationURL;
    this.menuAnimationRestingProgressForItem = (p: CYLIndexPath) => this.item(p).restingProgress;
    this.menuStyleForSection = (s: number) => this.sections[s].style;
    this.menuItemIsEnabled = (p: CYLIndexPath) => this.item(p).isEnabled;
    this.menuItemIsExclusive = (p: CYLIndexPath) => this.item(p).isExclusive;
  }

  item(indexPath: CYLIndexPath): CYLExampleMenuItem {
    return this.sections[indexPath.section].items[indexPath.item];
  }

  numberOfSectionsInMenu(): number {
    return this.sections.length;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.sections[section].items.length;
  }

  menuTitleForSection(section: number): string {
    return this.sections[section].title;
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return this.item(indexPath).title;
  }
}

// MARK: - Look

/** UIKit system colors (light). */
export class CYLSystemColor {
  static readonly blue: string = '#007AFF';
  static readonly orange: string = '#FF9500';
  static readonly purple: string = '#AF52DE';
  static readonly teal: string = '#30B0C7';
  static readonly pink: string = '#FF2D55';
  static readonly indigo: string = '#5856D6';
  static readonly green: string = '#34C759';
  static readonly yellow: string = '#FFCC00';
  static readonly label: string = '#000000';
  static readonly secondaryLabel: string = '#993C3C43';
  static readonly separator: string = '#4A3C3C43';
  static readonly groupedBackground: string = '#F2F2F7';
  static readonly secondarySystemBackground: string = '#F2F2F7';
}

/** The header of an inset grouped table section. */
@Builder
export function cylSectionHeader(title: string) {
  Text(title)
    .fontSize(13)
    .fontColor(CYLSystemColor.secondaryLabel)
    .padding({ left: 32, right: 32, top: 16, bottom: 6 })
    .width('100%')
}

/** The footer of an inset grouped table section. */
@Builder
export function cylSectionFooter(title: string) {
  Text(title)
    .fontSize(13)
    .fontColor(CYLSystemColor.secondaryLabel)
    .padding({ left: 32, right: 32, top: 6, bottom: 8 })
    .width('100%')
}
