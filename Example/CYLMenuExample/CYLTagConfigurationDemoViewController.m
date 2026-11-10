//
//  CYLTagConfigurationDemoViewController.m
//  CYLMenuExample
//

#import "CYLTagConfigurationDemoViewController.h"
#import "CYLExampleLocalization.h"

@interface CYLTagConfigurationDemoViewController () <CYLMenuDelegate>
@property (nonatomic, strong, readwrite, nullable) CYLTagListView *fileTagListView;
@property (nonatomic, strong, readwrite) CYLTagListView *mapTagListView;
@property (nonatomic, strong, readwrite, nullable) NSError *configurationError;
@property (nonatomic, strong) UILabel *eventLabel;
@end

@implementation CYLTagConfigurationDemoViewController

+ (NSString *)configurationFilePath {
    return @"CYLMenuExample.bundle/Configurations/animated-tags.json";
}

+ (NSURL *)animationNamed:(NSString *)name {
    return [[NSBundle mainBundle] URLForResource:[@"CYLMenuExample.bundle/Animations" stringByAppendingPathComponent:name.stringByDeletingPathExtension]
                                   withExtension:name.pathExtension];
}

+ (NSDictionary<NSString *, id> *)mapConfiguration {
    // In code, values keep their types (UIColor, NSValue, NSURL...); strings work too.
    return @{
        CYLTagListViewSelectionMode : @(CYLMenuSelectionModeMultiple),
        CYLTagListViewFoldStyle : @(CYLMenuFoldStyleNone),
        CYLTagListViewScrollEnabled : @NO,
        CYLTagListViewSelectedItems : @[[NSIndexPath indexPathForItem:1 inSection:0]],
        CYLTagListViewStyle : @{
            CYLMenuStyleImageSize : [NSValue valueWithCGSize:CGSizeMake(20, 20)],
            CYLMenuStyleImageTitleSpacing : @4,
            CYLMenuStyleItemHeight : @36,
            CYLMenuStyleLayoutCentered : @YES,
            CYLMenuStyleNormal : @{ CYLTagAppearanceIconColor : UIColor.systemIndigoColor,
                                    CYLTagAppearanceBorderColor : UIColor.systemIndigoColor,
                                    CYLTagAppearanceBorderWidth : @1,
                                    CYLTagAppearanceCornerRadius : @8 },
            CYLMenuStyleSelected : @{ CYLTagAppearanceBackgroundColor : UIColor.systemIndigoColor,
                                      CYLTagAppearanceBorderColor : UIColor.systemIndigoColor,
                                      CYLTagAppearanceIconColor : UIColor.whiteColor,
                                      CYLTagAppearanceCornerRadius : @8 },
        },
        CYLTagListViewSections : @[ @{
            CYLTagSectionTitle : CYLExampleLocalizedString(@"字典（map）初始化"),
            CYLTagSectionItems : @[
                @{ CYLTagItemTitle : @"Lottie", CYLTagItemAnimation : [self animationNamed:@"tab_me_animate.json"] ?: @"" },
                @{ CYLTagItemTitle : @"GIF", CYLTagItemAnimation : [self animationNamed:@"cyl_tab_sample_animated.gif"] ?: @"" },
                @{ CYLTagItemTitle : @"Rive", CYLTagItemAnimation : [self animationNamed:@"menu_button.riv"] ?: @"" },
                @{ CYLTagItemImage : @"system:heart", CYLTagItemSelectedImage : @"system:heart.fill" },
                @"Text only",
            ],
        } ],
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = CYLExampleLocalizedString(@"配置初始化");
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    UILabel *fileTitle = [self captionWithText:[NSString stringWithFormat:CYLExampleLocalizedString(@"配置文件初始化：%@"), [[self class] configurationFilePath]]];
    NSError *error = nil;
    self.fileTagListView = [CYLTagListView tagListViewWithConfigurationFile:[[self class] configurationFilePath] error:&error];
    self.configurationError = error;
    self.fileTagListView.menuDelegate = self;

    UILabel *mapTitle = [self captionWithText:CYLExampleLocalizedString(@"字典（map）初始化：-initWithConfiguration:")];
    self.mapTagListView = [[CYLTagListView alloc] initWithConfiguration:[[self class] mapConfiguration]];
    self.mapTagListView.menuDelegate = self;

    self.eventLabel = [self captionWithText:[CYLTagButton isAnimationEngineAvailable]
                       ? CYLExampleLocalizedString(@"动效引擎：CYLTabBarItemAnimationFactory 已链接")
                       : CYLExampleLocalizedString(@"动效引擎未链接：显示静态图标")];

    NSMutableArray<UIView *> *views = [NSMutableArray arrayWithObject:fileTitle];
    if (self.fileTagListView) {
        [views addObject:self.fileTagListView];
    } else {
        [views addObject:[self captionWithText:error.localizedDescription ?: @"?"]];
    }
    [views addObjectsFromArray:@[mapTitle, self.mapTagListView, self.eventLabel]];
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:views];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12],
        [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];
}

- (UILabel *)captionWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    [self setText:text ofCaption:label];
    return label;
}

/// Footnote text inset by 16 pt, to line up with the tags.
- (void)setText:(NSString *)text ofCaption:(UILabel *)label {
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.firstLineHeadIndent = 16;
    paragraph.headIndent = 16;
    paragraph.tailIndent = -16;
    label.attributedText = [[NSAttributedString alloc] initWithString:text ?: @"" attributes:@{
        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote],
        NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
        NSParagraphStyleAttributeName: paragraph}];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    for (CYLTagListView *view in @[self.fileTagListView ?: self.mapTagListView, self.mapTagListView]) {
        CGFloat height = [view heightThatFitsWidth:width];
        NSLayoutConstraint *constraint = nil;
        for (NSLayoutConstraint *existing in view.constraints) {
            if (existing.firstAttribute == NSLayoutAttributeHeight && existing.firstItem == view) constraint = existing;
        }
        if (!constraint) {
            constraint = [view.heightAnchor constraintEqualToConstant:height];
            constraint.active = YES;
        } else if (fabs(constraint.constant - height) > 0.5) {
            constraint.constant = height;
        }
    }
}

- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CYLTagListView *view = menu;
    NSString *title = [view.menuDataSource menuTitleForItemAtIndexPath:indexPath];
    [self setText:[NSString stringWithFormat:CYLExampleLocalizedString(@"点击「%@」"), title] ofCaption:self.eventLabel];
}

- (void)menu:(id)menu didChangeContentHeight:(CGFloat)height {
    [self.view setNeedsLayout];
}

@end
