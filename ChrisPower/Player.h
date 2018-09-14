//
//  Player.h
//  ChrisPower
//
//  Created by Chris on 14/12/30.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DynamicProtocol.h"

@class ChrisMap;
@class ChrisMonster;
@class ChrisTower;
@class ChrisCannon;
@class Level;
@class DynamicLevel;
@class DynamicMonster;
@class DynamicTower;
@class DynamicCannon;
@class PlayerBag;

#define TOWER_RANDOM_ATTRIBUTE_POWER_LV_MAX         5
#define TOWER_RANDOM_ATTRIBUTE_PERCENT_LV_MAX       6

#define TOWER_MAGIC_SLOT_NUM_MAX                    3

#define CANNON_MAGIC_LV_MAX                         5
#define DIY_MAP_NUMBER_LIMIT                        15

enum {
    CANNON_MAGIC_FIRE = 0,
    CANNON_MAGIC_ICE,
    CANNON_MAGIC_GAS,
};

#define TEACH_LEVEL_MASK1   (1 << 0)
#define TEACH_LEVEL_MASK2   (1 << 1)
#define TEACH_LEVEL_MASK3   (1 << 2)
#define AD_BAG_AWARD        (1 << 3)
#define INITIAL_BAG_AWARD    (1 << 4)

#define MASK_SET(move_mask, mask)      move_mask |= (mask)
#define MASK_CLEAR(move_mask, mask)    move_mask &= ~(mask)
#define MASK_CHECK(move_mask, mask)    (((move_mask) & (mask)) ? YES : NO)

@interface Player : NSObject <NSCoding, DynamicProtocol>
{
    NSString *playerName;
    
    int gold;
    int cGold;
    
    int lv;
    int experience;
    
    /* TODO: this attribute need save in CODER */
    int bagSize;
    /* Dynamic bag */
    PlayerBag *bag;
    
    NSMutableDictionary *levelsInfo;
    NSMutableDictionary *monstersInfo;
    NSMutableDictionary *towersInfo;
    NSMutableDictionary *cannonsInfo;
    
    /* DIY Level */
    NSMutableDictionary *diyLevels;
    
    /* Tower Random Addition */
    int randAttackPowerLv;
    int randIgPowerLv;
    int randAttackRangePowerLv;
    int randAttackIntervalPowerLv;
    int randSpadditionPowerLv;
  
    int randAttackPercentLv;
    int randIgPercentLv;
    int randAttackRangePercentLv;
    int randAttackIntervalPercentLv;
    int randSpadditionPercentLv;

    /* Tower Magic Slot */
    int towerMagicSlot;
    
    /* Magic Cannons */
    int cannonTraceLv;
    int cannonSpUpLv;
    int cannonFireLv;
    int cannonIceLv;
    int cannonGasLv;
    
    /*  DIY Map limit */
    int diyMapNumberMax;
    
    /* Teach level award flag */
    int awardFlag;
    
    __weak DynamicLevel *currentDynamicLevel;
}
@property (nonatomic, readonly) int lv;
@property (nonatomic, readonly) int experience;

@property (nonatomic, readonly) int gold;
@property (nonatomic, readonly) int cGold;

@property (nonatomic, readonly) int randAttackPowerLv;
@property (nonatomic, readonly) int randIgPowerLv;
@property (nonatomic, readonly) int randAttackRangePowerLv;
@property (nonatomic, readonly) int randAttackIntervalPowerLv;
@property (nonatomic, readonly) int randSpadditionPowerLv;

@property (nonatomic, readonly) int randAttackPercentLv;
@property (nonatomic, readonly) int randIgPercentLv;
@property (nonatomic, readonly) int randAttackRangePercentLv;
@property (nonatomic, readonly) int randAttackIntervalPercentLv;
@property (nonatomic, readonly) int randSpadditionPercentLv;

@property (nonatomic, readonly) int towerMagicSlot;

@property (nonatomic, readonly) int cannonTraceLv;
@property (nonatomic, readonly) int cannonSpUpLv;
@property (nonatomic, readonly) int cannonFireLv;
@property (nonatomic, readonly) int cannonIceLv;
@property (nonatomic, readonly) int cannonGasLv;

@property (nonatomic, readonly) int diyMapNumberMax;

+ (NSString *)gamePlayerFilePath;
+ (Player *)currentPlayer;
+ (void)reset;

/* Tower Power */
- (int)towerPowerCurrentAttack;
- (int)towerPowerCurrentIg;
- (int)towerPowerCurrentAttackRange;
- (int)towerPowerCurrentAttackInterval;
- (int)towerPowerCurrentSpAddition;

