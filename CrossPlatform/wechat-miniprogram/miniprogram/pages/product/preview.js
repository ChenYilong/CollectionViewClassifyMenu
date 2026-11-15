/**
 * The product page's keyword preview without `wx` (node --test), 1:1 with CYLProductViewController: the keyword filters
 * only (their indexes in CYLReviewStore.filters kept for the review page), in reviewFilterStyle() with section insets
 * {4, 0, 12, 0}, no selection, no section header, truncated to two rows without a fold control (foldStyle .truncate).
 */
const store = require('../reviews/store.js');
const list = require('../reviews/list.js');

/** The sample product (not localized). */
const PRODUCT = { name: '潮牌电镀镜面MLGB字母iphone6手机壳苹果6plus手机壳情侣5S外壳潮', price: '¥9.90-14.90' };

/** Maps preview items to indexes in store.filters. */
function previewFilterIndexes() {
  return store.filters.map((f, index) => (f.isKeyword ? index : -1)).filter((index) => index >= 0);
}

function previewConfiguration() {
  return {
    selectionMode: 'none',
    defaultVisibleRows: 2,
    foldControl: { position: 'none', content: 'title' },
    style: list.reviewFilterStyle({ sectionInsets: { top: 4, left: 0, bottom: 12, right: 0 } }),
    // The section's title 关键词 is not shown (showsSectionHeaders = false); cyl-tag-list hides an untitled header.
    sections: [{ title: '', items: previewFilterIndexes().map((index) => ({ title: store.title(store.filters[index]) })) }],
  };
}

/** The first two reviews, "user\ntext". */
function previewReviews() {
  return store.reviews.slice(0, 2).map((r) => ({ id: r.id, text: `${r.user}\n${r.text}` }));
}

/** The review page for a filter index (CYLReviewListViewController(selectedFilterIndex:), memory). */
function reviewsURL(index) {
  return `/pages/reviews/reviews?filter=${index}`;
}

module.exports = { PRODUCT, previewFilterIndexes, previewConfiguration, previewReviews, reviewsURL };
