//
//  ChrisMap.m
//  ChrisPower
//
//  Created by Chris on 14/12/8.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "ChrisMapBox.h"
#import "ChrisMapPathItem.h"

#import "ChrisMap.h"

#define ARRAY_INDEX(x, y)   ((y) * mapBoxColNumber + (x))

@interface ChrisMap()

/* Help to create dynamic path */
- (int *)createCounterMap;
- (void)deleteCounterMap:(int *)counterMap;
- (int)mapFillPathWithCounterMap:(int *)counterMap;
- (int)mapFillPathDirection;

@end

@implementation ChrisMap
@synthesize frame;
@synthesize frameLineWidth, mapBoxLineWidth;

@synthesize mapBoxColNumber, mapBoxRolNumber;
@synthesize mapBoxWidthBits, mapBoxHeightBits;
@synthesize mapInfo;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        
        mapBoxRolNumber = [aDecoder decodeIntForKey:@"mapBoxRolNumber"];
        mapBoxColNumber = [aDecoder decodeIntForKey:@"mapBoxColNumber"];
        
        mapBoxWidthBits = [aDecoder decodeIntForKey:@"mapBoxWidthBits"];
        mapBoxHeightBits = [aDecoder decodeIntForKey:@"mapBoxHeightBits"];
        

        const char *tmpMapInfo = (void *)[aDecoder decodeBytesForKey:@"mapInfo" returnedLength:nil];
        mapInfo = malloc(sizeof(int) * mapBoxRolNumber * mapBoxColNumber);
        memcpy(mapInfo, tmpMapInfo, sizeof(int) * mapBoxRolNumber * mapBoxColNumber);
        
        frame.origin = [aDecoder decodeCGPointForKey:@"mapFrameOrigin"];
        frame.size.width = mapBoxColNumber * mapBoxWidthBits;
        frame.size.height = mapBoxRolNumber * mapBoxHeightBits;
    }

    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (id)initWithMapBoxColNumber:(int)width rolNumber:(int)height
{
    self = [super init];
    
    if (self) {
        
        mapBoxRolNumber = height;
        mapBoxColNumber = width;
        
        mapBoxWidthBits = 50;
        mapBoxHeightBits = 50;
        
        frame.origin = CGPointMake(10, 10);
        frame.size.width = mapBoxColNumber * mapBoxWidthBits;
        frame.size.height = mapBoxRolNumber * mapBoxHeightBits;
        
        frameLineWidth = 10;
        mapBoxLineWidth = 1;
        
        mapInfo = malloc(sizeof(int) * mapBoxRolNumber * mapBoxColNumber);
        memset(mapInfo, 0, (sizeof(int) * mapBoxRolNumber * mapBoxColNumber));
    }
    
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (id)initWithInstance:(ChrisMap *)otherMap
{
    self = [super init];
    
    if (self) {
        [self forceCopyBasicInfoFromMap:otherMap];
    }
    
    return self;
}

- (void)dealloc
{
    free(mapInfo);
    mapInfo = nil;
}

- (BOOL)setPathStartEndByMapInfo
{
    BOOL startP = NO;
    BOOL endP = NO;
    
    for (int i = 0; i < mapBoxRolNumber; i++) {
        
        for (int j = 0; j < mapBoxColNumber; j++) {
            
            int type = mapInfo[i * mapBoxColNumber + j];
            
            if (MAP_BOX_TYPE_START == type) {
                pathStart = CGPointMake(j, i);
                startP = YES;
            } else if (MAP_BOX_TYPE_END == type) {
                pathEnd = CGPointMake(j, i);
                endP = YES;
            }

        } /* for j */
        
    } /* for i */
    
    if (YES == startP && YES == endP) {
        return YES;
    } else {
        return NO;
    }
}

- (NSMutableArray *)createMapBoxArray
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    if (nil == newArray) {
        return nil;
    }
    
    for (int i = 0; i < mapBoxRolNumber; i++) {
        
        for (int j = 0; j < mapBoxColNumber; j++) {
            
            int type = mapInfo[i * mapBoxColNumber +j];
            
            ChrisMapBox *box = [[ChrisMapBox alloc] init];
            [box setType:type];
            [box setFrame:CGRectMake(frame.origin.x + j * mapBoxWidthBits, frame.origin.y + i * mapBoxHeightBits, mapBoxWidthBits, mapBoxHeightBits)];
            
            [newArray addObject:box];
        }
    }
    
    return newArray;
}

