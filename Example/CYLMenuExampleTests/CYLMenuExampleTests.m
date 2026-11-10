//
//  CYLMenuExampleTests.m
//  CYLMenuExampleTests
//
//  Covers the CYLTagListView API and the two README scenarios built with it.
//

#import <XCTest/XCTest.h>
@import CollectionViewClassifyMenu;
#import "CYLExampleMenuSource.h"
#import "CYLExampleAppDelegate.h"
#import "CYLSearchHomeViewController.h"
#import "CYLTagStyleDemoViewController.h"
#import "CYLTagConfigurationDemoViewController.h"
#import "CYLProductViewController.h"
#import "CYLReviewListViewController.h"
#import "CYLReviewStore.h"
#import "CYLSearchCategoryViewController.h"

@interface CYLRecordingDelegate : NSObject <CYLMenuDelegate>
@property (nonatomic, strong) NSMutableArray<NSString *> *events;
@property (nonatomic, strong, nullable) NSIndexPath *blockedIndexPath;
@property (nonatomic, assign) CGFloat lastHeight;
@property (nonatomic, assign) NSUInteger changeCount;
@end

@implementation CYLRecordingDelegate
- (instancetype)init {
    self = [super init];
    _events = [NSMutableArray array];
    return self;
}
- (NSString *)describe:(NSIndexPath *)indexPath {
    // item-section, as the expectations are written.
    return [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.item, (long)indexPath.section];
}
- (BOOL)menu:(id)menu shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return ![indexPath isEqual:self.blockedIndexPath];
}
- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.events addObject:[@"select " stringByAppendingString:[self describe:indexPath]]];
}
- (void)menu:(id)menu didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.events addObject:[@"deselect " stringByAppendingString:[self describe:indexPath]]];
}
- (void)menu:(id)menu didChangeExpanded:(BOOL)expanded inSection:(NSInteger)section {
    [self.events addObject:[NSString stringWithFormat:@"%@ %ld", expanded ? @"expand" : @"collapse", (long)section]];
}
- (void)menu:(id)menu didChangeContentHeight:(CGFloat)height {
    self.lastHeight = height;
}
- (void)menu:(id)menu didChangeSelectedItems:(NSArray<NSIndexPath *> *)indexPaths {
    self.changeCount++;
}
@end

@interface CYLMenuExampleTests : XCTestCase
@property (nonatomic, strong) UIWindow *window;
@end

@implementation CYLMenuExampleTests

- (void)setUp {
    [super setUp];
    // The expectations below are written in Chinese; the simulator's language may differ.
    CYLMenuResources.preferredLanguage = @"zh-Hans";
}

- (void)tearDown {
    self.window.hidden = YES;
    self.window = nil;
    CYLMenuResources.preferredLanguage = nil;
    [super tearDown];
}

#pragma mark Helpers

- (CYLExampleMenuSource *)sourceWithItemCount:(NSUInteger)count sections:(NSUInteger)sections {
    NSMutableArray *result = [NSMutableArray array];
    for (NSUInteger section = 0; section < sections; section++) {
        NSMutableArray *titles = [NSMutableArray array];
        for (NSUInteger item = 0; item < count; item++) {
            [titles addObject:[NSString stringWithFormat:@"标签 %lu-%lu 🌟", (unsigned long)section, (unsigned long)item]];
        }
        [result addObject:[CYLExampleMenuSection sectionWithTitle:[NSString stringWithFormat:@"分组 %lu", (unsigned long)section] titles:titles]];
    }
    return [CYLExampleMenuSource sourceWithSections:result];
}

- (CYLTagListView *)hostedViewWithSource:(CYLExampleMenuSource *)source width:(CGFloat)width {
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, width, 700)];
    UIViewController *controller = [[UIViewController alloc] init];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    CYLTagListView *view = [[CYLTagListView alloc] initWithFrame:CGRectMake(0, 0, width, 700)];
    view.menuDataSource = source;
    [controller.view addSubview:view];
    [view reloadMenuData];
    [view layoutIfNeeded];
    return view;
}

- (UICollectionView *)collectionViewOf:(CYLTagListView *)view {
    return [view valueForKey:@"collectionView"];
}

