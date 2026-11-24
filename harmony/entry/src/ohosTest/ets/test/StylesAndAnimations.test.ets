import { ON } from '@kit.TestKit';
import { describe, it, expect } from '@ohos/hypium';
import { CYLExampleLocalizedString } from '../../../main/ets/data/CYLExampleLocalization';
import { cylBack, cylLaunchExample, cylTapAccessible, cylText } from './TestSupport';

/**
 * The 样式 and 动效 tabs and the configuration demo (CYLTagStyleDemoViewController, CYLTagAnimationDemoViewController,
 * CYLTagConfigurationDemoViewController).
 */
export default function stylesAndAnimationsTest() {
  describe('StylesAndAnimationsTest', () => {
    it('styleActionsApplyAndReset', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTapAccessible(driver, CYLExampleLocalizedString('样式'), 'tab-样式', 1200);
      await driver.assertComponentExist(ON.id('styleTagList'));
      await cylTapAccessible(driver, CYLExampleLocalizedString('设置边框宽度 borderWidth'), 'style-borderWidth', 400);
      await cylTapAccessible(driver, CYLExampleLocalizedString('设置圆角 cornerRadius（0 为直角，1000 为胶囊）'), 'style-cornerRadius', 400);
      await cylTapAccessible(driver, CYLExampleLocalizedString('只显示 title'), 'style-content.titleOnly', 400);
      await cylTapAccessible(driver, CYLExampleLocalizedString('重置 reset'), 'style-reset', 400);
      await driver.assertComponentExist(ON.id('styleTagList'));
    })

    it('animationControlsPlayAll', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTapAccessible(driver, CYLExampleLocalizedString('动效'), 'tab-动效', 1500);
      await driver.assertComponentExist(ON.id('speedSlider'));
      await driver.assertComponentExist(ON.id('loopSwitch'));
      // The speed is read through accessibility: the "1×" label is hidden from it (accessibilityLevel('no'), so uitest
      // reads it as empty) and the slider's description announces the speed instead.
      const slider = await driver.findComponent(ON.id('speedSlider'));
      expect(await slider.getDescription()).assertEqual(CYLExampleLocalizedString('%@ 倍').replace('%@', '1'));
      await cylTapAccessible(driver, CYLExampleLocalizedString('循环播放'), 'loopSwitch', 400);
      await cylTapAccessible(driver, CYLExampleLocalizedString('全部播放'), 'playAll', 1500);
      const status = await cylText(driver, 'animationStatus');
      expect(status.length > 0).assertTrue();
    })

    it('configurationBuildsBothLists', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTapAccessible(driver, CYLExampleLocalizedString('样式'), 'tab-样式', 1200);
      await cylTapAccessible(driver, CYLExampleLocalizedString('配置文件 / 字典（map）初始化'), 'style-configuration', 1500);
      await driver.assertComponentExist(ON.id('configurationFileList'));
      await driver.assertComponentExist(ON.id('configurationMapList'));
      await driver.assertComponentExist(ON.text(CYLExampleLocalizedString('配置初始化')));
      await cylBack(driver);
    })
  })
}
