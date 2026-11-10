//
//  CYLTagStyleDemoViewController.m
//  CYLMenuExample
//

#import "CYLTagStyleDemoViewController.h"
#import "CYLExampleMenuSource.h"
#import "CYLExampleLocalization.h"

static NSString * const kStyleCell = @"StyleCell";

@interface CYLTagStyleDemoViewController () <UITableViewDataSource, UITableViewDelegate, CYLMenuDelegate>
@property (nonatomic, strong, readwrite) CYLTagListView *tagListView;
@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong, readwrite) CYLMenuStyle *style;
@property (nonatomic, assign, readwrite) CYLTagStyleDemoContent content;
@property (nonatomic, assign) BOOL usesSelectedImage;
@property (nonatomic, strong) CYLExampleMenuSource *menuSource;
@property (nonatomic, strong) NSLayoutConstraint *previewHeight;
/// How many times each action ran, to cycle through its values.
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *steps;
@end

@implementation CYLTagStyleDemoViewController

#pragma mark Actions

- (NSArray<NSArray<NSString *> *> *)actionIdentifiers {
    return @[
        @[@"iconColor.normal", @"iconColor.selected", @"titleColor.normal", @"titleColor.selected", @"font",
          @"imageTitleSpacing", @"imageSize", @"imageInsets", @"titlePositionAdjustment", @"imagePositionAdjustment",
          @"content.iconAndTitle", @"content.iconOnly", @"content.titleOnly", @"layoutCentered", @"selectedImage"],
        @[@"backgroundColor.normal", @"backgroundColor.selected", @"borderColor", @"borderWidth", @"cornerRadius", @"margin"],
        @[@"reset"],
    ];
}

- (NSString *)titleForSection:(NSInteger)section {
    return @[CYLExampleLocalizedString(@"标题与图标（参照 CYLFlatDesignTabBarItem）"),
             CYLExampleLocalizedString(@"背景、边框与圆角（参照 CYLBadgeView）"),
             CYLExampleLocalizedString(@"其它")][section];
}

- (NSString *)titleForAction:(NSString *)identifier {
    NSDictionary<NSString *, NSString *> *titles = @{
        @"iconColor.normal": @"设置 iconColor（normal）",
        @"iconColor.selected": @"设置 iconColor（selected）",
        @"titleColor.normal": @"设置文字颜色 titleTextAttributes（normal）",
        @"titleColor.selected": @"设置文字颜色 titleTextAttributes（selected）",
        @"font": @"设置字体 NSFontAttributeName",
        @"imageTitleSpacing": @"设置 icon 与文字间距 imageTitleSpacing",
        @"imageSize": @"设置 icon 大小 imageSize",
        @"imageInsets": @"设置 imageInsets",
        @"titlePositionAdjustment": @"设置 titlePositionAdjustment",
        @"imagePositionAdjustment": @"设置 imagePositionAdjustment",
        @"content.iconAndTitle": @"显示 icon + title",
        @"content.iconOnly": @"只显示 icon",
        @"content.titleOnly": @"只显示 title",
        @"layoutCentered": @"切换 layoutCentered（只有 icon 或 title 时居中）",
        @"selectedImage": @"切换选中图片 selectedImage",
        @"backgroundColor.normal": @"设置背景色 backgroundColor（normal）",
        @"backgroundColor.selected": @"设置背景色 backgroundColor（selected）",
        @"borderColor": @"设置边框颜色 borderColor",
        @"borderWidth": @"设置边框宽度 borderWidth",
        @"cornerRadius": @"设置圆角 cornerRadius（0 为胶囊）",
        @"margin": @"设置内边距 margin",
        @"reset": @"重置 reset",
    };
    return CYLExampleLocalizedString(titles[identifier]);
}

/// A fixed palette, so that screenshots are stable.
- (UIColor *)colorAtStep:(NSUInteger)step {
    NSArray<UIColor *> *palette = @[[UIColor systemOrangeColor], [UIColor systemPurpleColor], [UIColor systemTealColor],
                                    [UIColor systemPinkColor], [UIColor systemIndigoColor], [UIColor systemGreenColor]];
    return palette[step % palette.count];
}