- (void)tap:(CYLTagListView *)view item:(NSInteger)item section:(NSInteger)section {
    UICollectionView *collection = [self collectionViewOf:view];
    [collection.delegate collectionView:collection didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
}

- (NSIndexPath *)ip:(NSInteger)item :(NSInteger)section {
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (void)assertNoOverlapsOrOverflowIn:(CYLTagListView *)view {
    UICollectionView *collection = [self collectionViewOf:view];
    [collection layoutIfNeeded];
    CGFloat maxX = CGRectGetWidth(collection.bounds) - view.style.sectionInsets.right + 0.5;
    for (NSInteger section = 0; section < [collection numberOfSections]; section++) {
        UICollectionViewLayoutAttributes *previous = nil;
        for (NSInteger item = 0; item < [collection numberOfItemsInSection:section]; item++) {
            UICollectionViewLayoutAttributes *attributes = [collection.collectionViewLayout layoutAttributesForItemAtIndexPath:[self ip:item :section]];
            XCTAssertNotNil(attributes);
            XCTAssertLessThanOrEqual(CGRectGetMaxX(attributes.frame), maxX);
            if (previous) {
                XCTAssertFalse(CGRectIntersectsRect(previous.frame, attributes.frame));
            }
            previous = attributes;
        }
    }
}

#pragma mark Selection

- (void)testSingleSelectionReplacesWithinSectionAndReportsDeselect {
    CYLExampleMenuSource *source = [self sourceWithItemCount:4 sections:2];
    CYLTagListView *view = [self hostedViewWithSource:source width:375];
    CYLRecordingDelegate *delegate = [[CYLRecordingDelegate alloc] init];
    view.menuDelegate = delegate;
    XCTAssertEqual(view.selectionMode, CYLMenuSelectionModeSingle);

    [self tap:view item:0 section:0];
    [self tap:view item:2 section:0];
    [self tap:view item:1 section:1];
    XCTAssertEqualObjects(view.selectedIndexPaths, (@[[self ip:2 :0], [self ip:1 :1]]));
    XCTAssertEqualObjects(delegate.events, (@[@"select 0-0", @"deselect 0-0", @"select 2-0", @"select 1-1"]));
    XCTAssertEqual(delegate.changeCount, 3u, @"One change notification per tap that changed the selection");

    [self tap:view item:2 section:0];
    XCTAssertEqualObjects(view.selectedIndexPaths, (@[[self ip:1 :1]]), @"Empty selection is allowed by default");

    view.allowsEmptySelection = NO;
    [self tap:view item:1 section:1];
    XCTAssertEqualObjects(view.selectedIndexPaths, (@[[self ip:1 :1]]), @"The last selection stays");
}

- (void)testMultipleSelectionHonoursExclusiveItems {
    CYLExampleMenuSource *source = [self sourceWithItemCount:4 sections:1];
    source.sections[0].items[0].exclusive = YES;
    CYLTagListView *view = [self hostedViewWithSource:source width:375];
    view.selectionMode = CYLMenuSelectionModeMultiple;
    view.selectedIndexPaths = @[[self ip:0 :0]];

    [self tap:view item:1 section:0];
    [self tap:view item:2 section:0];
    XCTAssertEqualObjects(view.selectedIndexPaths, (@[[self ip:1 :0], [self ip:2 :0]]));
    [self tap:view item:0 section:0];
    XCTAssertEqualObjects(view.selectedIndexPaths, (@[[self ip:0 :0]]));
}

- (void)testNoneModeReportsTapsWithoutKeepingSelection {
    CYLTagListView *view = [self hostedViewWithSource:[self sourceWithItemCount:3 sections:1] width:375];
    CYLRecordingDelegate *delegate = [[CYLRecordingDelegate alloc] init];
    view.menuDelegate = delegate;
    view.selectionMode = CYLMenuSelectionModeNone;
    [self tap:view item:1 section:0];
    [view selectItemAtIndexPath:[self ip:2 :0]];
    XCTAssertEqualObjects(view.selectedIndexPaths, @[]);
    XCTAssertEqualObjects(delegate.events, @[@"select 1-0"]);
}

- (void)testDisabledAndVetoedItemsAreIgnored {
    CYLExampleMenuSource *source = [self sourceWithItemCount:3 sections:1];
    source.sections[0].items[1].enabled = NO;
    CYLTagListView *view = [self hostedViewWithSource:source width:375];
    CYLRecordingDelegate *delegate = [[CYLRecordingDelegate alloc] init];
    delegate.blockedIndexPath = [self ip:2 :0];
    view.menuDelegate = delegate;
    [self tap:view item:1 section:0];
    [self tap:view item:2 section:0];
    XCTAssertEqualObjects(view.selectedIndexPaths, @[]);
    XCTAssertEqualObjects(delegate.events, @[]);
}

- (void)testProgrammaticSelectionValidatesAndDoesNotCallDelegate {
    CYLTagListView *view = [self hostedViewWithSource:[self sourceWithItemCount:3 sections:1] width:375];
    CYLRecordingDelegate *delegate = [[CYLRecordingDelegate alloc] init];
    view.menuDelegate = delegate;
    [view selectItemAtIndexPath:[self ip:1 :0]];
    XCTAssertEqualObjects(view.selectedIndexPaths, @[[self ip:1 :0]]);
    [view deselectItemAtIndexPath:[self ip:1 :0]];
    XCTAssertEqualObjects(view.selectedIndexPaths, @[]);
    view.selectedIndexPaths = @[[self ip:2 :0]];
    [view deselectAllItems];
    XCTAssertEqualObjects(view.selectedIndexPaths, @[]);
    XCTAssertThrowsSpecificNamed(view.selectedIndexPaths = @[[self ip:9 :0]], NSException, NSInvalidArgumentException);
    XCTAssertEqualObjects(delegate.events, @[]);
}

- (void)testSelectedCellsUseSelectedStyleAfterReuse {
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    style.selectedAppearance.backgroundColor = [UIColor redColor];
    CYLTagListView *view = [self hostedViewWithSource:[self sourceWithItemCount:200 sections:1] width:320];
    view.style = style;
    view.frame = CGRectMake(0, 0, 320, 200);
    [view layoutIfNeeded];
    view.selectedIndexPaths = @[[self ip:0 :0]];
    UICollectionView *collection = [self collectionViewOf:view];
    [collection setContentOffset:CGPointMake(0, collection.contentSize.height - 200) animated:NO];
    [collection layoutIfNeeded];
    [collection setContentOffset:CGPointZero animated:NO];
    [collection layoutIfNeeded];
    for (NSIndexPath *indexPath in collection.indexPathsForVisibleItems) {
        UICollectionViewCell *cell = [collection cellForItemAtIndexPath:indexPath];
        CYLTagButton *button = [cell valueForKey:@"button"];
        BOOL red = CGColorEqualToColor(button.layer.backgroundColor, [UIColor redColor].CGColor);
        XCTAssertEqual(red, indexPath.item == 0, @"%@", indexPath);
    }
}

#pragma mark Folding and size

- (void)testFooterChevronFoldsAndReportsHeight {
    CYLExampleMenuSource *source = [self sourceWithItemCount:30 sections:1];
    CYLTagListView *view = [self hostedViewWithSource:source width:320];
    CYLRecordingDelegate *delegate = [[CYLRecordingDelegate alloc] init];
    view.menuDelegate = delegate;
    view.showsSectionHeaders = NO;
    view.defaultVisibleRows = 2;
    view.foldStyle = CYLMenuFoldStyleFooterChevron;
    [view layoutIfNeeded];
    UICollectionView *collection = [self collectionViewOf:view];

    XCTAssertTrue([view canFoldSection:0]);
    XCTAssertGreaterThan([view numberOfRowsInSection:0], 2u);
    NSInteger collapsed = [collection numberOfItemsInSection:0];
    XCTAssertLessThan(collapsed, 30);
    XCTAssertEqual(collapsed, [view numberOfVisibleItemsInSection:0]);
    CGFloat collapsedHeight = view.contentHeight;
    XCTAssertEqualWithAccuracy(collapsedHeight, [view heightThatFitsWidth:320], 1);
    XCTAssertEqualWithAccuracy(view.intrinsicContentSize.height, collapsedHeight, 0.5);
    UICollectionReusableView *footer = [collection supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[self ip:0 :0]];
    XCTAssertNotNil(footer);

    [view setExpanded:YES forSection:0 animated:NO];
    XCTAssertTrue([view isSectionExpanded:0]);
    XCTAssertEqual([collection numberOfItemsInSection:0], 30);
    XCTAssertGreaterThan(view.contentHeight, collapsedHeight);
    XCTAssertEqualWithAccuracy(view.contentHeight, [view heightThatFitsWidth:320], 1);
    XCTAssertEqualWithAccuracy(delegate.lastHeight, view.contentHeight, 0.5);
    [self assertNoOverlapsOrOverflowIn:view];

    [view setExpanded:NO forSection:0 animated:NO];
    XCTAssertEqual([collection numberOfItemsInSection:0], collapsed);
    XCTAssertEqualObjects(delegate.events, (@[@"expand 0", @"collapse 0"]));
}

- (void)testTruncateStyleShowsRowsWithoutControls {
    CYLTagListView *view = [self hostedViewWithSource:[self sourceWithItemCount:30 sections:1] width:320];
    view.showsSectionHeaders = NO;
    view.defaultVisibleRows = 2;
    view.foldStyle = CYLMenuFoldStyleTruncate;
    [view layoutIfNeeded];
    UICollectionView *collection = [self collectionViewOf:view];
    XCTAssertLessThan([collection numberOfItemsInSection:0], 30);
    XCTAssertNil([collection supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[self ip:0 :0]]);
    XCTAssertNil([collection supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[self ip:0 :0]]);
}

- (void)testHeaderButtonFoldsEachSectionIndependently {
    CYLTagListView *view = [self hostedViewWithSource:[self sourceWithItemCount:20 sections:2] width:320];
    view.foldStyle = CYLMenuFoldStyleHeaderButton;
    view.defaultVisibleRows = 1;
    [view layoutIfNeeded];
    UICollectionView *collection = [self collectionViewOf:view];
    UICollectionReusableView *header = [collection supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[self ip:0 :0]];
    UIButton *fold = [header valueForKey:@"foldButton"];
    XCTAssertFalse(fold.hidden);
    XCTAssertEqualObjects([fold titleForState:UIControlStateNormal], view.style.expandTitle);
    [fold sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertTrue([view isSectionExpanded:0]);
    XCTAssertFalse([view isSectionExpanded:1]);
    XCTAssertEqual([collection numberOfItemsInSection:0], 20);
    XCTAssertLessThan([collection numberOfItemsInSection:1], 20);
}

- (void)testReloadKeepsValidStateAndDropsStaleState {
    CYLExampleMenuSource *source = [self sourceWithItemCount:30 sections:2];
    CYLTagListView *view = [self hostedViewWithSource:source width:320];
    view.foldStyle = CYLMenuFoldStyleHeaderButton;
    view.selectedIndexPaths = @[[self ip:1 :0], [self ip:20 :1]];
    [view setExpanded:YES forSection:1 animated:NO];
    source.sections = [self sourceWithItemCount:5 sections:1].sections;
    [view reloadMenuData];
    XCTAssertEqualObjects(view.selectedIndexPaths, @[[self ip:1 :0]]);
    XCTAssertFalse([view isSectionExpanded:1]);
    XCTAssertEqual([[self collectionViewOf:view] numberOfSections], 1);
}

#pragma mark Data source hooks and style

- (void)testImagesHeaderIconsAndAccessoryViewsComeFromTheHost {
    CYLExampleMenuSource *source = [self sourceWithItemCount:3 sections:1];
    UIImage *icon = [UIImage systemImageNamed:@"star.fill"];
    source.sections[0].items[0].image = icon;
    // Same title, so the image alone accounts for the width difference
    // (system digits are proportional).
    source.sections[0].items[1].title = source.sections[0].items[0].title;
    source.sections[0].image = icon;
    UIButton *accessory = [UIButton buttonWithType:UIButtonTypeSystem];
    [accessory setTitle:@"行业: IT互联网 ▾" forState:UIControlStateNormal];
    source.sections[0].accessoryView = accessory;
    CYLTagListView *view = [self hostedViewWithSource:source width:375];
    UICollectionView *collection = [self collectionViewOf:view];
    [collection layoutIfNeeded];

    CGFloat withImage = [collection.collectionViewLayout layoutAttributesForItemAtIndexPath:[self ip:0 :0]].frame.size.width;
    CGFloat withoutImage = [collection.collectionViewLayout layoutAttributesForItemAtIndexPath:[self ip:1 :0]].frame.size.width;
    XCTAssertEqualWithAccuracy(withImage - withoutImage, view.style.imageSize.width + view.style.imageTitleSpacing, 1,
                               @"The image accounts for the difference");
    UICollectionViewCell *cell = [collection cellForItemAtIndexPath:[self ip:0 :0]];
    CYLTagButton *button = [cell valueForKey:@"button"];
    XCTAssertEqual(button.imageView.image, icon);

    UICollectionReusableView *header = [collection supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[self ip:0 :0]];
    [header layoutIfNeeded];
    XCTAssertEqual(accessory.superview, header);
    XCTAssertLessThanOrEqual(CGRectGetMaxX(accessory.frame), CGRectGetWidth(header.bounds));
    UILabel *title = [header valueForKey:@"titleLabel"];
    XCTAssertLessThanOrEqual(CGRectGetMaxX(title.frame), CGRectGetMinX(accessory.frame));
    XCTAssertEqual(((UIImageView *)[header valueForKey:@"iconView"]).image, icon);
}

- (void)testStyleAndDynamicTypeChangeItemSize {
    CYLTagListView *view = [self hostedViewWithSource:[self sourceWithItemCount:40 sections:1] width:320];
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    style.itemHeight = 40;
    style.normalAppearance.cornerRadius = 0;  // automatic capsule
    view.style = style;
    [view layoutIfNeeded];
    UICollectionView *collection = [self collectionViewOf:view];
    XCTAssertEqualWithAccuracy([collection.collectionViewLayout layoutAttributesForItemAtIndexPath:[self ip:0 :0]].frame.size.height, 40, 0.5);
    style.itemHeight = 10;
    XCTAssertEqualWithAccuracy(view.style.itemHeight, 40, 0.01, @"The view keeps its own copy");

    UITraitCollection *large = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];
    UIFont *largeFont = [view.style titleFontForState:UIControlStateNormal traitCollection:large];
    CGFloat base = view.style.normalAppearance.font.pointSize;
    XCTAssertGreaterThan(largeFont.pointSize, base);
    XCTAssertLessThanOrEqual(largeFont.pointSize, base * CYLMaximumFontScale + 0.01);
    CYLMenuStyle *fixed = [view.style copy];
    fixed.adjustsFontForContentSizeCategory = NO;
    XCTAssertEqualWithAccuracy([fixed titleFontForState:UIControlStateNormal traitCollection:large].pointSize, base, 0.01);
}

- (void)testNarrowWidthsAndLongTitlesStayInside {
    for (NSNumber *width in @[@240, @320, @390]) {
        CYLExampleMenuSource *source = [self sourceWithItemCount:25 sections:3];
        source.sections[1].items[0].title = @"一个非常非常非常非常非常非常非常非常非常长的标签 🧑‍🍳✨🚀";
        CYLTagListView *view = [self hostedViewWithSource:source width:width.doubleValue];
        view.foldStyle = CYLMenuFoldStyleHeaderButton;
        [view layoutIfNeeded];
        [self assertNoOverlapsOrOverflowIn:view];
        for (NSInteger section = 0; section < 3; section++) {
            [view setExpanded:YES forSection:section animated:NO];
        }
        [self assertNoOverlapsOrOverflowIn:view];
        XCTAssertEqualWithAccuracy(view.contentHeight, [view heightThatFitsWidth:width.doubleValue], 1);
    }
}

#pragma mark Tag button (CYLFlatDesignTabBarItem layout, CYLBadgeView box)

- (CYLTagButton *)buttonWithTitle:(NSString *)title image:(UIImage *)image style:(CYLMenuStyle *)style {
    CYLTagButton *button = [[CYLTagButton alloc] initWithFrame:CGRectMake(0, 0, 160, 30)];
    button.style = style;
    button.title = title;
    button.image = image;
    [button layoutIfNeeded];
    return button;
}

- (void)testTagButtonPutsTheIconBeforeTheTitle {
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    style.imageTitleSpacing = 6;
    CYLTagButton *button = [self buttonWithTitle:@"消息" image:[UIImage systemImageNamed:@"message"] style:style];
    CGRect image = button.imageView.frame;
    CGRect title = button.titleLabel.frame;
    XCTAssertEqualWithAccuracy(CGRectGetMinX(title) - CGRectGetMaxX(image), 6, 0.5, @"imageTitleSpacing");
    XCTAssertEqualWithAccuracy(CGRectGetMidY(image), CGRectGetMidY(title), 1, @"Side by side, not stacked");
    XCTAssertEqualWithAccuracy(CGRectGetMinX(image), 160 - CGRectGetMaxX(title), 1, @"The group is centered");
    XCTAssertTrue(CGSizeEqualToSize(image.size, style.imageSize));

    CGFloat expected = 2 * style.normalAppearance.margin + style.imageSize.width + 6 +
        ceil([@"消息" sizeWithAttributes:@{NSFontAttributeName: [style titleFontForState:UIControlStateNormal traitCollection:button.traitCollection]}].width);
    XCTAssertEqualWithAccuracy([CYLTagButton widthForTitle:@"消息" image:[UIImage systemImageNamed:@"message"] style:style traitCollection:button.traitCollection], expected, 1);
}

- (void)testTagButtonLayoutCenteredForIconOnlyAndTitleOnly {
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    XCTAssertTrue(style.layoutCentered);
    CYLTagButton *iconOnly = [self buttonWithTitle:nil image:[UIImage systemImageNamed:@"house"] style:style];
    XCTAssertEqualWithAccuracy(CGRectGetMidX(iconOnly.imageView.frame), 80, 1);
    XCTAssertTrue(CGRectIsEmpty(iconOnly.titleLabel.frame));
    CYLTagButton *titleOnly = [self buttonWithTitle:@"首页" image:nil style:style];
    XCTAssertEqualWithAccuracy(CGRectGetMidX(titleOnly.titleLabel.frame), 80, 1);
    XCTAssertTrue(CGRectIsEmpty(titleOnly.imageView.frame));

    style.layoutCentered = NO;
    iconOnly = [self buttonWithTitle:nil image:[UIImage systemImageNamed:@"house"] style:style];
    XCTAssertEqualWithAccuracy(CGRectGetMinX(iconOnly.imageView.frame), style.normalAppearance.margin, 0.5);
    titleOnly = [self buttonWithTitle:@"首页" image:nil style:style];
    XCTAssertEqualWithAccuracy(CGRectGetMinX(titleOnly.titleLabel.frame),
                               style.normalAppearance.margin + style.imageSize.width + style.imageTitleSpacing, 0.5,
                               @"The title keeps its place after an empty icon slot");
    XCTAssertGreaterThan([CYLTagButton widthForTitle:@"首页" image:nil style:style traitCollection:nil],
                         [CYLTagButton widthForTitle:@"首页" image:nil style:[CYLMenuStyle defaultStyle] traitCollection:nil]);
}

- (void)testTagButtonPositionAdjustmentsAndImageInsets {
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    CYLTagButton *plain = [self buttonWithTitle:@"同城" image:[UIImage systemImageNamed:@"mappin"] style:style];
    style.titlePositionAdjustment = UIOffsetMake(3, -2);
    style.imagePositionAdjustment = UIOffsetMake(-4, 1);
    style.imageInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    CYLTagButton *moved = [self buttonWithTitle:@"同城" image:[UIImage systemImageNamed:@"mappin"] style:style];
    XCTAssertEqualWithAccuracy(CGRectGetMinX(moved.titleLabel.frame) - CGRectGetMinX(plain.titleLabel.frame), 3, 0.5);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(moved.titleLabel.frame) - CGRectGetMinY(plain.titleLabel.frame), -2, 0.5);
    XCTAssertEqualWithAccuracy(CGRectGetMinX(moved.imageView.frame) - CGRectGetMinX(plain.imageView.frame), -4, 0.5);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(moved.imageView.frame) - CGRectGetMinY(plain.imageView.frame), 1, 0.5);
    XCTAssertEqualWithAccuracy(CGRectGetWidth(moved.imageView.frame), style.imageSize.width - 4, 0.01, @"imageInsets shrink the icon in place");
}

