//
//  GameConfig.m
//  ChrisPower
//
//  Created by Chris on 14/12/23.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "NSMutableDictionary+ChrisOperation.h"
#import "MapTemplates.h"

#import "Player.h"
#import "DynamicLevel.h"

#import "ChrisMap.h"
#import "ChrisMonster.h"
#import "ChrisTower.h"
#import "ChrisCannon.h"
#import "Level.h"
#import "Home.h"
#import "Waves.h"

#import "GameConfig.h"

static GameConfig *globalConfig = nil;

@implementation GameConfig
@synthesize currentPlayerId;
@synthesize currentLevelPrimaryType;
@synthesize currentLevelSecondaryType;

@synthesize majorObject, majorIndex;

- (void)createSingleLevelWithPrimaryIndex:(int)priIndex
                           secondaryIndex:(int)secIndex
                                 mapWidth:(int)width
                                mapHeight:(int)height
                                 tmpArray:(int[])array
{
    Level *level = nil;
    ChrisMap *map = nil;
    Home *home = nil;
    Waves *waves = nil;
    /* Map Home Wave Limit */
    
    /* Level 1-1 */
    level = [[Level alloc] init];
    [level setPrimaryIndex:priIndex];
    [level setSecondaryIndex:secIndex];
    
    /* Map Setting */
    map = [[ChrisMap alloc] initWithMapBoxColNumber:width rolNumber:height];
    [map updateMapInfoWithInfo:array itemNumber:width * height];
    [level setMap:map];
    
    /* Home Setting */
    home = [[Home alloc] initWithLevelPrimaryIndex:priIndex secondaryIndex:secIndex];
    [level setHome:home];
    
    /* Wave Setting */
    waves = [[Waves alloc] initWithLevelPrimaryIndex:priIndex secondaryIndex:secIndex];
    [level setWaves:waves];
    
    /* Limit */
    [level setMonsterExistNumberMax:30];
    [level setTowerExistNumberMax:20];
    [self updateStoreWithLevel:level];
}

- (void)initTestLevels
{
    /* Create classical level */
    for (int i = 0; i < INITIAL_LEVEL_NUMBER; i++) {
        [self createSingleLevelWithPrimaryIndex:1 secondaryIndex:i + 1
                                       mapWidth:initialMapInfo[i].width
                                      mapHeight:initialMapInfo[i].height
                                       tmpArray:initialMapInfo[i].mapArray];
    }
    
    /* Create Teach level */
    for (int i = 0; i < TEACH_LEVEL_NUMBER; i++) {
        [self createSingleLevelWithPrimaryIndex:TEACH_LEVEL_PIRMARY_INDEX secondaryIndex:i + 1
                                       mapWidth:teachMapInfo[i].width
                                      mapHeight:teachMapInfo[i].height
                                       tmpArray:teachMapInfo[i].mapArray];
    }
}

- (void)addSingleTestMonsterWithType:(int)type
                         healthPoint:(int)hp
                               armor:(int)armor
                           moveSpeed:(int)speed
                           goldAward:(int)award
{
    ChrisMonster *monster = nil;
    
    monster = [[ChrisMonster alloc] init];
    [monster setType:type];
    [monster setHealthPointMax:hp];
    [monster setArmor:armor];
    [monster setMoveSpeed:speed];
    [monster setKilledGoldAward:award];
    [monster createImage];
    [self updateStoreWithMonster:monster];
    
}

- (void)initTestMonsters
{
    [self addSingleTestMonsterWithType:1 healthPoint:100 armor:1 moveSpeed:1 goldAward:1];
    [self addSingleTestMonsterWithType:2 healthPoint:500 armor:3 moveSpeed:2 goldAward:5];
    [self addSingleTestMonsterWithType:3 healthPoint:1500 armor:10 moveSpeed:1 goldAward:9];
    [self addSingleTestMonsterWithType:4 healthPoint:300 armor:0 moveSpeed:3 goldAward:4];
    [self addSingleTestMonsterWithType:5 healthPoint:500 armor:3 moveSpeed:5 goldAward:16];
    [self addSingleTestMonsterWithType:6 healthPoint:600 armor:5 moveSpeed:3 goldAward:11];
    [self addSingleTestMonsterWithType:7 healthPoint:3000 armor:15 moveSpeed:2 goldAward:37];
    [self addSingleTestMonsterWithType:8 healthPoint:1800 armor:5 moveSpeed:4 goldAward:46];
}

