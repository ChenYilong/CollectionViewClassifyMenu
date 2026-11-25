import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import { CYLAnimatedItemBackgroundModifier, CYLAnimatedItemBackgroundStyle, CYLLiquidGlass } from 'cylanimateditem';
import {
  CYLColor, CYLColorKey, CYLFont, CYLMenuStyle, CYLTagAppearance, CYLTagBackgroundStyle, CYLTagButton,
  CYLTagButtonMetrics, CYLTagListState, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const RED: string = '#FFFF0000';
const BLUE: string = '#FF0000FF';
const BUTTON_HEIGHT: number = 44;
const BUTTON_WIDTH: number = 120;
const TITLE: string = 'Tag';

function glassStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  style.backgroundStyle = CYLTagBackgroundStyle.liquidGlass;
  return style;
}

function buttonWith(style: CYLMenuStyle): CYLTagButton {
  const button = new CYLTagButton(TITLE);
  button.style = style;
  button.setBounds(BUTTON_WIDTH, BUTTON_HEIGHT);
  return button;
}

function configured(styleJson: string): CYLMenuStyle {
  return CYLTagListState.withConfiguration(
    JSON.parse(`{"style":${styleJson},"sections":[{"items":["a"]}]}`) as Record<string, Object>).style;
}

/**
 * Under Liquid Glass an unset tag background is ignored (owner rule, as iOS `CYLTagButton`): only an explicit color tints the
 * glass, otherwise the glass keeps its frosted default tint. Flat tags and glass where the system draws none are unchanged.
 */
