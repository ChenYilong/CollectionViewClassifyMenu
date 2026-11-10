//
//  CYLTopTabBarController.m
//  CYLMenuExample
//

#import "CYLTopTabBarController.h"

@implementation CYLTopTabBarController

- (CGFloat)stripHeightForWidth:(CGFloat)width {
    CGFloat height = [self.tabBar sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
    return MAX(49, ceil(height));
}

@end
