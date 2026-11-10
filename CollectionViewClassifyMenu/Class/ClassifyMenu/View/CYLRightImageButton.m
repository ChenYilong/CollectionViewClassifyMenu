//
//  CYLRightImageButton.m
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/23.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//
static float const kImageToTextMargin = 7;

#import "CYLRightImageButton.h"
#import "CYLMenuResources.h"

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
    [self setImage:[CYLMenuResources imageNamed:@"home_btn_more_normal"] forState:UIControlStateNormal];
    [self setImage:[CYLMenuResources imageNamed:@"home_btn_more_selected"] forState:UIControlStateSelected];
    return self;
}

// Places the title before the image after UIKit's layout, instead of the
// edge insets and content-rect overrides deprecated in iOS 15. The group
// keeps UIKit's alignment.
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect imageFrame = self.imageView.frame;
    CGRect titleFrame = self.titleLabel.frame;
    if (self.currentImage == nil || self.currentTitle.length == 0 ||
        CGRectIsEmpty(imageFrame) || CGRectIsEmpty(titleFrame)) {
        return;
    }
    CGFloat groupX = MIN(CGRectGetMinX(imageFrame), CGRectGetMinX(titleFrame)) - kImageToTextMargin / 2.0;
    titleFrame.origin.x = MAX(0, groupX);
    CGFloat maxTitleWidth = CGRectGetWidth(self.bounds) - CGRectGetWidth(imageFrame) - kImageToTextMargin - CGRectGetMinX(titleFrame);
    titleFrame.size.width = MAX(0, MIN(CGRectGetWidth(titleFrame), maxTitleWidth));
    imageFrame.origin.x = CGRectGetMaxX(titleFrame) + kImageToTextMargin;
    self.titleLabel.frame = titleFrame;
    self.imageView.frame = imageFrame;
}

- (void)setHighlighted:(BOOL)highlighted {}

@end
