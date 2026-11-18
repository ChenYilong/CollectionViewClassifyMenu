/**
 * The data source and delegate of a menu, as iOS `CYLMenuDataSource.swift`. ArkTS interfaces have no default
 * methods: the four required data source methods are methods, every optional one is an optional function property, and
 * `CYLMenuDefaults` gives the iOS default of each (the value when a data source does not implement it).
 */
import { CYLIndexPath } from '../components/CYLTagListModel';
import { CYLMenuStyle } from './CYLMenuStyle';
import { CYLImage } from './CYLTypes';

/** What an item of a tag list is: a tag (the default), or "+ 新建标签", which asks for a name. */
export enum CYLMenuItemType {
  tag = 0,
  create = 1
}

/** The sections and items of a menu, owned by the host. */
export interface CYLMenuDataSource {
  numberOfSectionsInMenu(): number;
  menuNumberOfItemsInSection(section: number): number;
  menuTitleForSection(section: number): string;
  menuTitleForItem(indexPath: CYLIndexPath): string;

  /** An image shown before the title (a resource or a path). */
  menuImageForItem?: (indexPath: CYLIndexPath) => CYLImage | undefined;
  /** The image of a selected item. */
  menuSelectedImageForItem?: (indexPath: CYLIndexPath) => CYLImage | undefined;
  /** A Lottie animation played as the item's icon: `asset:<rawfile path>` or the JSON text. */
  menuAnimationURLForItem?: (indexPath: CYLIndexPath) => string | undefined;
  /** The progress (0...1) the animation rests at while not selected. */
  menuAnimationRestingProgressForItem?: (indexPath: CYLIndexPath) => number | undefined;
  /** The style of a section (the list's style when undefined). */
  menuStyleForSection?: (section: number) => CYLMenuStyle | undefined;
  /** The style of one item (its section's style when undefined). */
  menuStyleForItem?: (indexPath: CYLIndexPath) => CYLMenuStyle | undefined;
  /** The icon of a section header. */
  menuImageForSection?: (section: number) => CYLImage | undefined;
  /**
   * A view at the trailing end of a section header, left of a trailing fold control, at most half the header's
   * width (a builder that takes the section; ArkTS passes builders as WrappedBuilder).
   */
  menuAccessoryViewForSection?: (section: number) => WrappedBuilder<[number]> | undefined;
  menuItemIsEnabled?: (indexPath: CYLIndexPath) => boolean;
  /** An item that clears the other selected items of its section (the "全部" of a filter). */
  menuItemIsExclusive?: (indexPath: CYLIndexPath) => boolean;
  menuItemIsSelectable?: (indexPath: CYLIndexPath) => boolean;
  menuItemType?: (indexPath: CYLIndexPath) => CYLMenuItemType;
  menuAccessibilityHintForItem?: (indexPath: CYLIndexPath) => string | undefined;
  menuShowsMoreButtonInSection?: (section: number) => boolean;
  menuAccessibilityLabelForMoreButtonInSection?: (section: number) => string | undefined;
  menuItemIsDeletable?: (indexPath: CYLIndexPath) => boolean;
  menuRemoveItem?: (indexPath: CYLIndexPath) => void;
  /** Implemented when the list may reorder items (iOS: `respondsToSelector:`). */
  menuMoveItem?: (from: CYLIndexPath, to: CYLIndexPath) => void;
  /**
   * `menuSectionAllowsEditing(_:)`: whether a section takes part in `CYLTagListState`'s editing mode (delete indicators,
   * reordering); true when not implemented.
   */
  menuSectionAllowsEditing?: (section: number) => boolean;
  /**
   * `menuCacheKey(forSection:)`: the key the list saves a section's titles under in its cache (`cachePolicy`), stable
   * when sections come and go (e.g. "mine"); the section's index when not implemented.
   */
  menuCacheKeyForSection?: (section: number) => string;
}

/**
 * Selection, new items, folding, height, the More button, deletion, long press, reordering and dragging of a menu.
 * Every method is optional; `menu` is the list that calls it.
 */
export interface CYLMenuDelegate {
  menuShouldSelectItem?: (menu: Object, indexPath: CYLIndexPath) => boolean;
  menuDidSelectItem?: (menu: Object, indexPath: CYLIndexPath) => void;
  menuDidRequestNewItemWithName?: (menu: Object, name: string, indexPath: CYLIndexPath) => void;
  menuDidDeselectItem?: (menu: Object, indexPath: CYLIndexPath) => void;
  menuDidChangeSelectedItems?: (menu: Object, indexPaths: CYLIndexPath[]) => void;
  menuDidConfirmSelectedItems?: (menu: Object, indexPaths: CYLIndexPath[]) => void;
  menuDidChangeExpanded?: (menu: Object, expanded: boolean, section: number) => void;
  menuDidChangeContentHeight?: (menu: Object, height: number) => void;
  menuDidTapMoreButtonInSection?: (menu: Object, section: number) => void;
  menuDidDeleteItem?: (menu: Object, indexPath: CYLIndexPath) => void;
  menuDidLongPressItem?: (menu: Object, indexPath: CYLIndexPath) => void;
  menuDidMoveItem?: (menu: Object, from: CYLIndexPath, to: CYLIndexPath) => void;
  menuDidBeginDraggingSelectedItem?: (menu: Object, indexPath: CYLIndexPath) => void;
  /** `menu(_:didChangeEditing:)`: the list entered (true) or left (false) editing mode (`setEditing`). */
  menuDidChangeEditing?: (menu: Object, editing: boolean) => void;
}

/** The iOS defaults of the optional data source methods, for a data source that does not implement them. */
export class CYLMenuDefaults {
  static isEnabled(source: CYLMenuDataSource, indexPath: CYLIndexPath): boolean {
    return source.menuItemIsEnabled ? source.menuItemIsEnabled(indexPath) : true;
  }

  static isExclusive(source: CYLMenuDataSource, indexPath: CYLIndexPath): boolean {
    return source.menuItemIsExclusive ? source.menuItemIsExclusive(indexPath) : false;
  }

  static isSelectable(source: CYLMenuDataSource, indexPath: CYLIndexPath): boolean {
    return source.menuItemIsSelectable ? source.menuItemIsSelectable(indexPath) : true;
  }

  static itemType(source: CYLMenuDataSource, indexPath: CYLIndexPath): CYLMenuItemType {
    return source.menuItemType ? source.menuItemType(indexPath) : CYLMenuItemType.tag;
  }

  static isDeletable(source: CYLMenuDataSource, indexPath: CYLIndexPath): boolean {
    return source.menuItemIsDeletable ? source.menuItemIsDeletable(indexPath) : false;
  }

  static showsMoreButton(source: CYLMenuDataSource, section: number): boolean {
    return source.menuShowsMoreButtonInSection ? source.menuShowsMoreButtonInSection(section) : false;
  }

  /** Whether the list may reorder items: the data source moves them. */
  static supportsMovingItems(source: CYLMenuDataSource): boolean {
    return source.menuMoveItem !== undefined;
  }

  /** Whether `menuShouldSelectItem` allows the selection (true when the delegate does not implement it). */
  static shouldSelect(delegate: CYLMenuDelegate | undefined, menu: Object, indexPath: CYLIndexPath): boolean {
    return delegate?.menuShouldSelectItem ? delegate.menuShouldSelectItem(menu, indexPath) : true;
  }
}
