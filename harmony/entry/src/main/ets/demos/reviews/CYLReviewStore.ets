import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
import { hilog } from '@kit.PerformanceAnalysisKit';
/**
 * Mock reviews and the filters shown above them (场景一：淘宝评价筛选), as iOS CYLReviewStore.swift, and the three ways
 * to apply the selected filters (iOS CYLReviewQuery.swift): in memory, through a simulated server, and as SQL on the
 * shared database (cyl_places.sqlite, tables reviews / review_keywords).
 */
import { common } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { PlacesDatabase } from '../../data/PlacesDatabase';

export enum CYLReviewRating {
  good = 0,
  neutral = 1,
  bad = 2
}

export class CYLReview {
  user: string = '';
  text: string = '';
  date: string = '';
  sku: string = '';
  rating: CYLReviewRating = CYLReviewRating.good;
  hasPhoto: boolean = false;
  hasFollowUp: boolean = false;
  keywords: string[] = [];
}

/** One filter chip, such as "好评(3)" or the keyword "质量不错(2)". */
export class CYLReviewFilter {
  /** all, good, neutral, bad, photo, followup or keyword:<word>. */
  identifier: string = '';
  name: string = '';
  /** An SF Symbol stand-in (a glyph) and its color. */
  image?: Resource;
  imageColor: string = '#FF731A';
  /** The icon on the selected (orange) chip: a white copy of `image`. */
  selectedImage: Resource | undefined = undefined;
  isKeyword: boolean = false;
  matches: (review: CYLReview) => boolean = () => true;
}

function review(user: string, text: string, date: string, sku: string, rating: CYLReviewRating, photo: boolean,
  followUp: boolean, keywords: string[]): CYLReview {
  const r = new CYLReview();
  r.user = user;
  r.text = text;
  r.date = date;
  r.sku = sku;
  r.rating = rating;
  r.hasPhoto = photo;
  r.hasFollowUp = followUp;
  r.keywords = keywords;
  return r;
}

const IDENTIFIERS: Map<string, string> = new Map<string, string>([
  ['全部', 'all'], ['好评', 'good'], ['中评', 'neutral'], ['差评', 'bad'], ['有图', 'photo'], ['追加', 'followup']
]);

function makeFilter(name: string, image: Resource | undefined, selectedImage: Resource | undefined, color: string, keyword: boolean,
  matches: (r: CYLReview) => boolean): CYLReviewFilter {
  const f = new CYLReviewFilter();
  f.identifier = keyword ? 'keyword:' + name : (IDENTIFIERS.get(name) ?? name);
  f.name = name;
  f.isKeyword = keyword;
  f.matches = matches;
  f.image = image;
  f.selectedImage = selectedImage;
  f.imageColor = color;
  return f;
}

export class CYLReviewStore {
  private static instance?: CYLReviewStore;
  readonly reviews: CYLReview[];
  /** 全部, 好评, 中评, 差评, 有图, 追加, then keywords. */
  readonly filters: CYLReviewFilter[];

  private constructor() {
    this.reviews = CYLReviewStore.mockReviews();
    this.filters = CYLReviewStore.makeFilters();
  }

  static shared(): CYLReviewStore {
    if (CYLReviewStore.instance === undefined) {
      CYLReviewStore.instance = new CYLReviewStore();
    }
    return CYLReviewStore.instance;
  }

  /** Sample data (not localized). */
  static mockReviews(): CYLReview[] {
    const pink = '颜色分类:苹果6 4.7【镜面粉字】';
    const white = '颜色分类:苹果6plus【白边白字】';
    const G = CYLReviewRating.good;
    return [
      review('1**1', '这是我买的第二个了，太棒了，酷毙了，又能当化妆镜，又能当手机壳，价格真的很实惠，质量也不错。', '2015-06-17', pink, G, true, false, ['手机套不错', '质量不错', '划算']),
      review('雨**4', '刚收到就拆卡看壳，然后手机壳上有一层膜，没看到，找了卖家，卖家非常细心的解说，宝贝不错。', '2015-06-16', white, G, false, false, ['态度不错', '手机套不错']),
      review('j**8', '太炫了，闪瞎眼，质量蛮不错的非常超值，好几个朋友看了都说也要买。', '2015-06-12', pink, G, false, true, ['质量不错', '划算']),
      review('杨**6', '已经第N次购买了，不管是老板还是客服都非常好，东西更加不用说，超级靓。', '2015-06-13', white, G, true, false, ['态度不错', '质量不错']),
      review('小**猫', '颜色很正，和图片一样，镜面效果很好，就是有点容易留指纹。', '2015-06-11', pink, G, true, true, ['颜色不错']),
      review('t**2', '背面细节一般，边缘有一点毛刺，不过这个价格可以接受。', '2015-06-10', white, CYLReviewRating.neutral, false, false, ['背面细节一般']),
      review('阿**宝', '手机壳很薄，手感好，颜色也漂亮，推荐购买。', '2015-06-09', pink, G, false, false, ['手机套不错', '颜色不错']),
      review('z**9', '物流很快，第二天就到了，壳子做工精细，背面细节一般。', '2015-06-08', white, G, true, false, ['质量不错', '背面细节一般']),
      review('大**熊', '给女朋友买的，她很喜欢，客服回复也很及时。', '2015-06-07', pink, G, false, true, ['态度不错']),
      review('m**0', '性价比高，用了一周没有掉色，会回购。', '2015-06-05', white, G, false, false, ['划算', '质量不错'])
    ];
  }

