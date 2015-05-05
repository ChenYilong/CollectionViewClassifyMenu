//
//  CYLDoctorSkillDBManager.h
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by https://github.com/ChenYilong on 15/4/22.
//  Copyright (c) 2015年  https://github.com/ChenYilong . All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kDataSourceSectionKey;
extern NSString *const kDataSourceCellTextKey;
extern NSString *const kDataSourceCellPictureKey;

@interface CYLDBManager : NSObject

+ (NSMutableArray *)dataSource;
+ (NSMutableArray *)allTags;

@end
