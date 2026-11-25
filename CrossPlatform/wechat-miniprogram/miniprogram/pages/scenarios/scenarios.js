/**
 * 查询筛选: the plus button's page, 1:1 with the iOS example's `CYLQueryScenariosViewController` (an inset grouped
 * table): the filter demos by scenario, then the database's tables with their row counts. A tag opens its demo,
 * pushed without the tab bar; the list is a cyl-tag-list (scenarios-model.js).
 */
const { t } = require('../../utils/i18n.js');
const db = require('../../utils/places-db.js');
const reviews = require('../../data/reviews.js');
const selections = require('../../utils/selections.js');
const model = require('./scenarios-model.js');

/** The rows of a table: reviews and places from the shared database, selections from the saved scenarios. */
function rowCount(table) {
  if (table === 'reviews') return reviews.length;
  if (table === 'places') return db.ROWS.length;
  return selections.savedScenarios().length;
}

Page({
  data: { configuration: {} },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('查询筛选') });
  },

  onShow() {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().syncWithRoute(this.route);
    // The selections saved by the demos change the database section (viewWillAppear reloads the table).
    this.setData({
      configuration: model.configuration(t, {
        reviews: rowCount('reviews'), places: rowCount('places'), selections: rowCount('selections'),
      }),
    });
  },

  onTagTap(event) {
    const url = model.urlFor(event.detail.section, event.detail.item);
    if (url) wx.navigateTo({ url });
  },
});
