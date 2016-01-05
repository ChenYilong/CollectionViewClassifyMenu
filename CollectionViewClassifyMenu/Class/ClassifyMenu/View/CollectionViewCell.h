//
//  CollectionViewCell.h
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/17.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYLIndexPathButton.h"

@interface CollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) CYLIndexPathButton *button;
@property (nonatomic, assign) NSUInteger         section;
@property (nonatomic, assign) NSUInteger         row;
@property (nonatomic, assign) BOOL               shouldShow;

@end
