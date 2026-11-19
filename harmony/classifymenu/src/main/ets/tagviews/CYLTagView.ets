/**
 * The TagCollectionView demo view (iOS CYLTagView.swift, Views/CYLTagCell.swift, Views/CYLTagHeaderCell.swift and
 * their XIBs; Android CYLTagView.kt): groups of `CYLTagModel` from a `CYLMenuDataSource`, each with a header whose
 * button opens the group or folds it to its first row, the tags in left-aligned rows.
 *
 * `CYLTagView` holds the state and the API (as the iOS class, with its collection view data source and flow layout
 * methods); `CYLTagViewComponent` draws it.
 */
import { CYLIndexPath } from '../components/CYLTagListModel';
import { CYLMenuDataSource, CYLMenuDelegate } from '../core/CYLMenuDataSource';
import { CYLMenuLocalizedString } from '../core/CYLMenuResources';
import { CYLTagGroup, CYLTagModel, CYLTagViewCellSpacing, CYLTagViewSectionInset } from '../core/CYLTagModel';
import { CYLColor, CYLEdgeInsets, CYLFont, CYLRect, CYLSize } from '../core/CYLTypes';

/** `collectionView.contentInset.top`. */
const CONTENT_INSET_TOP: number = 35;
/** `UICollectionViewFlowLayout.minimumLineSpacing`'s default. */
const LINE_SPACING: number = 10;
/** CYLTagCell.xib: the label's blue (0, 0.478, 1), white text, alpha 0.4. */
const TAG_BACKGROUND: string = CYLColor.rgb(0, 0.47843137250000001, 1);
const TAG_TEXT_COLOR: string = CYLColor.white(1);
const TAG_LABEL_ALPHA: number = 0.40000000000000002;
/** CYLTagHeaderCell.xib: background (0.937, 0.937, 0.957), the name at 17 pt 22 from the leading edge, the button
 * at 14 pt at the trailing and top layout margins (8). */
const HEADER_BACKGROUND: string = CYLColor.rgb(0.93725490199999995, 0.93725490199999995, 0.95686274510000002);
const HEADER_NAME_FONT_SIZE: number = 17;
const HEADER_NAME_LEADING: number = 22;
const HEADER_BUTTON_FONT_SIZE: number = 14;
const HEADER_LAYOUT_MARGIN: number = 8;

/** `UICollectionView.elementKindSectionHeader`. */
export const CYLTagViewElementKindSectionHeader: string = 'UICollectionElementKindSectionHeader';

/** A tag of `CYLTagView`: a capsule label with the model's title. */
export class CYLTagCell {
  /** The tag shown. */
  model?: CYLTagModel;
  /** Where the cell is, in the view's content. */
  frame: CYLRect = new CYLRect();
  indexPath: CYLIndexPath = { section: 0, item: 0 };
  /** The title font for the text size the view measured with. */
  font: CYLFont = CYLTagModel.titleFont();

  /** The screen reader label: the title. */
  get accessibilityLabel(): string {
    return this.model?.title ?? '';
  }
}

/** Receives the taps on a group header's fold button. */
export interface CYLTagHeaderCellDelegate {
  /** The group of `headerCell` (in `section`) was opened or folded; reload the list. */
  tagHeaderCell(headerCell: CYLTagHeaderCell, section: number): void;
}

/** The header of a `CYLTagView` group: the group's name and a button that opens or folds it. */
export class CYLTagHeaderCell {
  /** The group shown. */
  group?: CYLTagGroup;
  /** Receives the taps on the fold button. */
  delegate?: CYLTagHeaderCellDelegate;
  /** Where the header is, in the view's content. */
  frame: CYLRect = new CYLRect();

  /** The fold button's title: 收起 when the group is open, else 更多. */
  get buttonTitle(): string {
    return CYLMenuLocalizedString(this.group?.isOpened ?? false ? 'CYLMenuCollapse' : 'CYLMenuExpand');
  }

  /** The fold button names the group it changes. */
  get buttonAccessibilityHint(): string {
    return this.group?.groupName ?? '';
  }

  /** Handle group button taps: toggle the group, then let the delegate reload. */
  btnClick(): void {
    const group = this.group;
    if (group === undefined) {
      return;
    }
    group.isOpened = !group.isOpened;
    this.delegate?.tagHeaderCell(this, group.section);
  }
}

@Observed
export class CYLTagView implements CYLTagHeaderCellDelegate {
  /** The insets of every group's tags. */
  static readonly sectionInset: CYLEdgeInsets = CYLTagViewSectionInset;
  /** The horizontal space between two tags of a row. */
  static readonly cellSpacing: number = CYLTagViewCellSpacing;

  /** Bumped on every change the component draws. */
  revision: number = 0;
  /** All data groups (`CYLTagGroup`). */
  groups: CYLTagGroup[] = [];
  /** The groups and their tags. */
  menuDataSource?: CYLMenuDataSource;
  /** Receives the taps on tags. */
  menuDelegate?: CYLMenuDelegate;
  /** The laid out headers and cells, from `layout()`. */
  headers: CYLTagHeaderCell[] = [];
  cells: CYLTagCell[] = [];
  contentHeight: number = 0;
  private showsHeader: boolean = true;
  private width: number = 0;
  private fontScaleValue: number = 1;