- (UIColor *)lightColorAtStep:(NSUInteger)step {
    return [[self colorAtStep:step] colorWithAlphaComponent:0.15];
}

- (NSUInteger)nextStepFor:(NSString *)identifier {
    NSUInteger step = self.steps[identifier].unsignedIntegerValue;
    self.steps[identifier] = @(step + 1);
    return step;
}

- (void)performAction:(NSString *)identifier {
    [self loadViewIfNeeded];
    CYLMenuStyle *style = self.style;
    NSUInteger step = [self nextStepFor:identifier];
    if ([identifier isEqualToString:@"iconColor.normal"]) {
        [style setIconColor:[self colorAtStep:step] forState:UIControlStateNormal];
    } else if ([identifier isEqualToString:@"iconColor.selected"]) {
        NSArray<UIColor *> *colors = @[[UIColor systemYellowColor], [UIColor blackColor], [UIColor whiteColor]];
        [style setIconColor:colors[step % colors.count] forState:UIControlStateSelected];
    } else if ([identifier isEqualToString:@"titleColor.normal"] || [identifier isEqualToString:@"titleColor.selected"]) {
        UIControlState state = [identifier hasSuffix:@"selected"] ? UIControlStateSelected : UIControlStateNormal;
        NSMutableDictionary *attributes = [[style titleTextAttributesForState:state] mutableCopy];
        attributes[NSForegroundColorAttributeName] = state == UIControlStateSelected ? [UIColor colorWithWhite:1 - 0.15 * (step % 3) alpha:1] : [self colorAtStep:step];
        [style setTitleTextAttributes:attributes forState:state];
    } else if ([identifier isEqualToString:@"font"]) {
        NSArray<UIFont *> *fonts = @[[UIFont systemFontOfSize:16 weight:UIFontWeightSemibold], [UIFont systemFontOfSize:12],
                                     [UIFont italicSystemFontOfSize:15], [UIFont systemFontOfSize:14]];
        for (CYLTagAppearance *appearance in @[style.normalAppearance, style.selectedAppearance, style.disabledAppearance]) {
            appearance.font = fonts[step % fonts.count];
        }
    } else if ([identifier isEqualToString:@"imageTitleSpacing"]) {
        style.imageTitleSpacing = [@[@10, @0, @4][step % 3] doubleValue];
    } else if ([identifier isEqualToString:@"imageSize"]) {
        CGFloat side = [@[@20, @10, @14][step % 3] doubleValue];
        style.imageSize = CGSizeMake(side, side);
    } else if ([identifier isEqualToString:@"imageInsets"]) {
        CGFloat inset = step % 2 == 0 ? 3 : 0;
        style.imageInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    } else if ([identifier isEqualToString:@"titlePositionAdjustment"]) {
        NSArray<NSValue *> *offsets = @[[NSValue valueWithUIOffset:UIOffsetMake(0, -4)], [NSValue valueWithUIOffset:UIOffsetMake(4, 0)],
                                        [NSValue valueWithUIOffset:UIOffsetZero]];
        style.titlePositionAdjustment = offsets[step % offsets.count].UIOffsetValue;
    } else if ([identifier isEqualToString:@"imagePositionAdjustment"]) {
        NSArray<NSValue *> *offsets = @[[NSValue valueWithUIOffset:UIOffsetMake(0, -4)], [NSValue valueWithUIOffset:UIOffsetMake(-4, 0)],
                                        [NSValue valueWithUIOffset:UIOffsetZero]];
        style.imagePositionAdjustment = offsets[step % offsets.count].UIOffsetValue;
    } else if ([identifier hasPrefix:@"content."]) {
        self.content = [identifier isEqualToString:@"content.iconOnly"] ? CYLTagStyleDemoContentIconOnly
                     : [identifier isEqualToString:@"content.titleOnly"] ? CYLTagStyleDemoContentTitleOnly
                     : CYLTagStyleDemoContentIconAndTitle;
        [self reloadItems];
    } else if ([identifier isEqualToString:@"layoutCentered"]) {
        style.layoutCentered = !style.layoutCentered;
    } else if ([identifier isEqualToString:@"selectedImage"]) {
        self.usesSelectedImage = !self.usesSelectedImage;
        [self reloadItems];
    } else if ([identifier isEqualToString:@"backgroundColor.normal"]) {
        style.normalAppearance.backgroundColor = [self lightColorAtStep:step];
    } else if ([identifier isEqualToString:@"backgroundColor.selected"]) {
        style.selectedAppearance.backgroundColor = [self colorAtStep:step];
        style.selectedAppearance.borderColor = [self colorAtStep:step];
    } else if ([identifier isEqualToString:@"borderColor"]) {
        style.normalAppearance.borderColor = [self colorAtStep:step];
    } else if ([identifier isEqualToString:@"borderWidth"]) {
        CGFloat width = [@[@2, @0, @1, @0.5][step % 4] doubleValue];
        for (CYLTagAppearance *appearance in @[style.normalAppearance, style.selectedAppearance, style.disabledAppearance]) {
            appearance.borderWidth = width;
        }
    } else if ([identifier isEqualToString:@"cornerRadius"]) {
        CGFloat radius = [@[@0, @8, @3][step % 3] doubleValue];
        for (CYLTagAppearance *appearance in @[style.normalAppearance, style.selectedAppearance, style.disabledAppearance]) {
            appearance.cornerRadius = radius;
        }
    } else if ([identifier isEqualToString:@"margin"]) {
        CGFloat margin = [@[@18, @4, @10][step % 3] doubleValue];
        for (CYLTagAppearance *appearance in @[style.normalAppearance, style.selectedAppearance, style.disabledAppearance]) {
            appearance.margin = margin;
        }
    } else if ([identifier isEqualToString:@"reset"]) {
        self.style = [[self class] demoStyle];
        self.content = CYLTagStyleDemoContentIconAndTitle;
        self.usesSelectedImage = YES;
        [self.steps removeAllObjects];
        [self reloadItems];
    }
    [self applyStyle];
}

