//
//  NSMutableDictionary+ChrisOperation.h
//  ChrisPower
//
//  Created by Chris on 15/1/1.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary(ChrisOperation)

- (void)enumItemWithOperationBlock:(void(^)(id))operation;

- (void)readOnlyEnumArrayItemWithOperationBlock:(void(^)(const id, const NSString *))operation;

@end
