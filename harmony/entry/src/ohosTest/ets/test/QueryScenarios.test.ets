import { CYLExampleLocalizedString } from '../../../main/ets/data/CYLExampleLocalization';
import { ON } from '@kit.TestKit';
import { describe, it, expect } from '@ohos/hypium';
import { cylBack, cylLaunchExample, cylTap, cylTapAccessible, cylText } from './TestSupport';

/**
 * The plus button's query scenarios: the database tables, the classify menu with the multiple filter, and the search
 * history with discover (CYLQueryScenariosViewController, CYLMenuLinkageViewController, CYLSearchDiscoverViewController).
 */
export default function queryScenariosTest() {
  describe('QueryScenariosTest', () => {
    it('scenariosListTheTablesWithRowCounts', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTapAccessible(driver, CYLExampleLocalizedString('查询筛选'), 'tab-plus', 1500);
      await driver.assertComponentExist(ON.id('scenario-0'));
      await driver.assertComponentExist(ON.id('scenario-3'));
      await cylTap(driver, 'table-reviews', 300);
      const places = await cylText(driver, 'table-places');
      expect(places.length > 0).assertTrue();
    })

    it('menuLinkageQueriesTheDatabase', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTapAccessible(driver, CYLExampleLocalizedString('查询筛选'), 'tab-plus', 1500);
      await cylTapAccessible(driver, CYLExampleLocalizedString('分类菜单 + 多选筛选 · 数据库联动'), 'scenario-3', 2000);
      const before = await cylText(driver, 'menuLinkageStatus');
      expect(before.includes('SQLite')).assertTrue();
      await cylTapAccessible(driver, CYLExampleLocalizedString('多选筛选'), 'menuLinkageFilter', 1000);
      await driver.assertComponentExist(ON.id('menuLinkageFilter'));
      await cylBack(driver);
      await cylTapAccessible(driver, CYLExampleLocalizedString('重置'), 'menuLinkageReset', 1500);
      const after = await cylText(driver, 'menuLinkageStatus');
      expect(after.includes('SQLite')).assertTrue();
      await cylBack(driver);
    })

    it('searchDiscoverShowsRecentAndDiscover', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTapAccessible(driver, CYLExampleLocalizedString('查询筛选'), 'tab-plus', 1500);
      await cylTapAccessible(driver, CYLExampleLocalizedString('最近搜索 + 发现'), 'scenario-4', 1500);
      await driver.assertComponentExist(ON.id('recentList'));
      await driver.assertComponentExist(ON.id('discoverList'));
      await driver.assertComponentExist(ON.id('CYLSearchDiscoverField'));
      await cylTapAccessible(driver, CYLExampleLocalizedString('清空最近搜索'), 'clearRecentSearches', 800);
      await driver.assertComponentExist(ON.id('discoverList'));
      await cylTapAccessible(driver, CYLExampleLocalizedString('返回'), 'CYLSearchDiscoverBack', 800);
    })
  })
}
