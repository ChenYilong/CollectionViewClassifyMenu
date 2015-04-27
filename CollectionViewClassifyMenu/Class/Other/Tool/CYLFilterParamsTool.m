
//
//  CYLFilterParamsTool.m
//  PiFuKeYiSheng
//
//  Created by chenyilong on 15/4/22.
//  Copyright (c) 2015年 com.pifukeyisheng. All rights reserved.
//
#define udDoctorFilterSetting @"udDoctorFilterSetting"
#define udDoctorFilterSettingModified @"udDoctorFilterSettingModified"

#import "CYLFilterParamsTool.h"
#import "CYLDBManager.h"

@implementation CYLFilterParamsTool
//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.filterParamsDictionary forKey:@"filterParamsDictionary"];
    [encoder encodeObject:self.filterParamsArray forKey:@"filterParamsArray"];
    [encoder encodeObject:self.filterParamsContentDictionary forKey:@"filterParamsContentDictionary"];
    [encoder encodeObject:self.dataSources forKey:@"dataSources"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
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
 *  懒加载_filterParamsDictionary
 *
 *  @return NSMutableDictionary
 */
- (NSMutableDictionary *)filterParamsDictionary
{
    if (_filterParamsDictionary == nil) {
        _filterParamsDictionary = [[NSMutableDictionary alloc] init];
        _filterParamsDictionary[udDoctorFilterSettingModified] = @(NO);
        _filterParamsDictionary[udDoctorFilterSetting] = self.filterParamsArray;
    }
    return _filterParamsDictionary;
}

/**
 *  懒加载_filterParamsArray
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)filterParamsArray
{
    if (_filterParamsArray == nil) {
        NSMutableArray *state = [NSMutableArray arrayWithObjects:@1, @0,nil];
        NSMutableArray *types = [NSMutableArray arrayWithObject:@(1)];
        NSArray *symptoms = [[CYLDBManager sharedCYLDBManager] getAllSkillTags];
        [symptoms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [types addObject:@0];
        }];
        _filterParamsArray = [NSMutableArray arrayWithArray:@[state, types]];
    }
    return _filterParamsArray;
}

/**
 *  懒加载_filterParamsContentArray
 *
 *  @return NSMutableArray
 */

/**
 *  懒加载_filterParamsContentDictionary
 *
 *  @return NSMutableDictionary
 */
- (NSMutableDictionary *)filterParamsContentDictionary
{
    if (_filterParamsContentDictionary == nil) {
        _filterParamsContentDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        _filterParamsContentDictionary[@"skilled"] = [NSMutableArray array];
    }
    return _filterParamsContentDictionary;
}

/**
 *  懒加载_dataSources
 *
 *  @return NSArray
 */
- (NSArray *)dataSources
{
    if (_dataSources == nil) {
        
        NSMutableArray *hospitals = [NSMutableArray arrayWithObjects:@"全部", @"请选择", nil];
        NSMutableArray *skillTypes = [NSMutableArray arrayWithObject:@"全部"];
        [skillTypes addObjectsFromArray:[[CYLDBManager sharedCYLDBManager] getAllSkillTags]];
        _dataSources = [[NSArray alloc] initWithObjects:hospitals,skillTypes,nil];
    }
    return _dataSources;
}


/**
 *  懒加载_filename
 *
 *  @return NSString
 */
- (NSString *)filename
{
    if (_filename == nil) {
        NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        _filename = [Path stringByAppendingPathComponent:udDoctorFilterSetting];
    }
    return _filename;
}
@end