- (void)addSingleTowerWithType:(int)type
                        attack:(int)atk
                            ig:(int)ig
                      interval:(int)interval
                        radius:(int)radius
                          spUp:(int)spUp
                          cost:(int)cost
                      luUpCost:(int)lucCost
{
    ChrisTower *tower = [[ChrisTower alloc] init];
    [tower setType:type];
    [tower setAttack:atk];
    [tower setIgnoreArmor:ig];
    [tower setAttackInterval:interval];
    [tower setAttackRadius:radius];
    [tower setSpeedAddition:spUp];
    [tower setValueOfGold:cost];
    [tower setCannonSlotNumber:1];
    [tower setLvUpGold:lucCost];
    [tower createImage];
    [self updateStoreWithTower:tower];
}

- (void)initTestTowers
{
    
    [self addSingleTowerWithType:1 attack:30 ig:0 interval:24 radius:80 spUp:2 cost:40 luUpCost:18];
    [self addSingleTowerWithType:2 attack:120 ig:5 interval:45 radius:55 spUp:0 cost:80 luUpCost:24];
    [self addSingleTowerWithType:3 attack:199 ig:1 interval:65 radius:130 spUp:1 cost:245 luUpCost:65];
    [self addSingleTowerWithType:4 attack:110 ig:2 interval:20 radius:111 spUp:2 cost:355 luUpCost:144];
    [self addSingleTowerWithType:5 attack:2400 ig:10 interval:140 radius:140 spUp:1 cost:1777 luUpCost:360];
}

- (void)initTestCannons
{
    ChrisCannon *cannon = nil;
    
    cannon = [[ChrisCannon alloc] init];
    [cannon setType:1];
    [cannon setAttack:0];
    [cannon setIgnoreArmor:0];
    [cannon setMoveSpeed:7];
    [cannon createImage];
    [self updateStoreWithCannon:cannon];
}

+ (GameConfig *)globalConfig
{
    if (nil == globalConfig) {
   
        globalConfig = [NSKeyedUnarchiver unarchiveObjectWithFile:[self configFilePath]];
        if (nil == globalConfig) {
            globalConfig = [[GameConfig alloc] init];
            
            [globalConfig initTestLevels];
            [globalConfig initTestMonsters];
            [globalConfig initTestTowers];
            [globalConfig initTestCannons];
            
            [NSKeyedArchiver archiveRootObject:globalConfig toFile:[self configFilePath]];
        }
    }
    
    return globalConfig;
}

+ (void)reset
{
    globalConfig = [[GameConfig alloc] init];
    [globalConfig initTestLevels];
    [globalConfig initTestMonsters];
    [globalConfig initTestTowers];
    [globalConfig initTestCannons];
    [NSKeyedArchiver archiveRootObject:globalConfig toFile:[self configFilePath]];
    NSLog(@"%@", [self configFilePath]);
}

+ (NSString *)configFilePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    NSLog(@"<%s:%d> %d, %@", __func__, __LINE__, (int)documentDirectories.count, documentDirectories);
    return [documentDirectory stringByAppendingString:@"/game.cfg"];
}

+ (BOOL)saveConfigToFile
{
    return [NSKeyedArchiver archiveRootObject:globalConfig toFile:[self configFilePath]];
}

+ (void)configReadFromLocal
{
    globalConfig = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"game" ofType:@"cfg"]];
    
    if (nil == globalConfig) {
        NSLog(@"<%s:%d> Read local config file failed.", __func__, __LINE__);
    }
}

