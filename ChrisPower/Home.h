//
//  Home.h
//  ChrisPower
//
//  Created by Chris on 14/12/16.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameConfig.h"

typedef enum home_status_ {
    HOME_STATUS_PREPARE = 0,
    HOME_STATUS_DEFENCE = 1,
    HOME_STATUS_BEAT_BACK = 2,
    HOME_STATUS_DESTROY = 3,
} home_status_e;

@class Player;

@interface Home : NSObject <NSCoding, GameConfigProtocol>
{
    int gold;
    int healthPoint;
    int magicPoint;
    int armor;
    
    int beatBackPercents;
    
    home_status_e status;
}
@property (nonatomic, readonly) home_status_e status;

@property (nonatomic) int gold;
@property (nonatomic) int healthPoint;
@property (nonatomic) int magicPoint;
@property (nonatomic) int armor;

@property (nonatomic) int beatBackPercents;

- (id)initWithLevelPrimaryIndex:(int)priIndex secondaryIndex:(int)secIndex;

- (int)getHurtWithAttack:(int)atk;
- (void)earnGold:(int)inputGold;
- (BOOL)spendGold:(int)inputGold;

- (void)strengthenWithPlayer:(Player *)player;

@end
