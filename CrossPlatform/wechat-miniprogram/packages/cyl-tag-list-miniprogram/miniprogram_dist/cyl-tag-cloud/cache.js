/**
 * The cache of a tag list's edited tags (iOS `CYLTagListCache.swift`): an order changed in editing mode (a drag), a
 * deleted tag or an added one survives a relaunch. No `wx` call at load time, so node tests can use it with a fake.
 *
 * Policies (`CYLTagListCachePolicy`): 'none'; 'database'; 'userDefaults' (NSUserDefaults on iOS: `wx.setStorageSync`);
 * 'sandboxFile' (a JSON file in the user data folder, `wx.env.USER_DATA_PATH`). A mini program has no SQLite, so
 * 'database' keeps its own storage entry ("CYLTagListDatabase.<name>"), apart from 'userDefaults'. Without `wx` (node
 * tests) every policy keeps the titles in memory for the process, as iOS when its database cannot open.
 */

const POLICIES = ['none', 'database', 'userDefaults', 'sandboxFile'];

/** Every saved list without `wx`: {"policy:name": {section: titles}}. */
const MEMORY = {};

function wxApi() {
  return typeof wx !== 'undefined' ? wx : null;
}

/**
 * `CYLTagListStore`: the built-in caches behind one class. `name` separates the caches of different lists (the storage
 * key or the file name); "CYLTagListView" when empty. Methods: `cachedTitles(section)` (undefined when nothing was
 * saved), `saveTitles(titles, section)`, `removeTitles(section)`, `removeAllTitles()`. Sections are strings ("0").
 */
class CYLTagListStore {
  constructor(policy, name) {
    this.policy = POLICIES.includes(policy) ? policy : 'none';
    this.name = name ? String(name) : 'CYLTagListView';
  }

  /** `cache(policy:name:)`: the store for `policy` and `name`; null for 'none'. */
  static cache(policy, name) {
    return policy && policy !== 'none' && POLICIES.includes(policy) ? new CYLTagListStore(policy, name) : null;
  }

  cachedTitles(section) {
    if (this.policy === 'none') return undefined;
    const titles = this._read()[String(section)];
    return Array.isArray(titles) ? titles.slice() : undefined;
  }

  saveTitles(titles, section) {
    if (this.policy === 'none') return;
    const all = this._read();
    all[String(section)] = (titles || []).map(String);
    // Plain titles replace any items saved for the section.
    delete all[`${section}#items`];
    this._write(all);
  }

  removeTitles(section) {
    if (this.policy === 'none') return;
    const all = this._read();
    delete all[String(section)];
    delete all[`${section}#items`];
    this._write(all);
  }

  removeAllTitles() {
    if (this.policy === 'none') return;
    this._write({});
  }

  /** `cachedItems(forSection:)`: the saved items ({identifier, title}); titles saved alone are their own ids. */
  cachedItems(section) {
    if (this.policy === 'none') return undefined;
    const all = this._read();
    const items = all[`${section}#items`];
    if (Array.isArray(items)) return items.map((item) => ({ identifier: String(item.identifier), title: String(item.title) }));
    const titles = all[String(section)];
    return Array.isArray(titles) ? titles.map((title) => ({ identifier: String(title), title: String(title) })) : undefined;
  }

  /** `saveItems(_:forSection:)`: the items with their ids, and their titles as the section itself. */
  saveItems(items, section) {
    if (this.policy === 'none') return;
    const all = this._read();
    const list = (items || []).map((item) => ({ identifier: String(item.identifier), title: String(item.title) }));
    all[`${section}#items`] = list;
    all[String(section)] = list.map((item) => item.title);
    this._write(all);
  }

  // MARK: Storage

  get _storageKey() {
    return `${this.policy === 'database' ? 'CYLTagListDatabase' : 'CYLTagListCache'}.${this.name}`;
  }

  get _filePath() {
    const api = wxApi();
    const safe = Array.from(this.name).map((c) => (/[\p{L}\p{N}]/u.test(c) ? c : '_')).join('');
    return `${api.env.USER_DATA_PATH}/tags-${safe}.json`;
  }

  _read() {
    const api = wxApi();
    if (!api) return { ...(MEMORY[`${this.policy}:${this.name}`] || {}) };
    try {
      if (this.policy === 'sandboxFile') {
        const text = api.getFileSystemManager().readFileSync(this._filePath, 'utf8');
        return JSON.parse(text) || {};
      }
      const text = api.getStorageSync(this._storageKey);
      return text ? JSON.parse(text) : {};
    } catch (error) {
      // Nothing saved yet, or a damaged cache: empty.
      return {};
    }
  }