- (void)testTagButtonColorsFontsAndSelectedImagePerState {
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    UIFont *font = [UIFont boldSystemFontOfSize:17];
    [style setTitleTextAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor redColor]} forState:UIControlStateNormal];
    [style setIconColor:[UIColor blueColor] forState:UIControlStateNormal];
    [style setIconColor:[UIColor yellowColor] forState:UIControlStateSelected];
    XCTAssertEqualObjects([style titleTextAttributesForState:UIControlStateNormal][NSForegroundColorAttributeName], [UIColor redColor]);
    XCTAssertEqualObjects(style.normalAppearance.font, font);
    XCTAssertEqualObjects([style iconColorForState:UIControlStateDisabled], style.disabledAppearance.textColor, @"nil iconColor uses the text color");

    UIImage *normal = [UIImage systemImageNamed:@"star"];
    UIImage *selected = [UIImage systemImageNamed:@"star.fill"];
    CYLTagButton *button = [self buttonWithTitle:@"我的" image:normal style:style];
    button.selectedImage = selected;
    XCTAssertEqualObjects(button.titleLabel.textColor, [UIColor redColor]);
    XCTAssertEqualObjects(button.imageView.tintColor, [UIColor blueColor]);
    XCTAssertEqual(button.imageView.image, normal);
    button.selected = YES;
    XCTAssertEqual(button.imageView.image, selected);
    XCTAssertEqualObjects(button.imageView.tintColor, [UIColor yellowColor]);
    XCTAssertEqualObjects(button.titleLabel.textColor, style.selectedAppearance.textColor);
    button.enabled = NO;
    XCTAssertEqualObjects(button.titleLabel.textColor, style.disabledAppearance.textColor, @"Disabled wins over selected");

    [style setTitleTextAttributes:nil forState:UIControlStateNormal];
    XCTAssertEqualObjects(style.normalAppearance.font, [UIFont systemFontOfSize:14], @"nil restores the default, as CYLBadgeAppearance");
}

