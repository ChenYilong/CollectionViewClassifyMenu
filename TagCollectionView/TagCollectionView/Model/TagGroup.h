//
//  TagGroup.h
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 AK. All rights reserved.
//

#import <Foundation/Foundation.h>


static float const kCollectionViewCellsHorizonMargin          = 12;

static float const kCollectionViewToLeftMargin                = 16;
static float const kCollectionViewToTopMargin                 = 12;
static float const kCollectionViewToRightMargin               = 16;
static float const kCollectionViewToBottomtMargin             = 10;


@interface TagGroup : NSObject

@property (nonatomic, copy) NSString* groupName;

@property (nonatomic, assign) float width;

@property (nonatomic, assign) float height;



/**
 *  标识这组是否需要展开,  YES : 展开 ,  NO : 关闭
 */
@property (nonatomic, assign, getter = isOpened) BOOL opened;

@property (nonatomic, assign) NSInteger  section;

@property(nonatomic,copy)NSArray* itemArr;


@property(nonatomic,assign)NSUInteger firstRowCount;

- (NSUInteger)firstRowCellCountForContentWidth:(CGFloat)contentWidth;
/**
 * 有几行 每行有几个item
 */
@property (nonatomic, strong) NSArray *cellsCountArrayPerRowInSections;

@end
