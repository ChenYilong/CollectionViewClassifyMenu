/**
 * iOS `CYLRightImageButton.swift`, migrated from Android `CYLClassifyMenu.kt`: the "more" button of a menu section:
 * its title ("更多" / "收起", CYLMenuExpand / CYLMenuCollapse) with the arrow image after it, 7 vp apart; selected
 * means expanded. It is never highlighted.
 */
import { CYLMenuLocalizedString, CYLMenuResources } from '../core/CYLMenuResources';
import { CYLColor, CYLFont } from '../core/CYLTypes';

export class CYLRightImageButton {
  /** The space between the title and the image. */
  static readonly imageToTextMargin: number = 7;

  isSelected: boolean = false;
  isHidden: boolean = false;
  /** `UIView.tag`: the section in a menu header. */
  tag: number = 0;
  accessibilityHint: string | undefined = undefined;
  font: CYLFont = CYLFont.systemFont(12);
  titleColor: string = CYLColor.BLACK;
  normalTitle: string = CYLMenuLocalizedString('CYLMenuExpand');
  selectedTitle: string = CYLMenuLocalizedString('CYLMenuCollapse');
  normalImage: Resource | undefined = CYLMenuResources.image('home_btn_more_normal');
  selectedImage: Resource | undefined = CYLMenuResources.image('home_btn_more_selected');

  /** Never highlighted: the button toggles between its normal and selected looks only. */
  get isHighlighted(): boolean {
    return false;
  }

  get currentTitle(): string {
    return this.isSelected ? this.selectedTitle : this.normalTitle;
  }

  get currentImage(): Resource | undefined {
    return this.isSelected ? this.selectedImage : this.normalImage;
  }
}

/** Renders a `CYLRightImageButton` filling its parent. */
@Component
export struct CYLRightImageButtonView {
  button: CYLRightImageButton = new CYLRightImageButton();
  onTap?: (button: CYLRightImageButton) => void;

  build() {
    Row({ space: CYLRightImageButton.imageToTextMargin }) {
      Text(this.button.currentTitle)
        .fontSize(`${this.button.font.size}fp`)
        .fontColor(this.button.titleColor)
        .maxLines(1)
        .flexShrink(1)
      if (this.button.currentImage !== undefined) {
        Image(this.button.currentImage)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .visibility(this.button.isHidden ? Visibility.Hidden : Visibility.Visible)
    .accessibilityText(this.button.currentTitle)
    .accessibilityDescription(this.button.accessibilityHint ?? '')
    .onClick(() => {
      if (this.onTap !== undefined) {
        this.onTap(this.button);
      }
    })
  }
}