#pragma mark 1. Attributes Basic Operations
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:mapBoxRolNumber forKey:@"mapBoxRolNumber"];
    [aCoder encodeInt:mapBoxColNumber forKey:@"mapBoxColNumber"];
    
    [aCoder encodeInt:mapBoxWidthBits forKey:@"mapBoxWidthBits"];
    [aCoder encodeInt:mapBoxHeightBits forKey:@"mapBoxHeightBits"];
    
    [aCoder encodeCGPoint:frame.origin forKey:@"mapFrameOrigin"];
    
    [aCoder encodeBytes:(void *)mapInfo length:(mapBoxRolNumber * mapBoxColNumber * sizeof(int)) forKey:@"mapInfo"];
}
- (BOOL)updateMapInfoWithInfo:(const int *)info itemNumber:(int)number
{
    if ((mapBoxRolNumber * mapBoxColNumber) != number) {
        return NO;
    }
    
    memcpy(mapInfo, info, sizeof(int) * number);
    
    return YES;
}

- (BOOL)updateWithInstance:(ChrisMap *)otherMap
{
    [self forceCopyBasicInfoFromMap:otherMap];
    return YES;
}

- (void)forceCopyBasicInfoFromMap:(ChrisMap *)otherMap
{
    mapBoxRolNumber = otherMap.mapBoxRolNumber;
    mapBoxColNumber = otherMap.mapBoxColNumber;
    
    mapBoxWidthBits = otherMap.mapBoxWidthBits;
    mapBoxHeightBits = otherMap.mapBoxHeightBits;
    
    frame = otherMap.frame;
    
    free(mapInfo);
    mapInfo = malloc(sizeof(int) * mapBoxRolNumber * mapBoxColNumber);
    memcpy(mapInfo, otherMap.mapInfo, sizeof(int) * mapBoxRolNumber * mapBoxColNumber);
}

- (void)extraInit
{
    mapboxDrawLocker = [[NSLock alloc] init];
    mapPathDrawLocker = [[NSLock alloc] init];
    
    frameLineWidth = 10;
    mapBoxLineWidth = 1;
    
    [self setPathStartEndByMapInfo];
    mapBoxArray = [self createMapBoxArray];
    
    path = [[NSMutableArray alloc] init];
    [self createDynamicPath];
}

- (void)updateMapFrameOrigin:(CGPoint)point
{
    float xAdd = point.x - frame.origin.x;
    float yAdd = point.y - frame.origin.y;
    
    for (ChrisMapBox *box in mapBoxArray) {
        CGPoint newOrigin = CGPointMake(box.frame.origin.x + xAdd, box.frame.origin.y + yAdd);
        [box setFrameOrigin:newOrigin];
    }
    
    frame.origin = point;
}

- (void)resetMapWithMapBoxColNumber:(int)width rolNumber:(int)height
{
    mapBoxRolNumber = height;
    mapBoxColNumber = width;
    
    frame.size.width = mapBoxColNumber * mapBoxWidthBits;
    frame.size.height = mapBoxRolNumber * mapBoxHeightBits;
    
    free(mapInfo);
    mapInfo = malloc(sizeof(int) * mapBoxRolNumber * mapBoxColNumber);
    memset(mapInfo, 0, (sizeof(int) * mapBoxRolNumber * mapBoxColNumber));
}

- (void)setMapBoxType:(int)type atTouchPoint:(CGPoint)point
{
    CGPoint index = [self mapBoxGetIndexByCoordinate:point];
    int arrayIndex = [self mapBoxGetArrayIndexByIndex:index];
    
    mapInfo[arrayIndex] = type;
}

- (void)mapClear
{
    free(mapInfo);
    mapInfo = nil;
    
    [path removeAllObjects];
    path = nil;
    
    [mapboxDrawLocker lock];
    [mapBoxArray removeAllObjects];
    mapBoxArray = nil;
    [mapboxDrawLocker unlock];
    
    NSLog(@"<%s:%d>", __func__, __LINE__);
}

