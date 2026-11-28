import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import { CYLAnimatedItemBackgroundStyle, CYLAnimatedItemContrast, CYLAnimatedItemContrastKindIcon, CYLAnimatedItemContrastKindText, CYLLiquidGlass } from 'cylanimateditem';
import {
  CYLControlState, CYLFont, CYLMenuStyle, CYLTagBackgroundStyle, CYLTagButton, CYLTagButtonMetrics, CYLTextMeasurer, cylTagAnimationImage
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const BUTTON_HEIGHT: number = 44;
const BUTTON_WIDTH: number = 120;
const COLOR_MODE_KEY: string = 'cyl_colorMode';
const MODE_DARK: string = 'dark';
const MODE_LIGHT: string = 'light';
const MINIMUM_TEXT_CONTRAST: number = 4.5;
const MINIMUM_ICON_CONTRAST: number = 3;
const DARK_TEAL: string = '#FF004D4D';
const DARK_TEXT: string = '#FF3C3C43';
const ANIMATION_FILE: string = 'asset:rawfile/icon.json';

function buttonWith(style: CYLMenuStyle): CYLTagButton {
  const button = new CYLTagButton('Tag');
  button.style = style;
  button.setBounds(BUTTON_WIDTH, BUTTON_HEIGHT);
  return button;
}

function glassStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  style.backgroundStyle = CYLTagBackgroundStyle.liquidGlass;
  return style;
}

function setMode(mode: string): void {
  AppStorage.setOrCreate<string>(COLOR_MODE_KEY, mode);
}

/** The WCAG contrast of `color` over the default frosted dark glass (no explicit tint, default tint alpha); 0 for a non-static colour. */
function contrastOnGlass(color: ResourceColor, tint: ResourceColor | undefined, alpha: number): number {
  const rgba = CYLAnimatedItemContrast.components(color);
  if (rgba === undefined) {
    return 0;
  }
  const glass = CYLAnimatedItemContrast.glassReferenceLuminance(tint, alpha);
  return CYLAnimatedItemContrast.contrastRatio(CYLAnimatedItemContrast.relativeLuminance(rgba.red, rgba.green, rgba.blue), glass);
}

/**
 * Every icon and text a tag draws on drawn dark Liquid Glass is as readable as the title: the animated icon's colour channels, the
 * delete cross / label / symbol, the editing icons and the inline fold cell's rule (`CYLTagButton.adaptedOnGlassOf`). Flat, light and
 * disabled built-in colours stay as they are. The animated icon's inner item stays flat (it would draw a second glass), so the tag
 * lifts the channels it hands over.
 */
