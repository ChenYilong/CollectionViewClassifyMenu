//
//  CYLTopTabBarController.h
//  CYLMenuExample
//
//  A CYLTabBarController whose tab bar sits at the top of its view, for category
//  tabs inside a screen (脉脉 找人/动态/八卦/职位). The app's root tab bar is a
//  plain CYLTabBarController at the bottom: two tab bars with different roles.
//

#import <UIKit/UIKit.h>
#import <CYLTabBarController/CYLTabBarController.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN CGFloat const CYLTopTabBarHeight;

@interface CYLTopTabBarController : CYLTabBarController
@end

NS_ASSUME_NONNULL_END
