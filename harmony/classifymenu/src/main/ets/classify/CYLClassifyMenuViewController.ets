import { CYLUIContext } from '../core/CYLUIContext';
/**
 * iOS `CYLClassifyMenuViewController.swift`, migrated from Android `CYLClassifyMenu.kt`: a single-choice classify
 * menu: sections of tags from `menuDataSource`, each folded to `defaultVisibleRows` rows with a "more" button, an
 * optional header above and footer below the tags in one scroll view. Taps are reported to `menuDelegate`.
 * The logic lives in `CYLClassifyMenuViewController`; `CYLClassifyMenuView` renders it.
 */
import { CYLIndexPath } from '../components/CYLTagListModel';
import { CYLTagButtonMetrics } from '../components/CYLTagListState';
import { CYLMenuDataSource, CYLMenuDelegate } from '../core/CYLMenuDataSource';
import { CYLMenuLocalizedString } from '../core/CYLMenuResources';
import { CYLTagMetrics } from '../core/CYLTagMetrics';
import { CYLColor, CYLControlState, CYLEdgeInsets, CYLFont, CYLImage, CYLRect, CYLSize } from '../core/CYLTypes';
import { CYLCollectionViewCell, CYLCollectionViewCellView } from './CYLCollectionViewCell';
import { CYLCollectionViewLeftAlignedLayout } from './CYLCollectionViewLeftAlignedLayout';
import { CYLFilterHeaderView, CYLFilterHeaderViewComponent, CYLFilterHeaderViewDelegate } from './CYLFilterHeaderView';
import { CYLRightImageButton } from './CYLRightImageButton';

const CELLS_HORIZONTAL_MARGIN: number = 12;
const CELL_HEIGHT: number = 30;
const ITEM_BUTTON_IMAGE_TO_TEXT_MARGIN: number = 5;
const COLLECTION_VIEW_TO_LEFT_MARGIN: number = 16;
const COLLECTION_VIEW_TO_TOP_MARGIN: number = 12;
const COLLECTION_VIEW_TO_RIGHT_MARGIN: number = 16;
const COLLECTION_VIEW_TO_BOTTOM_MARGIN: number = 10;
const CELL_BUTTON_CENTER_TO_BORDER_MARGIN: number = 19;
/** The collection view's `contentInset.top`. */
const CONTENT_INSET_TOP: number = 15;
/** The extra height of the scroll view's content below the footer. */
const BACKGROUND_EXTRA_HEIGHT: number = 64;
const HEADER_HEIGHT: number = 38;

/** `UICollectionView.elementKindSectionHeader`. */
export const CYLElementKindSectionHeader: string = 'UICollectionElementKindSectionHeader';

/** An item of `dataSource`: `kDataSourceCellTextKey` and, when it has one, `kDataSourceCellPictureKey`. */
class CYLMenuItemEntry {
  readonly text: string;
  readonly image: CYLImage | undefined;

  constructor(text: string, image: CYLImage | undefined) {
    this.text = text;
    this.image = image;
  }
}

/** A section of `dataSource`: `Type` (the title) and `kDataSourceSectionKey` (the items). */
class CYLMenuSectionEntry {
  readonly type: string;
  readonly items: CYLMenuItemEntry[];

  constructor(type: string, items: CYLMenuItemEntry[]) {
    this.type = type;
    this.items = items;
  }
}

/** A header placed in the menu. */
export class CYLClassifyMenuHeaderFrame {
  readonly key: string;
  readonly header: CYLFilterHeaderView;
  readonly frame: CYLRect;

  constructor(key: string, header: CYLFilterHeaderView, frame: CYLRect) {
    this.key = key;
    this.header = header;
    this.frame = frame;
  }
}

/** A cell placed in the menu. */
export class CYLClassifyMenuCellFrame {
  readonly key: string;
  readonly cell: CYLCollectionViewCell;
  readonly frame: CYLRect;

  constructor(key: string, cell: CYLCollectionViewCell, frame: CYLRect) {
    this.key = key;
    this.cell = cell;
    this.frame = frame;
  }
}

