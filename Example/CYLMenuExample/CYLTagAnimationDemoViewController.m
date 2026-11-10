//
//  CYLTagAnimationDemoViewController.m
//  CYLMenuExample
//

#import "CYLTagAnimationDemoViewController.h"
#import "CYLExampleLocalization.h"

@interface CYLTagAnimationDemoViewController () <CYLMenuDelegate>
@property (nonatomic, strong, readwrite) CYLTagListView *tagListView;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation CYLTagAnimationDemoViewController

+ (NSArray<NSString *> *)sectionIdentifiers {
    return @[@"lottie", @"lottie-images", @"lottie-green", @"pag", @"rive", @"rive-icons", @"gif", @"images"];
}

/// A file of CYLMenuExample.bundle/Animations (copied from CYLTabBarController's examples).
+ (NSString *)animation:(NSString *)path {
    return [@"CYLMenuExample.bundle/Animations" stringByAppendingPathComponent:path];
}

+ (NSDictionary *)item:(NSString *)title animation:(nullable NSString *)animation image:(nullable NSString *)image {
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObject:CYLExampleLocalizedString(title) forKey:CYLTagItemTitle];
    if (animation) item[CYLTagItemAnimation] = animation;
    if (image) item[CYLTagItemImage] = image;
    return item;
}

+ (NSDictionary *)item:(NSString *)title rive:(NSString *)name options:(NSDictionary<NSString *, NSString *> *)options {
    NSMutableDictionary *item = [[self item:title animation:[self animation:[NSString stringWithFormat:@"Rive/%@.riv", name]] image:nil] mutableCopy];
    item[CYLTagItemAnimationOptions] = options;
    return item;
}