#pragma mark Path Operation
- (ChrisMapPathItem *)pathItemAtIndex:(int)index
{
    if (nil == path) {
        return nil;
    }
    
    if (index >= [path count]) {
        NSLog(@"<%s:%d> Get path item failed!", __func__, __LINE__);
        return nil;
    }
    
    return [path objectAtIndex:index];
}

- (BOOL)isEndPath:(int)pathIndex
{
    if (nil == path) {
        return YES;
    }
    
    if (pathIndex == path.count - 1) {
        return YES;
    }
    
    return NO;
}

- (int)getNextPathIndexByCurrentPathIndex:(int)curIndex
{
    return curIndex + 1;
}

- (int)createDynamicPath
{
    int *counterMap = nil;

    counterMap = [self createCounterMap];
    if (nil == counterMap) {
        return -1;
    }
    
    [self mapFillPathWithCounterMap:counterMap];
    [self deleteCounterMap:counterMap];
    
    return 0;
}

#pragma mark Counter map related
static int MAPPATH_UNVALID = -1;
static int MAPPATH_NOSET = 0;

- (int *)createCounterMap
{
    int *counterMap = nil;
    int mapBoxNumber = mapBoxColNumber * mapBoxRolNumber;
    
    /* Prepare 1 : alloc counter map */
    counterMap = malloc(mapBoxNumber * sizeof(int));
    if (nil == counterMap) {
        NSLog(@"ERROR!");
        return nil;
    }

    /* Prepare 2 : counter map intial */
    for (int i = 0; i < mapBoxNumber; i++) {
        
        if (MAP_BOX_TYPE_START == mapInfo[i]
            || MAP_BOX_TYPE_END == mapInfo[i]
            || MAP_BOX_TYPE_WALKWAY == mapInfo[i]) {
            
            counterMap[i] = MAPPATH_NOSET;
            
        } else {
            
            /* HILL & STONE */
            counterMap[i] = MAPPATH_UNVALID;
            
        }
    }
    
    /* Use NSMutableArray as a queue to help fill counterMap */
    NSMutableArray *tmpQueue = [[NSMutableArray alloc] init];
    
    /* Set start value */
    [tmpQueue addObject:[NSValue valueWithCGPoint:pathStart]];
    counterMap[ARRAY_INDEX((int)pathStart.x, (int)pathStart.y)] = 1;
    
    /* For every point, the related point fill order is left, up, right, down */
    while (0 != [tmpQueue count]) {
        
        CGPoint tmpPoint = [[tmpQueue objectAtIndex:0] CGPointValue];
        
        NSLog(@"Point: %f, %f, value = %d, arrayCount = %d", tmpPoint.x, tmpPoint.y, counterMap[ARRAY_INDEX((int)tmpPoint.x, (int)tmpPoint.y)], (int)[tmpQueue count] );
        
        if (pathEnd.x == tmpPoint.x && pathEnd.y == tmpPoint.y) {
            NSLog(@"Find the end of the map!");
            return counterMap;
        }
        
        int tx = tmpPoint.x;
        int ty = tmpPoint.y;
        int value = counterMap[ARRAY_INDEX(tx, ty)];
        
        if ((0 != tx) && (MAPPATH_NOSET == counterMap[ARRAY_INDEX(tx - 1, ty)])) {
            counterMap[ARRAY_INDEX(tx - 1, ty)] = value + 1;
            [tmpQueue addObject:[NSValue valueWithCGPoint:CGPointMake(tx - 1, ty)]];
        }
        
        if ((0 != ty) && (MAPPATH_NOSET == counterMap[ARRAY_INDEX(tx, ty - 1)])) {
            counterMap[ARRAY_INDEX(tx, ty - 1)] = value + 1;
            [tmpQueue addObject:[NSValue valueWithCGPoint:CGPointMake(tx, ty - 1)]];
        }
        
        if (((mapBoxColNumber - 1) != tx) && (MAPPATH_NOSET == counterMap[ARRAY_INDEX(tx + 1, ty)])) {
            counterMap[ARRAY_INDEX(tx + 1, ty)] = value + 1;
            [tmpQueue addObject:[NSValue valueWithCGPoint:CGPointMake(tx + 1, ty)]];
        }
        
        if (((mapBoxRolNumber - 1) != ty) && (MAPPATH_NOSET == counterMap[ARRAY_INDEX(tx, ty + 1)])) {
            counterMap[ARRAY_INDEX(tx, ty + 1)] = value + 1;
            [tmpQueue addObject:[NSValue valueWithCGPoint:CGPointMake(tx, ty + 1)]];
        }
        
        [tmpQueue removeObjectAtIndex:0];
    }
    
    free(counterMap);
    counterMap = nil;
    
    return nil;
}

