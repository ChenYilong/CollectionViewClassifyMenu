import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLColor, CYLColorKey, CYLControlState, CYLEdgeInsets, CYLFont, CYLImageIsSymbol, CYLMenuLocalizedString, CYLMenuStyle,
  CYLOffset, CYLSize, CYLTagBadgeDefaultColor, cylIconColorFilter, CYLTagButton, CYLTagButtonMetrics, CYLTagImagePlacement, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;

/**
 * CYLTagButton on its own, the one icon + title + animated icon component (iOS CYLTagButtonTests, Android
 * CYLTagButtonStandaloneTest): the icon above or below the title, the badge, the convenience constructor.
 */
export default function tagButtonTest() {
  let saved: CYLTextMeasurer = FIXED;

  describe('CYLTagButton', () => {
    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('stacksTheIconAboveOrBelowTheTitle', 0, () => {
      expect(CYLTagImagePlacement.top as number).assertEqual(2);
      expect(CYLTagImagePlacement.bottom as number).assertEqual(3);
      expect(CYLTagImagePlacement.trailing as number).assertEqual(1);
      const style = new CYLMenuStyle();
      style.imagePlacement = CYLTagImagePlacement.top;
      style.imageSize = new CYLSize(24, 24);
      style.imageTitleSpacing = 4;
      const button = new CYLTagButton('Messages', 'icon.png');
      button.style = style;
      button.setBounds(120, CYLTagButton.height(style));
      const image = button.imageView.frame;
      const title = button.titleLabel.frame;
      expect(title.y - image.maxY).assertEqual(4);
      expect(image.x + image.width / 2).assertEqual(60);
      expect(title.x + title.width / 2).assertEqual(60);
      expect(CYLTagButton.width('Messages', new CYLSize(24, 24), false, style))
        .assertEqual(80 + style.normalAppearance.contentInsets.left + style.normalAppearance.contentInsets.right);
      style.imagePlacement = CYLTagImagePlacement.bottom;
      button.style = style;
      expect(button.imageView.frame.y - button.titleLabel.frame.maxY).assertEqual(4);
    });

    it('replaysABuilderDrawnIconOnceItHasLoaded', 0, () => {
      // No player for a builder-drawn type (Rive): a play before the load is pending, and the load bumps the token that
      // CYLAnimatedItemView.animationRestartToken gets.
      const button = new CYLTagButton('Home', 'home.png');
      button.animationURL = 'asset:rive/house.riv';
      button.playAnimation();
      expect(button.pendingPlay).assertTrue();
      const before = button.playToken;
      button.itemDidLoad();
      expect(button.pendingPlay).assertFalse();
      expect(button.playToken).assertEqual(before + 1);
      button.itemDidLoad();
      expect(button.playToken).assertEqual(before + 1);
    });

    it('tintsTheAnimatedIconsStaticImageThroughTheComponent', 0, () => {
      // CYLAnimatedItemView.iconColor (CYLTabBarController PR #816): the static image under an animated icon takes the
      // state's icon color, as the tag's own static icon does; '' without a style color or without an animation.
      const style = new CYLMenuStyle();
      style.setIconColor('#FFFFFF', CYLControlState.SELECTED);
      const animated = new CYLTagButton('Home', 'home.png');
      animated.animationURL = 'asset:lottie/home.json';
      animated.style = style;
      expect(animated.animationIconColor as string).assertEqual('');
      animated.isSelected = true;
      expect(animated.animationIconColor as string).assertEqual('#FFFFFF');
      animated.isSelected = false;
      expect(animated.animationIconColor as string).assertEqual('');
      const still = new CYLTagButton('Home', 'home.png');
      still.style = style;
      still.isSelected = true;
      expect(still.animationIconColor as string).assertEqual('');
      expect(still.imageView.tintsImage).assertTrue();
      // One filter: the tag's own (CYLColor.tintFilter) is the component's, for every kind of value.
      for (const color of ['#FFFFFF', '#FF5000', '#80112233', 'FF5000', '', 'red']) {
        expect(JSON.stringify(CYLColor.tintFilter(color))).assertEqual(JSON.stringify(cylIconColorFilter(color)));
      }
    });

    it('imageFillsTheTagHeightAtTheLeadingEdge', 0, () => {
      // iOS testImageFillsTheTagHeightAtTheLeadingEdge: AndroidTagView's avatar, a circle as tall as the tag.
      const style = new CYLMenuStyle();
      style.imageSize = new CYLSize(24, 24);
      style.imageTitleSpacing = 6;
      style.imageFillsTagHeight = true;
      const side = CYLTagButton.heightForTitle('Kotlin', new CYLSize(24, 24), style);
      expect(side).assertEqual(CYLTagButton.heightForTitle('Kotlin', CYLSize.ZERO, style));
      const right = style.normalAppearance.contentInsets.right;
      expect(CYLTagButton.width('Kotlin', new CYLSize(24, 24), false, style)).assertEqual(side + 60 + 6 + right);
      const button = new CYLTagButton('Kotlin', 'avatar.png');
      button.style = style;
      button.setBounds(CYLTagButton.width('Kotlin', new CYLSize(24, 24), false, style), side);
      const image = button.imageView.frame;
      expect(image.x).assertEqual(0);
      expect(image.y).assertEqual(0);
      expect(image.width).assertEqual(side);
      expect(image.height).assertEqual(side);
      expect(button.imageView.cornerRadius).assertEqual(side / 2);
      expect(button.titleLabel.frame.x).assertEqual(side + 6);
      expect(button.titleLabel.frame.width).assertEqual(60);
      // Without an image the title keeps its usual place.
      const plain = new CYLTagButton('Kotlin');
      plain.style = style;
      expect(CYLTagButton.width('Kotlin', CYLSize.ZERO, false, style))
        .assertEqual(CYLTagButton.width('Kotlin', CYLSize.ZERO, false, new CYLMenuStyle()) + 0);
      const copy = style.copy();
      expect(copy.imageFillsTagHeight).assertTrue();
    });

    it('wrapsTitlesDrawsACrossImageAndAnElevation', 0, () => {
      // iOS 00760142 (the Android Container tab's sixth container): titleWraps, deleteIndicatorImage, elevation.
      const style = new CYLMenuStyle();
      style.titleWraps = true;
      const title = 'A long tag that wraps';
      const single = CYLTagButton.heightForTitle(title, CYLSize.ZERO, style);
      const insets = style.normalAppearance.contentInsets;
      // 21 characters at 10 vp each (210 vp) in a tag 120 vp wide wrap onto three lines.
      const room = 120 - insets.left - insets.right;
      const lines = Math.ceil(210 / room);
      const wrapped = CYLTagButtonMetrics.heightForTitleWidth(title, CYLSize.ZERO, 120, false, style);
      expect(lines > 1).assertTrue();
      expect(wrapped > single).assertTrue();
      style.titleWraps = false;
      expect(CYLTagButtonMetrics.heightForTitleWidth(title, CYLSize.ZERO, 120, false, style)).assertEqual(single);
      // A cross image: a square as tall as a line of the indicator font, the padding only beside it, so a one-line tag
      // keeps the image (it vanished on iOS when the padding was taken above it too).
      const crossed = new CYLMenuStyle();
      crossed.deleteIndicatorPadding = 4;
      crossed.deleteIndicatorImage = 'cross.png';
      const button = new CYLTagButton('End');
      button.style = crossed;
      button.showsDeleteIndicator = true;
      button.setBounds(120, CYLTagButton.height(crossed));
      const frame = button.deleteIndicatorImageFrame;
      expect(frame.width > 0 && frame.width === frame.height).assertTrue();
      expect(button.deleteIndicatorImage).assertEqual('cross.png');
      expect(button.showsCross).assertFalse();
      expect(button.deleteIndicatorLabel.text === undefined).assertTrue();
      // Elevation: on the button, and copied with the style.
      crossed.elevation = 4;
      button.style = crossed;
      expect(button.elevation).assertEqual(4);
      const copy = crossed.copy();
      expect(copy.elevation).assertEqual(4);
      expect(copy.deleteIndicatorImage).assertEqual('cross.png');
      expect(style.copy().titleWraps).assertFalse();
    });

    it('reservesNoSpacingForAMissingPart', 0, () => {
      const style = new CYLMenuStyle();
      style.imagePlacement = CYLTagImagePlacement.top;
      expect(CYLTagButton.heightForTitle('Home', CYLSize.ZERO, style))
        .assertEqual(CYLTagButton.heightForTitle('Home', CYLSize.ZERO, new CYLMenuStyle()));
      const iconOnly = new CYLTagButton(undefined, 'icon.png');
      const insets = iconOnly.style.normalAppearance.contentInsets;
      expect(iconOnly.intrinsicSize().width).assertEqual(iconOnly.style.imageSize.width + insets.left + insets.right);
    });

    it('drawsABadgeAtTheIconsCorner', 0, () => {
      const button = new CYLTagButton('Messages', 'icon.png');
      button.setBounds(120, 40);
      expect(button.badgeValue === undefined).assertTrue();
      expect(button.badgeLabel.isHidden).assertTrue();
      expect(button.badgeColor).assertEqual(CYLTagBadgeDefaultColor);
      expect(button.accessibilityValue === undefined).assertTrue();
      button.badgeValue = '';
      expect(button.badgeLabel.isHidden).assertFalse();
      expect(button.badgeLabel.frame.width).assertEqual(8);
      expect(button.badgeLabel.frame.x + 4).assertEqual(button.imageView.frame.maxX);
      expect(button.badgeLabel.frame.y + 4).assertEqual(button.imageView.frame.y);
      expect(button.accessibilityValue).assertEqual(CYLMenuLocalizedString('CYLTagBadgeDot'));
      button.badgeValue = '99+';
      button.badgeColor = '#0000FF';
      expect(button.badgeLabel.text).assertEqual('99+');
      expect(button.badgeLabel.tintColor).assertEqual('#0000FF');
      expect(button.badgeLabel.frame.width > button.badgeLabel.frame.height).assertTrue();
      expect(button.badgeLabel.frame.maxX <= 120).assertTrue();
      expect(button.accessibilityValue).assertEqual('99+');
      expect(button.accessibilityLabel).assertEqual('Messages');
      button.badgeColor = undefined;
      expect(button.badgeColor).assertEqual(CYLTagBadgeDefaultColor);
    });

    it('drawsSystemSymbolsAndTakesThemeColors', 0, () => {
      const symbol = $r('sys.symbol.camera');
      expect(CYLImageIsSymbol(symbol)).assertTrue();
      expect(CYLImageIsSymbol('icon.png')).assertFalse();
      // A rawfile that exists ($rawfile is resolved at compile time; 'icon.png' did not exist and broke the test build).
      expect(CYLImageIsSymbol($rawfile('img_tab_home_0.png'))).assertFalse();
      expect(CYLImageIsSymbol(undefined)).assertFalse();
      const tint = $r('sys.color.font_primary');
      const style = new CYLMenuStyle();
      style.imageSize = new CYLSize(20, 20);
      [CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED].forEach((state: number) => {
        const appearance = style.appearance(state);
        appearance.textColor = tint;
        appearance.backgroundColor = Color.Transparent;
        appearance.borderColor = undefined;
        style.setIconColor(tint, state);
      });
      const button = new CYLTagButton(undefined, symbol);
      button.style = style;
      button.setBounds(36, 36);
      expect(button.imageView.image === symbol).assertTrue();
      expect(CYLColorKey(button.imageView.tintColor)).assertEqual(CYLColorKey(tint));
      expect(button.backgroundColor === Color.Transparent).assertTrue();
      expect(button.borderWidth).assertEqual(0);
      button.badgeColor = $r('sys.color.warning');
      expect(CYLColorKey(button.badgeColor)).assertEqual(CYLColorKey($r('sys.color.warning')));
    });

    it('growsToItsMinimumSizeAndCentersTheIcon', 0, () => {
      const style = new CYLMenuStyle();
      style.imageSize = new CYLSize(20, 20);
      style.itemHeight = 0;
      [CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED].forEach((state: number) => {
        style.appearance(state).contentInsets = new CYLEdgeInsets(0, 0, 0, 0);
      });
      const button = new CYLTagButton(undefined, 'icon.png');
      button.style = style;
      expect(button.intrinsicSize().width).assertEqual(20);
      button.minimumSize = new CYLSize(36, 36);
      expect(button.intrinsicSize().width).assertEqual(36);
      expect(button.intrinsicSize().height).assertEqual(36);
      button.setBounds(36, 36);
      expect(button.imageView.frame.x).assertEqual(8);
      expect(button.imageView.frame.y).assertEqual(8);
    });

    it('takesTheBadgeMetrics', 0, () => {
      const button = new CYLTagButton('Messages', 'icon.png');
      button.setBounds(120, 40);
      button.badgeValue = '1';
      button.badgeMinimumSize = new CYLSize(20, 20);
      expect(button.badgeLabel.frame.height).assertEqual(20);
      expect(button.badgeLabel.frame.width).assertEqual(20);
      const x = button.badgeLabel.frame.x;
      button.badgePositionAdjustment = new CYLOffset(-3, 0);
      expect(button.badgeLabel.frame.x).assertEqual(x - 3);
      button.badgeContentInsets = new CYLEdgeInsets(0, 12, 0, 12);
      expect(button.badgeLabel.frame.width).assertEqual(10 + 24);
      button.badgeTextColor = '#FF000000';
      expect(button.badgeLabel.textColor).assertEqual('#FF000000');
      button.badgeFont = CYLFont.systemFont(9);
      expect(button.badgeLabel.font.size).assertEqual(9);
    });
  });
}
