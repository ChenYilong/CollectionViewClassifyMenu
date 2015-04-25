//
//  FilterHeaderView.m
//  PiFuKeYiSheng
//
//  Created by 喻平 on 14-7-9.
//  Copyright (c) 2014年 com.pifukeyisheng. All rights reserved.
//

#import "FilterHeaderView.h"

@implementation FilterHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    //仅修改_titleLabel的宽度,xyh值不变
    float width = [UIScreen mainScreen].bounds.size.width - 50 - 50;
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, width, _titleLabel.frame.size.height);
    _titleLabel.frame = CGRectMake(0, _titleLabel.frame.size.height - 0.5f, _titleLabel.frame.size.width, 0.5f);
     _titleLabel.backgroundColor = [UIColor colorWithRed:146/255.f green:175/255.f blue:164/255.f alpha:1.f];
    _titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
}

@end