- (void)deleteCounterMap:(int *)counterMap
{
    if (nil == counterMap) {
        return;
    }
    
    free(counterMap);
    counterMap = nil;
}

- (int)mapFillPathWithCounterMap:(int *)counterMap
{
    int tx = pathEnd.x;
    int ty = pathEnd.y;
    int val = counterMap[ARRAY_INDEX(tx, ty)];
    
    while (val > 0) {
        ChrisMapPathItem *pathItem = [[ChrisMapPathItem alloc] init];
        
        pathItem.pos = CGPointMake(tx, ty);
        [path insertObject:pathItem atIndex:0];
        NSLog(@"Path item %f, %f", pathItem.pos.x, pathItem.pos.y);
        
        val--;
        
        if ((0 != tx) && (val == counterMap[ARRAY_INDEX(tx - 1, ty)])) {
            tx--;
        } else if ((0 != ty) && (val == counterMap[ARRAY_INDEX(tx, ty - 1)])) {
            ty--;
        } else if (((mapBoxColNumber - 1) != tx) && val == counterMap[ARRAY_INDEX(tx +1, ty)]) {
            tx++;
        } else if (((mapBoxRolNumber - 1) != ty) && val == counterMap[ARRAY_INDEX(tx, ty + 1)]) {
            ty++;
        } else {
            NSLog(@"<%s:%d> Block path, value = %d", __func__, __LINE__, val);
        }
        
    }
    
    [self mapFillPathDirection];
    
    return 0;
}

- (int)mapFillPathDirection
{
    ChrisMapPathItem *cur = nil, *next = nil;
    int curIn = LEFT, curOut = 0, nextIn = 0;
    
    if (0 == [path count]) {
        NSLog(@"<%s:%d> No path information", __func__, __LINE__);
        return -1;
    }
    
    /* Traverse all path item and set direction */
    for (int i = 0; i < [path count] - 1; i++) {
        cur = [path objectAtIndex:i];
        next = [path objectAtIndex:i + 1];
        
        if (next.pos.x > cur.pos.x) {
            curOut = RIGHT;
            nextIn = LEFT;
        } else if (next.pos.x < cur.pos.x) {
            curOut = LEFT;
            nextIn = RIGHT;
        } else if (next.pos.y > cur.pos.y) {
            curOut = DOWN;
            nextIn = UP;
        } else if (next.pos.y < cur.pos.y) {
            curOut = UP;
            nextIn = DOWN;
        } else {
            NSLog(@"<%s,%d> ERROR", __func__, __LINE__);
        }
        
        NSLog(@"in %d, out %d", curIn, curOut);
        [cur setDirection:DIRECTION_COMPILE(curIn, curOut)];
        
        curIn = nextIn;
    }
    
    /* Operate the end item */
    cur = [path objectAtIndex:([path count] - 1)];
    if (0 == cur.pos.x) {
        curOut = LEFT;
    } else if (0 == cur.pos.y) {
        curOut = UP;
    } else if ((mapBoxColNumber - 1) == cur.pos.x ) {
        curOut = RIGHT;
    } else if ((mapBoxRolNumber - 1) == cur.pos.y) {
        curOut = DOWN;
    } else {
        curOut = DIRECTION_REVERSE(curIn);
    }
    
    if (curIn == curOut) {
        curOut = REVERSE_SUM - curIn;
    }
    
    [cur setDirection:DIRECTION_COMPILE(curIn, curOut)];
    
    return 0;
}

#pragma mark MapBox Operations
- (CGPoint)mapBoxGetIndexByCoordinate:(CGPoint)coordinate
{
    int tx = coordinate.x;
    int ty = coordinate.y;
    
    tx = (tx >= frame.origin.x) ? ((coordinate.x - frame.origin.x) / mapBoxWidthBits) : -1;
    ty = (ty >= frame.origin.y) ? ((coordinate.y - frame.origin.y) / mapBoxHeightBits) : -1;
    
    return CGPointMake(tx, ty);
}

