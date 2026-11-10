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
#import "CYLProductViewController.h"
#import "CYLReviewListViewController.h"
#import "CYLReviewStore.h"
#import "CYLSearchCategoryViewController.h"

@interface CYLRecordingDelegate : NSObject <CYLMenuDelegate>
@property (nonatomic, strong) NSMutableArray<NSString *> *events;
@property (nonatomic, strong, nullable) NSIndexPath *blockedIndexPath;
@property (nonatomic, assign) CGFloat lastHeight;
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
    style.selectedItemBackgroundColor = [UIColor redColor];
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
        BOOL red = CGColorEqualToColor(cell.contentView.layer.backgroundColor, [UIColor redColor].CGColor);
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
    UIImageView *iconView = [cell valueForKey:@"iconView"];
    XCTAssertEqual(iconView.image, icon);

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
    style.cornerRadius = -1;
    view.style = style;
    [view layoutIfNeeded];
    UICollectionView *collection = [self collectionViewOf:view];
    XCTAssertEqualWithAccuracy([collection.collectionViewLayout layoutAttributesForItemAtIndexPath:[self ip:0 :0]].frame.size.height, 40, 0.5);
    style.itemHeight = 10;
    XCTAssertEqualWithAccuracy(view.style.itemHeight, 40, 0.01, @"The view keeps its own copy");

    UITraitCollection *large = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];
    UIFont *largeFont = [view.style itemFontForTraitCollection:large];
    XCTAssertGreaterThan(largeFont.pointSize, view.style.font.pointSize);
    XCTAssertLessThanOrEqual(largeFont.pointSize, view.style.font.pointSize * CYLMaximumFontScale + 0.01);
    CYLMenuStyle *fixed = [view.style copy];
    fixed.adjustsFontForContentSizeCategory = NO;
    XCTAssertEqualWithAccuracy([fixed itemFontForTraitCollection:large].pointSize, fixed.font.pointSize, 0.01);
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
    footer = [collection supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[self ip:0 :0]];
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
    UIFont *regularFont = [style itemFontForTraitCollection:regular];
    UIFont *boldFont = [style itemFontForTraitCollection:bold];
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

- (void)testReviewFilterSelectsAndFiltersReviews {
    CYLReviewStore *store = [CYLReviewStore sharedStore];
    CYLReviewListViewController *controller = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:0];
    [self hostController:controller];
    CYLTagListView *filter = controller.filterView;
    XCTAssertEqual(filter.foldStyle, CYLMenuFoldStyleFooterChevron);
    XCTAssertEqualObjects(filter.selectedIndexPaths, @[[self ip:0 :0]]);
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)store.reviews.count);
    XCTAssertEqual(controller.tableView.tableHeaderView, filter);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(filter.frame), filter.contentHeight, 1);
    // Regression: collapsed chips must be drawn inside the table header, not
    // pushed out by the navigation bar's safe-area inset.
    UICollectionView *filterCollection = [self collectionViewOf:filter];
    [filterCollection layoutIfNeeded];
    XCTAssertEqual(filterCollection.contentInsetAdjustmentBehavior, UIScrollViewContentInsetAdjustmentNever);
    XCTAssertEqualWithAccuracy(filterCollection.contentOffset.y, -filterCollection.contentInset.top, 0.5);
    XCTAssertGreaterThan(filterCollection.visibleCells.count, 0u);
    for (UICollectionViewCell *cell in filterCollection.visibleCells) {
        CGRect frame = [cell convertRect:cell.bounds toView:filter];
        XCTAssertTrue(CGRectContainsRect(CGRectInset(filter.bounds, -0.5, -0.5), frame), @"%@", NSStringFromCGRect(frame));
    }

    [self tap:filter item:1 section:0];  // 好评
    NSUInteger good = [store reviewsMatchingFilter:store.filters[1]].count;
    XCTAssertEqual([controller.tableView numberOfRowsInSection:0], (NSInteger)good);
    NSString *countSuffix = [NSString stringWithFormat:@"(%lu)", (unsigned long)good];
    XCTAssertTrue([[store titleForFilter:store.filters[1]] hasSuffix:countSuffix]);

    [self tap:filter item:1 section:0];
    XCTAssertEqualObjects(filter.selectedIndexPaths, @[[self ip:1 :0]], @"Tapping the selected chip keeps it");
    [self tap:filter item:3 section:0];  // 差评(0) is disabled.
    XCTAssertEqualObjects(filter.selectedIndexPaths, @[[self ip:1 :0]]);

    CGFloat collapsed = CGRectGetHeight(filter.frame);
    [filter setExpanded:YES forSection:0 animated:NO];
    XCTAssertGreaterThan(CGRectGetHeight(filter.frame), collapsed, @"The table header follows the expanded height");
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
    CYLReviewFilter *filter = [CYLReviewStore sharedStore].filters[reviews.selectedFilterIndex];
    XCTAssertTrue(filter.isKeyword);
    XCTAssertEqualObjects(preview.selectedIndexPaths, @[]);
}

