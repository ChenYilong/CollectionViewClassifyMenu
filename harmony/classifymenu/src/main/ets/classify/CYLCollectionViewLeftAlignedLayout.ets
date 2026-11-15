/**
 * iOS `CYLCollectionViewLeftAlignedLayout.swift`, migrated from Android `CYLCollectionViewLeftAlignedLayout.kt`: a flow
 * layout whose rows start at the leading edge (or are centered / at the trailing edge, `rowAlignment`): items in
 * order, a new row when the next one does not fit, items centered vertically in their row, never wider than the
 * section's content width. ArkUI has no collection view layout object, so `frames` places one section's items (vp).
 */
import { CYLTagRowAlignment } from '../core/CYLMenuStyle';
import { CYLEdgeInsets, CYLRect, CYLSize } from '../core/CYLTypes';

/**
 * `UICollectionViewDelegateLeftAlignedLayout`: the delegate of the left-aligned layout. Like iOS (an empty refinement
 * of the flow layout delegate) it declares nothing of its own; the menus answer the flow-layout questions themselves
 * (`sizeForItemAt`, `insetForSectionAt`, `minimumInteritemSpacingForSectionAt`).
 */
export interface UICollectionViewDelegateLeftAlignedLayout {
  /** Flow-layout `collectionView(_:layout:insetForSectionAt:)`, when the delegate answers it. */
  insetForSectionAt?: (section: number) => CYLEdgeInsets;
}

/** The frames of one section's items and the bottom of its last row (before the bottom inset). */
export class CYLLeftAlignedSectionFrames {
  readonly frames: CYLRect[];
  readonly bottom: number;

  constructor(frames: CYLRect[], bottom: number) {
    this.frames = frames;
    this.bottom = bottom;
  }
}

export class CYLCollectionViewLeftAlignedLayout {
  /** The flow layout's default `minimumLineSpacing`, the space between rows. */
  static readonly defaultLineSpacing: number = 10;

  /** Leading (the default), centered or trailing. */
  rowAlignment: CYLTagRowAlignment = CYLTagRowAlignment.leading;

  /**
   * The frames of items of `sizes` in a section that starts at `top`, `width` wide, with `insets`, the spacing between
   * items and between rows.
   */
  frames(sizes: CYLSize[], top: number, width: number, insets: CYLEdgeInsets, interitemSpacing: number,
    lineSpacing: number = CYLCollectionViewLeftAlignedLayout.defaultLineSpacing,
    rightToLeft: boolean = false): CYLLeftAlignedSectionFrames {
    const contentWidth = Math.max(0, width - insets.left - insets.right);
    const rows: number[][] = [];
    let row: number[] = [];
    let used = 0;
    for (let index = 0; index < sizes.length; index++) {
      const itemWidth = Math.min(sizes[index].width, contentWidth);
      if (row.length > 0 && used + interitemSpacing + itemWidth > contentWidth) {
        rows.push(row);
        row = [];
        used = 0;
      }
      used += (row.length > 0 ? interitemSpacing : 0) + itemWidth;
      row.push(index);
    }
    if (row.length > 0) {
      rows.push(row);
    }
    const frames: CYLRect[] = [];
    let y = top + insets.top;
    for (let rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      const items = rows[rowIndex];
      let rowHeight = 0;
      let rowWidth = interitemSpacing * (items.length - 1);
      for (const index of items) {
        rowHeight = Math.max(rowHeight, sizes[index].height);
        rowWidth += Math.min(sizes[index].width, contentWidth);
      }
      const free = Math.max(0, contentWidth - rowWidth);
      let x = insets.left;
      if (this.rowAlignment === CYLTagRowAlignment.center) {
        x += Math.floor(free / 2);
      } else if (this.rowAlignment === CYLTagRowAlignment.trailing) {
        x += free;
      }
      for (const index of items) {
        const size = sizes[index];
        const itemWidth = Math.min(size.width, contentWidth);
        const frameX = rightToLeft ? width - x - itemWidth : x;
        frames.push(new CYLRect(frameX, y + (rowHeight - size.height) / 2, itemWidth, size.height));
        x += itemWidth + interitemSpacing;
      }
      y += rowHeight + (rowIndex < rows.length - 1 ? lineSpacing : 0);
    }
    return new CYLLeftAlignedSectionFrames(frames, y);
  }
}
