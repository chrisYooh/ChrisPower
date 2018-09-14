//
//  NSMutableArray+ChrisOperation.h
//  ChrisPower
//
//  Created by Chris on 14/12/17.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray(ChrisOperation)

- (void)enumArrayItemWithOperationBlock:(void(^)(id))operation;
- (void)safeEnumArrayItemWithOperationBlock:(BOOL(^)(id))isRemove;

@end
