//
//  CYLDoctorSkillDBManager.h
//  PiFuKeYiSheng
//
//  Created by chenyilong on 15/4/22.
//  Copyright (c) 2015年 com.pifukeyisheng. All rights reserved.
//

#define kDataSourceSectionKey                      @"Symptoms"
#define kDataSourceCellTextKey                     @"Food_Name"
#define kDataSourceCellPictureKey                  @"Picture"

#import <Foundation/Foundation.h>

@interface CYLDBManager : NSObject

- (NSMutableArray *)dataSource;
- (NSMutableArray *)allSkills;
+ (id)sharedCYLDBManager;
- (NSArray *)getAllSkillTags;
- (NSArray *)getDataSource;
@end
