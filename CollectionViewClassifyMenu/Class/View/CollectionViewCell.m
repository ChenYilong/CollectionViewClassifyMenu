//
//  CollectionViewCell.m
//  CollectionViewClassifyMenu
//
//  Created by chenyilong on 15/3/17.
//  Copyright (c) 2015年 chenyilong. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder: (NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}
- (id)sharedInit {
    [self setup];
    return self;
}

- (void)setup {
    self.button = [CYLIndexPathButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    self.button.layer.cornerRadius = 5.0;
    self.button.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.button setTitleColor:[UIColor colorWithRed:18/255.0 green:133/255.0 blue:117/255.0 alpha:1] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor colorWithRed:18/255.0 green:133/255.0 blue:117/255.0 alpha:0.7] forState:UIControlStateSelected];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    UIImage *imageHighlighted = [[UIImage alloc] init];
    imageHighlighted = [[self class] imageWithColor:[UIColor colorWithRed:18/255.0 green:133/255.0 blue:117/255.0 alpha:1]];
    [self.button setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];

    self.button.backgroundColor = [UIColor whiteColor];
    self.button.layer.borderWidth = 1;
    self.button.layer.masksToBounds = YES;
    self.button.layer.borderColor = [UIColor colorWithRed:18/255.0 green:133/255.0 blue:117/255.0 alpha:1].CGColor;
    [self.contentView addSubview:self.button];
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
