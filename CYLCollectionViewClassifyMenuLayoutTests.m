#import <XCTest/XCTest.h>
@import CollectionViewClassifyMenu;

// Core tests: they use the demo data (data.json of the host app) but no demo code. The demo app's own tests
// (CYLMainViewController, CYLDemoLocalizedString) are in CYLClassifyMenuDemoTests.swift.

/// data.json's sections, read directly (the demo's CYLDBManager is Swift and app code).
static NSArray<NSDictionary *> *CYLTestDataSource(void) {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"data.json" withExtension:nil];
    NSData *data = url ? [NSData dataWithContentsOfURL:url] : nil;
    NSArray *sections = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] : nil;
    return [sections isKindOfClass:[NSArray class]] ? sections : @[];
}

/// Every item title of data.json, in order.
static NSArray<NSString *> *CYLTestAllTags(void) {
    NSMutableArray *tags = [NSMutableArray array];
    for (NSDictionary *section in CYLTestDataSource()) {
        for (NSDictionary *item in section[CYLMenuKeys.dataSourceSectionKey]) {
            [tags addObject:item[CYLMenuKeys.dataSourceCellTextKey]];
        }
    }
    return tags;
}

@interface CYLTestMenuSource : NSObject <CYLMenuDataSource, CYLMenuDelegate>
@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *sections;
@property (nonatomic, copy) NSArray<NSIndexPath *> *confirmed;
@property (nonatomic, strong) NSIndexPath *lastSelection;
@end

@implementation CYLTestMenuSource
- (NSInteger)numberOfSectionsInMenu { return self.sections.count; }
- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section { return self.sections[section].count; }
- (NSString *)menuTitleForSection:(NSInteger)section { return [NSString stringWithFormat:@"Section %ld", (long)section]; }
- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath { return self.sections[indexPath.section][indexPath.item]; }
- (BOOL)menuItemIsExclusiveAtIndexPath:(NSIndexPath *)indexPath { return indexPath.item == 0; }
- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath { self.lastSelection = indexPath; }
- (void)menu:(id)menu didConfirmSelectedItems:(NSArray<NSIndexPath *> *)indexPaths { self.confirmed = indexPaths; }
@end

@interface CYLLayoutFixture : NSObject <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSArray<NSArray<NSString *> *> *sections;
@end

@implementation CYLLayoutFixture
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sections.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sections[section].count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessibilityLabel = self.sections[indexPath.section][indexPath.item];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.sections[indexPath.section][indexPath.item];
    CGFloat width = ceil([title sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}].width) + 16;
    return CGSizeMake(MIN(width, CGRectGetWidth(collectionView.bounds) - 32), 30);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(12, 16, 10, 16);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return section == 0 ? 8 : 13;
}
@end

@interface CYLCountingLayout : CYLCollectionViewLeftAlignedLayout
@property (nonatomic, assign) NSUInteger itemLookups;
@end

@implementation CYLCountingLayout
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.itemLookups++;
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}
@end

@interface CYLCollectionViewClassifyMenuLayoutTests : XCTestCase
@end

@interface UIViewController (CYLTesting)
- (void)cyl_judgeMoreButtonShowWhenDefaultRowsCount:(NSUInteger)defaultRowsCount;
@end

@implementation CYLCollectionViewClassifyMenuLayoutTests

- (void)testNamespacedCategoryMethodsAndClasses {
    NSArray *items = @[@"example"];
    NSDictionary *dictionary = @{@"key": @"value"};
    XCTAssertTrue([[items cyl_descriptionWithLocale:nil] containsString:@"example"]);
    XCTAssertTrue([[dictionary cyl_descriptionWithLocale:nil] containsString:@"value"]);
    XCTAssertEqual(NSClassFromString(@"CYLCollectionViewLeftAlignedLayout"), [CYLCollectionViewLeftAlignedLayout class]);
    XCTAssertEqual(NSClassFromString(@"CYLFilterBaseController"), [CYLFilterBaseController class]);
    XCTAssertEqual(NSClassFromString(@"CYLTagView"), [CYLTagView class]);
}

