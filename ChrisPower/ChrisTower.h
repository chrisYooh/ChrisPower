//
//  ChrisTower.h
//  ChrisPower
//
//  Created by Chris on 14/12/10.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "GameConfig.h"

#define TOWER_LV_MAX    5
#define TOWER_SALE_CUTOFF 0.4

enum {
    TOWER_POWER_NONE = 0,
    TOWER_POWER_ATTACK ,
    TOWER_POWER_IGNORE_ARMOR,
    TOWER_POWER_ATTACK_INTERVAL,
    TOWER_POWER_ATTACK_RADIUS,
    TOWER_POWER_SPEED_ADDITION,
};

typedef enum tower_status_ {
    TOWER_STATUS_PREPARE = 0,
    TOWER_STATUS_OBSERVE = 1,
    TOWER_STATUS_ATTACK = 2,
    TOWER_STATUS_REMOVE = 3,
} tower_status_e;

@class Player;
@class ChrisMap;
@class ChrisMonster;
@class ChrisMapBox;
@class ChrisTower;

@protocol ChrisTowerDatasource <NSObject>

- (ChrisMap *)towerMap:(ChrisTower *)tower;

@end

@protocol ChrisTowerDelegate <NSObject>

@optional
- (void)tower:(ChrisTower *)tower didCreateCannon:(ChrisCannon *)cannon;
- (void)towerDidStartObserve:(ChrisTower *)tower;
- (void)towerDidRemoved:(ChrisTower *)tower;

@end

@interface ChrisTower : NSObject <NSCoding, GameConfigProtocol>
{
    double attackMul;
    double attackRangeMul;
    
    int type;
    
    int attack;
    int ignoreArmor;
    int attackInterval;
    int attackRadius;
    int speedAddition;
    
    int valueOfGold;
    int cannonSlotNumber;
    
    int lv;
    int lvUpGold;   /* Also used as currentLvUpGold */
    int randLvUpPower[TOWER_LV_MAX];
    
    int attackCheckInterval;
    
    int cannonSlotUsedNumber;
    NSMutableArray *installedCannons;
    
    tower_status_e status;
    int attackCheckIntervalCounter; /* Valid in sleep status */
    int attackIntervalCounter;
    NSMutableArray *attackScopeHelper; /* For attack ratio*/
    __weak ChrisMapBox *locatedMapBox;
    
    CGRect frame;
    
    int imageCounter;
    NSMutableArray *imageArray;
    UIImage *iconImage;
}
@property (nonatomic,weak) id<ChrisTowerDatasource, ChrisTowerDelegate> delegate;
@property (nonatomic) CGRect frame;

@property (nonatomic) int type;
@property (nonatomic) int attack;
@property (nonatomic) int ignoreArmor;
@property (nonatomic) int attackInterval;
@property (nonatomic) int attackRadius;
@property (nonatomic) int speedAddition;
@property (nonatomic) int valueOfGold;
@property (nonatomic) int cannonSlotNumber;
@property (nonatomic) int lvUpGold;

@property (nonatomic) int lv;

@property (nonatomic, readonly) int cannonSlotUsedNumber;
@property (nonatomic, readonly) NSMutableArray *installedCannons;

@property (nonatomic, readonly) NSMutableArray *imageArray;
@property (nonatomic, readonly) UIImage *iconImage;

@property (nonatomic, readonly) tower_status_e status;
@property (nonatomic, readonly) NSMutableArray *attackScopeHelper;
@property (nonatomic, weak) ChrisMapBox *locatedMapBox;

+ (NSString *)towerKeyWithType:(int)type;
+ (NSString *)getImagePathByType:(int)type;

- (void)selfStatusHandle;

- (BOOL)createImage;
- (UIImage *)displayImage;

- (void)startWithMapBox:(ChrisMapBox *)box;
- (void)setRemove;

/* User interface */
- (int)saleGold;
- (BOOL)canLvUp;
- (int)lvUp;
- (int)recommendValueOfGold;
- (BOOL)setCannonWithCannonType:(int)cannonType;
- (NSString *)randPowerStr;
- (void)strengthenWithPlayer:(Player *)player;
- (BOOL)canNewMagicSet;
- (void)setMagicWithFlag:(int)flag;

/* Draw */
- (void)drawTowerWithContext:(CGContextRef)context;

@end
