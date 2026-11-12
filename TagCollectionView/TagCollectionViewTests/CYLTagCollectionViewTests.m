//
//  CYLTagCollectionViewTests.m
//  CYLTagCollectionViewTests
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CYLTagView.h"

@interface CYLCountingTagModel : CYLTagModel
@property (nonatomic, assign) NSUInteger widthReads;
@end

@implementation CYLCountingTagModel
- (float)width {
    self.widthReads++;
    return [super width];
}
@end

@interface CYLTagTestSource : NSObject <CYLMenuDataSource, CYLMenuDelegate>
@property (nonatomic, copy) NSArray<NSString *> *titles;
@property (nonatomic, strong) NSIndexPath *selection;
@end

@implementation CYLTagTestSource
- (NSInteger)numberOfSectionsInMenu { return 1; }
- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section { return self.titles.count; }
- (NSString *)menuTitleForSection:(NSInteger)section { return @"External section"; }
- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath { return self.titles[indexPath.item]; }
- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath { self.selection = indexPath; }
@end

@interface CYLTagCollectionViewTests : XCTestCase

@end

@implementation CYLTagCollectionViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testLongEmojiTagsFitAndCollapsedRowTracksWidth {
    CYLTagView *view = [CYLTagView tagView];
    CYLTagGroup *group = [[CYLTagGroup alloc] init];
    group.itemArr = @[[CYLTagModel modelWithTitle:@"短标签 😀"],
                      [CYLTagModel modelWithTitle:@"稍长的标签 🎉"],
                      [CYLTagModel modelWithTitle:@"一个非常非常非常非常非常非常非常长的标签 🧪🚀"],
                      [CYLTagModel modelWithTitle:@"另一个长标签 🌟"]];
    view.groups = [NSMutableArray arrayWithObject:group];

    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 600)];
    window.rootViewController = [[UIViewController alloc] init];
    [window.rootViewController.view addSubview:view];
    view.frame = CGRectMake(0, 0, 320, 600);
    [window makeKeyAndVisible];
    [view layoutIfNeeded];
    UICollectionView *collection = [view valueForKey:@"collectionView"];
    [collection reloadData];
    [collection layoutIfNeeded];
    XCTAssertEqual([collection numberOfItemsInSection:0], [group firstRowCellCountForContentWidth:288]);
    XCTAssertGreaterThan([collection numberOfItemsInSection:0], 0);

    group.opened = YES;
    [collection reloadData];
    [collection layoutIfNeeded];
    for (CGFloat width = 320; width <= 390; width += 70) {
        view.frame = CGRectMake(0, 0, width, 600);
        [view setNeedsLayout];
        [view layoutIfNeeded];
        [collection layoutIfNeeded];
        NSMutableArray<UICollectionViewLayoutAttributes *> *items = [NSMutableArray array];
        for (NSInteger index = 0; index < group.itemArr.count; index++) {
            UICollectionViewLayoutAttributes *attributes =
                [collection.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            XCTAssertNotNil(attributes);
            XCTAssertLessThanOrEqual(CGRectGetMaxX(attributes.frame), width - kTagCollectionViewToRightMargin + 0.5);
            for (UICollectionViewLayoutAttributes *previous in items) {
                XCTAssertFalse(CGRectIntersectsRect(attributes.frame, previous.frame));
            }
            [items addObject:attributes];
        }
    }

    group.opened = NO;
    [collection reloadData];
    XCTAssertEqual([collection numberOfItemsInSection:0], [group firstRowCellCountForContentWidth:358]);
    XCTAssertEqual([group firstRowCellCountForContentWidth:0], 1);
}

- (void)testRowCalculationIsLinearAndInvalidatedWhenItemsChange {
    CYLCountingTagModel *model = [[CYLCountingTagModel alloc] init];
    model.title = @"长标签 😀";
    NSMutableArray *items = [NSMutableArray array];
    for (NSUInteger i = 0; i < 1200; i++) {
        [items addObject:model];
    }
    CYLTagGroup *group = [[CYLTagGroup alloc] init];
    group.itemArr = items;
    model.widthReads = 0;
    NSArray *rows = group.cellsCountArrayPerRowInSections;
    NSUInteger total = 0;
    for (NSNumber *count in rows) {
        total += count.unsignedIntegerValue;
    }
    XCTAssertEqual(total, items.count);
    XCTAssertEqual(model.widthReads, items.count);
    group.itemArr = @[[CYLTagModel modelWithTitle:@"替换后的数据 🌟"]];
    XCTAssertEqualObjects(group.cellsCountArrayPerRowInSections, (@[@1]));
}

