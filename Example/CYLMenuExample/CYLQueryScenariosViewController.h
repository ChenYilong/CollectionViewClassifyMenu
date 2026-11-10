//
//  CYLQueryScenariosViewController.h
//  CYLMenuExample
//
//  PlusButton 的子控制器：按场景分组的筛选演示。
//  - 查询参数设置：淘宝评价默认显示全部，条件太多时由用户多选输入（标签列表的用途），分别用内存、网络、
//    数据库（SQLite）三种方式筛选；
//  - 菜单选择：移植 CollectionViewClassifyMenu 原 Demo 的分类菜单与多选筛选，并与数据库联动；
//  - 数据库：各表的行数。
//  The plus button's child view controller: the filter demos grouped by scenario.
//

#import <UIKit/UIKit.h>
#import "CYLExampleDatabase.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLQueryScenario) {
    CYLQueryScenarioReviewsDatabase = 0,
    CYLQueryScenarioReviewsMemory,
    CYLQueryScenarioReviewsNetwork,
    CYLQueryScenarioMenuLinkage,
};

@interface CYLQueryScenariosViewController : UITableViewController
- (instancetype)initWithDatabase:(CYLExampleDatabase *)database NS_DESIGNATED_INITIALIZER;
- (instancetype)init;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
@property (nonatomic, strong, readonly) CYLExampleDatabase *database;
/// The demo a row opens, with `hidesBottomBarWhenPushed`.
- (UIViewController *)viewControllerForScenario:(CYLQueryScenario)scenario;
/// Pushes a demo, as tapping its row does.
- (void)openScenario:(CYLQueryScenario)scenario;
@end

NS_ASSUME_NONNULL_END
