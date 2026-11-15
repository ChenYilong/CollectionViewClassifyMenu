import { abilityDelegatorRegistry, Driver, MatchPattern, ON } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';
import { describe, beforeAll, it, expect } from '@ohos/hypium';

const BUNDLE = 'com.cyl.classifymenu.example';

<<<<<<< HEAD
/**
 * A string of the example (entry) or the core (cyl_menu_*) in the device language: the test finds controls by what
 * the screen reader and the user see, so it runs in every language.
 */
function text(key: string): string {
  const context = abilityDelegatorRegistry.getAbilityDelegator().getAppContext().createModuleContext('entry');
  return context.resourceManager.getStringByNameSync(key);
}

/**
 * The example's screens driven as a user would, through accessibility first (AGENTS.md "Accessibility and
 * localization on HarmonyOS"): tabs, buttons and tags by their localized text, the fold control by its localized
 * hint; ids only where a control has no text of its own (the slider's thumb position).
 */
=======
/** The example's root tab bar and scenarios 1 and 2 (the iOS example's screens), driven as a user would. */
>>>>>>> c69f327 (feat(harmony): the iOS example's screens on HarmonyOS (score 98.4))
export default function exampleUiTest() {
  describe('ExampleUiTest', () => {
    beforeAll(async () => {
      const want: Want = { bundleName: BUNDLE, abilityName: 'EntryAbility' };
      await abilityDelegatorRegistry.getAbilityDelegator().startAbility(want);
      await Driver.create().delayMs(2000);
    })

    it('rootTabBarShowsTheIOSTabs', 0, async () => {
      const driver = Driver.create();
<<<<<<< HEAD
      // The first section's fold control, by its hint ("Shows every tag").
      const unfold = await driver.findComponent(ON.description(text('cyl_menu_expand_hint')));
      expect(unfold !== null).assertTrue();
      await unfold.click();
      await driver.delayMs(500);
      // Its hint changes once the section is open.
      await driver.assertComponentExist(ON.description(text('cyl_menu_collapse_hint')));

      // A tag of the Lottie row by its localized title.
      await (await driver.findComponent(ON.text(text('tab_home')))).click();
      await driver.delayMs(500);
      const tapped = text('tapped').replace('%s', text('tab_home'));
      await driver.assertComponentExist(ON.text(tapped));

      const loop = await driver.findComponent(ON.text(text('loop')).isBefore(ON.text(text('play_all'))));
      expect(loop !== null).assertTrue();
      const loopSwitch = await driver.findComponent(ON.type('Toggle'));
      const before = await loopSwitch.isChecked();
      await loopSwitch.click();
      await driver.delayMs(300);
      expect(await (await driver.findComponent(ON.type('Toggle'))).isChecked()).assertEqual(!before);

      // The slider has no text: found by its type, read through its localized accessibility description.
      const slider = await driver.findComponent(ON.type('Slider'));
      const speed = await slider.getDescription();
      const bounds = await slider.getBounds();
      const y = Math.round((bounds.top + bounds.bottom) / 2);
      await driver.drag(Math.round((bounds.left + bounds.right) / 2), y, bounds.right + 40, y, 600);
      await driver.delayMs(300);
      const faster = await (await driver.findComponent(ON.type('Slider'))).getDescription();
      expect(`${parseFloat(speed)} -> ${parseFloat(faster)}`).assertEqual('1 -> 4');

      await (await driver.findComponent(ON.text(text('play_all')))).click();
=======
      await driver.assertComponentExist(ON.id('tab-场景一：评价筛选'));
      await driver.assertComponentExist(ON.id('tab-场景二：搜索分类'));
      await driver.assertComponentExist(ON.id('tab-plus'));
      await driver.assertComponentExist(ON.id('tab-样式'));
      await driver.assertComponentExist(ON.id('tab-动效'));
      await driver.assertComponentExist(ON.text('宝贝详情'));
>>>>>>> c69f327 (feat(harmony): the iOS example's screens on HarmonyOS (score 98.4))
    })

    it('productKeywordOpensFilteredReviews', 0, async () => {
      const driver = Driver.create();
<<<<<<< HEAD
      const all = text('all');
      const count = (n: number): string => text('places_count').replace('%d', `${n}`);
      await (await driver.findComponent(ON.text(text('tab_classify')))).click();
      await driver.delayMs(1500);
      await (await driver.findComponent(ON.text(text('reset')))).click();
      await driver.delayMs(500);
      await driver.assertComponentExist(ON.text(`${all}: ${count(83)}`));
      // A multi-step flow by text: pick 川菜, check the list shrank, reset.
      await (await driver.findComponent(ON.text('川菜', MatchPattern.STARTS_WITH))).click();
      await driver.delayMs(800);
      const summary = await (await driver.findComponent(ON.text('川菜', MatchPattern.STARTS_WITH)
        .isAfter(ON.text(text('reset'))).within(ON.type('List')))).getText();
      expect(summary.length > 0).assertTrue();
      await (await driver.findComponent(ON.text(text('reset')))).click();
      await driver.delayMs(500);
      await driver.assertComponentExist(ON.text(`${all}: ${count(83)}`));
=======
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
      await (await driver.findComponent(ON.id('CYLDemoBarBack'))).click();
      await driver.delayMs(800);
>>>>>>> c69f327 (feat(harmony): the iOS example's screens on HarmonyOS (score 98.4))
    })
  })
}
