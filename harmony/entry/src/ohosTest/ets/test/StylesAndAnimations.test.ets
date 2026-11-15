import { ON } from '@kit.TestKit';
import { describe, it, expect } from '@ohos/hypium';
import { CYLExampleLocalizedString } from '../../../main/ets/data/CYLExampleLocalization';
import { cylBack, cylLaunchExample, cylTap, cylText } from './TestSupport';

/**
 * The 样式 and 动效 tabs and the configuration demo (CYLTagStyleDemoViewController, CYLTagAnimationDemoViewController,
 * CYLTagConfigurationDemoViewController).
 */
export default function stylesAndAnimationsTest() {
  describe('StylesAndAnimationsTest', () => {
    it('styleActionsApplyAndReset', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTap(driver, 'tab-样式', 1200);
      await driver.assertComponentExist(ON.id('styleTagList'));
      await cylTap(driver, 'style-borderWidth', 400);
      await cylTap(driver, 'style-cornerRadius', 400);
      await cylTap(driver, 'style-content.titleOnly', 400);
      await cylTap(driver, 'style-reset', 400);
      await driver.assertComponentExist(ON.id('styleTagList'));
    })

    it('animationControlsPlayAll', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTap(driver, 'tab-动效', 1500);
      await driver.assertComponentExist(ON.id('speedSlider'));
      await driver.assertComponentExist(ON.id('loopSwitch'));
      expect(await cylText(driver, 'speedValue')).assertEqual('1×');
      await cylTap(driver, 'loopSwitch', 400);
      await cylTap(driver, 'playAll', 1500);
      const status = await cylText(driver, 'animationStatus');
      expect(status.length > 0).assertTrue();
    })

    it('configurationBuildsBothLists', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTap(driver, 'tab-样式', 1200);
      await cylTap(driver, 'style-configuration', 1500);
      await driver.assertComponentExist(ON.id('configurationFileList'));
      await driver.assertComponentExist(ON.id('configurationMapList'));
      await driver.assertComponentExist(ON.text(CYLExampleLocalizedString('配置初始化')));
      await cylBack(driver);
    })
  })
}
