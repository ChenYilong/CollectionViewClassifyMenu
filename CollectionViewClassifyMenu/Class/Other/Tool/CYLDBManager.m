//
//  CYLDoctorSkillDBManager.m
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by https://github.com/ChenYilong on 15/4/22.
//  Copyright (c) 2015年  https://github.com/ChenYilong . All rights reserved.
//

#import "CYLDBManager.h"

NSString *const kDataSourceSectionKey     = @"Symptoms";
NSString *const kDataSourceCellTextKey    = @"Food_Name";
NSString *const kDataSourceCellPictureKey = @"Picture";

@interface CYLDBManager()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *allSkills;

@end

@implementation CYLDBManager

@synthesize dataSource = _dataSource;
@synthesize allSkills = _allSkills;

+ (id)sharedCYLDBManager
{
    static dispatch_once_t onceQueue;
    static CYLDBManager *cYLDBManager = nil;
    
    dispatch_once(&onceQueue, ^{ cYLDBManager = [[self alloc] init]; });
    return cYLDBManager;
}


- (NSArray *)getDataSource {
    return (NSArray *)self.dataSource;
}

- (NSArray *)getAllSkillTags {
    return (NSArray *)self.allSkills;
}
/**
 *  懒加载_dataSource
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data.json" ofType:nil];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        NSError *error;
        if (data) {
            _dataSource = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        }
    }
    return _dataSource;
}

/**
 *  懒加载_allSkills
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)allSkills
{
    if (_allSkills == nil) {
        _allSkills = [[NSMutableArray alloc] init];
        __weak __typeof(self) weakSelf = self;
        [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            @autoreleasepool {
                NSArray *symptoms = [NSArray arrayWithArray:[obj objectForKey:kDataSourceSectionKey]];
                [symptoms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf->_allSkills addObject:[obj objectForKey:kDataSourceCellTextKey]];
                }];
            }
        }];
    }
    return _allSkills;
}

@end