- (NSString *)valueForAction:(NSString *)identifier {
    CYLMenuStyle *style = self.style;
    if ([identifier isEqualToString:@"imageTitleSpacing"]) return [NSString stringWithFormat:@"%.0f", style.imageTitleSpacing];
    if ([identifier isEqualToString:@"imageSize"]) return NSStringFromCGSize(style.imageSize);
    if ([identifier isEqualToString:@"imageInsets"]) return NSStringFromUIEdgeInsets(style.imageInsets);
    if ([identifier isEqualToString:@"titlePositionAdjustment"]) return NSStringFromUIOffset(style.titlePositionAdjustment);
    if ([identifier isEqualToString:@"imagePositionAdjustment"]) return NSStringFromUIOffset(style.imagePositionAdjustment);
    if ([identifier isEqualToString:@"layoutCentered"]) return style.layoutCentered ? @"YES" : @"NO";
    if ([identifier isEqualToString:@"selectedImage"]) return self.usesSelectedImage ? @"YES" : @"NO";
    if ([identifier isEqualToString:@"font"]) return [NSString stringWithFormat:@"%@ %.0f", style.normalAppearance.font.fontName, style.normalAppearance.font.pointSize];
    if ([identifier isEqualToString:@"borderWidth"]) return [NSString stringWithFormat:@"%.1f", style.normalAppearance.borderWidth];
    if ([identifier isEqualToString:@"cornerRadius"]) return [NSString stringWithFormat:@"%.0f", style.normalAppearance.cornerRadius];
    if ([identifier isEqualToString:@"margin"]) return [NSString stringWithFormat:@"%.0f", style.normalAppearance.margin];
    if ([identifier hasPrefix:@"content."]) {
        NSString *current = @[@"content.iconAndTitle", @"content.iconOnly", @"content.titleOnly"][self.content];
        return [identifier isEqualToString:current] ? @"✓" : @"";
    }
    return @"";
}

#pragma mark Style and data

