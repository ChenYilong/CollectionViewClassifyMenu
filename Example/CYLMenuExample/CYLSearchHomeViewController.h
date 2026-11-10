//
//  CYLSearchHomeViewController.h
//  CYLMenuExample
//
//  场景二首页（根 TabBar 的第二个 Tab）：点击搜索框 push 搜索分类页，push 后隐藏根 TabBar。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CYLSearchCategoryViewController;

@interface CYLSearchHomeViewController : UIViewController
@property (nonatomic, strong, readonly) UIButton *searchButton;
/// Pushes the search screen with the root tab bar hidden, and returns it.
- (CYLSearchCategoryViewController *)openSearch;
@end

NS_ASSUME_NONNULL_END
