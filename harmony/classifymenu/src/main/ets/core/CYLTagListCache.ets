/**
 * The cache of a tag list's edited sections (iOS `CYLTagListCache.swift`), so an order changed in editing mode (a
 * drag), a deleted tag or an added one survives a relaunch: a database (`relationalStore`), the app's `preferences`
 * (NSUserDefaults on iOS) or a JSON file in the app's sandbox, behind one store.
 */
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { preferences, relationalStore } from '@kit.ArkData';
import { CYLUIContext } from './CYLUIContext';

/** `CYLTagListCachePolicy`: where the list keeps the titles of its edited sections (`cachePolicy`). */
export enum CYLTagListCachePolicy {
  /** No cache (the default): edits live as long as the host's data. */
  none = 0,
  /** A database of the app (`relationalStore`, `tags.db`). */
  database = 1,
  /** The app's `preferences` (NSUserDefaults on iOS). */
  userDefaults = 2,
  /** A JSON file in the app's sandbox (its files folder). */
  sandboxFile = 3
}

/**
 * `CYLTagListCache`: a store of the ordered titles of a tag list's sections. The list makes the built-in store of its
 * `cachePolicy`; implement this interface and set `cache` to use another store.
 */
export interface CYLTagListCache {
  /** The titles saved for `section`, in order; undefined when nothing was saved for it. */
  cachedTitles(section: string): string[] | undefined;
  /** Saves `titles` (in this order) as the contents of `section`, replacing what was saved. */
  saveTitles(titles: string[], section: string): void;
  /** Removes what was saved for `section`. */
  removeTitles(section: string): void;
  /** Removes every section of this cache. */
  removeAllTitles(): void;
  /** `cachedItems(forSection:)`: the items saved for `section`, in order; undefined when none. Optional. */
  cachedItems?: (section: string) => CYLTagListCacheItem[] | undefined;
  /** `saveItems(_:forSection:)`: saves `items` (in this order) as the contents of `section`. Optional. */
  saveItems?: (items: CYLTagListCacheItem[], section: string) => void;
}

/**
 * `CYLTagListCacheItem`: one saved item of a tag list, its stable identifier (a database id; the title when the item
 * has none) and its current title. A reorder or a rename keeps the identifier.
 */
export class CYLTagListCacheItem {
  readonly identifier: string;
  readonly title: string;

  constructor(identifier: string, title: string) {
    this.identifier = identifier;
    this.title = title;
  }

  toString(): string {
    return `${this.identifier}:${this.title}`;
  }
}

/** The separator of an encoded "identifier<US>title" item (iOS `itemSeparator`). */
const CYL_ITEM_SEPARATOR: string = '\u001F';

/** Every saved list: {list name: {section: titles}}. Shared by the stores of one process, as the storage is. */
const CYL_MEMORY: Map<string, Map<string, string[]>> = new Map<string, Map<string, string[]>>();

/**
 * `CYLTagListStore`: the built-in caches behind one class. `name` separates the caches of different lists (the database
 * key, the preferences key or the file name). The app's context comes from the UI the list was shown in
 * (`CYLUIContext`), or from `context`. Without a context (host unit tests) the titles live in memory for the process,
 * as iOS keeps them in memory when its database cannot open. The database opens asynchronously: until it is open the
 * store answers from memory, then it reads the saved rows once and writes through.
 */
export class CYLTagListStore implements CYLTagListCache {
  /** The policy of this store. */
  readonly policy: CYLTagListCachePolicy;
  /** Separates the caches of different lists ("CYLTagListView" when empty). */
  readonly name: string;
  private context?: common.Context;
  private rdb?: relationalStore.RdbStore;

  /** The store for `policy` and `name`; undefined for `CYLTagListCachePolicy.none`. */
  static cache(policy: CYLTagListCachePolicy, name: string, context?: common.Context): CYLTagListStore | undefined {
    return policy === CYLTagListCachePolicy.none ? undefined : new CYLTagListStore(policy, name, context);
  }

