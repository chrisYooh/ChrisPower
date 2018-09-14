//
//  ChrisMap.h
//  ChrisPower
//
//  Created by Chris on 14/12/8.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "GameConfig.h"

enum {
    MAP_BOX_SCOPE_ORDER_DEFAULT = 0,
    MAP_BOX_SCOPE_ORDER_IN2OUT = 1,
};

enum {
    MAP_BOX_FILTER_MASK_LEFT_UP = 1 << 0,
    MAP_BOX_FILTER_MASK_UP = 1 << 1,
    MAP_BOX_FILTER_MASK_RIGHT_UP = 1 << 2,
    MAP_BOX_FILTER_MASK_RIGHT = 1 << 3,
    MAP_BOX_FILTER_MASK_RIGHT_DOWN = 1 << 4,
    MAP_BOX_FILTER_MASK_DOWN = 1 << 5,
    MAP_BOX_FILTER_MASK_LEFT_DOWN = 1 << 6,
    MAP_BOX_FILTER_MASK_LEFT = 1 << 7,
};

#define MAP_BOX_FILTER_MASK_SET(filter_mask, mask)      filter_mask |= (mask)
#define MAP_BOX_FILTER_MASK_CLEAR(filter_mask, mask)    filter_mask &= ~(mask)
#define MAP_BOX_FILTER_MASK_CHECK(filter_mask, mask)    ((filter_mask) & (mask))

@class ChrisMapBox;
@class ChrisMapPathItem;
@class Level;

@interface ChrisMap : NSObject <NSCoding, GameConfigProtocol>
{
    __weak Level *levelInfo;
    
    /* Map boxes number */
    int mapBoxRolNumber;
    int mapBoxColNumber;
    
    /* Map boxes size */
    int mapBoxWidthBits;
    int mapBoxHeightBits;
    
    /* Map information, for example */
    int *mapInfo;
    NSMutableArray *mapBoxArray;
    NSLock *mapboxDrawLocker;
    
    /*Path infromation */
    NSMutableArray *path;
    CGPoint pathStart;
    CGPoint pathEnd;
    NSLock *mapPathDrawLocker;
    
    /* Draw related attributes */
    CGRect frame;
    float frameLineWidth;
    float mapBoxLineWidth ;
}
@property (nonatomic, readonly) CGRect frame;
@property (nonatomic) float frameLineWidth;
@property (nonatomic) float mapBoxLineWidth;

@property (nonatomic, readonly) int mapBoxColNumber;
@property (nonatomic, readonly) int mapBoxRolNumber;

@property (nonatomic, readonly) int mapBoxWidthBits;
@property (nonatomic, readonly) int mapBoxHeightBits;

@property (nonatomic, readonly) int *mapInfo;

- (id)initWithMapBoxColNumber:(int)width rolNumber:(int)height;
- (void)extraInit;

- (void)updateMapFrameOrigin:(CGPoint)point;

- (void)resetMapWithMapBoxColNumber:(int)width rolNumber:(int)height;
- (void)setMapBoxType:(int)type atTouchPoint:(CGPoint)point;

/* Path Operations */
- (ChrisMapPathItem *)pathItemAtIndex:(int)index;
- (BOOL)isEndPath:(int)pathIndex;
- (int)getNextPathIndexByCurrentPathIndex:(int)curIndex;

- (int)createDynamicPath;

/* Map Box Operations */
- (CGPoint)mapBoxGetIndexByCoordinate:(CGPoint)coordinate;
- (int)mapBoxGetArrayIndexByIndex:(CGPoint)index;
- (ChrisMapBox *)mapBoxAtIndex:(CGPoint)index;
- (ChrisMapBox *)mapBoxAtTouchPoint:(CGPoint)point;
- (ChrisMapBox *)getMapBoxByPathIndex:(int)pathIndex;

- (NSMutableArray *)getCircleScopeMapBoxesWithCenter:(CGPoint)center
                                              radius:(int)radius
                                               order:(int)order
                                           boxFilter:(BOOL(^)(ChrisMapBox *box))filter;

- (int)resetCircleScopeMapBoxes:(NSMutableArray *)circleScope
                     withCenter:(CGPoint)center
                         radius:(int)radius
                           order:(int)order
                      boxFilter:(BOOL(^)(ChrisMapBox *box))filter;

- (int)calcDistanceSquareFormPoint:(CGPoint)point toMapBox:(ChrisMapBox *)box;

#pragma mark misc
- (void)mapClear;
- (BOOL)updateMapInfoWithInfo:(const int *)info itemNumber:(int)number;
- (BOOL)setPathStartEndByMapInfo;

/* Draw */
- (void)drawMapFrameWithContext:(CGContextRef)context;
- (void)drawMapBoxesWithContext:(CGContextRef)context;
- (void)drawMapPathWithContext:(CGContextRef)context;

@end
