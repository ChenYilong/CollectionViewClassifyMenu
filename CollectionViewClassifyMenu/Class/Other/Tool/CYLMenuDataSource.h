//
//  CYLMenuDataSource.h
//  CollectionViewClassifyMenu
//
//  Host-owned data and callbacks shared by every menu in the component.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CYLMenuDataSource <NSObject>

- (NSInteger)numberOfSectionsInMenu;
- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section;
- (NSString *)menuTitleForSection:(NSInteger)section;
- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
/// Icon drawn before the item's title. Return nil for a text-only item.
- (nullable UIImage *)menuImageForItemAtIndexPath:(NSIndexPath *)indexPath;
/// Icon drawn before the section title. Return nil for no icon.
- (nullable UIImage *)menuImageForSection:(NSInteger)section;
/// View placed at the trailing edge of the section header, such as a picker
/// button. The menu sizes it with -sizeThatFits: and does not retain it beyond
/// the header's lifetime; return the same instance to keep its state.
- (nullable UIView *)menuAccessoryViewForSection:(NSInteger)section;
/// Disabled items are drawn dimmed and cannot be selected. Defaults to YES.
- (BOOL)menuItemIsEnabledAtIndexPath:(NSIndexPath *)indexPath;
/// Selecting an exclusive item clears the other items in its section and
/// vice versa (for example "全部"). Defaults to NO.
- (BOOL)menuItemIsExclusiveAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol CYLMenuDelegate <NSObject>

@optional
/// Return NO to ignore a tap. Not called for disabled items.
- (BOOL)menu:(id)menu shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
/// Called for every accepted tap, including in CYLMenuSelectionModeNone.
- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
/// Called when a tap or another selection removes an item from the selection.
- (void)menu:(id)menu didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)menu:(id)menu didConfirmSelectedItems:(NSArray<NSIndexPath *> *)indexPaths;
/// Called after a section is expanded or collapsed by the user or the host.
- (void)menu:(id)menu didChangeExpanded:(BOOL)expanded inSection:(NSInteger)section;
/// Called when the height needed to show the whole menu changes, so that a
/// host can resize an embedded, non-scrolling menu.
- (void)menu:(id)menu didChangeContentHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
