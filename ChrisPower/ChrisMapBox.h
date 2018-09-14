//
//  ChrisMapBox.h
//  ChrisPower
//
//  Created by Chris on 14/12/8.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ChrisMonster;
@class ChrisTower;

enum {
    LEFT = 0,
    UP = 1,
    DOWN = 2,
    RIGHT = 3,
    REVERSE_SUM = 3,
    
    IN_OFFSET = 2,
};
#define DIRECTION_REVERSE(half_dir)     (REVERSE_SUM - (half_dir))
#define DIRECTION_COMPILE(in, out)      (((in) << IN_OFFSET) + out)
#define DIRECTION_IN(dir)               ((dir) >> IN_OFFSET)
#define DIRECTION_OUT(dir)              ((dir) % (1 << IN_OFFSET))

#define DIRECTION_IN_LANDSCAPE(dir)     ((LEFT == DIRECTION_IN(dir)) || (RIGHT == DIRECTION_IN(dir)))
#define DIRECTION_IN_PORTRAIT(dir)      ((UP == DIRECTION_IN(dir)) || (DOWN == DIRECTION_IN(dir)))
#define DIRECTION_OUT_LANDSCAPE(dir)    ((LEFT == DIRECTION_OUT(dir)) || (RIGHT == DIRECTION_OUT(dir)))
#define DIRECTION_OUT_PORTRAIT(dir)     ((UP == DIRECTION_OUT(dir)) || (DOWN == DIRECTION_OUT(dir)))

#define DIRECTION_TURN(dir)             ((DIRECTION_IN_LANDSCAPE(dir) && DIRECTION_OUT_PORTRAIT(dir)) || (DIRECTION_IN_PORTRAIT(dir) && DIRECTION_OUT_LANDSCAPE(dir)))

enum {
    MAP_BOX_TYPE_WALKWAY = 0,
    MAP_BOX_TYPE_HILL = 1,
    MAP_BOX_TYPE_STONE = 2,
    MAP_BOX_TYPE_START = 10,
    MAP_BOX_TYPE_END = 20,
};

@interface ChrisMapBox : NSObject
{
    int type;
    
    NSMutableArray *monsterArray;
    ChrisTower *tower;

    CGRect frame;
}
@property (nonatomic) CGRect frame;
@property (nonatomic) int type;
@property (nonatomic) ChrisTower *tower;
@property (nonatomic, readonly) NSMutableArray *monsterArray;

- (CGPoint)center;

- (void)setFrameOrigin:(CGPoint)point;

/* Monster Operation */
- (int)addMonsterAtHead:(ChrisMonster *)monster;
- (int)addMonsterAtTail:(ChrisMonster *)monster;
- (void)removeMonster:(ChrisMonster *)monster;
-(ChrisMonster *)headerMonster;

/* Tower operation */
- (BOOL)canSetTower;
- (void)removeTower;

/* Draw */
- (void)drawMapBoxWithContext:(CGContextRef)context;

@end
