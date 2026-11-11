//
//  CYLMenuDataSource.h
//  CollectionViewClassifyMenu
//
//  Host-owned data and callbacks shared by every menu in the component.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CYLMenuStyle;

/*!
 * What an item of CYLTagListView is.
 */
typedef NS_ENUM(NSInteger, CYLMenuItemType) {
    /*!
     * A tag (the default).
     */
    CYLMenuItemTypeTag = 0,
    /*!
     * "+ 新建标签": an outlined action with the core's plus icon (CYLTagCreateCell), never selected. Its
     * title from -menuTitleForItemAtIndexPath: is the name to create, shown as "新建标签：<name>"
     * (localized); an empty title shows "新建标签". A tap calls -menu:didRequestNewItemWithName:atIndexPath:.
     */
    CYLMenuItemTypeCreate,
};

@protocol CYLMenuDataSource <NSObject>

- (NSInteger)numberOfSectionsInMenu;
- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section;
- (NSString *)menuTitleForSection:(NSInteger)section;
- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
/*!
 * Icon drawn before the item's title. Return nil for a text-only item.
 */
- (nullable UIImage *)menuImageForItemAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * Icon shown while the item is selected; nil keeps the normal icon.
 */
- (nullable UIImage *)menuSelectedImageForItemAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * Animated icon (a Lottie .json, .pag, .riv or .gif file), played like a CYLTabBarController
 * tab icon: it plays when a tap selects the item. Needs the library's CYLTabBarController
 * subspec in the app (e.g. `pod 'CYLTabBarController/Lottie'`); without it the image is shown.
 */
- (nullable NSURL *)menuAnimationURLForItemAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * The frame (0...1) an animated icon shows while its item is not selected. Default (nil) 0, the first
 * frame, as a CYLTabBarController tab icon; for a file whose first frame is empty, e.g. @1 for the last.
 */
- (nullable NSNumber *)menuAnimationRestingProgressForItemAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * The look of one section's tags (colors, fonts, borders, icon colors, title and image layout), e.g. dark
 * tags for white icons. Return nil for the list's style. Item height, spacing and insets always come from
 * the list's style. Return the same object for as long as it does not change.
 */
- (nullable CYLMenuStyle *)menuStyleForSection:(NSInteger)section;
/*!
 * The look of one item, over its section's (for example an outlined "+ 新建标签" action among the tags).
 * Return nil for the section's style. Metrics come from the list's style, as for sections.
 */
- (nullable CYLMenuStyle *)menuStyleForItemAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * Icon drawn before the section title. Return nil for no icon.
 */
- (nullable UIImage *)menuImageForSection:(NSInteger)section;
/*!
 * View placed at the trailing edge of the section header, such as a picker
 * button. The menu sizes it with -sizeThatFits: and does not retain it beyond
 * the header's lifetime; return the same instance to keep its state.
 */
- (nullable UIView *)menuAccessoryViewForSection:(NSInteger)section;
/*!
 * Disabled items are drawn dimmed and cannot be selected. Defaults to YES.
 */
- (BOOL)menuItemIsEnabledAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * Selecting an exclusive item clears the other items in its section and
 * vice versa (for example "全部"). Defaults to NO.
 */
- (BOOL)menuItemIsExclusiveAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * NO for an item that acts like a button in any selection mode, such as "+ 新建标签": a tap is
 * reported through -menu:didSelectItemAtIndexPath: but the item never stays selected and the
 * selection does not change. Defaults to YES.
 */
- (BOOL)menuItemIsSelectableAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * Tag (default) or "+ 新建标签" (CYLMenuItemTypeCreate).
 */
- (CYLMenuItemType)menuItemTypeAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * The VoiceOver hint of an item (what a tap does, for example "Double-tap to remove"), already
 * localized. The label is the item's title, the traits are set by the list. Defaults to nil.
 */
- (nullable NSString *)menuAccessibilityHintForItemAtIndexPath:(NSIndexPath *)indexPath
    NS_SWIFT_NAME(menuAccessibilityHintForItem(at:));
/*!
 * A short badge after the item's title, such as "热" (already localized); nil (the default) for none. The title
 * is truncated to leave room for it; VoiceOver reads it as the item's value. Colors: CYLMenuStyle.badgeBackgroundColor
 * and badgeTextColor. Only CYLTagListView shows badges.
 */
- (nullable NSString *)menuBadgeForItemAtIndexPath:(NSIndexPath *)indexPath NS_SWIFT_NAME(menuBadgeForItem(at:));
/*!
 * YES shows a More button (three dots, CYLMenuStyle.moreButtonImage) at the trailing edge of the section header,
 * whose action the host decides in `-menu:didTapMoreButtonInSection:` (for example refreshing the section).
 * Defaults to NO. Only CYLTagListView shows it.
 */
- (BOOL)menuShowsMoreButtonInSection:(NSInteger)section NS_SWIFT_NAME(menuShowsMoreButton(inSection:));

@end

@protocol CYLMenuDelegate <NSObject>

@optional
/*!
 * Return NO to ignore a tap. Not called for disabled items.
 */
- (BOOL)menu:(id)menu shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * Called for every accepted tap, including in CYLMenuSelectionModeNone. For a CYLMenuItemTypeCreate
 * item, only when the delegate does not implement -menu:didRequestNewItemWithName:atIndexPath:.
 */
- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * A tap on a "+ 新建标签" item (CYLMenuItemTypeCreate): `name` is its title from the data source, empty
 * when the host should ask for one.
 */
- (void)menu:(id)menu didRequestNewItemWithName:(NSString *)name atIndexPath:(NSIndexPath *)indexPath;
/*!
 * Called when a tap or another selection removes an item from the selection.
 */
- (void)menu:(id)menu didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
/*!
 * Called once after a tap that changed the selection, after the select and
 * deselect callbacks: the place to refresh content filtered by the selection.
 */
- (void)menu:(id)menu didChangeSelectedItems:(NSArray<NSIndexPath *> *)indexPaths;
- (void)menu:(id)menu didConfirmSelectedItems:(NSArray<NSIndexPath *> *)indexPaths;
/*!
 * Called after a section is expanded or collapsed by the user or the host.
 */
- (void)menu:(id)menu didChangeExpanded:(BOOL)expanded inSection:(NSInteger)section;
/*!
 * Called when the height needed to show the whole menu changes, so that a
 * host can resize an embedded, non-scrolling menu.
 */
- (void)menu:(id)menu didChangeContentHeight:(CGFloat)height;

/*!
 * The More button of a section header was tapped (`menuShowsMoreButtonInSection:`); the host runs its own action,
 * for example loading other items and calling -reloadMenuData.
 */
- (void)menu:(id)menu didTapMoreButtonInSection:(NSInteger)section NS_SWIFT_NAME(menu(_:didTapMoreButtonInSection:));

@end

NS_ASSUME_NONNULL_END
