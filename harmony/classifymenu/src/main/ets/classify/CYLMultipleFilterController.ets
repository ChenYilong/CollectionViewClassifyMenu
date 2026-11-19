import { CYLUIContext } from '../core/CYLUIContext';
/**
 * iOS `CYLMultipleFilterController.swift`, migrated from Android `CYLMultipleFilter.kt`: a side panel with a
 * multiple-choice filter: the sections and items come from `menuDataSource`; taps, the confirmation and the selection
 * are reported to `menuDelegate`. Items the data source marks exclusive ("All") are selected alone in their section.
 * `CYLMultipleFilterView` renders it.
 */
import { CYLIndexPath } from '../components/CYLTagListModel';
import { CYLTagButtonMetrics } from '../components/CYLTagListState';
import { CYLMenuDataSource, CYLMenuDefaults, CYLMenuDelegate } from '../core/CYLMenuDataSource';
import { CYLTagMetrics } from '../core/CYLTagMetrics';
import { CYLControlState, CYLFont, CYLRect, CYLSize } from '../core/CYLTypes';
import { CYLFilterBaseController, CYLFilterPanelView } from './CYLFilterBaseController';
import {
  CYLFilterCollectionCell, CYLFilterCollectionCellView, CYLMultipleFilterHeaderView,
  CYLMultipleFilterHeaderViewComponent
} from './CYLFilterCollectionCell';
import { CYLElementKindSectionHeader } from './CYLClassifyMenuViewController';

const CELLS_HORIZONTAL_MARGIN: number = 12;
const CELL_HEIGHT: number = 30;
const CELL_TEXT_PADDING: number = 16;

export class CYLMultipleFilterHeaderFrame {
  readonly key: string;
  readonly header: CYLMultipleFilterHeaderView;
  readonly frame: CYLRect;

  constructor(key: string, header: CYLMultipleFilterHeaderView, frame: CYLRect) {
    this.key = key;
    this.header = header;
    this.frame = frame;
  }
}

export class CYLMultipleFilterCellFrame {
  readonly key: string;
  readonly indexPath: CYLIndexPath;
  readonly cell: CYLFilterCollectionCell;
  readonly frame: CYLRect;

  constructor(key: string, indexPath: CYLIndexPath, cell: CYLFilterCollectionCell, frame: CYLRect) {
    this.key = key;
    this.indexPath = indexPath;
    this.cell = cell;
    this.frame = frame;
  }
}

export class CYLMultipleFilterLayout {
  readonly headers: CYLMultipleFilterHeaderFrame[];
  readonly cells: CYLMultipleFilterCellFrame[];
  readonly height: number;

  constructor(headers: CYLMultipleFilterHeaderFrame[], cells: CYLMultipleFilterCellFrame[], height: number) {
    this.headers = headers;
    this.cells = cells;
    this.height = height;
  }
}

export class CYLMultipleFilterController extends CYLFilterBaseController {
  /** The menu's sections and items. */
  menuDataSource: CYLMenuDataSource | undefined = undefined;
  /** Receives taps, the confirmed selection and selection changes. */
  menuDelegate: CYLMenuDelegate | undefined = undefined;
  /** The system font scale the tags are measured at. */
  fontScale: number = 1;

  /** The items' titles, per section. */
  private titles: string[][] = [];
  /** Whether each item is selected, per section (the same shape as `titles`). */
  private selection: boolean[][] = [];
  private loaded: boolean = false;

  constructor() {
    super();
    this.collectionView.contentInsetTop = 50;
  }

  /** Reloads the list from the current selection, without asking the data source again. */
  refreshFilterParams(): void {
    this.notify();
  }

  /**
   * Reads the sections and items from the data source again; each section starts with its first exclusive item
   * selected.
   */
  reloadMenuData(): void {
    this.loaded = true;
    const titles: string[][] = [];
    const selection: boolean[][] = [];
    const source = this.menuDataSource;
    if (source !== undefined) {
      for (let section = 0; section < source.numberOfSectionsInMenu(); section++) {
        const items: string[] = [];
        const states: boolean[] = [];
        let selectedExclusive = false;
        for (let item = 0; item < source.menuNumberOfItemsInSection(section); item++) {
          const indexPath: CYLIndexPath = { section: section, item: item };
          items.push(source.menuTitleForItem(indexPath));
          const exclusive = CYLMenuDefaults.isExclusive(source, indexPath);
          states.push(exclusive && !selectedExclusive);
          selectedExclusive = selectedExclusive || exclusive;
        }
        titles.push(items);
        selection.push(states);
      }
    }
    this.titles = titles;
    this.selection = selection;
    this.notify();
  }

