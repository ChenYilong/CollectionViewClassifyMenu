//
//  CYLExampleAppDelegate.m
//  CYLMenuExample
//

#import "CYLExampleAppDelegate.h"
#import "CYLProductViewController.h"
#import "CYLReviewListViewController.h"
#import "CYLSearchCategoryViewController.h"

@implementation CYLExampleAppDelegate

+ (CYLTabBarController *)makeRootTabBarController {
    UINavigationController *reviews = [[UINavigationController alloc] initWithRootViewController:[[CYLProductViewController alloc] init]];
    UINavigationController *search = [[UINavigationController alloc] initWithRootViewController:[[CYLSearchCategoryViewController alloc] init]];
    NSArray *attributes = @[
        @{CYLTabBarItemTitle: @"场景一：评价筛选",
          CYLTabBarItemImage: [UIImage systemImageNamed:@"cart"],
          CYLTabBarItemSelectedImage: [UIImage systemImageNamed:@"cart.fill"]},
        @{CYLTabBarItemTitle: @"场景二：搜索分类",
          CYLTabBarItemImage: [UIImage systemImageNamed:@"magnifyingglass.circle"],
          CYLTabBarItemSelectedImage: [UIImage systemImageNamed:@"magnifyingglass.circle.fill"]},
    ];
    return [[CYLTabBarController alloc] initWithViewControllers:@[reviews, search] tabBarItemsAttributes:attributes];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    CYLTabBarController *tabs = [[self class] makeRootTabBarController];
    self.window.rootViewController = tabs;
    [self.window makeKeyAndVisible];
    // `-CYLExampleScreen <name>` opens a screen directly (used by scripts/example-screenshots.sh).
    [[self class] openScreen:[[NSUserDefaults standardUserDefaults] stringForKey:@"CYLExampleScreen"] inTabBarController:tabs];
    return YES;
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
