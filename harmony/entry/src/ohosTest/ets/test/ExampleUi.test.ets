import { abilityDelegatorRegistry, Driver, MatchPattern, ON } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';
import { describe, beforeAll, it, expect } from '@ohos/hypium';

const BUNDLE = 'com.cyl.classifymenu.example';

/** The example's screens driven as a user would: the checks of docs/android.md, done by hand before. */
export default function exampleUiTest() {
  describe('ExampleUiTest', () => {
    beforeAll(async () => {
      const want: Want = { bundleName: BUNDLE, abilityName: 'EntryAbility' };
      await abilityDelegatorRegistry.getAbilityDelegator().startAbility(want);
      await Driver.create().delayMs(2000);
    })

    it('tagsTabUnfoldsTapsAndSetsPlayback', 0, async () => {
      const driver = Driver.create();
      await driver.assertComponentExist(ON.id('CYLTagListFold-0'));
      await (await driver.findComponent(ON.id('CYLTagListFold-0'))).click();
      await driver.delayMs(500);
      await (await driver.findComponent(ON.id('CYLTagListItem-0-0'))).click();
      await driver.delayMs(500);
      const lastTap = await (await driver.findComponent(ON.id('lastTap'))).getText();
      expect(lastTap.length > 0).assertTrue();

      const loop = await driver.findComponent(ON.id('loopSwitch'));
      const before = await loop.isChecked();
      await loop.click();
      await driver.delayMs(300);
      expect(await (await driver.findComponent(ON.id('loopSwitch'))).isChecked()).assertEqual(!before);

      // The value label is hidden from the screen reader; the slider's description carries it ("1 times").
      const speed = await (await driver.findComponent(ON.id('speedSlider'))).getDescription();
      const slider = await driver.findComponent(ON.id('speedSlider'));
      const bounds = await slider.getBounds();
      // Dragged to its right end: the maximum, 4x.
      const y = Math.round((bounds.top + bounds.bottom) / 2);
      await driver.drag(Math.round((bounds.left + bounds.right) / 2), y, bounds.right + 40, y, 600);
      await driver.delayMs(300);
      const faster = await (await driver.findComponent(ON.id('speedSlider'))).getDescription();
      // Localized ("4 times", "4 倍"): only the number is compared.
      expect(`${parseFloat(speed)} -> ${parseFloat(faster)}`).assertEqual('1 -> 4');
      await driver.assertComponentExist(ON.id('playAll'));
      await (await driver.findComponent(ON.id('playAll'))).click();
    })

    it('classifyTabFiltersByTagAndResets', 0, async () => {
      const driver = Driver.create();
      await (await driver.findComponent(ON.id('tab-Classify'))).click();
      await driver.delayMs(1500);
      const reset = await driver.findComponent(ON.id('reset'));
      await reset.click();
      await driver.delayMs(500);
      expect(await (await driver.findComponent(ON.id('summary'))).getText()).assertEqual('全部: 83 places');
      await (await driver.findComponent(ON.text('川菜', MatchPattern.STARTS_WITH).within(ON.id('classifyPage')))).click();
      await driver.delayMs(800);
      const filtered = await (await driver.findComponent(ON.id('summary'))).getText();
      expect(filtered.startsWith('川菜')).assertTrue();
      expect(filtered.endsWith(': 83 places')).assertFalse();
      await (await driver.findComponent(ON.id('reset'))).click();
      await driver.delayMs(500);
      expect(await (await driver.findComponent(ON.id('summary'))).getText()).assertEqual('全部: 83 places');
    })
  })
}