- (void)testTagBoxFollowsCYLBadgeAppearance {
    CYLTagAppearance *appearance = [[CYLTagAppearance alloc] init];
    appearance.cornerRadius = -3;
    appearance.borderWidth = NAN;
    appearance.margin = -1;
    XCTAssertEqual(appearance.cornerRadius, 0);
    XCTAssertEqual(appearance.borderWidth, 0);
    XCTAssertEqual(appearance.margin, 0);
    appearance.backgroundColor = [UIColor redColor];
    appearance.backgroundColor = nil;
    XCTAssertEqualObjects(appearance.backgroundColor, [UIColor whiteColor], @"null_resettable");
    [appearance reset];
    XCTAssertEqual(appearance.margin, 10);

    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    style.normalAppearance.cornerRadius = 0;
    style.normalAppearance.borderColor = [UIColor greenColor];
    style.normalAppearance.borderWidth = 2;
    style.normalAppearance.backgroundColor = [UIColor cyanColor];
    CYLTagButton *button = [self buttonWithTitle:@"首页" image:nil style:style];
    XCTAssertEqualWithAccuracy(button.layer.cornerRadius, 15, 0.01, @"0 is an automatic capsule");
    XCTAssertEqual(button.layer.borderWidth, 2);
    XCTAssertTrue(CGColorEqualToColor(button.layer.borderColor, [UIColor greenColor].CGColor));
    XCTAssertTrue(CGColorEqualToColor(button.layer.backgroundColor, [UIColor cyanColor].CGColor));
    style.normalAppearance.cornerRadius = 5;
    button.style = style;
    [button layoutIfNeeded];
    XCTAssertEqualWithAccuracy(button.layer.cornerRadius, 5, 0.01);
    XCTAssertEqual([style copy].normalAppearance.cornerRadius, 5);
    XCTAssertNotEqual([style copy].normalAppearance, style.normalAppearance, @"A copy has its own appearances");
}

- (void)testStyleDemoRowsRestyleTheTagsLive {
    CYLTagStyleDemoViewController *demo = [[CYLTagStyleDemoViewController alloc] init];
    [self hostController:demo];
    [demo.view layoutIfNeeded];
    NSArray<NSArray<NSString *> *> *actions = [demo actionIdentifiers];
    XCTAssertEqual([demo.tableView numberOfSections], (NSInteger)actions.count);
    XCTAssertEqual([demo.tableView numberOfRowsInSection:0], (NSInteger)actions[0].count);
    UICollectionView *collection = [self collectionViewOf:demo.tagListView];
    [collection layoutIfNeeded];
    CYLTagButton *first = [[collection cellForItemAtIndexPath:[self ip:1 :0]] valueForKey:@"button"];
    XCTAssertNotNil(first.imageView.image);
    XCTAssertGreaterThan(first.title.length, 0u);

    // A tap on the cornerRadius row: 0 makes capsules.
    NSIndexPath *cornerRow = [NSIndexPath indexPathForRow:(NSInteger)[actions[1] indexOfObject:@"cornerRadius"] inSection:1];
    [demo.tableView.delegate tableView:demo.tableView didSelectRowAtIndexPath:cornerRow];
    [collection layoutIfNeeded];
    first = [[collection cellForItemAtIndexPath:[self ip:1 :0]] valueForKey:@"button"];
    XCTAssertEqual(demo.tagListView.style.normalAppearance.cornerRadius, 0);
    XCTAssertEqualWithAccuracy(first.layer.cornerRadius, CGRectGetHeight(first.bounds) / 2, 0.5);

    [demo performAction:@"iconColor.normal"];
    [collection layoutIfNeeded];
    first = [[collection cellForItemAtIndexPath:[self ip:1 :0]] valueForKey:@"button"];
    XCTAssertEqualObjects(first.imageView.tintColor, [demo.style iconColorForState:UIControlStateNormal]);

    [demo performAction:@"content.iconOnly"];
    [collection layoutIfNeeded];
    first = [[collection cellForItemAtIndexPath:[self ip:1 :0]] valueForKey:@"button"];
    XCTAssertEqual(first.title.length, 0u);
    XCTAssertEqualWithAccuracy(CGRectGetMidX(first.imageView.frame), CGRectGetWidth(first.bounds) / 2, 1, @"layoutCentered");

    [demo performAction:@"reset"];
    XCTAssertEqual(demo.content, CYLTagStyleDemoContentIconAndTitle);
    XCTAssertEqual(demo.tagListView.style.normalAppearance.cornerRadius, 3);
}

#pragma mark Configuration (map and file, as CYLTabBarController)

- (void)testDictionaryConfigurationCreatesAndStylesTheTags {
    CYLTagListView *view = [[CYLTagListView alloc] initWithConfiguration:[CYLTagConfigurationDemoViewController mapConfiguration]];
    view.frame = CGRectMake(0, 0, 375, 300);
    [view layoutIfNeeded];
    XCTAssertEqual(view.selectionMode, CYLMenuSelectionModeMultiple);
    XCTAssertFalse(view.isScrollEnabled);
    XCTAssertEqualObjects(view.selectedIndexPaths, @[[self ip:1 :0]]);
    XCTAssertNotNil(view.configurationDataSource, @"The view keeps the data source it built");
    XCTAssertEqual(view.menuDataSource, view.configurationDataSource);
    XCTAssertEqual([view.menuDataSource menuNumberOfItemsInSection:0], 5);
    XCTAssertEqualObjects([view.menuDataSource menuTitleForItemAtIndexPath:[self ip:4 :0]], @"Text only", @"A string item is a title");
    XCTAssertNotNil([view.menuDataSource menuImageForItemAtIndexPath:[self ip:3 :0]], @"system: images are SF Symbols");
    XCTAssertTrue(CGSizeEqualToSize(view.style.imageSize, CGSizeMake(20, 20)));
    XCTAssertEqual(view.style.normalAppearance.cornerRadius, 8);
    XCTAssertEqualObjects(view.style.normalAppearance.iconColor, UIColor.systemIndigoColor);
}

