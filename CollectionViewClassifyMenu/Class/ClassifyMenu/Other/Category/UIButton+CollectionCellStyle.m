//
//  UIButton+CollectionCellStyle.m
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/4/2.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//

#import "UIButton+CollectionCellStyle.h"

@implementation UIButton (CollectionCellStyle)

- (void)generalStyle {
    self.layer.cornerRadius = 5.0;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 1;
    self.layer.masksToBounds = YES;
}

- (void)homeStyle {
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self setTitleColor:[UIColor colorWithRed:18/255.0 green:133/255.0 blue:117/255.0 alpha:1] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithRed:18/255.0 green:133/255.0 blue:117/255.0 alpha:0.7] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    UIImage *imageHighlighted = [[self class] imageWithColor:[UIColor colorWithRed:18/255.0 green:133/255.0 blue:117/255.0 alpha:1]];
    [self setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    self.layer.borderColor = [UIColor colorWithRed:18/255.0 green:133/255.0 blue:117/255.0 alpha:1].CGColor;
}

- (void)redStyle {
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self setTitleColor:[UIColor colorWithRed:160/255.0 green:15/255.0 blue:85/255.0 alpha:1] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    UIImage *imageHighlighted  = [[self class] imageWithColor:[UIColor colorWithRed:18/255.0 green:133/255.0 blue:117/255.0 alpha:1]];
    [self setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    self.layer.borderColor = [UIColor colorWithRed:160/255.0 green:15/255.0 blue:85/255.0 alpha:1].CGColor ;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
