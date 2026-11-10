//
//  CYLExampleAppDelegate.h
//  CYLMenuExample
//

#import <UIKit/UIKit.h>
#import <CYLTabBarController/CYLTabBarController.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYLExampleAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong, nullable) UIWindow *window;

/// The app's root tab bar: 场景一（淘宝评价筛选）and 场景二（脉脉搜索分类）, each in a
/// navigation controller. Scenario 2 has a second, top tab bar for its categories.
+ (CYLTabBarController *)makeRootTabBarController;
@end

NS_ASSUME_NONNULL_END
