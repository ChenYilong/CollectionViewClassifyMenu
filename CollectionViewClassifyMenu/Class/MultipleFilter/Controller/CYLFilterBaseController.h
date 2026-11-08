//
//  CYLFilterBaseController.h
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by  https://github.com/ChenYilong  on 14-5-12.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//

// 问题筛选和医生筛选的基础类 / Base class for question and doctor filters.

static float const kCollectionViewToLeftMargin    = 50;
static float const kCollectionViewToTopMargin     = 12;
static float const kCollectionViewToRightMargin   = 5;
static float const kCollectionViewToBottomtMargin = 15;

#import "CYLCollectionViewLeftAlignedLayout.h"
#import "CYLMultipleFilterHeaderView.h"
#import "CYLFilterCollectionCell.h"

@class CYLFilterBaseController;
@protocol CYLFilterControllerDelegate <NSObject>

@optional
- (void)filterControllerDidComplete:(CYLFilterBaseController *)controller;

@end

@interface CYLFilterBaseController : UIViewController

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIButton *restoreButton;
@property (nonatomic, weak) IBOutlet UIButton *okButton;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *settingArray;
@property (nonatomic, weak) id<CYLFilterControllerDelegate> delegate;

- (void)showInView:(UIView *)view;
- (void)itemButtonClicked:(CYLIndexPathButton *)button;
- (IBAction)confirmButtonClicked:(id)sender;
- (IBAction)restoreButtonClicked:(id)sender;

@end
