import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import { CYLLiquidGlass } from 'cylanimateditem';
import {
  CYLControlState, CYLFont, CYLMenuStyle, CYLTagBackgroundStyle, CYLTagButton, CYLTagButtonMetrics, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const BUTTON_HEIGHT: number = 44;
const BUTTON_WIDTH: number = 120;
/** An icon color far too dark for dark glass: the item (not the tag) adapts it. */
const DARK_TEAL: string = '#FF004D4D';

/**
 * The tag does not adapt the icon color to dark Liquid Glass: it hands the item the style's icon color unchanged (the
 * adaptation is `cylanimateditem`'s, `CYLAnimatedItemContrast`).
 */
export default function tagIconColorTest() {
  let savedMeasurer: CYLTextMeasurer = FIXED;
  let savedGlass: boolean | undefined = undefined;

  describe('CYLTagIconColor', () => {
    beforeEach(() => {
      savedMeasurer = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
      savedGlass = CYLLiquidGlass.activeOverride;
      CYLLiquidGlass.activeOverride = true;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = savedMeasurer;
      CYLLiquidGlass.activeOverride = savedGlass;
    });

    it('aGlassTagHandsTheItemTheStylesIconColorUnchanged', 0, () => {
      const style = new CYLMenuStyle();
      style.backgroundStyle = CYLTagBackgroundStyle.liquidGlass;
      style.setIconColor(DARK_TEAL, CYLControlState.NORMAL);
      const button = new CYLTagButton('Tag');
      button.style = style;
      button.setBounds(BUTTON_WIDTH, BUTTON_HEIGHT);
      expect(button.imageView.tintColor).assertEqual(DARK_TEAL);
      expect(button.imageView.tintsImage).assertTrue();
    });
  });
}
