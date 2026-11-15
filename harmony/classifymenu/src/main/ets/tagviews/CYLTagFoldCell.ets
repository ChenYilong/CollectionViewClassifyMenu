/**
 * The inline fold control of the tag list (iOS CYLTagFoldCell.swift; Android CYLTagFoldCell.kt): a cell among the
 * tags, after the last visible one, drawn like a tag (`CYLTagFoldButton`). The cell is the accessibility element
 * (id `CYLTagListFoldControl`), a button whose label the list sets.
 */
import { CYLMenuFoldControl } from '../core/CYLMenuFoldControl';
import { CYLMenuStyle } from '../core/CYLMenuStyle';
import { CYLTagButtonComponent } from './CYLTagButton';
import { CYLTagFoldButton } from './CYLTagFoldButton';
import { CYLTagListAccessibilityIdentifier } from './CYLTagListAccessibility';

@Observed
export class CYLTagFoldCell {
  /** The control drawn in the cell; the cell handles its taps. */
  readonly foldButton: CYLTagFoldButton = new CYLTagFoldButton();
  /** The cell's screen reader label ("<section> 更多/收起"), set by the list. */
  accessibilityLabel: string = '';
  accessibilityHint?: string;

  /** Shows `foldControl` for the expanded or collapsed state, drawn like the tags of `itemStyle`. */
  configure(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: boolean, animated: boolean): void {
    this.foldButton.applyInlineFoldControl(foldControl, itemStyle, expanded, animated);
  }
}

/** Draws a `CYLTagFoldCell`. */
@Component
export struct CYLTagFoldCellComponent {
  @ObjectLink cell: CYLTagFoldCell;
  cellWidth?: number;
  cellHeight?: number;
  onCellClick?: () => void;

  build() {
    Stack() {
      CYLTagButtonComponent({
        button: this.cell.foldButton,
        tagWidth: this.cellWidth,
        tagHeight: this.cellHeight,
        interactive: false
      })
    }
    .id(CYLTagListAccessibilityIdentifier.foldControl)
    .accessibilityGroup(true)
    .accessibilityText(this.cell.accessibilityLabel)
    .accessibilityDescription(this.cell.accessibilityHint ?? '')
    .onClick(() => this.onCellClick?.())
  }
}
