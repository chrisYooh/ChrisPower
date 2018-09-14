//
//  PlayerBagItem.h
//  ChrisPower
//
//  Created by Chris on 15/1/19.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    BAG_ITEM_NUMBER_UNLIMIT = -1,
};

enum {
    BAG_ITEM_TYPE_TOWER = 0,
    BAG_ITEM_TYPE_CANNON = 1,
};

@interface PlayerBagItem : NSObject
{
    /* Sygn the data type */
    int type;
    
    /* One bag item save one type, but the type may has a number limit */
    int number;
    
    /* The data may be Tower, Cannon... 
     * The real data saved in GameConfig */
    __weak id data;
}
@property (nonatomic) int sortIndex;
@property (nonatomic) int type;
@property (nonatomic) int number;
@property (nonatomic, weak) id data;

+ (NSComparator)comparator;

@end