#pragma mark Scenario 2: search categories

- (void)layOutSelectedCategoryOf:(CYLSearchCategoryViewController *)controller {
    [controller.view layoutIfNeeded];
    [controller.categoryTabBarController.view layoutIfNeeded];
    [controller.categoryTabBarController.selectedViewController.view layoutIfNeeded];
    [controller.tagListView layoutIfNeeded];
}

- (void)testSearchCategoriesUseATopTabBarAndFillTheSearchBar {
    CYLSearchCategoryViewController *controller = [[CYLSearchCategoryViewController alloc] init];
    [self hostController:controller];
    [self layOutSelectedCategoryOf:controller];
    CYLTopTabBarController *tabs = controller.categoryTabBarController;
    XCTAssertTrue([tabs isKindOfClass:[CYLTabBarController class]]);
    XCTAssertEqual(tabs.viewControllers.count, 4u);
    XCTAssertEqualObjects([tabs.tabBar.items valueForKey:@"title"], (@[@"找人", @"动态", @"八卦", @"职位"]));
    CYLTagListView *tags = controller.tagListView;
    CGRect barFrame = [tabs.tabBar convertRect:tabs.tabBar.bounds toView:controller.view];
    CGRect tagsFrame = [tags convertRect:tags.bounds toView:controller.view];
    XCTAssertLessThan(CGRectGetMaxY(barFrame), CGRectGetHeight(controller.view.bounds) / 2, @"The category tab bar is at the top");
    XCTAssertGreaterThanOrEqual(CGRectGetMinY(tagsFrame), CGRectGetMaxY(barFrame) - 0.5, @"Tags start below the tab bar");
    XCTAssertFalse(tags.hidden);

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
    XCTAssertTrue(tags.hidden, @"Only the selected category is shown");
    XCTAssertFalse(gossip.hidden);
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
    XCTAssertEqualObjects([tabs.tabBar.items valueForKey:@"title"], (@[@"Reviews", @"Search"]));

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
    XCTAssertEqual(tabs.viewControllers.count, 2u);
    XCTAssertEqualObjects([tabs.tabBar.items valueForKey:@"title"], (@[@"场景一：评价筛选", @"场景二：搜索分类"]));
    UINavigationController *first = (UINavigationController *)tabs.viewControllers[0];
    UINavigationController *second = (UINavigationController *)tabs.viewControllers[1];
    XCTAssertTrue([first.viewControllers.firstObject isKindOfClass:[CYLProductViewController class]]);
    XCTAssertTrue([second.viewControllers.firstObject isKindOfClass:[CYLSearchCategoryViewController class]]);
    XCTAssertGreaterThan(CGRectGetMinY(tabs.tabBar.frame), CGRectGetHeight(tabs.view.bounds) / 2, @"The root tab bar is at the bottom");

    // Two tab bars with different roles: scenario 2 adds its own category tabs.
    tabs.selectedIndex = 1;
    CYLSearchCategoryViewController *search = (CYLSearchCategoryViewController *)second.viewControllers.firstObject;
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