  /** `init()`: an empty view. */
  constructor() {
  }

  /** `makeTagView()` (Objective-C `+tagView`). */
  static makeTagView(): CYLTagView {
    return new CYLTagView();
  }

  /** Whether each group shows its header (default true). */
  get isShowHeader(): boolean {
    return this.showsHeader;
  }

  set isShowHeader(value: boolean) {
    this.showsHeader = value;
    this.reloadData();
  }

  /** The system font scale the tags are measured at (iOS: the content size category). */
  get fontScale(): number {
    return this.fontScaleValue;
  }

  set fontScale(value: number) {
    if (value === this.fontScaleValue) {
      return;
    }
    this.fontScaleValue = value;
    // Re-measures every tag for the text size and reloads the layout.
    this.groups.forEach((group: CYLTagGroup) => {
      group.items.forEach((model: CYLTagModel) => model.updateSize(value));
      group.invalidateRowCounts();
    });
    this.reloadData();
  }

  /** Reads the groups and their tags from the data source again. */
  reloadMenuData(): void {
    const groups: CYLTagGroup[] = [];
    const source = this.menuDataSource;
    if (source !== undefined) {
      for (let section = 0; section < source.numberOfSectionsInMenu(); section++) {
        const group = new CYLTagGroup();
        group.section = section;
        group.groupName = source.menuTitleForSection(section);
        const items: CYLTagModel[] = [];
        for (let item = 0; item < source.menuNumberOfItemsInSection(section); item++) {
          const model = new CYLTagModel(source.menuTitleForItem({ section: section, item: item }));
          model.updateSize(this.fontScaleValue);
          items.push(model);
        }
        group.items = items;
        groups.push(group);
      }
    }
    groups.forEach((group: CYLTagGroup) => group.width = this.width);
    this.groups = groups;
    this.reloadData();
  }

  /** The view's width, from the component (`layoutSubviews`). */
  setWidth(width: number): void {
    if (width === this.width) {
      return;
    }
    this.width = width;
    this.groups.forEach((group: CYLTagGroup) => group.width = width);
    this.reloadData();
  }

  // MARK: - CYLTagHeaderCellDelegate

  tagHeaderCell(headerCell: CYLTagHeaderCell, section: number): void {
    this.reloadData();
  }

  // MARK: - Data source

  numberOfSections(): number {
    return this.groups.length;
  }

  /** `numberOfVisibleItems(inSection:)`: the tags a section shows now (Android `numberOfVisibleItemsInSection`). */
  numberOfVisibleItems(section: number): number {
    return this.numberOfItemsInSection(section);
  }

  numberOfItemsInSection(section: number): number {
    const group = this.group(section);
    if (group === undefined) {
      return 0;
    }
    return group.isOpened ? group.items.length : group.firstRowCellCount(this.contentWidth());
  }

  cellForItemAt(indexPath: CYLIndexPath): CYLTagCell {
    const cell = new CYLTagCell();
    cell.model = this.model(indexPath);
    cell.indexPath = indexPath;
    cell.font = CYLTagModel.titleFont(this.fontScaleValue);
    return cell;
  }

  /** The header of a section (`kind` `CYLTagViewElementKindSectionHeader`); undefined for another kind. */
  viewForSupplementaryElementOfKind(kind: string, indexPath: CYLIndexPath): CYLTagHeaderCell | undefined {
    if (kind !== CYLTagViewElementKindSectionHeader) {
      return undefined;
    }
    const header = new CYLTagHeaderCell();
    header.delegate = this;
    header.group = this.group(indexPath.section);
    return header;
  }

  // MARK: - Delegate

  didSelectItemAt(indexPath: CYLIndexPath): void {
    this.menuDelegate?.menuDidSelectItem?.(this, indexPath);
  }

  // MARK: - Flow layout (left-aligned)

  sizeForItemAt(indexPath: CYLIndexPath): CYLSize {
    const model = this.model(indexPath);
    if (model === undefined) {
      return CYLSize.ZERO;
    }
    return new CYLSize(Math.min(Math.max(0, model.width), this.contentWidth()), model.height);
  }

  minimumInteritemSpacingForSectionAt(section: number): number {
    return CYLTagView.cellSpacing;
  }

  referenceSizeForHeaderInSection(section: number): CYLSize {
    const group = this.group(section);
    if (!this.isShowHeader || group === undefined) {
      return CYLSize.ZERO;
    }
    return new CYLSize(this.contentWidth(), group.height);
  }

  insetForSectionAt(section: number): CYLEdgeInsets {
    return CYLTagView.sectionInset;
  }

  // MARK: - Private

