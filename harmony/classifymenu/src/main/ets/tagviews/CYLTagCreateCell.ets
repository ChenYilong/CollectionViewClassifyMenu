/**
 * The "+ 新建标签" item of the tag list (iOS CYLTagCreateCell.swift; Android CYLTagCreateCell.kt;
 * `CYLMenuItemType.create`): an outlined tag with a plus icon, an action rather than a tag (never selected). Draw it
 * with `CYLTagListCellComponent`.
 */
import { CYLTagCreateItem } from '../components/CYLTagListState';
import { CYLMenuStyle } from '../core/CYLMenuStyle';
import { CYLImage } from '../core/CYLTypes';
import { CYLTagListAccessibilityIdentifier } from './CYLTagListAccessibility';
import { CYLTagListCell } from './CYLTagListCell';

@Observed
export class CYLTagCreateCell extends CYLTagListCell {
  /** The plus icon of the core resources (drawn in the icon color). */
  static get plusImage(): CYLImage {
    return CYLTagCreateItem.plusImage;
  }

  /** "新建标签" for an empty name, "新建标签：<name>" otherwise. */
  static title(name?: string): string {
    return CYLTagCreateItem.title(name);
  }

  /** The outlined look of the item, from a list (or section) style. */
  static outlinedStyle(style: CYLMenuStyle): CYLMenuStyle {
    return CYLTagCreateItem.outlinedStyle(style);
  }

  /** `configure(name:style:isEnabled:)`: "+ 新建标签" or "+ 新建标签：<name>" in `style` (already outlined). */
  configureCreate(name: string | undefined, style: CYLMenuStyle, isEnabled: boolean): void {
    this.configure(CYLTagCreateCell.title(name), CYLTagCreateCell.plusImage, undefined, undefined, style, false,
      isEnabled);
    // An action, not a tag: never "selected".
    this.accessibilitySelected = false;
    this.accessibilityIdentifier = CYLTagListAccessibilityIdentifier.createItem;
    this.revision++;
  }
}
