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

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect rect = [super imageRectForContentRect:contentRect];
    if (self.cyl_imageTitleSpacing > 0 && self.currentTitle.length > 0) {
        rect.origin.x -= self.cyl_imageTitleSpacing / 2.0;
    }
    return rect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect rect = [super titleRectForContentRect:contentRect];
    CGFloat offset = self.cyl_titleLeadingInset;
    if (self.cyl_imageTitleSpacing > 0 && self.currentImage != nil) {
        offset += self.cyl_imageTitleSpacing / 2.0;
    }
    if (offset == 0) {
        return rect;
    }
    rect.origin.x += offset;
    CGFloat maxWidth = CGRectGetMaxX(contentRect) - CGRectGetMinX(rect);
    rect.size.width = MAX(0, MIN(CGRectGetWidth(rect), maxWidth));
    return rect;
}

@end
