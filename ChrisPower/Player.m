//
//  Player.m
//  ChrisPower
//
//  Created by Chris on 14/12/30.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "GameConfig.h"
#import "NSMutableDictionary+ChrisOperation.h"

#import "ChrisMap.h"
#import "ChrisMonster.h"
#import "ChrisTower.h"
#import "ChrisCannon.h"

#import "Level.h"
#import "Home.h"
#import "Waves.h"

#import "DynamicLevel.h"
#import "DynamicMonster.h"
#import "DynamicTower.h"
#import "DynamicCannon.h"

#import "PlayerBag.h"
#import "PlayerBagItem.h"

#import "Player.h"

#define PLAYER_LV_MILESTONE1    49
#define PLAYER_LV_MILESTONE2    85
#define PLAYER_LV_MILESTONE3    126
#define PLAYER_LV_MAX           150

static Player *currentPlayer;

@implementation Player
@synthesize lv;
@synthesize experience;

@synthesize gold;
@synthesize cGold;

@synthesize  randAttackPowerLv;
@synthesize  randIgPowerLv;
@synthesize  randAttackRangePowerLv;
@synthesize  randAttackIntervalPowerLv;
@synthesize  randSpadditionPowerLv;

@synthesize  randAttackPercentLv;
@synthesize  randIgPercentLv;
@synthesize  randAttackRangePercentLv;
@synthesize  randAttackIntervalPercentLv;
@synthesize  randSpadditionPercentLv;

@synthesize  towerMagicSlot;

@synthesize  cannonTraceLv;
@synthesize  cannonSpUpLv;
@synthesize  cannonFireLv;
@synthesize  cannonIceLv;
@synthesize  cannonGasLv;

@synthesize  diyMapNumberMax;

- (void)createTestBag
{
    GameConfig *config = [GameConfig globalConfig];
    
    [config readOnlyEnumTowerWithBlock:^(const ChrisTower *tower, const NSString *key) {
        PlayerBagItem *item = [[PlayerBagItem alloc] init];
        [item setType:BAG_ITEM_TYPE_TOWER];
        [item setNumber:BAG_ITEM_NUMBER_UNLIMIT];
        [item setData:tower];
        [bag updateObjetArrayWithItem:item];
    }];
    
    [config readOnlyEnumCannonWithBlock:^(const ChrisCannon *cannon, const NSString *key) {
        PlayerBagItem *item = [[PlayerBagItem alloc] init];
        [item setType:BAG_ITEM_TYPE_TOWER];
        [item setNumber:BAG_ITEM_NUMBER_UNLIMIT];
        [item setData:cannon];
        [bag updateObjetArrayWithItem:item];
    }];
    
    bag.size = (int)(bag.objectArray.count);
}

+ (Player *)currentPlayer
{
    if (nil == currentPlayer) {
        currentPlayer = [NSKeyedUnarchiver unarchiveObjectWithFile:[self gamePlayerFilePath]];
        if (nil == currentPlayer) {
            currentPlayer = [[Player alloc] initWithGameConfig:[GameConfig globalConfig]];
            
            /* Unlock the first level */
            [[currentPlayer getDynamicLevelByPriIndex:1 secIndex:1] setObjectValidUntilDate:nil];
            /* Save file */
            [NSKeyedArchiver archiveRootObject:currentPlayer toFile:[self gamePlayerFilePath]];
        }
    }

    return currentPlayer;
}

+ (void)reset
{
    /* Force init */
    currentPlayer = [[Player alloc] initWithGameConfig:[GameConfig globalConfig]];
    [[currentPlayer getDynamicLevelByPriIndex:1 secIndex:1] setObjectValidUntilDate:nil];
    [NSKeyedArchiver archiveRootObject:currentPlayer toFile:[self gamePlayerFilePath]];
}

