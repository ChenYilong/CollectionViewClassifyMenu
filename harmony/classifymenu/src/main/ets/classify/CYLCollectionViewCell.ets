import { CYLAccessibilitySelectedModifier } from '../core/CYLAccessibilitySelected';
/**
 * iOS `CYLCollectionViewCell.swift`, migrated from Android `CYLClassifyMenu.kt`: a tag cell of the classify menu, one
 * `CYLIndexPathButton` in the `chengNi` look that fills the cell.
 */
import { CYLCollectionCellButtonStyle, CYLIndexPathButton, CYLIndexPathButtonView } from './CYLIndexPathButton';

export class CYLCollectionViewCell {
  /** The tag's button, as large as the cell. */
  readonly button: CYLIndexPathButton = new CYLIndexPathButton();
  /** The section of the tag the cell shows. */
  section: number = 0;
  /** The row (item) of the tag the cell shows. */
  row: number = 0;
  /** Whether the cell's tag is shown (kept for layouts that hide tags). */
  shouldShow: boolean = false;

  constructor() {
    this.button.cylApply(CYLCollectionCellButtonStyle.chengNi);
  }
}

/** Renders a `CYLCollectionViewCell` filling its parent. */
@Component
export struct CYLCollectionViewCellView {
  cell: CYLCollectionViewCell = new CYLCollectionViewCell();
  onTap?: (button: CYLIndexPathButton) => void;

  build() {
    Stack() {
      CYLIndexPathButtonView({ button: this.cell.button, onTap: this.onTap })
    }
    .width('100%')
    .height('100%')
    .attributeModifier(new CYLAccessibilitySelectedModifier(this.cell.button.isSelected))
  }
}
