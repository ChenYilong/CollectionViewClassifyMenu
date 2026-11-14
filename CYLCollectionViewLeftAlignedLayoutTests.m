#import <XCTest/XCTest.h>
@import CollectionViewClassifyMenu;

// The upstream pull requests and issues of mokagio/UICollectionViewLeftAlignedLayout, one test each (or per group).
// Rows and scores: docs/CYLCollectionViewLeftAlignedLayout.md.

/// A collection view source of item sizes, with optional headers and footers.
@interface CYLLeftAlignedFixture : NSObject <UICollectionViewDataSource, UICollectionViewDelegateLeftAlignedLayout>
@property (nonatomic, copy) NSArray<NSArray<NSValue *> *> *sizes;
@property (nonatomic, assign) UIEdgeInsets inset;
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) CGSize headerSize;
@property (nonatomic, assign) CGSize footerSize;
@property (nonatomic, assign) BOOL usesDelegateSizes;
@end

@implementation CYLLeftAlignedFixture
- (instancetype)init {
    self = [super init];
    if (self) {
        _inset = UIEdgeInsetsMake(10, 16, 10, 16);
        _spacing = 8;
        _usesDelegateSizes = YES;
    }
    return self;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView { return self.sizes.count; }
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { return self.sizes[section].count; }
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kind forIndexPath:indexPath];
}
- (BOOL)respondsToSelector:(SEL)selector {
    if (selector == @selector(collectionView:layout:sizeForItemAtIndexPath:)) return self.usesDelegateSizes;
    return [super respondsToSelector:selector];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.sizes[indexPath.section][indexPath.item].CGSizeValue;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout insetForSectionAtIndex:(NSInteger)section {
    return self.inset;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.spacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.spacing;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout referenceSizeForHeaderInSection:(NSInteger)section {
    return self.headerSize;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout referenceSizeForFooterInSection:(NSInteger)section {
    return self.footerSize;
}
@end

/// A self-sizing cell (issues #13, #17, #18): its width depends only on its item, so the layout settles.
@interface CYLSelfSizingCell : UICollectionViewCell
@end

@implementation CYLSelfSizingCell
- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    UICollectionViewLayoutAttributes *attributes = [layoutAttributes copy];
    attributes.size = CGSizeMake(40 + (layoutAttributes.indexPath.item % 5) * 23, 32);
    return attributes;
}
@end

@interface CYLCollectionViewLeftAlignedLayoutTests : XCTestCase
@property (nonatomic, strong) UIWindow *window;
@end

@implementation CYLCollectionViewLeftAlignedLayoutTests

- (void)tearDown {
    self.window.hidden = YES;
    self.window = nil;
    [super tearDown];
}

- (UICollectionView *)collectionViewWithLayout:(UICollectionViewFlowLayout *)layout fixture:(CYLLeftAlignedFixture *)fixture width:(CGFloat)width {
    return [self collectionViewWithLayout:layout fixture:fixture width:width cellClass:[UICollectionViewCell class]];
}

- (UICollectionView *)collectionViewWithLayout:(UICollectionViewFlowLayout *)layout fixture:(CYLLeftAlignedFixture *)fixture width:(CGFloat)width cellClass:(Class)cellClass {
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, width, 480) collectionViewLayout:layout];
    collectionView.dataSource = fixture;
    collectionView.delegate = fixture;
    [collectionView registerClass:cellClass forCellWithReuseIdentifier:@"cell"];
    for (NSString *kind in @[UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter]) {
        [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:kind];
    }
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, MAX(width, 320), 480)];
    UIViewController *controller = [[UIViewController alloc] init];
    self.window.rootViewController = controller;
    [controller.view addSubview:collectionView];
    [self.window makeKeyAndVisible];
    [collectionView reloadData];
    [collectionView layoutIfNeeded];
    return collectionView;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)cellAttributesIn:(UICollectionView *)collectionView {
    UICollectionViewLayout *layout = collectionView.collectionViewLayout;
    CGRect all = CGRectMake(0, 0, MAX(layout.collectionViewContentSize.width, 1), MAX(layout.collectionViewContentSize.height, 1));
    NSMutableArray *cells = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attributes in [layout layoutAttributesForElementsInRect:all]) {
        if (attributes.representedElementCategory == UICollectionElementCategoryCell) [cells addObject:attributes];
    }
    return cells;
}

