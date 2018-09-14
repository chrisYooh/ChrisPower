//
//  PlayerBagItem.m
//  ChrisPower
//
//  Created by Chris on 15/1/19.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//


#import "ChrisTower.h"
#import "ChrisCannon.h"

#import "PlayerBagItem.h"

static NSComparator compareBlock = ^(PlayerBagItem *obj1,  PlayerBagItem *obj2)
{
    if ( obj1.type > obj2.type) {
        return (NSComparisonResult)NSOrderedDescending;
    } else if ( obj1.type > obj2.type) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    
#if 0
    if (BAG_ITEM_TYPE_TOWER == obj1.type) {
        ChrisTower *tmp1 = obj1.data;
        ChrisTower *tmp2 = obj2.data;
        
        if (tmp1.type > tmp2.type) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if (tmp1.type < tmp2.type) {
            return (NSComparisonResult)NSOrderedAscending;
        }
    } else if (BAG_ITEM_TYPE_CANNON == obj1.type) {
        ChrisCannon *tmp1 = obj1.data;
        ChrisCannon *tmp2 = obj2.data;
        
        if (tmp1.type > tmp2.type) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if (tmp1.type < tmp2.type) {
            return (NSComparisonResult)NSOrderedAscending;
        }
    }
#endif

    return (NSComparisonResult)NSOrderedSame;
};

@implementation PlayerBagItem
@synthesize sortIndex;
@synthesize type;
@synthesize number;
@synthesize data;

+ (NSComparator)comparator
{
    return compareBlock;
}

@end