+ (NSDictionary<NSString *, id> *)configuration {
    NSArray *sections = @[
        @{CYLTagSectionTitle: @"Lottie · pod 'CYLTabBarController/Lottie'", CYLTagSectionItems: @[
            [self item:@"首页" animation:[self animation:@"Lottie/tab_home_animate.json"] image:nil],
            [self item:@"消息" animation:[self animation:@"Lottie/tab_message_animate.json"] image:nil],
            [self item:@"搜索" animation:[self animation:@"Lottie/tab_search_animate.json"] image:nil],
            [self item:@"我的" animation:[self animation:@"Lottie/tab_me_animate.json"] image:nil]]},
        // Lottie files with image assets next to them, and placeholder images for when no engine is linked.
        @{CYLTagSectionTitle: CYLExampleLocalizedString(@"Lottie（带图片资源与占位图）"), CYLTagSectionItems: @[
            [self item:@"首页" animation:[self animation:@"Lottie/gray_tabbar_home_animation.json"] image:@"gray_tabbar_home_animation_lottie_placeholder"],
            [self item:@"消息" animation:[self animation:@"Lottie/gray_tabbar_message_animation.json"] image:@"gray_tabbar_message_animation_lottie_placeholder"],
            [self item:@"我的" animation:[self animation:@"Lottie/gray_tabbar_me_animation.json"] image:@"gray_tabbar_me_animation_lottie_placeholder"]]},
        @{CYLTagSectionTitle: CYLExampleLocalizedString(@"Lottie（绿色主题）"), CYLTagSectionItems: @[
            [self item:@"首页" animation:[self animation:@"Lottie/green_lottie_tab_home.json"] image:nil],
            [self item:@"资讯" animation:[self animation:@"Lottie/green_lottie_tab_news.json"] image:nil],
            [self item:@"发现" animation:[self animation:@"Lottie/green_lottie_tab_discover.json"] image:nil],
            [self item:@"我的" animation:[self animation:@"Lottie/green_lottie_tab_mine.json"] image:nil]]},
        // The PAG tab icons of CYLTabBarController's Example-PAG (tab_*.pag, downloaded by `pod install`), and two
        // libpag samples. 1.pag's first frame is empty: while not selected it rests on its last frame instead.
        @{CYLTagSectionTitle: @"PAG · pod 'CYLTabBarController/PAG'", CYLTagSectionItems: @[
            [self item:@"首页" animation:@"pag-ios/tab_home.pag" image:nil],
            [self item:@"健康" animation:@"pag-ios/tab_health.pag" image:nil],
            [self item:@"动态" animation:@"pag-ios/tab_moments.pag" image:nil],
            [self item:@"我的" animation:@"pag-ios/tab_me.pag" image:nil],
            [self item:@"动效一" animation:@"pag-ios/0.pag" image:nil],
            @{CYLTagItemTitle: CYLExampleLocalizedString(@"动效二"), CYLTagItemAnimation: @"pag-ios/1.pag",
              CYLTagItemAnimationRestingProgress: @1}]},
        // The options CYLTabBarController's Rive examples use for each file (Example-SwiftUI-Rive): a Rive icon needs its
        // state machine and input (or animation), given with CYLTagItemAnimationOptions. icons.riv follows, on dark tags.
        @{CYLTagSectionTitle: @"Rive · pod 'CYLTabBarController/Rive'", CYLTagSectionItems: @[
            [self item:@"首页" rive:@"house" options:@{@"stateMachine": @"State Machine 1"}],
            [self item:@"完成" rive:@"check" options:@{@"stateMachine": @"State Machine 1", @"triggerInput": @"Check"}],
            [self item:@"菜单" rive:@"menu_button" options:@{@"stateMachine": @"State Machine", @"input": @"isOpen", @"duration": @"0"}],
            [self item:@"按钮" rive:@"button" options:@{@"animation": @"active"}],
            [self item:@"形状" rive:@"shapes" options:@{@"legacy": @"1"}],
            // truck.riv from rive-app/rive-ios's examples, in place of confetti.riv (empty until its explosion plays).
            [self item:@"卡车" rive:@"truck" options:@{@"legacy": @"1"}]]},
        // icons.riv, as on CYLTabBarController's dark Rive tab bar: its artboards are white strokes, so this
        // section's tags are dark (CYLTagSectionStyle, over the list's style).
        @{CYLTagSectionTitle: CYLExampleLocalizedString(@"Rive · icons.riv（深色标签）"),
          CYLTagSectionStyle: @{
              CYLMenuStyleNormal: @{CYLTagAppearanceBackgroundColor: @"#17203A", CYLTagAppearanceTextColor: @"#FFFFFF",
                                    CYLTagAppearanceBorderColor: @"#17203A"},
              CYLMenuStyleSelected: @{CYLTagAppearanceBackgroundColor: @"#3A4E8C", CYLTagAppearanceTextColor: @"#FFFFFF",
                                      CYLTagAppearanceBorderColor: @"#6792FF"}},
          CYLTagSectionItems: @[
            [self item:@"聊天" rive:@"icons" options:@{@"artboard": @"CHAT", @"stateMachine": @"CHAT_Interactivity", @"input": @"active"}],
            [self item:@"搜索" rive:@"icons" options:@{@"artboard": @"SEARCH", @"stateMachine": @"SEARCH_Interactivity", @"input": @"active"}],
            [self item:@"计时" rive:@"icons" options:@{@"artboard": @"TIMER", @"stateMachine": @"TIMER_Interactivity", @"input": @"active"}],
            [self item:@"提醒" rive:@"icons" options:@{@"artboard": @"BELL", @"stateMachine": @"BELL_Interactivity", @"input": @"active"}],
            [self item:@"我的" rive:@"icons" options:@{@"artboard": @"USER", @"stateMachine": @"USER_Interactivity", @"input": @"active"}]]},
        @{CYLTagSectionTitle: @"GIF · pod 'CYLTabBarController/GIF'", CYLTagSectionItems: @[
            [self item:@"火焰" animation:[self animation:@"GIF/tab_fire.gif"] image:nil],
            [self item:@"火箭" animation:[self animation:@"GIF/tab_rocket.gif"] image:nil],
            [self item:@"星星" animation:[self animation:@"GIF/tab_star.gif"] image:nil],
            [self item:@"示例" animation:[self animation:@"GIF/cyl_tab_sample_animated.gif"] image:nil]]},
        // CYLTabBarController's tab images: normal and highlighted.
        @{CYLTagSectionTitle: CYLExampleLocalizedString(@"静态图片（CYLTabBarController Example）"), CYLTagSectionItems: @[
            @{CYLTagItemTitle: CYLExampleLocalizedString(@"首页"), CYLTagItemImage: @"home_normal", CYLTagItemSelectedImage: @"home_highlight"},
            @{CYLTagItemTitle: CYLExampleLocalizedString(@"同城"), CYLTagItemImage: @"fishpond_normal", CYLTagItemSelectedImage: @"fishpond_highlight"},
            @{CYLTagItemTitle: CYLExampleLocalizedString(@"发布"), CYLTagItemImage: @"post_normal", CYLTagItemSelectedImage: @"post_highlight"},
            @{CYLTagItemTitle: CYLExampleLocalizedString(@"消息"), CYLTagItemImage: @"message_normal", CYLTagItemSelectedImage: @"message_highlight"},
            @{CYLTagItemTitle: CYLExampleLocalizedString(@"我的"), CYLTagItemImage: @"account_normal", CYLTagItemSelectedImage: @"account_highlight"}]},
    ];
    NSMutableArray *selected = [NSMutableArray array];
    for (NSUInteger section = 0; section < sections.count; section++) {
        [selected addObject:[NSString stringWithFormat:@"%lu-0", (unsigned long)section]];
    }
    return @{
        CYLTagListViewSelectionMode: @"single",
        CYLTagListViewAllowsEmptySelection: @NO,
        CYLTagListViewSelectedItems: selected,
        CYLTagListViewStyle: @{
            CYLMenuStyleImageSize: @"{28, 28}",
            CYLMenuStyleImageTitleSpacing: @6,
            CYLMenuStyleItemHeight: @44,
            CYLMenuStyleLayoutCentered: @YES,
            CYLMenuStyleSectionInsets: @[@6, @16, @14, @16],
            CYLMenuStyleNormal: @{CYLTagAppearanceCornerRadius: @0, CYLTagAppearanceMargin: @12,
                                  CYLTagAppearanceBorderColor: @"#D1D1D6", CYLTagAppearanceBorderWidth: @1},
            CYLMenuStyleSelected: @{CYLTagAppearanceCornerRadius: @0, CYLTagAppearanceMargin: @12,
                                    CYLTagAppearanceBackgroundColor: @"#FFF1E6", CYLTagAppearanceTextColor: @"#FF6A00",
                                    CYLTagAppearanceBorderColor: @"#FF6A00", CYLTagAppearanceBorderWidth: @1},
        },
        CYLTagListViewSections: sections,
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigationItem, not title: a view controller's title would replace its tab's title.
    self.navigationItem.title = CYLExampleLocalizedString(@"动效图标");
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CYLExampleLocalizedString(@"全部播放")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(playSelectedAnimations)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"1x" style:UIBarButtonItemStylePlain
                                                                            target:self action:@selector(changeSpeed)];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.statusLabel.adjustsFontForContentSizeCategory = YES;
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.text = [CYLTagButton isAnimationEngineAvailable]
        ? CYLExampleLocalizedString(@"动效引擎：CYLTabBarItemAnimationFactory 已链接")
        : CYLExampleLocalizedString(@"动效引擎未链接：显示静态图标");
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];

    self.tagListView = [CYLTagListView tagListViewWithConfiguration:[[self class] configuration]];
    self.tagListView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tagListView.menuDelegate = self;
    [self.view addSubview:self.tagListView];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.topAnchor constraintEqualToAnchor:safe.topAnchor constant:8],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [self.tagListView.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:4],
        [self.tagListView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tagListView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tagListView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (UICollectionView *)collectionView {
    return [self.tagListView valueForKey:@"collectionView"];
}

- (void)playSelectedAnimations {
    [self.collectionView layoutIfNeeded];
    for (NSIndexPath *indexPath in self.tagListView.selectedIndexPaths) {
        CYLTagButton *button = [[self.collectionView cellForItemAtIndexPath:indexPath] valueForKey:@"button"];
        [button playAnimation];
    }
}

- (void)changeSpeed {
    CYLMenuStyle *style = [self.tagListView.style copy];
    NSArray<NSNumber *> *speeds = @[@1, @2, @0.5];
    NSUInteger index = [speeds indexOfObject:@(style.animationSpeed)];
    style.animationSpeed = speeds[(index == NSNotFound ? 0 : index + 1) % speeds.count].doubleValue;
    self.tagListView.style = style;
    self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"%gx", style.animationSpeed];
    [self playSelectedAnimations];
}

- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *section = [self.tagListView.menuDataSource menuTitleForSection:indexPath.section];
    NSString *title = [self.tagListView.menuDataSource menuTitleForItemAtIndexPath:indexPath];
    self.statusLabel.text = [NSString stringWithFormat:CYLExampleLocalizedString(@"点击「%@」"), [NSString stringWithFormat:@"%@ · %@", section, title]];
}

- (void)scrollToSectionIdentifier:(NSString *)identifier {
    NSUInteger section = [[[self class] sectionIdentifiers] indexOfObject:identifier];
    if (section == NSNotFound) return;
    [self loadViewIfNeeded];
    [self.view layoutIfNeeded];
    [self.tagListView scrollToSection:(NSInteger)section animated:NO];
}

@end
