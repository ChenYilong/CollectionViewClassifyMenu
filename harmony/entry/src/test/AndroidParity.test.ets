import { describe, it, expect } from '@ohos/hypium';
import {
  CYLColor, CYLControlState, CYLFilterParamsTool, CYLMenuStyle, CYLTag, CYLTagContentAlignment,
  kMultipleFilterSetting, kMultipleFilterSettingModified, kTagCollectionViewCellsHorizonMargin,
  kTagCollectionViewToBottomtMargin, kTagCollectionViewToLeftMargin
} from '@cyl/classifymenu';

/**
 * The APIs the iOS core added for Android parity (docs/android-ios-api.md), ported to HarmonyOS: the filter's params
 * tool, the classify menu's spacing constants, the classify menu / filter / section-title styles and the resets.
 */
export default function androidParityTest() {
  describe('AndroidParity', () => {
    it('makesTheFilterParamsOnFirstUse', 0, () => {
      const tool = new CYLFilterParamsTool();
      tool.dataSources = [['全部', '北京', '上海'], ['全部', '川菜']];
      // The first item of each section is selected by default.
      expect(JSON.stringify(tool.filterParamsArray)).assertEqual(JSON.stringify([[true, false, false], [true, false]]));
      expect(tool.filterParamsDictionary[kMultipleFilterSettingModified]).assertEqual(false);
      expect(JSON.stringify(tool.filterParamsDictionary[kMultipleFilterSetting])).assertEqual(JSON.stringify(tool.filterParamsArray));
      expect(JSON.stringify(tool.filterParamsContentDictionary)).assertEqual(JSON.stringify({ skilled: [] }));
      expect(tool.filename).assertEqual(kMultipleFilterSetting);
      tool.filesDir = '/data/files';
      expect(tool.filename).assertEqual('/data/files/kMultipleFilterSetting');
      tool.filename = 'custom';
      expect(tool.filename).assertEqual('custom');
    });

    it('exposesTheClassifyMenuSpacing', 0, () => {
      expect(kTagCollectionViewCellsHorizonMargin).assertEqual(12);
      expect(kTagCollectionViewToLeftMargin).assertEqual(16);
      expect(kTagCollectionViewToBottomtMargin).assertEqual(10);
    });

    it('buildsTheClassifyMenuFilterAndSectionTitleStyles', 0, () => {
      // chengNi (the default look): a mint capsule, the app tint while selected.
      const chengNi = CYLMenuStyle.classifyMenuTag();
      expect(chengNi.appearance(CYLControlState.NORMAL).cornerRadius).assertEqual(13);
      expect(chengNi.appearance(CYLControlState.SELECTED).backgroundColor).assertEqual(CYLColor.APP_TINT);
      expect(chengNi.itemHeight).assertEqual(30);
      // general: white with a 1 vp black border.
      const general = CYLMenuStyle.classifyMenuTag(0);
      expect(general.appearance(CYLControlState.NORMAL).borderWidth).assertEqual(1);
      const filter = CYLMenuStyle.filterTag();
      expect(filter.appearance(CYLControlState.SELECTED).textColor).assertEqual(CYLColor.WHITE);
      expect(filter.appearance(CYLControlState.NORMAL).backgroundImage !== undefined).assertTrue();
      const title = CYLMenuStyle.sectionTitle(12, CYLColor.BLACK, 8);
      expect(title.contentAlignment).assertEqual(CYLTagContentAlignment.leading);
      expect(title.appearance(CYLControlState.NORMAL).contentInsets.left).assertEqual(8);
    });

    it('resetsTheTagColors', 0, () => {
      const tag = new CYLTag(0, 'Tag', '#FF0000');
      tag.resetColors();
      expect(tag.backgroundColor === '#FF0000').assertFalse();
    });
  });
}
