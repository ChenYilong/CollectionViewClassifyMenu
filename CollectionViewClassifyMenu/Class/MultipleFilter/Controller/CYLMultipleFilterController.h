//
//  CYLMultipleFilterController.h
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by  https://github.com/ChenYilong  on 14-7-10.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//  CYLMultipleFilterController Choice Storage Filter

#import "CYLFilterBaseController.h"
#import "CYLMenuDataSource.h"

@interface CYLMultipleFilterController : CYLFilterBaseController

@property (nonatomic, weak) id<CYLMenuDataSource> menuDataSource;
@property (nonatomic, weak) id<CYLMenuDelegate> menuDelegate;

- (void)refreshFilterParams;
- (void)reloadMenuData;
- (NSArray<NSIndexPath *> *)selectedIndexPaths;
- (void)setSelectedIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

@end
