//
//  DateLimitObject.m
//  ChrisPower
//
//  Created by Chris on 15/1/3.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "DateLimitObject.h"

#import "DynamicLevel.h"

@implementation DateLimitObject
@synthesize valid;

- (id)init
{
    self = [super init];
    
    if (self) {
        valid = NO;
        validEndDate = nil;
    }
    
    return self;
}

- (BOOL)checkObjectValidSetWithDate:(NSDate *)inputDate
{
    if ((NO == valid)
        || (nil == inputDate)
        || (nil != validEndDate && inputDate > validEndDate)) {
        return YES;
    }
    
    return NO;
}

- (void)setObjectValidUntilDate:(NSDate *)endDate
{
    if (NO == [self checkObjectValidSetWithDate:endDate]) {
        return;
    }
    
    validEndDate = endDate;
    valid = YES;
}

- (BOOL)autoSetObjectUnvalid
{
    NSDate *nowDate = [NSDate date];
    
    if ((nil != validEndDate) && (nowDate > validEndDate)) {
        validEndDate = nil;
        valid = NO;
        return YES;
    }
    
    return NO;
}

@end