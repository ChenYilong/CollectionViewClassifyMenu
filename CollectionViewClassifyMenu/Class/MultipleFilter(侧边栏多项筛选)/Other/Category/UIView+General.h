//
//  UIView+UIViewEXT.h
//  CanXinTong
//
//  Created by  https://github.com/ChenYilong  on 13-2-28.
//  Copyright (c) 2013年  https://github.com/ChenYilong . All rights reserved.
//

#import <UIKit/UIKit.h>
#define LINE_COLOR rgb(198, 200, 199).CGColor
#define QUESTIONDETAIL_LINE_COLOR [UIColor colorWithRed:73/255.0 green:156/255.0 blue:101/255.0 alpha:1].CGColor
#define LINE_COLOR_GREEN [UIColor colorWithRed:90/255.0 green:182/255.0 blue:171/255.0 alpha:1].CGColor //绿线
#define LINE_COLOR_GRAY [UIColor colorWithRed:137/255.0 green:137/255.0 blue:137/255.0 alpha:1].CGColor //边框颜色灰色
#define LINE_VIEW_COLOR [UIColor colorWithRed:138/255.0 green:205/255.0 blue:198/255.0 alpha:1]

@interface UIView (General)

- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;

- (void)setSize:(CGSize)size;

- (CGFloat)height;
- (CGFloat)width;
- (CGFloat)x;
- (CGFloat)y;
- (CGFloat)maxY;
- (CGFloat)maxX;
- (void)horizontalCenterWithWidth:(CGFloat)width;
- (void)verticalCenterWithHeight:(CGFloat)height;
- (void)verticalCenterInSuperView;
- (void)horizontalCenterInSuperView;

- (void)setBoarderWith:(CGFloat)width color:(CGColorRef)color;
- (void)setCornerRadius:(CGFloat)radius;

- (CALayer *)addSubLayerWithFrame:(CGRect)frame color:(CGColorRef)colorRef;


- (void)setTarget:(id)target action:(SEL)action;

- (UIImage *)capture;

@end
