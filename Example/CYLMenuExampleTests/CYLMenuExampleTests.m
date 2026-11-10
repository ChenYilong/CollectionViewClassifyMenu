//
//  CYLMenuExampleTests.m
//  CYLMenuExampleTests
//
//  Covers the CYLTagListView API and the two README scenarios built with it.
//

#import <XCTest/XCTest.h>
@import CollectionViewClassifyMenu;
#import "CYLExampleMenuSource.h"
#import "CYLExampleListViewController.h"
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
    return [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.item];
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

- (void)tearDown {
    self.window.hidden = YES;
    self.window = nil;
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
                               @"Titles differ only in their numbers, so the image accounts for the difference");
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

- (void)testSearchCategoriesFillTheSearchBar {
    CYLSearchCategoryViewController *controller = [[CYLSearchCategoryViewController alloc] init];
    [self hostController:controller];
    CYLTagListView *tags = controller.tagListView;
    UICollectionView *collection = [self collectionViewOf:tags];
    XCTAssertEqual(controller.category, CYLSearchCategoryPeople);
    XCTAssertEqual([collection numberOfSections], 4);
    XCTAssertEqualObjects(controller.searchBar.placeholder, @"搜人名,职位,公司...");
    XCTAssertTrue(controller.jobCategoryTableView.hidden);

    [self tap:tags item:1 section:1];
    XCTAssertEqualObjects(controller.searchBar.text, @"IDG资本");
    XCTAssertEqualObjects(tags.selectedIndexPaths, @[]);

    controller.categoryControl.selectedSegmentIndex = CYLSearchCategoryGossip;
    [controller.categoryControl sendActionsForControlEvents:UIControlEventValueChanged];
    [controller.view layoutIfNeeded];
    XCTAssertEqual([collection numberOfSections], 2);
    XCTAssertEqualObjects(controller.searchBar.placeholder, @"搜八卦");
    [self assertNoOverlapsOrOverflowIn:tags];
}

- (void)testJobCategoriesUseSidebarAndIndustryAccessory {
    CYLSearchCategoryViewController *controller = [[CYLSearchCategoryViewController alloc] init];
    [self hostController:controller];
    [controller selectCategory:CYLSearchCategoryJobs];
    [controller.view layoutIfNeeded];
    CYLTagListView *tags = controller.tagListView;
    UICollectionView *collection = [self collectionViewOf:tags];
    XCTAssertFalse(controller.jobCategoryTableView.hidden);
    XCTAssertEqualWithAccuracy(CGRectGetMinX(tags.frame), CGRectGetMaxX(controller.jobCategoryTableView.frame), 0.5);
    XCTAssertEqual([controller.jobCategoryTableView numberOfRowsInSection:0], 10);
    NSInteger developmentCount = [collection numberOfItemsInSection:0];
    XCTAssertEqual(developmentCount, 31);
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

- (void)testExampleListOpensBothScenarios {
    CYLExampleListViewController *list = [[CYLExampleListViewController alloc] initWithStyle:UITableViewStyleInsetGrouped];
    [self hostController:list];
    XCTAssertEqual([list.tableView numberOfRowsInSection:0], 2);
    XCTAssertTrue([[list viewControllerForRow:0] isKindOfClass:[CYLProductViewController class]]);
    XCTAssertTrue([[list viewControllerForRow:1] isKindOfClass:[CYLSearchCategoryViewController class]]);
}

@end
