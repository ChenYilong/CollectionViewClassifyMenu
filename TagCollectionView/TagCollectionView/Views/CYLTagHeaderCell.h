//
//  CYLTagHeaderCell.h
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CYLTagGroup.h"
@class CYLTagHeaderCell;
@protocol CYLTagHeaderCellDelegate<NSObject>

- (void)headerViewDidTapNameView:(CYLTagHeaderCell *)headerCell index:(NSInteger)idx;

@end

@interface CYLTagHeaderCell : UICollectionReusableView

@property(nonatomic,copy)CYLTagGroup*group;
@property(nonatomic,weak)id<CYLTagHeaderCellDelegate> delegate;
@end