- (id)init
{
    self = [super init];
    
    if (self) {
        currentPlayerId = 1;
        currentLevelPrimaryType = 1;
        currentLevelSecondaryType = 1;
        
        majorObject = 1;
        majorIndex = 2;
        
        levelStore = [[NSMutableDictionary alloc] init];
        monsterStore = [[NSMutableDictionary alloc] init];
        towerStore = [[NSMutableDictionary alloc] init];
        cannonStore = [[NSMutableDictionary alloc] init];
    }
    
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        currentPlayerId = 1;
        currentLevelPrimaryType = 1;
        currentLevelSecondaryType = 1;
        
        majorObject = 1;
        majorIndex = 2;
        
        levelStore = [aDecoder decodeObjectForKey:@"levelStore"];
        monsterStore = [aDecoder decodeObjectForKey:@"monsterStore"];
        towerStore = [aDecoder decodeObjectForKey:@"towerStore"];
        cannonStore = [aDecoder decodeObjectForKey:@"cannonStore"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:levelStore forKey:@"levelStore"];
    [aCoder encodeObject:monsterStore forKey:@"monsterStore"];
    [aCoder encodeObject:towerStore forKey:@"towerStore"];
    [aCoder encodeObject:cannonStore forKey:@"cannonStore"];
}

- (BOOL)updateStore:(NSMutableDictionary *)store withObject:(id)object forKey:(NSString *)key
{
    if (nil == store || nil == object) {
        return NO;
    }
    
    id tmpObj = [store objectForKey:key];
    if (nil == tmpObj) {
        
        if (NO == [object respondsToSelector:@selector(initWithInstance:)]) {
            return NO;
        }
        
        tmpObj = [[[object class] alloc] initWithInstance:object];
        if (nil == tmpObj) {
            return NO;
        }
        
        [store setObject:tmpObj forKey:key];
        return YES;
    } else {
        
        if ( NO == [tmpObj respondsToSelector:@selector(updateWithInstance:)]) {
            return NO;
        }
        return [tmpObj updateWithInstance:object];
    }
}

#pragma mark Level operate
- (void)readOnlyEnumLevelWithBlock:(void (^)(const Level *, const NSString *))operation
{
    [levelStore readOnlyEnumArrayItemWithOperationBlock:operation];
    
    [[Player currentPlayer] readOnlyEnumDIYLevelWithBlock:operation];
}

- (void)configOnlyReadOnlyEnumLevelWithBlock:(void(^)(const Level *, const NSString *))operation
{
    [levelStore readOnlyEnumArrayItemWithOperationBlock:operation];
}

- (BOOL)updateStoreWithLevel:(Level *)level
{
    NSString *levelkey = [Level levelKeyWithPrimaryIndex:level.primaryIndex secondaryIndex:level.secondaryIndex];
    
    if (USER_CREATE_LEVEL_PRIMARY_INDEX == level.primaryIndex) {
        return [[Player currentPlayer] updateDIYLevelsWithLevel:level];
    } else {
        return [self updateStore:levelStore withObject:level forKey:levelkey];
    }
}

- (Level *)getTemplateLevelFromStoreWithPrimaryIndex:(int)priIndex secondaryIndex:(int)secIndex
{
    NSString *levelKey = [Level levelKeyWithPrimaryIndex:priIndex secondaryIndex:secIndex];
    
    if (USER_CREATE_LEVEL_PRIMARY_INDEX == priIndex) {
        return [[Player currentPlayer] getTemplateDIYLevelWithIndex:secIndex];
    } else {
        return [levelStore objectForKey:levelKey];
    }
}

- (Level *)getCurrentTemplateLevelFromStore
{
    return [self getTemplateLevelFromStoreWithPrimaryIndex:currentLevelPrimaryType secondaryIndex:currentLevelSecondaryType];
}