- (NSArray<NSArray<NSString *> *> *)longEmojiSections {
    NSMutableArray *sections = [NSMutableArray array];
    NSArray *source = CYLTestDataSource();
    XCTAssertGreaterThan(source.count, 0u);
    NSUInteger index = 0;
    for (NSDictionary *section in source) {
        NSMutableArray *titles = [NSMutableArray array];
        for (NSDictionary *item in section[CYLMenuKeys.dataSourceSectionKey]) {
            NSString *title = item[CYLMenuKeys.dataSourceCellTextKey];
            XCTAssertNotNil(title);
            [titles addObject:[title stringByAppendingString:index++ % 2 ? @" 🍜 长文字示例" : @" 🧑‍🍳✨ 很长的测试标签包含多个 emoji"]];
        }
        [sections addObject:titles];
    }
    NSArray *filterSections = @[@[@"全部", @"北京"], [@[@"全部"] arrayByAddingObjectsFromArray:CYLTestAllTags()]];
    for (NSArray *sourceSection in filterSections) {
        NSMutableArray *titles = [NSMutableArray array];
        for (NSString *title in sourceSection) {
            [titles addObject:[title stringByAppendingString:index++ % 2 ? @" 🌟 额外文本" : @" 🧑‍💻🍜 更长的筛选内容"]];
        }
        [sections addObject:titles];
    }
    return sections;
}

- (void)assertNoOverlaps:(UICollectionView *)collectionView fixture:(CYLLayoutFixture *)fixture {
    UICollectionViewLayout *layout = collectionView.collectionViewLayout;
    for (NSInteger section = 0; section < fixture.sections.count; section++) {
        id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)collectionView.delegate;
        UIEdgeInsets inset = [delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]
            ? [delegate collectionView:collectionView layout:layout insetForSectionAtIndex:section]
            : ((UICollectionViewFlowLayout *)layout).sectionInset;
        UICollectionViewLayoutAttributes *previous = nil;
        for (NSInteger item = 0; item < fixture.sections[section].count; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attributes = [layout layoutAttributesForItemAtIndexPath:indexPath];
            XCTAssertNotNil(attributes, @"Missing attributes for %@", indexPath);
            if (!attributes) continue;
            XCTAssertGreaterThan(CGRectGetWidth(attributes.frame), 0);
            XCTAssertLessThanOrEqual(CGRectGetMaxX(attributes.frame), CGRectGetWidth(collectionView.bounds) - inset.right + 0.01);
            if (previous) {
                XCTAssertFalse(CGRectIntersectsRect(previous.frame, attributes.frame), @"Overlapping items %@ and %@", previous.indexPath, indexPath);
            }
            CGRect frame = attributes.frame;
            attributes.frame = CGRectZero;
            XCTAssertTrue(CGRectEqualToRect([layout layoutAttributesForItemAtIndexPath:indexPath].frame, frame));
            previous = [layout layoutAttributesForItemAtIndexPath:indexPath];
        }
    }
}

- (void)assertVisibleCells:(UICollectionView *)collectionView fixture:(CYLLayoutFixture *)fixture buttonKey:(NSString *)buttonKey {
    NSArray<NSIndexPath *> *visible = collectionView.indexPathsForVisibleItems;
    XCTAssertGreaterThan(visible.count, 0u);
    for (NSIndexPath *indexPath in visible) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        UIButton *button = [cell valueForKey:buttonKey];
        [cell layoutIfNeeded];
        XCTAssertEqualObjects([button titleForState:UIControlStateNormal], fixture.sections[indexPath.section][indexPath.item]);
        XCTAssertEqualWithAccuracy(CGRectGetWidth(button.frame), CGRectGetWidth(cell.contentView.bounds), 0.1);
        XCTAssertEqualWithAccuracy(CGRectGetHeight(button.frame), CGRectGetHeight(cell.contentView.bounds), 0.1);
    }
}

- (void)scrollAndCheck:(UICollectionView *)collectionView fixture:(CYLLayoutFixture *)fixture buttonKey:(NSString *)buttonKey {
    CGFloat maxY = MAX(0, collectionView.contentSize.height - CGRectGetHeight(collectionView.bounds));
    for (CGFloat y = 0; y <= maxY; y += 180) {
        [collectionView setContentOffset:CGPointMake(0, y) animated:NO];
        [collectionView layoutIfNeeded];
        [self assertVisibleCells:collectionView fixture:fixture buttonKey:buttonKey];
        [self assertNoOverlaps:collectionView fixture:fixture];
    }
    [collectionView setContentOffset:CGPointZero animated:NO];
    [collectionView layoutIfNeeded];
    [self assertVisibleCells:collectionView fixture:fixture buttonKey:buttonKey];
}

