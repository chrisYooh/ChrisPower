//
//  NSMutableDictionary+ChrisOperation.m
//  ChrisPower
//
//  Created by Chris on 15/1/1.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "NSMutableDictionary+ChrisOperation.h"

@implementation NSMutableDictionary(ChrisOperation)

- (void)enumItemWithOperationBlock:(void(^)(id))operation
{
    for (id key in self) {
        operation([self objectForKey:key]);
    }
}

- (void)readOnlyEnumArrayItemWithOperationBlock:(void (^)(const id, const NSString *))operation
{
    for (id key in self) {
        
        operation([self objectForKey:key], key);
    }
}

@end
