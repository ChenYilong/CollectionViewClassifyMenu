import { describe, it, expect } from '@ohos/hypium';
import { CYLMenuResources } from '@cyl/classifymenu';
import { cylExampleLanguage, CYLExampleLocalizedString } from '../main/ets/data/CYLExampleLocalization';
import { cylFormat } from '../main/ets/demos/samples/SampleSupport';

export default function localizationTest() {
  describe('CYLExampleLocalization', () => {
    it('picksTheLanguageAsIOSDoes', 0, () => {
      expect(cylExampleLanguage('en-Latn-US')).assertEqual('en');
      expect(cylExampleLanguage('zh-Hans')).assertEqual('zh-Hans');
      expect(cylExampleLanguage('zh-Hans-CN')).assertEqual('zh-Hans');
      expect(cylExampleLanguage('zh-Hant')).assertEqual('zh-Hant');
      expect(cylExampleLanguage('zh-TW')).assertEqual('zh-Hant');
      expect(cylExampleLanguage('zh-HK')).assertEqual('zh-Hant');
      expect(cylExampleLanguage('fr-FR')).assertEqual('en');
    });

    it('looksUpTheIOSStrings', 0, () => {
      expect(CYLExampleLocalizedString('宝贝详情', 'en')).assertEqual('Item');
      expect(CYLExampleLocalizedString('宝贝详情', 'zh-Hans')).assertEqual('宝贝详情');
      expect(CYLExampleLocalizedString('SVGA 动效图标', 'en')).assertEqual('SVGA animated icons');
      expect(CYLExampleLocalizedString('SVGA 动效图标', 'zh-Hant')).assertEqual('SVGA 動效圖示');
      // A key without a translation (sample data) stays as it is.
      expect(CYLExampleLocalizedString('质量不错', 'en')).assertEqual('质量不错');
    });

    it('formatsTheIOSPlaceholders', 0, () => {
      expect(cylFormat(CYLExampleLocalizedString('匹配 %lu 条', 'en'), 5)).assertEqual('5 matches');
      expect(cylFormat(CYLExampleLocalizedString('SQLite 返回 %lu 条（共 %ld 家）', 'en'), 3, 40))
        .assertEqual('SQLite returned 3 (of 40 places)');
      expect(cylFormat('点击「%@」', '川菜')).assertEqual('点击「川菜」');
    });

    it('hasTheCoreStringsInThreeLanguages', 0, () => {
      expect(CYLMenuResources.availableLanguages.join(',')).assertEqual('en,zh-Hans,zh-Hant');
      expect(CYLMenuResources.localizedString('CYLFilterReset', 'en')).assertEqual('Reset');
    });
  });
}
