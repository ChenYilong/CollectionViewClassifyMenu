//
//  UIView+UIViewEXT.m
//  CanXinTong
//
//  Created by  https://github.com/ChenYilong  on 13-2-28.
//  Copyright (c) 2013年  https://github.com/ChenYilong . All rights reserved.
//

#import "UIView+General.h"

@implementation UIView (General)

- (void)setWidth:(CGFloat)width
{
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}
- (void)setHeight:(CGFloat)height
{
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}
- (void)setX:(CGFloat)x
{
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}
- (void)setY:(CGFloat)y
{
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}
- (CGFloat)x
{
    return self.frame.origin.x;
}
- (CGFloat)y
{
    return self.frame.origin.y;
}
- (CGFloat)height
{
    return self.frame.size.height;
}
- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)maxY
{
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)maxX
{
    return CGRectGetMaxX(self.frame);
}

- (void)setSize:(CGSize)size
{
    CGRect rect = self.frame;
    rect.size = size;
    self.frame = rect;
}

- (void)horizontalCenterWithWidth:(CGFloat)width
{
    [self setX:ceilf((width - self.width) / 2)];
}

- (void)verticalCenterWithHeight:(CGFloat)height
{
    [self setY:ceilf((height - self.height) / 2)];
}
- (void)verticalCenterInSuperView
{
    [self verticalCenterWithHeight:self.superview.height];
}
- (void)horizontalCenterInSuperView
{
    [self horizontalCenterWithWidth:self.superview.width];
}

- (void)setBoarderWith:(CGFloat)width color:(CGColorRef)color
{
    self.layer.borderWidth = width;
    self.layer.borderColor = color;
}
- (void)setCornerRadius:(CGFloat)radius
{
    self.layer.cornerRadius = radius;
}

- (CALayer *)addSubLayerWithFrame:(CGRect)frame color:(CGColorRef)colorRef
{
    CALayer *layer = [CALayer layer];
    layer.frame = frame;
    layer.backgroundColor = colorRef;
    [self.layer addSublayer:layer];
    return layer;
}

- (void)setTarget:(id)target action:(SEL)action
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:recognizer];
}

- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(270, self.bounds.size.height), self.opaque, 0.0);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
