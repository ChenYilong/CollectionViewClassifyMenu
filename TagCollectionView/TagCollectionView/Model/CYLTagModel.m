//
//  CYLTagModel.m
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CYLTagModel.h"
#import "CYLParameterConfiguration.h"

static CGFloat const kTagTitleFontSize = 17;
static CGFloat const kTagMinimumHeight = 35;
static CGFloat const kTagHorizontalPadding = 50;

@implementation CYLTagModel

+(instancetype)modelWithTitle:(NSString*)title {
    
    CYLTagModel*m=  [[CYLTagModel alloc]init];
    m.title=title; 
    
    return m;
}

-(void)setTitle:(NSString *)title{
    _title=title;

    [self calcuWidth];

}

-(void)calcuWidth{
    [self updateSizeForTraitCollection:nil];
}

+ (UIFont *)titleFontForTraitCollection:(UITraitCollection *)traitCollection {
    return CYLScaledSystemFont(kTagTitleFontSize, traitCollection);
}

- (void)updateSizeForTraitCollection:(UITraitCollection *)traitCollection {
    UIFont *font = [[self class] titleFontForTraitCollection:traitCollection];
    CGSize size = [self.title ?: @"" sizeWithAttributes:@{NSFontAttributeName: font}];
    _width = ceil(size.width) + kTagHorizontalPadding;
    _height = CYLTagHeightForFont(font, kTagMinimumHeight);
}
@end