#pragma mark Monster operate
- (void)readOnlyEnumMonsterWithBlock:(void (^)(const ChrisMonster *, const NSString *))operation
{
    [monsterStore readOnlyEnumArrayItemWithOperationBlock:operation];
}

- (BOOL)updateStoreWithMonster:(ChrisMonster *)monster
{
    NSString *monsterKey = [ChrisMonster monsterKeyWithType:monster.type];
    
    return [self updateStore:monsterStore withObject:monster forKey:monsterKey];
}

- (ChrisMonster *)getTemplateMonsterFromStoreWithType:(int)type
{
    NSString *monsterKey = [ChrisMonster monsterKeyWithType:type];
    
    return [monsterStore objectForKey:monsterKey];
}

- (int)monsterNumber
{
    return (int)[monsterStore count];
}

#pragma mark Tower operate
- (void)readOnlyEnumTowerWithBlock:(void (^)(const ChrisTower *, const NSString *))operation
{
    [towerStore readOnlyEnumArrayItemWithOperationBlock:operation];
}

-(BOOL)updateStoreWithTower:(ChrisTower *)tower
{
    NSString *towerKey = [ChrisTower towerKeyWithType:tower.type];
    
    return [self updateStore:towerStore withObject:tower forKey:towerKey];
}

- (ChrisTower *)getTemplateTowerFromStoreWithType:(int)type
{
    NSString *towerKey = [ChrisTower towerKeyWithType:type];
    
    return [towerStore objectForKey:towerKey];
}

- (int)towerNumber
{
    return (int)[towerStore count];
}

#pragma mark Cannon operate
- (void)readOnlyEnumCannonWithBlock:(void (^)(const ChrisCannon *, const NSString *))operation
{
    [cannonStore readOnlyEnumArrayItemWithOperationBlock:operation];
}

- (BOOL)updateStoreWithCannon:(ChrisCannon *)cannon
{
    NSString *cannonKey = [ChrisCannon cannonKeyWithType:cannon.type];
    
    return [self updateStore:cannonStore withObject:cannon forKey:cannonKey];
}

- (ChrisCannon *)getTemplateCannonFromStoreWithType:(int)type
{
    NSString *cannonKey = [ChrisCannon cannonKeyWithType:type];
    
    return [cannonStore objectForKey:cannonKey];
}

- (int)cannonNumber
{
    return (int)[cannonStore count];
}

#pragma mark Information show
- (NSString *)description
{
    NSString *infoStr = [NSString stringWithFormat:@"GAME CONFIG\n"];
    
    /* Player */
    infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:
                                                @"Player Id: %d\n"
                                                "Major: %d--%d\n",
                                                currentPlayerId,
                                                majorObject,
                                                majorIndex]];
    
    /* level */
    infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"Level %d --- %d\n", currentLevelPrimaryType, currentLevelSecondaryType]];
    
    infoStr = [infoStr stringByAppendingString:@"--LEVELS INFO--\n"];
    for (Level *level in levelStore) {
        infoStr = [infoStr stringByAppendingString:[level description]];
        infoStr = [infoStr stringByAppendingString:@"\n"];
    }
    
    infoStr = [infoStr stringByAppendingString:@"--MONSTERS INFO--\n"];
    for (ChrisMonster *monster in monsterStore) {
        infoStr = [infoStr stringByAppendingString:[monster description]];
        infoStr = [infoStr stringByAppendingString:@"\n"];
    }
    
    infoStr = [infoStr stringByAppendingString:@"--TOWERS INFO--\n"];
    for (ChrisTower *tower in towerStore) {
        infoStr = [infoStr stringByAppendingString:[tower description]];
        infoStr = [infoStr stringByAppendingString:@"\n"];
    }
    
    infoStr = [infoStr stringByAppendingString:@"--CANNONS INFO--\n"];
    for (ChrisCannon *cannon in cannonStore) {
        infoStr = [infoStr stringByAppendingString:[cannon description]];
        infoStr = [infoStr stringByAppendingString:@"\n"];
    }
    
    return infoStr;
}

@end
