/**
 * CYLAndroidSampleSupport.swift: what the three Android sample ports share — a toast (Android's Toast), the samples'
 * filled buttons, the text fields with a bottom line, and the pictures of the TagViewGroup sample (drawn, as on iOS).
 */
import { promptAction } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';

/** `String(format:)` for the %ld / %@ placeholders of the example's strings. */
export function cylFormat(format: string, ...args: (string | number)[]): string {
  let index = 0;
  return format.replace(new RegExp('%(ld|@|d)', 'g'), (): string => {
    const value = index < args.length ? args[index] : '';
    index++;
    return `${value}`;
  });
}

/** Android's Toast.LENGTH_SHORT: a message at the bottom for two seconds. */
export function cylToast(text: string): void {
  try {
    promptAction.showToast({ message: text, duration: 2000, bottom: 48 });
  } catch (e) {
    // No UI context (tests).
  }
}

/** UIColor.systemPink / systemOrange / systemGray / systemBlue / systemTeal. */
export const SYSTEM_PINK: string = '#FFFF2D55';
export const SYSTEM_ORANGE: string = '#FFFF9500';
export const SYSTEM_GRAY: string = '#FF8E8E93';
export const SYSTEM_BLUE: string = '#FF007AFF';
export const SYSTEM_TEAL: string = '#FF30B0C7';
export const SECONDARY_LABEL: string = '#993C3C43';
export const GROUPED_BACKGROUND: string = '#FFF2F2F7';

/** A filled button (UIButton.Configuration.filled, small corners), as the samples' buttons. */
@Component
export struct CYLSampleButton {
  @Prop title: string = '';
  @Prop color: string = SYSTEM_BLUE;
  identifier: string = '';
  action: () => void = () => {
  };

  build() {
    Button(this.title, { type: ButtonType.Normal })
      .fontSize(17)
      .fontColor(Color.White)
      .backgroundColor(this.color)
      .borderRadius(6)
      .constraintSize({ minHeight: 44 })
      .width('100%')
      .id(this.identifier)
      .onClick(() => this.action())
  }
}

/** A picture of the TagViewGroup sample: a gradient and a large glyph, `index` choosing the colors and the glyph. */
class CYLPicturePalette {
  dark: string;
  light: string;
  glyph: string;
  label: string;

  constructor(dark: string, light: string, glyph: string, label: string) {
    this.dark = dark;
    this.light = light;
    this.glyph = glyph;
    this.label = label;
  }
}

const PALETTES: CYLPicturePalette[] = [
  new CYLPicturePalette('rgb(140,107,84)', 'rgb(217,194,168)', '👞', '鞋子图片'),
  new CYLPicturePalette('rgb(64,89,128)', 'rgb(179,204,230)', '👜', '包图片'),
  new CYLPicturePalette('rgb(77,115,89)', 'rgb(199,224,191)', '👕', '衣服图片'),
];

export class CYLSamplePicture {
  private static cache: Map<string, image.PixelMap> = new Map<string, image.PixelMap>();

  /** The label of picture `index` (CYLImageTagView reads it as the picture's label). */
  static label(index: number): string {
    return PALETTES[index % PALETTES.length].label;
  }

  static picture(index: number, size: number = 750): image.PixelMap | undefined {
    const key = `${index % PALETTES.length}-${size}`;
    const cached = CYLSamplePicture.cache.get(key);
    if (cached !== undefined) {
      return cached;
    }
    try {
      const palette = PALETTES[index % PALETTES.length];
      const canvas = new OffscreenCanvas(size, size);
      const context = canvas.getContext('2d');
      const gradient = context.createLinearGradient(0, 0, size, size);
      gradient.addColorStop(0, palette.light);
      gradient.addColorStop(1, palette.dark);
      context.fillStyle = gradient;
      context.fillRect(0, 0, size, size);
      context.globalAlpha = 0.55;
      context.font = `${Math.round(size * 0.42)}px`;
      context.textAlign = 'center';
      context.textBaseline = 'middle';
      context.fillStyle = '#FFFFFF';
      context.fillText(palette.glyph, size / 2, size / 2);
      const pixelMap = context.getPixelMap(0, 0, size, size);
      CYLSamplePicture.cache.set(key, pixelMap);
      return pixelMap;
    } catch (e) {
      return undefined;
    }
  }
}
