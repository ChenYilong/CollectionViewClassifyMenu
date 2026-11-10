//
//  CYLMenuLinkageViewController.h
//  CYLMenuExample
//
//  菜单选择（移植自 CollectionViewClassifyMenu 原 Demo）：分类菜单（吃/喝/玩/逛，data.json）单选一个标签，
//  左上角按钮打开多选筛选（地区过滤、菜品过滤）。原 Demo 只有筛选界面；这里每次选择都会生成 SQL，在 SQLite
//  的 places 表中查询，并在标签下方显示条件、SQL 与结果，选择保存在数据库中，再次打开时恢复。
//  The classify menu and the multiple-choice filter of the original app, with the same data source
//  (CYLDemoDataSource) and the core's CYLClassifyMenuViewController and CYLMultipleFilterController,
//  now linked to data: every selection runs a query on the Example's database.
//

#import <UIKit/UIKit.h>
@import CollectionViewClassifyMenu;
#import "CYLExampleDatabase.h"

NS_ASSUME_NONNULL_BEGIN

/// Keys of the selections saved in CYLExampleDatabase.
FOUNDATION_EXTERN NSString *const CYLMenuLinkageClassifyScenario;
FOUNDATION_EXTERN NSString *const CYLMenuLinkageFilterScenario;

@interface CYLMenuLinkageViewController : CYLClassifyMenuViewController

- (instancetype)initWithDatabase:(CYLExampleDatabase *)database NS_DESIGNATED_INITIALIZER;
/// On CYLExampleDatabase.sharedDatabase.
- (instancetype)init;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@property (nonatomic, strong, readonly) CYLExampleDatabase *database;
@property (nonatomic, strong, readonly) CYLMultipleFilterController *filterController;

/// The conditions: the classify menu's tag (nil for every tag), and the filter's regions and dishes
/// (empty for "全部").
@property (nonatomic, copy, readonly, nullable) NSString *selectedTag;
@property (nonatomic, copy, readonly) NSArray<NSString *> *selectedRegions;
@property (nonatomic, copy, readonly) NSArray<NSString *> *selectedDishes;
/// The last statement and its rows (name, category, tag, region, rating, price).
@property (nonatomic, strong, readonly) CYLExampleSQLQuery *lastQuery;
@property (nonatomic, copy, readonly) NSArray<NSDictionary<NSString *, id> *> *results;
/// Conditions, SQL and number of results, shown above the results.
@property (nonatomic, strong, readonly) UILabel *statusLabel;

+ (CYLExampleSQLQuery *)queryForTag:(nullable NSString *)tag regions:(NSArray<NSString *> *)regions dishes:(NSArray<NSString *> *)dishes;

/// As a tap on the classify menu: selects the tag, or clears it when it is already selected.
- (void)selectClassifyItemAtIndexPath:(NSIndexPath *)indexPath;
/// As choosing these filter items and tapping the filter's OK button.
- (void)confirmFilterSelection:(NSArray<NSIndexPath *> *)indexPaths;
/// Every tag, every region and dish ("重置筛选条件").
- (void)resetConditions;
/// Opens the multiple-choice filter, as the left bar button does.
- (void)showFilter;

@end

NS_ASSUME_NONNULL_END
