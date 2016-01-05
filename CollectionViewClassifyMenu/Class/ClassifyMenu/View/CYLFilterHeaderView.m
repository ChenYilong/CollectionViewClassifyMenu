//
//  FilterHeaderView.m
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by  https://github.com/ChenYilong  on 14-7-9.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//

#import "CYLFilterHeaderView.h"

static float const kTitleButtonWidth = 250.f;
static float const kMoreButtonWidth  = 36 * 2;
static float const kCureOfLineHight  = 0.5;
static float const kCureOfLineOffX   = 16;

float const CYLFilterHeaderViewHeigt = 38;

@interface CYLFilterHeaderView()

@end

@implementation CYLFilterHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)sharedInit {
    UIView *cureOfLine = [[UIView alloc] initWithFrame:CGRectMake(kCureOfLineOffX, CYLFilterHeaderViewHeigt-kCureOfLineHight, [UIScreen mainScreen].bounds.size.width - 2 * kCureOfLineOffX, kCureOfLineHight)];
    cureOfLine.backgroundColor = [UIColor colorWithRed:188.0 / 255.0 green:188.0 / 255.0 blue:188.0 / 255.0 alpha:1.0];
    [self addSubview:cureOfLine];
    self.backgroundColor = [UIColor whiteColor];
    //仅修改self.titleButton的宽度,xyh值不变
    self.titleButton = [[CYLIndexPathButton alloc] init];
    self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
    self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.titleButton.frame = CGRectMake(16, 0, kTitleButtonWidth,  self.frame.size.height);
    self.titleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self addSubview:self.titleButton];
    CGRect  moreBtnFrame = CGRectMake(self.moreButton.frame.origin.x, 0, kMoreButtonWidth, self.frame.size.height);
    self.moreButton = [[CYLRightImageButton alloc] initWithFrame:moreBtnFrame];
    //仅修改self.moreButton的x,ywh值不变
    self.moreButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 12 - self.moreButton.frame.size.width, self.moreButton.frame.origin.y, self.moreButton.frame.size.width, self.moreButton.frame.size.height);
    [self.moreButton setImage:[UIImage imageNamed:@"home_btn_more_normal"] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage imageNamed:@"home_btn_more_selected"] forState:UIControlStateSelected];
    [self.moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.moreButton setTitle:@"更多" forState:UIControlStateNormal];
    [self.moreButton setTitle:@"收起" forState:UIControlStateSelected];
    self.moreButton.titleLabel.textAlignment = NSTextAlignmentRight;
    self.moreButton.hidden = YES;
    [self.moreButton addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreButton];
    return self;
}

- (void)moreBtnClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(filterHeaderViewMoreBtnClicked:)]) {
        [self.delegate filterHeaderViewMoreBtnClicked:self.moreButton];
    }
}

@end