+ (NSString *)gamePlayerFilePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    NSLog(@"<%s,%d> %d, %@", __func__, __LINE__, (int)documentDirectories.count, documentDirectories);
    
    NSString *fileName = [NSString stringWithFormat:@"/play%d.dyn", [[GameConfig globalConfig] currentPlayerId]];
    
    return [documentDirectory stringByAppendingString:fileName];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        playerName = [aDecoder decodeObjectForKey:@"playName"];
        
        gold = [aDecoder decodeIntForKey:@"gold"];
        cGold = [aDecoder decodeIntForKey:@"cGold"];
        
        lv = [aDecoder decodeIntForKey:@"lv"];
        experience = [aDecoder decodeIntForKey:@"experience"];
        
        levelsInfo = [aDecoder decodeObjectForKey:@"levelsInfo"];
        
        monstersInfo = [aDecoder decodeObjectForKey:@"monstersInfo"];
        towersInfo = [aDecoder decodeObjectForKey:@"towersInfo"];
        cannonsInfo = [aDecoder decodeObjectForKey:@"cannonsInfo"];
        
        diyLevels = [aDecoder decodeObjectForKey:@"diyLevels"];
        
        randAttackPowerLv = [aDecoder decodeIntForKey:@"randAttackPowerLv"];
        randIgPowerLv = [aDecoder decodeIntForKey:@"randIgPowerLv"];
        randAttackRangePowerLv = [aDecoder decodeIntForKey:@"randAttackRangePowerLv"];
        randAttackIntervalPowerLv = [aDecoder decodeIntForKey:@"randAttackIntervalPowerLv"];
        randSpadditionPowerLv = [aDecoder decodeIntForKey:@"randSpadditionPowerLv"];

        randAttackPercentLv = [aDecoder decodeIntForKey:@"randAttackPercentLv"];
        randIgPercentLv = [aDecoder decodeIntForKey:@"randIgPercentLv"];
        randAttackRangePercentLv = [aDecoder decodeIntForKey:@"randAttackRangePercentLv"];
        randAttackIntervalPercentLv = [aDecoder decodeIntForKey:@"randAttackIntervalPercentLv"];
        randSpadditionPercentLv = [aDecoder decodeIntForKey:@"randSpadditionPercentLv"];
        
        towerMagicSlot = [aDecoder decodeIntForKey:@"towerMagicSlot"];
        
        cannonTraceLv = [aDecoder decodeIntForKey:@"cannonTraceLv"];
        cannonSpUpLv = [aDecoder decodeIntForKey:@"cannonSpUpLv"];
        cannonFireLv = [aDecoder decodeIntForKey:@"cannonFireLv"];
        cannonIceLv = [aDecoder decodeIntForKey:@"cannonIceLv"];
        cannonGasLv = [aDecoder decodeIntForKey:@"cannonGasLv"];

        diyMapNumberMax = [aDecoder decodeIntForKey:@"diyMapNumberMax"];
        
        awardFlag = [aDecoder decodeIntForKey:@"awardFlag"];
    }
    
    return self;
}

