/**
 * 宝贝详情 (tab 场景一：评价筛选), 1:1 with the iOS example's CYLProductViewController: the product's name and price,
 * then 宝贝评价(10), a two-row preview of the review keywords, the first two reviews and 查看更多评价. A keyword opens the
 * review page with that keyword selected; the button opens it with 全部.
 */
const { t } = require('../../utils/i18n.js');
const store = require('../reviews/store.js');
const preview = require('./preview.js');

Page({
  data: {
    name: preview.PRODUCT.name,
    price: preview.PRODUCT.price,
    reviewTitle: '',
    configuration: {},
    reviews: [],
    moreTitle: '',
  },

  onLoad() {
    // navigationItem, not title: a view controller's title would replace its tab's title.
    wx.setNavigationBarTitle({ title: t('宝贝详情') });
    this.previewFilterIndexes = preview.previewFilterIndexes();
    this.setData({
      reviewTitle: t('宝贝评价(%lu)', store.reviews.length),
      configuration: preview.previewConfiguration(),
      reviews: preview.previewReviews(),
      moreTitle: t('查看更多评价'),
    });
  },

  onShow() {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().syncWithRoute(this.route);
  },

  onKeywordTap(event) {
    this.showReviews(this.previewFilterIndexes[event.detail.item]);
  },

  moreTapped() {
    this.showReviews(0);
  },

  /** Pushes the review page with the given filter selected (hidesBottomBarWhenPushed: a pushed page has no tab bar). */
  showReviews(index) {
    wx.navigateTo({ url: preview.reviewsURL(index) });
  },
});
