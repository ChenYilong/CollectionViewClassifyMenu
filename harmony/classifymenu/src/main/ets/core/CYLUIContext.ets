import { display } from '@kit.ArkUI';
import { MeasureOptions } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { deviceInfo } from '@kit.BasicServicesKit';

/**
 * The UI context the library's model code measures with.
 *
 * Model classes (tags, layouts) have no component and so no `getUIContext()`. The library's components call
 * `CYLUIContext.remember(this.getUIContext())` when they appear. Until then, and in unit tests, sizes come from the default display's density and text from an
 * offscreen canvas.
 */
export class CYLUIContext {
  private static context?: UIContext;

  /**
   * Keeps `context` for later measurements.
   */
  static remember(context: UIContext | undefined): void {
    if (context !== undefined) {
      CYLUIContext.context = context;
    }
  }

  /**
   * Whether a UI context has been remembered (measurements before it use the canvas fallback).
   */
  static get hasContext(): boolean {
    return CYLUIContext.context !== undefined;
  }

  /**
   * The context of the ability that shows `ui` (or the remembered UI context): `getHostContext()` from API 18, the
   * global `getContext()` on API 12 to 17, where the replacement does not exist yet.
   */
  static hostContext(ui?: UIContext): common.UIAbilityContext {
    const context = ui ?? CYLUIContext.context;
    if (deviceInfo.sdkApiVersion >= 18 && context !== undefined) {
      const host = context.getHostContext();
      if (host !== undefined) {
        return host as common.UIAbilityContext;
      }
    }
    // API 12 to 17: the only way to reach the context from a component.
    return getContext() as common.UIAbilityContext;
  }

  /**
   * The density of the default display (px per vp), 1 without a display.
   */
  static density(): number {
    try {
      const density = display.getDefaultDisplaySync().densityPixels;
      return density > 0 ? density : 1;
    } catch (error) {
      return 1;
    }
  }

  /**
   * Converts physical pixels to vp.
   */
  static px2vp(px: number): number {
    if (CYLUIContext.context !== undefined) {
      return CYLUIContext.context.px2vp(px);
    }
    return px / CYLUIContext.density();
  }

  /**
   * Converts vp to physical pixels.
   */
  static vp2px(vp: number): number {
    if (CYLUIContext.context !== undefined) {
      return CYLUIContext.context.vp2px(vp);
    }
    return vp * CYLUIContext.density();
  }

  /**
   * The width of one line of `options.textContent`, in vp.
   */
  static measureTextWidth(options: MeasureOptions, fontSize: number, fontWeight: number | FontWeight | string = 400): number {
    if (CYLUIContext.context !== undefined) {
      const width = CYLUIContext.context.px2vp(Number(CYLUIContext.context.getMeasureUtils().measureText(options)));
      if (Number.isFinite(width) && width > 0) {
        return width;
      }
    }
    return CYLUIContext.canvasSize(String(options.textContent), fontSize, fontWeight, 0).width;
  }

  /**
   * The size of `options.textContent` wrapped at `options.constraintWidth`, in vp.
   */
  static measureTextSize(options: MeasureOptions, fontSize: number, fontWeight: number | FontWeight | string = 400,
    constraintWidth: number = 0): Size {
    if (CYLUIContext.context !== undefined) {
      const size: SizeOptions = CYLUIContext.context.getMeasureUtils().measureTextSize(options);
      return {
        width: CYLUIContext.context.px2vp(Number(size.width ?? 0)),
        height: CYLUIContext.context.px2vp(Number(size.height ?? 0))
      };
    }
    return CYLUIContext.canvasSize(String(options.textContent), fontSize, fontWeight, constraintWidth);
  }

  /**
   * The size of `text` on an offscreen canvas, in vp: the font in physical pixels (a canvas font does not take `vp`),
   * divided back by the density. Never 0 or NaN for a non-empty text: an estimate of 0.6 em per character instead, so
   * a tag measured before any UI context exists is never laid out with no width.
   */
  private static canvasSize(text: string, fontSize: number, fontWeight: number | FontWeight | string,
    constraintWidth: number): Size {
    const lineHeight = fontSize * 1.2;
    const estimate = Array.from(text).length * fontSize * 0.6;
    let width = estimate;
    try {
      const density = CYLUIContext.density();
      const canvas = new OffscreenCanvas(1, 1);
      const context = canvas.getContext('2d');
      const weight = typeof fontWeight === 'number' ? `${fontWeight}` : 'normal';
      context.font = `${weight} ${Math.round(fontSize * density)}px sans-serif`;
      const measured = context.measureText(text).width / density;
      if (Number.isFinite(measured) && (measured > 0 || text.length === 0)) {
        width = measured;
      }
    } catch (error) {
      width = estimate;
    }
    if (constraintWidth > 0 && width > constraintWidth) {
      return { width: constraintWidth, height: Math.ceil(width / constraintWidth) * lineHeight };
    }
    return { width: width, height: lineHeight };
  }

}