/** The menu's headers and cells at a width, and the collection view's height. */
export class CYLClassifyMenuLayout {
  readonly headers: CYLClassifyMenuHeaderFrame[];
  readonly cells: CYLClassifyMenuCellFrame[];
  readonly collectionHeight: number;

  constructor(headers: CYLClassifyMenuHeaderFrame[], cells: CYLClassifyMenuCellFrame[], collectionHeight: number) {
    this.headers = headers;
    this.cells = cells;
    this.collectionHeight = collectionHeight;
  }
}

export class CYLClassifyMenuViewController implements CYLFilterHeaderViewDelegate {
  /** The menu's sections and tags. */
  menuDataSource: CYLMenuDataSource | undefined = undefined;
  /** Receives the taps on tags. */
  menuDelegate: CYLMenuDelegate | undefined = undefined;
  /** A view above the tags, in the same scroll view. */
  menuHeaderView: WrappedBuilder<[]> | undefined = undefined;
  /** The system font scale the tags are measured at. */
  fontScale: number = 1;
  /** The navigation title ("Categories", localized). */
  readonly title: string = CYLMenuLocalizedString('CYLMenuTitle');

  private footer: WrappedBuilder<[]> | undefined = undefined;
  private selected: CYLIndexPath | undefined = undefined;
  private defaultVisibleRowsStorage: number = 0;
  private dataSource: CYLMenuSectionEntry[] = [];
  private expandSectionArray: Set<number> = new Set<number>();
  /** Per section: the number of tags in each row; undefined recomputes it. */
  private cellsCountPerRow: number[][] | undefined = undefined;
  private collectionWidth: number = 0;
  private listeners: (() => void)[] = [];
  private loaded: boolean = false;

  /** `init()`: a menu; set the data source, then show it with `CYLClassifyMenuView`. */
  constructor() {
  }

  /**
   * A view below the tags, in the same scroll view, e.g. the results of the selected tag; as wide as the menu, as
   * high as its content. Call `updateMenuLayout()` after its content changes.
   */
  get menuFooterView(): WrappedBuilder<[]> | undefined {
    return this.footer;
  }

  set menuFooterView(value: WrappedBuilder<[]> | undefined) {
    this.footer = value;
    this.updateMenuLayout();
  }

  /**
   * The tag shown as selected (single choice), or undefined. Taps are reported to the menu delegate and do not change
   * it: set it from `menuDidSelectItem`.
   */
  get selectedIndexPath(): CYLIndexPath | undefined {
    return this.selected;
  }

  set selectedIndexPath(value: CYLIndexPath | undefined) {
    this.selected = value;
    this.notify();
  }

  /** The rows each section shows before its "more" button (at least 1, the default). */
  get defaultVisibleRows(): number {
    return this.defaultVisibleRowsStorage === 0 ? 1 : this.defaultVisibleRowsStorage;
  }

  set defaultVisibleRows(value: number) {
    this.defaultVisibleRowsStorage = Math.max(1, Math.floor(value));
    this.notify();
  }

  /** Reads the sections and tags from the data source again and folds every section. */
  reloadMenuData(): void {
    this.initData();
    this.expandSectionArray.clear();
    this.notify();
  }

  /** Lays the tags, the header and the footer out again, e.g. after the footer's content changed. */
  updateMenuLayout(): void {
    this.notify();
  }

  // UICollectionViewDataSource

  numberOfSections(): number {
    return this.dataSource.length;
  }

  numberOfItemsInSection(section: number): number {
    if (section < 0 || section >= this.dataSource.length) {
      return 0;
    }
    if (this.expandSectionArray.has(section)) {
      return this.dataSource[section].items.length;
    }
    return this.firstRowsCellCount(section);
  }