/// No two cells overlap, every cell is inside the section insets, and the first cell of each row is at the leading inset.
- (void)assertLeftAligned:(UICollectionView *)collectionView fixture:(CYLLeftAlignedFixture *)fixture {
    NSArray<UICollectionViewLayoutAttributes *> *cells = [self cellAttributesIn:collectionView];
    XCTAssertGreaterThan(cells.count, 0u);
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    for (UICollectionViewLayoutAttributes *a in cells) {
        XCTAssertGreaterThanOrEqual(CGRectGetMinX(a.frame), fixture.inset.left - 0.01, @"%@ before the leading inset", a.indexPath);
        XCTAssertLessThanOrEqual(CGRectGetMaxX(a.frame), width - fixture.inset.right + 0.01, @"%@ past the trailing inset", a.indexPath);
        for (UICollectionViewLayoutAttributes *b in cells) {
            if (a == b) continue;
            XCTAssertFalse(CGRectIntersectsRect(CGRectInset(a.frame, 0.01, 0.01), CGRectInset(b.frame, 0.01, 0.01)),
                           @"%@ overlaps %@", a.indexPath, b.indexPath);
        }
    }
    NSArray *sorted = [cells sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewLayoutAttributes *a, UICollectionViewLayoutAttributes *b) {
        return [a.indexPath compare:b.indexPath];
    }];
    UICollectionViewLayoutAttributes *previous = nil;
    for (UICollectionViewLayoutAttributes *a in sorted) {
        BOOL sameRow = previous && previous.indexPath.section == a.indexPath.section &&
                       fabs(CGRectGetMidY(previous.frame) - CGRectGetMidY(a.frame)) < 1;
        if (sameRow) {
            XCTAssertEqualWithAccuracy(CGRectGetMinX(a.frame), CGRectGetMaxX(previous.frame) + fixture.spacing, 0.01, @"%@", a.indexPath);
        } else {
            XCTAssertEqualWithAccuracy(CGRectGetMinX(a.frame), fixture.inset.left, 0.01, @"%@ starts a row", a.indexPath);
        }
        previous = a;
    }
}

static NSArray<NSValue *> *CYLSizes(NSUInteger count, CGSize (^size)(NSUInteger index)) {
    NSMutableArray *sizes = [NSMutableArray array];
    for (NSUInteger index = 0; index < count; index++) [sizes addObject:[NSValue valueWithCGSize:size(index)]];
    return sizes;
}

#pragma mark PR #37, issues #7 and #30: horizontal scrolling

- (void)testHorizontalScrollingKeepsTheFlowLayoutFrames {
    CYLLeftAlignedFixture *fixture = [[CYLLeftAlignedFixture alloc] init];
    fixture.sizes = @[CYLSizes(30, ^CGSize(NSUInteger i) { return CGSizeMake(60 + (i % 3) * 20, 40); })];
    CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [self collectionViewWithLayout:layout fixture:fixture width:320];
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *reference = [[UICollectionView alloc] initWithFrame:collectionView.frame collectionViewLayout:flow];
    reference.dataSource = fixture;
    reference.delegate = fixture;
    [reference registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.window.rootViewController.view addSubview:reference];
    [reference layoutIfNeeded];
    NSUInteger atZero = 0;
    for (NSInteger item = 0; item < 30; item++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CGRect frame = [layout layoutAttributesForItemAtIndexPath:indexPath].frame;
        XCTAssertTrue(CGRectEqualToRect(frame, [flow layoutAttributesForItemAtIndexPath:indexPath].frame), @"item %ld", (long)item);
        if (CGRectGetMinX(frame) == 0) atZero++;
    }
    XCTAssertEqual(atZero, 0u, @"x became 0 (issue #30)");
    NSArray *cells = [self cellAttributesIn:collectionView];
    for (UICollectionViewLayoutAttributes *a in cells) {
        for (UICollectionViewLayoutAttributes *b in cells) {
            if (a != b) XCTAssertFalse(CGRectIntersectsRect(a.frame, b.frame), @"cells overlap (issue #7)");
        }
    }
}

#pragma mark PR #31, #20, issues #26, #27, #33: full-width cells, fractional origins, trailing inset

- (void)testFullWidthCellsWithFractionalHeightsStartTheirOwnRows {
    CYLLeftAlignedFixture *fixture = [[CYLLeftAlignedFixture alloc] init];
    fixture.spacing = 0.333333;
    fixture.sizes = @[CYLSizes(12, ^CGSize(NSUInteger i) { return CGSizeMake(320 - 32, 33.333333 + (i % 2) * 0.333333); })];
    UICollectionView *collectionView = [self collectionViewWithLayout:[[CYLCollectionViewLeftAlignedLayout alloc] init] fixture:fixture width:320];
    [self assertLeftAligned:collectionView fixture:fixture];
    for (UICollectionViewLayoutAttributes *a in [self cellAttributesIn:collectionView]) {
        XCTAssertEqualWithAccuracy(CGRectGetMinX(a.frame), 16, 0.001, @"item %ld (PR #20, #31)", (long)a.indexPath.item);
    }
}