- (id)initWithGameConfig:(GameConfig *)config
{
    self = [super init];
    
    if (self) {
        playerName = [NSString stringWithFormat:@"Play%d", config.currentPlayerId];
        
        gold = 1000;
        cGold = 0;
        
        lv = 0;
        experience = 0;
        
        /* For now, we only use key */
        /* Level */
        levelsInfo = [[NSMutableDictionary alloc] init];
        [config configOnlyReadOnlyEnumLevelWithBlock:^(const Level *levelItem, const NSString *key) {
            
            DynamicLevel *level = [[DynamicLevel alloc] init];
            [levelsInfo setObject:level forKey:key];
            
            if (1 != levelItem.primaryIndex || 1 == levelItem.secondaryIndex) {
                [level setObjectValidUntilDate:nil];
            }
        }];
        [self readOnlyEnumDIYLevelWithBlock:^(const Level *levelItem, const NSString *key) {
            
            DynamicLevel *level = [[DynamicLevel alloc] init];
            [levelsInfo setObject:level forKey:key];
            [level setObjectValidUntilDate:nil];
        }];
        
        /* Monster */
        monstersInfo = [[NSMutableDictionary alloc] init];
        [config readOnlyEnumMonsterWithBlock:^(const ChrisMonster *monsterItem, const NSString *key) {
            
            DynamicMonster *monster = [[DynamicMonster alloc] init];
     
            [monstersInfo setObject:monster forKey:key];
        }];
        
        /* Tower */
        towersInfo = [[NSMutableDictionary alloc] init];
        [config readOnlyEnumTowerWithBlock:^(const ChrisTower *towerItem, const NSString *key) {
            
            DynamicTower *tower = [[DynamicTower alloc] init];
 
            [towersInfo setObject:tower forKey:key];
        }];

        
        /* Cannons */
        cannonsInfo = [[NSMutableDictionary alloc] init];
        [config readOnlyEnumCannonWithBlock:^(const ChrisCannon *cannonItem, const NSString *key) {
            
            DynamicCannon *cannon = [[DynamicCannon alloc] init];
            
            [cannonsInfo setObject:cannon forKey:key];
        }];
        
        /* DIY levels */
        diyLevels = [[NSMutableDictionary alloc] init];
        
        /* Tower Random Addition */
        randAttackPowerLv = 0;
        randIgPowerLv = 0;
        randAttackRangePowerLv = 0;
        randAttackIntervalPowerLv = 0;
        randSpadditionPowerLv = 0;
        
        randAttackPercentLv = 0;
        randIgPercentLv = 0;
        randAttackRangePercentLv = 0;
        randAttackIntervalPercentLv = 0;
        randSpadditionPercentLv = 0;
        
        /* Tower Magic Slot */
        towerMagicSlot = 1;
        
        /* Magic Cannons */
        cannonTraceLv = 0;
        cannonSpUpLv = 0;
        cannonFireLv = 0;
        cannonIceLv = 0;
        cannonGasLv = 0;
        
        /*  DIY Map limit */
        diyMapNumberMax = 1;
        awardFlag = 0;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:playerName forKey:@"playName"];
    
    [aCoder encodeInt:gold forKey:@"gold"];
    [aCoder encodeInt:cGold forKey:@"cGold"];
    
    [aCoder encodeInt:lv forKey:@"lv"];
    [aCoder encodeInt:experience forKey:@"experience"];
    
    [aCoder encodeObject:levelsInfo forKey:@"levelsInfo"];
    [aCoder encodeObject:monstersInfo forKey:@"monstersInfo"];
    [aCoder encodeObject:towersInfo forKey:@"towersInfo"];
    [aCoder encodeObject:cannonsInfo forKey:@"cannonsInfo"];
    [aCoder encodeObject:diyLevels forKey:@"diyLevels"];
    
    [aCoder encodeInt:randAttackPowerLv forKey:@"randAttackPowerLv"];
    [aCoder encodeInt:randIgPowerLv forKey:@"randIgPowerLv"];
    [aCoder encodeInt:randAttackRangePowerLv forKey:@"randAttackRangePowerLv"];
    [aCoder encodeInt:randAttackIntervalPowerLv forKey:@"randAttackIntervalPowerLv"];
    [aCoder encodeInt:randSpadditionPowerLv forKey:@"randSpadditionPowerLv"];
    
    [aCoder encodeInt:randAttackPercentLv forKey:@"randAttackPercentLv"];
    [aCoder encodeInt:randIgPercentLv forKey:@"randIgPercentLv"];
    [aCoder encodeInt:randAttackRangePercentLv forKey:@"randAttackRangePercentLv"];
    [aCoder encodeInt:randAttackIntervalPercentLv forKey:@"randAttackIntervalPercentLv"];
    [aCoder encodeInt:randSpadditionPercentLv forKey:@"randSpadditionPercentLv"];
    
    [aCoder encodeInt:towerMagicSlot forKey:@"towerMagicSlot"];
    
    [aCoder encodeInt:cannonTraceLv forKey:@"cannonTraceLv"];
    [aCoder encodeInt:cannonSpUpLv forKey:@"cannonSpUpLv"];
    [aCoder encodeInt:cannonFireLv forKey:@"cannonFireLv"];
    [aCoder encodeInt:cannonIceLv forKey:@"cannonIceLv"];
    [aCoder encodeInt:cannonGasLv forKey:@"cannonGasLv"];
    
    [aCoder encodeInt:diyMapNumberMax forKey:@"diyMapNumberMax"];
    
    [aCoder encodeInt:awardFlag forKey:@"awardFlag"];
}

#pragma mark Attribute-Random-LvUp-Info
/* Tower Power */
- (int)towerPowerCurrentAttack
{
    return randAttackPowerLv * 10 + 10;
}

- (int)towerPowerCurrentIg
{
    return randIgPowerLv + 1;
}

- (int)towerPowerCurrentAttackRange
{
    return randAttackRangePercentLv * 3 + 5;
}

- (int)towerPowerCurrentAttackInterval
{
    return randAttackIntervalPowerLv + 1;
}

- (int)towerPowerCurrentSpAddition
{
    return randSpadditionPowerLv + 1;
}

- (int)towerPowerLvUpCostWithLv:(int)inputLv
{
    if (inputLv >= TOWER_RANDOM_ATTRIBUTE_POWER_LV_MAX) {
        return  0;
    } else {
        return (inputLv * 10 + 20) * (inputLv + 1) / 2;
    }
}

- (int)towerPowerCurrentAttackLvUpCost
{
    return [self towerPowerLvUpCostWithLv:randAttackPowerLv];
}

- (int)towerPowerCurrentIgLvUpCost
{
    return [self towerPowerLvUpCostWithLv:randIgPowerLv];
}

- (int)towerPowerCurrentAttackRangeLvUpCost
{
    return [self towerPowerLvUpCostWithLv:randAttackRangePowerLv];
}

- (int)towerPowerCurrentAttackIntervalLvUpCost
{
    return [self towerPowerLvUpCostWithLv:randAttackIntervalPowerLv];
}

- (int)towerPowerCurrentSpAdditionLvUpCost
{
    return [self towerPowerLvUpCostWithLv:randSpadditionPowerLv];
}

- (void)towerPowerAttackLvUp
{
    if (randAttackPowerLv >= TOWER_RANDOM_ATTRIBUTE_POWER_LV_MAX) {
        return;
    }
    
    randAttackPowerLv += 1;
}

