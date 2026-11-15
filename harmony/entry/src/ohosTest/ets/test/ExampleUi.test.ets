import { abilityDelegatorRegistry, Driver, MatchPattern, ON } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';
import { describe, beforeAll, it, expect } from '@ohos/hypium';

const BUNDLE = 'com.cyl.classifymenu.example';

/** The example's root tab bar and scenarios 1 and 2 (the iOS example's screens), driven as a user would. */
export default function exampleUiTest() {
  describe('ExampleUiTest', () => {
    beforeAll(async () => {
      const want: Want = { bundleName: BUNDLE, abilityName: 'EntryAbility' };
      await abilityDelegatorRegistry.getAbilityDelegator().startAbility(want);
      await Driver.create().delayMs(2000);
    })

    it('rootTabBarShowsTheIOSTabs', 0, async () => {
      const driver = Driver.create();
      await driver.assertComponentExist(ON.id('tab-场景一：评价筛选'));
      await driver.assertComponentExist(ON.id('tab-场景二：搜索分类'));
      await driver.assertComponentExist(ON.id('tab-plus'));
      await driver.assertComponentExist(ON.id('tab-样式'));
      await driver.assertComponentExist(ON.id('tab-动效'));
      await driver.assertComponentExist(ON.text('宝贝详情'));
    })

    it('productKeywordOpensFilteredReviews', 0, async () => {
      const driver = Driver.create();
      // The keyword preview: "质量不错(5)" opens the review page with that filter selected.
      await (await driver.findComponent(ON.text('质量不错', MatchPattern.STARTS_WITH).within(ON.id('productPreview'))))
        .click();
      await driver.delayMs(1000);
      const status = await (await driver.findComponent(ON.id('reviewStatus'))).getText();
      expect(status.includes('已选：质量不错')).assertTrue();
      expect(status.includes('匹配 5 条')).assertTrue();

      // Network filtering answers after the simulated delay.
      await (await driver.findComponent(ON.id('reviewMode-1'))).click();
      await driver.delayMs(1200);
      const network = await (await driver.findComponent(ON.id('reviewStatus'))).getText();
      expect(network.includes('GET /reviews?filter=keyword:质量不错')).assertTrue();
      expect(network.includes('服务器返回 5 条')).assertTrue();

      // Database filtering runs the SQL on the shared database.
      await (await driver.findComponent(ON.id('reviewMode-2'))).click();
      await driver.delayMs(1500);
      const database = await (await driver.findComponent(ON.id('reviewStatus'))).getText();
      expect(database.includes('k.keyword = \'质量不错\'')).assertTrue();
      expect(database.includes('匹配 5 条')).assertTrue();
      await (await driver.findComponent(ON.id('CYLDemoBarBack'))).click();
      await driver.delayMs(800);
    })

    it('searchCategoryTagFillsTheSearchBar', 0, async () => {
      const driver = Driver.create();
      await (await driver.findComponent(ON.id('tab-场景二：搜索分类'))).click();
      await driver.delayMs(800);
      await (await driver.findComponent(ON.id('searchHomeButton'))).click();
      await driver.delayMs(1000);
      await (await driver.findComponent(ON.text('百度研发'))).click();
      await driver.delayMs(500);
      expect(await (await driver.findComponent(ON.id('searchCategoryField'))).getText()).assertEqual('百度研发');
      await (await driver.findComponent(ON.id('searchTab-职位'))).click();
      await driver.delayMs(800);
      await driver.assertComponentExist(ON.id('industryButton'));
      await (await driver.findComponent(ON.id('jobCategory-1'))).click();
      await driver.delayMs(500);
      await driver.assertComponentExist(ON.text('自动化测试'));
      await (await driver.findComponent(ON.id('CYLSearchCategoryBack'))).click();
      await driver.delayMs(800);
    })
  })
}
