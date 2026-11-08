//
//  TagCollectionViewTests.m
//  TagCollectionViewTests
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 AK. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TagView.h"

@interface TagCollectionViewTests : XCTestCase

@end

@implementation TagCollectionViewTests

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
    TagView *view = [TagView TagView];
    TagGroup *group = [[TagGroup alloc] init];
    group.itemArr = @[[TagModel modelWithTitle:@"短标签 😀"],
                      [TagModel modelWithTitle:@"稍长的标签 🎉"],
                      [TagModel modelWithTitle:@"一个非常非常非常非常非常非常非常长的标签 🧪🚀"],
                      [TagModel modelWithTitle:@"另一个长标签 🌟"]];
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
            XCTAssertLessThanOrEqual(CGRectGetMaxX(attributes.frame), width - kCollectionViewToRightMargin + 0.5);
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

@end
