//
//  Level.h
//  ChrisPower
//
//  Created by Chris on 14/12/16.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameConfig.h"

#define LEVEL_WAVE_NUMBER_MAX   20

@class ChrisMap;
@class Home;
@class Waves;

enum {
    INITIAL_LEVEL_PRIMARY_INDEX = 1,
    TEACH_LEVEL_PIRMARY_INDEX = 100,
    USER_CREATE_LEVEL_PRIMARY_INDEX = 99,
    TEST_LEVEL_PRIMARY_INDEX = 999,
};

@interface Level : NSObject <NSCoding, GameConfigProtocol>
{
    int primaryIndex;
    int secondaryIndex;
    
    int type;
    
    /* Map */
    ChrisMap *map;
    
    /* Home */
    Home *home;
    
    /* Waves */
    Waves *waves;
    
    /* Limit */
    int monsterExistNumberMax;
    int towerExistNumberMax;
}
@property (nonatomic) int primaryIndex;
@property (nonatomic) int secondaryIndex;

@property (nonatomic) int type;

@property (nonatomic, retain) ChrisMap *map;
@property (nonatomic, retain) Home *home;
@property (nonatomic, retain) Waves *waves;

@property (nonatomic) int monsterExistNumberMax;
@property (nonatomic) int towerExistNumberMax;

+ (NSString *)levelKeyWithPrimaryIndex:(int)priLevel secondaryIndex:(int)secLevel;

- (void)extraInit;

@end
