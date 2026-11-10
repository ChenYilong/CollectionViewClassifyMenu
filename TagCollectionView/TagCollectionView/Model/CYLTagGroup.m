//
//  CYLTagGroup.m
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import "CYLTagGroup.h"
#import <UIKit/UIKit.h>
#import "CYLTagModel.h"
@interface CYLTagGroup()

@property (nonatomic, strong) NSArray *rowsCountPerSection;

@end
@implementation CYLTagGroup


-(instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{
    
    [self caculate];
    
}

-(void)caculate{
    
    // Width is supplied by the hosting view; see -firstRowCellCountForContentWidth:.
    _width=0;
    
    _height=38;
}

-(void)setItemArr:(NSArray *)itemArr{
    
    _itemArr=itemArr;
    self.cellsCountArrayPerRowInSections = nil;
    self.rowsCountPerSection = nil;
    

//    更多 展示1行数据 / Show one row before expansion.
    self.firstRowCount= [self firstRowCellCountWithArray:self.itemArr];
//
//    NSArray* rowsCountPerSection=self.rowsCountPerSection;

    
//    更多 展示2行数据 / Show two rows before expansion.
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
    CGFloat available = [self cyl_defaultContentWidth];
    NSMutableArray *counts = [NSMutableArray array];
    CGFloat used = 0;
    NSUInteger count = 0;
    for (CYLTagModel *model in array) {
        CGFloat width = MIN(MAX(0, model.width), available);
        if (count && used + kTagCollectionViewCellsHorizonMargin + width > available) {
            [counts addObject:@(count)];
            count = 0;
            used = 0;
        }
        used += (count ? kTagCollectionViewCellsHorizonMargin : 0) + width;
        count++;
    }
    if (count) {
        [counts addObject:@(count)];
    }
    return counts;
}

- (NSUInteger)firstRowCellCountWithArray:(NSArray *)array {
    return [self firstRowCellCountWithArray:array
                               contentWidth:[self cyl_defaultContentWidth]];
}

/// Content width used before a hosting view supplies one: the group's `width`
/// when set, otherwise the screen width as a legacy fallback.
- (CGFloat)cyl_defaultContentWidth {
    CGFloat width = self.width > 0 ? self.width : [UIScreen mainScreen].bounds.size.width;
    return MAX(0, width - kTagCollectionViewToLeftMargin - kTagCollectionViewToRightMargin);
}

- (NSUInteger)firstRowCellCountForContentWidth:(CGFloat)contentWidth {
    return [self firstRowCellCountWithArray:self.itemArr contentWidth:MAX(0, contentWidth)];
}

- (NSUInteger)firstRowCellCountWithArray:(NSArray *)array contentWidth:(CGFloat)contentWidth {
    NSUInteger count = 0;
    CGFloat usedWidth = 0;
    for (CYLTagModel *model in array) {
        CGFloat width = MIN(MAX(0, model.width), contentWidth);
        CGFloat nextWidth = usedWidth + (count ? kTagCollectionViewCellsHorizonMargin : 0) + width;
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
 The last item in a section has no trailing spacing.
 分行规则 / Wrapping rules:
 
 1. cell与cell之间必须有大小为kTagCollectionViewCellsHorizonMargin的间距，
    Adjacent cells require kTagCollectionViewCellsHorizonMargin spacing.
 2. 左右可以没有间距。 / No spacing is required at the outer edges.
 
 那么有这样的规律： / Consequently:
 
 1. 一旦cell+kTagCollectionViewCellsHorizonMargin超过contentViewWidth，则肯定要分行。
    A cell plus its spacing exceeding the available width wraps.
 2. cell超过contentViewWidth也会分行。 / A cell wider than the available width also wraps.
 
 两者的区别在于cell的宽度，前者还是自身宽度，但后者已经变成了contentViewWidth的宽度。
 The former keeps its own width; the latter is capped at the available width.
 */
- (float)textImageWidthAndRightMargin:(NSString *)text
                              content:(CYLTagModel*)obj
                                array:(NSArray *)array {
    
    CGFloat contentViewWidth = [self cyl_defaultContentWidth];
    __block float cellWidth = obj.width;
    __block float cellWidthAndRightMargin;
    if (cellWidth == contentViewWidth) {
        cellWidthAndRightMargin = contentViewWidth;
    } else {
        if (obj == [array lastObject]) {
            cellWidthAndRightMargin = cellWidth;
        } else {
            [self cellLimitWidth:cellWidth
                     limitMargin:kTagCollectionViewCellsHorizonMargin
                    isLimitWidth:^(BOOL isLimitWidth, NSNumber *data) {
                        if (isLimitWidth) {
                            //当cell和kTagCollectionViewCellsHorizonMargin总和大于contentViewWidth，
                            //但是cell却小于contentViewWidth时，还是占一行。
                            // A cell that fits alone but not with spacing occupies its own row.
                            cellWidthAndRightMargin = contentViewWidth;
                        } else {
                            //这个地方只是大概的估计下，他不能判断出当加上下一个cell的cellWidthAndRightMargin大于contentViewWidth时，
                            //cellWidthAndRightMargin右侧剩余的部分
                            //所以必须在后续判断与下个一cell的cellWidthAndRightMargin的和超出contentViewWidth时的情况
                            // This estimate cannot know the remaining space after the next cell;
                            // the following layout calculation must check whether their sum fits.
                            cellWidthAndRightMargin = cellWidth + kTagCollectionViewCellsHorizonMargin;
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
    float limitWidth = ([self cyl_defaultContentWidth] - limitMargin);
    if (cellWidth >= limitWidth) {
        cellWidth = limitWidth;
        isLimitWidth ? isLimitWidth(YES, @(cellWidth)) : nil;
        return cellWidth;
    }
    isLimitWidth ? isLimitWidth(NO, @(cellWidth)) : nil;
    return cellWidth;
}

@end