- (void)testConfigurationStringValuesAreConverted {
    CYLTagListView *view = [CYLTagListView tagListViewWithConfiguration:@{
        CYLTagListViewSelectionMode : @"single",
        CYLTagListViewFoldStyle : @"footerChevron",
        CYLTagListViewDefaultVisibleRows : @"2",
        CYLTagListViewShowsSectionHeaders : @"false",
        CYLTagListViewSelectedItems : @[@"1-0"],
        CYLTagListViewStyle : @{
            CYLMenuStyleImageInsets : @"{1, 2, 3, 4}",
            CYLMenuStyleTitlePositionAdjustment : @[@2, @-1],
            CYLMenuStyleImageSize : @{@"width": @18, @"height": @16},
            CYLMenuStyleLayoutCentered : @"no",
            CYLMenuStyleNormal : @{ CYLTagAppearanceTextColor : @"#FF0000",
                                    CYLTagAppearanceBorderColor : @"systemBlue",
                                    CYLTagAppearanceFont : @{@"size": @15, @"weight": @"bold"},
                                    CYLTagAppearanceMargin : @"6" },
        },
        CYLTagListViewSections : @[ @{ CYLTagSectionTitle : @"A", CYLTagSectionItems : @[@"x", @"y"] },
                                    @{ CYLTagSectionTitle : @"B", CYLTagSectionItems : @[ @{ CYLTagItemTitle : @"z", CYLTagItemEnabled : @"false" } ] } ],
    }];
    XCTAssertEqual(view.selectionMode, CYLMenuSelectionModeSingle);
    XCTAssertEqual(view.foldStyle, CYLMenuFoldStyleFooterChevron);
    XCTAssertEqual(view.defaultVisibleRows, 2u);
    XCTAssertFalse(view.showsSectionHeaders);
    XCTAssertEqualObjects(view.selectedIndexPaths, @[[self ip:0 :1]], @"\"section-item\"");
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(view.style.imageInsets, UIEdgeInsetsMake(1, 2, 3, 4)));
    XCTAssertTrue(UIOffsetEqualToOffset(view.style.titlePositionAdjustment, UIOffsetMake(2, -1)));
    XCTAssertTrue(CGSizeEqualToSize(view.style.imageSize, CGSizeMake(18, 16)));
    XCTAssertFalse(view.style.layoutCentered);
    CGFloat red = 0, green = 1, blue = 1, alpha = 0;
    [view.style.normalAppearance.textColor getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertEqualWithAccuracy(red, 1, 0.01);
    XCTAssertEqualWithAccuracy(green, 0, 0.01);
    XCTAssertEqualObjects(view.style.normalAppearance.borderColor, UIColor.systemBlueColor);
    XCTAssertEqualWithAccuracy(view.style.normalAppearance.font.pointSize, 15, 0.01);
    XCTAssertTrue(view.style.normalAppearance.font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold);
    XCTAssertEqual(view.style.normalAppearance.margin, 6);
    XCTAssertFalse([view.menuDataSource menuItemIsEnabledAtIndexPath:[self ip:0 :1]]);
}

- (void)testConfigurationFileCreatesAnimatedTags {
    NSError *error = nil;
    NSString *file = [CYLTagConfigurationDemoViewController configurationFilePath];
    NSDictionary *configuration = [CYLTagListView configurationWithContentsOfFile:file error:&error];
    XCTAssertNotNil(configuration, @"%@", error);
    CYLTagListView *view = [CYLTagListView tagListViewWithConfigurationFile:file error:&error];
    XCTAssertNotNil(view, @"%@", error);
    XCTAssertEqual(view.selectionMode, CYLMenuSelectionModeSingle);
    XCTAssertFalse(view.allowsEmptySelection);
    XCTAssertEqual(view.foldStyle, CYLMenuFoldStyleFooterChevron);
    XCTAssertEqualObjects(view.selectedIndexPaths, @[[self ip:0 :0]]);
    XCTAssertEqual(view.style.normalAppearance.cornerRadius, 0, @"A capsule");
    for (NSInteger item = 0; item < 4; item++) {
        NSURL *URL = [view.menuDataSource menuAnimationURLForItemAtIndexPath:[self ip:item :0]];
        XCTAssertNotNil(URL, @"item %ld", (long)item);
        XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:URL.path], @"%@ resolves next to the file or in the app", URL);
    }
    XCTAssertNil([CYLTagListView tagListViewWithConfigurationFile:@"missing.json" error:&error]);
    XCTAssertEqualObjects(error.domain, CYLMenuConfigurationErrorDomain);
    XCTAssertEqual(error.code, CYLMenuConfigurationErrorFileNotFound);
}

#pragma mark Animated icons (CYLTabBarController animation engine)

- (void)testAnimatedIconsUseCYLTabBarControllerAnimationEngine {
    XCTAssertTrue([CYLTagButton isAnimationEngineAvailable], @"CYLTabBarController/CYLTabBarItemAnimation is linked");
    NSURL *resources = NSBundle.mainBundle.resourceURL;
    NSDictionary<NSString *, NSString *> *files = @{
        @"GIF": @"CYLMenuExample.bundle/Animations/tab_star.gif",
        @"Lottie": @"CYLMenuExample.bundle/Animations/tab_home_animate.json",
        @"PAG": @"pag-ios/0.pag",
        @"Rive": @"CYLMenuExample.bundle/Animations/check.riv",
    };
    for (NSString *library in files) {
        NSURL *URL = [resources URLByAppendingPathComponent:files[library]];
        XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:URL.path], @"%@ file in the app", library);
        CYLTagButton *button = [self buttonWithTitle:library image:[UIImage systemImageNamed:@"star"] style:[CYLMenuStyle defaultStyle]];
        button.animationURL = URL;
        [button layoutIfNeeded];
        XCTAssertNotNil(button.animationView, @"%@ view from CYLTabBarItemAnimationFactory", library);
        XCTAssertNotNil(button.animationPlayer, @"%@ player", library);
        XCTAssertTrue(button.imageView.hidden, @"%@ takes the icon slot", library);
        XCTAssertTrue(CGSizeEqualToSize(button.animationView.frame.size, button.style.imageSize), @"%@ %@", library, NSStringFromCGRect(button.animationView.frame));
        XCTAssertEqualWithAccuracy(CGRectGetMinX(button.titleLabel.frame) - CGRectGetMaxX(button.animationView.frame), button.style.imageTitleSpacing, 0.5);
        button.selected = YES;
        [button playAnimation];
        button.selected = NO;
    }
    CYLTagButton *missing = [self buttonWithTitle:@"x" image:[UIImage systemImageNamed:@"star"] style:[CYLMenuStyle defaultStyle]];
    missing.animationURL = [resources URLByAppendingPathComponent:@"missing.json"];
    XCTAssertNil(missing.animationView, @"Falls back to the image");
    XCTAssertFalse(missing.imageView.hidden);
}

- (void)testStyleDemoShowsAnimatedIconsAndOpensTheConfigurationDemo {
    CYLTagStyleDemoViewController *demo = [[CYLTagStyleDemoViewController alloc] init];
    UINavigationController *navigation = [self hostController:demo];
    UICollectionView *collection = [self collectionViewOf:demo.tagListView];
    for (NSString *library in @[@"lottie", @"gif", @"pag", @"rive"]) {
        [demo performAction:[@"animation." stringByAppendingString:library]];
        [collection layoutIfNeeded];
        CYLTagButton *button = [[collection cellForItemAtIndexPath:[self ip:0 :0]] valueForKey:@"button"];
        XCTAssertEqualObjects(demo.animationLibrary, library);
        XCTAssertNotNil(button.animationView, @"%@", library);
    }
    [demo performAction:@"animation.off"];
    [collection layoutIfNeeded];
    XCTAssertNil([[[collection cellForItemAtIndexPath:[self ip:0 :0]] valueForKey:@"button"] animationView]);

    [demo performAction:@"configuration"];
    CYLTagConfigurationDemoViewController *configuration = (CYLTagConfigurationDemoViewController *)navigation.topViewController;
    XCTAssertTrue([configuration isKindOfClass:[CYLTagConfigurationDemoViewController class]]);
    [configuration loadViewIfNeeded];
    XCTAssertNotNil(configuration.fileTagListView, @"%@", configuration.configurationError);
    XCTAssertNotNil(configuration.mapTagListView);
}

#pragma mark Accessibility

