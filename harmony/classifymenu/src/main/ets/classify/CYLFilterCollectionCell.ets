import { CYLAccessibilitySelectedModifier } from '../core/CYLAccessibilitySelected';
/**
 * iOS `CYLFilterCollectionCell.swift` and `CYLMultipleFilterHeaderView.swift`, migrated from Android
 * `CYLMultipleFilter.kt`: a tag of the multiple-choice filter (a button that fills the cell and shows the selection;
 * the cell takes the touches) and a section header (an image, then the section's title over a thin line).
 */
import { CYLMenuResources } from '../core/CYLMenuResources';
import { CYLTagMetrics } from '../core/CYLTagMetrics';
import { CYLColor, CYLControlState, CYLImage } from '../core/CYLTypes';
import { CYLIndexPathButton } from './CYLIndexPathButton';

export class CYLFilterCollectionCell {
  /** The tag's button; it ignores touches (the cell takes them). */
  readonly titleButton: CYLIndexPathButton = new CYLIndexPathButton();

  constructor() {
    const button = this.titleButton;
    button.isUserInteractionEnabled = false;
    button.font = CYLTagMetrics.titleFont();
    button.setBackgroundImage(CYLMenuResources.image('btn_slide_normal'), CYLControlState.NORMAL);
    button.setBackgroundImage(CYLMenuResources.image('btn_slide_selected'), CYLControlState.SELECTED);
    button.setTitleColor(CYLColor.rgb(96 / 255, 147 / 255, 130 / 255), CYLControlState.NORMAL);
    button.setTitleColor(CYLColor.WHITE, CYLControlState.SELECTED);
  }
}

/** Renders a `CYLFilterCollectionCell` filling its parent; the background images stretch from their centers. */
@Component
export struct CYLFilterCollectionCellView {
  cell: CYLFilterCollectionCell = new CYLFilterCollectionCell();
  onTap?: (cell: CYLFilterCollectionCell) => void;
  @State private slice: EdgeWidths = { top: 0, left: 0, bottom: 0, right: 0 };

  build() {
    Stack() {
      if (this.cell.titleButton.backgroundImageFor(this.cell.titleButton.stateFlags()) !== undefined) {
        Image(this.cell.titleButton.backgroundImageFor(this.cell.titleButton.stateFlags()))
          .accessibilityLevel('no')
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Fill)
          .resizable({ slice: this.slice })
          .onComplete((event) => {
            if (event !== undefined) {
              // `resizableImage(withCapInsets:)` with half the image on each side.
              const vertical = Math.floor(this.getUIContext().px2vp(event.height) / 2);
              const horizontal = Math.floor(this.getUIContext().px2vp(event.width) / 2);
              this.slice = { top: vertical, left: horizontal, bottom: vertical, right: horizontal };
            }
          })
      }
      Text(this.cell.titleButton.currentTitle ?? '')
        .fontSize(`${this.cell.titleButton.font.size}fp`)
        .fontWeight(this.cell.titleButton.font.weight)
        .fontColor(this.cell.titleButton.titleColorFor(this.cell.titleButton.stateFlags()))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height('100%')
    .accessibilityGroup(true)
    .accessibilityText(this.cell.titleButton.currentTitle ?? '')
    .attributeModifier(new CYLAccessibilitySelectedModifier(this.cell.titleButton.isSelected))
    .onClick(() => {
      if (this.onTap !== undefined) {
        this.onTap(this.cell);
      }
    })
  }
}

/** The title's x and the image's frame in the default XIB. */
const TITLE_X: number = 50;
const IMAGE_X: number = 6;
const IMAGE_SIZE: number = 38;

export class CYLMultipleFilterHeaderView {
  static readonly height: number = 38;
  static readonly lineColor: string = CYLColor.rgb(146 / 255, 175 / 255, 164 / 255);

  /** An image before the title (empty by default). */
  imageView: CYLImage | undefined = undefined;
  /** The section's title. */
  titleLabel: string = '';
  titleFontSize: number = 16;
  titleColor: string = CYLColor.white(0, 0.5);
}

/** Renders a `CYLMultipleFilterHeaderView` `width` wide. */
@Component
export struct CYLMultipleFilterHeaderViewComponent {
  header: CYLMultipleFilterHeaderView = new CYLMultipleFilterHeaderView();
  viewWidth: number = 0;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.header.imageView !== undefined) {
        Image(this.header.imageView)
          .accessibilityLevel('no')
          .objectFit(ImageFit.None)
          .position({ x: IMAGE_X, y: 0 })
          .width(IMAGE_SIZE)
          .height(IMAGE_SIZE)
      }
      Text(this.header.titleLabel)
        .fontSize(`${this.header.titleFontSize}fp`)
        .fontColor(this.header.titleColor)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .position({ x: TITLE_X, y: 0 })
        .width(Math.max(0, this.viewWidth - TITLE_X))
        .height(CYLMultipleFilterHeaderView.height)
      Column()
        .position({ x: TITLE_X, y: CYLMultipleFilterHeaderView.height - 0.5 })
        .width(Math.max(0, this.viewWidth - TITLE_X))
        .height(0.5)
        .backgroundColor(CYLMultipleFilterHeaderView.lineColor)
    }
    .width(this.viewWidth)
    .height(CYLMultipleFilterHeaderView.height)
    .accessibilityGroup(true)
    .accessibilityText(this.header.titleLabel)
  }
}