  /** The selected items, section by section. */
  selectedIndexPaths(): CYLIndexPath[] {
    const paths: CYLIndexPath[] = [];
    this.selection.forEach((states: boolean[], section: number) => {
      states.forEach((selected: boolean, item: number) => {
        if (selected) {
          paths.push({ section: section, item: item });
        }
      });
    });
    return paths;
  }

  /**
   * Selects exactly these items. Throws for an item outside the menu, or when an exclusive item would share its
   * section with another selected item (iOS raises `NSInvalidArgumentException`).
   */
  setSelectedIndexPaths(indexPaths: CYLIndexPath[]): void {
    this.loadIfNeeded();
    const exclusiveSections = new Set<number>();
    const otherSections = new Set<number>();
    for (const path of indexPaths) {
      if (path.section < 0 || path.section >= this.titles.length || path.item < 0 ||
        path.item >= this.titles[path.section].length) {
        throw new Error(`Invalid menu selection: [${path.section}, ${path.item}]`);
      }
      const exclusive = this.isExclusive(path);
      if ((exclusive && (exclusiveSections.has(path.section) || otherSections.has(path.section))) ||
        (!exclusive && exclusiveSections.has(path.section))) {
        throw new Error(`Exclusive selection conflicts in section ${path.section}`);
      }
      if (exclusive) {
        exclusiveSections.add(path.section);
      } else {
        otherSections.add(path.section);
      }
    }
    this.selection = this.selection.map((states: boolean[]) => states.map(() => false));
    for (const path of indexPaths) {
      this.selection[path.section][path.item] = true;
    }
    this.notify();
  }

  // Actions

  confirmButtonClicked(sender?: Object): void {
    this.menuDelegate?.menuDidConfirmSelectedItems?.(this, this.selectedIndexPaths());
    super.confirmButtonClicked(sender);
  }

  restoreButtonClicked(sender?: Object): void {
    this.reloadMenuData();
    this.confirmButtonClicked(sender);
  }

  // UICollectionViewDataSource

  numberOfSections(): number {
    return this.titles.length;
  }

  numberOfItemsInSection(section: number): number {
    return section >= 0 && section < this.titles.length ? this.titles[section].length : 0;
  }

  /** `collectionView(_:viewForSupplementaryElementOfKind:at:)`: the section's header (headers only). */
  viewForSupplementaryElementOfKind(kind: string, indexPath: CYLIndexPath): CYLMultipleFilterHeaderView | undefined {
    if (kind !== CYLElementKindSectionHeader) {
      return undefined;
    }
    const header = new CYLMultipleFilterHeaderView();
    header.titleLabel = this.menuDataSource?.menuTitleForSection(indexPath.section) ?? '';
    return header;
  }

  cellForItemAt(indexPath: CYLIndexPath): CYLFilterCollectionCell {
    const cell = new CYLFilterCollectionCell();
    const button = cell.titleButton;
    const text = this.title(indexPath);
    button.setTitle(text, CYLControlState.NORMAL);
    button.setTitle(text, CYLControlState.SELECTED);
    button.font = this.tagFont();
    button.isSelected = this.isSelected(indexPath);
    button.section = indexPath.section;
    button.row = indexPath.item;
    return cell;
  }

  // UICollectionViewDelegate

  didSelectItemAt(indexPath: CYLIndexPath): void {
    if (indexPath.section < 0 || indexPath.section >= this.selection.length) {
      return;
    }
    let setting = this.selection[indexPath.section].slice();
    const section = indexPath.section;
    const hasExclusive = this.menuDataSource?.menuItemIsExclusive !== undefined;
    if (this.isExclusive(indexPath)) {
      setting = setting.map((value: boolean, item: number) => item === indexPath.item);
    } else {
      setting[indexPath.item] = !setting[indexPath.item];
      for (let item = 0; item < setting.length; item++) {
        if (this.isExclusive({ section: section, item: item })) {
          setting[item] = false;
        }
      }
      if (hasExclusive && !setting.includes(true)) {
        // Nothing left selected: fall back to the section's first exclusive item ("All").
        for (let item = 0; item < setting.length; item++) {
          if (this.isExclusive({ section: section, item: item })) {
            setting[item] = true;
            break;
          }
        }
      }
    }
    this.selection[section] = setting;
    this.notify();
    this.menuDelegate?.menuDidSelectItem?.(this, indexPath);
  }

  // UICollectionViewDelegateFlowLayout

  sizeForItemAt(indexPath: CYLIndexPath): CYLSize {
    const font = this.tagFont();
    const width = Math.ceil(CYLTagButtonMetrics.textMeasurer(this.title(indexPath), font));
    return new CYLSize(this.limitedCellWidth(width), CYLTagMetrics.tagHeight(font, CELL_HEIGHT));
  }

  minimumInteritemSpacingForSectionAt(section: number): number {
    return CELLS_HORIZONTAL_MARGIN;
  }

