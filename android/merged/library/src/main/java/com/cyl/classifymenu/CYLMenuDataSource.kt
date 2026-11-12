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

    /** Whether the long press is handled (`respondsToSelector:` of `menu:didLongPressItemAtIndexPath:`). */
    fun handlesLongPress(): Boolean = false
}