- (void)testLongEmojiTitlesRemainSeparatedAfterReloadAndScrolling {
    CYLLayoutFixture *fixture = [[CYLLayoutFixture alloc] init];
    fixture.sections = [self longEmojiSections];
    XCTAssertGreaterThan(fixture.sections.count, 1u);
    CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 240) collectionViewLayout:layout];
    collectionView.dataSource = fixture;
    collectionView.delegate = fixture;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIViewController *controller = [[UIViewController alloc] init];
    window.rootViewController = controller;
    [controller.view addSubview:collectionView];
    [window makeKeyAndVisible];

    for (NSNumber *width in @[@320, @390, @320]) {
        collectionView.frame = CGRectMake(0, 0, width.doubleValue, 240);
        [layout invalidateLayout];
        [collectionView reloadData];
        [collectionView layoutIfNeeded];
        [self assertNoOverlaps:collectionView fixture:fixture];
        CGFloat maxY = MAX(0, collectionView.contentSize.height - CGRectGetHeight(collectionView.bounds));
        for (CGFloat y = 0; y <= maxY; y += 180) {
            [collectionView setContentOffset:CGPointMake(0, y) animated:NO];
            [collectionView layoutIfNeeded];
            [self assertNoOverlaps:collectionView fixture:fixture];
        }
        [collectionView setContentOffset:CGPointZero animated:NO];
        [collectionView layoutIfNeeded];
        [self assertNoOverlaps:collectionView fixture:fixture];
    }
    window.hidden = YES;
}