- (int)towerPowerCurrentAttackLvUpCost;
- (int)towerPowerCurrentIgLvUpCost;
- (int)towerPowerCurrentAttackRangeLvUpCost;
- (int)towerPowerCurrentAttackIntervalLvUpCost;
- (int)towerPowerCurrentSpAdditionLvUpCost;

- (void)towerPowerAttackLvUp;
- (void)towerPowerIgLvUp;
- (void)towerPowerAttackRangeLvUp;
- (void)towerPowerAttackIntervalLvUp;
- (void)towerPowerSpAdditionLvUp;

/* Tower Percent */
- (int)towerPercentCurrentAttack;
- (int)towerPercentCurrentIg;
- (int)towerPercentCurrentAttackRange;
- (int)towerPercentCurrentAttackInterval;
- (int)towerPercentCurrentSpAddition;

- (int)towerPercentCurrentAttackLvUpCost;
- (int)towerPercentCurrentIgLvUpCost;
- (int)towerPercentCurrentAttackRangeLvUpCost;
- (int)towerPercentCurrentAttackIntervalLvUpCost;
- (int)towerPercentCurrentSpAdditionLvUpCost;

- (void)towerPercentAttackLvUp;
- (void)towerPercentIgLvUp;
- (void)towerPercentAttackRangeLvUp;
- (void)towerPercentAttackIntervalLvUp;
- (void)towerPercentSpAdditionLvUp;

/* Tower magic slot */
- (int)towerMagicSlotAddOneCost;
- (void)towerMagicSlotAddOne;

/* Cannon Magic */
- (int)cannonMagicCurrentTraceLvUpCost;
- (int)cannonMagicCurrentSpUpLvUpCost;

- (double)cannonMagicFireHurtRatio;
- (int)cannonMagicCurrentFireRange;
- (int)cannonMagicCurrentFireLvUpCost;

- (double)cannonMagicIceSpeedDownRatio;
- (int)cannonMagicCurrentIceStopTime;
- (int)cannonMagicCurrentIceTime;
- (int)cannonMagicCurrentIceLvUpCost;

- (int)cannonMagicCurrentGasHurtPercent;
- (int)cannonMagicCurrentGasHurtInterval;
- (int)cannonMagicCurrentGasTime;
- (int)cannonMagicCurrentGasLvUpCost;

- (void)cannonMagicTraceLvUp;
- (void)cannonMagicSpUpLvUp;
- (void)cannonMagicFireLvUp;
- (void)cannonMagicIceLvUp;
- (void)cannonMagicGasLvUp;

/* Diy Map */
- (int)diyMapLvUpCost;
- (void)getNewMapPaper;

/* Diy level op */
- (void)readOnlyEnumDIYLevelWithBlock:(void(^)(const Level *, const NSString *))operation;
- (BOOL)updateDIYLevelsWithLevel:(Level *)level;
- (Level *)getTemplateDIYLevelWithIndex:(int)index;

- (BOOL)updateDIYLevelWithLevelIndex:(int)index
                                 map:(ChrisMap *)map
                            monster1:(int)monster1
                            monster2:(int)monster2
                            monster3:(int)monster3;


/* Dynamic infos */
- (DynamicLevel *)currentDynamicLevel;
- (DynamicLevel *)getDynamicLevelByPriIndex:(int)priIndex secIndex:(int)secIndex;
- (void)updateCurrentDynamicLevel;

- (DynamicMonster *)getDynamicMonsterByType:(int)type;
- (void)monsterBeenKilled:(ChrisMonster *)monster;

- (DynamicTower *)getDynamicTowerByType:(int)type;
- (void)towerWithType:(int)type earnExperience:(int)exp;

- (DynamicCannon *)getDynamicCannonByType:(int)type;
- (void)cannonWithType:(int)type earnExperience:(int)exp;

/* Exp OP */
#define PLAYER_LVUP     1
- (int)earnExperience:(int)exp;
- (int)currentLvUpExperience;

/* Gold OP */
- (void)earnGold:(int)number;
- (void)earnCGold:(int)number;

- (BOOL)spendGold:(int)number;
- (BOOL)spendCGold:(int)number;

/* TODO: In the future, we need a bagitemSelectView */
- (void)createTestBag;

/* Teach level flag operation */
- (NSString *)teachLevelAwardWithIndex:(int)index;
- (NSString *)awardWithCodeString:(NSString *)str;

/* Strengthen */
- (int)currentHomeInitialGold;
- (int)currentHomeHp;
- (int)currentHomeArmor;

- (int)currentTowerAttackUpPercent;

@end
