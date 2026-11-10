//
//  CYLTopTabBarController.h
//  CYLMenuExample
//
//  A CYLTabBarController used as a tab strip at the top of a screen (脉脉 找人/
//  动态/八卦/职位). Its view is exactly as tall as its tab bar, so UIKit lays
//  the bar out as usual; the host shows the selected tab's content below it.
//  The app's root tab bar is a plain CYLTabBarController at the bottom: two tab
//  bars with different roles.
//

#import <UIKit/UIKit.h>
#import <CYLTabBarController/CYLTabBarController.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYLTopTabBarController : CYLTabBarController
/// Height the strip needs for its tab bar at the given width.
- (CGFloat)stripHeightForWidth:(CGFloat)width;
@end

NS_ASSUME_NONNULL_END
