//
//  CYLExampleAppDelegate.m
//  CYLMenuExample
//

#import "CYLExampleAppDelegate.h"
#import "CYLProductViewController.h"
#import "CYLReviewListViewController.h"
#import "CYLSearchCategoryViewController.h"
#import "CYLExampleLocalization.h"

@implementation CYLExampleAppDelegate

+ (CYLTabBarController *)makeRootTabBarController {
    UINavigationController *reviews = [[UINavigationController alloc] initWithRootViewController:[[CYLProductViewController alloc] init]];
    UINavigationController *search = [[UINavigationController alloc] initWithRootViewController:[[CYLSearchCategoryViewController alloc] init]];
    NSArray *attributes = @[
        @{CYLTabBarItemTitle: CYLExampleLocalizedString(@"场景一：评价筛选"),
          CYLTabBarItemImage: [UIImage systemImageNamed:@"cart"],
          CYLTabBarItemSelectedImage: [UIImage systemImageNamed:@"cart.fill"]},
        @{CYLTabBarItemTitle: CYLExampleLocalizedString(@"场景二：搜索分类"),
          CYLTabBarItemImage: [UIImage systemImageNamed:@"magnifyingglass.circle"],
          CYLTabBarItemSelectedImage: [UIImage systemImageNamed:@"magnifyingglass.circle.fill"]},
    ];
    return [[CYLTabBarController alloc] initWithViewControllers:@[reviews, search] tabBarItemsAttributes:attributes];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // `-CYLExampleLanguage en` (or a screen name ending in "@en") switches the language of the
    // component and the Example, as an in-app language setting would.
    NSString *screen = [[NSUserDefaults standardUserDefaults] stringForKey:@"CYLExampleScreen"];
    NSString *language = [[NSUserDefaults standardUserDefaults] stringForKey:@"CYLExampleLanguage"];
    NSRange at = [screen rangeOfString:@"@"];
    if (at.location != NSNotFound) {
        language = [screen substringFromIndex:at.location + 1];
        screen = [screen substringToIndex:at.location];
    }
    if (language.length > 0) {
        CYLMenuResources.preferredLanguage = language;
    }
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    CYLTabBarController *tabs = [[self class] makeRootTabBarController];
    self.window.rootViewController = tabs;
    [self.window makeKeyAndVisible];
    // `-CYLExampleScreen <name>` opens a screen directly (used by scripts/example-screenshots.sh).
    [[self class] openScreen:screen inTabBarController:tabs];
    if (screen.length > 0) {
        // Layout report for scripts/example-screenshots.sh, printed before the screenshot is taken.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[self class] reportLayoutOfScreen:screen inTabBarController:tabs];
        });
    }
    return YES;
}

+ (void)reportTagList:(CYLTagListView *)view named:(NSString *)name {
    UICollectionView *collection = [view valueForKey:@"collectionView"];
    NSMutableString *line = [NSMutableString stringWithFormat:@"[CYLExampleLayout] %@ frame=%@ hidden=%d window=%d contentHeight=%.1f collection=%@ contentSize=%@ offset=%@ adjustedInset=%@ sections=%ld",
                             name, NSStringFromCGRect(view.frame), view.hidden, view.window != nil, view.contentHeight,
                             NSStringFromCGRect(collection.frame), NSStringFromCGSize(collection.contentSize),
                             NSStringFromCGPoint(collection.contentOffset), NSStringFromUIEdgeInsets(collection.adjustedContentInset),
                             (long)collection.numberOfSections];
    for (NSInteger section = 0; section < collection.numberOfSections; section++) {
        [line appendFormat:@" items[%ld]=%ld", (long)section, (long)[collection numberOfItemsInSection:section]];
    }
    [line appendFormat:@" visibleCells=%lu", (unsigned long)collection.visibleCells.count];
    UICollectionViewCell *first = collection.visibleCells.firstObject;
    if (first) {
        [line appendFormat:@" firstCell=%@ inWindow=%@ alpha=%.2f hidden=%d", NSStringFromCGRect(first.frame),
                           NSStringFromCGRect([first convertRect:first.bounds toView:nil]), first.alpha, first.hidden];
    }
    fprintf(stderr, "%s\n", line.UTF8String);
}

+ (void)reportLayoutOfScreen:(NSString *)screen inTabBarController:(CYLTabBarController *)tabs {
    UINavigationController *navigation = (UINavigationController *)tabs.selectedViewController;
    UIViewController *top = navigation.topViewController;
    fprintf(stderr, "[CYLExampleLayout] screen=%s top=%s\n", screen.UTF8String, NSStringFromClass([top class]).UTF8String);
    if ([top isKindOfClass:[CYLReviewListViewController class]]) {
        CYLReviewListViewController *reviews = (CYLReviewListViewController *)top;
        fprintf(stderr, "[CYLExampleLayout] tableHeader=%s table=%s\n",
                NSStringFromCGRect(reviews.tableView.tableHeaderView.frame).UTF8String,
                NSStringFromCGRect(reviews.tableView.frame).UTF8String);
        [self reportTagList:reviews.filterView named:@"reviewFilter"];
    } else if ([top isKindOfClass:[CYLProductViewController class]]) {
        [self reportTagList:((CYLProductViewController *)top).previewView named:@"productPreview"];
    } else if ([top isKindOfClass:[CYLSearchCategoryViewController class]]) {
        CYLSearchCategoryViewController *search = (CYLSearchCategoryViewController *)top;
        UITabBar *bar = search.categoryTabBarController.tabBar;
        fprintf(stderr, "[CYLExampleLayout] categoryTabBar=%s\n", NSStringFromCGRect([bar convertRect:bar.bounds toView:nil]).UTF8String);
        [self reportTagList:search.tagListView named:@"searchTags"];
    }
}

+ (void)openScreen:(NSString *)screen inTabBarController:(CYLTabBarController *)tabs {
    if ([screen hasPrefix:@"reviews"]) {
        tabs.selectedIndex = 0;
        UINavigationController *navigation = (UINavigationController *)tabs.viewControllers[0];
        NSUInteger index = [screen isEqualToString:@"reviews-good"] ? 1 : 0;
        CYLReviewListViewController *reviews = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:index];
        reviews.hidesBottomBarWhenPushed = YES;
        [navigation pushViewController:reviews animated:NO];
        if ([screen isEqualToString:@"reviews-expanded"]) {
            [reviews loadViewIfNeeded];
            [reviews.filterView setExpanded:YES forSection:0 animated:NO];
        }
    } else if ([screen hasPrefix:@"search"]) {
        tabs.selectedIndex = 1;
        UINavigationController *navigation = (UINavigationController *)tabs.viewControllers[1];
        CYLSearchCategoryViewController *search = (CYLSearchCategoryViewController *)navigation.viewControllers.firstObject;
        if ([screen isEqualToString:@"search-gossip"]) {
            [search selectCategory:CYLSearchCategoryGossip];
        } else if ([screen isEqualToString:@"search-jobs"]) {
            [search selectCategory:CYLSearchCategoryJobs];
        }
    }
}

@end