  constructor(policy: CYLTagListCachePolicy, name: string, context?: common.Context) {
    this.policy = policy;
    this.name = name.length > 0 ? name : 'CYLTagListView';
    this.context = context ?? CYLTagListStore.appContext();
    if (policy === CYLTagListCachePolicy.database) {
      this.openDatabase();
    }
  }

  private static appContext(): common.Context | undefined {
    if (!CYLUIContext.hasContext) {
      return undefined;
    }
    try {
      return CYLUIContext.hostContext();
    } catch (error) {
      return undefined;
    }
  }

  // MARK: - CYLTagListCache

  cachedTitles(section: string): string[] | undefined {
    switch (this.policy) {
      case CYLTagListCachePolicy.none:
        return undefined;
      case CYLTagListCachePolicy.database:
        return this.copy(this.memory().get(section));
      case CYLTagListCachePolicy.userDefaults:
        return this.copy(this.preferencesContents().get(section));
      default:
        return this.copy(this.fileContents().get(section));
    }
  }

  saveTitles(titles: string[], section: string): void {
    // Plain titles replace any items saved for the section.
    this.removeRawTitles(`${section}#items`);
    this.saveRawTitles(titles, section);
  }

  /** `cachedItems(forSection:)`: the saved items; titles saved alone are their own identifiers. */
  cachedItems = (section: string): CYLTagListCacheItem[] | undefined => {
    const encoded = this.cachedTitles(`${section}#items`);
    if (encoded !== undefined) {
      return encoded.map((entry: string) => {
        const parts = entry.split(CYL_ITEM_SEPARATOR);
        return parts.length >= 2 ? new CYLTagListCacheItem(parts[0], parts.slice(1).join(CYL_ITEM_SEPARATOR)) :
          new CYLTagListCacheItem(entry, entry);
      });
    }
    return this.cachedTitles(section)?.map((title: string) => new CYLTagListCacheItem(title, title));
  };

  /** `saveItems(_:forSection:)`: the items in a companion section, the titles in the section itself. */
  saveItems = (items: CYLTagListCacheItem[], section: string): void => {
    this.saveRawTitles(items.map((item: CYLTagListCacheItem) => item.identifier + CYL_ITEM_SEPARATOR + item.title), `${section}#items`);
    this.saveRawTitles(items.map((item: CYLTagListCacheItem) => item.title), section);
  };

  private saveRawTitles(titles: string[], section: string): void {
    switch (this.policy) {
      case CYLTagListCachePolicy.none:
        return;
      case CYLTagListCachePolicy.database:
        this.memory().set(section, titles.slice());
        this.writeDatabaseSection(section, titles);
        return;
      case CYLTagListCachePolicy.userDefaults: {
        const all = this.preferencesContents();
        all.set(section, titles.slice());
        this.writePreferences(all);
        return;
      }
      default: {
        const all = this.fileContents();
        all.set(section, titles.slice());
        this.writeFile(all);
      }
    }
  }

  removeTitles(section: string): void {
    this.removeRawTitles(`${section}#items`);
    this.removeRawTitles(section);
  }

  private removeRawTitles(section: string): void {
    switch (this.policy) {
      case CYLTagListCachePolicy.none:
        return;
      case CYLTagListCachePolicy.database:
        this.memory().delete(section);
        this.executeDatabase('DELETE FROM tags WHERE list = ? AND section = ?', [this.name, section]);
        return;
      case CYLTagListCachePolicy.userDefaults: {
        const all = this.preferencesContents();
        all.delete(section);
        this.writePreferences(all);
        return;
      }
      default: {
        const all = this.fileContents();
        all.delete(section);
        this.writeFile(all);
      }
    }
  }

  removeAllTitles(): void {
    switch (this.policy) {
      case CYLTagListCachePolicy.none:
        return;
      case CYLTagListCachePolicy.database:
        this.memory().clear();
        this.executeDatabase('DELETE FROM tags WHERE list = ?', [this.name]);
        return;
      case CYLTagListCachePolicy.userDefaults:
        this.writePreferences(new Map<string, string[]>());
        return;
      default:
        this.writeFile(new Map<string, string[]>());
    }
  }

  // MARK: - Storage

  private copy(titles: string[] | undefined): string[] | undefined {
    return titles === undefined ? undefined : titles.slice();
  }