- (void)towerPowerIgLvUp
{
    if (randIgPowerLv >= TOWER_RANDOM_ATTRIBUTE_POWER_LV_MAX) {
        return;
    }
    
    randIgPowerLv += 1;
}

- (void)towerPowerAttackRangeLvUp
{
    if (randAttackRangePowerLv >= TOWER_RANDOM_ATTRIBUTE_POWER_LV_MAX) {
        return;
    }
    
    randAttackRangePowerLv += 1;
}

- (void)towerPowerAttackIntervalLvUp
{
    if (randAttackIntervalPowerLv >= TOWER_RANDOM_ATTRIBUTE_POWER_LV_MAX) {
        return;
    }
    
    randAttackIntervalPowerLv += 1;
}

- (void)towerPowerSpAdditionLvUp
{
    if (randSpadditionPowerLv >= TOWER_RANDOM_ATTRIBUTE_POWER_LV_MAX) {
        return;
    }
    
    randSpadditionPowerLv += 1;
}

/* Tower Percent */
- (int)towerPercentWithLv:(int)inputLv
{
    return (inputLv * 2 + 5);
}

- (int)towerPercentCurrentAttack
{
    return [self towerPercentWithLv:randAttackPercentLv];
}

- (int)towerPercentCurrentIg
{
    return [self towerPercentWithLv:randIgPercentLv];
}

- (int)towerPercentCurrentAttackRange
{
    return [self towerPercentWithLv:randAttackRangePercentLv];
}

- (int)towerPercentCurrentAttackInterval
{
    return [self towerPercentWithLv:randAttackIntervalPercentLv];
}

- (int)towerPercentCurrentSpAddition
{
    return [self towerPercentWithLv:randSpadditionPercentLv];
}

- (int)towerPercentLvUpCostWithLv:(int)inputLv
{
    if (inputLv >= TOWER_RANDOM_ATTRIBUTE_PERCENT_LV_MAX) {
        return  0;
    } else {
        return (inputLv * 10 + 20) * (inputLv + 1) / 2;
    }
}

- (int)towerPercentCurrentAttackLvUpCost
{
    return [self towerPercentLvUpCostWithLv:randAttackPercentLv];
}

- (int)towerPercentCurrentIgLvUpCost
{
    return [self towerPercentLvUpCostWithLv:randIgPercentLv];
}

- (int)towerPercentCurrentAttackRangeLvUpCost
{
    return [self towerPercentLvUpCostWithLv:randAttackRangePercentLv];
}

- (int)towerPercentCurrentAttackIntervalLvUpCost
{
    return [self towerPercentLvUpCostWithLv:randAttackIntervalPercentLv];
}

- (int)towerPercentCurrentSpAdditionLvUpCost
{
    return [self towerPercentLvUpCostWithLv:randSpadditionPercentLv];
}

- (void)towerPercentAttackLvUp
{
    if (randAttackPercentLv >= TOWER_RANDOM_ATTRIBUTE_PERCENT_LV_MAX) {
        return;
    }
    
    randAttackPercentLv += 1;
}

- (void)towerPercentIgLvUp
{
    if (randIgPercentLv >= TOWER_RANDOM_ATTRIBUTE_PERCENT_LV_MAX) {
        return;
    }
    
    randIgPercentLv += 1;
}

- (void)towerPercentAttackRangeLvUp
{
    if (randAttackRangePercentLv >= TOWER_RANDOM_ATTRIBUTE_PERCENT_LV_MAX) {
        return;
    }
    
    randAttackRangePercentLv += 1;
}

- (void)towerPercentAttackIntervalLvUp
{
    if (randAttackIntervalPercentLv >= TOWER_RANDOM_ATTRIBUTE_PERCENT_LV_MAX) {
        return;
    }
    
    randAttackIntervalPercentLv += 1;
}

- (void)towerPercentSpAdditionLvUp
{
    if (randSpadditionPercentLv >= TOWER_RANDOM_ATTRIBUTE_PERCENT_LV_MAX) {
        return;
    }
    
    randSpadditionPercentLv += 1;
}

#pragma mark Tower Magic Slot
- (int)towerMagicSlotAddOneCost
{
    if (1 == towerMagicSlot) {
        return 200;
    } else if (2 == towerMagicSlot) {
        return 500;
    } else {
        return 0;
    }
}

- (void)towerMagicSlotAddOne
{
    if (towerMagicSlot >= TOWER_MAGIC_SLOT_NUM_MAX) {
        NSLog(@"Slot number to the ceil.\n");
    }
    
    towerMagicSlot++;
}

#pragma makr Attribute-Cannon-Magics
- (int)cannonMagicCurrentTraceLvUpCost
{
    if (0 == cannonTraceLv) {
        return 50;
    } else {
        return 0;
    }
}