- (void)testProgrammaticViewUsesExternalDataAndDelegate {
    CYLTagTestSource *source = [[CYLTagTestSource alloc] init];
    source.titles = @[@"External item 😀", @"Another item 🌟"];
    CYLTagView *view = [[CYLTagView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    view.menuDataSource = source;
    view.menuDelegate = source;
    [view reloadMenuData];
    UICollectionView *collection = [view valueForKey:@"collectionView"];
    ((CYLTagGroup *)view.groups.firstObject).opened = YES;
    [collection reloadData];
    XCTAssertNotNil(collection);
    XCTAssertEqual([collection numberOfSections], 1);
    XCTAssertEqual([collection numberOfItemsInSection:0], 2);
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
    [collection.delegate collectionView:collection didSelectItemAtIndexPath:path];
    XCTAssertEqualObjects(source.selection, path);
    view.showHeader = NO;
    id<UICollectionViewDelegateFlowLayout> layoutDelegate = (id<UICollectionViewDelegateFlowLayout>)collection.delegate;
    XCTAssertTrue(CGSizeEqualToSize([layoutDelegate collectionView:collection layout:collection.collectionViewLayout
                                  referenceSizeForHeaderInSection:0], CGSizeZero));
    source.titles = @[@"Updated 🧪"];
    [view reloadMenuData];
    XCTAssertEqual([collection numberOfItemsInSection:0], 1);
}

- (void)testTagViewScalesWithAccessibilityTextSize {
    UITraitCollection *large = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];
    UITraitCollection *standard = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryLarge];
    CYLTagModel *model = [CYLTagModel modelWithTitle:@"一个非常非常长的标签 🧪🚀"];
    [model updateSizeForTraitCollection:standard];
    CGFloat standardWidth = model.width;
    XCTAssertEqualWithAccuracy(model.height, 35, 0.01);
    [model updateSizeForTraitCollection:large];
    XCTAssertGreaterThan(model.width, standardWidth);
    XCTAssertGreaterThan(model.height, 35);

    CYLTagTestSource *source = [[CYLTagTestSource alloc] init];
    source.titles = @[@"短标签 😀", @"稍长的标签 🎉", @"一个非常非常非常非常非常非常非常长的标签 🧪🚀", @"另一个长标签 🌟"];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 240, 600)];
    UIViewController *parent = [[UIViewController alloc] init];
    UIViewController *child = [[UIViewController alloc] init];
    window.rootViewController = parent;
    [window makeKeyAndVisible];
    [parent addChildViewController:child];
    child.view.frame = parent.view.bounds;
    [parent.view addSubview:child.view];
    [child didMoveToParentViewController:parent];
    CYLTagView *view = [[CYLTagView alloc] initWithFrame:child.view.bounds];
    view.menuDataSource = source;
    [child.view addSubview:view];
    [view reloadMenuData];
    [parent setOverrideTraitCollection:large forChildViewController:child];
    [child.view setNeedsLayout];
    [child.view layoutIfNeeded];
    [view layoutIfNeeded];
    CYLTagGroup *group = view.groups.firstObject;
    group.opened = YES;
    UICollectionView *collection = [view valueForKey:@"collectionView"];
    [collection reloadData];
    [collection layoutIfNeeded];
    UIFont *largeFont = [CYLTagModel titleFontForTraitCollection:large];
    NSMutableArray<UICollectionViewLayoutAttributes *> *items = [NSMutableArray array];
    for (NSInteger index = 0; index < group.itemArr.count; index++) {
        UICollectionViewLayoutAttributes *attributes =
            [collection.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        XCTAssertNotNil(attributes);
        XCTAssertGreaterThan(CGRectGetHeight(attributes.frame), 35);
        XCTAssertLessThanOrEqual(CGRectGetMaxX(attributes.frame), 240 - kTagCollectionViewToRightMargin + 0.5);
        for (UICollectionViewLayoutAttributes *previous in items) {
            XCTAssertFalse(CGRectIntersectsRect(attributes.frame, previous.frame));
        }
        [items addObject:attributes];
    }
    for (UICollectionViewCell *cell in collection.visibleCells) {
        UILabel *label = [cell valueForKey:@"titleLb"];
        XCTAssertEqualWithAccuracy(label.font.pointSize, largeFont.pointSize, 0.01);
    }
    window.hidden = YES;
}

@end
