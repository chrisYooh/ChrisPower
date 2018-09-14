//
//  ChrisMapPathItem.m
//  ChrisPower
//
//  Created by Chris on 14/12/9.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "ChrisMapPathItem.h"

@implementation ChrisMapPathItem
@synthesize pos, direction;

- (NSString *)description
{
    return [NSString stringWithFormat:@"pos = <%f, %f>, direction = %x", pos.x, pos.y, direction];
}

@end