export default function tagGlassIconCoverageTest() {
  let savedMeasurer: CYLTextMeasurer = FIXED;
  let savedGlass: boolean | undefined = undefined;
  let savedMode: string | undefined = undefined;

  describe('CYLTagGlassIconCoverage', () => {
    beforeEach(() => {
      savedMeasurer = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
      savedGlass = CYLLiquidGlass.activeOverride;
      CYLLiquidGlass.activeOverride = true;
      savedMode = AppStorage.get<string>(COLOR_MODE_KEY);
      setMode(MODE_DARK);
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = savedMeasurer;
      CYLLiquidGlass.activeOverride = savedGlass;
      setMode(savedMode ?? '');
    });

    it('darkGlassLiftsTheAnimatedIconsExplicitColorHandedToTheItem', 0, () => {
      const style = glassStyle();
      style.setIconColor(DARK_TEAL, CYLControlState.NORMAL);
      const button = new CYLTagButton('Tag', undefined, ANIMATION_FILE);
      button.style = style;
      button.setBounds(BUTTON_WIDTH, BUTTON_HEIGHT);
      expect(button.animationIconColor).assertEqual(DARK_TEAL);
      const handed = button.resolvedAnimationIconColor();
      expect(handed === DARK_TEAL).assertFalse();
      expect(contrastOnGlass(handed, button.glassTint, button.glassTintAlpha) >= MINIMUM_ICON_CONTRAST).assertTrue();
    });

    it('anAnimatedIconWithoutAnExplicitColorHandsNothingAndItsBuiltInChannelStaysDynamic', 0, () => {
      const button = new CYLTagButton('Tag', undefined, ANIMATION_FILE);
      button.style = glassStyle();
      button.setBounds(BUTTON_WIDTH, BUTTON_HEIGHT);
      expect(button.resolvedAnimationIconColor()).assertEqual('');
      // The default text colour is a theme resource: never adapted.
      expect(button.resolvedAnimationBuiltInIconColor()).assertEqual(button.builtInIconColor);
    });

    it('theAnimatedIconsStaticBuiltInColorIsLiftedOnDarkGlass', 0, () => {
      const style = glassStyle();
      style.normalAppearance.textColor = DARK_TEXT;
      const button = new CYLTagButton('Tag', undefined, ANIMATION_FILE);
      button.style = style;
      button.setBounds(BUTTON_WIDTH, BUTTON_HEIGHT);
      expect(contrastOnGlass(button.resolvedAnimationBuiltInIconColor(), button.glassTint, button.glassTintAlpha) >=
        MINIMUM_ICON_CONTRAST).assertTrue();
    });

    it('flatLightAndDisabledAnimatedIconColorsAreUnchanged', 0, () => {
      const flat = new CYLMenuStyle();
      flat.setIconColor(DARK_TEAL, CYLControlState.NORMAL);
      const flatButton = new CYLTagButton('Tag', undefined, ANIMATION_FILE);
      flatButton.style = flat;
      expect(flatButton.resolvedAnimationIconColor()).assertEqual(DARK_TEAL);
      const light = glassStyle();
      light.setIconColor(DARK_TEAL, CYLControlState.NORMAL);
      setMode(MODE_LIGHT);
      const lightButton = new CYLTagButton('Tag', undefined, ANIMATION_FILE);
      lightButton.style = light;
      expect(lightButton.resolvedAnimationIconColor()).assertEqual(DARK_TEAL);
      setMode(MODE_DARK);
      const disabledStyle = glassStyle();
      disabledStyle.normalAppearance.textColor = DARK_TEXT;
      disabledStyle.disabledAppearance.textColor = DARK_TEXT;
      const disabled = new CYLTagButton('Tag', undefined, ANIMATION_FILE);
      disabled.style = disabledStyle;
      disabled.isEnabled = false;
      // A disabled tag's built-in colour keeps the disabled look.
      expect(disabled.resolvedAnimationBuiltInIconColor()).assertEqual(disabled.builtInIconColor);
    });

    it('darkGlassLiftsAnExplicitDeleteCrossLabelAndSymbolColor', 0, () => {
      const style = glassStyle();
      style.deleteIndicatorColor = DARK_TEAL;
      style.deleteIndicatorLineWidth = 1;
      const button = buttonWith(style);
      button.showsDeleteIndicator = true;
      expect(button.crossColor).assertEqual(DARK_TEAL);
      const cross = button.resolvedCrossColor();
      expect(cross === DARK_TEAL).assertFalse();
      expect(contrastOnGlass(cross, button.glassTint, button.glassTintAlpha) >= MINIMUM_ICON_CONTRAST).assertTrue();
      const symbol = button.resolvedDeleteSymbolColor();
      expect(contrastOnGlass(symbol, button.glassTint, button.glassTintAlpha) >= MINIMUM_ICON_CONTRAST).assertTrue();
      const label = button.resolvedDeleteLabelColor();
      expect(contrastOnGlass(label, button.glassTint, button.glassTintAlpha) >= MINIMUM_TEXT_CONTRAST).assertTrue();
    });

    it('theDeleteIndicatorFollowingAnExplicitTitleColorIsLiftedWithIt', 0, () => {
      const style = glassStyle();
      style.normalAppearance.textColor = DARK_TEXT;
      const button = buttonWith(style);
      button.showsDeleteIndicator = true;
      expect(button.indicatorColorIsExplicit).assertTrue();
      expect(contrastOnGlass(button.resolvedDeleteLabelColor(), button.glassTint, button.glassTintAlpha) >=
        MINIMUM_TEXT_CONTRAST).assertTrue();
    });

    it('theEditingIconsGetTheLiftedStaticColor', 0, () => {
      const style = glassStyle();
      style.deleteIndicatorColor = DARK_TEAL;
      const button = buttonWith(style);
      button.showsDeleteIndicator = true;
      button.showsRenameIndicator = true;
      expect(button.editingIconColor).assertEqual(DARK_TEAL);
      const lifted = button.resolvedEditingIconColor();
      expect(lifted === DARK_TEAL).assertFalse();
      expect(button.editingIndicatorsView.iconColor).assertEqual(lifted);
    });

    it('flatLightAndBuiltInIndicatorColorsAreUnchanged', 0, () => {
      const flat = new CYLMenuStyle();
      flat.deleteIndicatorColor = DARK_TEAL;
      flat.deleteIndicatorLineWidth = 1;
      const flatButton = buttonWith(flat);
      flatButton.showsDeleteIndicator = true;
      expect(flatButton.resolvedCrossColor()).assertEqual(DARK_TEAL);
      expect(flatButton.resolvedDeleteLabelColor()).assertEqual(DARK_TEAL);
      const light = glassStyle();
      light.deleteIndicatorColor = DARK_TEAL;
      setMode(MODE_LIGHT);
      const lightButton = buttonWith(light);
      lightButton.showsDeleteIndicator = true;
      expect(lightButton.resolvedCrossColor()).assertEqual(DARK_TEAL);
      setMode(MODE_DARK);
      // Unset indicator colour: the theme's default text colour, a resource, is never changed.
      const unset = buttonWith(glassStyle());
      unset.showsDeleteIndicator = true;
      expect(unset.indicatorColorIsExplicit).assertFalse();
      expect(unset.resolvedCrossColor()).assertEqual(unset.crossColor);
    });

    it('theInlineFoldCellRuleLiftsOnDrawnDarkGlassOnly', 0, () => {
      const glass = CYLAnimatedItemBackgroundStyle.liquidGlass;
      const flat = CYLAnimatedItemBackgroundStyle.flat;
      const textLifted = CYLTagButton.adaptedOnGlassOf(DARK_TEXT, CYLAnimatedItemContrastKindText, glass, undefined, undefined);
      expect(textLifted === DARK_TEXT).assertFalse();
      expect(contrastOnGlass(textLifted, undefined, -1) >= MINIMUM_TEXT_CONTRAST).assertTrue();
      const iconLifted = CYLTagButton.adaptedOnGlassOf(DARK_TEAL, CYLAnimatedItemContrastKindIcon, glass, undefined, undefined);
      expect(contrastOnGlass(iconLifted, undefined, -1) >= MINIMUM_ICON_CONTRAST).assertTrue();
      expect(CYLTagButton.adaptedOnGlassOf(DARK_TEXT, CYLAnimatedItemContrastKindText, flat, undefined, undefined)).assertEqual(DARK_TEXT);
      setMode(MODE_LIGHT);
      expect(CYLTagButton.adaptedOnGlassOf(DARK_TEXT, CYLAnimatedItemContrastKindText, glass, undefined, undefined)).assertEqual(DARK_TEXT);
      setMode(MODE_DARK);
      CYLLiquidGlass.activeOverride = false;
      expect(CYLTagButton.adaptedOnGlassOf(DARK_TEXT, CYLAnimatedItemContrastKindText, glass, undefined, undefined)).assertEqual(DARK_TEXT);
    });

    it('aSymbolUnderAnAnimationIsHandedToTheItem', 0, () => {
      expect(cylTagAnimationImage(undefined)).assertEqual('');
      expect(cylTagAnimationImage('rawfile/static.png')).assertEqual('rawfile/static.png');
      const symbol: Resource = $r('sys.symbol.camera');
      expect(cylTagAnimationImage(symbol) === symbol).assertTrue();
    });
  });
}