+ (CYLMenuStyle *)demoStyle {
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    [style setIconColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [style setIconColor:[UIColor whiteColor] forState:UIControlStateSelected];
    style.selectedAppearance.backgroundColor = [UIColor systemBlueColor];
    style.selectedAppearance.borderColor = [UIColor systemBlueColor];
    style.imageSize = CGSizeMake(16, 16);
    style.imageTitleSpacing = 4;
    style.itemHeight = 34;
    style.sectionInsets = UIEdgeInsetsMake(12, 16, 12, 16);
    return style;
}

- (void)reloadItems {
    NSArray<NSArray *> *samples = @[
        @[@"首页", @"house", @"house.fill"],
        @[@"同城", @"mappin.and.ellipse", @"mappin.circle.fill"],
        @[@"消息", @"message", @"message.fill"],
        @[@"我的", @"person", @"person.fill"],
        @[@"一个很长很长的标签标题", @"star", @"star.fill"],
        @[@"已禁用", @"nosign", @"nosign"],
    ];
    NSMutableArray *items = [NSMutableArray array];
    for (NSArray *sample in samples) {
        BOOL iconOnly = self.content == CYLTagStyleDemoContentIconOnly;
        BOOL titleOnly = self.content == CYLTagStyleDemoContentTitleOnly;
        CYLExampleMenuItem *item = [CYLExampleMenuItem itemWithTitle:iconOnly ? @"" : CYLExampleLocalizedString(sample[0])];
        item.image = titleOnly ? nil : [UIImage systemImageNamed:sample[1]];
        item.selectedImage = (titleOnly || !self.usesSelectedImage) ? nil : [UIImage systemImageNamed:sample[2]];
        item.enabled = ![sample[0] isEqualToString:@"已禁用"];
        [items addObject:item];
    }
    self.menuSource = [CYLExampleMenuSource sourceWithSections:@[[CYLExampleMenuSection sectionWithTitle:@"" items:items]]];
    NSArray<NSIndexPath *> *selection = self.tagListView.selectedIndexPaths;
    self.tagListView.menuDataSource = self.menuSource;
    [self.tagListView reloadMenuData];
    self.tagListView.selectedIndexPaths = selection.count > 0 ? selection : @[[NSIndexPath indexPathForItem:0 inSection:0]];
}

- (void)applyStyle {
    self.tagListView.style = self.style;
    [self.tableView reloadData];
    [self.view setNeedsLayout];
}

#pragma mark Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigationItem, not title: a view controller's title would replace its tab's title.
    self.navigationItem.title = CYLExampleLocalizedString(@"标签样式");
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.steps = [NSMutableDictionary dictionary];
    self.style = [[self class] demoStyle];
    self.usesSelectedImage = YES;

    self.tagListView = [[CYLTagListView alloc] init];
    self.tagListView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tagListView.selectionMode = CYLMenuSelectionModeMultiple;
    self.tagListView.showsSectionHeaders = NO;
    self.tagListView.scrollEnabled = NO;
    self.tagListView.menuDelegate = self;
    [self.view addSubview:self.tagListView];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kStyleCell];
    [self.view addSubview:self.tableView];

    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = [UIColor separatorColor];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:separator];

    self.previewHeight = [self.tagListView.heightAnchor constraintEqualToConstant:0];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.tagListView.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.tagListView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tagListView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        self.previewHeight,
        [separator.topAnchor constraintEqualToAnchor:self.tagListView.bottomAnchor],
        [separator.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [separator.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [separator.heightAnchor constraintEqualToConstant:1.0 / MAX(1, UIScreen.mainScreen.scale)],
        [self.tableView.topAnchor constraintEqualToAnchor:separator.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    [self reloadItems];
    [self applyStyle];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat height = [self.tagListView heightThatFitsWidth:CGRectGetWidth(self.view.bounds)];
    if (fabs(self.previewHeight.constant - height) > 0.5) {
        self.previewHeight.constant = height;
    }
}

- (void)menu:(id)menu didChangeContentHeight:(CGFloat)height {
    [self.view setNeedsLayout];
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self actionIdentifiers].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self actionIdentifiers][section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self titleForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStyleCell forIndexPath:indexPath];
    NSString *identifier = [self actionIdentifiers][indexPath.section][indexPath.row];
    UIListContentConfiguration *content = [UIListContentConfiguration valueCellConfiguration];
    content.text = [self titleForAction:identifier];
    content.textProperties.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    content.textProperties.numberOfLines = 0;
    content.secondaryText = [self valueForAction:identifier];
    content.prefersSideBySideTextAndSecondaryText = YES;
    cell.contentConfiguration = content;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performAction:[self actionIdentifiers][indexPath.section][indexPath.row]];
}

@end