  // Rendering

  /** The headers and cells of the list at the panel's width. */
  layout(): CYLMultipleFilterLayout {
    this.loadIfNeeded();
    const width = this.collectionView.width;
    const headers: CYLMultipleFilterHeaderFrame[] = [];
    const cells: CYLMultipleFilterCellFrame[] = [];
    let y = 0;
    for (let section = 0; section < this.numberOfSections(); section++) {
      const header = this.viewForSupplementaryElementOfKind(CYLElementKindSectionHeader, { section: section, item: 0 });
      const headerHeight = this.referenceSizeForHeaderInSection(section).height;
      if (header !== undefined) {
        headers.push(new CYLMultipleFilterHeaderFrame(`h${section}`, header, new CYLRect(0, y, width, headerHeight)));
      }
      y += headerHeight;
      const count = this.numberOfItemsInSection(section);
      const sizes: CYLSize[] = [];
      for (let item = 0; item < count; item++) {
        sizes.push(this.sizeForItemAt({ section: section, item: item }));
      }
      const insets = this.insetForSectionAt(section);
      const placed = this.collectionView.collectionViewLayout.frames(sizes, y, width, insets,
        this.minimumInteritemSpacingForSectionAt(section));
      for (let item = 0; item < count; item++) {
        const indexPath: CYLIndexPath = { section: section, item: item };
        cells.push(new CYLMultipleFilterCellFrame(`c${section}-${item}`, indexPath, this.cellForItemAt(indexPath),
          placed.frames[item]));
      }
      y = (count === 0 ? y + insets.top : placed.bottom) + insets.bottom;
    }
    return new CYLMultipleFilterLayout(headers, cells, y);
  }

  // Private

  /** `viewDidLoad` reads the data source once. */
  private loadIfNeeded(): void {
    if (!this.loaded) {
      this.reloadMenuData();
    }
  }

  private isExclusive(indexPath: CYLIndexPath): boolean {
    const source = this.menuDataSource;
    return source !== undefined && CYLMenuDefaults.isExclusive(source, indexPath);
  }

  private title(indexPath: CYLIndexPath): string {
    const items = this.titles[indexPath.section];
    return items !== undefined && indexPath.item >= 0 && indexPath.item < items.length ? items[indexPath.item] : '';
  }

  private isSelected(indexPath: CYLIndexPath): boolean {
    const states = this.selection[indexPath.section];
    return states !== undefined && indexPath.item >= 0 && indexPath.item < states.length && states[indexPath.item];
  }

  private tagFont(): CYLFont {
    return CYLTagMetrics.titleFont(this.fontScale);
  }

  private limitedCellWidth(cellWidth: number): number {
    const inset = CYLFilterBaseController.sectionInset;
    const limitWidth = Math.max(0, this.collectionView.width - inset.left - inset.right);
    return Math.min(cellWidth + CELL_TEXT_PADDING, limitWidth);
  }
}

/** Renders a `CYLMultipleFilterController`: place it in a `Stack` above the host's content and call `show()`. */
@Component
export struct CYLMultipleFilterView {
  controller: CYLMultipleFilterController = new CYLMultipleFilterController();
  @State private version: number = 0;
  @State private filterLayout: CYLMultipleFilterLayout = new CYLMultipleFilterLayout([], [], 0);
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
    this.filterLayout = this.controller.layout();
    this.version++;
  }

  @Builder
  list() {
    Stack({ alignContent: Alignment.TopStart }) {
      ForEach(this.filterLayout.headers, (entry: CYLMultipleFilterHeaderFrame) => {
        Column() {
          CYLMultipleFilterHeaderViewComponent({ header: entry.header, viewWidth: entry.frame.width })
        }
        .position({ x: entry.frame.x, y: entry.frame.y })
      }, (entry: CYLMultipleFilterHeaderFrame) => `${this.version}-${entry.key}`)
      ForEach(this.filterLayout.cells, (entry: CYLMultipleFilterCellFrame) => {
        Column() {
          CYLFilterCollectionCellView({
            cell: entry.cell,
            onTap: () => this.controller.didSelectItemAt(entry.indexPath)
          })
        }
        .position({ x: entry.frame.x, y: entry.frame.y })
        .width(entry.frame.width)
        .height(entry.frame.height)
      }, (entry: CYLMultipleFilterCellFrame) => `${this.version}-${entry.key}`)
    }
    .width('100%')
    .height(this.filterLayout.height)
    .onAreaChange((oldArea: Area, newArea: Area) => {
      const width = Number(newArea.width);
      if (width > 0 && width !== this.controller.collectionView.width) {
        this.controller.collectionView.width = width;
        this.relayout();
      }
    })
  }

  build() {
    CYLFilterPanelView({ controller: this.controller }) {
      this.list()
    }
  }
}
