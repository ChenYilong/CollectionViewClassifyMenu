//
//  CYLTagGroup.h
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import <Foundation/Foundation.h>


static float const kTagCollectionViewCellsHorizonMargin          = 12;

static float const kTagCollectionViewToLeftMargin                = 16;
static float const kTagCollectionViewToTopMargin                 = 12;
static float const kTagCollectionViewToRightMargin               = 16;
static float const kTagCollectionViewToBottomtMargin             = 10;


@interface CYLTagGroup : NSObject

@property (nonatomic, copy) NSString* groupName;

@property (nonatomic, assign) float width;

@property (nonatomic, assign) float height;



/*!
 *  标识这组是否需要展开, YES: 展开, NO: 关闭 / Whether the group is expanded.
 */
@property (nonatomic, assign, getter = isOpened) BOOL opened;

@property (nonatomic, assign) NSInteger  section;

@property(nonatomic,copy)NSArray* itemArr;


@property(nonatomic,assign)NSUInteger firstRowCount;

- (NSUInteger)firstRowCellCountForContentWidth:(CGFloat)contentWidth;
/*!
 * 有几行 每行有几个item / Number of items in each row.
 */
@property (nonatomic, strong) NSArray *cellsCountArrayPerRowInSections;

@end
