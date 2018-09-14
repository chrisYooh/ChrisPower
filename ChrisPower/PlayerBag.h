//
//  PlayerBag.h
//  ChrisPower
//
//  Created by Chris on 15/1/18.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PlayerBagItem.h"

@interface PlayerBag : NSObject
{
    int size;
    
    NSArray *objectArray;
}
@property (nonatomic) int size;
@property (nonatomic) NSArray *objectArray;

- (void)updateObjetArrayWithItem:(PlayerBagItem *)item;

- (NSArray *)towerItems;
- (NSArray *)cannonItems;

@end