- (void)testCellsNeverPassTheTrailingInset {
    CYLLeftAlignedFixture *fixture = [[CYLLeftAlignedFixture alloc] init];
    fixture.inset = UIEdgeInsetsMake(10, 10, 10, 10);
    fixture.sizes = @[CYLSizes(25, ^CGSize(NSUInteger i) { return CGSizeMake(i % 7 == 0 ? 300 : 37.7 + (i % 4) * 31.3, 30); })];
    for (NSNumber *width in @[@320, @375, @414]) {
        UICollectionView *collectionView = [self collectionViewWithLayout:[[CYLCollectionViewLeftAlignedLayout alloc] init] fixture:fixture width:width.doubleValue];
        [self assertLeftAligned:collectionView fixture:fixture];
    }
}

#pragma mark PR #25, issues #9, #11, #13, #17, #18: self-sizing cells

- (void)testSelfSizingCellsAppearAndSettle {
    CYLLeftAlignedFixture *fixture = [[CYLLeftAlignedFixture alloc] init];
    fixture.usesDelegateSizes = NO;
    fixture.sizes = @[CYLSizes(40, ^CGSize(NSUInteger i) { return CGSizeZero; })];
    CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
    layout.estimatedItemSize = CGSizeMake(50, 32);
    UICollectionView *collectionView = [self collectionViewWithLayout:layout fixture:fixture width:320 cellClass:[CYLSelfSizingCell class]];
    for (NSUInteger pass = 0; pass < 3; pass++) {
        [collectionView layoutIfNeeded];
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
    }
    XCTAssertGreaterThan(collectionView.visibleCells.count, 0u, @"no cells shown (issue #18)");
    XCTAssertGreaterThan(layout.collectionViewContentSize.height, 0, @"content size (issue #11)");
    for (UICollectionViewCell *cell in collectionView.visibleCells) {
        NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
        XCTAssertEqualWithAccuracy(CGRectGetWidth(cell.frame), 40 + (indexPath.item % 5) * 23, 0.5, @"self-sized width (issue #13)");
    }
    [self assertLeftAligned:collectionView fixture:fixture];
}

#pragma mark Issues #16, #22, #32: headers and footers

- (void)testHeadersAndFootersKeepTheFlowLayoutFrames {
    CYLLeftAlignedFixture *fixture = [[CYLLeftAlignedFixture alloc] init];
    fixture.headerSize = CGSizeMake(0, 36);
    fixture.footerSize = CGSizeMake(0, 20);
    fixture.sizes = @[CYLSizes(9, ^CGSize(NSUInteger i) { return CGSizeMake(70 + i * 9, 30); }),
                      CYLSizes(1, ^CGSize(NSUInteger i) { return CGSizeMake(90, 30); }),
                      CYLSizes(5, ^CGSize(NSUInteger i) { return CGSizeMake(120, 44); })];
    CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
    UICollectionView *collectionView = [self collectionViewWithLayout:layout fixture:fixture width:320];
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *reference = [[UICollectionView alloc] initWithFrame:collectionView.frame collectionViewLayout:flow];
    reference.dataSource = fixture;
    reference.delegate = fixture;
    [reference registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    for (NSString *kind in @[UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter]) {
        [reference registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:kind];
    }
    [self.window.rootViewController.view addSubview:reference];
    [reference layoutIfNeeded];
    for (NSInteger section = 0; section < 3; section++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        for (NSString *kind in @[UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter]) {
            CGRect frame = [layout layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath].frame;
            XCTAssertTrue(CGRectEqualToRect(frame, [flow layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath].frame), @"%@ %ld", kind, (long)section);
            XCTAssertGreaterThan(CGRectGetHeight(frame), 0);
        }
        CGRect header = [layout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath].frame;
        CGRect firstCell = [layout layoutAttributesForItemAtIndexPath:indexPath].frame;
        XCTAssertLessThanOrEqual(CGRectGetMaxY(header), CGRectGetMinY(firstCell), @"header %ld above its cells (issue #32)", (long)section);
    }
    NSUInteger supplementary = 0;
    for (UICollectionViewLayoutAttributes *attributes in [layout layoutAttributesForElementsInRect:CGRectMake(0, 0, 320, layout.collectionViewContentSize.height)]) {
        if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView) supplementary++;
    }
    XCTAssertEqual(supplementary, 6u, @"headers and footers in a rect query (issue #16)");
    [self assertLeftAligned:collectionView fixture:fixture];
}

#pragma mark Issues #10, #29: many items

