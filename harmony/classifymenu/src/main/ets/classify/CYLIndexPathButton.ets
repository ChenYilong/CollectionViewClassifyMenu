/**
 * iOS `CYLIndexPathButton.swift` and `UIButton+CYLCollectionCellStyle.swift`, migrated from Android
 * `CYLClassifyMenu.kt` / `CYLGeneralExtensions.kt`: a button model that knows the item it shows (`section`, `row`),
 * with per-state titles, images, title colors and backgrounds as UIButton, and `CYLIndexPathButtonView`, which renders
 * it. The image moves `imageTitleSpacing / 2` toward the leading edge and the title the same toward the trailing edge,
 * plus `titleLeadingInset`, as iOS `imageRect(forContentRect:)` / `titleRect(forContentRect:)`.
 */
import { CYLColor, CYLControlState, CYLFont, CYLImage } from '../core/CYLTypes';
import { CYLMenuResources } from '../core/CYLMenuResources';
import { CYLTagMetrics } from '../core/CYLTagMetrics';

/** UIButton's default title font (system, 15 pt). */
const UIBUTTON_DEFAULT_FONT_SIZE: number = 15;

/** `CYLCollectionCellButtonStyle`: the looks of a classify-menu tag button (`cylApply`). */
export enum CYLCollectionCellButtonStyle {
  /** White with a 1 pt border and 5 pt corners. */
  general = 0,
  /** Green text and border; filled green while highlighted. */
  home = 1,
  /** Red text and border; filled green while highlighted. */
  red = 2,
  /** A light green capsule; the app's tint while selected or highlighted (the menu's default). */
  chengNi = 3
}

/** `UIControl.ContentHorizontalAlignment`, the two values the menus use. */
export enum CYLContentHorizontalAlignment {
  center = 0,
  left = 1
}

/** A per-state value with UIKit's fallback: the exact state, then selected, then normal. */
function stateValue<T>(values: Map<number, T>, state: number): T | undefined {
  const exact = values.get(state);
  if (exact !== undefined) {
    return exact;
  }
  if ((state & CYLControlState.SELECTED) !== 0) {
    const selected = values.get(CYLControlState.SELECTED);
    if (selected !== undefined) {
      return selected;
    }
  }
  return values.get(CYLControlState.NORMAL);
}

export class CYLIndexPathButton {
  /** The section of the item the button shows. */
  section: number = 0;
  /** The row (item) of the item the button shows. */
  row: number = 0;
  /** Space between the image and the title when both are shown; 0 by default. */
  imageTitleSpacing: number = 0;
  /** Extra leading space before the title; 0 by default. */
  titleLeadingInset: number = 0;

  isSelected: boolean = false;
  isHidden: boolean = false;
  isUserInteractionEnabled: boolean = true;
  /** `UIView.tag`. */
  tag: number = 0;
  accessibilityHint: string | undefined = undefined;
  /** Whether the button reads as a heading (`accessibilityTraits = .header`). */
  isAccessibilityHeader: boolean = false;
  contentHorizontalAlignment: CYLContentHorizontalAlignment = CYLContentHorizontalAlignment.center;
  font: CYLFont = CYLFont.systemFont(UIBUTTON_DEFAULT_FONT_SIZE);
  cornerRadius: number = 0;
  borderWidth: number = 0;
  borderColor: string = CYLColor.BLACK;
  backgroundColor: string = CYLColor.CLEAR;

  private titles: Map<number, string> = new Map<number, string>();
  private images: Map<number, CYLImage> = new Map<number, CYLImage>();
  /** A custom UIButton's default title color is white. */
  private titleColors: Map<number, string> = new Map<number, string>([[CYLControlState.NORMAL, CYLColor.WHITE]]);
  private backgroundImages: Map<number, Resource> = new Map<number, Resource>();
  /** Backgrounds of `cylImage(filledWith:)`: a solid color per state. */
  private backgroundFills: Map<number, string> = new Map<number, string>();

  /** The state flags (`UIControl.State`) of the button, highlighted while `pressed`. */
  stateFlags(pressed: boolean = false): number {
    return (this.isSelected ? CYLControlState.SELECTED : 0) | (pressed ? CYLControlState.HIGHLIGHTED : 0);
  }

  setTitle(title: string | undefined, state: number): void {
    if (title === undefined) {
      this.titles.delete(state);
    } else {
      this.titles.set(state, title);
    }
  }

  setImage(image: CYLImage | undefined, state: number): void {
    if (image === undefined) {
      this.images.delete(state);
    } else {
      this.images.set(state, image);
    }
  }

  setTitleColor(color: string, state: number): void {
    this.titleColors.set(state, color);
  }

  setBackgroundImage(image: Resource | undefined, state: number): void {
    if (image === undefined) {
      this.backgroundImages.delete(state);
    } else {
      this.backgroundImages.set(state, image);
    }
  }

  /** `setBackgroundImage(UIButton.cylImage(filledWith: color), for: state)`. */
  setBackgroundFill(color: string, state: number): void {
    this.backgroundFills.set(state, color);
  }

  titleFor(state: number): string | undefined {
    return stateValue<string>(this.titles, state);
  }

  imageFor(state: number): CYLImage | undefined {
    return stateValue<CYLImage>(this.images, state);
  }

  titleColorFor(state: number): string {
    return stateValue<string>(this.titleColors, state) ?? CYLColor.WHITE;
  }

  backgroundImageFor(state: number): Resource | undefined {
    return stateValue<Resource>(this.backgroundImages, state);
  }

  backgroundColorFor(state: number): string {
    return stateValue<string>(this.backgroundFills, state) ?? this.backgroundColor;
  }