- (int)cannonMagicCurrentSpUpLvUpCost
{
    if (0 == cannonSpUpLv) {
        return 30;
    } else {
        return 0;
    }
}

- (double)cannonMagicFireHurtRatio
{
    return 0.55;
}

- (int)cannonMagicCurrentFireRange
{
    if (0 == cannonFireLv) {
        return 0;
    } else {
        return (40 + cannonFireLv * 10);
    }
}

- (int)cannonMagicCurrentFireLvUpCost
{
    if (0 == cannonFireLv) {
        return 100;
    } else if (cannonFireLv >= CANNON_MAGIC_LV_MAX) {
        return 0;
    } else {
        return (cannonFireLv * 20);
    }
}

- (double)cannonMagicIceSpeedDownRatio
{
    return 0.50;
}

- (int)cannonMagicCurrentIceStopTime
{
    return 15;
}

- (int)cannonMagicCurrentIceTime
{
    if (0 == cannonIceLv) {
        return 0;
    } else {
        return (20 + cannonIceLv * 20);
    }
}

- (int)cannonMagicCurrentIceLvUpCost
{
   if (cannonIceLv >= CANNON_MAGIC_LV_MAX) {
        return 0;
    } else {
        return 30;
    }
}

- (int)cannonMagicCurrentGasHurtPercent
{
    return (cannonGasLv * 5);
}

- (int)cannonMagicCurrentGasHurtInterval
{
    return 20;
}

- (int)cannonMagicCurrentGasTime
{
    if (0 == cannonGasLv) {
        return 0;
    } else {
        return (20 + cannonGasLv * 20);
    }
}

- (int)cannonMagicCurrentGasLvUpCost
{
    if (cannonGasLv >= CANNON_MAGIC_LV_MAX) {
        return 0;
    } else {
        return (20 + cannonGasLv * 20);
    }
}

- (void)cannonMagicTraceLvUp
{
    if (0 != cannonTraceLv) {
        return;
    }
    
    cannonTraceLv = 1;
}

- (void)cannonMagicSpUpLvUp
{
    if (0 != cannonSpUpLv) {
        return;
    }
    
    cannonSpUpLv = 1;
}

- (void)cannonMagicFireLvUp
{
    if (cannonFireLv >= CANNON_MAGIC_LV_MAX) {
        return;
    }
    
    cannonFireLv += 1;
}

- (void)cannonMagicIceLvUp
{
    if (cannonIceLv >= CANNON_MAGIC_LV_MAX) {
        return;
    }
    
    cannonIceLv += 1;
}

- (void)cannonMagicGasLvUp
{
    if (cannonGasLv >= CANNON_MAGIC_LV_MAX) {
        return;
    }
    
    cannonGasLv += 1;
}

#pragma mark DIY Map
- (int)diyMapLvUpCost
{
    if (1 == diyMapNumberMax) {
        return 1;
    } else if (diyMapNumberMax >= DIY_MAP_NUMBER_LIMIT) {
        return 0;
    } else {
        return 40 + ((diyMapNumberMax * 10 - 10) * diyMapNumberMax / 2);
    }
}

- (void)getNewMapPaper
{
    if (diyMapNumberMax >= DIY_MAP_NUMBER_LIMIT) {
        return;
    }
    
    diyMapNumberMax += 1;
}

#pragma mark DIY Levels
/* TODO: Copy from gameConfig. Think about merge later */
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

- (void)readOnlyEnumDIYLevelWithBlock:(void(^)(const Level *, const NSString *))operation
{
    [diyLevels readOnlyEnumArrayItemWithOperationBlock:operation];
}

- (BOOL)updateDIYLevelsWithLevel:(Level *)level
{
    if (USER_CREATE_LEVEL_PRIMARY_INDEX != level.primaryIndex) {
        NSLog(@"Not DIY Level, can't update there.\n");
        return NO;
    }
    
    NSString *levelkey = [Level levelKeyWithPrimaryIndex:level.primaryIndex secondaryIndex:level.secondaryIndex];
    
    return [self updateStore:diyLevels withObject:level forKey:levelkey];
}

- (Level *)getTemplateDIYLevelWithIndex:(int)index
{
    NSString *levelKey = [Level levelKeyWithPrimaryIndex:USER_CREATE_LEVEL_PRIMARY_INDEX secondaryIndex:index];
    
    return [diyLevels objectForKey:levelKey];
}