export default function tagGlassBackgroundTest() {
  let savedMeasurer: CYLTextMeasurer = FIXED;
  let savedOverride: boolean | undefined = undefined;

  describe('CYLTagGlassBackground', () => {
    beforeEach(() => {
      savedMeasurer = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
      savedOverride = CYLLiquidGlass.activeOverride;
      CYLLiquidGlass.activeOverride = true;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = savedMeasurer;
      CYLLiquidGlass.activeOverride = savedOverride;
    });

    it('anAppearanceTellsAnExplicitBackgroundFromTheBuiltInDefault', 0, () => {
      const appearance = new CYLTagAppearance();
      expect(appearance.explicitBackgroundColor === undefined).assertTrue();
      expect(appearance.isBackgroundColorSet).assertFalse();
      // The effective color still reads the built-in default.
      expect(appearance.backgroundColor).assertEqual(CYLTagAppearance.defaultBackgroundColor);
      appearance.backgroundColor = RED;
      expect(appearance.explicitBackgroundColor).assertEqual(RED);
      expect(appearance.isBackgroundColorSet).assertTrue();
      expect(appearance.copy().explicitBackgroundColor).assertEqual(RED);
      appearance.resetBackgroundColor();
      expect(appearance.explicitBackgroundColor === undefined).assertTrue();
      appearance.backgroundColor = RED;
      appearance.reset();
      expect(appearance.isBackgroundColorSet).assertFalse();
      // A copy of an untouched appearance stays untouched.
      expect(new CYLTagAppearance().copy().isBackgroundColorSet).assertFalse();
    });

    it('theStyleAndTheConfigurationNeverStoreTheDefaultAsAnExplicitColor', 0, () => {
      const style = new CYLMenuStyle();
      expect(style.normalAppearance.isBackgroundColorSet).assertFalse();
      expect(style.disabledAppearance.isBackgroundColorSet).assertFalse();
      // The selected tag's tint is a color the style sets: explicit.
      expect(style.selectedAppearance.explicitBackgroundColor).assertEqual(CYLColor.APP_TINT);
      expect(style.copy().normalAppearance.isBackgroundColorSet).assertFalse();
      // A configuration without a background key leaves it unset; a key that is not a color resets it; a color sets it.
      expect(configured('{}').normalAppearance.isBackgroundColorSet).assertFalse();
      expect(configured('{"normal":{"textColor":"#112233"}}').normalAppearance.isBackgroundColorSet).assertFalse();
      expect(configured('{"normal":{"backgroundColor":5}}').normalAppearance.isBackgroundColorSet).assertFalse();
      expect(configured('{"normal":{"backgroundColor":"#112233"}}').normalAppearance.explicitBackgroundColor)
        .assertEqual('#FF112233');
      const reset = new CYLMenuStyle();
      reset.normalAppearance.backgroundColor = RED;
      expect(reset.normalAppearance.isBackgroundColorSet).assertTrue();
    });

    it('glassWithAnUnsetNormalBackgroundHandsNoColor', 0, () => {
      const button = buttonWith(glassStyle());
      expect(button.itemBackgroundStyle).assertEqual(CYLAnimatedItemBackgroundStyle.liquidGlass);
      expect(button.backgroundColor).assertEqual(CYLTagButton.GLASS_DEFAULT_TINT);
      // "No color" is the modifier's frosted default, whatever the mode.
      expect(CYLAnimatedItemBackgroundModifier.glassTint(button.backgroundColor))
        .assertEqual(CYLAnimatedItemBackgroundModifier.DEFAULT_GLASS_TINT);
      // The disabled state has no background either.
      button.isEnabled = false;
      expect(button.backgroundColor).assertEqual(CYLTagButton.GLASS_DEFAULT_TINT);
    });

    it('glassWithAnExplicitBackgroundHandsItAndTheAlphaRuleIsTheModifiers', 0, () => {
      const style = glassStyle();
      style.normalAppearance.backgroundColor = RED;
      const button = buttonWith(style);
      expect(button.itemBackgroundStyle).assertEqual(CYLAnimatedItemBackgroundStyle.liquidGlass);
      expect(button.backgroundColor).assertEqual(RED);
      // Unchanged: the modifier turns the explicit color translucent (alpha x 0.75), it is not the frosted default.
      const tint = CYLAnimatedItemBackgroundModifier.glassTint(button.backgroundColor);
      expect(tint === RED).assertFalse();
      expect(tint === CYLAnimatedItemBackgroundModifier.DEFAULT_GLASS_TINT).assertFalse();
    });

    it('aClearedBackgroundMeansUnsetUnderGlass', 0, () => {
      const style = glassStyle();
      style.normalAppearance.backgroundColor = CYLColor.CLEAR;
      expect(buttonWith(style).backgroundColor).assertEqual(CYLTagButton.GLASS_DEFAULT_TINT);
      expect(CYLTagButton.glassTintColor(undefined)).assertEqual(CYLTagButton.GLASS_DEFAULT_TINT);
      expect(CYLTagButton.glassTintColor(RED)).assertEqual(RED);
    });

    it('theSelectedTagKeepsItsExplicitTintAtFullAlpha', 0, () => {
      const button = buttonWith(glassStyle());
      button.isSelected = true;
      expect(button.backgroundColor).assertEqual(CYLColor.APP_TINT);
      expect(button.glassTintAlpha).assertEqual(1);
      button.isSelected = false;
      expect(button.backgroundColor).assertEqual(CYLTagButton.GLASS_DEFAULT_TINT);
      // A selected state whose color the app reset has no color to hand either.
      const reset = glassStyle();
      reset.selectedAppearance.resetBackgroundColor();
      const resetButton = buttonWith(reset);
      resetButton.isSelected = true;
      expect(resetButton.backgroundColor).assertEqual(CYLTagButton.GLASS_DEFAULT_TINT);
    });

    it('thePressedColorIsExplicitUnderGlass', 0, () => {
      const style = glassStyle();
      style.highlightedBackgroundColor = BLUE;
      const button = buttonWith(style);
      expect(button.backgroundColor).assertEqual(CYLTagButton.GLASS_DEFAULT_TINT);
      button.isHighlighted = true;
      expect(button.backgroundColor).assertEqual(BLUE);
      button.isHighlighted = false;
      expect(button.backgroundColor).assertEqual(CYLTagButton.GLASS_DEFAULT_TINT);
    });

    it('flatTagsKeepTheEffectiveBackground', 0, () => {
      const button = buttonWith(new CYLMenuStyle());
      expect(button.itemBackgroundStyle).assertEqual(CYLAnimatedItemBackgroundStyle.flat);
      expect(CYLColorKey(button.backgroundColor)).assertEqual(CYLColorKey(CYLTagAppearance.defaultBackgroundColor));
      button.isSelected = true;
      expect(button.backgroundColor).assertEqual(CYLColor.APP_TINT);
      const explicit = new CYLMenuStyle();
      explicit.normalAppearance.backgroundColor = RED;
      expect(buttonWith(explicit).backgroundColor).assertEqual(RED);
    });

    it('glassWhereTheSystemDrawsNoneIsUnchanged', 0, () => {
      CYLLiquidGlass.activeOverride = false;
      const button = buttonWith(glassStyle());
      expect(button.itemBackgroundStyle).assertEqual(CYLAnimatedItemBackgroundStyle.flat);
      expect(CYLColorKey(button.backgroundColor)).assertEqual(CYLColorKey(CYLTagAppearance.defaultBackgroundColor));
      expect(button.itemBackgroundStyle === CYLAnimatedItemBackgroundStyle.liquidGlass).assertFalse();
    });
  });
}