- (void)testRealMenuControllersWithLongEmojiData {
    NSArray *source = CYLTestDataSource();
    XCTAssertGreaterThan(source.count, 0u);
    NSMutableArray *menuData = [NSMutableArray array];
    NSMutableArray *menuTitles = [NSMutableArray array];
    NSMutableArray *expanded = [NSMutableArray array];
    for (NSDictionary *original in source) {
        NSMutableDictionary *section = [original mutableCopy];
        NSMutableArray *items = [NSMutableArray array];
        NSMutableArray *titles = [NSMutableArray array];
        for (NSDictionary *originalItem in original[CYLMenuKeys.dataSourceSectionKey]) {
            NSMutableDictionary *item = [originalItem mutableCopy];
            NSString *title = [item[CYLMenuKeys.dataSourceCellTextKey] stringByAppendingString:@" 🧑‍🍳✨ 更长的测试标签"];
            item[CYLMenuKeys.dataSourceCellTextKey] = title;
            [items addObject:item];
            [titles addObject:title];
        }
        section[CYLMenuKeys.dataSourceSectionKey] = items;
        [menuData addObject:section];
        [menuTitles addObject:titles];
        [expanded addObject:@(expanded.count)];
    }

    CYLTestMenuSource *menuSource = [[CYLTestMenuSource alloc] init];
    menuSource.sections = menuTitles;
    UIViewController *menu = [[NSClassFromString(@"CYLClassifyMenuViewController") alloc] init];
    [menu setValue:menuSource forKey:@"menuDataSource"];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = menu;
    [window makeKeyAndVisible];
    [menu loadViewIfNeeded];
    [menu setValue:menuData forKey:@"dataSource"];
    [menu setValue:expanded forKey:@"expandSectionArray"];
    UICollectionView *menuCollection = [menu valueForKey:@"collectionView"];
    menuCollection.frame = CGRectMake(0, 0, 320, 240);
    [menuCollection reloadData];
    [menuCollection layoutIfNeeded];
    CYLLayoutFixture *fixture = [[CYLLayoutFixture alloc] init];
    fixture.sections = menuTitles;
    [self assertNoOverlaps:menuCollection fixture:fixture];
    [self scrollAndCheck:menuCollection fixture:fixture buttonKey:@"button"];

    // The demo app's header at this width: testDemoHeaderFitsANarrowScreen (CYLClassifyMenuDemoTests.swift).

    NSMutableArray *filterTitles = [NSMutableArray array];
    NSArray *filterSections = @[@[@"全部", @"北京"], [@[@"全部"] arrayByAddingObjectsFromArray:CYLTestAllTags()]];
    for (NSArray *original in filterSections) {
        NSMutableArray *titles = [NSMutableArray array];
        for (NSString *title in original) {
            [titles addObject:[title stringByAppendingString:@" 🧑‍💻🍜 长筛选文字"]];
        }
        [filterTitles addObject:titles];
    }
    CYLTestMenuSource *filterSource = [[CYLTestMenuSource alloc] init];
    filterSource.sections = filterTitles;
    CYLMultipleFilterController *filterController = [[CYLMultipleFilterController alloc] init];
    filterController.menuDataSource = filterSource;
    [filterController loadViewIfNeeded];
    CYLFilterParamsTool *filter = [filterController valueForKey:@"filterParamsTool"];
    window.rootViewController = filterController;
    UICollectionView *filterCollection = [filterController valueForKey:@"collectionView"];
    filterCollection.frame = CGRectMake(0, 0, 320, 240);
    [filterCollection reloadData];
    [filterCollection layoutIfNeeded];
    fixture.sections = filterTitles;
    [self assertNoOverlaps:filterCollection fixture:fixture];
    [self scrollAndCheck:filterCollection fixture:fixture buttonKey:@"titleButton"];
    NSIndexPath *selection = [NSIndexPath indexPathForItem:1 inSection:1];
    [filterCollection scrollToItemAtIndexPath:selection atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    [filterCollection layoutIfNeeded];
    XCTAssertNotNil([filterCollection cellForItemAtIndexPath:selection]);
    [filterCollection.delegate collectionView:filterCollection didSelectItemAtIndexPath:selection];
    XCTAssertTrue([filter.filterParamsArray[1][1] boolValue]);
    [self scrollAndCheck:filterCollection fixture:fixture buttonKey:@"titleButton"];
    [filterCollection scrollToItemAtIndexPath:selection atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    [filterCollection layoutIfNeeded];
    UIButton *selectedButton = [[filterCollection cellForItemAtIndexPath:selection] valueForKey:@"titleButton"];
    XCTAssertNotNil(selectedButton);
    XCTAssertTrue(selectedButton.selected);
    window.hidden = YES;
}

- (void)testCollapsedRowsMatchMeasuredLongEmojiItems {
    NSArray *source = CYLTestDataSource();
    XCTAssertGreaterThan(source.count, 0u);
    NSMutableArray *menuData = [NSMutableArray array];
    for (NSDictionary *original in source) {
        NSMutableDictionary *section = [original mutableCopy];
        NSMutableArray *items = [NSMutableArray array];
        for (NSDictionary *originalItem in original[CYLMenuKeys.dataSourceSectionKey]) {
            NSMutableDictionary *item = [originalItem mutableCopy];
            item[CYLMenuKeys.dataSourceCellTextKey] = [item[CYLMenuKeys.dataSourceCellTextKey] stringByAppendingString:@" 🍜✨ 较长的标签"];
            [items addObject:item];
        }
        section[CYLMenuKeys.dataSourceSectionKey] = items;
        [menuData addObject:section];
    }
    UIViewController *menu = [[NSClassFromString(@"CYLClassifyMenuViewController") alloc] init];
    [menu loadViewIfNeeded];
    [menu setValue:menuData forKey:@"dataSource"];
    [menu setValue:nil forKey:@"firstRowCellCountArray"];
    [menu setValue:nil forKey:@"collectionHeaderMoreBtnHideBoolArray"];
    [menu setValue:nil forKey:@"rowsCountPerSection"];
    [menu setValue:nil forKey:@"cellsCountArrayPerRowInSections"];
    UICollectionView *collectionView = [menu valueForKey:@"collectionView"];
    collectionView.frame = CGRectMake(0, 0, 320, 240);
    [menu cyl_judgeMoreButtonShowWhenDefaultRowsCount:1];

    NSArray *actual = [menu valueForKey:@"firstRowCellCountArray"];
    id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)collectionView.delegate;
    for (NSInteger section = 0; section < menuData.count; section++) {
        CGFloat used = 0;
        NSUInteger expected = 0;
        NSArray *items = menuData[section][CYLMenuKeys.dataSourceSectionKey];
        for (NSInteger item = 0; item < items.count; item++) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:item inSection:section];
            CGFloat width = [delegate collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:path].width;
            CGFloat next = used + (expected ? 12 : 0) + width;
            if (expected && next > 320 - 32) break;
            used = next;
            expected++;
        }
        XCTAssertEqual([actual[section] unsignedIntegerValue], expected, @"Wrong collapsed count in section %ld", (long)section);
    }
}

