import { CYL_SEARCH_DISCOVER_JSON } from '../../data/CYLExampleStrings';
import { cylExampleLanguage } from '../../data/CYLExampleLocalization';

/**
 * The data of the search history and discover demo (iOS CYLSearchDiscoverData.swift, from
 * CYLMenuExample.bundle/<language>.lproj/search-discover.json): recent searches, and a pool of discover topics from which
 * the More button picks another random selection.
 */
export interface CYLDiscoverTopic {
  title: string;
  /** "hot": the hot icon (discover-hot.png, 热) after the title. */
  icon?: string;
}

/** search-discover.json as parsed. */
interface CYLSearchDiscoverFile {
  version?: number;
  discoverCount?: number;
  recentSearches?: string[];
  discover?: CYLDiscoverTopic[];
}

export class CYLSearchDiscoverData {
  version: number = 1;
  /** How many topics the discover grid shows at a time. */
  discoverCount: number = 6;
  recentSearches: string[] = [];
  discover: CYLDiscoverTopic[] = [];

  /**
   * The data of the app's language (iOS: CYLMenuExample.bundle/<language>.lproj/search-discover.json, exported to
   * CYL_SEARCH_DISCOVER_JSON by harmony/scripts/export-example-strings.py); Simplified Chinese when a language has none.
   */
  static bundled(language: string = cylExampleLanguage()): CYLSearchDiscoverData {
    const data = new CYLSearchDiscoverData();
    const text = CYL_SEARCH_DISCOVER_JSON[language] ?? CYL_SEARCH_DISCOVER_JSON['zh-Hans'];
    if (text === undefined) {
      return data;
    }
    const file = JSON.parse(text) as CYLSearchDiscoverFile;
    data.version = file.version ?? 1;
    data.discoverCount = file.discoverCount ?? 6;
    data.recentSearches = file.recentSearches ?? [];
    data.discover = (file.discover ?? []).map((t: CYLDiscoverTopic): CYLDiscoverTopic =>
      t.icon !== undefined ? { title: t.title, icon: t.icon } : { title: t.title });
    return data;
  }

  /** The first selection: the first `discoverCount` topics, so the first screen is always the same. */
  get initialTopics(): CYLDiscoverTopic[] {
    return this.discover.slice(0, Math.max(0, this.discoverCount));
  }

  /** Another random selection of `discoverCount` topics; it differs from `current` whenever the pool allows. */
  randomTopics(current: CYLDiscoverTopic[], random: () => number = Math.random): CYLDiscoverTopic[] {
    const count = Math.min(Math.max(0, this.discoverCount), this.discover.length);
    const titles = current.map((t: CYLDiscoverTopic) => t.title);
    const shuffle = (list: CYLDiscoverTopic[]): CYLDiscoverTopic[] => {
      const copy = list.slice();
      for (let i = copy.length - 1; i > 0; i--) {
        const j = Math.floor(random() * (i + 1));
        const t = copy[i];
        copy[i] = copy[j];
        copy[j] = t;
      }
      return copy;
    };
    // Prefer topics that are not shown now; fill up with the others when the pool is small.
    const picked = shuffle(this.discover.filter((t: CYLDiscoverTopic) => !titles.includes(t.title))).slice(0, count);
    if (picked.length < count) {
      const rest = shuffle(this.discover.filter((t: CYLDiscoverTopic) => !picked.includes(t)));
      rest.slice(0, count - picked.length).forEach((t: CYLDiscoverTopic) => picked.push(t));
    }
    return picked;
  }
}