  /** The in-memory titles of this list and policy (the database's mirror, or the store without a context). */
  private memory(): Map<string, string[]> {
    const key = `${this.policy}:${this.name}`;
    let map = CYL_MEMORY.get(key);
    if (map === undefined) {
      map = new Map<string, string[]>();
      CYL_MEMORY.set(key, map);
    }
    return map;
  }

  private decode(text: string): Map<string, string[]> {
    const result = new Map<string, string[]>();
    if (text.length === 0) {
      return result;
    }
    try {
      const json = JSON.parse(text) as Record<string, string[]>;
      Object.keys(json).forEach((key: string) => result.set(key, json[key]));
    } catch (error) {
      // A damaged cache reads as empty.
    }
    return result;
  }

  private encode(contents: Map<string, string[]>): string {
    const json: Record<string, string[]> = {};
    contents.forEach((titles: string[], key: string) => {
      json[key] = titles;
    });
    return JSON.stringify(json);
  }

  private get preferencesKey(): string {
    return `CYLTagListCache.${this.name}`;
  }

  private preferencesStore(): preferences.Preferences | undefined {
    if (this.context === undefined) {
      return undefined;
    }
    try {
      return preferences.getPreferencesSync(this.context, { name: 'CYLTagListCache' } as preferences.Options);
    } catch (error) {
      return undefined;
    }
  }

  private preferencesContents(): Map<string, string[]> {
    const store = this.preferencesStore();
    if (store === undefined) {
      return new Map<string, string[]>(this.memory());
    }
    return this.decode(store.getSync(this.preferencesKey, '') as string);
  }

  private writePreferences(contents: Map<string, string[]>): void {
    const store = this.preferencesStore();
    if (store === undefined) {
      this.replaceMemory(contents);
      return;
    }
    store.putSync(this.preferencesKey, this.encode(contents));
    store.flush();
  }

  private get filePath(): string | undefined {
    if (this.context === undefined) {
      return undefined;
    }
    const folder = `${this.context.filesDir}/CollectionViewClassifyMenu`;
    try {
      if (!fileIo.accessSync(folder)) {
        fileIo.mkdirSync(folder, true);
      }
    } catch (error) {
      return undefined;
    }
    const safe = Array.from(this.name).map((c: string) => /[\p{L}\p{N}]/u.test(c) ? c : '_').join('');
    return `${folder}/tags-${safe}.json`;
  }

  private fileContents(): Map<string, string[]> {
    const path = this.filePath;
    if (path === undefined) {
      return new Map<string, string[]>(this.memory());
    }
    try {
      return fileIo.accessSync(path) ? this.decode(fileIo.readTextSync(path)) : new Map<string, string[]>();
    } catch (error) {
      return new Map<string, string[]>();
    }
  }

  private writeFile(contents: Map<string, string[]>): void {
    const path = this.filePath;
    if (path === undefined) {
      this.replaceMemory(contents);
      return;
    }
    if (contents.size === 0) {
      try {
        if (fileIo.accessSync(path)) {
          fileIo.unlinkSync(path);
        }
      } catch (error) {
        // Nothing to remove.
      }
      return;
    }
    const temporary = `${path}.tmp`;
    const file = fileIo.openSync(temporary, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC);
    fileIo.writeSync(file.fd, this.encode(contents));
    fileIo.closeSync(file);
    fileIo.renameSync(temporary, path);
  }

  private replaceMemory(contents: Map<string, string[]>): void {
    const memory = this.memory();
    memory.clear();
    contents.forEach((titles: string[], key: string) => memory.set(key, titles.slice()));
  }