- (void)testLargeTagSetDoesNotRecursivelyRecomputePreviousItems {
    NSArray *source = [self longEmojiSections];
    NSArray *original = source.firstObject;
    XCTAssertGreaterThan(original.count, 0u);
    if (original.count == 0) return;
    NSMutableArray *titles = [NSMutableArray array];
    for (NSUInteger index = 0; index < 1200; index++) {
        [titles addObject:original[index % original.count]];
    }
    CYLLayoutFixture *fixture = [[CYLLayoutFixture alloc] init];
    fixture.sections = @[titles];
    CYLCountingLayout *layout = [[CYLCountingLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 240) collectionViewLayout:layout];
    collectionView.dataSource = fixture;
    collectionView.delegate = fixture;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [collectionView reloadData];
    [collectionView layoutIfNeeded];
    layout.itemLookups = 0;
    for (NSUInteger index = 0; index < titles.count; index++) {
        XCTAssertNotNil([layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]]);
    }
    XCTAssertEqual(layout.itemLookups, titles.count);
    [self assertNoOverlaps:collectionView fixture:fixture];
}

- (void)testUnmeasuredMenuWidthNeverProducesNegativeItemSize {
    CYLTestMenuSource *source = [[CYLTestMenuSource alloc] init];
    source.sections = @[@[@"测试长文字😀"]];
    UIViewController *menu = [[NSClassFromString(@"CYLClassifyMenuViewController") alloc] init];
    [menu setValue:source forKey:@"menuDataSource"];
    [menu loadViewIfNeeded];
    UICollectionView *collectionView = [menu valueForKey:@"collectionView"];
    collectionView.frame = CGRectMake(0, 0, 0, 240);
    id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)collectionView.delegate;
    CGSize size = [delegate collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertGreaterThanOrEqual(size.width, 0);
}

- (void)testExternalSourceSelectionAndResources {
    CYLTestMenuSource *source = [[CYLTestMenuSource alloc] init];
    source.sections = @[@[@"All", @"Long external item 😀"], @[@"All", @"Other 🍜"]];
    CYLMultipleFilterController *controller = [[CYLMultipleFilterController alloc] init];
    controller.menuDataSource = source;
    controller.menuDelegate = source;
    [controller loadViewIfNeeded];
    UICollectionView *collection = controller.collectionView;
    NSIndexPath *item = [NSIndexPath indexPathForItem:1 inSection:0];
    [collection.delegate collectionView:collection didSelectItemAtIndexPath:item];
    XCTAssertEqualObjects(source.lastSelection, item);
    XCTAssertTrue([controller.selectedIndexPaths containsObject:item]);
    XCTAssertFalse([controller.selectedIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    [controller confirmButtonClicked:nil];
    XCTAssertEqualObjects(source.confirmed, controller.selectedIndexPaths);
    [controller setSelectedIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:1]]];
    XCTAssertEqualObjects(controller.selectedIndexPaths, (@[[NSIndexPath indexPathForItem:1 inSection:1]]));
    XCTAssertThrowsSpecificNamed(([controller setSelectedIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0],
                                                                      [NSIndexPath indexPathForItem:1 inSection:0]]]),
                                 NSException, NSInvalidArgumentException);
    XCTAssertNotNil([CYLMenuResources imageNamed:@"home_btn_more_normal"]);
    source.sections = @[@[@"New source 🌟"]];
    [controller reloadMenuData];
    XCTAssertEqual([collection numberOfSections], 1);
    XCTAssertEqual([collection numberOfItemsInSection:0], 1);
}

- (void)testCoreLookupsReadTheCoreBundle {
    NSString *saved = CYLMenuResources.preferredLanguage;
    CYLMenuResources.preferredLanguage = @"en";
    // Two lookups, two bundles: the core's and the demo app's.
    XCTAssertEqualObjects(CYLMenuLocalizedString(@"CYLMenuNewTag", nil), @"New Tag");
    XCTAssertEqualObjects(CYLMenuLocalizedStringForKey(@"CYLMenuNewTag"), @"New Tag");
    XCTAssertEqualObjects(CYLMenuLocalizedString(@"重置筛选条件", nil), @"重置筛选条件", @"Demo strings are not in the core bundle");
    XCTAssertNotNil(CYLMenuImage(@"cyl_tag_plus"));
    // The demo app's lookup over its own bundle: testDemoLookupReadsItsOwnBundle (CYLClassifyMenuDemoTests.swift).
    CYLMenuResources.preferredLanguage = saved;
}

