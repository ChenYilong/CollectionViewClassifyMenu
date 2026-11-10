//
//  CYLExampleAppDelegate.m
//  CYLMenuExample
//

#import "CYLExampleAppDelegate.h"
#import "CYLProductViewController.h"
#import "CYLReviewListViewController.h"
#import "CYLSearchCategoryViewController.h"
#import "CYLSearchHomeViewController.h"
#import "CYLTagStyleDemoViewController.h"
#import "CYLTagConfigurationDemoViewController.h"
#import "CYLTagAnimationDemoViewController.h"
#import "CYLExampleLocalization.h"

@implementation CYLExampleAppDelegate

+ (CYLTabBarController *)makeRootTabBarController {
    UINavigationController *reviews = [[UINavigationController alloc] initWithRootViewController:[[CYLProductViewController alloc] init]];
    UINavigationController *search = [[UINavigationController alloc] initWithRootViewController:[[CYLSearchHomeViewController alloc] init]];
    NSArray *attributes = @[
        @{CYLTabBarItemTitle: CYLExampleLocalizedString(@"场景一：评价筛选"),
          CYLTabBarItemImage: [UIImage systemImageNamed:@"cart"],
          CYLTabBarItemSelectedImage: [UIImage systemImageNamed:@"cart.fill"]},
        @{CYLTabBarItemTitle: CYLExampleLocalizedString(@"场景二：搜索分类"),
          CYLTabBarItemImage: [UIImage systemImageNamed:@"magnifyingglass.circle"],
          CYLTabBarItemSelectedImage: [UIImage systemImageNamed:@"magnifyingglass.circle.fill"]},
        @{CYLTabBarItemTitle: CYLExampleLocalizedString(@"样式"),
          CYLTabBarItemImage: [UIImage systemImageNamed:@"paintbrush"],
          CYLTabBarItemSelectedImage: [UIImage systemImageNamed:@"paintbrush.fill"]},
        @{CYLTabBarItemTitle: CYLExampleLocalizedString(@"动效"),
          CYLTabBarItemImage: [UIImage systemImageNamed:@"sparkles"],
          CYLTabBarItemSelectedImage: [UIImage systemImageNamed:@"sparkles"]},
    ];
    UINavigationController *animations = [[UINavigationController alloc] initWithRootViewController:[[CYLTagAnimationDemoViewController alloc] init]];
    UINavigationController *styles = [[UINavigationController alloc] initWithRootViewController:[[CYLTagStyleDemoViewController alloc] init]];
    return [[CYLTabBarController alloc] initWithViewControllers:@[reviews, search, styles, animations] tabBarItemsAttributes:attributes];
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
        NSURL *documents = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
        [[NSFileManager defaultManager] removeItemAtURL:[documents URLByAppendingPathComponent:@"CYLExampleLayout.txt"] error:NULL];
        // Layout report for scripts/example-screenshots.sh, printed before the screenshot is taken.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[self class] reportLayoutOfScreen:screen inTabBarController:tabs];
        });
    }
    return YES;
}

/// Appends a line to Documents/CYLExampleLayout.txt, which scripts/example-screenshots.sh copies
/// next to each screenshot.
+ (void)appendLayoutReport:(NSString *)line {
    NSLog(@"%@", line);
    NSURL *documents = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *file = [documents URLByAppendingPathComponent:@"CYLExampleLayout.txt"];
    NSString *existing = [NSString stringWithContentsOfURL:file encoding:NSUTF8StringEncoding error:NULL] ?: @"";
    [[existing stringByAppendingFormat:@"%@\n", line] writeToURL:file atomically:YES encoding:NSUTF8StringEncoding error:NULL];
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
        for (UIView *subview in first.contentView.subviews) {
            [line appendFormat:@" sub=%@%@", NSStringFromClass([subview class]), NSStringFromCGRect(subview.frame)];
        }
    }
    [line appendFormat:@" collectionHidden=%d alpha=%.2f bg=%@ superviews=", collection.hidden, collection.alpha, collection.backgroundColor];
    for (UIView *v = view.superview; v; v = v.superview) [line appendFormat:@"%@%@,", NSStringFromClass([v class]), NSStringFromCGRect(v.frame)];
    [self appendLayoutReport:line];
}

