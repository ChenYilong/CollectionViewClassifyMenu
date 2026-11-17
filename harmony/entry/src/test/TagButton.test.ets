import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLFont, CYLMenuLocalizedString, CYLMenuStyle, CYLSize, CYLTagBadgeDefaultColor, CYLTagButton, CYLTagButtonMetrics,
  CYLTagImagePlacement, CYLTextMeasurer
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
  });
}
