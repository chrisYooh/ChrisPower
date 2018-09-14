//
//  Game.h
//  ChrisPower
//
//  Created by Chris on 14/12/16.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChrisMap;
@class ChrisMonster;
@class ChrisTower;
@class ChrisCannon;
@class Home;
@class Waves;
@class WaveItem;
@class Game;

enum {
    MONSTER_TRAVERSE_ORDER_NORMAL = 0,
    MONSTER_TRAVERSE_ORDER_DRAW = 1,
};

@protocol GameDelegate <NSObject>

@optional
- (void)Game:(Game *)game monsterWillGoToNextPiece:(ChrisMonster *)monster;
- (void)Game:(Game *)game monsterDidGoneToNextPiece:(ChrisMonster *)monster;

- (void)Game:(Game *)game towerWillGoToNextPiece:(ChrisTower *)tower;
- (void)Game:(Game *)game towerDidGoneToNextPiece:(ChrisTower *)tower;

- (void)Game:(Game *)game cannonWillGoToNextPiece:(ChrisCannon *)cannon;
- (void)Game:(Game *)game cannonDidGoneToNextPiece:(ChrisCannon *)cannon;

@end

@interface Game : NSObject
{
    int currentLevelPrimaryIndex;
    int currentLevelSecondaryIndex;
    
    /* Monster, Tower, Cannon */
    NSMutableArray *monsterArray;
    NSMutableArray *monsterNormalDrawArray;
    NSMutableArray *monsterUpDrawArray;
    
    NSMutableArray *towerArray;
    NSMutableArray *cannonArray;
    
    NSLock *monsterDrawArrayLocker;
    NSLock *towerDrawArrayLocker;
    NSLock *cannonDrawArrayLocker;
    
    /* Home */
    Home *home;
    
    /* Map */
    ChrisMap *map;
    
    /* Wave */
    int currentWaveIndex;
    Waves *wavesInfo;
}
@property (nonatomic, weak) id<GameDelegate> delegate;

/* Whole Game */
@property (nonatomic, readonly) int currentLevelPrimaryIndex;
@property (nonatomic, readonly) int currentLevelSecondaryIndex;
@property (nonatomic, readonly) int totalExperienceGot;
@property (nonatomic, readonly) int totalGoldGot;

/* Monster, Tower, Cannon */
@property (nonatomic, readonly) int totalMonsterKilledNumber;
@property (nonatomic, readonly) int totalMissedMonster;
@property (nonatomic, readonly) int totalMissedMonsterDemage;

@property (nonatomic, readonly) int totalMonsterCreatedNumber;
@property (nonatomic, readonly) int totalTowerCreatedNumber;
@property (nonatomic, readonly) int totalCannonCareateNumber;

/* Home */
@property (nonatomic, retain) Home *home;

/* Map */
@property (nonatomic, retain) ChrisMap *map;

/* Wave */
@property (nonatomic) int currentWaveIndex;
@property (nonatomic, retain) Waves *wavesInfo;

- (void)reset;

/* Wave operation */
- (WaveItem *)currentWave;
- (BOOL)nextWave;

/* Monster operation */
- (int)addMonster:(ChrisMonster *)monster;

- (void)monsterBeKilled:(ChrisMonster *)monster;
- (void)monsterAttack:(ChrisMonster *)monster;

- (int)monsterMoveToNormalDrawArray:(ChrisMonster *)monster;
- (int)monsterMoveToUpDrawArray:(ChrisMonster *)monster;

- (ChrisMonster *)monsterAtIndex:(int)index;

- (void)monstersDrawOrderEnumWithOperation:(void(^)(ChrisMonster *))singleMonsterDrawOperation;
- (void)monstersEnumWithOperation:(void(^)(ChrisMonster *))singleMonsterOperation;
- (void)monstersSafeEnumWithOperation:(BOOL(^)(ChrisMonster *))singleMonsterOperation;

/* Tower operation */
- (int)addTower:(ChrisTower *)tower;

- (void)towersEnumWithOperation:(void(^)(ChrisTower *))singleTowerOperation;
- (void)towersSafeEnumWithOperation:(BOOL(^)(ChrisTower *))singleTowerOperation;
- (void)towersDrawOrderEnumWithOperation:(void(^)(ChrisTower *))singleTowerDrawOperation;
- (int)towerCurrentNumber;
- (NSArray *)copiedTowerArray;

/* Cannon operation */
- (int)addCannon:(ChrisCannon *)cannon;

- (void)cannonsEnumWithOperation:(void(^)(ChrisCannon *))singleCannonOperation;
- (void)cannonsSafeEnumWithOperation:(BOOL(^)(ChrisCannon *))singleCannonOperation;
- (void)cannonsDrawOrderEnumWithOperation:(void(^)(ChrisCannon *))singleCannonDrawOperation;

- (void)nextPiece;

@end

















