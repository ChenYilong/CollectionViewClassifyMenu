//
//  CYLReviewListViewController.h
//  CYLMenuExample
//
//  场景一（评价页）：多选评价筛选，折叠为两行，旋转箭头展开/收起；每次选择后按全部所选条件（AND）
//  刷新下方评价列表。内存筛选、网络筛选与数据库筛选（SQLite）是三种场景，通过顶部开关切换。
//

#import <UIKit/UIKit.h>
@import CollectionViewClassifyMenu;
#import "CYLReviewQuery.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLReviewListViewController : UIViewController

/// Opens with the filter at `index` of CYLReviewStore.filters selected (0 is "全部"), filtering in memory.
- (instancetype)initWithSelectedFilterIndex:(NSUInteger)index;
- (instancetype)initWithSelectedFilterIndex:(NSUInteger)index mode:(CYLReviewFilteringMode)mode NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// The orange review filter style, also used for the product page preview.
+ (CYLMenuStyle *)reviewFilterStyle;

@property (nonatomic, strong, readonly) CYLTagListView *filterView;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) UISegmentedControl *modeControl;
/// The last tap and the query state, shown above the list.
@property (nonatomic, strong, readonly) UILabel *statusLabel;
@property (nonatomic, assign, readonly) CYLReviewFilteringMode mode;
@property (nonatomic, strong, readonly) id<CYLReviewQuerying> query;
@property (nonatomic, copy, readonly) NSArray<CYLReviewFilter *> *selectedFilters;
@property (nonatomic, copy, readonly) NSArray<CYLReview *> *visibleReviews;

- (void)setMode:(CYLReviewFilteringMode)mode;
/// Selects filters by index (as if tapped one after another) and refreshes the list.
- (void)selectFilterIndexes:(NSArray<NSNumber *> *)indexes;

@end

NS_ASSUME_NONNULL_END
