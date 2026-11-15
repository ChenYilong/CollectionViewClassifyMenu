import { describe, it, expect } from '@ohos/hypium';
import { Want } from '@kit.AbilityKit';
import { CYLLaunchOptions } from '../main/ets/data/CYLLaunchOptions';
import { cylExampleLanguage, CYLExampleLocalizedString } from '../main/ets/data/CYLExampleLocalization';

/** The launch options used by scripts/screenshots.sh (screen, its parameter, language, color mode). */
export default function launchOptionsTest() {
  describe('CYLLaunchOptions', () => {
    it('readsTheScreenAndItsParameter', 0, () => {
      const want: Want = { parameters: { 'cylScreen': 'CYLReviewListViewController',
        'cylScreenParam': '{"selectedFilterIndex":0,"mode":"network"}' } };
      CYLLaunchOptions.read(want);
      const param = CYLLaunchOptions.screenParam as Record<string, Object>;
      expect(param['mode'] as string).assertEqual('network');
      expect(CYLLaunchOptions.takeScreen()).assertEqual('CYLReviewListViewController');
      // Taken once.
      expect(CYLLaunchOptions.takeScreen()).assertEqual('');
    });

    it('ignoresABrokenParameter', 0, () => {
      CYLLaunchOptions.read({ parameters: { 'cylScreen': 'CYLProductViewController', 'cylScreenParam': '{oops' } });
      expect(CYLLaunchOptions.screenParam === undefined).assertTrue();
      CYLLaunchOptions.takeScreen();
    });

    it('switchesTheExampleLanguage', 0, () => {
      CYLLaunchOptions.read({ parameters: { 'cylLanguage': 'en', 'cylColorMode': 'dark' } });
      expect(cylExampleLanguage()).assertEqual('en');
      expect(CYLExampleLocalizedString('宝贝详情')).assertEqual('Item');
      expect(CYLLaunchOptions.colorMode).assertEqual('dark');
      CYLLaunchOptions.read({ parameters: { 'cylLanguage': 'zh-Hant' } });
      expect(cylExampleLanguage()).assertEqual('zh-Hant');
      CYLLaunchOptions.language = '';
      CYLLaunchOptions.colorMode = '';
    });
  });
}
