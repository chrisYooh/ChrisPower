//
//  Game.m
//  ChrisPower
//
//  Created by Chris on 14/12/16.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "NSMutadbleArray+ChrisOperation.h"

#import "Player.h"

#import "ChrisMap.h"
#import "ChrisMapBox.h"
#import "ChrisMonster.h"
#import "ChrisTower.h"
#import "ChrisCannon.h"
#import "Level.h"
#import "Home.h"
#import "Waves.h"
#import "WaveItem.h"

#import "Game.h"

@implementation Game
@synthesize delegate;

@synthesize currentLevelPrimaryIndex;
@synthesize currentLevelSecondaryIndex;

@synthesize totalMonsterKilledNumber;
@synthesize totalMissedMonster;
@synthesize totalMissedMonsterDemage;

@synthesize totalExperienceGot;
@synthesize totalGoldGot;

@synthesize totalMonsterCreatedNumber;
@synthesize totalTowerCreatedNumber;
@synthesize totalCannonCareateNumber;

@synthesize home;
@synthesize map;
@synthesize currentWaveIndex;
@synthesize wavesInfo;

- (id)init
{
    self = [super init];
    if (self) {
        monsterArray = [[NSMutableArray alloc] init];
        monsterNormalDrawArray = [[NSMutableArray alloc] init];
        monsterUpDrawArray = [[NSMutableArray alloc] init];
        towerArray = [[NSMutableArray alloc] init];
        cannonArray = [[NSMutableArray alloc] init];
        
        monsterDrawArrayLocker = [[NSLock alloc] init];
        towerDrawArrayLocker = [[NSLock alloc] init];
        cannonDrawArrayLocker = [[NSLock alloc] init];
        
        home = [[Home alloc] init];
        map = [[ChrisMap alloc] init];
        wavesInfo = [[Waves alloc] init];
        
        [self reset];
    }
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (void)reset
{
    /* Whole Game */
    totalExperienceGot = 0;
    totalGoldGot = 0;
    
    totalMonsterKilledNumber = 0;
    totalMissedMonster = 0;
    totalMissedMonsterDemage = 0;
    
    totalMonsterCreatedNumber = 0;
    totalTowerCreatedNumber = 0;
    totalCannonCareateNumber = 0;
    
    /* Cannon */
    [cannonDrawArrayLocker lock];
    [cannonArray removeAllObjects];
    [cannonDrawArrayLocker unlock];
    
    /* Tower */
    [towerDrawArrayLocker lock];
    for (ChrisTower *tower in towerArray) {
        [[tower locatedMapBox] setTower:nil];
    }
    [towerArray removeAllObjects];
    [towerDrawArrayLocker unlock];
    
    /* Monster */
    for (ChrisMonster *monster in monsterArray) {
        [[monster locatedMapBox] removeMonster:monster];
    }
    [monsterDrawArrayLocker lock];
    [monsterNormalDrawArray removeAllObjects];
    [monsterUpDrawArray removeAllObjects];
    [monsterDrawArrayLocker unlock];
    
    [monsterArray removeAllObjects];
    
    Level *tmpLevel = [[GameConfig globalConfig] getCurrentTemplateLevelFromStore];
    
    currentLevelPrimaryIndex = tmpLevel.primaryIndex;
    currentLevelSecondaryIndex = tmpLevel.secondaryIndex;
    
    /* Home */
    [home updateWithInstance:tmpLevel.home];
    [home strengthenWithPlayer:[Player currentPlayer]];
    
    /* Map */
    [map updateWithInstance:tmpLevel.map];
    [map extraInit];
    
    CGRect wholeWindow = [UIScreen mainScreen].bounds;
    CGRect mapRect = map.frame;
    CGPoint newMapOrigin = map.frame.origin;
    if (mapRect.size.width < wholeWindow.size.width) {
        newMapOrigin.x = (int)((wholeWindow.size.width - mapRect.size.width) / 2);
    }
    
    if (mapRect.size.height < wholeWindow.size.height) {
        newMapOrigin.y = (int)((wholeWindow.size.height - mapRect.size.height) / 2);
    }
    
    if (newMapOrigin.y < 60) {
        newMapOrigin.y = 60;
    }
    [map updateMapFrameOrigin:newMapOrigin];
    
    /* Wave */
    currentWaveIndex = 0;
    [wavesInfo updateWithInstance:tmpLevel.waves];
}

#pragma mark Wave Operation
- (const WaveItem *)currentWave
{
    return [wavesInfo getWaveByIndex:currentWaveIndex];
}

- (BOOL)nextWave
{
    if (0 >= [monsterArray count]) {
        currentWaveIndex++;
        return YES;
    }
    
    return NO;
}

#pragma mark Monster array operation
- (int)addMonster:(ChrisMonster *)monster
{
    [monsterArray addObject:monster];
    
    [monsterDrawArrayLocker lock];
    [monsterNormalDrawArray insertObject:monster atIndex:0];
    [monsterDrawArrayLocker unlock];
    
    totalMonsterCreatedNumber++;
    
    return 0;
}

- (void)removeMonster:(ChrisMonster *)monster
{
    [monsterDrawArrayLocker lock];
    [monsterNormalDrawArray removeObject:monster];
    [monsterDrawArrayLocker unlock];
    
    [monsterDrawArrayLocker lock];
    [monsterUpDrawArray removeObject:monster];
    [monsterDrawArrayLocker unlock];
}

- (void)monsterBeKilled:(ChrisMonster *)monster
{
//    currentGold += 1;
    
    totalMonsterKilledNumber++;
    totalExperienceGot += 1;
    totalGoldGot += 1;
    return;
}

- (void)monsterAttack:(ChrisMonster *)monster
{
//    currentHealthPoint -= 1;
    
    totalMissedMonster++;
    totalMissedMonsterDemage += 1;
    
    return;
}

- (int)monsterMoveToNormalDrawArray:(ChrisMonster *)monster
{
    [monsterDrawArrayLocker lock];
    [monsterNormalDrawArray insertObject:monster atIndex:0];
    [monsterUpDrawArray removeObject:monster];
    [monsterDrawArrayLocker unlock];
    
    return 0;
}

- (int)monsterMoveToUpDrawArray:(ChrisMonster *)monster
{
    [monsterDrawArrayLocker lock];
    [monsterUpDrawArray addObject:monster];
    [monsterNormalDrawArray removeObject:monster];
    [monsterDrawArrayLocker unlock];
    
    return 0;
}

- (ChrisMonster *)monsterAtIndex:(int)index
{
    return [monsterArray objectAtIndex:index];
}

- (void)monstersEnumWithOperation:(void (^)(ChrisMonster *))singleMonsterOperation
{
    [monsterArray enumArrayItemWithOperationBlock:singleMonsterOperation];
}

- (void)monstersSafeEnumWithOperation:(BOOL (^)(ChrisMonster *))monsterBlock
{
    BOOL(^enumBlock)(ChrisMonster *) = ^(ChrisMonster *monster) {
        if (YES == monsterBlock(monster)) {
            [self removeMonster:monster];
            return YES;
        }
        
        return NO;
    };
    
    [monsterArray safeEnumArrayItemWithOperationBlock:enumBlock];
}

- (void)monstersDrawOrderEnumWithOperation:(void (^)(ChrisMonster *))singleMonsterDrawOperation
{
    [monsterDrawArrayLocker lock];
    for (ChrisMonster *monster in monsterNormalDrawArray) {
        singleMonsterDrawOperation(monster);
    }
    
    for (ChrisMonster *monster in monsterUpDrawArray) {
        singleMonsterDrawOperation(monster);
    }
    [monsterDrawArrayLocker unlock];
}

#pragma mark Tower array operation
- (int)addTower:(ChrisTower *)tower
{
    [towerDrawArrayLocker lock];
    [towerArray addObject:tower];
    [towerDrawArrayLocker unlock];
    
    totalTowerCreatedNumber++;
    
    return 0;
}

- (void)towersEnumWithOperation:(void(^)(ChrisTower *))singleTowerOperation
{
    [towerDrawArrayLocker lock];
    [towerArray enumArrayItemWithOperationBlock:singleTowerOperation];
    [towerDrawArrayLocker unlock];
}

- (void)towersSafeEnumWithOperation:(BOOL(^)(ChrisTower *))singleTowerOperation
{
    [towerDrawArrayLocker lock];
    [towerArray safeEnumArrayItemWithOperationBlock:singleTowerOperation];
    [towerDrawArrayLocker unlock];
}

- (void)towersDrawOrderEnumWithOperation:(void (^)(ChrisTower *))singleTowerDrawOperation
{
    [self towersEnumWithOperation:singleTowerDrawOperation];
}

- (int)towerCurrentNumber
{
    return (int)towerArray.count;
}

- (NSArray *)copiedTowerArray
{
    NSArray *tmpArray = nil;
    
    [towerDrawArrayLocker lock];
    tmpArray = [NSArray arrayWithArray:towerArray];
    NSLog(@"Copy tower array for use.\n");
    [towerDrawArrayLocker unlock];
    
    return tmpArray;
}

#pragma mark Cannon array operations
- (int)addCannon:(ChrisCannon *)cannon
{
    [cannonDrawArrayLocker lock];
    [cannonArray addObject:cannon];
    [cannonDrawArrayLocker unlock];
    
    totalCannonCareateNumber++;
    
    return 0;
}

- (void)cannonsEnumWithOperation:(void(^)(ChrisCannon *))singleCannonOperation
{
    [cannonDrawArrayLocker lock];
    [cannonArray enumArrayItemWithOperationBlock:singleCannonOperation];
    [cannonDrawArrayLocker unlock];
}

- (void)cannonsSafeEnumWithOperation:(BOOL(^)(ChrisCannon *))singleCannonOperation
{
    [cannonDrawArrayLocker lock];
    [cannonArray safeEnumArrayItemWithOperationBlock:singleCannonOperation];
    [cannonDrawArrayLocker unlock];
}

- (void)cannonsDrawOrderEnumWithOperation:(void (^)(ChrisCannon *))singleCannonDrawOperation
{
    [self cannonsEnumWithOperation:singleCannonDrawOperation];
}

#pragma mark Game operating
- (void)nextPiece
{
    [self monstersNextPiece];
    [self towersNextPiece];
    [self cannonsNextPiece];
    [self homeNextPiece];
    [self waveNextPiece];
}

- (void)monstersNextPiece
{
    [self monstersSafeEnumWithOperation:^(ChrisMonster *monster) {
        BOOL retValue = NO;
        
        if (MONSTER_STATUS_REMOVED == [monster status]) {
            retValue = YES;
        }
        
        [[self delegate] Game:self monsterWillGoToNextPiece:monster];
        [monster selfStatusHandle];
        [[self delegate] Game:self monsterDidGoneToNextPiece:monster];
        return retValue;
    }];
}

- (void)towersNextPiece
{
    [self towersSafeEnumWithOperation:^(ChrisTower *tower) {
        BOOL retValue = NO;
        
        if (TOWER_STATUS_REMOVE == [tower status]) {
            retValue = YES;
        }
        
        [[self delegate] Game:self towerWillGoToNextPiece:tower];
        [tower selfStatusHandle];
        [[self delegate] Game:self towerDidGoneToNextPiece:tower];
        return retValue;
    }];
}

- (void)cannonsNextPiece
{
    [self cannonsSafeEnumWithOperation:^(ChrisCannon *cannon) {
        BOOL retValue = NO;
        
        if (CANNON_STATUS_REMOVE == [cannon status]) {
            retValue = YES;
        }
        
        [[self delegate] Game:self cannonWillGoToNextPiece:cannon];
        [cannon selfStatusHandle];
        [[self delegate] Game:self cannonDidGoneToNextPiece:cannon];
        return retValue;
    }];
}

- (void)homeNextPiece
{
    
}

- (void)waveNextPiece
{
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:

            @"Current wave index %d\n"
            
            "monster killed number: %d\n"
            "monster missed number: %d\n"
            
            "monster demage: %d\n"
            "monster experiences: %d\n"
            "monster gold: %d\n"
            
            "monster number: %d/%d\n"
            "tower number: %d/%d\n"
            "cannon number: %d/%d\n",
           
            currentWaveIndex,
            
            totalMonsterKilledNumber,
            totalMissedMonster,
            
            totalMissedMonsterDemage,
            totalExperienceGot,
            totalGoldGot,
            
            (int)monsterArray.count, totalMonsterCreatedNumber,
            (int)towerArray.count, totalTowerCreatedNumber,
            (int)cannonArray.count, totalCannonCareateNumber];
}

@end
