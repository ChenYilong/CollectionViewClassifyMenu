import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import { CYLLiquidGlass } from 'cylanimateditem';
import {
  CYLColor, CYLControlState, CYLFont, CYLIconContrast, CYLHSL, CYLMenuRelativeLuminance, CYLMenuStyle, CYLRGBA,
  CYLTagBackgroundStyle, CYLTagButton, CYLTagButtonMetrics, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const BUTTON_HEIGHT: number = 44;
const BUTTON_WIDTH: number = 120;
const TITLE: string = 'Tag';
const ACCURACY: number = 0.002;
const HUE_ACCURACY: number = 0.01;
const PASSING: number = 2.99;
const TEAL: string = '#FF30B0C7';
const RED: string = '#FFFF3B30';
const BLUE: string = '#FF007AFF';
const DARK_TEAL: string = '#FF004040';
const TAG_DARK_TEAL: string = '#FF004D4D';
const BRIGHT: string = '#FF99E6FF';
const TINT: string = '#CC3399FF';
const TINT_ALPHA: number = 0.8;
const TINT_RED: number = 0.2;
const TINT_GREEN: number = 0.6;
const TINT_SHARE: number = 0.6;
const GRAY_24: number = 36 / 255;
const LIFT_MARGIN: number = 0.05;

function rgbaOf(color: ResourceColor): CYLRGBA {
  const rgba = CYLIconContrast.components(color);
  return rgba === undefined ? new CYLRGBA(0, 0, 0, 0) : rgba;
}

function hueOf(color: ResourceColor): number {
  const c = rgbaOf(color);
  return CYLIconContrast.hslFromRGB(c.red, c.green, c.blue).hue;
}

function lightnessOf(color: ResourceColor): number {
  const c = rgbaOf(color);
  return CYLIconContrast.hslFromRGB(c.red, c.green, c.blue).lightness;
}

function contrastOf(color: ResourceColor, glassTint: ResourceColor | undefined = undefined,
  tintAlpha: number | undefined = undefined): number {
  const c = rgbaOf(color);
  return CYLIconContrast.contrastRatio(CYLMenuRelativeLuminance(c.red, c.green, c.blue),
    CYLIconContrast.glassReferenceLuminance(glassTint, tintAlpha));
}

function lift(color: ResourceColor): ResourceColor {
  return CYLIconContrast.liftedIconColor(color, undefined, undefined);
}

function buttonWith(glass: boolean, icon: ResourceColor | undefined): CYLTagButton {
  const style = new CYLMenuStyle();
  style.backgroundStyle = glass ? CYLTagBackgroundStyle.liquidGlass : CYLTagBackgroundStyle.flat;
  if (icon !== undefined) {
    style.setIconColor(icon, CYLControlState.NORMAL);
  }
  const button = new CYLTagButton(TITLE);
  button.style = style;
  button.setBounds(BUTTON_WIDTH, BUTTON_HEIGHT);
  return button;
}

/**
 * The dark Liquid Glass icon lift (iOS `CYLIconContrastTests`): an explicit static icon color too dark for dark glass is
 * lifted to 3:1 with its hue kept; everything else is unchanged.
 */
export default function iconContrastTest() {
  let savedMeasurer: CYLTextMeasurer = FIXED;
  let savedGlass: boolean | undefined = undefined;
  let savedDark: boolean | undefined = undefined;

  describe('CYLIconContrast', () => {
    beforeEach(() => {
      savedMeasurer = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
      savedGlass = CYLLiquidGlass.activeOverride;
      CYLLiquidGlass.activeOverride = true;
      savedDark = CYLTagButton.darkModeOverride;
      CYLTagButton.darkModeOverride = true;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = savedMeasurer;
      CYLLiquidGlass.activeOverride = savedGlass;
      CYLTagButton.darkModeOverride = savedDark;
    });

    it('theConstants', 0, () => {
      expect(CYLIconContrast.minimumContrastRatio).assertEqual(3);
      expect(CYLIconContrast.frostedGlassWhiteAlpha).assertEqual(0.14);
      expect(CYLIconContrast.defaultGlassTintShare).assertEqual(0.75);
      expect(CYLIconContrast.lightnessStep).assertEqual(0.005);
      // White at 0.14 over black is about #242424.
      const reference = CYLIconContrast.glassReferenceLuminance(undefined, undefined);
      expect(Math.abs(reference - CYLMenuRelativeLuminance(GRAY_24, GRAY_24, GRAY_24)) < ACCURACY).assertTrue();
      // Alpha 0 is the frosted default.
      expect(CYLIconContrast.glassReferenceLuminance(CYLColor.CLEAR, undefined)).assertEqual(reference);
    });

    it('staticTealRedAndBlueReach3To1WithTheirHue', 0, () => {
      const colors: string[] = [TEAL, RED, BLUE];
      for (const icon of colors) {
        const lifted = lift(icon);
        expect(contrastOf(lifted) >= PASSING).assertTrue();
        expect(Math.abs(hueOf(lifted) - hueOf(icon)) < HUE_ACCURACY).assertTrue();
        expect(lightnessOf(lifted) <= 1).assertTrue();
      }
    });

    it('aDarkStaticColorIsLiftedAndNeverAboveWhite', 0, () => {
      const lifted = lift(DARK_TEAL);
      expect(contrastOf(DARK_TEAL) < CYLIconContrast.minimumContrastRatio).assertTrue();
      expect(contrastOf(lifted) >= PASSING).assertTrue();
      expect(Math.abs(hueOf(lifted) - hueOf(DARK_TEAL)) < HUE_ACCURACY).assertTrue();
      // Black cannot keep a hue: it is lifted to a gray, capped at white.
      const black = lift(CYLColor.BLACK);
      expect(contrastOf(black) >= PASSING).assertTrue();
      expect(rgbaOf(black).red <= 1).assertTrue();
      // The alpha is kept.
      expect(rgbaOf(lift('#80004040')).alpha > 0.5 && rgbaOf(lift('#80004040')).alpha < 0.51).assertTrue();
    });

    it('anExplicitGlassTintIsTheReferenceTimesTheAlphaRule', 0, () => {
      const lifted = CYLIconContrast.liftedIconColor(BLUE, TINT, undefined);
      expect(contrastOf(lifted, TINT, undefined) >= PASSING).assertTrue();
      // The selected tag tints at alpha 1: a brighter reference, so the lift is at least as strong.
      const selected = CYLIconContrast.liftedIconColor(BLUE, TINT, 1);
      expect(contrastOf(selected, TINT, 1) >= PASSING).assertTrue();
      // The reference is the tint's color times its alpha times the default share (0.8 x 0.75 = 0.6).
      const expected = CYLMenuRelativeLuminance(TINT_RED * TINT_SHARE, TINT_GREEN * TINT_SHARE, TINT_SHARE);
      expect(TINT_ALPHA * CYLIconContrast.defaultGlassTintShare).assertEqual(TINT_SHARE);
      expect(Math.abs(CYLIconContrast.glassReferenceLuminance(TINT, undefined) - expected) < ACCURACY / 2).assertTrue();
    });

    it('unchangedCases', 0, () => {
      // Already passing: returned as the same color.
      expect(lift(CYLColor.WHITE)).assertEqual(CYLColor.WHITE);
      expect(contrastOf(BRIGHT) >= CYLIconContrast.minimumContrastRatio).assertTrue();
      expect(lift(BRIGHT)).assertEqual(BRIGHT);
      // Dynamic colors (a theme resource, a Color constant) are not static: unchanged.
      const resource: ResourceColor = $r('sys.color.font_primary');
      expect(CYLIconContrast.liftedIconColor(resource, undefined, undefined) === resource).assertTrue();
      expect(CYLIconContrast.liftedIconColor(Color.Black, undefined, undefined) === Color.Black).assertTrue();
      expect(CYLIconContrast.components(resource) === undefined).assertTrue();
    });

    it('thePureFunctionGivesTheSameOutputForTheSameInput', 0, () => {
      const first = lift(TEAL);
      CYLTagButton.darkModeOverride = false;
      const second = lift(TEAL);
      expect(first).assertEqual(second);
      const hsl: CYLHSL = CYLIconContrast.hslFromRGB(0.2, 0.4, 0.6);
      const back: CYLRGBA = CYLIconContrast.rgbFromHSL(hsl.hue, hsl.saturation, hsl.lightness);
      expect(Math.abs(back.red - 0.2) < ACCURACY / 2 && Math.abs(back.green - 0.4) < ACCURACY / 2 &&
        Math.abs(back.blue - 0.6) < ACCURACY / 2).assertTrue();
    });

    it('aDarkGlassTagLiftsAnExplicitDarkIconAndFlatLightOrBuiltInDoNot', 0, () => {
      const glass = buttonWith(true, TAG_DARK_TEAL);
      const lifted = glass.imageView.tintColor;
      expect(lifted === TAG_DARK_TEAL).assertFalse();
      expect(lightnessOf(lifted) > lightnessOf(TAG_DARK_TEAL) + LIFT_MARGIN).assertTrue();
      expect(Math.abs(hueOf(lifted) - hueOf(TAG_DARK_TEAL)) < HUE_ACCURACY).assertTrue();
      expect(glass.imageView.tintsImage).assertTrue();
      // Flat: as set.
      expect(buttonWith(false, TAG_DARK_TEAL).imageView.tintColor).assertEqual(TAG_DARK_TEAL);
      // Glass where the system draws none: flat, as set.
      CYLLiquidGlass.activeOverride = false;
      expect(buttonWith(true, TAG_DARK_TEAL).imageView.tintColor).assertEqual(TAG_DARK_TEAL);
      CYLLiquidGlass.activeOverride = true;
      // Light mode: as set.
      CYLTagButton.darkModeOverride = false;
      expect(buttonWith(true, TAG_DARK_TEAL).imageView.tintColor).assertEqual(TAG_DARK_TEAL);
      CYLTagButton.darkModeOverride = true;
      // No explicit icon color: the built-in follows the text color, untouched, and bitmaps keep their own colors.
      const style = new CYLMenuStyle();
      style.backgroundStyle = CYLTagBackgroundStyle.liquidGlass;
      expect(style.explicitIconColor(CYLControlState.NORMAL) === undefined).assertTrue();
      const builtIn = buttonWith(true, undefined);
      expect(builtIn.imageView.tintColor === style.iconColor(CYLControlState.NORMAL)).assertTrue();
      expect(builtIn.imageView.tintsImage).assertFalse();
    });
  });
}