- (BOOL)updateDIYLevelWithLevelIndex:(int)index
                                 map:(ChrisMap *)map
                            monster1:(int)monster1
                            monster2:(int)monster2
                            monster3:(int)monster3
{
    Level *level = [self getTemplateDIYLevelWithIndex:index];
    
    if (nil == level) {
        level = [[Level alloc] init];
        [level setPrimaryIndex:USER_CREATE_LEVEL_PRIMARY_INDEX];
        [level setSecondaryIndex:index];
        /* Map Setting */
        [level setMap:[[ChrisMap alloc] initWithInstance:map]];
        /* Home Setting */
        [level setHome:[[Home alloc] initWithLevelPrimaryIndex:USER_CREATE_LEVEL_PRIMARY_INDEX secondaryIndex:index]];
        /* Wave Setting */
        Waves *tmpWaves = [[Waves alloc] initWithWaveNumber:49
                                         monterPerWaveBasic:10
                                                      type1:monster1
                                                   percent1:33
                                                      type2:monster2
                                                   percent2:33
                                                      type3:monster3];
        [level setWaves:tmpWaves];
        /* Limit */
        [level setMonsterExistNumberMax:30];
        [level setTowerExistNumberMax:20];
        
        [self updateDIYLevelsWithLevel:level];
        
        [[self getDynamicLevelByPriIndex:USER_CREATE_LEVEL_PRIMARY_INDEX secIndex:index] setObjectValidUntilDate:nil];
    } else {
        /* Map update */
        [level.map updateWithInstance:map];
        
        /* Wave update */
        Waves *tmpWaves = [[Waves alloc] initWithWaveNumber:49
                                         monterPerWaveBasic:10
                                                      type1:monster1
                                                   percent1:33
                                                      type2:monster2
                                                   percent2:33
                                                      type3:monster3];
        [level setWaves:tmpWaves];
    }
    
    [NSKeyedArchiver archiveRootObject:self toFile:[Player gamePlayerFilePath]];
    
    return YES;
}

#pragma Teach level award flag
- (NSString *)teachLevel1Award
{
    if (YES == MASK_CHECK(awardFlag, TEACH_LEVEL_MASK1)) {
        NSLog(@"Teach level1 already Awarded.");
        return nil;
    }

    [self earnGold:1000];
    [self earnCGold:10];
    
    MASK_SET(awardFlag, TEACH_LEVEL_MASK1);
    return @"试玩关卡1通关奖励\n"
    "获得金币：1000\n"
    "获得C币：10\n";
}

- (NSString *)teachLevel2Award
{
    if (YES == MASK_CHECK(awardFlag, TEACH_LEVEL_MASK2)) {
        NSLog(@"Teach level2 already Awarded.");
        return nil;
    }
    
    [self earnGold:2000];
    [self earnCGold:30];
    
    MASK_SET(awardFlag, TEACH_LEVEL_MASK2);
    return @"试玩关卡2通关奖励\n"
    "获得金币：2000\n"
    "获得C币：30\n";
}

- (NSString *)teachLevel3Award
{
    if (YES == MASK_CHECK(awardFlag, TEACH_LEVEL_MASK3)) {
        NSLog(@"Teach level3 already Awarded.");
        return nil;
    }
    
    [self earnGold:5000];
    [self earnCGold:50];
    
    MASK_SET(awardFlag, TEACH_LEVEL_MASK3);
    return @"试玩关卡3通关奖励\n"
    "获得金币：5000\n"
    "获得C币：50\n";
}

- (NSString *)teachLevelAwardWithIndex:(int)index
{
    switch (index) {
        case 1:
            return [self teachLevel1Award];
        case 2:
            return [self teachLevel2Award];
        case 3:
            return [self teachLevel3Award];
        default:
            return nil;
    }
}

#define AWARD_INITIAL_STRING        @"welcome1"
#define AWARD_INITIAL_GOLD          3000
#define AWARD_INITIAL_CGOLD         100

#define AWARD_AD_STRING             @"nryzygzadnr1"
#define AWARD_AD_GOLD               10000
#define AWARD_AD_CGOLD              300

- (NSString *)awardWithCodeString:(NSString *)str
{
    NSString *alertStr = nil;
    
    if ([str isEqual: AWARD_INITIAL_STRING]) {
        
        if (MASK_CHECK(awardFlag, INITIAL_BAG_AWARD)) {
            alertStr = @"已经领取过初始大礼包";
        } else {
            [self earnGold:AWARD_INITIAL_GOLD];
            [self earnCGold:AWARD_INITIAL_CGOLD];
            alertStr = [NSString stringWithFormat:@"兑奖成功，获得初始大礼包\n"
                        "内含金币:%d C币:%d\n",
                        AWARD_INITIAL_GOLD,
                        AWARD_INITIAL_CGOLD];
            MASK_SET(awardFlag, INITIAL_BAG_AWARD);
        }
    
    } else if ([str isEqual: AWARD_AD_STRING]) {
        
        if (MASK_CHECK(awardFlag, AD_BAG_AWARD)) {
            alertStr = @"已经领取过宣传大礼包";
        } else {
            [self earnGold:AWARD_AD_GOLD];
            [self earnCGold:AWARD_AD_CGOLD];
            alertStr = [NSString stringWithFormat:@"兑奖成功，获得宣传大礼包\n"
                        "内含金币:%d C币:%d\n",
                        AWARD_INITIAL_GOLD,
                        AWARD_INITIAL_CGOLD];
            MASK_SET(awardFlag, AD_BAG_AWARD);
        }
    
    } else {
        alertStr = @"无效的对象码";
    }
    
    [NSKeyedArchiver archiveRootObject:currentPlayer toFile:[Player gamePlayerFilePath]];
    
    return alertStr;
}

