//
//  UIView+General.m
//
//
//  Created by  http://weibo.com/luohanchenyilong/ on 13-2-28.
//  Copyright (c) 2013年  https://github.com/ChenYilong . All rights reserved.
//

#import "UIView+General.h"

@implementation UIView (General)

- (void)cyl_setWidth:(CGFloat)width {
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

- (void)cyl_setHeight:(CGFloat)height {
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (void)cyl_setX:(CGFloat)x {
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}

- (void)cyl_setY:(CGFloat)y {
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}

- (CGFloat)cyl_x {
    return self.frame.origin.x;
}

- (CGFloat)cyl_y {
    return self.frame.origin.y;
}

- (CGFloat)cyl_height {
    return self.frame.size.height;
}

- (CGFloat)cyl_width {
    return self.frame.size.width;
}

- (CGFloat)cyl_maxY {
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)cyl_maxX {
    return CGRectGetMaxX(self.frame);
}

- (void)cyl_setSize:(CGSize)size {
    CGRect rect = self.frame;
    rect.size = size;
    self.frame = rect;
}

- (void)cyl_horizontalCenterWithWidth:(CGFloat)width {
    [self cyl_setX:ceilf((width - self.cyl_width) / 2)];
}

- (void)cyl_verticalCenterWithHeight:(CGFloat)height {
    [self cyl_setY:ceilf((height - self.cyl_height) / 2)];
}

- (void)cyl_verticalCenterInSuperView {
    [self cyl_verticalCenterWithHeight:self.superview.cyl_height];
}

- (void)cyl_horizontalCenterInSuperView {
    [self cyl_horizontalCenterWithWidth:self.superview.cyl_width];
}

- (void)cyl_setBoarderWith:(CGFloat)width color:(CGColorRef)color {
    self.layer.borderWidth = width;
    self.layer.borderColor = color;
}

- (void)cyl_setCornerRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
}

- (CALayer *)cyl_addSubLayerWithFrame:(CGRect)frame color:(CGColorRef)colorRef {
    CALayer *layer = [CALayer layer];
    layer.frame = frame;
    layer.backgroundColor = colorRef;
    [self.layer addSublayer:layer];
    return layer;
}

- (void)cyl_setTarget:(id)target action:(SEL)action {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:recognizer];
}

- (UIImage *)cyl_capture {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(270, self.bounds.size.height), self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
