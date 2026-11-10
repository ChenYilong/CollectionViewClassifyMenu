//
//  CYLExampleAppDelegate.m
//  CYLMenuExample
//

#import "CYLExampleAppDelegate.h"
#import "CYLExampleListViewController.h"
#import "CYLProductViewController.h"
#import "CYLReviewListViewController.h"
#import "CYLSearchCategoryViewController.h"

@implementation CYLExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    CYLExampleListViewController *list = [[CYLExampleListViewController alloc] initWithStyle:UITableViewStyleInsetGrouped];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:list];
    // `-CYLExampleScreen <name>` opens a screen directly (used by scripts/example-screenshots.sh).
    NSString *screen = [[NSUserDefaults standardUserDefaults] stringForKey:@"CYLExampleScreen"];
    NSArray<UIViewController *> *stack = [[self class] viewControllersForScreen:screen];
    if (stack.count > 0) {
        [navigation setViewControllers:[@[list] arrayByAddingObjectsFromArray:stack] animated:NO];
    }
    self.window.rootViewController = navigation;
    [self.window makeKeyAndVisible];
    UIViewController *top = stack.lastObject;
    if ([screen isEqualToString:@"reviews-expanded"]) {
        CYLReviewListViewController *reviews = (CYLReviewListViewController *)top;
        [reviews loadViewIfNeeded];
        [reviews.filterView setExpanded:YES forSection:0 animated:NO];
    } else if ([screen isEqualToString:@"search-gossip"] || [screen isEqualToString:@"search-jobs"]) {
        CYLSearchCategoryViewController *search = (CYLSearchCategoryViewController *)top;
        [search loadViewIfNeeded];
        [search selectCategory:[screen hasSuffix:@"jobs"] ? CYLSearchCategoryJobs : CYLSearchCategoryGossip];
    }
    return YES;
}

+ (NSArray<UIViewController *> *)viewControllersForScreen:(NSString *)screen {
    if ([screen isEqualToString:@"product"]) {
        return @[[[CYLProductViewController alloc] init]];
    }
    if ([screen hasPrefix:@"reviews"]) {
        NSUInteger index = [screen isEqualToString:@"reviews-good"] ? 1 : 0;
        return @[[[CYLProductViewController alloc] init],
                 [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:index]];
    }
    if ([screen hasPrefix:@"search"]) {
        return @[[[CYLSearchCategoryViewController alloc] init]];
    }
    return @[];
}

@end
