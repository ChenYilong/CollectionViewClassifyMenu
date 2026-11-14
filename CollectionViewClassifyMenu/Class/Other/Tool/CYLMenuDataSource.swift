//
//  CYLMenuDataSource.swift
//  CollectionViewClassifyMenu
//
//  Host-owned data and callbacks shared by every menu in the component.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md). The protocols stay `@objc` with their
//  Objective-C selectors: their methods are optional and the core's Objective-C tests implement them.
//

import UIKit

/**
 * What an item of `CYLTagListView` is.
 */
@objc public enum CYLMenuItemType: Int {
    /**
     * A tag (the default).
     */
    case tag = 0
    /**
     * "+ 新建标签": an outlined action with the core's plus icon (`CYLTagCreateCell`), never selected. Its title from
     * `menuTitleForItem(at:)` is the name to create, shown as "新建标签：<name>" (localized); an empty title shows
     * "新建标签". A tap calls `menu(_:didRequestNewItemWithName:at:)`.
     */
    case create
}

/**
 * The sections and items of a menu, owned by the host.
 */
@objc public protocol CYLMenuDataSource: NSObjectProtocol {

    /**
     * The number of sections.
     */
    func numberOfSectionsInMenu() -> Int

    /**
     * The number of items in a section.
     */
    func menuNumberOfItems(inSection section: Int) -> Int

    /**
     * A section's title.
     */
    func menuTitle(forSection section: Int) -> String

    /**
     * An item's title.
     */
    @objc(menuTitleForItemAtIndexPath:)
    func menuTitleForItem(at indexPath: IndexPath) -> String

    /**
     * Icon drawn before the item's title. Return `nil` for a text-only item.
     */
    @objc(menuImageForItemAtIndexPath:)
    optional func menuImageForItem(at indexPath: IndexPath) -> UIImage?

    /**
     * Icon shown while the item is selected; `nil` keeps the normal icon.
     */
    @objc(menuSelectedImageForItemAtIndexPath:)
    optional func menuSelectedImageForItem(at indexPath: IndexPath) -> UIImage?

    /**
     * Animated icon (a Lottie .json, .pag, .riv or .gif file), played like a CYLTabBarController tab icon: it plays
     * when a tap selects the item. Needs the library's CYLTabBarController subspec in the app (e.g.
     * `pod 'CYLTabBarController/Lottie'`); without it the image is shown.
     */
    @objc(menuAnimationURLForItemAtIndexPath:)
    optional func menuAnimationURLForItem(at indexPath: IndexPath) -> URL?

    /**
     * The frame (0...1) an animated icon shows while its item is not selected. Default (`nil`) 0, the first frame, as
     * a CYLTabBarController tab icon; for a file whose first frame is empty, e.g. 1 for the last.
     */
    @objc(menuAnimationRestingProgressForItemAtIndexPath:)
    optional func menuAnimationRestingProgressForItem(at indexPath: IndexPath) -> NSNumber?

    /**
     * The look of one section's tags (colors, fonts, borders, icon colors, title and image layout), e.g. dark tags for
     * white icons. Return `nil` for the list's style. Item height, spacing and insets always come from the list's
     * style. Return the same object for as long as it does not change.
     */
    @objc(menuStyleForSection:)
    optional func menuStyle(forSection section: Int) -> CYLMenuStyle?

    /**
     * The look of one item, over its section's (for example an outlined "+ 新建标签" action among the tags). Return
     * `nil` for the section's style. Metrics come from the list's style, as for sections.
     */
    @objc(menuStyleForItemAtIndexPath:)
    optional func menuStyleForItem(at indexPath: IndexPath) -> CYLMenuStyle?

    /**
     * Icon drawn before the section title. Return `nil` for no icon.
     */
    @objc(menuImageForSection:)
    optional func menuImage(forSection section: Int) -> UIImage?

    /**
     * View placed at the trailing edge of the section header, such as a picker button. The menu sizes it with
     * `sizeThatFits(_:)` and does not retain it beyond the header's lifetime; return the same instance to keep its
     * state.
     */
    @objc(menuAccessoryViewForSection:)
    optional func menuAccessoryView(forSection section: Int) -> UIView?

    /**
     * Disabled items are drawn dimmed and cannot be selected. Defaults to true.
     */
    @objc(menuItemIsEnabledAtIndexPath:)
    optional func menuItemIsEnabled(at indexPath: IndexPath) -> Bool

    /**
     * Selecting an exclusive item clears the other items in its section and vice versa (for example "全部").
     * Defaults to false.
     */
    @objc(menuItemIsExclusiveAtIndexPath:)
    optional func menuItemIsExclusive(at indexPath: IndexPath) -> Bool

    /**
     * False for an item that acts like a button in any selection mode, such as "+ 新建标签": a tap is reported through
     * `menu(_:didSelectItemAt:)` but the item never stays selected and the selection does not change. Defaults to
     * true.
     */
    @objc(menuItemIsSelectableAtIndexPath:)
    optional func menuItemIsSelectable(at indexPath: IndexPath) -> Bool

    /**
     * Tag (default) or "+ 新建标签" (`CYLMenuItemType.create`).
     */
    @objc(menuItemTypeAtIndexPath:)
    optional func menuItemType(at indexPath: IndexPath) -> CYLMenuItemType

    /**
     * The VoiceOver hint of an item (what a tap does, for example "Double-tap to remove"), already localized. The
     * label is the item's title, the traits are set by the list. Defaults to `nil`.
     */
    @objc(menuAccessibilityHintForItemAtIndexPath:)
    optional func menuAccessibilityHintForItem(at indexPath: IndexPath) -> String?

