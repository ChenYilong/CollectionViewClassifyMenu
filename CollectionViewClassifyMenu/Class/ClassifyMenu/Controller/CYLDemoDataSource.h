#import <Foundation/Foundation.h>
#import "CYLMenuDataSource.h"

@interface CYLDemoDataSource : NSObject <CYLMenuDataSource>

+ (instancetype)classifyDataSource;
+ (instancetype)filterDataSource;

@end