- (void)testVoiceOverDescribesTagsAndFoldControls {
    CYLExampleMenuSource *source = [self sourceWithItemCount:30 sections:1];
    source.sections[0].items[2].enabled = NO;
    CYLTagListView *view = [self hostedViewWithSource:source width:320];
    view.foldStyle = CYLMenuFoldStyleFooterChevron;
    view.defaultVisibleRows = 2;
    view.selectedIndexPaths = @[[self ip:1 :0]];
    [view layoutIfNeeded];
    UICollectionView *collection = [self collectionViewOf:view];
    [collection layoutIfNeeded];
    for (NSInteger item = 0; item < 3; item++) {
        UICollectionViewCell *cell = [collection cellForItemAtIndexPath:[self ip:item :0]];
        XCTAssertTrue(cell.isAccessibilityElement);
        XCTAssertEqualObjects(cell.accessibilityLabel, source.sections[0].items[item].title);
        XCTAssertTrue(cell.accessibilityTraits & UIAccessibilityTraitButton);
        XCTAssertEqual((BOOL)(cell.accessibilityTraits & UIAccessibilityTraitSelected), item == 1);
        XCTAssertEqual((BOOL)(cell.accessibilityTraits & UIAccessibilityTraitNotEnabled), item == 2);
    }
    [self tap:view item:0 section:0];
    XCTAssertTrue([collection cellForItemAtIndexPath:[self ip:0 :0]].accessibilityTraits & UIAccessibilityTraitSelected,
                  @"Selection changes are reflected in the traits");

    UICollectionReusableView *header = [collection supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[self ip:0 :0]];
    XCTAssertTrue(((UILabel *)[header valueForKey:@"titleLabel"]).accessibilityTraits & UIAccessibilityTraitHeader);
    UICollectionReusableView *footer = [collection supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[self ip:0 :0]];
    UIButton *chevron = [footer valueForKey:@"chevronButton"];
    XCTAssertEqualObjects(chevron.accessibilityLabel, @"分组 0 更多");
    [view setExpanded:YES forSection:0 animated:NO];
    [collection layoutIfNeeded];
    // Thirty expanded tags are taller than the view: scroll the footer into view.
    [collection setContentOffset:CGPointMake(0, MAX(0, collection.contentSize.height - CGRectGetHeight(collection.bounds))) animated:NO];
    [collection layoutIfNeeded];
    footer = [collection supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[self ip:0 :0]];
    XCTAssertNotNil(footer);
    XCTAssertEqualObjects(((UIButton *)[footer valueForKey:@"chevronButton"]).accessibilityLabel, @"分组 0 收起");

    view.foldStyle = CYLMenuFoldStyleHeaderButton;
    [collection layoutIfNeeded];
    header = [collection supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[self ip:0 :0]];
    XCTAssertEqualObjects(((UIButton *)[header valueForKey:@"foldButton"]).accessibilityLabel, @"分组 0 收起");
}

- (void)testBoldTextMakesTagsBoldAndWider {
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    UITraitCollection *regular = [UITraitCollection traitCollectionWithTraitsFromCollections:@[
        [UITraitCollection traitCollectionWithLegibilityWeight:UILegibilityWeightRegular],
        [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryLarge]]];
    UITraitCollection *bold = [UITraitCollection traitCollectionWithTraitsFromCollections:@[
        [UITraitCollection traitCollectionWithLegibilityWeight:UILegibilityWeightBold],
        [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryLarge]]];
    UIFont *regularFont = [style titleFontForState:UIControlStateNormal traitCollection:regular];
    UIFont *boldFont = [style titleFontForState:UIControlStateNormal traitCollection:bold];
    XCTAssertFalse(regularFont.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold);
    XCTAssertTrue(boldFont.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold);
    NSString *title = @"Accessibility 无障碍";
    XCTAssertGreaterThan([title sizeWithAttributes:@{NSFontAttributeName: boldFont}].width,
                         [title sizeWithAttributes:@{NSFontAttributeName: regularFont}].width,
                         @"Measured with the bold font, so bold tags do not truncate");
}

- (void)testExampleControlsHaveSpokenLabels {
    CYLSearchCategoryViewController *controller = [[CYLSearchCategoryViewController alloc] init];
    [self hostController:controller];
    XCTAssertEqualObjects(controller.industryButton.accessibilityLabel, @"行业 IT互联网");
    XCTAssertEqualObjects(controller.industryButton.accessibilityHint, @"选择行业");
    [controller selectIndustry:@"金融"];
    XCTAssertEqualObjects(controller.industryButton.accessibilityLabel, @"行业 金融");
}

#pragma mark Scenario 1: review filter

- (UINavigationController *)hostController:(UIViewController *)controller {
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = navigation;
    [self.window makeKeyAndVisible];
    [controller loadViewIfNeeded];
    [controller.view layoutIfNeeded];
    return navigation;
}

- (void)waitForQueryOf:(CYLReviewListViewController *)controller {
    NSPredicate *done = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return !controller.query.isLoading;
    }];
    [self waitForExpectations:@[[[XCTNSPredicateExpectation alloc] initWithPredicate:done object:nil]] timeout:10];
}

- (NSArray *)identifiersOf:(NSArray<CYLReviewFilter *> *)filters {
    return [filters valueForKey:@"identifier"];
}

- (void)testMemoryFilteringMatchesEverySelectedTagImmediately {
    CYLReviewStore *store = [CYLReviewStore sharedStore];
    CYLReviewListViewController *controller = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:0];
    [self hostController:controller];
    CYLTagListView *filter = controller.filterView;
    XCTAssertEqual(controller.mode, CYLReviewFilteringModeMemory);
    XCTAssertEqual(filter.selectionMode, CYLMenuSelectionModeMultiple);
    XCTAssertEqualObjects(filter.selectedIndexPaths, @[[self ip:0 :0]]);
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)store.reviews.count);
    XCTAssertNil(controller.tableView.tableHeaderView, @"The filter sits above the list, not in it");
    XCTAssertGreaterThan([self collectionViewOf:filter].visibleCells.count, 0u);

    [self tap:filter item:1 section:0];  // 好评
    XCTAssertEqualObjects(filter.selectedIndexPaths, @[[self ip:1 :0]], @"Selecting a condition clears 全部");
    NSArray *good = [store reviewsMatchingAllFilters:@[store.filters[1]]];
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)good.count, @"Refreshed synchronously");
    XCTAssertTrue([controller.statusLabel.text containsString:@"点击「好评("]);

    [self tap:filter item:4 section:0];  // 有图: both must match
    NSArray *both = [store reviewsMatchingAllFilters:@[store.filters[1], store.filters[4]]];
    XCTAssertLessThan(both.count, good.count);
    XCTAssertEqualObjects([self identifiersOf:controller.selectedFilters], (@[@"good", @"photo"]));
    XCTAssertEqualObjects(controller.visibleReviews, both);
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)both.count);
    NSString *matches = [NSString stringWithFormat:@"匹配 %lu 条", (unsigned long)both.count];
    XCTAssertTrue([controller.statusLabel.text containsString:matches], @"%@", controller.statusLabel.text);

    [self tap:filter item:4 section:0];  // deselect 有图
    XCTAssertTrue([controller.statusLabel.text containsString:@"取消「有图("]);
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)good.count);
    [self tap:filter item:1 section:0];  // deselect the last condition
    XCTAssertEqualObjects(filter.selectedIndexPaths, @[[self ip:0 :0]], @"Nothing selected shows 全部");
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)store.reviews.count);

    [self tap:filter item:3 section:0];  // 差评(0) is disabled.
    XCTAssertEqualObjects(filter.selectedIndexPaths, @[[self ip:0 :0]]);
    [self tap:filter item:6 section:0];
    [self tap:filter item:0 section:0];  // 全部 clears the conditions
    XCTAssertEqualObjects(filter.selectedIndexPaths, @[[self ip:0 :0]]);
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)store.reviews.count);
}

- (void)testNetworkFilteringRefreshesWhenTheResponseArrives {
    CYLReviewStore *store = [CYLReviewStore sharedStore];
    CYLReviewListViewController *controller = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:0 mode:CYLReviewFilteringModeNetwork];
    CYLNetworkReviewQuery *network = (CYLNetworkReviewQuery *)controller.query;
    XCTAssertTrue([network isKindOfClass:[CYLNetworkReviewQuery class]]);
    network.latency = 0.3;
    [self hostController:controller];
    XCTAssertTrue(network.isLoading, @"The first page is requested from the server");
    [self waitForQueryOf:controller];
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)store.reviews.count);

    [self tap:controller.filterView item:1 section:0];  // 好评
    XCTAssertTrue(network.isLoading);
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)store.reviews.count, @"The list waits for the server");
    XCTAssertTrue([controller.statusLabel.text containsString:@"加载中"]);
    XCTAssertEqualObjects(network.lastRequestURL.absoluteString, @"https://api.example.com/reviews?filter=good");
    [self waitForQueryOf:controller];
    NSArray *good = [store reviewsMatchingAllFilters:@[store.filters[1]]];
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)good.count);
    NSString *returned = [NSString stringWithFormat:@"服务器返回 %lu 条", (unsigned long)good.count];
    XCTAssertTrue([controller.statusLabel.text containsString:returned], @"%@", controller.statusLabel.text);

    // Two quick changes: only the response to the last request is shown.
    NSUInteger dropped = network.droppedResponseCount;
    [self tap:controller.filterView item:4 section:0];
    [self tap:controller.filterView item:4 section:0];
    [self waitForQueryOf:controller];
    NSPredicate *droppedOne = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return network.droppedResponseCount > dropped;
    }];
    [self waitForExpectations:@[[[XCTNSPredicateExpectation alloc] initWithPredicate:droppedOne object:nil]] timeout:10];
    XCTAssertEqualObjects(controller.visibleReviews, good);

    // The server receives every condition.
    NSURL *URL = [CYLNetworkReviewQuery requestURLForFilters:@[store.filters[1], store.filters[6]]];
    XCTAssertTrue([URL.query containsString:@"filter=good"]);
    XCTAssertEqualObjects([CYLReviewServer reviewsForRequestURL:URL], ([store reviewsMatchingAllFilters:@[store.filters[1], store.filters[6]]]));
}

