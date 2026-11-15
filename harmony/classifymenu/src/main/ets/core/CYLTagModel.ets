/**
 * The tag models of the TagCollectionView demo, as iOS `CYLTagModel.swift` and `CYLTagGroup.swift`: a title sized
 * with the 17 pt system font (plus 50 vp of padding), and a group of them laid out in rows of `CYLTagView`'s width.
 */
import { MeasureText } from '@kit.ArkUI';
import { CYLTagMetrics } from './CYLTagMetrics';
import { CYLEdgeInsets, CYLFont } from './CYLTypes';

const TITLE_FONT_SIZE: number = 17;
const MINIMUM_HEIGHT: number = 35;
const HORIZONTAL_PADDING: number = 50;

/** `CYLTagView.sectionInset`: the insets of the tag view's sections. */
export const CYLTagViewSectionInset: CYLEdgeInsets = new CYLEdgeInsets(12, 16, 10, 16);
/** `CYLTagView.cellSpacing`: the spacing between tags and rows. */
export const CYLTagViewCellSpacing: number = 12;
/** The width a group lays out in when it has none (iOS: the screen width), vp. */
export const CYLTagDefaultListWidth: number = 360;

export class CYLTagModel {
  private storedTitle: string;
  private storedWidth: number = 0;
  private storedHeight: number = 0;

  constructor(title: string) {
    this.storedTitle = title;
    this.updateSize();
  }

  get title(): string {
    return this.storedTitle;
  }

  set title(value: string) {
    this.storedTitle = value;
    this.updateSize();
  }

  get width(): number {
    return this.storedWidth;
  }

  get height(): number {
    return this.storedHeight;
  }

  /** The title font at the system font scale `fontScale`. */
  static titleFont(fontScale: number = 1): CYLFont {
    return CYLTagMetrics.scaledSystemFont(TITLE_FONT_SIZE, fontScale);
  }

  /** Measures the title: its width plus the padding, and the tag height of the font. */
  updateSize(fontScale: number = 1): void {
    const font = CYLTagModel.titleFont(fontScale);
    const widthPx = Number(MeasureText.measureText({ textContent: this.storedTitle, fontSize: `${font.size}fp` }));
    this.storedWidth = Math.ceil(px2vp(widthPx)) + HORIZONTAL_PADDING;
    this.storedHeight = CYLTagMetrics.tagHeight(font, MINIMUM_HEIGHT);
  }
}

export class CYLTagGroup {
  groupName: string = '';
  width: number = 0;
  height: number = 38;
  isOpened: boolean = false;
  section: number = 0;
  private storedItems: CYLTagModel[] = [];
  private cachedCounts?: number[];

  get items(): CYLTagModel[] {
    return this.storedItems;
  }

  set items(value: CYLTagModel[]) {
    this.storedItems = value;
    this.cachedCounts = undefined;
  }

  /** The number of tags in each row at the group's width. */
  get cellCountsPerRow(): number[] {
    if (this.cachedCounts === undefined) {
      this.cachedCounts = CYLTagGroup.countsPerRow(this.storedItems, this.defaultContentWidth());
    }
    return this.cachedCounts;
  }

  invalidateRowCounts(): void {
    this.cachedCounts = undefined;
  }

  firstRowCellCount(contentWidth: number): number {
    const counts = CYLTagGroup.countsPerRow(this.storedItems, Math.max(0, contentWidth));
    return counts.length > 0 ? counts[0] : 0;
  }

  private defaultContentWidth(): number {
    const listWidth = this.width > 0 ? this.width : CYLTagDefaultListWidth;
    return Math.max(0, listWidth - CYLTagViewSectionInset.left - CYLTagViewSectionInset.right);
  }

  private static countsPerRow(items: CYLTagModel[], contentWidth: number): number[] {
    const counts: number[] = [];
    let used = 0;
    let count = 0;
    items.forEach((model: CYLTagModel) => {
      const width = Math.min(Math.max(0, model.width), contentWidth);
      if (count > 0 && used + CYLTagViewCellSpacing + width > contentWidth) {
        counts.push(count);
        count = 0;
        used = 0;
      }
      used += (count > 0 ? CYLTagViewCellSpacing : 0) + width;
      count += 1;
    });
    if (count > 0) {
      counts.push(count);
    }
    return counts;
  }
}
