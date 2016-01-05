//
//  NSDictionary+log.m
//  
//
//  Created by  http://weibo.com/luohanchenyilong/ on 13-2-28.
//  Copyright (c) 2013年  https://github.com/ChenYilong . All rights reserved.
//

#import "NSDictionary+log.h"

@implementation NSDictionary (log)

- (NSString *)descriptionWithLocale:(id)locale {
    NSString *tempStr1 = [[self description] stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    return str;
}

@end