- (int)mapBoxGetArrayIndexByIndex:(CGPoint)index
{
    if (index.x < 0 || index.x >= mapBoxColNumber
        || index.y < 0 || index.y >= mapBoxRolNumber) {
        return -1;
    }
    
    return index.y * mapBoxColNumber + index.x;
}

- (ChrisMapBox *)mapBoxAtIndex:(CGPoint)index
{
    int arrayIndex = [self mapBoxGetArrayIndexByIndex:index];
    
    if (arrayIndex < 0 || arrayIndex > (mapBoxArray.count - 1)) {
        return nil;
    }
    
    return [mapBoxArray objectAtIndex:arrayIndex];
}

- (ChrisMapBox *)mapBoxAtTouchPoint:(CGPoint)point
{
    return [self mapBoxAtIndex:[self mapBoxGetIndexByCoordinate:point]];
}

- (ChrisMapBox *)getMapBoxByPathIndex:(int)pathIndex
{
    if (pathIndex >= (path.count - 1)) {
        return nil;
    }
    
    ChrisMapPathItem *item = [path objectAtIndex:pathIndex];
    
    return [self mapBoxAtIndex:item.pos];
}

- (NSMutableArray *)getCircleScopeMapBoxesWithCenter:(CGPoint)center
                                              radius:(int)radius
                                               order:(int)order
                                           boxFilter:(BOOL (^)(ChrisMapBox *))filter
{
    if (0 == radius) {
        return nil;
    }
    
    float radiusSquare = powf(radius, 2);
    
    NSMutableArray *boxArray = [[NSMutableArray alloc] init];
    NSMutableArray *tmpQueue = [[NSMutableArray alloc] init];
    
    char *scopeMask = malloc(sizeof(char) * mapBoxColNumber * mapBoxRolNumber);
    memset(scopeMask, 0, sizeof(char) * mapBoxColNumber * mapBoxRolNumber);
    
    ChrisMapBox *tmpBox = [self mapBoxAtTouchPoint:center];
    if (nil != tmpBox) {
        [tmpQueue addObject:[self mapBoxAtTouchPoint:center]];
    }
    
    while (0 != [tmpQueue count]) {
        
        ChrisMapBox *curBox = [tmpQueue objectAtIndex:0];
        
        if ([self calcDistanceSquareFormPoint:center toMapBox:curBox] >= radiusSquare) {
            [tmpQueue removeObject:curBox];
            continue;
        }
        
        if (filter(curBox)) {
            [boxArray addObject:curBox];
        }

        /* Init mask by filter */
        CGPoint boxIndex = [self mapBoxGetIndexByCoordinate:curBox.frame.origin];
        int tmpArrayIndex = 0;
        int tx = boxIndex.x;
        int ty = boxIndex.y;
        ChrisMapBox *tmpBox = nil;
        
        /* Left */
//        NSLog(@"<%s:%d> Left analysis", __func__, __LINE__);
        tmpArrayIndex = ARRAY_INDEX(tx - 1, ty);
        if ((0 < tx) && !scopeMask[tmpArrayIndex]) {
            tmpBox = [mapBoxArray objectAtIndex:tmpArrayIndex];
            [tmpQueue addObject:tmpBox];
            scopeMask[tmpArrayIndex] = 1;
        }
        
        /* Right */
//        NSLog(@"<%s:%d> Right analysis", __func__, __LINE__);
        tmpArrayIndex = ARRAY_INDEX(tx + 1, ty);
        if (((mapBoxColNumber - 1) > tx) && !scopeMask[tmpArrayIndex]) {
            tmpBox = [mapBoxArray objectAtIndex:tmpArrayIndex];
            [tmpQueue addObject:tmpBox];
            scopeMask[tmpArrayIndex] = 1;
        }
        
        /* Up */
//        NSLog(@"<%s:%d> Up analysis", __func__, __LINE__);
        tmpArrayIndex = ARRAY_INDEX(tx, ty - 1);
        if ((0 < ty) && !scopeMask[tmpArrayIndex]) {
            tmpBox = [mapBoxArray objectAtIndex:tmpArrayIndex];
            [tmpQueue addObject:tmpBox];
            scopeMask[tmpArrayIndex] = 1;
        }
        
        /* Down */
//        NSLog(@"<%s:%d> Down analysis", __func__, __LINE__);
        tmpArrayIndex = ARRAY_INDEX(tx, ty + 1);
        if (((mapBoxRolNumber - 1) > ty) && !scopeMask[tmpArrayIndex]) {
            tmpBox = [mapBoxArray objectAtIndex:tmpArrayIndex];
            [tmpQueue addObject:tmpBox];
            scopeMask[tmpArrayIndex] = 1;
        }
        
        /* Left Up */
//        NSLog(@"<%s:%d> Left Up analysis", __func__, __LINE__);
        tmpArrayIndex = ARRAY_INDEX(tx - 1, ty - 1);
        if ((0 < tx) && (0 < ty) && !scopeMask[tmpArrayIndex]) {
            tmpBox = [mapBoxArray objectAtIndex:tmpArrayIndex];
            [tmpQueue addObject:tmpBox];
            scopeMask[tmpArrayIndex] = 1;
        }
        
        /* Left Down */
//        NSLog(@"<%s:%d> Left Down analysis", __func__, __LINE__);
        tmpArrayIndex = ARRAY_INDEX(tx - 1, ty + 1);
        if ((0 < tx) && ((mapBoxRolNumber - 1) > ty) && !scopeMask[tmpArrayIndex]) {
            tmpBox = [mapBoxArray objectAtIndex:tmpArrayIndex];
            [tmpQueue addObject:tmpBox];
            scopeMask[tmpArrayIndex] = 1;
        }
        
        /* Right Up */
//        NSLog(@"<%s:%d> Right Up analysis", __func__, __LINE__);
        tmpArrayIndex = ARRAY_INDEX(tx + 1, ty - 1);
        if (((mapBoxColNumber - 1) > tx) && (0 < ty) && !scopeMask[tmpArrayIndex]) {
            tmpBox = [mapBoxArray objectAtIndex:tmpArrayIndex];
            [tmpQueue addObject:tmpBox];
            scopeMask[tmpArrayIndex] = 1;
        }
        
        /* Right Down */
//        NSLog(@"<%s:%d> Right Down analysis", __func__, __LINE__);
        tmpArrayIndex = ARRAY_INDEX(tx + 1, ty + 1);
        if (((mapBoxColNumber - 1) > tx) && ((mapBoxRolNumber - 1) > ty) && !scopeMask[tmpArrayIndex]) {
            tmpBox = [mapBoxArray objectAtIndex:tmpArrayIndex];
            [tmpQueue addObject:tmpBox];
            scopeMask[tmpArrayIndex] = 1;
        }

        [tmpQueue removeObject:curBox];
    }
    
    free(scopeMask);
    scopeMask = nil;
    
    return boxArray;
}