+ (void)reportLayoutOfScreen:(NSString *)screen inTabBarController:(CYLTabBarController *)tabs {
    UINavigationController *navigation = (UINavigationController *)tabs.selectedViewController;
    UIViewController *top = navigation.topViewController;
    [self appendLayoutReport:[NSString stringWithFormat:@"[CYLExampleLayout] screen=%@ top=%@", screen, NSStringFromClass([top class])]];
    if ([top isKindOfClass:[CYLReviewListViewController class]]) {
        CYLReviewListViewController *reviews = (CYLReviewListViewController *)top;
        [self appendLayoutReport:[NSString stringWithFormat:@"[CYLExampleLayout] table=%@ rows=%ld status=%@",
                                  NSStringFromCGRect(reviews.tableView.frame), (long)[reviews.tableView numberOfRowsInSection:0],
                                  [reviews.statusLabel.text stringByReplacingOccurrencesOfString:@"\n" withString:@" | "]]];
        [self reportTagList:reviews.filterView named:@"reviewFilter"];
    } else if ([top isKindOfClass:[CYLProductViewController class]]) {
        [self reportTagList:((CYLProductViewController *)top).previewView named:@"productPreview"];
    } else if ([top isKindOfClass:[CYLSearchCategoryViewController class]]) {
        CYLSearchCategoryViewController *search = (CYLSearchCategoryViewController *)top;
        UITabBar *bar = search.categoryTabBarController.tabBar;
        [self appendLayoutReport:[NSString stringWithFormat:@"[CYLExampleLayout] categoryTabBar=%@", NSStringFromCGRect([bar convertRect:bar.bounds toView:nil])]];
        [self reportTagList:search.tagListView named:@"searchTags"];
    } else if ([top isKindOfClass:[CYLTagStyleDemoViewController class]]) {
        [self reportTagList:((CYLTagStyleDemoViewController *)top).tagListView named:@"styleTags"];
    } else if ([top isKindOfClass:[CYLTagAnimationDemoViewController class]]) {
        [self reportTagList:((CYLTagAnimationDemoViewController *)top).tagListView named:@"animationTags"];
    }
}

+ (void)openScreen:(NSString *)screen inTabBarController:(CYLTabBarController *)tabs {
    if ([screen hasPrefix:@"reviews"]) {
        tabs.selectedIndex = 0;
        UINavigationController *navigation = (UINavigationController *)tabs.viewControllers[0];
        CYLReviewFilteringMode mode = [screen isEqualToString:@"reviews-network"] ? CYLReviewFilteringModeNetwork : CYLReviewFilteringModeMemory;
        CYLReviewListViewController *reviews = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:0 mode:mode];
        reviews.hidesBottomBarWhenPushed = YES;
        [navigation pushViewController:reviews animated:NO];
        if ([screen isEqualToString:@"reviews-expanded"]) {
            [reviews loadViewIfNeeded];
            [reviews.filterView setExpanded:YES forSection:0 animated:NO];
        } else if ([screen isEqualToString:@"reviews-multi"] || [screen isEqualToString:@"reviews-network"]) {
            // 好评 + 有图: both conditions must match.
            [reviews selectFilterIndexes:@[@1, @4]];
        }
    } else if ([screen hasPrefix:@"style"]) {
        tabs.selectedIndex = 2;
        UINavigationController *navigation = (UINavigationController *)tabs.viewControllers[2];
        CYLTagStyleDemoViewController *demo = (CYLTagStyleDemoViewController *)navigation.viewControllers.firstObject;
        NSDictionary<NSString *, NSArray<NSString *> *> *actions = @{
            // A capsule with a wider icon spacing, colored icons and a colored selection.
            @"style-custom": @[@"cornerRadius", @"imageTitleSpacing", @"iconColor.normal", @"backgroundColor.selected", @"borderColor", @"borderWidth"],
            @"style-icon-only": @[@"content.iconOnly", @"cornerRadius"],
            @"style-title-uncentered": @[@"content.titleOnly", @"layoutCentered"],
            @"style-lottie": @[@"animation.lottie"],
            @"style-pag": @[@"animation.pag"],
            @"style-rive": @[@"animation.rive"],
            @"style-gif": @[@"animation.gif"],
        };
        for (NSString *action in actions[screen]) {
            [demo performAction:action];
        }
    } else if ([screen hasPrefix:@"animations"]) {
        tabs.selectedIndex = 3;
        UINavigationController *navigation = (UINavigationController *)tabs.viewControllers[3];
        CYLTagAnimationDemoViewController *demo = (CYLTagAnimationDemoViewController *)navigation.viewControllers.firstObject;
        if ([screen isEqualToString:@"animations-speed"]) {
            [demo loadViewIfNeeded];
            [demo changeSpeed];
        } else if ([screen isEqualToString:@"animations-rive"]) {
            // PAG, Rive and icons.riv on dark tags, below the first screen.
            dispatch_async(dispatch_get_main_queue(), ^{
                [demo scrollToSectionIdentifier:@"pag"];
            });
        }
    } else if ([screen isEqualToString:@"config"]) {
        tabs.selectedIndex = 2;
        UINavigationController *navigation = (UINavigationController *)tabs.viewControllers[2];
        [navigation pushViewController:[[CYLTagConfigurationDemoViewController alloc] init] animated:NO];
    } else if ([screen isEqualToString:@"search-home"]) {
        tabs.selectedIndex = 1;
    } else if ([screen hasPrefix:@"search"]) {
        tabs.selectedIndex = 1;
        UINavigationController *navigation = (UINavigationController *)tabs.viewControllers[1];
        CYLSearchCategoryViewController *search = [[CYLSearchCategoryViewController alloc] init];
        search.hidesBottomBarWhenPushed = YES;
        [navigation pushViewController:search animated:NO];
        if ([screen isEqualToString:@"search-gossip"]) {
            [search selectCategory:CYLSearchCategoryGossip];
        } else if ([screen isEqualToString:@"search-jobs"]) {
            [search selectCategory:CYLSearchCategoryJobs];
        }
    }
}

@end
