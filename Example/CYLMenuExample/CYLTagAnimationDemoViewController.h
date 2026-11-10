//
//  CYLTagAnimationDemoViewController.h
//  CYLMenuExample
//
//  动效图标演示：CYLTabBarController Example 中的动效与图片资源（Lottie、PAG、Rive、GIF、静态图片），
//  每个分组一种动效库，点击标签播放，与 CYLTabBarController 的 Tab 图标相同。用字典（map）初始化。
//

#import <UIKit/UIKit.h>
@import CollectionViewClassifyMenu;

NS_ASSUME_NONNULL_BEGIN

@interface CYLTagAnimationDemoViewController : UIViewController
@property (nonatomic, strong, readonly) CYLTagListView *tagListView;
/// Section titles, one per library, in order.
+ (NSArray<NSString *> *)sectionIdentifiers;
/// The configuration (map) the tag list is created with.
+ (NSDictionary<NSString *, id> *)configuration;
/// Plays the animated icon of every selected tag, as the "全部播放" button does.
- (void)playSelectedAnimations;
/// Cycles the animation speed (1x, 2x, 0.5x), as the speed button does.
- (void)changeSpeed;
/// Scrolls the tags to a section of +sectionIdentifiers (e.g. @"pag").
- (void)scrollToSectionIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
