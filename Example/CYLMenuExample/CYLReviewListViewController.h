//
//  CYLReviewListViewController.h
//  CYLMenuExample
//
//  场景一（评价页）：可折叠的单选评价筛选，选中后过滤下方评价列表。
//

#import <UIKit/UIKit.h>
@import CollectionViewClassifyMenu;

NS_ASSUME_NONNULL_BEGIN

@interface CYLReviewListViewController : UIViewController

/// Index into CYLReviewStore.filters to select first; 0 is "全部".
- (instancetype)initWithSelectedFilterIndex:(NSUInteger)index NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// The orange review filter style, also used for the product page preview.
+ (CYLMenuStyle *)reviewFilterStyle;

@property (nonatomic, strong, readonly) CYLTagListView *filterView;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, assign, readonly) NSUInteger selectedFilterIndex;

@end

NS_ASSUME_NONNULL_END
