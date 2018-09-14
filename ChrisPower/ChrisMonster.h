//
//  ChrisMonster.h
//  ChrisPower
//
//  Created by Chris on 14/12/10.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "GameConfig.h"

enum {
    MONSTER_TYPE_RANDOM = 0,
    MONSTER_TYPE_BIGEYE,
    MONSTER_TYPE_ROBOT,
    MONSTER_TYPE_FLATWORM,
    MONSTER_TYPE_LEAF,
    MONSTER_TYPE_TORNADO,
    MONSTER_TYPE_SPERM,
    MONSTER_TYPE_OCTOPUS,
    MONSTER_TYPE_STICKS,
    
//    MONSTER_TYPE_BOSS_AA,
//    MONSTER_TYPE_BOSS_BB,
    MONSTER_TYPE_MIN = 1,
    MONSTER_TYPE_MAX = MONSTER_TYPE_STICKS,
    MONSTER_TYPE_NUMBER = MONSTER_TYPE_MAX - MONSTER_TYPE_MIN + 1,
};

#define MONSTER_MOVE_MASK_FREEZING    (1 << 2)
#define MONSTER_MOVE_MASK_POISONING   (1 << 3)

#define MONSTER_MOVE_MASK_SET(move_mask, mask)      move_mask |= (mask)
#define MONSTER_MOVE_MASK_CLEAR(move_mask, mask)    move_mask &= ~(mask)
#define MONSTER_MOVE_MASK_CHECK(move_mask, mask)    (((move_mask) & (mask)) ? YES : NO)

typedef enum monster_status_{
    MONSTER_STATUS_PREPARE = 0,
    MONSTER_STATUS_MOVE,
    MONSTER_STATUS_ANGRY,
    MONSTER_STATUS_CRAZY,
    MONSTER_STATUS_KILLED,
    MONSTER_STATUS_ATTACK,
    MONSTER_STATUS_REMOVED,
} monster_status_e;

enum {
    MONSTER_MOVE_NEW_BOX = 1,
    MONSTER_MOVE_OLD_BOX = 2,
    MONSTER_MOVE_ERROR = -1,
};

enum {
    MONSTER_DIE_REASON_KILLED = MONSTER_STATUS_KILLED,
    MONSTER_DIE_REASON_ATTACK_HOME = MONSTER_STATUS_ATTACK,
};

@class ChrisMap;
@class ChrisMapBox;
@class ChrisMapPathItem;
@class ChrisMonster;

@protocol ChrisMonsterDatasource <NSObject>

- (ChrisMap *)monsterMap:(ChrisMonster *)monster;

@end

@protocol ChrisMonsterDelegate <NSObject>

@optional
- (void)monsterDidStartMove:(ChrisMonster *)monster;
- (void)monsterWillMoveToNewRect:(ChrisMonster *)monster;
- (void)monsterDidMoveToNewRect:(ChrisMonster *)monster;
- (void)monsterDidDead:(ChrisMonster *)monster withReason:(int)reason;

@end

@interface ChrisMonster : NSObject <NSCoding, GameConfigProtocol>
{
    double hurtMul;
    
    int type;
    
    int healthPointMax;
    int armor;
    int moveSpeed;
    int killedGoldAward;

    int lv;
    
    monster_status_e status;
    int moveMask;
    
    int prepareRemainTime;
    int currentHealthPoint;
    
    /* Move in rect */
    int currentMoveDirection;
    int currentMoveCounter;
    CGRect currentMoveRect;
    __weak ChrisMapBox *locatedMapBox;
    
    /* Move in map */
    int currentPathIndex;
    
    /* ANGRY time counter */
    int extraCounter;
    
    /* Slow Donw */
    int speedDown;
    int freezeCounter;
    
    /* Poisoning */
    int singleHurt;
    int poisonHurtCounter;
    int poisoningCounter;
    
    /* Draw */
    CGRect frame;
 
    int imageCounter;
    NSMutableArray *imageArray;
    UIImage *iconImage;
}
@property (nonatomic,weak) id<ChrisMonsterDatasource, ChrisMonsterDelegate> delegate;

@property (nonatomic) CGRect frame;
@property (nonatomic) int type;
@property (nonatomic) int healthPointMax;
@property (nonatomic) int armor;
@property (nonatomic) int moveSpeed;
@property (nonatomic) int killedGoldAward;

@property (nonatomic) int moveMask;
@property (nonatomic) int singleHurt;

@property (nonatomic, readonly) NSMutableArray *imageArray;
@property (nonatomic, readonly) UIImage *iconImage;

@property (nonatomic, readonly) monster_status_e status;
@property (nonatomic) int prepareTime;
@property (nonatomic, weak, readonly) ChrisMapBox *locatedMapBox;
@property (nonatomic, readonly) int currentPathIndex;
@property (nonatomic, readonly) int currentMoveDirection;

@property (nonatomic,readonly) int currentHealthPoint;

+ (NSString *)monsterKeyWithType:(int)type;
+ (NSString *)getImagePathByType:(int)type;

- (void)selfStatusHandle;

- (BOOL)createImage;
- (UIImage *)displayImage;

- (BOOL)isActive;
- (void)startWithPrepareTime:(int)preTime;
- (void)getHurtWithAttack:(int)atk;
- (void)freezing;
- (void)poisoningWithAttack:(int)atk;
- (int)recommendKilledGoldAward;
- (void)strengthenWithWaveIndex:(int)index;

- (UIImage *)currentImage;
- (void)drawMonsterWithContext:(CGContextRef)context;

@end
