#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CYLMenuDataSource <NSObject>

- (NSInteger)numberOfSectionsInMenu;
- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section;
- (NSString *)menuTitleForSection:(NSInteger)section;
- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (BOOL)menuItemHasImageAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)menuItemIsExclusiveAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol CYLMenuDelegate <NSObject>

@optional
- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)menu:(id)menu didConfirmSelectedItems:(NSArray<NSIndexPath *> *)indexPaths;

@end

NS_ASSUME_NONNULL_END
