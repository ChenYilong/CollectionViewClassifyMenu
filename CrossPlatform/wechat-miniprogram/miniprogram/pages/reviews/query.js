/**
 * Three ways to apply the selected review filters, 1:1 with the iOS example's CYLReviewQuery.swift, kept apart on
 * purpose:
 * - MemoryReviewQuery filters the reviews already in memory, synchronously.
 * - NetworkReviewQuery sends the conditions to a server and refreshes when the response arrives; responses to older
 *   requests are dropped. The server is simulated (reviewsForRequestURL, after `latency` ms), as on iOS, so the
 *   example runs offline: no request leaves the Mini Program.
 * - DatabaseReviewQuery turns the conditions into one SQL statement (the same text and arguments as iOS) and runs it
 *   on the rows of the shared database's `reviews` and `review_keywords` tables (data/reviews.js; a Mini Program has
 *   no SQLite, so runStatement evaluates the statement's conditions).
 * Also the status text of CYLReviewListViewController.updateStatus(). No `wx` calls (node --test).
 */
const { t } = require('../../utils/i18n.js');
const store = require('./store.js');

/** CYLReviewFilteringMode: the raw value is the index of the mode's segment. */
const MODES = ['memory', 'network', 'database'];

function modeIndex(mode) {
  const index = MODES.indexOf(mode);
  return index < 0 ? 0 : index;
}

/** A mode name from a launch query (`mode=database`, or the raw value `mode=2`); memory otherwise. */
function parseMode(value) {
  if (value == null) return 'memory';
  const text = String(value);
  if (MODES.includes(text)) return text;
  const n = Number(text);
  return Number.isInteger(n) && MODES[n] ? MODES[n] : 'memory';
}

// MARK: Memory

class MemoryReviewQuery {
  get mode() { return 'memory'; }
  get isLoading() { return false; }

  fetchReviewsMatching(filters, completion) {
    completion(store.reviewsMatchingAll(filters));
  }
}

// MARK: Network

const BASE_URL = 'https://api.example.com/reviews';

/** Percent-encodes a query value like URLComponents (the characters of urlQueryAllowed stay as they are). */
function encodeQueryValue(value) {
  return encodeURIComponent(value).replace(/%(21|24|27|28|29|2A|2B|2C|3B|2F|3F|3A|40)/g,
    (match, hex) => String.fromCharCode(parseInt(hex, 16)));
}

/** The request for the filters: "https://api.example.com/reviews?filter=good&filter=photo" (no query when empty). */
function requestURL(filters) {
  if (!filters.length) return BASE_URL;
  return `${BASE_URL}?${filters.map((f) => `filter=${encodeQueryValue(f.identifier)}`).join('&')}`;
}