  /** `collectionView(_:cellForItemAt:)`: a configured cell for the item. */
  cellForItemAt(indexPath: CYLIndexPath): CYLCollectionViewCell {
    const cell = new CYLCollectionViewCell();
    const button = cell.button;
    const item = this.dataSource[indexPath.section].items[indexPath.item];
    if (item.image !== undefined) {
      button.setImage(item.image, CYLControlState.NORMAL);
      button.imageTitleSpacing = ITEM_BUTTON_IMAGE_TO_TEXT_MARGIN;
    } else {
      button.setImage(undefined, CYLControlState.NORMAL);
      button.imageTitleSpacing = 0;
    }
    button.font = this.tagFont();
    button.setTitle(item.text, CYLControlState.NORMAL);
    button.setTitle(item.text, CYLControlState.SELECTED);
    button.section = indexPath.section;
    button.row = indexPath.item;
    cell.section = indexPath.section;
    cell.row = indexPath.item;
    cell.shouldShow = true;
    button.isSelected = this.isSelected(indexPath);
    return cell;
  }

  /** `collectionView(_:viewForSupplementaryElementOfKind:at:)`: the section's header (headers only). */
  viewForSupplementaryElementOfKind(kind: string, indexPath: CYLIndexPath): CYLFilterHeaderView | undefined {
    if (kind !== CYLElementKindSectionHeader) {
      return undefined;
    }
    const section = indexPath.section;
    const header = new CYLFilterHeaderView();
    const sectionTitle = this.dataSource[section]?.type;
    header.moreButton.isHidden = this.moreButtonHidden(section);
    header.delegate = this;
    header.titleButton.tag = section;
    header.moreButton.tag = section;
    header.moreButton.isSelected = this.expandSectionArray.has(section);
    header.titleButton.isAccessibilityHeader = true;
    header.moreButton.accessibilityHint = sectionTitle;
    header.titleButton.setTitle(sectionTitle, CYLControlState.NORMAL);
    header.titleButton.setTitle(sectionTitle, CYLControlState.SELECTED);
    const source = this.menuDataSource;
    const sectionImage = source?.menuImageForSection ? source.menuImageForSection(section) : undefined;
    header.titleButton.setImage(sectionImage, CYLControlState.NORMAL);
    return header;
  }

  // UICollectionViewDelegate

  didSelectItemAt(indexPath: CYLIndexPath): void {
    this.menuDelegate?.menuDidSelectItem?.(this, indexPath);
  }

  // CYLFilterHeaderViewDelegate

  filterHeaderViewDidTapMoreButton(headerView: CYLFilterHeaderView, moreButton: CYLRightImageButton): void {
    moreButton.isSelected = !moreButton.isSelected;
    if (moreButton.isSelected) {
      this.expandSectionArray.add(moreButton.tag);
    } else {
      this.expandSectionArray.delete(moreButton.tag);
    }
    this.notify();
  }

  // UICollectionViewDelegateFlowLayout (left-aligned layout)

  sizeForItemAt(indexPath: CYLIndexPath): CYLSize {
    return new CYLSize(this.cellWidth(this.dataSource[indexPath.section].items[indexPath.item]), this.cellHeight());
  }

  minimumInteritemSpacingForSectionAt(section: number): number {
    return CELLS_HORIZONTAL_MARGIN;
  }

  referenceSizeForHeaderInSection(section: number): CYLSize {
    return new CYLSize(Math.max(0, this.collectionWidth - 50), HEADER_HEIGHT);
  }

  insetForSectionAt(section: number): CYLEdgeInsets {
    return new CYLEdgeInsets(COLLECTION_VIEW_TO_TOP_MARGIN, COLLECTION_VIEW_TO_LEFT_MARGIN,
      COLLECTION_VIEW_TO_BOTTOM_MARGIN, COLLECTION_VIEW_TO_RIGHT_MARGIN);
  }

  // Rendering