#pragma mark Attribute-Level
- (NSString *)currentLevelKey
{
    GameConfig *config = [GameConfig globalConfig];
    
    return [Level levelKeyWithPrimaryIndex:config.currentLevelPrimaryType secondaryIndex:config.currentLevelSecondaryType];
}

- (DynamicLevel *)currentDynamicLevel
{
    if (nil == currentDynamicLevel) {
        [self updateCurrentDynamicLevel];
    }
    
    return currentDynamicLevel;
}

/* Only get, not create */
- (DynamicLevel *)getDynamicLevelByPriIndex:(int)priIndex secIndex:(int)secIndex
{
    DynamicLevel *dynLevel =  [levelsInfo objectForKey:[Level levelKeyWithPrimaryIndex:priIndex secondaryIndex:secIndex]];
    
    if (nil == dynLevel) {
        NSString *tmpKey = [Level levelKeyWithPrimaryIndex:priIndex secondaryIndex:secIndex];
        
        dynLevel = [[DynamicLevel alloc] init];
        [levelsInfo setObject:dynLevel forKey:tmpKey];
    }
    
    return dynLevel;
}

- (void)updateCurrentDynamicLevel
{
    currentDynamicLevel = [levelsInfo objectForKey:[self currentLevelKey]];
    
    if (nil == currentDynamicLevel) {
        
        DynamicLevel *dynamicLevel = [[DynamicLevel alloc] init];
        [levelsInfo setObject:dynamicLevel forKey:[self currentLevelKey]];
        currentDynamicLevel = dynamicLevel;
    }
}

#pragma mark Attribute-Monster
- (DynamicMonster *)getDynamicMonsterByType:(int)type
{
    NSString *key = [ChrisMonster monsterKeyWithType:type];
    DynamicMonster *monster = [monstersInfo objectForKey:key];
    
    if (nil == monster) {
        monster = [[DynamicMonster alloc] init];
        [monstersInfo setObject:monster forKey:key];
    }
    
    return monster;
}

- (void)monsterBeenKilled:(ChrisMonster *)monster
{
    DynamicMonster *dynMonster = [self getDynamicMonsterByType:monster.type];
    
    [dynMonster updateCurrentExperienceByValue:1];
    [[self currentDynamicLevel] updateCurrentGradeWithValue:(monster.killedGoldAward + monster.currentHealthPoint * (-1))];
}

#pragma mark Attribute-Tower
- (DynamicTower *)getDynamicTowerByType:(int)type
{
    NSString *key = [ChrisTower towerKeyWithType:type];
    DynamicTower *tower = [towersInfo objectForKey:key];
    
    if (nil == tower) {
        tower = [[DynamicTower alloc] init];
        [towersInfo setObject:tower forKey:key];
    }
    
    return tower;
}

- (void)towerWithType:(int)type earnExperience:(int)exp
{
    DynamicTower *dynTower = [self getDynamicTowerByType:type];
    [dynTower updateCurrentExperienceByValue:exp];
}

#pragma mark Attribute-Cannon
- (DynamicCannon *)getDynamicCannonByType:(int)type
{
    NSString *key = [ChrisCannon cannonKeyWithType:type];
    DynamicCannon *cannon =  [cannonsInfo objectForKey:key];
    
    if (nil == cannon) {
        cannon = [[DynamicCannon alloc] init];
        [cannonsInfo setObject:cannon forKey:key];
    }
    
    return cannon;
}

- (void)cannonWithType:(int)type earnExperience:(int)exp;
{
    DynamicCannon *dynCannon = [self getDynamicCannonByType:type];
    [dynCannon updateCurrentExperienceByValue:exp];
}