  /** Lays the headers and cells out as the left-aligned flow layout does, then lets the component draw them. */
  private reloadData(): void {
    const headers: CYLTagHeaderCell[] = [];
    const cells: CYLTagCell[] = [];
    let y = CONTENT_INSET_TOP;
    for (let section = 0; section < this.numberOfSections(); section++) {
      const headerSize = this.referenceSizeForHeaderInSection(section);
      if (headerSize.height > 0) {
        const header = this.viewForSupplementaryElementOfKind(CYLTagViewElementKindSectionHeader,
          { section: section, item: 0 });
        if (header !== undefined) {
          // A vertical flow layout's header spans the collection view's width.
          header.frame = new CYLRect(0, y, this.width, headerSize.height);
          headers.push(header);
        }
        y += headerSize.height;
      }
      const insets = this.insetForSectionAt(section);
      const spacing = this.minimumInteritemSpacingForSectionAt(section);
      const right = this.width - insets.right;
      y += insets.top;
      let x = insets.left;
      let rowTop = y;
      let rowHeight = 0;
      const count = this.numberOfItemsInSection(section);
      for (let item = 0; item < count; item++) {
        const indexPath: CYLIndexPath = { section: section, item: item };
        const size = this.sizeForItemAt(indexPath);
        if (item > 0 && x + size.width > right) {
          rowTop += rowHeight + LINE_SPACING;
          rowHeight = 0;
          x = insets.left;
        }
        const cell = this.cellForItemAt(indexPath);
        cell.frame = new CYLRect(x, rowTop, size.width, size.height);
        cells.push(cell);
        x += size.width + spacing;
        rowHeight = Math.max(rowHeight, size.height);
      }
      y = (count > 0 ? rowTop + rowHeight : y) + insets.bottom;
    }
    this.headers = headers;
    this.cells = cells;
    this.contentHeight = y;
    this.revision++;
  }

  private group(section: number): CYLTagGroup | undefined {
    return section >= 0 && section < this.groups.length ? this.groups[section] : undefined;
  }

  private model(indexPath: CYLIndexPath): CYLTagModel | undefined {
    const items = this.group(indexPath.section)?.items;
    if (items === undefined || indexPath.item < 0 || indexPath.item >= items.length) {
      return undefined;
    }
    return items[indexPath.item];
  }

  private contentWidth(): number {
    return Math.max(0, this.width - CYLTagView.sectionInset.left - CYLTagView.sectionInset.right);
  }
}

function cellKey(cell: CYLTagCell): string {
  return [cell.indexPath.section, cell.indexPath.item, cell.model?.title ?? '', cell.frame.x, cell.frame.y,
    cell.frame.width, cell.frame.height, cell.font.size].join('|');
}

function headerKey(header: CYLTagHeaderCell): string {
  return [header.group?.section ?? -1, header.group?.groupName ?? '', header.group?.isOpened ?? false,
    header.frame.y, header.frame.width, header.frame.height].join('|');
}

/** Draws a `CYLTagView` in a vertical scroll view. */
@Component
export struct CYLTagViewComponent {
  @ObjectLink tagView: CYLTagView;

  build() {
    Scroll() {
      Stack({ alignContent: Alignment.TopStart }) {
        if (this.tagView.revision >= 0) {
          ForEach(this.tagView.headers, (header: CYLTagHeaderCell) => {
            Stack({ alignContent: Alignment.TopStart }) {
              Text(header.group?.groupName ?? '')
                .fontSize(HEADER_NAME_FONT_SIZE)
                .fontColor(CYLColor.BLACK)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .height(header.frame.height)
                .position({ x: HEADER_NAME_LEADING, y: 0 })
              Text(header.buttonTitle)
                .fontSize(HEADER_BUTTON_FONT_SIZE)
                .fontColor(CYLColor.BLACK)
                .markAnchor({ x: '100%', y: 0 })
                .position({ x: header.frame.width - HEADER_LAYOUT_MARGIN, y: HEADER_LAYOUT_MARGIN })
                .accessibilityDescription(header.buttonAccessibilityHint)
                .onClick(() => header.btnClick())
            }
            .width(header.frame.width)
            .height(header.frame.height)
            .backgroundColor(HEADER_BACKGROUND)
            .position({ x: header.frame.x, y: header.frame.y })
          }, (header: CYLTagHeaderCell) => headerKey(header))
          ForEach(this.tagView.cells, (cell: CYLTagCell) => {
            Text(cell.model?.title ?? '')
              .fontSize(cell.font.size)
              .fontWeight(cell.font.weight)
              .fontColor(TAG_TEXT_COLOR)
              .textAlign(TextAlign.Center)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .backgroundColor(TAG_BACKGROUND)
              .opacity(TAG_LABEL_ALPHA)
              .borderRadius(cell.frame.height / 2)
              .clip(true)
              .width(cell.frame.width)
              .height(cell.frame.height)
              .position({ x: cell.frame.x, y: cell.frame.y })
              .accessibilityText(cell.accessibilityLabel)
              .onClick(() => this.tagView.didSelectItemAt(cell.indexPath))
          }, (cell: CYLTagCell) => cellKey(cell))
        }
      }
      .width('100%')
      .height(this.tagView.contentHeight)
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.tagView.setWidth(Number(newArea.width));
    })
  }
}
