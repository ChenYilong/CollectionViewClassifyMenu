import { abilityDelegatorRegistry, Driver, MatchPattern, ON } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';
import { describe, beforeAll, it, expect } from '@ohos/hypium';

const BUNDLE = 'com.cyl.classifymenu.example';

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
export default function exampleUiTest() {
  describe('ExampleUiTest', () => {
    beforeAll(async () => {
      const want: Want = { bundleName: BUNDLE, abilityName: 'EntryAbility' };
      await abilityDelegatorRegistry.getAbilityDelegator().startAbility(want);
      await Driver.create().delayMs(2000);
    })

    it('tagsTabUnfoldsTapsAndSetsPlayback', 0, async () => {
      const driver = Driver.create();
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
    })

    it('classifyTabFiltersByTagAndResets', 0, async () => {
      const driver = Driver.create();
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
    })
  })
}