    /**
     * True shows a More button (three dots, `CYLMenuStyle.moreButtonImage`) at the trailing edge of the section
     * header, whose action the host decides in `menu(_:didTapMoreButtonInSection:)` (for example refreshing the
     * section). Defaults to false. Only `CYLTagListView` shows it.
     */
    @objc(menuShowsMoreButtonInSection:)
    optional func menuShowsMoreButton(inSection section: Int) -> Bool

    /**
     * What VoiceOver, Voice Control and the Large Content Viewer call the section's More button, already localized:
     * say what its action does, for example "换一批" (refresh). `nil` (the default) uses "<section title> 更多操作".
     */
    @objc(menuAccessibilityLabelForMoreButtonInSection:)
    optional func menuAccessibilityLabelForMoreButton(inSection section: Int) -> String?

    /**
     * True shows a delete indicator ("×", `CYLMenuStyle.deleteIndicatorTitle`) after the item's title, as
     * android-tagview's deletable tags; a tap on it (or VoiceOver's "Delete" action) deletes the item. Defaults to
     * false. Only `CYLTagListView` shows it.
     */
    @objc(menuItemIsDeletableAtIndexPath:)
    optional func menuItemIsDeletable(at indexPath: IndexPath) -> Bool

    /**
     * Remove the item from your data: the delete indicator of a deletable item was tapped. The list then reloads and
     * calls `menu(_:didDeleteItemAt:)`. Without it, the list only reports the tap (the host removes the item and calls
     * `reloadMenuData()`).
     */
    @objc(menuRemoveItemAtIndexPath:)
    optional func menuRemoveItem(at indexPath: IndexPath)

    /**
     * Move the item in your data: the user reordered the items of a section (`CYLTagListView.allowsReordering`).
     */
    @objc(menuMoveItemAtIndexPath:toIndexPath:)
    optional func menuMoveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

/**
 * Taps, selection, folding and size changes of a menu, reported to the host. `menu` is the menu that reports it
 * (a `CYLTagListView` or a `CYLMultipleFilterController`).
 */
@objc public protocol CYLMenuDelegate: NSObjectProtocol {

    /**
     * Return false to ignore a tap. Not called for disabled items.
     */
    @objc(menu:shouldSelectItemAtIndexPath:)
    optional func menu(_ menu: Any, shouldSelectItemAt indexPath: IndexPath) -> Bool

    /**
     * Called for every accepted tap, including in `CYLMenuSelectionMode.none`. For a `CYLMenuItemType.create` item,
     * only when the delegate does not implement `menu(_:didRequestNewItemWithName:at:)`.
     */
    @objc(menu:didSelectItemAtIndexPath:)
    optional func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath)

    /**
     * A tap on a "+ 新建标签" item (`CYLMenuItemType.create`): `name` is its title from the data source, empty when
     * the host should ask for one.
     */
    @objc(menu:didRequestNewItemWithName:atIndexPath:)
    optional func menu(_ menu: Any, didRequestNewItemWithName name: String, at indexPath: IndexPath)

    /**
     * Called when a tap or another selection removes an item from the selection.
     */
    @objc(menu:didDeselectItemAtIndexPath:)
    optional func menu(_ menu: Any, didDeselectItemAt indexPath: IndexPath)

    /**
     * Called once after a tap that changed the selection, after the select and deselect callbacks: the place to
     * refresh content filtered by the selection.
     */
    @objc(menu:didChangeSelectedItems:)
    optional func menu(_ menu: Any, didChangeSelectedItems indexPaths: [IndexPath])

    /**
     * The selection a filter panel confirmed (`CYLMultipleFilterController`).
     */
    @objc(menu:didConfirmSelectedItems:)
    optional func menu(_ menu: Any, didConfirmSelectedItems indexPaths: [IndexPath])

    /**
     * Called after a section is expanded or collapsed by the user or the host.
     */
    @objc(menu:didChangeExpanded:inSection:)
    optional func menu(_ menu: Any, didChangeExpanded expanded: Bool, inSection section: Int)

    /**
     * Called when the height needed to show the whole menu changes, so that a host can resize an embedded,
     * non-scrolling menu.
     */
    @objc(menu:didChangeContentHeight:)
    optional func menu(_ menu: Any, didChangeContentHeight height: CGFloat)

    /**
     * The More button of a section header was tapped (`menuShowsMoreButton(inSection:)`); the host runs its own
     * action, for example loading other items and calling `reloadMenuData()`.
     */
    @objc(menu:didTapMoreButtonInSection:)
    optional func menu(_ menu: Any, didTapMoreButtonInSection section: Int)

    /**
     * The delete indicator of a deletable item was tapped (as android-tagview's onTagDeleted). When the data source
     * implements `menuRemoveItem(at:)`, the item is already gone and `indexPath` is where it was.
     */
    @objc(menu:didDeleteItemAtIndexPath:)
    optional func menu(_ menu: Any, didDeleteItemAt indexPath: IndexPath)

    /**
     * A long press on an item that did not move it (AndroidTagView's onTagLongClick).
     */
    @objc(menu:didLongPressItemAtIndexPath:)
    optional func menu(_ menu: Any, didLongPressItemAt indexPath: IndexPath)

    /**
     * The user moved an item; the data source has moved it.
     */
    @objc(menu:didMoveItemAtIndexPath:toIndexPath:)
    optional func menu(_ menu: Any, didMoveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)

    /**
     * A selected item started moving (AndroidTagView's onSelectedTagDrag).
     */
    @objc(menu:didBeginDraggingSelectedItemAtIndexPath:)
    optional func menu(_ menu: Any, didBeginDraggingSelectedItemAt indexPath: IndexPath)
}
