//
//  UIView+General.h
//
//
//  Created by  http://weibo.com/luohanchenyilong/ on 13-2-28.
//  Copyright (c) 2013年  https://github.com/ChenYilong . All rights reserved.
//

#import <UIKit/UIKit.h>
#define LINE_COLOR rgb(198, 200, 199).CGColor
#define QUESTIONDETAIL_LINE_COLOR [UIColor colorWithRed:73/255.0 green:156/255.0 blue:101/255.0 alpha:1].CGColor
#define LINE_COLOR_GREEN [UIColor colorWithRed:90/255.0 green:182/255.0 blue:171/255.0 alpha:1].CGColor //绿线
#define LINE_COLOR_GRAY [UIColor colorWithRed:137/255.0 green:137/255.0 blue:137/255.0 alpha:1].CGColor //边框颜色灰色
#define LINE_VIEW_COLOR [UIColor colorWithRed:138/255.0 green:205/255.0 blue:198/255.0 alpha:1]

@interface UIView (General)

- (void)cyl_setWidth:(CGFloat)width;
- (void)cyl_setHeight:(CGFloat)height;
- (void)cyl_setX:(CGFloat)x;
- (void)cyl_setY:(CGFloat)y;

- (void)cyl_setSize:(CGSize)size;

- (CGFloat)cyl_height;
- (CGFloat)cyl_width;
- (CGFloat)cyl_x;
- (CGFloat)cyl_y;
- (CGFloat)cyl_maxY;
- (CGFloat)cyl_maxX;
- (void)cyl_horizontalCenterWithWidth:(CGFloat)width;
- (void)cyl_verticalCenterWithHeight:(CGFloat)height;
- (void)cyl_verticalCenterInSuperView;
- (void)cyl_horizontalCenterInSuperView;
- (void)cyl_setBoarderWith:(CGFloat)width color:(CGColorRef)color;
- (void)cyl_setCornerRadius:(CGFloat)radius;
- (CALayer *)cyl_addSubLayerWithFrame:(CGRect)frame color:(CGColorRef)colorRef;
- (void)cyl_setTarget:(id)target action:(SEL)action;
- (UIImage *)cyl_capture;

@end
