import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import { CYLAnimatedItemContrast, CYLLiquidGlass } from 'cylanimateditem';
import {
  CYLControlState, CYLFont, CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlPosition, CYLMenuStyle,
  CYLTagAppearance, CYLTagBackgroundStyle, CYLTagButton, CYLTagButtonMetrics, CYLTagFoldButton, CYLTagFoldMetrics, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const BUTTON_HEIGHT: number = 44;
const BUTTON_WIDTH: number = 120;
const COLOR_MODE_KEY: string = 'cyl_colorMode';
const MODE_DARK: string = 'dark';
const MODE_LIGHT: string = 'light';
const MINIMUM_TEXT_CONTRAST: number = 4.5;
const MINIMUM_ICON_CONTRAST: number = 3;
/** An icon color far too dark for dark glass. */
const DARK_TEAL: string = '#FF004D4D';
/** The configuration demo's dark title color (menu/animated-tags.json): invisible on dark glass. */
const DARK_TEXT: string = '#FF3C3C43';
const DARK_BLUE_TINT: string = '#FF204060';
const READABLE_WHITE: string = '#FFFFFFFF';

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

/** The WCAG contrast of `color` over the glass of `button` (its tint and alpha); 0 for a color that is not static. */
function contrastOnGlass(button: CYLTagButton, color: ResourceColor): number {
  const rgba = CYLAnimatedItemContrast.components(color);
  if (rgba === undefined) {
    return 0;
  }
  const glass = CYLAnimatedItemContrast.glassReferenceLuminance(button.glassTint, button.glassTintAlpha);
  return CYLAnimatedItemContrast.contrastRatio(CYLAnimatedItemContrast.relativeLuminance(rgba.red, rgba.green, rgba.blue), glass);
}

function tailControl(): CYLMenuFoldControl {
  return new CYLMenuFoldControl(CYLMenuFoldControlPosition.tail, CYLMenuFoldControlContent.icon);
}

function tailCell(style: CYLMenuStyle): CYLTagFoldButton {
  const cell = new CYLTagFoldButton();
  cell.applyInlineFoldControl(tailControl(), style, false, false);
  cell.setBounds(BUTTON_HEIGHT, BUTTON_HEIGHT);
  return cell;
}

function setMode(mode: string): void {
  AppStorage.setOrCreate<string>(COLOR_MODE_KEY, mode);
}

/**
 * The tag draws its title and static icons itself and hands the colours to the shared item through its CHANNELS: an EXPLICIT
 * colour through the subclass-explicit level, an unset one through the subclass built-in level
 * (`CYLAnimatedItemColorResolver`, the item's one precedence and adaptation path). The tag has no contrast code of its own:
 * an explicit colour is lifted only where glass is drawn in dark mode; everything else is unchanged.
 */
export default function tagIconColorTest() {
  let savedMeasurer: CYLTextMeasurer = FIXED;
  let savedGlass: boolean | undefined = undefined;
  let savedMode: string | undefined = undefined;

  describe('CYLTagIconColor', () => {
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

    it('theTagHandsTheStylesIconColorThroughTheExplicitChannel', 0, () => {
      const style = glassStyle();
      style.setIconColor(DARK_TEAL, CYLControlState.NORMAL);
      const button = buttonWith(style);
      expect(button.imageView.tintColor).assertEqual(DARK_TEAL);
      expect(button.imageView.tintsImage).assertTrue();
      expect(button.subclassIconColor).assertEqual(DARK_TEAL);
    });

    it('darkGlassLiftsAnExplicitDarkTitleColor', 0, () => {
      const style = glassStyle();
      style.normalAppearance.textColor = DARK_TEXT;
      const button = buttonWith(style);
      expect(button.subclassTitleColor).assertEqual(DARK_TEXT);
      expect(contrastOnGlass(button, DARK_TEXT) < MINIMUM_TEXT_CONTRAST).assertTrue();
      expect(button.resolvedTitleColor() === DARK_TEXT).assertFalse();
      expect(contrastOnGlass(button, button.resolvedTitleColor()) >= MINIMUM_TEXT_CONTRAST).assertTrue();
    });

    it('darkGlassLiftsAnExplicitDarkTitleColorOverAnExplicitTint', 0, () => {
      const style = glassStyle();
      style.normalAppearance.textColor = DARK_TEXT;
      style.normalAppearance.backgroundColor = DARK_BLUE_TINT;
      const button = buttonWith(style);
      expect(button.glassTint).assertEqual(DARK_BLUE_TINT);
      expect(contrastOnGlass(button, button.resolvedTitleColor()) >= MINIMUM_TEXT_CONTRAST).assertTrue();
    });

    it('anUnsetTitleColorGoesThroughTheBuiltInChannelAndStaysReadableInNight', 0, () => {
      // Night mode (beforeEach) with a LIGHT-only theme: the unset title is the tag's built-in (mode-aware) default, handed
      // as the built-in level; no explicit colour, and the dynamic default is never replaced by a lifted constant.
      const unset = buttonWith(glassStyle());
      expect(unset.subclassTitleColor === undefined).assertTrue();
      expect(unset.builtInTitleColor).assertEqual(CYLTagAppearance.defaultTextColor);
      expect(unset.resolvedTitleColor()).assertEqual(CYLTagAppearance.defaultTextColor);
      const selected = buttonWith(glassStyle());
      selected.isSelected = true;
      expect(selected.subclassTitleColor === undefined).assertTrue();
      const reset = glassStyle();
      reset.normalAppearance.textColor = DARK_TEXT;
      reset.normalAppearance.resetTextColor();
      expect(buttonWith(reset).subclassTitleColor === undefined).assertTrue();
    });

    it('aSelectedTagWithoutAnExplicitColorDoesNotBorrowTheNormalOne', 0, () => {
      const style = glassStyle();
      style.normalAppearance.textColor = DARK_TEXT;
      const button = buttonWith(style);
      button.isSelected = true;
      expect(button.subclassTitleColor === undefined).assertTrue();
      expect(button.resolvedTitleColor() === DARK_TEXT).assertFalse();
    });

    it('anAppearanceTellsAnExplicitTitleColorFromTheBuiltInDefault', 0, () => {
      const appearance = new CYLTagAppearance();
      expect(appearance.explicitTextColor === undefined).assertTrue();
      appearance.textColor = DARK_TEXT;
      expect(appearance.explicitTextColor).assertEqual(DARK_TEXT);
      expect(appearance.copy().explicitTextColor).assertEqual(DARK_TEXT);
      appearance.reset();
      expect(appearance.explicitTextColor === undefined).assertTrue();
      const style = new CYLMenuStyle();
      expect(style.selectedAppearance.explicitTextColor === undefined).assertTrue();
      expect(style.disabledAppearance.explicitTextColor === undefined).assertTrue();
    });

    it('flatLightAndNonGlassTitlesAreUnchanged', 0, () => {
      const flat = new CYLMenuStyle();
      flat.normalAppearance.textColor = DARK_TEXT;
      expect(buttonWith(flat).resolvedTitleColor()).assertEqual(DARK_TEXT);
      const light = glassStyle();
      light.normalAppearance.textColor = DARK_TEXT;
      setMode(MODE_LIGHT);
      expect(buttonWith(light).resolvedTitleColor()).assertEqual(DARK_TEXT);
      setMode(MODE_DARK);
      CYLLiquidGlass.activeOverride = false;
      expect(buttonWith(light).resolvedTitleColor()).assertEqual(DARK_TEXT);
    });

    it('aReadableTitleColorIsHandedBackAsItIs', 0, () => {
      const style = glassStyle();
      style.normalAppearance.textColor = READABLE_WHITE;
      expect(buttonWith(style).resolvedTitleColor()).assertEqual(READABLE_WHITE);
    });

    it('darkGlassLiftsAnExplicitIconColorToThree', 0, () => {
      const style = glassStyle();
      style.setIconColor(DARK_TEAL, CYLControlState.NORMAL);
      const button = buttonWith(style);
      expect(contrastOnGlass(button, DARK_TEAL) < MINIMUM_ICON_CONTRAST).assertTrue();
      const adapted = button.resolvedIconColor();
      expect(adapted === DARK_TEAL).assertFalse();
      expect(contrastOnGlass(button, adapted) >= MINIMUM_ICON_CONTRAST).assertTrue();
    });

    it('anIconThatFollowsAnExplicitTitleColorIsLiftedWithIt', 0, () => {
      const style = glassStyle();
      style.normalAppearance.textColor = DARK_TEXT;
      const button = buttonWith(style);
      expect(button.imageView.tintsImage).assertFalse();
      expect(button.subclassIconColor).assertEqual(DARK_TEXT);
      expect(contrastOnGlass(button, button.resolvedIconColor()) >= MINIMUM_ICON_CONTRAST).assertTrue();
    });

    it('anUnsetIconColorGoesThroughTheBuiltInChannelAndTintsNothing', 0, () => {
      const button = buttonWith(glassStyle());
      expect(button.subclassIconColor === undefined).assertTrue();
      expect(button.imageView.tintsImage).assertFalse();
      expect(button.resolvedIconColor()).assertEqual(button.imageView.tintColor);
    });

    it('flatAndLightIconsAreUnchanged', 0, () => {
      const flat = new CYLMenuStyle();
      flat.setIconColor(DARK_TEAL, CYLControlState.NORMAL);
      expect(buttonWith(flat).resolvedIconColor()).assertEqual(DARK_TEAL);
      const light = glassStyle();
      light.setIconColor(DARK_TEAL, CYLControlState.NORMAL);
      setMode(MODE_LIGHT);
      expect(buttonWith(light).resolvedIconColor()).assertEqual(DARK_TEAL);
    });

    it('theTailCellResolvesTheSameColorsAsAPlainTag', 0, () => {
      const explicit = glassStyle();
      explicit.normalAppearance.textColor = DARK_TEXT;
      const plain = buttonWith(explicit);
      const cell = tailCell(explicit);
      // An icon-only tail control draws no title and tints its icon with the fold control's own colour, by design: only the unset-colour hand-over is compared.
      const unset = glassStyle();
      expect(tailCell(unset).resolvedTitleColor()).assertEqual(buttonWith(unset).resolvedTitleColor());
    });

    it('theTailCellTakesTheTagsTitleColorAndItsExplicitFlag', 0, () => {
      const explicit = glassStyle();
      explicit.normalAppearance.textColor = DARK_TEXT;
      const inline = CYLTagFoldMetrics.inlineStyle(tailControl(), explicit);
      expect(inline.normalAppearance.explicitTextColor).assertEqual(DARK_TEXT);
      expect(inline.selectedAppearance.explicitTextColor).assertEqual(DARK_TEXT);
      expect(inline.disabledAppearance.explicitTextColor).assertEqual(DARK_TEXT);
      expect(tailCell(explicit).itemBackgroundStyle).assertEqual(buttonWith(explicit).itemBackgroundStyle);
      const unset = CYLTagFoldMetrics.inlineStyle(tailControl(), glassStyle());
      expect(unset.normalAppearance.explicitTextColor === undefined).assertTrue();
      expect(unset.selectedAppearance.explicitTextColor === undefined).assertTrue();
      expect(unset.disabledAppearance.explicitTextColor === undefined).assertTrue();
    });
  });
}
