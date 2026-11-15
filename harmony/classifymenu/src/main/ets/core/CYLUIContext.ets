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
      return CYLUIContext.context.px2vp(Number(CYLUIContext.context.getMeasureUtils().measureText(options)));
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

  private static canvasSize(text: string, fontSize: number, fontWeight: number | FontWeight | string,
    constraintWidth: number): Size {
    const lineHeight = fontSize * 1.2;
    try {
      const canvas = new OffscreenCanvas(1, 1);
      const context = canvas.getContext('2d');
      const weight = typeof fontWeight === 'number' ? `${fontWeight}` : 'normal';
      context.font = `${weight} ${fontSize}vp sans-serif`;
      const width = context.measureText(text).width;
      if (constraintWidth > 0 && width > constraintWidth) {
        return { width: constraintWidth, height: Math.ceil(width / constraintWidth) * lineHeight };
      }
      return { width: width, height: lineHeight };
    } catch (error) {
      const width = Array.from(text).length * fontSize * 0.5;
      return { width: width, height: lineHeight };
    }
  }
}
