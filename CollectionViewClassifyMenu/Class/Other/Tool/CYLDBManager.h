//
//  CYLDoctorSkillDBManager.h
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by https://github.com/ChenYilong on 15/4/22.
//  Copyright (c) 2015年 (year 2015)  https://github.com/ChenYilong . All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<CollectionViewClassifyMenu/CYLMenuKeys.h>)
#import <CollectionViewClassifyMenu/CYLMenuKeys.h>
#else
#import "CYLMenuKeys.h"
#endif

@interface CYLDBManager : NSObject

+ (NSMutableArray *)dataSource;
+ (NSMutableArray *)allTags;

@end
