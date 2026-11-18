/**
 * The reviews and the filters shown above them (场景一：淘宝评价筛选), 1:1 with the iOS example's CYLReviewStore.swift:
 * the 10 mock reviews (data/reviews.js, from the shared database) and the filters 全部, 好评, 中评, 差评, 有图, 追加, then
 * the keywords. No `wx` calls (node --test).
 */
const { t } = require('../../utils/i18n.js');
const REVIEWS = require('../../data/reviews.js');

/** CYLReviewRating raw values. */
const RATING = { good: 0, neutral: 1, bad: 2 };

/** Identifiers of the rating filters; their names are localization keys looked up in title(). */
const IDENTIFIERS = { 全部: 'all', 好评: 'good', 中评: 'neutral', 差评: 'bad', 有图: 'photo', 追加: 'followup' };

/** The keyword filters, in the order of makeFilters(). */
const KEYWORDS = ['手机套不错', '质量不错', '态度不错', '划算', '颜色不错', '背面细节一般']; // NOLOCALIZE: user content: the shop's review keywords, as iOS CYLReviewStore

/**
 * Stand-ins for the SF Symbols of makeFilters(), tinted as there (orange, 差评 gray; `.alwaysOriginal`, so they keep
 * their color on a selected tag).
 */
const SYMBOL_IMAGES = {
  'hand.thumbsup.fill': '/images/reviews/hand-thumbsup-fill.png',
  'hand.raised.fill': '/images/reviews/hand-raised-fill.png',
  'hand.thumbsdown.fill': '/images/reviews/hand-thumbsdown-fill.png',
};

function filter(name, symbol, keyword, matches) {
  return {
    identifier: keyword ? `keyword:${name}` : (IDENTIFIERS[name] || name),
    name,
    symbol: symbol || '',
    image: symbol ? SYMBOL_IMAGES[symbol] : '',
    isKeyword: keyword,
    matches,
  };
}

function makeFilters() {
  const filters = [
    filter('全部', null, false, () => true),
    filter('好评', 'hand.thumbsup.fill', false, (r) => r.rating === RATING.good),
    filter('中评', 'hand.raised.fill', false, (r) => r.rating === RATING.neutral),
    filter('差评', 'hand.thumbsdown.fill', false, (r) => r.rating === RATING.bad),
    filter('有图', null, false, (r) => r.hasPhoto),
    filter('追加', null, false, (r) => r.hasFollowUp),
  ];
  KEYWORDS.forEach((keyword) => {
    filters.push(filter(keyword, null, true, (r) => r.keywords.includes(keyword)));
  });
  return filters;
}

const reviews = REVIEWS;
const filters = makeFilters();

function reviewsMatching(f) {
  return reviews.filter(f.matches);
}

/** Reviews that match every filter (AND); "all" adds no condition. */
function reviewsMatchingAll(list) {
  return reviews.filter((review) => list.every((f) => f.matches(review)));
}

function filterWithIdentifier(identifier) {
  return filters.find((f) => f.identifier === identifier) || null;
}

/** The name shown for a filter: rating filters are UI text and localized; keyword filters are sample data. */
function displayName(f) {
  return f.isKeyword ? f.name : t(f.name);
}

/** "好评(3)"; "全部" has no count. */
function title(f) {
  const name = displayName(f);
  if (f.name === '全部') return name;
  return `${name}(${reviewsMatching(f).length})`;
}

module.exports = {
  RATING, KEYWORDS, reviews, filters, reviewsMatching, reviewsMatchingAll, filterWithIdentifier, displayName, title,
};
