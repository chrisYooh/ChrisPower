//
//  PlayerBag.m
//  ChrisPower
//
//  Created by Chris on 15/1/18.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "PlayerBag.h"

@implementation PlayerBag
@synthesize size;
@synthesize objectArray;

- (void)updateObjetArrayWithItem:(PlayerBagItem *)item
{
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:objectArray];
    
    [tmpArray addObject:item];
    
    objectArray = [tmpArray sortedArrayUsingComparator:[PlayerBagItem comparator]];
}

- (NSArray *)towerItems
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    
    for (PlayerBagItem *item in objectArray) {
        if (BAG_ITEM_TYPE_TOWER == item.type) {
            [tmpArray addObject:item];
        }
    }
    
    return [NSArray arrayWithArray:tmpArray];
}

- (NSArray *)cannonItems
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    
    for (PlayerBagItem *item in objectArray) {
        if (BAG_ITEM_TYPE_CANNON == item.type) {
            [tmpArray addObject:item];
        }
    }
    
    return [NSArray arrayWithArray:tmpArray];
}

@end