  static makeFilters(): CYLReviewFilter[] {
    const orange = '#FF731A';
    const filters: CYLReviewFilter[] = [
      makeFilter(CYLExampleLocalizedString('全部'), undefined, undefined, orange, false, () => true),
      makeFilter(CYLExampleLocalizedString('好评'), $r('app.media.a_thumbsup'), $r('app.media.a_thumbsup_selected'), orange, false, (r: CYLReview) => r.rating === CYLReviewRating.good),
      makeFilter(CYLExampleLocalizedString('中评'), $r('app.media.a_hand_raised'), $r('app.media.a_hand_raised_selected'), orange, false,
        (r: CYLReview) => r.rating === CYLReviewRating.neutral),
      makeFilter(CYLExampleLocalizedString('差评'), $r('app.media.a_thumbsdown'), $r('app.media.a_thumbsdown_selected'), '#8E8E93', false,
        (r: CYLReview) => r.rating === CYLReviewRating.bad),
      makeFilter(CYLExampleLocalizedString('有图'), undefined, undefined, orange, false, (r: CYLReview) => r.hasPhoto),
      makeFilter(CYLExampleLocalizedString('追加'), undefined, undefined, orange, false, (r: CYLReview) => r.hasFollowUp)
    ];
    ['手机套不错', '质量不错', '态度不错', '划算', '颜色不错', '背面细节一般'].forEach((keyword: string) => {
      // The chip shows the keyword in the app's language; the match keeps the data's keyword.
      const filter = makeFilter(CYLExampleLocalizedString(keyword), undefined, undefined, orange, true,
        (r: CYLReview) => r.keywords.includes(keyword));
      filter.identifier = 'keyword:' + keyword;
      filters.push(filter);
    });
    return filters;
  }

  reviewsMatching(filter: CYLReviewFilter): CYLReview[] {
    return this.reviews.filter((r: CYLReview) => filter.matches(r));
  }

  /** Reviews that match every filter (AND). */
  reviewsMatchingAll(filters: CYLReviewFilter[]): CYLReview[] {
    return this.reviews.filter((r: CYLReview) => filters.every((f: CYLReviewFilter) => f.matches(r)));
  }

  filterWithIdentifier(identifier: string): CYLReviewFilter | undefined {
    return this.filters.find((f: CYLReviewFilter) => f.identifier === identifier);
  }

  /** "好评(3)"; "全部" has no count. */
  titleFor(filter: CYLReviewFilter): string {
    if (filter.name === CYLExampleLocalizedString('全部')) {
      return filter.name;
    }
    return `${filter.name}(${this.reviewsMatching(filter).length})`;
  }
}

// MARK: - Queries

export enum CYLReviewFilteringMode {
  memory = 0,
  network = 1,
  database = 2
}

export type CYLReviewQueryCompletion = (reviews: CYLReview[]) => void;

export interface CYLReviewQuerying {
  mode: CYLReviewFilteringMode;
  isLoading: boolean;
  /** Reviews matching every filter; not called for superseded requests. */
  fetchReviewsMatching(filters: CYLReviewFilter[], completion: CYLReviewQueryCompletion): void;
}

export class CYLMemoryReviewQuery implements CYLReviewQuerying {
  mode: CYLReviewFilteringMode = CYLReviewFilteringMode.memory;
  isLoading: boolean = false;

  fetchReviewsMatching(filters: CYLReviewFilter[], completion: CYLReviewQueryCompletion): void {
    completion(CYLReviewStore.shared().reviewsMatchingAll(filters));
  }
}

/** A stand-in for a backend: answers a request URL with the matching reviews. */
export class CYLReviewServer {
  static reviewsForRequestURL(url: string): CYLReview[] {
    const store = CYLReviewStore.shared();
    const q = url.indexOf('?');
    const filters: CYLReviewFilter[] = [];
    if (q >= 0) {
      url.substring(q + 1).split('&').forEach((pair: string) => {
        const eq = pair.indexOf('=');
        if (eq > 0 && pair.substring(0, eq) === 'filter') {
          const f = store.filterWithIdentifier(decodeURIComponent(pair.substring(eq + 1)));
          if (f !== undefined) {
            filters.push(f);
          }
        }
      });
    }
    return store.reviewsMatchingAll(filters);
  }
}

export class CYLNetworkReviewQuery implements CYLReviewQuerying {
  mode: CYLReviewFilteringMode = CYLReviewFilteringMode.network;
  isLoading: boolean = false;
  /** Simulated round trip, in seconds. */
  latency: number = 0.6;
  lastRequestURL?: string;
  requestCount: number = 0;
  droppedResponseCount: number = 0;

