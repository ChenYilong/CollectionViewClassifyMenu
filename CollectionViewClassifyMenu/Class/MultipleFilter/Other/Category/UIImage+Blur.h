//
//  UIImage+Blur.h
//  http://cnblogs.com/ChenYilong/
//
//  Created by  https://github.com/ChenYilong  on 14-7-17.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blur)

// 高斯模糊
- (UIImage *)cyl_blurredImageWithRadius:(CGFloat)radius
                             iterations:(NSUInteger)iterations
                              tintColor:(UIColor *)tintColor;

@end
