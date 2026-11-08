//
//  FilterHeaderView.h
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by  https://github.com/ChenYilong  on 14-7-9.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//
#import <UIKit/UIKit.h>

@class FilterHeaderView;
@protocol CYLFilterHeaderViewDelegate <NSObject>

@required
- (void)filterHeaderViewDidTapMoreButton:(id)sender;

@end

#import <UIKit/UIKit.h>
#import "CYLIndexPathButton.h"
#import "CYLRightImageButton.h"

extern const float CYLFilterHeaderViewHeigt;

@interface CYLFilterHeaderView : UICollectionReusableView

@property (nonatomic, strong) CYLIndexPathButton       *titleButton;
@property (nonatomic, strong) CYLRightImageButton      *moreButton;
@property (nonatomic, weak  ) id<CYLFilterHeaderViewDelegate> delegate;

- (void)moreButtonTapped:(id)sender;

@end
