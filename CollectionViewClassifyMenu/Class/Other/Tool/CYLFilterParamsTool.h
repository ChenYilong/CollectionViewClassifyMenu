//
//  CYLFilterParamsTool.h
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by https://github.com/ChenYilong on 15/4/22.
//  Copyright (c) 2015年  https://github.com/ChenYilong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYLFilterParamsTool : NSObject
@property (nonatomic, strong) NSMutableDictionary *filterParamsDictionary;
@property (nonatomic, strong) NSMutableArray *filterParamsArray;
@property (nonatomic, strong) NSMutableDictionary *filterParamsContentDictionary;
@property (nonatomic, strong) NSArray *dataSources;
@property (nonatomic, strong) NSString *filename;

@end
