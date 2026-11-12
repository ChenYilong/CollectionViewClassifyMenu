//
//  CYLIndexPathButton.m
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/19.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//

#import "CYLIndexPathButton.h"

@implementation CYLIndexPathButton

- (void)setCyl_imageTitleSpacing:(CGFloat)spacing {
    if (_cyl_imageTitleSpacing == spacing) {
        return;
    }
    _cyl_imageTitleSpacing = spacing;
    [self setNeedsLayout];
}

- (void)setCyl_titleLeadingInset:(CGFloat)inset {
    if (_cyl_titleLeadingInset == inset) {
        return;
    }
    _cyl_titleLeadingInset = inset;
    [self setNeedsLayout];
}

// Positions the image and title after UIKit's layout instead of using the
// image/title edge insets and content-rect overrides deprecated in iOS 15.
- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL hasImage = self.currentImage != nil;
    BOOL hasTitle = self.currentTitle.length > 0;
    CGFloat titleOffset = self.cyl_titleLeadingInset;
    if (self.cyl_imageTitleSpacing > 0 && hasImage && hasTitle) {
        CGRect imageFrame = self.imageView.frame;
        imageFrame.origin.x -= self.cyl_imageTitleSpacing / 2.0;
        self.imageView.frame = imageFrame;
        titleOffset += self.cyl_imageTitleSpacing / 2.0;
    }
    if (titleOffset != 0 && hasTitle) {
        CGRect titleFrame = self.titleLabel.frame;
        titleFrame.origin.x += titleOffset;
        titleFrame.size.width = MAX(0, MIN(CGRectGetWidth(titleFrame), CGRectGetWidth(self.bounds) - CGRectGetMinX(titleFrame)));
        self.titleLabel.frame = titleFrame;
    }
}

@end