- (void)testTwoThousandItemsLayOutQuickly {
    CYLLeftAlignedFixture *fixture = [[CYLLeftAlignedFixture alloc] init];
    fixture.sizes = @[CYLSizes(2000, ^CGSize(NSUInteger i) { return CGSizeMake(44 + (i * 37) % 90, 30); })];
    NSDate *start = [NSDate date];
    UICollectionView *collectionView = [self collectionViewWithLayout:[[CYLCollectionViewLeftAlignedLayout alloc] init] fixture:fixture width:375];
    CGFloat maxY = collectionView.contentSize.height - CGRectGetHeight(collectionView.bounds);
    for (CGFloat y = 0; y <= maxY; y += 400) {
        [collectionView setContentOffset:CGPointMake(0, y) animated:NO];
        [collectionView layoutIfNeeded];
    }
    NSTimeInterval elapsed = -start.timeIntervalSinceNow;
    XCTAssertLessThan(elapsed, 10, @"2000 items took %.2f s", elapsed);
    [self assertLeftAligned:collectionView fixture:fixture];
}

#pragma mark Issue #8: width change (rotation)

- (void)testWidthChangeRecomputesEveryFrame {
    CYLLeftAlignedFixture *fixture = [[CYLLeftAlignedFixture alloc] init];
    fixture.sizes = @[CYLSizes(20, ^CGSize(NSUInteger i) { return CGSizeMake(80 + (i % 4) * 15, 30); })];
    CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
    UICollectionView *collectionView = [self collectionViewWithLayout:layout fixture:fixture width:320];
    for (NSNumber *width in @[@568, @320, @414]) {
        XCTAssertTrue([layout shouldInvalidateLayoutForBoundsChange:CGRectMake(0, 0, width.doubleValue, 480)]);
        collectionView.frame = CGRectMake(0, 0, width.doubleValue, 480);
        self.window.frame = CGRectMake(0, 0, MAX(width.doubleValue, 320), 480);
        [collectionView layoutIfNeeded];
        [self assertLeftAligned:collectionView fixture:fixture];
    }
}

#pragma mark Issue #4: attributes are copies

- (void)testReturnedAttributesAreCopies {
    CYLLeftAlignedFixture *fixture = [[CYLLeftAlignedFixture alloc] init];
    fixture.sizes = @[CYLSizes(6, ^CGSize(NSUInteger i) { return CGSizeMake(90, 30); })];
    CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
    [self collectionViewWithLayout:layout fixture:fixture width:320];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
    UICollectionViewLayoutAttributes *first = [layout layoutAttributesForItemAtIndexPath:indexPath];
    CGRect frame = first.frame;
    first.frame = CGRectZero;
    UICollectionViewLayoutAttributes *second = [layout layoutAttributesForItemAtIndexPath:indexPath];
    XCTAssertNotEqual(first, second);
    XCTAssertTrue(CGRectEqualToRect(second.frame, frame), @"a caller's change leaked into the layout (issue #4)");
}

#pragma mark Issue #2: cells of different sizes

- (void)testCellsOfDifferentSizes {
    CYLLeftAlignedFixture *fixture = [[CYLLeftAlignedFixture alloc] init];
    fixture.sizes = @[CYLSizes(30, ^CGSize(NSUInteger i) { return CGSizeMake(30 + (i * 53) % 200, 24 + (i % 3) * 18); })];
    for (NSNumber *alignment in @[@0, @1, @2]) {
        CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
        layout.rowAlignment = (CYLTagRowAlignment)alignment.integerValue;
        UICollectionView *collectionView = [self collectionViewWithLayout:layout fixture:fixture width:375];
        if (alignment.integerValue == 0) {
            [self assertLeftAligned:collectionView fixture:fixture];
        } else {
            for (UICollectionViewLayoutAttributes *a in [self cellAttributesIn:collectionView]) {
                XCTAssertGreaterThanOrEqual(CGRectGetMinX(a.frame), fixture.inset.left - 0.01);
                XCTAssertLessThanOrEqual(CGRectGetMaxX(a.frame), 375 - fixture.inset.right + 0.01);
            }
        }
    }
}

#pragma mark Issue #36: privacy manifest

- (void)testThePodShipsAPrivacyManifest {
    NSURL *bundleURL = [[NSBundle bundleForClass:[CYLCollectionViewLeftAlignedLayout class]] URLForResource:@"CYLClassifyMenuResources" withExtension:@"bundle"];
    XCTAssertNotNil(bundleURL);
    NSURL *manifest = [[NSBundle bundleWithURL:bundleURL] URLForResource:@"PrivacyInfo" withExtension:@"xcprivacy"];
    XCTAssertNotNil(manifest);
    NSDictionary *contents = manifest ? [NSDictionary dictionaryWithContentsOfURL:manifest] : nil;
    XCTAssertEqualObjects(contents[@"NSPrivacyTracking"], @NO);
    XCTAssertEqualObjects(contents[@"NSPrivacyAccessedAPITypes"], @[]);
}

@end
