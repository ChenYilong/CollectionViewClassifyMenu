//
//  NSArray+log.m
//  
//
//  Created by CHENYI LONG on 14-8-10.
//  Copyright (c) 2014年 CHENYI LONG. All rights reserved.
//

#import "NSArray+log.h"

@implementation NSArray (log)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *str = [NSMutableString stringWithFormat:@"%@ (\n", @(self.count)];
    for (id obj in self) {
        [str appendFormat:@"\t%@,\n", obj];
    }
    [str appendString:@")"];
    return str;
}

@end
