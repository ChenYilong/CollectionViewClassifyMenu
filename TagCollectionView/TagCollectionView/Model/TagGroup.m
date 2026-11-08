//
//  TagGroup.m
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 AK. All rights reserved.
//

#import "TagGroup.h"
#import <UIKit/UIKit.h>
#import "TagModel.h"
@interface TagGroup()

@property (nonatomic, strong) NSArray *rowsCountPerSection;

@end
@implementation TagGroup


-(instancetype)init{
    if (self==[super init]) {
        [self setup];
    }
    return self;
}

-(void)setup{
    
    [self caculate];
    
}

-(void)caculate{
    
    _width=[UIScreen mainScreen].bounds.size.width - 50;
    
    _height=38;
}

-(void)setItemArr:(NSArray *)itemArr{
    
    _itemArr=itemArr;
    

//    更多 展示1行数据
    self.firstRowCount= [self firstRowCellCountWithArray:self.itemArr];
//
//    NSArray* rowsCountPerSection=self.rowsCountPerSection;

    
//    更多 展示2行数据
//    NSArray*cellsCountArrayPerRowInSections=self.cellsCountArrayPerRowInSections;
//    if (cellsCountArrayPerRowInSections.count>0) {
//
//
//        int row1= [(NSNumber*)[cellsCountArrayPerRowInSections firstObject ] intValue];
//        
//        int row2= [(NSNumber*)cellsCountArrayPerRowInSections[1] intValue];
//
//        self.firstRowCount=row1+row2;
//    }

 
    
}

#pragma mark - 💤 LazyLoad Method

/**
 *  lazy load _rowsCountPerSection
 *
 *  @return NSArray
 */
- (NSArray *)rowsCountPerSection {
    if (_rowsCountPerSection == nil) {
        
        _rowsCountPerSection = [[NSArray alloc] init];
        
        NSMutableArray *rowsCountPerSection = [NSMutableArray array];
        
        
        NSMutableArray *items = [NSMutableArray array];
        
        [items addObjectsFromArray:self.itemArr];
        
        NSUInteger secondRowCellCount =
                                    [[self cellsInPerRowWhenLayoutWithArray:items] count];
        
        [rowsCountPerSection addObject:@(secondRowCellCount)];
        
        _rowsCountPerSection = (NSArray *)rowsCountPerSection;
    }
    return _rowsCountPerSection;
}



/**
 *  lazy load _cellsCountArrayPerRowInSections
 *
 *  @return NSArray
 */
- (NSArray *)cellsCountArrayPerRowInSections {
    if (_cellsCountArrayPerRowInSections == nil) {
       
            NSMutableArray *items = [NSMutableArray array];
            
            [items addObjectsFromArray:self.itemArr];

        _cellsCountArrayPerRowInSections = [[NSArray alloc] initWithArray:[self cellsInPerRowWhenLayoutWithArray:items]];
        
        
    }
    return _cellsCountArrayPerRowInSections;
}

- (NSMutableArray *)cellsInPerRowWhenLayoutWithArray:(NSMutableArray *)array {
    __block NSUInteger secondRowCellCount = 0;
    NSMutableArray *items = [NSMutableArray arrayWithArray:array];
    NSUInteger firstRowCount = [self firstRowCellCountWithArray:items];
    
    NSLog(@"firstRowCount %lu",firstRowCount);
    
    NSMutableArray *cellCount = [NSMutableArray arrayWithObject:@(firstRowCount)];
    for (NSUInteger index = 0; index < [array count]; index++) {
        NSUInteger firstRowCount = [self firstRowCellCountWithArray:items];
        if (items.count != firstRowCount) {
            NSRange range = NSMakeRange(0, firstRowCount);
            [items removeObjectsInRange:range];
            NSUInteger secondRowCount = [self firstRowCellCountWithArray:items];
            secondRowCellCount = secondRowCount;
            [cellCount addObject:@(secondRowCount)];
        } else {
            return cellCount;
        }
    }
    return cellCount;
}

