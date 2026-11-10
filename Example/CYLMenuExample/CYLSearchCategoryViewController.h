//
//  CYLSearchCategoryViewController.h
//  CYLMenuExample
//
//  场景二：脉脉搜索分类。搜索框 + 找人/动态/八卦/职位 四个分类，
//  职位分类左侧为职位类别，右侧为热搜关键词，并带行业选择。
//

#import <UIKit/UIKit.h>
@import CollectionViewClassifyMenu;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLSearchCategory) {
    CYLSearchCategoryPeople = 0,
    CYLSearchCategoryFeeds,
    CYLSearchCategoryGossip,
    CYLSearchCategoryJobs,
};

@interface CYLSearchCategoryViewController : UIViewController

@property (nonatomic, strong, readonly) UISearchBar *searchBar;
@property (nonatomic, strong, readonly) UISegmentedControl *categoryControl;
/// Tags of the selected category (the job keywords on the 职位 tab).
@property (nonatomic, strong, readonly) CYLTagListView *tagListView;
@property (nonatomic, strong, readonly) UITableView *jobCategoryTableView;
@property (nonatomic, strong, readonly) UIButton *industryButton;
@property (nonatomic, assign, readonly) CYLSearchCategory category;
@property (nonatomic, copy, readonly) NSString *industry;

- (void)selectCategory:(CYLSearchCategory)category;
- (void)selectJobCategoryAtIndex:(NSUInteger)index;
- (void)selectIndustry:(NSString *)industry;
+ (NSArray<NSString *> *)industries;

@end

NS_ASSUME_NONNULL_END
