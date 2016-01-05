//
//  FilterBaseController.h
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by  https://github.com/ChenYilong  on 14-5-12.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//

// 问题筛选和医生筛选的基础类

static float const kCollectionViewToLeftMargin    = 50;
static float const kCollectionViewToTopMargin     = 12;
static float const kCollectionViewToRightMargin   = 5;
static float const kCollectionViewToBottomtMargin = 15;

#import "UICollectionViewLeftAlignedLayout.h"
#import "CYLMultipleFilterHeaderView.h"
#import "FilterCollectionCell.h"

@class FilterBaseController;
@protocol FilterControllerDelegate <NSObject>

@optional
- (void)filterControllerDidCompleted:(FilterBaseController *)controller;

@end

@interface FilterBaseController : UIViewController

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIButton *restoreButton;
@property (nonatomic, weak) IBOutlet UIButton *okButton;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *settingArray;
@property (nonatomic, assign) id<FilterControllerDelegate> delegate;

- (void)showInView:(UIView *)view;
- (void)itemButtonClicked:(CYLIndexPathButton *)button;
- (IBAction)confirmButtonClicked:(id)sender;
- (IBAction)restoreButtonClicked:(id)sender;

@end