- (NSUInteger)firstRowCellCountWithArray:(NSArray *)array {
    return [self firstRowCellCountWithArray:array
                               contentWidth:MAX(0, kUIScreenWidth - kCollectionViewToLeftMargin - kCollectionViewToRightMargin)];
}

- (NSUInteger)firstRowCellCountForContentWidth:(CGFloat)contentWidth {
    return [self firstRowCellCountWithArray:self.itemArr contentWidth:MAX(0, contentWidth)];
}

- (NSUInteger)firstRowCellCountWithArray:(NSArray *)array contentWidth:(CGFloat)contentWidth {
    NSUInteger count = 0;
    CGFloat usedWidth = 0;
    for (TagModel *model in array) {
        CGFloat width = MIN(MAX(0, model.width), contentWidth);
        CGFloat nextWidth = usedWidth + (count ? kCollectionViewCellsHorizonMargin : 0) + width;
        if (count && nextWidth > contentWidth) {
            break;
        }
        usedWidth = nextWidth;
        count++;
    }
    return count;
}



/*
 
 @attention 特别注意：本方法已经对每个 section 的最后一个元素进行了考虑，不会加上右边的间隔。
 分行规则：
 
 1. cell与cell之间必须有大小为kCollectionViewCellsHorizonMargin的间距，
 2. 左右可以没有间距。
 
 那么有这样的规律：
 
 1. 一旦cell+kCollectionViewCellsHorizonMargin超过contentViewWidth，则肯定要分行。
 2. cell超过contentViewWidth也会分行。
 
 两者的区别在于cell的宽度，前者还是自身宽度，但后者已经变成了contentViewWidth的宽度。
 */
- (float)textImageWidthAndRightMargin:(NSString *)text
                              content:(TagModel*)obj
                                array:(NSArray *)array {
    
    CGFloat contentViewWidth = kUIScreenWidth - kCollectionViewToLeftMargin - kCollectionViewToRightMargin;
    __block float cellWidth = obj.width;
    __block float cellWidthAndRightMargin;
    if (cellWidth == contentViewWidth) {
        cellWidthAndRightMargin = contentViewWidth;
    } else {
        if (obj == [array lastObject]) {
            cellWidthAndRightMargin = cellWidth;
        } else {
            [self cellLimitWidth:cellWidth
                     limitMargin:kCollectionViewCellsHorizonMargin
                    isLimitWidth:^(BOOL isLimitWidth, NSNumber *data) {
                        if (isLimitWidth) {
                            //当cell和kCollectionViewCellsHorizonMargin总和大于contentViewWidth，
                            //但是cell却小于contentViewWidth时，还是占一行。
                            cellWidthAndRightMargin = contentViewWidth;
                        } else {
                            //这个地方只是大概的估计下，他不能判断出当加上下一个cell的cellWidthAndRightMargin大于contentViewWidth时，
                            //cellWidthAndRightMargin右侧剩余的部分
                            //所以必须在后续判断与下个一cell的cellWidthAndRightMargin的和超出contentViewWidth时的情况
                            cellWidthAndRightMargin = cellWidth + kCollectionViewCellsHorizonMargin;
                        }
                    }];
        }
    }
    return cellWidthAndRightMargin;
}


typedef void(^ISLimitWidth)(BOOL yesORNo, id data);

- (float)cellLimitWidth:(float)cellWidth
            limitMargin:(CGFloat)limitMargin
           isLimitWidth:(ISLimitWidth)isLimitWidth {
    float limitWidth = (kUIScreenWidth - kCollectionViewToLeftMargin - kCollectionViewToRightMargin - limitMargin);
    if (cellWidth >= limitWidth) {
        cellWidth = limitWidth;
        isLimitWidth ? isLimitWidth(YES, @(cellWidth)) : nil;
        return cellWidth;
    }
    isLimitWidth ? isLimitWidth(NO, @(cellWidth)) : nil;
    return cellWidth;
}

@end
