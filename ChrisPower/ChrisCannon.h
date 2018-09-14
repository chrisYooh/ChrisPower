//
//  ChrisCannon.h
//  ChrisPower
//
//  Created by Chris on 14/12/10.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "GameConfig.h"

typedef enum cannon_status_ {
    CANNON_STATUS_PREPARE = 0,
    CANNON_STATUS_MOVE = 1,
    CANNON_STATUS_BLAST = 2,
    CANNON_STATUS_REMOVE = 3,
} cannon_status_e;

#define CANNON_MAGIC_MASK_TRACE       (1 << 0)
#define CANNON_MAGIC_MASK_SPEEDUP     (1 << 1)
#define CANNON_MAGIC_MASK_FIRE        (1 << 2)
#define CANNON_MAGIC_MASK_ICE         (1 << 3)
#define CANNON_MAGIC_MASK_GAS         (1 << 4)

#define CANNON_MAGIC_MASK_SET(move_mask, mask)      move_mask |= (mask)
#define CANNON_MAGIC_MASK_CLEAR(move_mask, mask)    move_mask &= ~(mask)
#define CANNON_MAGIC_MASK_CHECK(move_mask, mask)    (((move_mask) & (mask)) ? YES : NO)

/* TODO: just for test */
#define CANNON_TRACE_COST       20
#define CANNON_SPEEDUP_COST     20
#define CANNON_FIRE_COST        88
#define CANNON_ICE_COST         88
#define CANNON_GAS_COST         88

@class ChrisMonster;
@class ChrisCannon;
@class ChrisMapBox;
@class ChrisTower;

@protocol ChrisCannonDatasource <NSObject>

- (ChrisMap *)cannonMap:(ChrisCannon *)cannon;

@end

@protocol ChrisCannonDelegate <NSObject>

@optional
- (void)cannon:(ChrisCannon *)cannon didHurtTarget:(ChrisMonster *)monster withAttack:(int)attack;
- (void)cannonDidRemove:(ChrisCannon *)cannon;

@end

@interface ChrisCannon : NSObject <NSCoding, GameConfigProtocol>
{
    double attackMul;
    
    int type;
    int magicMask;
    
    int attack;
    int ignoreArmor;
    int moveSpeed;
    
    int lv;
    
    cannon_status_e status;
    
    /* For move */
    float moveSpeedX;
    float moveSpeedY;

    __weak ChrisMonster *target;
    __weak ChrisMonster *blustMonster;
    
    CGRect frame;
    int imageCounter;
    NSMutableArray *imageArray;
    UIImage *iconImage;
}
@property (nonatomic, weak) id<ChrisCannonDatasource, ChrisCannonDelegate> delegate;
@property (nonatomic) CGRect frame;

@property (nonatomic) int type;
@property (nonatomic) int magicMask;
@property (nonatomic) int attack;
@property (nonatomic) int ignoreArmor;
@property (nonatomic) int moveSpeed;
@property (nonatomic, readonly) NSMutableArray *imageArray;
@property (nonatomic, readonly) UIImage *iconImage;

@property (nonatomic, readonly) cannon_status_e status;
@property (nonatomic, weak) ChrisMonster *target;

+ (NSString *)cannonKeyWithType:(int)type;
+ (NSString *)getImagePathByType:(int)type;

- (void)selfStatusHandle;

- (BOOL)createImage;
- (UIImage *)displayImage;

- (void)startWithTarget:(ChrisMonster *)target tower:(ChrisTower *)tower;

- (void)drawCannonWithContext:(CGContextRef)context;

@end
