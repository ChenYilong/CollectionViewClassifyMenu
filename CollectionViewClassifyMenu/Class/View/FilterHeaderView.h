//
//  FilterHeaderView.h
//  PiFuKeYiSheng
//
//  Created by 喻平 on 14-7-9.
//  Copyright (c) 2014年 com.pifukeyisheng. All rights reserved.
//
#import <UIKit/UIKit.h>
@class FilterHeaderView;
@protocol FilterHeaderViewDelegate <NSObject>
@required
-(void)filterHeaderViewMoreBtnClicked:(id)sender;
@end

#import <UIKit/UIKit.h>
#import "CYLIndexPathButton.h"
extern float CYLFilterHeaderViewHeigt;
@interface FilterHeaderView : UICollectionReusableView
@property (nonatomic, strong) IBOutlet CYLIndexPathButton *titleButton;
@property (nonatomic, strong) IBOutlet CYLIndexPathButton *moreButton;
@property (nonatomic, weak) id<FilterHeaderViewDelegate> delegate;
- (IBAction)moreBtnClicked:(id)sender;

@end
