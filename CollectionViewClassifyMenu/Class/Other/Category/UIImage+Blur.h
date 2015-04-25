//
//  UIImage+Blur.h
//  PiFuKeYiSheng
//
//  Created by 喻平 on 14-7-17.
//  Copyright (c) 2014年 com.pifukeyisheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blur)
// 高斯模糊
- (UIImage *)blurredImageWithRadius:(CGFloat)radius
                         iterations:(NSUInteger)iterations
                          tintColor:(UIColor *)tintColor;
@end