- (int)resetCircleScopeMapBoxes:(NSMutableArray *)circleScope
                     withCenter:(CGPoint)center
                         radius:(int)radius
                          order:(int)order
                      boxFilter:(BOOL (^)(ChrisMapBox *))filter
{
    [circleScope removeAllObjects];
    
    [circleScope addObjectsFromArray:[self getCircleScopeMapBoxesWithCenter:center
                                                                    radius:radius
                                                                     order:order
                                                                 boxFilter:filter]];
    return 0;
}

- (int)calcDistanceSquareFormPoint:(CGPoint)point toMapBox:(ChrisMapBox *)box
{
    int distanceSquare = 0;
    
    CGPoint leftUp = box.frame.origin;
    CGPoint rightDown = CGPointMake(box.frame.origin.x + box.frame.size.width, box.frame.origin.y + box.frame.size.height);
    
    if ((rightDown.x < point.x) && (rightDown.y < point.y)) {
        /* On left up */
        distanceSquare = pow(rightDown.x - point.x, 2) + pow(rightDown.y - point.y, 2);
    } else if ((leftUp.x < point.x) && (rightDown.x > point.x) && (rightDown.y < point.y)) {
        /* On up */
        distanceSquare = pow(rightDown.y - point.y, 2);
    } else if ((leftUp.x > point.x) && (rightDown.y < point.y)) {
        /* On right up */
        distanceSquare = pow(leftUp.x - point.x, 2) + pow(rightDown.y - point.y, 2);
    } else if ((leftUp.y < point.y) && (rightDown.y > point.y) && (leftUp.x > point.x)) {
        /* On right */
        distanceSquare = pow(leftUp.x - point.x, 2);
    } else if ((leftUp.x > point.x) && (leftUp.y > point.y)) {
        /* On right down */
        distanceSquare = pow(leftUp.x - point.x, 2) + pow(leftUp.y - point.y, 2);
    } else if ((leftUp.x < point.x) && (rightDown.x > point.x) && (leftUp.y > point.y)) {
        /* On down */
        distanceSquare = pow(leftUp.y - point.y, 2);
    } else if ((rightDown.x < point.x) && (leftUp.y > point.y)) {
        /* On left down */
        distanceSquare = pow(rightDown.x - point.x, 2) + pow(leftUp.y - point.y, 2);
    } else if ((leftUp.y < point.y) && (rightDown.y > point.y) && (rightDown.x < point.x)) {
        /* On left */
        distanceSquare = pow(rightDown.x - point.x, 2);
    } else if ((leftUp.x < point.x) && (rightDown.x > point.x) && (leftUp.y < point.y) && (rightDown.y > point.y)) {
        distanceSquare = 0;
        NSLog(@"<%s:%d> Center box", __func__, __LINE__);
    } else {
        NSLog(@"《%s:%d> Direction error %f, %f, %f, %f ---- %f, %f", __func__, __LINE__, leftUp.x, leftUp.y, rightDown.x, rightDown.y, point.x, point.y);
    }
    
    return distanceSquare;
}

