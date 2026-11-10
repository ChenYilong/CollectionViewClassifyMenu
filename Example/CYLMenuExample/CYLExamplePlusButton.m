//
//  CYLExamplePlusButton.m
//  CYLMenuExample
//

#import "CYLExamplePlusButton.h"
#import "CYLQueryScenariosViewController.h"
#import "CYLExampleLocalization.h"

NSString *const CYLExampleRootTabBarContext = @"CYLMenuExampleRoot";

@implementation CYLExamplePlusButton

+ (id)plusButton {
    UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:30 weight:UIImageSymbolWeightSemibold];
    UIImage *image = [[UIImage systemImageNamed:@"plus.circle.fill" withConfiguration:configuration]
                      imageWithTintColor:[UIColor systemOrangeColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
    NSString *title = CYLExampleLocalizedString(@"查询筛选");
    CYLExamplePlusButton *button = [self cyl_plusButtonWithImage:image title:title selectedTitle:title
                                              selectedTitleColor:[UIColor systemOrangeColor]];
    button.accessibilityLabel = title;
    button.accessibilityHint = CYLExampleLocalizedString(@"按场景分组的筛选演示");
    return button;
}

+ (NSUInteger)indexOfPlusButtonInTabBar {
    // In the middle of the four tabs.
    return 2;
}

+ (UINavigationController *)plusNavigationController {
    return [[UINavigationController alloc] initWithRootViewController:[[CYLQueryScenariosViewController alloc] init]];
}

+ (UIViewController *)plusChildViewController {
    return [self plusNavigationController];
}

+ (BOOL)shouldSelectPlusChildViewController {
    return YES;
}

+ (NSString *)tabBarContext {
    return CYLExampleRootTabBarContext;
}

+ (NSString *)tabBarItemIdentifier {
    return @"plus";
}

@end
