//
//  CYLExamplePlusButton.h
//  CYLMenuExample
//
//  The root tab bar's plus button (CYLTabBarController's CYLPlusButton). It sits in the middle of the
//  bottom tab bar and opens the scenario list of the filter demos (CYLQueryScenariosViewController),
//  selected like the other tabs. It has its own tab bar context, so the category tab bar nested in
//  scenario 2 has no plus button.
//

#import <UIKit/UIKit.h>
#import <CYLTabBarController/CYLTabBarController.h>

NS_ASSUME_NONNULL_BEGIN

/// The context of the Example's root tab bar controller and of its plus button.
FOUNDATION_EXTERN NSString *const CYLExampleRootTabBarContext;

@interface CYLExamplePlusButton : CYLPlusButton <CYLPlusButtonSubclassing>
/// The plus button's tab: a navigation controller with the scenario list.
+ (UINavigationController *)plusNavigationController;
@end

NS_ASSUME_NONNULL_END
