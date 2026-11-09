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

// Place the title before the image without the image/title edge insets that
// are deprecated in iOS 15. The content group keeps UIKit's alignment.
- (CGFloat)cyl_groupOriginXForContentRect:(CGRect)contentRect {
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    if (CGRectIsEmpty(imageRect) || CGRectIsEmpty(titleRect)) {
        return 0;
    }
    return MIN(CGRectGetMinX(imageRect), CGRectGetMinX(titleRect)) - kImageToTextMargin / 2.0;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    if (CGRectIsEmpty(imageRect) || CGRectIsEmpty(titleRect)) {
        return titleRect;
    }
    titleRect.origin.x = MAX(CGRectGetMinX(contentRect), [self cyl_groupOriginXForContentRect:contentRect]);
    CGFloat maxWidth = CGRectGetMaxX(contentRect) - CGRectGetWidth(imageRect) - kImageToTextMargin - CGRectGetMinX(titleRect);
    titleRect.size.width = MAX(0, MIN(CGRectGetWidth(titleRect), maxWidth));
    return titleRect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    CGRect titleRect = [self titleRectForContentRect:contentRect];
    if (CGRectIsEmpty(imageRect) || CGRectIsEmpty(titleRect)) {
        return imageRect;
    }
    imageRect.origin.x = CGRectGetMaxX(titleRect) + kImageToTextMargin;
    return imageRect;
}

- (void)setHighlighted:(BOOL)highlighted {}

@end