  /** Called by the view when the menu changes; returns a function that removes the listener. */
  addListener(listener: () => void): () => void {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter((other: () => void) => other !== listener);
    };
  }

  /** The view's width changed (`viewDidLayoutSubviews`): measures every tag again. */
  setCollectionWidth(width: number): void {
    if (!this.loaded) {
      // viewDidLoad
      this.loaded = true;
      this.initData();
    }
    if (width > 0 && width !== this.collectionWidth) {
      this.collectionWidth = width;
      this.cellsCountPerRow = undefined;
    }
  }

  /** The headers and cells of the menu (the flow layout's `prepare()`), with the collection view's height. */
  layout(): CYLClassifyMenuLayout {
    const layout = new CYLCollectionViewLeftAlignedLayout();
    const width = this.collectionWidth;
    const headers: CYLClassifyMenuHeaderFrame[] = [];
    const cells: CYLClassifyMenuCellFrame[] = [];
    let y = 0;
    for (let section = 0; section < this.numberOfSections(); section++) {
      const header = this.viewForSupplementaryElementOfKind(CYLElementKindSectionHeader, { section: section, item: 0 });
      const headerHeight = this.referenceSizeForHeaderInSection(section).height;
      if (header !== undefined) {
        headers.push(new CYLClassifyMenuHeaderFrame(`h${section}`, header, new CYLRect(0, y, width, headerHeight)));
      }
      y += headerHeight;
      const sizes: CYLSize[] = [];
      const count = this.numberOfItemsInSection(section);
      for (let item = 0; item < count; item++) {
        sizes.push(this.sizeForItemAt({ section: section, item: item }));
      }
      const insets = this.insetForSectionAt(section);
      const placed = layout.frames(sizes, y, width, insets, this.minimumInteritemSpacingForSectionAt(section));
      for (let item = 0; item < count; item++) {
        const indexPath: CYLIndexPath = { section: section, item: item };
        cells.push(new CYLClassifyMenuCellFrame(`c${section}-${item}`, this.cellForItemAt(indexPath),
          placed.frames[item]));
      }
      y = (count === 0 ? y + insets.top : placed.bottom) + insets.bottom;
    }
    return new CYLClassifyMenuLayout(headers, cells,
      y + COLLECTION_VIEW_TO_TOP_MARGIN + COLLECTION_VIEW_TO_BOTTOM_MARGIN);
  }

  // Private

  private notify(): void {
    for (const listener of this.listeners) {
      listener();
    }
  }

  private initData(): void {
    this.cellsCountPerRow = undefined;
    const sections: CYLMenuSectionEntry[] = [];
    const source = this.menuDataSource;
    if (source !== undefined) {
      for (let section = 0; section < source.numberOfSectionsInMenu(); section++) {
        const items: CYLMenuItemEntry[] = [];
        for (let item = 0; item < source.menuNumberOfItemsInSection(section); item++) {
          const indexPath: CYLIndexPath = { section: section, item: item };
          const image = source.menuImageForItem ? source.menuImageForItem(indexPath) : undefined;
          items.push(new CYLMenuItemEntry(source.menuTitleForItem(indexPath), image));
        }
        sections.push(new CYLMenuSectionEntry(source.menuTitleForSection(section), items));
      }
    }
    this.dataSource = sections;
  }

  private isSelected(indexPath: CYLIndexPath): boolean {
    const selected = this.selected;
    return selected !== undefined && selected.section === indexPath.section && selected.item === indexPath.item;
  }

  private rowsOf(section: number): number[] {
    if (this.cellsCountPerRow === undefined) {
      this.cellsCountPerRow = this.dataSource.map((entry: CYLMenuSectionEntry) => this.cellsInPerRow(entry.items));
    }
    return this.cellsCountPerRow[section] ?? [];
  }

  /** `cyl_judgeMoreButtonShowWhenDefaultRowsCount:`: the "more" button shows when the section has more rows. */
  private moreButtonHidden(section: number): boolean {
    return this.rowsOf(section).length <= this.defaultVisibleRows;
  }

  /** The tags a folded section shows: those of its first `defaultVisibleRows` rows. */
  private firstRowsCellCount(section: number): number {
    let count = 0;
    this.rowsOf(section).slice(0, this.defaultVisibleRows).forEach((cells: number) => {
      count += cells;
    });
    return count;
  }

  private cellsInPerRow(items: CYLMenuItemEntry[]): number[] {
    const availableWidth = Math.max(0, this.collectionWidth - COLLECTION_VIEW_TO_LEFT_MARGIN -
      COLLECTION_VIEW_TO_RIGHT_MARGIN);
    let usedWidth = 0;
    let count = 0;
    const cellCounts: number[] = [];
    for (const item of items) {
      const width = this.cellWidth(item);
      if (count > 0 && usedWidth + CELLS_HORIZONTAL_MARGIN + width > availableWidth) {
        cellCounts.push(count);
        count = 0;
        usedWidth = 0;
      }
      usedWidth += (count > 0 ? CELLS_HORIZONTAL_MARGIN : 0) + width;
      count++;
    }
    if (count > 0) {
      cellCounts.push(count);
    }
    return cellCounts;
  }

  private tagFont(): CYLFont {
    return CYLTagMetrics.titleFont(this.fontScale);
  }

  private cellHeight(): number {
    return CYLTagMetrics.tagHeight(this.tagFont(), CELL_HEIGHT);
  }

  private cellWidth(item: CYLMenuItemEntry): number {
    const textWidth = CYLTagButtonMetrics.textMeasurer(item.text, this.tagFont());
    const margin = item.image !== undefined ? CELL_BUTTON_CENTER_TO_BORDER_MARGIN * 2 :
      CELL_BUTTON_CENTER_TO_BORDER_MARGIN;
    const limitWidth = Math.max(0, this.collectionWidth - COLLECTION_VIEW_TO_LEFT_MARGIN -
      COLLECTION_VIEW_TO_RIGHT_MARGIN);
    return Math.min(Math.ceil(textWidth) + margin, limitWidth);
  }
}