  _write(all) {
    const api = wxApi();
    if (!api) {
      MEMORY[`${this.policy}:${this.name}`] = JSON.parse(JSON.stringify(all));
      return;
    }
    const text = JSON.stringify(all);
    if (this.policy === 'sandboxFile') {
      const fs = api.getFileSystemManager();
      if (Object.keys(all).length === 0) {
        try {
          fs.unlinkSync(this._filePath);
        } catch (error) {
          // Nothing to remove.
        }
        return;
      }
      fs.writeFileSync(this._filePath, text, 'utf8');
      return;
    }
    if (Object.keys(all).length === 0) api.removeStorageSync(this._storageKey);
    else api.setStorageSync(this._storageKey, text);
  }
}

// MARK: Network sync (iOS 3fc2c23b)

/** `CYLTagListLoadPolicy`: 'cacheThenNetwork' (the default), 'cacheFirst', 'networkFirst'. */
const LOAD_POLICIES = ['cacheThenNetwork', 'cacheFirst', 'networkFirst'];

/**
 * `loadSections(withKeys:completion:)`: reads the sections saved under `keys` from `cache` (a store) and `remote` (an
 * object with `fetchSectionsWithKeys(keys, callback(sections, error))`, the host's networking), in the order of
 * `policy`, and calls `completion(sections, origin)` with the titles by key and 'cache' or 'network': once or twice
 * ('cacheThenNetwork': the cache at once, then the server). Downloaded sections are saved to the cache first. Without a
 * remote source it reads the cache only; nothing saved anywhere calls nothing.
 */
function loadSections({ cache, remote, policy = 'cacheThenNetwork', keys, completion }) {
  const cached = {};
  for (const key of keys) {
    const titles = cache ? cache.cachedTitles(key) : undefined;
    if (titles !== undefined) cached[key] = titles;
  }
  const count = Object.keys(cached).length;
  const fetch = (done) => {
    if (!remote || typeof remote.fetchSectionsWithKeys !== 'function') {
      done(false);
      return;
    }
    remote.fetchSectionsWithKeys(keys.slice(), (sections, error) => {
      if (!sections || error) {
        done(false);
        return;
      }
      const downloaded = {};
      for (const key of Object.keys(sections)) {
        if (!keys.includes(key)) continue;
        downloaded[key] = sections[key];
        if (cache) cache.saveTitles(sections[key], key);
      }
      completion(downloaded, 'network');
      done(true);
    });
  };
  const fallBack = (ok) => {
    if (!ok && count > 0) completion(cached, 'cache');
  };
  const chosen = LOAD_POLICIES.includes(policy) ? policy : 'cacheThenNetwork';
  if (chosen === 'cacheThenNetwork') {
    if (count > 0) completion(cached, 'cache');
    fetch(() => {});
  } else if (chosen === 'cacheFirst') {
    if (count === keys.length) completion(cached, 'cache');
    else fetch(fallBack);
  } else {
    fetch(fallBack);
  }
}

/**
 * `loadItems(withKeys:completion:)`: `loadSections` with ids: the cache's items and the remote source's
 * (`fetchItemsWithKeys(keys, callback(items, error))`, else its titles, each its own id); downloads are saved first.
 */
function loadItems({ cache, remote, policy = 'cacheThenNetwork', keys, completion }) {
  const asItems = (titles) => titles.map((title) => ({ identifier: String(title), title: String(title) }));
  const itemsRemote = remote ? {
    fetchSectionsWithKeys(fetchKeys, callback) {
      const done = (items, error) => {
        if (!items || error) {
          callback(null, error || new Error('CYLTagListRemoteSource'));
          return;
        }
        callback(items, null);
      };
      if (typeof remote.fetchItemsWithKeys === 'function') {
        remote.fetchItemsWithKeys(fetchKeys, done);
      } else if (typeof remote.fetchSectionsWithKeys === 'function') {
        remote.fetchSectionsWithKeys(fetchKeys, (sections, error) => {
          if (!sections || error) {
            done(null, error);
            return;
          }
          const items = {};
          for (const key of Object.keys(sections)) items[key] = asItems(sections[key]);
          done(items, null);
        });
      } else {
        done(null, new Error('CYLTagListRemoteSource'));
      }
    },
  } : null;
  const itemsCache = cache ? {
    cachedTitles: (key) => cache.cachedItems(key),
    saveTitles: (items, key) => cache.saveItems(items, key),
  } : null;
  loadSections({ cache: itemsCache, remote: itemsRemote, policy, keys, completion });
}

module.exports = { CYLTagListStore, POLICIES, LOAD_POLICIES, loadSections, loadItems };