  private openDatabase(): void {
    if (this.context === undefined) {
      return;
    }
    const config: relationalStore.StoreConfig = { name: 'CollectionViewClassifyMenu-tags.db', securityLevel: relationalStore.SecurityLevel.S1 };
    relationalStore.getRdbStore(this.context, config).then((store: relationalStore.RdbStore) => {
      store.executeSync('CREATE TABLE IF NOT EXISTS tags (list TEXT NOT NULL, section TEXT NOT NULL, ' +
        'position INTEGER NOT NULL, title TEXT, PRIMARY KEY (list, section, position))');
      this.rdb = store;
      // Read what earlier launches saved (sections saved in this launch before the database opened win).
      const saved = new Map<string, string[]>();
      const rows = store.querySqlSync('SELECT section, title FROM tags WHERE list = ? ORDER BY section, position', [this.name]);
      while (rows.goToNextRow()) {
        const section = rows.getString(0);
        const titles = saved.get(section) ?? [];
        if (!rows.isColumnNull(1)) {
          titles.push(rows.getString(1));
        }
        saved.set(section, titles);
      }
      rows.close();
      const memory = this.memory();
      saved.forEach((titles: string[], section: string) => {
        if (!memory.has(section)) {
          memory.set(section, titles);
        }
      });
      memory.forEach((titles: string[], section: string) => {
        if (!saved.has(section)) {
          this.writeDatabaseSection(section, titles);
        }
      });
    }).catch(() => {
      // Without a database the store keeps the titles in memory, as iOS when sqlite3_open fails.
    });
  }

  private executeDatabase(sql: string, args: relationalStore.ValueType[]): void {
    try {
      this.rdb?.executeSync(sql, args);
    } catch (error) {
      // The mirror in memory stays right; the next save writes again.
    }
  }

  private writeDatabaseSection(section: string, titles: string[]): void {
    if (this.rdb === undefined) {
      return;
    }
    this.executeDatabase('BEGIN', []);
    this.executeDatabase('DELETE FROM tags WHERE list = ? AND section = ?', [this.name, section]);
    // An empty section is a row with a NULL title, so "saved, empty" differs from "never saved".
    if (titles.length === 0) {
      this.executeDatabase('INSERT INTO tags (list, section, position, title) VALUES (?, ?, 0, NULL)', [this.name, section]);
    }
    titles.forEach((title: string, position: number) => {
      this.executeDatabase('INSERT INTO tags (list, section, position, title) VALUES (?, ?, ?, ?)', [this.name, section, position, title]);
    });
    this.executeDatabase('COMMIT', []);
  }
}

// MARK: - Network sync

/**
 * `CYLTagListLoadPolicy`: in what order `CYLTagListState.loadSectionsWithKeys` reads the cache and the remote source.
 * Unlike a search suggestion cache, a tag list may be kept on a server and edited on several devices.
 */
export enum CYLTagListLoadPolicy {
  /** The cache at once, then the remote source; a successful download is saved and reported again (the default). */
  cacheThenNetwork = 0,
  /** The cache when it holds every section asked for; otherwise the remote source (the cache if that fails). */
  cacheFirst = 1,
  /** The remote source; the cache only when the download fails. */
  networkFirst = 2
}

/** `CYLTagListDataOrigin`: where the titles reported by `loadSectionsWithKeys` come from. */
export enum CYLTagListDataOrigin {
  /** The local cache (`cache`). */
  cache = 0,
  /** The remote source (`remoteSource`). */
  network = 1
}

/**
 * `CYLTagListRemoteSource`: a server that keeps a tag list's sections, shared by the user's devices. The host implements
 * it with its own networking; the list only asks it for sections (`loadSectionsWithKeys`). Uploading is the host's too:
 * `menuDidFinishEditingWithTitles` / `editingFinishHandler` give it the edited sections.
 */
export interface CYLTagListRemoteSource {
  /**
   * `fetchSections(withKeys:completion:)`: downloads the sections saved under `keys`; calls `completion` once with the
   * titles by key (a missing key: nothing on the server) or an error.
   */
  fetchSectionsWithKeys(keys: string[], completion: (sections: Map<string, string[]> | undefined,
    error: Error | undefined) => void): void;
  /**
   * `fetchItems(withKeys:completion:)`: downloads the sections as items (stable identifier and title), for
   * `loadItemsWithKeys`. Optional: without it, the titles are fetched and each title is its own identifier.
   */
  fetchItemsWithKeys?: (keys: string[], completion: (items: Map<string, CYLTagListCacheItem[]> | undefined,
    error: Error | undefined) => void) => void;
}