  get currentTitle(): string | undefined {
    return this.titleFor(this.stateFlags());
  }

  get currentImage(): CYLImage | undefined {
    return this.imageFor(this.stateFlags());
  }

  /** Whether the image and the title are both shown with a spacing between them. */
  get showsImageAndTitleWithSpacing(): boolean {
    const title = this.currentTitle;
    return this.imageTitleSpacing > 0 && this.currentImage !== undefined && title !== undefined && title.length > 0;
  }

  /** `imageRect(forContentRect:)`'s horizontal move. */
  get imageOffsetX(): number {
    return this.showsImageAndTitleWithSpacing ? -this.imageTitleSpacing / 2 : 0;
  }

  /** `titleRect(forContentRect:)`'s horizontal move. */
  get titleOffsetX(): number {
    const title = this.currentTitle;
    if (title === undefined || title.length === 0) {
      return 0;
    }
    return this.titleLeadingInset + (this.showsImageAndTitleWithSpacing ? this.imageTitleSpacing / 2 : 0);
  }

  /** `UIButton.cylApply(_:)`: applies one of the classify menu's tag looks. */
  cylApply(style: CYLCollectionCellButtonStyle): void {
    const green = CYLColor.rgb(18 / 255, 133 / 255, 117 / 255);
    if (style === CYLCollectionCellButtonStyle.general) {
      this.cornerRadius = 5;
      this.backgroundColor = CYLColor.WHITE;
      this.borderWidth = 1;
    } else if (style === CYLCollectionCellButtonStyle.home) {
      this.font = CYLTagMetrics.titleFont();
      this.setTitleColor(green, CYLControlState.NORMAL);
      this.setTitleColor(CYLColor.withAlpha(green, 0.7), CYLControlState.SELECTED);
      this.setTitleColor(CYLColor.WHITE, CYLControlState.HIGHLIGHTED);
      this.setBackgroundFill(green, CYLControlState.HIGHLIGHTED);
      this.borderColor = green;
    } else if (style === CYLCollectionCellButtonStyle.red) {
      const red = CYLColor.rgb(160 / 255, 15 / 255, 85 / 255);
      this.font = CYLTagMetrics.titleFont();
      this.setTitleColor(red, CYLControlState.NORMAL);
      this.setTitleColor(CYLColor.WHITE, CYLControlState.HIGHLIGHTED);
      this.setBackgroundFill(green, CYLControlState.HIGHLIGHTED);
      this.borderColor = red;
    } else {
      this.cornerRadius = 13;
      this.setBackgroundFill(CYLColor.rgb(230 / 255, 255 / 255, 244 / 255), CYLControlState.NORMAL);
      this.font = CYLTagMetrics.titleFont();
      this.setTitleColor(CYLColor.rgb(42 / 255, 185 / 255, 160 / 255), CYLControlState.NORMAL);
      const highlighted = CYLMenuResources.image('tag_btn_background_highlighted');
      const states: number[] = [CYLControlState.HIGHLIGHTED, CYLControlState.SELECTED,
        CYLControlState.SELECTED | CYLControlState.HIGHLIGHTED];
      for (const state of states) {
        this.setTitleColor(CYLColor.WHITE, state);
        this.setBackgroundImage(highlighted, state);
      }
    }
  }
}

/** Renders a `CYLIndexPathButton` filling its parent (recreate it to show a changed model). */
@Component
export struct CYLIndexPathButtonView {
  button: CYLIndexPathButton = new CYLIndexPathButton();
  onTap?: (button: CYLIndexPathButton) => void;
  @State private pressed: boolean = false;

  build() {
    Stack({
      alignContent: this.button.contentHorizontalAlignment === CYLContentHorizontalAlignment.left ?
        Alignment.Start : Alignment.Center
    }) {
      if (this.button.backgroundImageFor(this.button.stateFlags(this.pressed)) !== undefined) {
        Image(this.button.backgroundImageFor(this.button.stateFlags(this.pressed)))
          .accessibilityLevel('no')
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Fill)
      }
      Row() {
        if (this.button.imageFor(this.button.stateFlags(this.pressed)) !== undefined) {
          Image(this.button.imageFor(this.button.stateFlags(this.pressed))).offset({ x: this.button.imageOffsetX })
            .accessibilityLevel('no')
        }
        if (this.button.titleFor(this.button.stateFlags(this.pressed)) !== undefined) {
          Text(this.button.titleFor(this.button.stateFlags(this.pressed)))
            .fontSize(`${this.button.font.size}fp`)
            .fontWeight(this.button.font.weight)
            .fontColor(this.button.titleColorFor(this.button.stateFlags(this.pressed)))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .offset({ x: this.button.titleOffsetX })
        }
      }
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .borderRadius(this.button.cornerRadius)
    .borderWidth(this.button.borderWidth)
    .borderColor(this.button.borderColor)
    .backgroundColor(this.button.backgroundColorFor(this.button.stateFlags(this.pressed)))
    .visibility(this.button.isHidden ? Visibility.Hidden : Visibility.Visible)
    .hitTestBehavior(this.button.isUserInteractionEnabled ? HitTestMode.Default : HitTestMode.Transparent)
    .accessibilityGroup(true)
    .accessibilityText(this.button.titleFor(this.button.stateFlags(this.pressed)) ?? '')
    .accessibilityDescription(this.button.accessibilityHint ?? '')
    .onTouch((event: TouchEvent) => {
      if (!this.button.isUserInteractionEnabled) {
        return;
      }
      if (event.type === TouchType.Down) {
        this.pressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressed = false;
      }
    })
    .onClick(() => {
      if (this.button.isUserInteractionEnabled && this.onTap !== undefined) {
        this.onTap(this.button);
      }
    })
  }
}