function parseURL(url) {
  const match = /^[a-z]+:\/\/[^/?#]*([^?#]*)(?:\?([^#]*))?/i.exec(url) || [];
  const query = match[2];
  const items = query == null || query === '' ? [] : query.split('&').map((pair) => {
    const at = pair.indexOf('=');
    const name = at < 0 ? pair : pair.slice(0, at);
    const value = at < 0 ? null : pair.slice(at + 1);
    return { name: decodeURIComponent(name), value: value == null ? null : decodeURIComponent(value) };
  });
  return { path: match[1] || '', query, items };
}

/** CYLReviewServer: a stand-in for a backend, answering a request URL with the matching reviews. */
function reviewsForRequestURL(url) {
  const filters = parseURL(url).items
    .filter((item) => item.name === 'filter' && item.value != null)
    .map((item) => store.filterWithIdentifier(item.value))
    .filter(Boolean);
  return store.reviewsMatchingAll(filters);
}

/** "GET /reviews?filter=good&filter=photo", the request as the status shows it (percent-decoded). */
function requestDisplay(url) {
  const parsed = url ? parseURL(url) : { path: '', query: null };
  let query = '';
  if (parsed.query) {
    let decoded = parsed.query;
    try { decoded = decodeURIComponent(parsed.query); } catch (error) { /* keep it encoded, as removingPercentEncoding */ }
    query = `?${decoded}`;
  }
  return `GET ${parsed.path}${query}`;
}

class NetworkReviewQuery {
  /** `schedule(fn, ms)` runs the simulated round trip; setTimeout by default. */
  constructor(schedule) {
    /** Simulated round trip in ms. Defaults to 0.6 s. */
    this.latency = 600;
    this.isLoading = false;
    this.lastRequestURL = null;
    this.requestCount = 0;
    this.droppedResponseCount = 0;
    this.schedule = schedule || ((fn, ms) => setTimeout(fn, ms));
    this.cancelled = false;
  }

  get mode() { return 'network'; }

  fetchReviewsMatching(filters, completion) {
    const url = requestURL(filters);
    this.lastRequestURL = url;
    this.requestCount += 1;
    const request = this.requestCount;
    this.isLoading = true;
    this.schedule(() => {
      // [weak self]: a query that was replaced (or whose page closed) calls nothing.
      if (this.cancelled) return;
      if (request !== this.requestCount) {
        // The user changed the filters again: this response is out of date.
        this.droppedResponseCount += 1;
        return;
      }
      this.isLoading = false;
      completion(reviewsForRequestURL(url));
    }, this.latency);
  }

  /** Drops every pending response (the iOS query is released with its view controller). */
  cancel() {
    this.cancelled = true;
  }
}

// MARK: Database

/** The SQL with each "?" replaced by its value ('text', numbers as is), for display only (CYLExampleSQLQuery). */
function displayString(sql, args) {
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

const KEYWORD_CONDITION = 'EXISTS (SELECT 1 FROM review_keywords k WHERE k.review_id = r.id AND k.keyword = ?)';

/**
 * The statement for the filters (CYLDatabaseReviewQuery.query(for:)): rating, photo and follow-up are columns of
 * `reviews`, keywords rows of `review_keywords`; every condition is ANDed.
 * @returns {{sql: string, arguments: Array, conditions: string[], displayString: () => string}}
 */
function databaseQuery(filters) {
  const conditions = [];
  const args = [];
  const ratings = { good: store.RATING.good, neutral: store.RATING.neutral, bad: store.RATING.bad };
  filters.forEach((f) => {
    const identifier = f.identifier;
    if (Object.prototype.hasOwnProperty.call(ratings, identifier)) {
      conditions.push('r.rating = ?');
      args.push(ratings[identifier]);
    } else if (identifier === 'photo') {
      conditions.push('r.has_photo = 1');
    } else if (identifier === 'followup') {
      conditions.push('r.has_follow_up = 1');
    } else if (f.isKeyword) {
      conditions.push(KEYWORD_CONDITION);
      args.push(f.name);
    }
  });
  let sql = 'SELECT r.id FROM reviews r';
  if (conditions.length) sql += ` WHERE ${conditions.join(' AND ')}`;
  sql += ' ORDER BY r.id';
  return { sql, arguments: args, conditions, displayString: () => displayString(sql, args) };
}

/** The rows of the shared database's `reviews` and `review_keywords` tables (as the export wrote them). */
function tables(reviews = store.reviews) {
  return {
    reviews: reviews.map((r) => ({
      id: r.id, user: r.user, text: r.text, date: r.date, sku: r.sku, rating: r.rating,
      has_photo: r.hasPhoto ? 1 : 0, has_follow_up: r.hasFollowUp ? 1 : 0,
    })),
    review_keywords: reviews.flatMap((r) => r.keywords.map((keyword) => ({ review_id: r.id, keyword }))),
  };
}

/**
 * Runs a statement of databaseQuery() on the tables: each condition of its WHERE clause, with its arguments in
 * order, then ORDER BY r.id. Returns the rows ({id}). Throws for a condition it does not know.
 */
function runStatement(query, db = tables()) {
  let next = 0;
  const predicates = query.conditions.map((condition) => {
    switch (condition) {
      case 'r.rating = ?': {
        const value = query.arguments[next++];
        return (row) => row.rating === value;
      }
      case 'r.has_photo = 1': return (row) => row.has_photo === 1;
      case 'r.has_follow_up = 1': return (row) => row.has_follow_up === 1;
      case KEYWORD_CONDITION: {
        const keyword = query.arguments[next++];
        return (row) => db.review_keywords.some((k) => k.review_id === row.id && k.keyword === keyword);
      }
      default: throw new Error(`Unsupported condition: ${condition}`);
    }
  });
  return db.reviews
    .filter((row) => predicates.every((matches) => matches(row)))
    .sort((a, b) => a.id - b.id)
    .map((row) => ({ id: row.id }));
}

class DatabaseReviewQuery {
  constructor(db) {
    this.db = db || tables();
    /** The statement of the last fetch. */
    this.lastQuery = null;
  }

  get mode() { return 'database'; }
  get isLoading() { return false; }

  fetchReviewsMatching(filters, completion) {
    const query = databaseQuery(filters);
    this.lastQuery = query;
    let rows = [];
    try {
      rows = runStatement(query, this.db);
    } catch (error) {
      console.error(`[CYLMenuExample] ${query.sql}: ${error}`);
    }
    const reviews = store.reviews;
    completion(rows
      .map((row) => (Number.isInteger(row.id) && row.id >= 0 && row.id < reviews.length ? reviews[row.id] : null))
      .filter(Boolean));
  }
}

/** CYLReviewListViewController.query(for:). */
function queryFor(mode, options = {}) {
  if (mode === 'network') return new NetworkReviewQuery(options.schedule);
  if (mode === 'database') return new DatabaseReviewQuery(options.db);
  return new MemoryReviewQuery();
}

// MARK: Status

/**
 * The status text above the list (updateStatus()): the last tap and the selection, then the mode's line(s) with the
 * count, the request (network) or the statement (database).
 */
function statusLines({ mode, query, lastEvent, selectedFilters, count }) {
  const names = selectedFilters.map(store.displayName);
  const selection = names.length ? names.join(t('、')) : t('全部');
  const lines = [`${lastEvent || ''} · ${t('已选：%@', selection)}`];
  if (mode === 'network') {
    lines.push(`${t('网络筛选：向服务器发送条件')} · ${requestDisplay(query && query.lastRequestURL)}`);
    lines.push(query && query.isLoading ? t('加载中…') : t('服务器返回 %lu 条', count));
  } else if (mode === 'database') {
    lines.push(`${t('数据库筛选：条件生成 SQL，在 SQLite 中查询')} · ${t('匹配 %lu 条', count)}`);
    lines.push(query && query.lastQuery ? query.lastQuery.displayString() : '');
  } else {
    lines.push(`${t('内存筛选：在已加载的评价中立即匹配')} · ${t('匹配 %lu 条', count)}`);
  }
  return lines;
}

module.exports = {
  MODES, modeIndex, parseMode,
  MemoryReviewQuery, NetworkReviewQuery, DatabaseReviewQuery, queryFor,
  BASE_URL, requestURL, parseURL, reviewsForRequestURL, requestDisplay,
  displayString, databaseQuery, tables, runStatement,
  statusLines,
};