- (void)testTagListViewsHaveStableAccessibilityIdentifiers {
    CYLTestMenuSource *source = [[CYLTestMenuSource alloc] init];
    source.sections = @[@[@"All", @"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine"]];
    CYLMenuFoldControl *fold = [CYLMenuFoldControl foldControlWithPosition:CYLMenuFoldControlPositionBottom
                                                               content:CYLMenuFoldControlContentIcon];
    CYLTagListView *list = [[CYLTagListView alloc] initWithFoldControl:fold];
    list.frame = CGRectMake(0, 0, 200, 400);
    list.title = @"Tags";
    list.defaultVisibleRows = 1;
    list.menuDataSource = source;
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 200, 400)];
    [window addSubview:list];
    [list reloadMenuData];
    [list layoutIfNeeded];
    XCTAssertEqualObjects(list.titleView.accessibilityIdentifier, @"CYLTagListTitle");
    XCTAssertTrue(list.titleView.isAccessibilityElement);
    XCTAssertTrue(list.titleView.accessibilityTraits & UIAccessibilityTraitHeader);
    NSMutableArray<UIView *> *stack = [NSMutableArray arrayWithObject:list];
    NSMutableArray<UIView *> *items = [NSMutableArray array];
    UIView *foldControl = nil;
    while (stack.count > 0) {
        UIView *view = stack.lastObject;
        [stack removeLastObject];
        if ([view.accessibilityIdentifier isEqualToString:CYLTagListItemAccessibilityIdentifier]) {
            [items addObject:view];
        } else if ([view.accessibilityIdentifier isEqualToString:CYLTagListFoldControlAccessibilityIdentifier] && !view.hidden) {
            foldControl = view;
        }
        [stack addObjectsFromArray:view.subviews];
    }
    XCTAssertTrue(items.count > 0);
    XCTAssertTrue([[items valueForKey:@"accessibilityLabel"] containsObject:@"One"], @"Tags are found by their label");
    XCTAssertNotNil(foldControl, @"The fold control is found by its identifier");
    XCTAssertTrue(foldControl.accessibilityLabel.length > 0);
    XCTAssertTrue(foldControl.accessibilityTraits & UIAccessibilityTraitButton);
}

- (void)testSectionHeaderFitsItsActualWidth {
    CYLFilterHeaderView *header = [[CYLFilterHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 38)];
    for (NSNumber *width in @[@320, @240, @390]) {
        header.frame = CGRectMake(0, 0, width.doubleValue, 38);
        [header setNeedsLayout];
        [header layoutIfNeeded];
        XCTAssertLessThanOrEqual(CGRectGetMaxX(header.moreButton.frame), width.doubleValue);
        XCTAssertLessThanOrEqual(CGRectGetMaxX(header.titleButton.frame), CGRectGetMinX(header.moreButton.frame));
    }
}

- (void)testButtonsPlaceImageAndTitleWithoutDeprecatedInsets {
    CYLIndexPathButton *button = [CYLIndexPathButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 120, 30);
    [button setImage:[CYLMenuResources imageNamed:@"home_btn_shrink"] forState:UIControlStateNormal];
    [button setTitle:@"Item 🌟" forState:UIControlStateNormal];
    [button layoutIfNeeded];
    CGRect plainImage = button.imageView.frame;
    CGRect plainTitle = button.titleLabel.frame;
    button.cyl_imageTitleSpacing = 5;
    [button layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetMinX(button.imageView.frame), CGRectGetMinX(plainImage) - 2.5, 0.5);
    XCTAssertEqualWithAccuracy(CGRectGetMinX(button.titleLabel.frame), CGRectGetMinX(plainTitle) + 2.5, 0.5);
    XCTAssertLessThanOrEqual(CGRectGetMaxX(button.titleLabel.frame), CGRectGetWidth(button.bounds));

    CYLFilterHeaderView *header = [[CYLFilterHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 38)];
    header.moreButton.hidden = NO;
    [header.titleButton setTitle:@"Section" forState:UIControlStateNormal];
    [header layoutIfNeeded];
    [header.titleButton layoutIfNeeded];
    [header.moreButton layoutIfNeeded];
    CGRect moreTitle = header.moreButton.titleLabel.frame;
    CGRect moreImage = header.moreButton.imageView.frame;
    XCTAssertGreaterThan(CGRectGetWidth(moreTitle), 0);
    XCTAssertLessThanOrEqual(CGRectGetMaxX(moreTitle), CGRectGetMinX(moreImage));
    XCTAssertLessThanOrEqual(CGRectGetMaxX(moreImage), CGRectGetWidth(header.moreButton.bounds) + 0.5);
    XCTAssertEqualWithAccuracy(CGRectGetMinX(header.titleButton.titleLabel.frame),
                               header.titleButton.cyl_titleLeadingInset, 0.5);
}

