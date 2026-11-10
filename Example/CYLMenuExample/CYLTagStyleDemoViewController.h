//
//  CYLTagStyleDemoViewController.h
//  CYLMenuExample
//
//  样式演示（参照 CYLTabBarController 的 CYLFlatDesignTabBarDemoViewController）：上方为标签预览，
//  下方列表的每一行修改一个样式参数，点击后立即生效。标签的标题与图标参数参照
//  CYLFlatDesignTabBarItem，背景、边框、圆角参照 CYLBadgeView。
//

#import <UIKit/UIKit.h>
@import CollectionViewClassifyMenu;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLTagStyleDemoContent) {
    CYLTagStyleDemoContentIconAndTitle = 0,
    CYLTagStyleDemoContentIconOnly,
    CYLTagStyleDemoContentTitleOnly,
};

@interface CYLTagStyleDemoViewController : UIViewController

@property (nonatomic, strong, readonly) CYLTagListView *tagListView;
@property (nonatomic, strong, readonly) UITableView *tableView;
/// The style being edited; applied to the preview after every action.
@property (nonatomic, strong, readonly) CYLMenuStyle *style;
@property (nonatomic, assign, readonly) CYLTagStyleDemoContent content;
/// "lottie", "gif", "pag", "rive", or nil for static icons.
@property (nonatomic, copy, readonly, nullable) NSString *animationLibrary;

/// Identifiers of the actions, in table order (e.g. @"iconColor.normal", @"cornerRadius").
- (NSArray<NSArray<NSString *> *> *)actionIdentifiers;
/// Performs an action as a tap on its row does.
- (void)performAction:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
