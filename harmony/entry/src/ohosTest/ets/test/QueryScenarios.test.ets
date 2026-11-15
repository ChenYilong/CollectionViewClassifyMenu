import { ON } from '@kit.TestKit';
import { describe, it, expect } from '@ohos/hypium';
import { cylBack, cylLaunchExample, cylTap, cylText } from './TestSupport';

/**
 * The plus button's query scenarios: the database tables, the classify menu with the multiple filter, and the search
 * history with discover (CYLQueryScenariosViewController, CYLMenuLinkageViewController, CYLSearchDiscoverViewController).
 */
export default function queryScenariosTest() {
  describe('QueryScenariosTest', () => {
    it('scenariosListTheTablesWithRowCounts', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTap(driver, 'tab-plus', 1500);
      await driver.assertComponentExist(ON.id('scenario-0'));
      await driver.assertComponentExist(ON.id('scenario-3'));
      await cylTap(driver, 'table-reviews', 300);
      const places = await cylText(driver, 'table-places');
      expect(places.length > 0).assertTrue();
    })

    it('menuLinkageQueriesTheDatabase', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTap(driver, 'tab-plus', 1500);
      await cylTap(driver, 'scenario-3', 2000);
      const before = await cylText(driver, 'menuLinkageStatus');
      expect(before.includes('SQLite')).assertTrue();
      await cylTap(driver, 'menuLinkageFilter', 1000);
      await driver.assertComponentExist(ON.id('menuLinkageFilter'));
      await cylBack(driver);
      await cylTap(driver, 'menuLinkageReset', 1500);
      const after = await cylText(driver, 'menuLinkageStatus');
      expect(after.includes('SQLite')).assertTrue();
      await cylBack(driver);
    })

    it('searchDiscoverShowsRecentAndDiscover', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTap(driver, 'tab-plus', 1500);
      await cylTap(driver, 'scenario-4', 1500);
      await driver.assertComponentExist(ON.id('recentList'));
      await driver.assertComponentExist(ON.id('discoverList'));
      await driver.assertComponentExist(ON.id('CYLSearchDiscoverField'));
      await cylTap(driver, 'clearRecentSearches', 800);
      await driver.assertComponentExist(ON.id('discoverList'));
      await cylTap(driver, 'CYLSearchDiscoverBack', 800);
    })
  })
}
