
//
//  CYLFilterParamsTool.m
//  http://cnblogs.com/ChenYilong/
//
//  Created by https://github.com/ChenYilong on 15/4/22.
//  Copyright (c) 2015年  https://github.com/ChenYilong . All rights reserved.
//

#import "CYLFilterParamsTool.h"
#import "CYLDBManager.h"

NSString *const kMultipleFilterSetting         = @"kMultipleFilterSetting";
NSString *const kMultipleFilterSettingModified = @"kMultipleFilterSettingModified";

@implementation CYLFilterParamsTool

//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.filterParamsDictionary forKey:@"filterParamsDictionary"];
    [encoder encodeObject:self.filterParamsArray forKey:@"filterParamsArray"];
    [encoder encodeObject:self.filterParamsContentDictionary forKey:@"filterParamsContentDictionary"];
    [encoder encodeObject:self.dataSources forKey:@"dataSources"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.filterParamsDictionary = [decoder decodeObjectForKey:@"filterParamsDictionary"];
        self.filterParamsArray = [decoder decodeObjectForKey:@"filterParamsArray"];
        self.filterParamsContentDictionary = [decoder decodeObjectForKey:@"filterParamsContentDictionary"];
        self.dataSources = [decoder decodeObjectForKey:@"dataSources"];
    }
    return self;
}

/**
 *  lazy load _filterParamsDictionary
 *
 *  @return NSMutableDictionary
 */
- (NSMutableDictionary *)filterParamsDictionary {
    if (_filterParamsDictionary == nil) {
        _filterParamsDictionary = [[NSMutableDictionary alloc] init];
        _filterParamsDictionary[kMultipleFilterSettingModified] = @(NO);
        _filterParamsDictionary[kMultipleFilterSetting] = self.filterParamsArray;
    }
    return _filterParamsDictionary;
}

/**
 *  lazy load _filterParamsArray
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)filterParamsArray {
    if (_filterParamsArray == nil) {
        NSMutableArray *state = [NSMutableArray arrayWithObjects:@1, @0,nil];
        NSMutableArray *types = [NSMutableArray arrayWithObject:@(1)];
        NSArray *items = [CYLDBManager allTags];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [types addObject:@0];
        }];
        _filterParamsArray = [NSMutableArray arrayWithArray:@[state, types]];
    }
    return _filterParamsArray;
}

/**
 *  lazy load _filterParamsContentDictionary
 *
 *  @return NSMutableDictionary
 */
- (NSMutableDictionary *)filterParamsContentDictionary {
    if (_filterParamsContentDictionary == nil) {
        _filterParamsContentDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        _filterParamsContentDictionary[@"skilled"] = [NSMutableArray array];
    }
    return _filterParamsContentDictionary;
}

/**
 *  lazy load _dataSources
 *
 *  @return NSArray
 */
- (NSArray *)dataSources {
    if (_dataSources == nil) {
        
        NSMutableArray *hospitals = [NSMutableArray arrayWithObjects:@"全部", @"请选择", nil];
        NSMutableArray *skillTypes = [NSMutableArray arrayWithObject:@"全部"];
        [skillTypes addObjectsFromArray:[CYLDBManager allTags]];
        _dataSources = [[NSArray alloc] initWithObjects:hospitals, skillTypes, nil];
    }
    return _dataSources;
}

/**
 *  lazy load _filename
 *
 *  @return NSString
 */
- (NSString *)filename {
    if (_filename == nil) {
        NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _filename = [Path stringByAppendingPathComponent:kMultipleFilterSetting];
    }
    return _filename;
}

@end
