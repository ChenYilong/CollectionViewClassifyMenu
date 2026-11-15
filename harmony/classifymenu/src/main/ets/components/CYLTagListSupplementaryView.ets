/**
 * A section header or footer of the tag list (iOS `CYLTagListHeaderView` / `CYLTagListFooterView`), as the object
 * the list draws it from: `CYLTagListState.viewForSupplementaryElementOfKind(kind, indexPath)` returns it. The list
 * configures it from its data source and style when that data changes (a reload, a fold, a style); changes made to it
 * in between are drawn: call `setNeedsDisplay()` after changing it.
 */
import { CYLTagButtonPart } from '../tagviews/CYLTagButton';
import { CYLColor, CYLImage } from '../core/CYLTypes';

/** `UICollectionView.elementKindSectionHeader`. */
export const CYLTagListElementKindSectionHeader: string = 'UICollectionElementKindSectionHeader';
/** `UICollectionView.elementKindSectionFooter`. */
export const CYLTagListElementKindSectionFooter: string = 'UICollectionElementKindSectionFooter';

export class CYLTagListSupplementaryView {
  readonly kind: string;
  section: number = 0;
  /** The section title (`isHidden` when section titles are hidden). Header only. */
  readonly titleLabel: CYLTagButtonPart = new CYLTagButtonPart();
  /** The section icon (`menuImageForSection`). Header only. */
  readonly iconView: CYLTagButtonPart = new CYLTagButtonPart();
  /** The bar before the title; undefined: none. */
  indicatorColor?: string;
  indicatorWidth: number = 3;
  indicatorHeight: number = 16;
  horizontalInset: number = 16;
  /** The fold control (in a header, or the footer's only content). */
  showsFoldButton: boolean = false;
  foldAtLeadingEdge: boolean = false;
  /** The More button. */
  showsMoreButton: boolean = false;
  moreImage?: ResourceStr;
  moreColor: string = CYLColor.GRAY;
  moreAccessibilityLabel: string = '';
  accessoryView?: WrappedBuilder<[number]>;
  /** The inputs it was last configured from (the list reconfigures it only when they change). */
  configuredInputs: string = '';
  private displayHandler?: () => void;

  constructor(kind: string) {
    this.kind = kind;
    this.titleLabel.textColor = CYLColor.GRAY;
  }

  /** Called by the list that draws it. */
  setDisplayHandler(handler: (() => void) | undefined): void {
    this.displayHandler = handler;
  }

  /** Draws the changes made to it. */
  setNeedsDisplay(): void {
    this.displayHandler?.();
  }

  /** The icon's image. */
  get icon(): CYLImage | undefined {
    return this.iconView.image;
  }
}