- (void)testFilteringModesAreSeparateScenarios {
    CYLReviewListViewController *controller = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:0];
    [self hostController:controller];
    XCTAssertEqual(controller.navigationItem.titleView, controller.modeControl);
    XCTAssertEqualObjects([controller.modeControl titleForSegmentAtIndex:0], @"内存筛选");
    XCTAssertEqualObjects([controller.modeControl titleForSegmentAtIndex:1], @"网络筛选");
    XCTAssertTrue([controller.query isKindOfClass:[CYLMemoryReviewQuery class]]);
    XCTAssertTrue([controller.statusLabel.text containsString:@"内存筛选"]);
    controller.modeControl.selectedSegmentIndex = 1;
    [controller.modeControl sendActionsForControlEvents:UIControlEventValueChanged];
    XCTAssertEqual(controller.mode, CYLReviewFilteringModeNetwork);
    XCTAssertTrue([controller.query isKindOfClass:[CYLNetworkReviewQuery class]]);
    XCTAssertTrue([controller.statusLabel.text containsString:@"网络筛选"]);
    [self waitForQueryOf:controller];
}

- (void)testFoldChevronFoldsToTwoRowsAndTurns {
    CYLReviewListViewController *controller = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:0];
    [self hostController:controller];
    CYLTagListView *filter = controller.filterView;
    UICollectionView *collection = [self collectionViewOf:filter];
    [collection layoutIfNeeded];
    XCTAssertTrue([filter canFoldSection:0]);
    NSInteger total = [filter.menuDataSource menuNumberOfItemsInSection:0];
    NSInteger folded = [collection numberOfItemsInSection:0];
    XCTAssertLessThan(folded, total, @"Folded to two rows");
    UICollectionReusableView *footer = [collection supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[self ip:0 :0]];
    UIButton *chevron = [footer valueForKey:@"chevronButton"];
    XCTAssertNotNil(chevron);
    XCTAssertTrue(CGAffineTransformIsIdentity(chevron.imageView.transform), @"Points down while folded");
    CGFloat foldedHeight = CGRectGetHeight(filter.frame);

    [chevron sendActionsForControlEvents:UIControlEventTouchUpInside];
    [controller.view layoutIfNeeded];
    XCTAssertTrue([filter isSectionExpanded:0]);
    XCTAssertEqual([collection numberOfItemsInSection:0], total, @"Every row is shown");
    UICollectionReusableView *sameFooter = [collection supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[self ip:0 :0]];
    XCTAssertEqual(sameFooter, footer, @"The footer stays, so its chevron can turn");
    XCTAssertEqualWithAccuracy(chevron.imageView.transform.a, -1, 0.01, @"Turned 180°");
    XCTAssertGreaterThan(CGRectGetHeight(filter.frame), foldedHeight);

    [chevron sendActionsForControlEvents:UIControlEventTouchUpInside];
    [controller.view layoutIfNeeded];
    XCTAssertEqual([collection numberOfItemsInSection:0], folded);
    XCTAssertEqualWithAccuracy(chevron.imageView.transform.a, 1, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(filter.frame), foldedHeight, 1);
}

- (void)testReviewPagePreselectsAndRevealsKeywordFilter {
    CYLReviewStore *store = [CYLReviewStore sharedStore];
    NSUInteger last = store.filters.count - 1;
    CYLReviewListViewController *controller = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:last];
    [self hostController:controller];
    XCTAssertEqualObjects(controller.filterView.selectedIndexPaths, @[[self ip:(NSInteger)last :0]]);
    XCTAssertGreaterThan([controller.filterView numberOfVisibleItemsInSection:0], (NSInteger)last);
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)[store reviewsMatchingFilter:store.filters[last]].count);
}

- (void)testProductPreviewShowsTwoRowsAndOpensReviews {
    CYLProductViewController *controller = [[CYLProductViewController alloc] init];
    UINavigationController *navigation = [self hostController:controller];
    CYLTagListView *preview = controller.previewView;
    XCTAssertEqual(preview.selectionMode, CYLMenuSelectionModeNone);
    XCTAssertEqual(preview.foldStyle, CYLMenuFoldStyleTruncate);
    NSInteger total = [preview.menuDataSource menuNumberOfItemsInSection:0];
    if ([preview numberOfRowsInSection:0] > 2) {
        XCTAssertLessThan([preview numberOfVisibleItemsInSection:0], total, @"Only two rows are previewed");
    } else {
        XCTAssertEqual([preview numberOfVisibleItemsInSection:0], total);
    }
    XCTAssertEqualWithAccuracy(CGRectGetHeight(preview.frame), [preview heightThatFitsWidth:CGRectGetWidth(preview.bounds)], 1);

    [self tap:preview item:1 section:0];
    CYLReviewListViewController *reviews = (CYLReviewListViewController *)navigation.topViewController;
    XCTAssertTrue([reviews isKindOfClass:[CYLReviewListViewController class]]);
    [reviews loadViewIfNeeded];
    XCTAssertEqual(reviews.selectedFilters.count, 1u);
    XCTAssertTrue(reviews.selectedFilters.firstObject.isKeyword);
    XCTAssertEqualObjects(preview.selectedIndexPaths, @[]);
}

#pragma mark Scenario 2: search categories

- (void)layOutSelectedCategoryOf:(CYLSearchCategoryViewController *)controller {
    [controller.view layoutIfNeeded];
    [controller.categoryTabBarController.view layoutIfNeeded];
    [controller.categoryTabBarController.selectedViewController.view layoutIfNeeded];
    [controller.tagListView layoutIfNeeded];
}

- (void)testSearchCategoriesUseABottomTabBarAndFillTheSearchBar {
    CYLSearchCategoryViewController *controller = [[CYLSearchCategoryViewController alloc] init];
    [self hostController:controller];
    [self layOutSelectedCategoryOf:controller];
    CYLTabBarController *tabs = controller.categoryTabBarController;
    XCTAssertTrue([tabs isKindOfClass:[CYLTabBarController class]]);
    XCTAssertEqual(tabs.viewControllers.count, 4u);
    XCTAssertEqualObjects([tabs.tabBar.items valueForKey:@"title"], (@[@"找人", @"动态", @"八卦", @"职位"]));
    CYLTagListView *tags = controller.tagListView;
    CGRect barFrame = [tabs.tabBar convertRect:tabs.tabBar.bounds toView:controller.view];
    CGRect tagsFrame = [tags convertRect:tags.bounds toView:controller.view];
    XCTAssertGreaterThan(CGRectGetMinY(barFrame), CGRectGetHeight(controller.view.bounds) / 2, @"Tab bars are always at the bottom");
    XCTAssertLessThanOrEqual(CGRectGetMaxY(tagsFrame), CGRectGetMinY(barFrame) + 0.5, @"Tags end above the tab bar");
    XCTAssertNotNil(tags.window);

    UICollectionView *collection = [self collectionViewOf:tags];
    XCTAssertEqual(controller.category, CYLSearchCategoryPeople);
    XCTAssertEqual([collection numberOfSections], 4);
    XCTAssertEqualObjects(controller.searchBar.placeholder, @"搜人名,职位,公司...");
    [self tap:tags item:1 section:1];
    XCTAssertEqualObjects(controller.searchBar.text, @"IDG资本");
    XCTAssertEqualObjects(tags.selectedIndexPaths, @[]);

    // A tap on the 八卦 tab, as the tab bar reports it.
    tabs.selectedIndex = CYLSearchCategoryGossip;
    [tabs.delegate tabBarController:tabs didSelectViewController:tabs.selectedViewController];
    [self layOutSelectedCategoryOf:controller];
    XCTAssertEqual(controller.category, CYLSearchCategoryGossip);
    XCTAssertEqualObjects(controller.searchBar.placeholder, @"搜八卦");
    CYLTagListView *gossip = controller.tagListView;
    XCTAssertNotEqual(gossip, tags);
    XCTAssertNil(tags.window, @"Only the selected category's page is shown");
    XCTAssertNotNil(gossip.window);
    XCTAssertEqual([[self collectionViewOf:gossip] numberOfSections], 2);
    [self assertNoOverlapsOrOverflowIn:gossip];
    [self tap:gossip item:2 section:0];
    XCTAssertEqualObjects(controller.searchBar.text, @"程序猿");
}

