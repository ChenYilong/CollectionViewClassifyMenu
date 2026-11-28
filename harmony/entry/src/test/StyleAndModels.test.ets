import { describe, it, expect } from '@ohos/hypium';
import {
  CYLColor, CYLControlState, CYLMenuColorFromString, CYLMenuStyle, CYLTag, CYLTagColors, CYLTagColorTheme, CYLTagGroup,
  CYLTagModel
} from '@cyl/classifymenu';

const BADGE_DOT_DIAMETER: number = 8;
const BADGE_TEXT_PADDING: number = 4;
const BADGE_DIAMETER: number = 16;
const BADGE_SHORT_TEXT_WIDTH: number = 6;
const BADGE_LONG_TEXT_WIDTH: number = 24;

/**
 * The style value types (CYLMenuStyle, colors) and the tag models (CYLTag, CYLTagModel, CYLTagGroup).
 */
export default function styleAndModelsTest() {
  describe('CYLMenuStyle', () => {
    it('parsesColorsAsIOSDoes', 0, () => {
      expect(CYLMenuColorFromString('#FF6A00')).assertEqual('#FFFF6A00');
      expect(CYLMenuColorFromString('#f60')).assertEqual('#FFFF6600');
      expect(CYLMenuColorFromString('#11223380')).assertEqual('#80112233');
      expect(CYLMenuColorFromString('#12')).assertEqual(undefined);
      expect(CYLMenuColorFromString('#GGGGGG')).assertEqual(undefined);
      expect(CYLMenuColorFromString(undefined)).assertEqual(undefined);
      expect(CYLMenuColorFromString('nonsenseColor')).assertEqual(undefined);
    });

    it('tintsBitmapIconsWithAnAlphaPreservingFilter', 0, () => {
      // White: every pixel's color channels become its alpha, so the icon is white where it is opaque (Y2).
      expect(JSON.stringify(CYLColor.tintFilter('#FFFFFFFF')))
        .assertEqual(JSON.stringify([0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0]));
      // '#RRGGBB' is opaque; no offsets, so the result does not depend on the channel range.
      const orange = CYLColor.tintFilter('#FF5000');
      expect(orange[3]).assertEqual(1);
      expect(Math.round(orange[8] * 255)).assertEqual(0x50);
      expect(orange[13]).assertEqual(0);
      expect(orange[18]).assertEqual(1);
      expect([orange[4], orange[9], orange[14], orange[19]].every((offset: number) => offset === 0)).assertTrue();
    });

    it('keepsStatesApartAndCopiesDeeply', 0, () => {
      const style = new CYLMenuStyle();
      style.setIconColor('#FF0000', CYLControlState.NORMAL);
      style.setIconColor('#00FF00', CYLControlState.SELECTED);
      expect(style.iconColor(CYLControlState.NORMAL)).assertEqual('#FF0000');
      expect(style.iconColor(CYLControlState.SELECTED)).assertEqual('#00FF00');
      const copy = style.copy();
      copy.setIconColor('#0000FF', CYLControlState.NORMAL);
      copy.selectedAppearance.backgroundColor = '#123456';
      expect(style.iconColor(CYLControlState.NORMAL)).assertEqual('#FF0000');
      expect(style.selectedAppearance.backgroundColor === '#123456').assertFalse();
    });

    it('shortensAndReversesTitles', 0, () => {
      const style = new CYLMenuStyle();
      expect(style.displayedTitle('abcdef')).assertEqual('abcdef');
      // As AndroidTagView's tag_max_length (and iOS since 58b2f335): max - 3 characters and "...", max in all.
      style.maximumTitleLength = 5;
      expect(style.displayedTitle('abcdef')).assertEqual('ab...');
      style.maximumTitleLength = 23;
      expect(style.displayedTitle('Welcome to use AndroidTagView!')).assertEqual('Welcome to use Andro...');
      style.maximumTitleLength = 2;
      expect(style.displayedTitle('abcdef')).assertEqual('...');
      expect(style.displayedTitle(undefined)).assertEqual('');
      style.maximumTitleLength = 0;
      style.reversesTitleCharacters = true;
      expect(style.displayedTitle('abc')).assertEqual('cba');
    });

    it('scalesFontsUpToTheLimit', 0, () => {
      const style = new CYLMenuStyle();
      style.adjustsFontForContentSizeCategory = true;
      const normal = style.titleFont(CYLControlState.NORMAL, 1).size;
      expect(style.titleFont(CYLControlState.NORMAL, 2).size > normal).assertTrue();
      expect(style.titleFont(CYLControlState.NORMAL, 100).size <= normal * 4).assertTrue();
      style.adjustsFontForContentSizeCategory = false;
      expect(style.titleFont(CYLControlState.NORMAL, 2).size).assertEqual(normal);
    });

    it('buildsTheNamedStyles', 0, () => {
      expect(CYLMenuStyle.gridStyle(0).numberOfItemsPerRow).assertEqual(1);
      expect(CYLMenuStyle.gridStyle(3).numberOfItemsPerRow).assertEqual(3);
      expect(CYLMenuStyle.tagCloud() !== undefined).assertTrue();
      expect(CYLMenuStyle.tagContainer() !== undefined).assertTrue();
    });
  });

  describe('CYLTagModels', () => {
    it('makesThemeColors', 0, () => {
      expect(CYLTagColors.fromTheme(CYLTagColorTheme.none, 1) === undefined).assertTrue();
      const cyan = CYLTagColors.fromTheme(CYLTagColorTheme.pureCyan, 0);
      expect(cyan !== undefined).assertTrue();
      const style = cyan?.styleByApplying(new CYLMenuStyle());
      expect(style !== undefined).assertTrue();
    });

    it('copiesTags', 0, () => {
      const tag = new CYLTag(7, 'hello', '#FF0000');
      const copy = tag.copy();
      expect(copy.identifier).assertEqual(7);
      expect(copy.title).assertEqual('hello');
      copy.title = 'changed';
      expect(tag.title).assertEqual('hello');
    });

    it('sizesAModelAndCountsRows', 0, () => {
      const model = new CYLTagModel('标签');
      model.updateSize();
      expect(model.width > 0).assertTrue();
      expect(model.height > 0).assertTrue();
      const group = new CYLTagGroup();
      group.groupName = 'G';
      expect(group.groupName).assertEqual('G');
    });

    it('aBadgeDotIsEightVpAndACapsuleKeepsTheCircleForAShortText', 0, () => {
      expect(CYLTag.badgeDotDiameter).assertEqual(BADGE_DOT_DIAMETER);
      expect(CYLTag.badgeImageTextPadding).assertEqual(BADGE_TEXT_PADDING);
      // A short text stays a circle of the diameter.
      expect(CYLTag.badgeImageWidthForText(BADGE_SHORT_TEXT_WIDTH, BADGE_DIAMETER)).assertEqual(BADGE_DIAMETER);
      // A long one widens the capsule to the text and the padding on both sides.
      expect(CYLTag.badgeImageWidthForText(BADGE_LONG_TEXT_WIDTH, BADGE_DIAMETER))
        .assertEqual(BADGE_LONG_TEXT_WIDTH + 2 * BADGE_TEXT_PADDING);
      // The text width rounds up.
      expect(CYLTag.badgeImageWidthForText(BADGE_LONG_TEXT_WIDTH + 0.2, BADGE_DIAMETER))
        .assertEqual(BADGE_LONG_TEXT_WIDTH + 1 + 2 * BADGE_TEXT_PADDING);
      // One character, a CJK one included, keeps the circle (iOS 09bc2413); two do not.
      expect(CYLTag.badgeTextKeepsCircle('1')).assertTrue();
      expect(CYLTag.badgeTextKeepsCircle('热')).assertTrue();
      expect(CYLTag.badgeTextKeepsCircle('99')).assertFalse();
    });
  });
}