- (void)infoUpdateWithCurrentValue
{
    /* Current Level update */
    DynamicLevel *level = [self currentDynamicLevel];
    [level infoUpdateWithCurrentValue];
    
    /* Monsters update */
    [monstersInfo enumItemWithOperationBlock:^(DynamicMonster *monster) {
        [monster infoUpdateWithCurrentValue];
    }];
    
    /* Towers update */
    [towersInfo enumItemWithOperationBlock:^(DynamicTower *tower) {
        [tower infoUpdateWithCurrentValue];
    }];

    /* Cannon update */
    [cannonsInfo enumItemWithOperationBlock:^(DynamicCannon *cannon) {
        [cannon infoUpdateWithCurrentValue];
    }];
    
    [NSKeyedArchiver archiveRootObject:self toFile:[Player gamePlayerFilePath]];
}

#pragma mark Exp OP
- (int)earnExperience:(int)exp
{
    experience += exp;
    
    int lvUpExp = [self currentLvUpExperience];
    if (experience >= lvUpExp) {
        experience -= lvUpExp;
        [self lvUp];
        return PLAYER_LVUP;
    }
    
    [NSKeyedArchiver archiveRootObject:self toFile:[Player gamePlayerFilePath]];
    return 0;
}

- (int)currentLvUpExperience
{
    int lvUpExp = 0;
    
    if (lv < PLAYER_LV_MILESTONE1) {
        lvUpExp = pow(1.1, lv) * 500;
    } else if (lv < PLAYER_LV_MILESTONE2) {
        lvUpExp = pow(1.02, lv - PLAYER_LV_MILESTONE1) * 50000;
    } else if (lv < PLAYER_LV_MILESTONE3) {
        lvUpExp = pow(1.01, lv - PLAYER_LV_MILESTONE2) * 100000;
    } else {
        lvUpExp = pow(1.005, lv - PLAYER_LV_MILESTONE3) * 150000;
    }
    
    return lvUpExp;
}

- (void)lvUp
{
    /* 1. CGold Award */
    [self earnCGold:30 + lv];
    
    lv++;
}

#pragma mark Gold OP
- (void)earnGold:(int)number
{
    gold += number;
    
//    gold = gold > 1000000 ? 1000000 : gold;
    
    [NSKeyedArchiver archiveRootObject:self toFile:[Player gamePlayerFilePath]];
}

- (void)earnCGold:(int)number
{
    cGold += number;
    
//    cGold = cGold > 1000000 ? 1000000 : cGold;
    
    [NSKeyedArchiver archiveRootObject:self toFile:[Player gamePlayerFilePath]];
}

- (BOOL)spendGold:(int)number
{
    if (gold < number) {
        return NO;
    }
    
    gold -= number;
    
    [NSKeyedArchiver archiveRootObject:self toFile:[Player gamePlayerFilePath]];
    
    return YES;
}

- (BOOL)spendCGold:(int)number
{
    if (cGold < number) {
        return NO;
    }
    
    cGold -= number;
    
    [NSKeyedArchiver archiveRootObject:self toFile:[Player gamePlayerFilePath]];
    
    return YES;
}

- (NSString *)description
{
    NSString *str = [NSString stringWithFormat:
                     @"PLAYER INFORMATION\n"
                     "Play name: %@\n"
                     "Gold: %d\n"
                     "cGold: %d\n"
                     "Lv: %d\n"
                     "Experience: %d\n",
                     playerName,
                     gold,
                     cGold,
                     lv,
                     experience];
    
    /* Level */
    str = [str stringByAppendingString:@"LEVEL INFO\n"];

    for (NSString *key in levelsInfo) {
        str = [str stringByAppendingString:key];
        str = [str stringByAppendingString:@"\n"];
        str = [str stringByAppendingString:[[levelsInfo objectForKey:key] description]];
    }
    
    str = [str stringByAppendingString:@"MONSTER INFO\n"];
    /* Monsters */
    for (NSString *key in monstersInfo) {
        str = [str stringByAppendingString:key];
        str = [str stringByAppendingString:@"\n"];
        str = [str stringByAppendingString:[[monstersInfo objectForKey:key] description]];
    }
    
    str = [str stringByAppendingString:@"TOWER INFO\n"];
    /* Towers */
    for (NSString *key in towersInfo) {
        str = [str stringByAppendingString:key];
        str = [str stringByAppendingString:@"\n"];
        str = [str stringByAppendingString:[[towersInfo objectForKey:key] description]];
    }
    
    str = [str stringByAppendingString:@"CANNON INFO\n"];
    /* Cannon */
    for (NSString *key in cannonsInfo) {
        str = [str stringByAppendingString:key];
        str = [str stringByAppendingString:@"\n"];
        str = [str stringByAppendingString:[[cannonsInfo objectForKey:key] description]];
    }

    return str;
}

#pragma mark Lv strengthen
- (int)currentHomeInitialGold
{
    return 300 + lv * 5;
}

- (int)currentHomeHp
{
    return 10 + lv / 5;
}

- (int)currentHomeArmor
{
    return 10 + lv;
}

- (int)currentTowerAttackUpPercent
{
    return lv;
}

@end