- (void)testJobCategoriesUseSidebarAndIndustryAccessory {
    CYLSearchCategoryViewController *controller = [[CYLSearchCategoryViewController alloc] init];
    [self hostController:controller];
    [controller selectCategory:CYLSearchCategoryJobs];
    [self layOutSelectedCategoryOf:controller];
    XCTAssertEqual(controller.categoryTabBarController.selectedIndex, (NSUInteger)CYLSearchCategoryJobs);
    CYLTagListView *tags = controller.tagListView;
    UICollectionView *collection = [self collectionViewOf:tags];
    XCTAssertEqual(controller.jobCategoryTableView.superview, tags.superview);
    XCTAssertEqualWithAccuracy(CGRectGetMinX(tags.frame), CGRectGetMaxX(controller.jobCategoryTableView.frame), 0.5);
    XCTAssertEqual([controller.jobCategoryTableView numberOfRowsInSection:0], 10);
    XCTAssertEqual([collection numberOfItemsInSection:0], 31);
    [self assertNoOverlapsOrOverflowIn:tags];

    [collection layoutIfNeeded];
    UICollectionReusableView *header = [collection supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[self ip:0 :0]];
    XCTAssertEqual(controller.industryButton.superview, header);
    [controller selectIndustry:@"金融"];
    XCTAssertEqualObjects(controller.industry, @"金融");
    XCTAssertTrue([[controller.industryButton titleForState:UIControlStateNormal] containsString:@"金融"]);

    [controller.jobCategoryTableView.delegate tableView:controller.jobCategoryTableView
                                didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    XCTAssertEqual([collection numberOfItemsInSection:0], 7);
    [self tap:tags item:0 section:0];
    XCTAssertEqualObjects(controller.searchBar.text, @"测试工程师");
}

#pragma mark Localization

- (void)testComponentStringsComeFromOneBundleInEveryLanguage {
    NSBundle *bundle = [CYLMenuResources bundle];
    XCTAssertEqualObjects(bundle.bundleURL.lastPathComponent, @"CYLClassifyMenuResources.bundle");
    NSArray *languages = [CYLMenuResources availableLanguages];
    XCTAssertEqualObjects(languages, (@[@"en", @"zh-Hans", @"zh-Hant"]));
    NSDictionary *english = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"CYLClassifyMenu" ofType:@"strings" inDirectory:nil forLocalization:@"en"]];
    XCTAssertGreaterThan(english.count, 0u);
    for (NSString *language in languages) {
        NSDictionary *table = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"CYLClassifyMenu" ofType:@"strings" inDirectory:nil forLocalization:language]];
        XCTAssertEqualObjects([NSSet setWithArray:table.allKeys], [NSSet setWithArray:english.allKeys], @"%@ has the same keys as en", language);
    }
    XCTAssertEqualObjects([CYLMenuResources localizedStringForKey:@"CYLMenuExpand" language:@"en"], @"More");
    XCTAssertEqualObjects([CYLMenuResources localizedStringForKey:@"CYLMenuExpand" language:@"zh-Hans"], @"更多");
    XCTAssertEqualObjects([CYLMenuResources localizedStringForKey:@"CYLMenuCollapse" language:@"zh-Hant"], @"收合");
    XCTAssertEqualObjects([CYLMenuResources localizedStringForKey:@"CYLMenuExpand" language:@"fr"], @"More", @"Unknown languages fall back to English");
    XCTAssertEqualObjects([CYLMenuResources localizedStringForKey:@"NoSuchKey"], @"NoSuchKey");

    CYLMenuResources.preferredLanguage = @"en";
    XCTAssertEqualObjects([CYLMenuResources currentLanguage], @"en");
    XCTAssertEqualObjects([CYLMenuStyle defaultStyle].expandTitle, @"More");
    CYLMenuResources.preferredLanguage = @"zh-Hant-TW";
    XCTAssertEqualObjects([CYLMenuResources currentLanguage], @"zh-Hant", @"Regional variants match their language");
    XCTAssertEqualObjects([CYLMenuStyle defaultStyle].collapseTitle, @"收合");
}

- (void)testExampleSwitchesLanguage {
    CYLMenuResources.preferredLanguage = @"en";
    CYLTabBarController *tabs = [CYLExampleAppDelegate makeRootTabBarController];
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    self.window.rootViewController = tabs;
    [self.window makeKeyAndVisible];
    [tabs.view layoutIfNeeded];
    XCTAssertEqualObjects([tabs.tabBar.items valueForKey:@"title"], (@[@"Reviews", @"Search", @"Styles"]));

    CYLSearchCategoryViewController *search = [[CYLSearchCategoryViewController alloc] init];
    [self hostController:search];
    XCTAssertEqualObjects([search.categoryTabBarController.tabBar.items valueForKey:@"title"], (@[@"People", @"Posts", @"Gossip", @"Jobs"]));
    XCTAssertEqualObjects(search.searchBar.placeholder, @"Search people, titles, companies...");
    XCTAssertEqualObjects(search.industryButton.accessibilityLabel, @"Industry Internet");
    [search selectCategory:CYLSearchCategoryJobs];
    [self layOutSelectedCategoryOf:search];
    XCTAssertEqualObjects([search.tagListView.menuDataSource menuTitleForSection:0], @"Trending job keywords:");

    CYLReviewListViewController *reviews = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:0];
    [self hostController:reviews];
    XCTAssertEqualObjects([reviews.filterView.menuDataSource menuTitleForItemAtIndexPath:[self ip:0 :0]], @"All");
    XCTAssertTrue([[reviews.filterView.menuDataSource menuTitleForItemAtIndexPath:[self ip:1 :0]] hasPrefix:@"Positive("]);
    XCTAssertEqualObjects(reviews.filterView.style.expandTitle, @"More");
}

#pragma mark Root tab bar

- (void)testRootTabBarHoldsBothScenarios {
    CYLTabBarController *tabs = [CYLExampleAppDelegate makeRootTabBarController];
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    self.window.rootViewController = tabs;
    [self.window makeKeyAndVisible];
    [tabs.view layoutIfNeeded];
    XCTAssertEqual(tabs.viewControllers.count, 3u);
    XCTAssertEqualObjects([tabs.tabBar.items valueForKey:@"title"], (@[@"场景一：评价筛选", @"场景二：搜索分类", @"样式"]));
    UINavigationController *first = (UINavigationController *)tabs.viewControllers[0];
    UINavigationController *second = (UINavigationController *)tabs.viewControllers[1];
    XCTAssertTrue([first.viewControllers.firstObject isKindOfClass:[CYLProductViewController class]]);
    XCTAssertTrue([second.viewControllers.firstObject isKindOfClass:[CYLSearchHomeViewController class]]);
    XCTAssertGreaterThan(CGRectGetMinY(tabs.tabBar.frame), CGRectGetHeight(tabs.view.bounds) / 2, @"The root tab bar is at the bottom");

    // Scenario 2: the home page pushes the search screen, which hides the root tab bar and
    // shows its own category tab bar, also at the bottom: two tab bars with different roles.
    tabs.selectedIndex = 1;
    CYLSearchHomeViewController *home = (CYLSearchHomeViewController *)second.viewControllers.firstObject;
    [home loadViewIfNeeded];
    CYLSearchCategoryViewController *search = [home openSearch];
    XCTAssertEqual(second.topViewController, search);
    XCTAssertTrue(search.hidesBottomBarWhenPushed);
    [search loadViewIfNeeded];
    XCTAssertNotEqual(search.categoryTabBarController, tabs);
    XCTAssertEqual(search.categoryTabBarController.parentViewController, search);

    // The review page hides the root tab bar.
    tabs.selectedIndex = 0;
    CYLProductViewController *product = (CYLProductViewController *)first.viewControllers.firstObject;
    [product loadViewIfNeeded];
    [product showReviewsWithFilterIndex:0];
    XCTAssertTrue(first.topViewController.hidesBottomBarWhenPushed);
}

@end
