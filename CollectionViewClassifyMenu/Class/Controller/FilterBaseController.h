//
//  FilterBaseController.h
//  PiFuKeYiSheng
//
//  Created by  https://github.com/ChenYilong  on 14-5-12.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//

// 问题筛选和医生筛选的基础类

#define kCollectionViewToLeftMargin                50
#define kCollectionViewToTopMargin                 12
#define kCollectionViewToRightMargin               5
#define kCollectionViewToBottomtMargin             15
//#import "Constant.h"
//#import "Util.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "FilterHeaderView.h"
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
