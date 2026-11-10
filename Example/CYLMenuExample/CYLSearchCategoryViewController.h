//
//  CYLSearchCategoryViewController.h
//  CYLMenuExample
//
//  场景二：脉脉搜索分类。由场景二首页 push 进入（隐藏根 TabBar）：搜索框 + 底部的分类
//  CYLTabBarController（找人/动态/八卦/职位），每个分类页由 CYLTagListView 展示标签；
//  职位页左侧为职位类别，右侧为热搜关键词并带行业选择。
//

#import <UIKit/UIKit.h>
@import CollectionViewClassifyMenu;
#import <CYLTabBarController/CYLTabBarController.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLSearchCategory) {
    CYLSearchCategoryPeople = 0,
    CYLSearchCategoryFeeds,
    CYLSearchCategoryGossip,
    CYLSearchCategoryJobs,
};

@interface CYLSearchCategoryViewController : UIViewController

@property (nonatomic, strong, readonly) UISearchBar *searchBar;
/// The category tabs: a CYLTabBarController embedded in this screen, its bar at the bottom.
@property (nonatomic, strong, readonly) CYLTabBarController *categoryTabBarController;
/// Tags of the selected category (the job keywords on the 职位 tab).
@property (nonatomic, strong, readonly) CYLTagListView *tagListView;
@property (nonatomic, strong, readonly) UITableView *jobCategoryTableView;
@property (nonatomic, strong, readonly) UIButton *industryButton;
@property (nonatomic, assign, readonly) CYLSearchCategory category;
@property (nonatomic, copy, readonly) NSString *industry;

- (void)selectCategory:(CYLSearchCategory)category;
- (CYLTagListView *)tagListViewForCategory:(CYLSearchCategory)category;
- (void)selectJobCategoryAtIndex:(NSUInteger)index;
- (void)selectIndustry:(NSString *)industry;
+ (NSArray<NSString *> *)industries;

@end

NS_ASSUME_NONNULL_END
