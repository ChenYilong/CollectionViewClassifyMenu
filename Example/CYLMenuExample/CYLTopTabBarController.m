//
//  CYLTopTabBarController.m
//  CYLMenuExample
//

#import "CYLTopTabBarController.h"

CGFloat const CYLTopTabBarHeight = 49;

@implementation CYLTopTabBarController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Move the bar to the top; the pages lay their content out below CYLTopTabBarHeight.
    self.tabBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CYLTopTabBarHeight);
    [self.view bringSubviewToFront:self.tabBar];
}

@end