/** Renders a `CYLClassifyMenuViewController`: the header, the sections of tags and the footer in a scroll view. */
@Component
export struct CYLClassifyMenuView {
  controller: CYLClassifyMenuViewController = new CYLClassifyMenuViewController();
  @State private version: number = 0;
  @State private menuLayout: CYLClassifyMenuLayout = new CYLClassifyMenuLayout([], [], 0);
  @State private viewWidth: number = 0;
  private removeListener?: () => void;

  aboutToAppear(): void {
    CYLUIContext.remember(this.getUIContext());
    this.removeListener = this.controller.addListener(() => this.relayout());
  }

  aboutToDisappear(): void {
    if (this.removeListener !== undefined) {
      this.removeListener();
    }
  }

  private relayout(): void {
    this.controller.setCollectionWidth(this.viewWidth);
    this.menuLayout = this.controller.layout();
    this.version++;
  }

  build() {
    Scroll() {
      Column() {
        if (this.controller.menuHeaderView !== undefined) {
          this.controller.menuHeaderView.builder()
        }
        Stack({ alignContent: Alignment.TopStart }) {
          ForEach(this.menuLayout.headers, (entry: CYLClassifyMenuHeaderFrame) => {
            Column() {
              CYLFilterHeaderViewComponent({ header: entry.header, viewWidth: entry.frame.width, viewHeight: entry.frame.height })
            }
            .position({ x: entry.frame.x, y: entry.frame.y + CONTENT_INSET_TOP })
          }, (entry: CYLClassifyMenuHeaderFrame) => `${this.version}-${entry.key}`)
          ForEach(this.menuLayout.cells, (entry: CYLClassifyMenuCellFrame) => {
            Column() {
              CYLCollectionViewCellView({
                cell: entry.cell,
                onTap: () => this.controller.didSelectItemAt({ section: entry.cell.section, item: entry.cell.row })
              })
            }
            .position({ x: entry.frame.x, y: entry.frame.y + CONTENT_INSET_TOP })
            .width(entry.frame.width)
            .height(entry.frame.height)
          }, (entry: CYLClassifyMenuCellFrame) => `${this.version}-${entry.key}`)
        }
        .width('100%')
        .height(this.menuLayout.collectionHeight)
        .backgroundColor(CYLColor.WHITE)
        .onAreaChange((oldArea: Area, newArea: Area) => {
          const width = Number(newArea.width);
          if (width !== this.viewWidth) {
            this.viewWidth = width;
            this.relayout();
          }
        })
        if (this.controller.menuFooterView !== undefined) {
          Column() {
            this.controller.menuFooterView.builder()
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding({ bottom: BACKGROUND_EXTRA_HEIGHT })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .align(Alignment.Top)
    .backgroundColor(CYLColor.rgb(252 / 255, 252 / 255, 252 / 255))
  }
}
