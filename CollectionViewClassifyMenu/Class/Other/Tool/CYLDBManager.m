//
//  CYLDoctorSkillDBManager.m
//  http://cnblogs.com/ChenYilong/
//
//  Created by https://github.com/ChenYilong on 15/4/22.
//  Copyright (c) 2015年  https://github.com/ChenYilong . All rights reserved.
//

#import "CYLDBManager.h"

NSString *const kDataSourceSectionKey     = @"Items";
NSString *const kDataSourceCellTextKey    = @"Item_Title";
NSString *const kDataSourceCellPictureKey = @"Picture";

@implementation CYLDBManager

/**
 *  lazy load _dataSource
 *
 *  @return NSMutableArray
 */
+ (NSMutableArray *)dataSource {
    static NSMutableArray * dataSource = nil;
    static dispatch_once_t dataSourceOnceToken;
    dispatch_once(&dataSourceOnceToken, ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data.json" ofType:nil];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        NSError *error;
        if (data) {
            dataSource = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        }
    });
    return dataSource;
}

/**
 *  lazy load _allTags
 *
 *  @return NSMutableArray
 */
+ (NSMutableArray *)allTags {
    static NSMutableArray * allTags = nil;
    static dispatch_once_t allTagsOnceToken;
    dispatch_once(&allTagsOnceToken, ^{
        allTags = [NSMutableArray array];
        [[[self class] dataSource] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSArray *items = [NSArray arrayWithArray:[obj objectForKey:kDataSourceSectionKey]];
                [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [allTags addObject:[obj objectForKey:kDataSourceCellTextKey]];
                }];
        }];
    });
    return allTags;
}

@end