- (UIViewController *)cyl_hostChild:(UIViewController *)child
                              width:(CGFloat)width
                             traits:(UITraitCollection *)traits
                             window:(UIWindow **)outWindow {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, width, 600)];
    UIViewController *parent = [[UIViewController alloc] init];
    window.rootViewController = parent;
    [window makeKeyAndVisible];
    [parent addChildViewController:child];
    child.view.frame = parent.view.bounds;
    child.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [parent.view addSubview:child.view];
    [child didMoveToParentViewController:parent];
    [parent setOverrideTraitCollection:traits forChildViewController:child];
    [child.view setNeedsLayout];
    [child.view layoutIfNeeded];
    *outWindow = window;
    return parent;
}

- (void)testAccessibilityTextSizesScaleTagsWithoutOverlapOrOverflow {
    UIContentSizeCategory category = UIContentSizeCategoryAccessibilityExtraExtraExtraLarge;
    UITraitCollection *large = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:category];
    UITraitCollection *standard = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryLarge];
    UIFont *standardFont = CYLTagTitleFontForTraitCollection(standard);
    UIFont *largeFont = CYLTagTitleFontForTraitCollection(large);
    XCTAssertEqualWithAccuracy(standardFont.pointSize, CYLTagTitleFontSize, 0.01);
    XCTAssertGreaterThan(largeFont.pointSize, standardFont.pointSize);
    XCTAssertLessThanOrEqual(largeFont.pointSize, CYLTagTitleFontSize * CYLMaximumFontScale + 0.01);
    XCTAssertGreaterThan(CYLTagHeightForFont(largeFont, 30), 30);

    CYLTestMenuSource *source = [[CYLTestMenuSource alloc] init];
    source.sections = [self longEmojiSections];
    CYLLayoutFixture *fixture = [[CYLLayoutFixture alloc] init];
    fixture.sections = source.sections;
    for (NSNumber *width in @[@320, @240]) {
        CYLClassifyMenuViewController *menu = [[CYLClassifyMenuViewController alloc] init];
        menu.menuDataSource = source;
        menu.defaultVisibleRows = 1000;  // Show every row so all items are laid out.
        UIWindow *window = nil;
        [self cyl_hostChild:menu width:width.doubleValue traits:large window:&window];
        UICollectionView *collection = [menu valueForKey:@"collectionView"];
        XCTAssertEqualObjects(collection.traitCollection.preferredContentSizeCategory, category);
        [collection layoutIfNeeded];
        [self assertNoOverlaps:collection fixture:fixture];
        UICollectionViewLayoutAttributes *first =
            [collection.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        XCTAssertEqualWithAccuracy(CGRectGetHeight(first.frame), CYLTagHeightForFont(largeFont, 30), 0.5);
        // Give the collection a fixed viewport, as the other controller tests do,
        // so scrolling exercises cell reuse.
        collection.frame = CGRectMake(0, 0, width.doubleValue, 240);
        [collection layoutIfNeeded];
        [self scrollAndCheck:collection fixture:fixture buttonKey:@"button"];
        XCTAssertGreaterThan(collection.visibleCells.count, 0u);
        for (UICollectionViewCell *cell in collection.visibleCells) {
            UIButton *button = [cell valueForKey:@"button"];
            XCTAssertEqualWithAccuracy(button.titleLabel.font.pointSize, largeFont.pointSize, 0.01);
        }
        for (UICollectionReusableView *view in [collection visibleSupplementaryViewsOfKind:UICollectionElementKindSectionHeader]) {
            CYLFilterHeaderView *header = (CYLFilterHeaderView *)view;
            XCTAssertLessThanOrEqual(CGRectGetMaxX(header.moreButton.frame), CGRectGetWidth(header.bounds) + 0.5);
        }
        window.hidden = YES;
    }

    NSMutableArray *filterTitles = [NSMutableArray array];
    for (NSArray *section in @[@[@"全部", @"北京"], [@[@"全部"] arrayByAddingObjectsFromArray:CYLTestAllTags()]]) {
        NSMutableArray *titles = [NSMutableArray array];
        for (NSString *title in section) {
            [titles addObject:[title stringByAppendingString:@" 🧑‍💻🍜 长筛选文字"]];
        }
        [filterTitles addObject:titles];
    }
    CYLTestMenuSource *filterSource = [[CYLTestMenuSource alloc] init];
    filterSource.sections = filterTitles;
    fixture.sections = filterTitles;
    for (NSNumber *width in @[@320, @240]) {
        CYLMultipleFilterController *filter = [[CYLMultipleFilterController alloc] init];
        filter.menuDataSource = filterSource;
        UIWindow *window = nil;
        [self cyl_hostChild:filter width:width.doubleValue traits:large window:&window];
        UICollectionView *collection = filter.collectionView;
        CGFloat panelWidth = CGRectGetWidth(collection.bounds);
        XCTAssertLessThan(panelWidth, width.doubleValue);
        XCTAssertEqualWithAccuracy(CGRectGetMinX(filter.restoreButton.frame), 0, 0.5);
        XCTAssertEqualWithAccuracy(CGRectGetMaxX(filter.okButton.frame), panelWidth, 0.5);
        XCTAssertEqualWithAccuracy(CGRectGetMaxX(filter.restoreButton.frame), CGRectGetMinX(filter.okButton.frame), 0.5);
        XCTAssertEqualWithAccuracy(CGRectGetMaxY(filter.okButton.frame), CGRectGetHeight(filter.view.bounds), 0.5);
        [collection reloadData];
        [collection layoutIfNeeded];
        [self assertNoOverlaps:collection fixture:fixture];
        UICollectionViewLayoutAttributes *first =
            [collection.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        XCTAssertEqualWithAccuracy(CGRectGetHeight(first.frame), CYLTagHeightForFont(largeFont, 30), 0.5);
        collection.frame = CGRectMake(0, 0, panelWidth, 240);
        [collection layoutIfNeeded];
        [self scrollAndCheck:collection fixture:fixture buttonKey:@"titleButton"];
        for (UICollectionViewCell *cell in collection.visibleCells) {
            // VoiceOver: the filter cell is the element, labelled with its title.
            UIButton *button = [cell valueForKey:@"titleButton"];
            XCTAssertTrue(cell.isAccessibilityElement);
            XCTAssertEqualObjects(cell.accessibilityLabel, [button titleForState:UIControlStateNormal]);
            XCTAssertEqual((BOOL)(cell.accessibilityTraits & UIAccessibilityTraitSelected), button.selected);
        }
        [collection setContentOffset:CGPointMake(0, -collection.contentInset.top) animated:NO];
        [collection layoutIfNeeded];
        NSArray *headers = [collection visibleSupplementaryViewsOfKind:UICollectionElementKindSectionHeader];
        XCTAssertGreaterThan(headers.count, 0u);
        for (CYLMultipleFilterHeaderView *header in headers) {
            [header layoutIfNeeded];
            XCTAssertLessThanOrEqual(CGRectGetMaxX(header.titleLabel.frame), CGRectGetWidth(header.bounds) + 0.5);
        }
        window.hidden = YES;
    }
}

- (void)testMenuRemeasuresWhenTextSizeChanges {
    CYLTestMenuSource *source = [[CYLTestMenuSource alloc] init];
    source.sections = [self longEmojiSections];
    CYLClassifyMenuViewController *menu = [[CYLClassifyMenuViewController alloc] init];
    menu.menuDataSource = source;
    UITraitCollection *standard = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryLarge];
    UIWindow *window = nil;
    UIViewController *parent = [self cyl_hostChild:menu width:320 traits:standard window:&window];
    UICollectionView *collection = [menu valueForKey:@"collectionView"];
    NSInteger standardCount = [collection numberOfItemsInSection:0];
    CGFloat standardHeight = CGRectGetHeight([collection.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].frame);

    UITraitCollection *large = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];
    [parent setOverrideTraitCollection:large forChildViewController:menu];
    [menu.view setNeedsLayout];
    [menu.view layoutIfNeeded];
    [collection layoutIfNeeded];
    CGFloat largeHeight = CGRectGetHeight([collection.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].frame);
    XCTAssertGreaterThan(largeHeight, standardHeight);
    // Larger text fits fewer tags on the first row, so the collapsed count is re-measured.
    XCTAssertLessThanOrEqual([collection numberOfItemsInSection:0], standardCount);
    window.hidden = YES;
}

@end
