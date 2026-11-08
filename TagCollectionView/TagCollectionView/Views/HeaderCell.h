//
//  HeaderCell.h
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 AK. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TagGroup.h"
@class HeaderCell;
@protocol HeaderCellDelegate<NSObject>

- (void)headerViewDidClickedNameView:(HeaderCell *)HeaderCell index:(NSInteger)idx;

@end

@interface HeaderCell : UICollectionReusableView

@property(nonatomic,copy)TagGroup*group;
@property(nonatomic,weak)id<HeaderCellDelegate> delegate;
@end