#pragma mark Draw Related Functions
- (void)drawMapFrameWithContext:(CGContextRef)context
{
    /* 1. Black Line */
    CGContextSetLineWidth(context, frameLineWidth);
    float lineWidthFixOffset = frameLineWidth / 2;
    [[UIColor blackColor] set];
    
    CGContextMoveToPoint(context, frame.origin.x - frameLineWidth, frame.origin.y - lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width + lineWidthFixOffset, frame.origin.y - lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width + lineWidthFixOffset, frame.origin.y + frame.size.height + lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x - lineWidthFixOffset, frame.origin.y + frame.size.height + lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x - lineWidthFixOffset, frame.origin.y - lineWidthFixOffset);
    CGContextStrokePath(context);
    
    /* 2. White line */
    CGContextSetLineWidth(context, frameLineWidth / 2);
    lineWidthFixOffset = frameLineWidth / 2;
    [[UIColor whiteColor] set];
    
    CGContextMoveToPoint(context, frame.origin.x - frameLineWidth + lineWidthFixOffset / 2, frame.origin.y - lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width + lineWidthFixOffset, frame.origin.y - lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width + lineWidthFixOffset, frame.origin.y + frame.size.height + lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x - lineWidthFixOffset, frame.origin.y + frame.size.height + lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x - lineWidthFixOffset, frame.origin.y - lineWidthFixOffset);
    CGContextStrokePath(context);
}

- (void)drawMapBoxesWithContext:(CGContextRef)context
{
    [mapboxDrawLocker lock];
    for ( ChrisMapBox *box in mapBoxArray) {
        
        [box drawMapBoxWithContext:context];
    }
    [mapboxDrawLocker unlock];
    
    return;
}

- (void)drawMapPathWithContext:(CGContextRef)context
{
    int offsetX = 0;
    int offsetY = 0;
    int curIn = 0, curOut = 0;
    
    for (ChrisMapPathItem *item in path) {
        //        NSLog(@"%@", item);
        
        offsetX = frame.origin.x + mapBoxWidthBits * item.pos.x;
        offsetY = frame.origin.y + mapBoxHeightBits * item.pos.y;
        
        curIn = item.direction >> IN_OFFSET;
        curOut = item.direction % (1 << IN_OFFSET);
        
        [[UIColor colorWithRed:(curIn + 1) / 4.0 green:(curOut + 1) / 4.0 blue:(curIn + 1) * (curOut + 1) / 16.0 alpha: 1] set];
        CGContextMoveToPoint(context, offsetX, offsetY);
        CGContextAddLineToPoint(context, offsetX + 50, offsetY + 50);
        CGContextStrokePath(context);
    }
    
    return;
}

@end

