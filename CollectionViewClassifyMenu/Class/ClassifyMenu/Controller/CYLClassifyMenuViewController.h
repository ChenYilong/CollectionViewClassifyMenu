//
//  CYLClassifyMenuViewController.h
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/17.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYLMenuDataSource.h"

@interface CYLClassifyMenuViewController : UIViewController

@property (nonatomic, weak) id<CYLMenuDataSource> menuDataSource;
@property (nonatomic, weak) id<CYLMenuDelegate> menuDelegate;
@property (nonatomic, strong) UIView *menuHeaderView;
@property (nonatomic, assign) NSUInteger defaultVisibleRows;

- (void)reloadMenuData;

@end
