package com.cyl.classifymenu

import android.graphics.drawable.Drawable
import android.net.Uri
import android.view.View

/** `CYLMenuItemType`: a tag, or the "+ New tag" item that asks for a name. */
enum class CYLMenuItemType { CYLMenuItemTypeTag, CYLMenuItemTypeCreate }

/**
 * `CYLMenuDataSource`: the sections and items of a tag list. The four required methods are abstract; the optional
 * ones have the iOS default behavior (as when a data source does not implement them).
 */
interface CYLMenuDataSource {
    fun numberOfSectionsInMenu(): Int
    fun menuNumberOfItemsInSection(section: Int): Int
    fun menuTitleForSection(section: Int): String
    fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath): String

    fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath): Drawable? = null
    fun menuSelectedImageForItemAtIndexPath(indexPath: CYLIndexPath): Drawable? = null
    fun menuAnimationURLForItemAtIndexPath(indexPath: CYLIndexPath): Uri? = null
    fun menuAnimationRestingProgressForItemAtIndexPath(indexPath: CYLIndexPath): Float? = null
    fun menuStyleForSection(section: Int): CYLMenuStyle? = null
    fun menuStyleForItemAtIndexPath(indexPath: CYLIndexPath): CYLMenuStyle? = null
    fun menuImageForSection(section: Int): Drawable? = null
    fun menuAccessoryViewForSection(section: Int): View? = null
    fun menuItemIsEnabledAtIndexPath(indexPath: CYLIndexPath): Boolean = true
    fun menuItemIsExclusiveAtIndexPath(indexPath: CYLIndexPath): Boolean = false
    fun menuItemIsSelectableAtIndexPath(indexPath: CYLIndexPath): Boolean = true
    fun menuItemTypeAtIndexPath(indexPath: CYLIndexPath): CYLMenuItemType = CYLMenuItemType.CYLMenuItemTypeTag
    fun menuAccessibilityHintForItemAtIndexPath(indexPath: CYLIndexPath): String? = null
    fun menuShowsMoreButtonInSection(section: Int): Boolean = false
    fun menuAccessibilityLabelForMoreButtonInSection(section: Int): String? = null
    fun menuItemIsDeletableAtIndexPath(indexPath: CYLIndexPath): Boolean = false
    fun menuRemoveItemAtIndexPath(indexPath: CYLIndexPath) {}

    /** Optional on iOS: a list may only reorder items when its data source moves them. */
    fun menuMoveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) {}

    /** Whether `menuMoveItemAtIndexPath` is implemented (`respondsToSelector:` on iOS). */
    fun supportsMovingItems(): Boolean = false

    /**
     * Whether `menuItemIsDeletableAtIndexPath` is implemented (`respondsToSelector:` on iOS). In `CYLTagListView`'s
     * editing mode every item of an editable section is deletable unless the data source decides (then its answer).
     */
    fun decidesDeletableItems(): Boolean = false

    /**
     * `menuSectionAllowsEditing:`: whether a section takes part in `CYLTagListView`'s editing mode (delete indicators,
     * reordering); true by default.
     */
    fun menuSectionAllowsEditing(section: Int): Boolean = true

    /**
     * `menuCacheKeyForSection:`: the key `CYLTagListView` saves a section's titles under in its cache (`cachePolicy`),
     * stable when sections come and go (e.g. "mine"); null (the default) uses the section's index.
     */
    fun menuCacheKeyForSection(section: Int): String? = null
}

/**
 * `CYLMenuDelegate`: selection, new items, folding, height, the More button, deletion, long press, reordering and
 * dragging of a tag list. Every method is optional (no-op by default); `menu` is the list.
 */
interface CYLMenuDelegate {
    fun menuShouldSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath): Boolean = true
    fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {}
    fun menuDidRequestNewItemWithName(menu: Any, name: String, atIndexPath: CYLIndexPath) {}
    fun menuDidDeselectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {}
    fun menuDidChangeSelectedItems(menu: Any, indexPaths: List<CYLIndexPath>) {}
    fun menuDidConfirmSelectedItems(menu: Any, indexPaths: List<CYLIndexPath>) {}
    fun menuDidChangeExpanded(menu: Any, expanded: Boolean, inSection: Int) {}
    fun menuDidChangeContentHeight(menu: Any, height: Float) {}
    fun menuDidTapMoreButtonInSection(menu: Any, section: Int) {}
    fun menuDidDeleteItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {}
    fun menuDidLongPressItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {}
    fun menuDidMoveItemAtIndexPath(menu: Any, sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) {}
    fun menuDidBeginDraggingSelectedItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {}

    /** `menu:didChangeEditing:`: `CYLTagListView` entered (true) or left (false) editing mode (`setEditing`). */
    fun menuDidChangeEditing(menu: Any, editing: Boolean) {}

    /**
     * `menu:didFinishEditingWithTitles:`: `CYLTagListView`'s editing ended; the edited sections' titles by cache key
     * (`cacheKeyForSection`), in their new order, already saved to its cache: upload them to your server here.
     */
    fun menuDidFinishEditingWithTitles(menu: Any, titles: Map<String, List<String>>) {}

    /** Whether the long press is handled (`respondsToSelector:` of `menu:didLongPressItemAtIndexPath:`). */
    fun handlesLongPress(): Boolean = false
}
