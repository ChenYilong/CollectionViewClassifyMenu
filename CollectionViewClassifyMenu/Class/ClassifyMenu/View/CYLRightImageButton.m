//
//  CYLRightImageButton.m
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/23.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//
static float const kImageToTextMargin = 7;

#import "CYLRightImageButton.h"

@implementation CYLRightImageButton

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
    [self setTitle:@"更多" forState:UIControlStateNormal];
    [self setTitle:@"收起" forState:UIControlStateSelected];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    self.adjustsImageWhenHighlighted = NO;
    [self setImage:[UIImage imageNamed:@"home_btn_more_normal"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"home_btn_more_selected"] forState:UIControlStateSelected];
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -self.imageView.frame.size.width-kImageToTextMargin, 0, self.imageView.frame.size.width);
    self.imageEdgeInsets = UIEdgeInsetsMake(0, self.titleLabel.frame.size.width, 0, -self.titleLabel.frame.size.width);
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {}

@end