  static requestURL(filters: CYLReviewFilter[]): string {
    const items = filters.map((f: CYLReviewFilter) => 'filter=' + encodeURIComponent(f.identifier));
    return 'https://api.example.com/reviews' + (items.length > 0 ? '?' + items.join('&') : '');
  }

  fetchReviewsMatching(filters: CYLReviewFilter[], completion: CYLReviewQueryCompletion): void {
    const url = CYLNetworkReviewQuery.requestURL(filters);
    this.lastRequestURL = url;
    this.requestCount += 1;
    const request = this.requestCount;
    this.isLoading = true;
    setTimeout(() => {
      if (request !== this.requestCount) {
        // The user changed the filters again: this response is out of date.
        this.droppedResponseCount += 1;
        return;
      }
      this.isLoading = false;
      completion(CYLReviewServer.reviewsForRequestURL(url));
    }, this.latency * 1000);
  }
}

export class CYLExampleSQLQuery {
  sql: string;
  args: relationalStore.ValueType[];

  constructor(sql: string, args: relationalStore.ValueType[]) {
    this.sql = sql;
    this.args = args;
  }

  /** The SQL with its arguments filled in, as shown on screen. */
  displayString(): string {
    const parts = this.sql.split('?');
    let result = '';
    parts.forEach((part: string, index: number) => {
      result += part;
      if (index + 1 < parts.length) {
        const value = index < this.args.length ? this.args[index] : null;
        if (typeof value === 'string') {
          result += `'${(value as string).split('\'').join('\'\'')}'`;
        } else if (typeof value === 'number') {
          result += `${value as number}`;
        } else {
          result += 'NULL';
        }
      }
    });
    return result;
  }
}

/** Runs the conditions as SQL on the shared database; every condition is ANDed. */
export class CYLDatabaseReviewQuery implements CYLReviewQuerying {
  mode: CYLReviewFilteringMode = CYLReviewFilteringMode.database;
  isLoading: boolean = false;
  lastQuery?: CYLExampleSQLQuery;
  private context: common.UIAbilityContext;
  private static store?: relationalStore.RdbStore;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  static query(filters: CYLReviewFilter[]): CYLExampleSQLQuery {
    const conditions: string[] = [];
    const args: relationalStore.ValueType[] = [];
    const ratings: Map<string, number> = new Map<string, number>([['good', 0], ['neutral', 1], ['bad', 2]]);
    filters.forEach((f: CYLReviewFilter) => {
      const rating = ratings.get(f.identifier);
      if (rating !== undefined) {
        conditions.push('r.rating = ?');
        args.push(rating);
      } else if (f.identifier === 'photo') {
        conditions.push('r.has_photo = 1');
      } else if (f.identifier === 'followup') {
        conditions.push('r.has_follow_up = 1');
      } else if (f.isKeyword) {
        conditions.push('EXISTS (SELECT 1 FROM review_keywords k WHERE k.review_id = r.id AND k.keyword = ?)');
        args.push(f.identifier.substring('keyword:'.length)); // the data's keyword, not the shown (translated) name
      }
    });
    let sql = 'SELECT r.id FROM reviews r';
    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ');
    }
    return new CYLExampleSQLQuery(sql + ' ORDER BY r.id', args);
  }

  private async openStore(): Promise<relationalStore.RdbStore> {
    try {
      if (CYLDatabaseReviewQuery.store === undefined) {
        // Copies cyl_places.sqlite from rawfile on first use.
        await PlacesDatabase.open(this.context);
        CYLDatabaseReviewQuery.store = await relationalStore.getRdbStore(this.context,
          { name: 'cyl_places.sqlite', securityLevel: relationalStore.SecurityLevel.S1 });
      }
      return CYLDatabaseReviewQuery.store;
    } catch (error) {
      hilog.error(0x0000, 'CYLReviewStore', '%{public}s', JSON.stringify(error));
      throw error as Error;
    }
  }

  fetchReviewsMatching(filters: CYLReviewFilter[], completion: CYLReviewQueryCompletion): void {
    const query = CYLDatabaseReviewQuery.query(filters);
    this.lastQuery = query;
    this.isLoading = true;
    this.openStore().then(async (store: relationalStore.RdbStore) => {
      const set = await store.querySql(query.sql, query.args);
      const reviews = CYLReviewStore.shared().reviews;
      const result: CYLReview[] = [];
      while (set.goToNextRow()) {
        const index = set.getLong(set.getColumnIndex('id'));
        if (index >= 0 && index < reviews.length) {
          result.push(reviews[index]);
        }
      }
      set.close();
      if (this.lastQuery === query) {
        this.isLoading = false;
        completion(result);
      }
    }).catch((e: Error) => {
      console.error(`[CYLMenuExample] ${query.sql}: ${e.message}`);
      this.isLoading = false;
      completion([]);
    });
  }
}
