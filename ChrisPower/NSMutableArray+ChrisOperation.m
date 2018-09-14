//
//  NSMutableArray+ChrisOperation.m
//  ChrisPower
//
//  Created by Chris on 14/12/17.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "NSMutadbleArray+ChrisOperation.h"

@implementation NSMutableArray(ChrisOperation)

- (void)enumArrayItemWithOperationBlock:(void(^)(id))operation
{
    for (id item in self) {
        operation(item);
    }
}

- (void)safeEnumArrayItemWithOperationBlock:(BOOL(^)(id))isRemove
{
    int itemNumber = (int)[self count];
    
    for (int i = 0, j = 0; i < itemNumber; i++, j++) {
        id item = [self objectAtIndex:j];
        
        if (YES == isRemove(item)) {
            [self removeObjectAtIndex:j];
            j--;
        }
    }
}

@end
