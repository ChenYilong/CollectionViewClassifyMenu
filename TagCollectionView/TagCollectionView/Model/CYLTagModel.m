//
//  CYLTagModel.m
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CYLTagModel.h"

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
    
    _height=35;
    
    float fontSize=17;

    CGSize size= [self.title  sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} ];

    
    _width=size.width+50;
    
}
@end
