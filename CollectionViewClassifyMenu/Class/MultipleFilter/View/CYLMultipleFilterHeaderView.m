//
//  FilterHeaderView.m
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by  https://github.com/ChenYilong  on 14-7-9.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//

#import "CYLMultipleFilterHeaderView.h"
#import "UIView+CYLGeneral.h"

@interface CYLMultipleFilterHeaderView ()
@property (nonatomic, strong) CALayer *separator;
@end

@implementation CYLMultipleFilterHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.separator = [_titleLabel cyl_addSubLayerWithFrame:CGRectZero color:[UIColor colorWithRed:146 / 255.f green:175 / 255.f blue:164 / 255.f alpha:1.f].CGColor];
    _titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 标题宽度跟随 header 实际宽度 / The title follows the header's actual width.
    CGRect frame = _titleLabel.frame;
    frame.size.width = MAX(0, CGRectGetWidth(self.bounds) - CGRectGetMinX(frame));
    _titleLabel.frame = frame;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.separator.frame = CGRectMake(0, CGRectGetHeight(frame) - 0.5f, CGRectGetWidth(frame), 0.5f);
    [CATransaction commit];
}

@end
