/**
 * iOS `CYLFilterHeaderView.swift`, migrated from Android `CYLClassifyMenu.kt`: a section header of the classify menu:
 * the section's title (and image), a "more" button that expands or folds the section, and a separator line at the
 * bottom.
 */
import { CYLColor, CYLControlState, CYLRect } from '../core/CYLTypes';
import { CYLContentHorizontalAlignment, CYLIndexPathButton, CYLIndexPathButtonView } from './CYLIndexPathButton';
import { CYLRightImageButton, CYLRightImageButtonView } from './CYLRightImageButton';

/** Receives the taps on a section header's "more" button. */
export interface CYLFilterHeaderViewDelegate {
  /** `filterHeaderView(_:didTapMoreButton:)`: `moreButton` is passed so the delegate can toggle its selection. */
  filterHeaderViewDidTapMoreButton(headerView: CYLFilterHeaderView, moreButton: CYLRightImageButton): void;
}

/** The frames of a header's subviews at a width and height. */
export class CYLFilterHeaderLayout {
  readonly titleButton: CYLRect;
  readonly moreButton: CYLRect;
  readonly separator: CYLRect;

  constructor(titleButton: CYLRect, moreButton: CYLRect, separator: CYLRect) {
    this.titleButton = titleButton;
    this.moreButton = moreButton;
    this.separator = separator;
  }
}

const MORE_BUTTON_WIDTH: number = 72;
const SEPARATOR_HEIGHT: number = 0.5;
const SEPARATOR_INSET: number = 16;

export class CYLFilterHeaderView {
  /** The header's height in the menu. */
  static readonly defaultHeight: number = 38;
  static readonly separatorColor: string = CYLColor.rgb(188 / 255, 188 / 255, 188 / 255);

  /** The section's title (and image). */
  readonly titleButton: CYLIndexPathButton = new CYLIndexPathButton();
  /** Expands or folds the section; hidden by default. */
  readonly moreButton: CYLRightImageButton = new CYLRightImageButton();
  /** Receives the taps on `moreButton`. */
  delegate: CYLFilterHeaderViewDelegate | undefined = undefined;
  backgroundColor: string = CYLColor.WHITE;

  constructor() {
    this.titleButton.titleLeadingInset = 16;
    this.titleButton.contentHorizontalAlignment = CYLContentHorizontalAlignment.left;
    this.titleButton.setTitleColor(CYLColor.BLACK, CYLControlState.NORMAL);
    this.titleButton.setTitleColor(CYLColor.BLACK, CYLControlState.SELECTED);
    this.moreButton.isHidden = true;
  }

  /** `moreButtonTapped`: tells the delegate. */
  moreButtonTapped(): void {
    this.delegate?.filterHeaderViewDidTapMoreButton(this, this.moreButton);
  }

  /** iOS `layoutButtons()`. */
  layout(width: number, height: number = CYLFilterHeaderView.defaultHeight): CYLFilterHeaderLayout {
    const moreWidth = Math.min(MORE_BUTTON_WIDTH, Math.max(0, width - 28));
    const moreX = Math.max(16, width - 12 - moreWidth);
    return new CYLFilterHeaderLayout(
      new CYLRect(16, 0, Math.max(0, moreX - 24), height),
      new CYLRect(moreX, 0, moreWidth, height),
      new CYLRect(SEPARATOR_INSET, Math.max(0, height - SEPARATOR_HEIGHT), Math.max(0, width - 2 * SEPARATOR_INSET),
        SEPARATOR_HEIGHT));
  }
}

/** Renders a `CYLFilterHeaderView` `width` wide. */
@Component
export struct CYLFilterHeaderViewComponent {
  header: CYLFilterHeaderView = new CYLFilterHeaderView();
  viewWidth: number = 0;
  viewHeight: number = CYLFilterHeaderView.defaultHeight;

  build() {
    Stack() {
      Column() {
        CYLIndexPathButtonView({ button: this.header.titleButton })
      }
      .position({ x: this.header.layout(this.viewWidth, this.viewHeight).titleButton.x, y: 0 })
      .width(this.header.layout(this.viewWidth, this.viewHeight).titleButton.width)
      .height(this.viewHeight)

      Column() {
        CYLRightImageButtonView({ button: this.header.moreButton, onTap: () => this.header.moreButtonTapped() })
      }
      .position({ x: this.header.layout(this.viewWidth, this.viewHeight).moreButton.x, y: 0 })
      .width(this.header.layout(this.viewWidth, this.viewHeight).moreButton.width)
      .height(this.viewHeight)

      Column()
        .position({
          x: this.header.layout(this.viewWidth, this.viewHeight).separator.x,
          y: this.header.layout(this.viewWidth, this.viewHeight).separator.y
        })
        .width(this.header.layout(this.viewWidth, this.viewHeight).separator.width)
        .height(this.header.layout(this.viewWidth, this.viewHeight).separator.height)
        .backgroundColor(CYLFilterHeaderView.separatorColor)
    }
    .width(this.viewWidth)
    .height(this.viewHeight)
    .backgroundColor(this.header.backgroundColor)
  }
}
