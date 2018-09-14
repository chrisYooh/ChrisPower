//
//  ChrisMapBox.m
//  ChrisPower
//
//  Created by Chris on 14/12/8.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "ChrisMonster.h"

#import "ChrisMapBox.h"

@implementation ChrisMapBox
@synthesize frame;
@synthesize type;
@synthesize tower;
@synthesize monsterArray;

- (id)init
{
    self = [super init];
    
    if (self) {
        monsterArray = [[NSMutableArray alloc] init];
    }

    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);    
    return self;
}

- (CGPoint)center
{
    return CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
}

- (void)setFrameOrigin:(CGPoint)point
{
    frame.origin = point;
}

#pragma mark Monster related operation
- (int)addMonsterAtHead:(ChrisMonster *)monster
{
    if (nil == monsterArray) {
        NSLog(@"<%s:%d> Monster array nil", __func__, __LINE__);
        return -1;
    }
    
    [monsterArray insertObject:monster atIndex:0];
    
    return 0;
}

- (int)addMonsterAtTail:(ChrisMonster *)monster
{
    if (nil == monsterArray) {
        NSLog(@"<%s:%d> Monster array nil", __func__, __LINE__);
        return -1;
    }
    
    [monsterArray addObject:monster];
    
    return 0;
}

- (void)removeMonster:(ChrisMonster *)monster
{
    if (nil == monsterArray) {
        return;
    }
    
    [monsterArray removeObject:monster];
}

-(ChrisMonster *)headerMonster
{
    if ((nil == monsterArray) || (0 == [monsterArray count])) {
        return nil;
    }
    
    return [monsterArray objectAtIndex:0];
}

#pragma mark Tower related operation
- (BOOL)canSetTower
{
    if (nil != tower) {
        NSLog(@"<%s:%d> Mapbox already have a tower!", __func__, __LINE__);
        return NO;
    }
    
    if (MAP_BOX_TYPE_HILL != type) {
        NSLog(@"<%s:%d> Mapbox can't set a tower, type = %d", __func__, __LINE__, type);
        return NO;
    }

    return YES;
}

- (void)removeTower
{
    self.tower = nil;
}

#pragma mark Draw Related Functions
- (void)drawMapBoxWithContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, frame.size.height - 2);
    
    if (MAP_BOX_TYPE_START == type) {
        [[UIColor lightGrayColor] set];
    } else if (MAP_BOX_TYPE_END == type) {
        [[UIColor blackColor] set];
    } else if (MAP_BOX_TYPE_WALKWAY == type) {
        [[UIColor darkGrayColor] set];
    } else if (MAP_BOX_TYPE_STONE == type) {
        [[UIColor clearColor] set];
    } else {
        [[UIColor clearColor] set];
    }
    
    
    int offset = 1;
    CGRect tmpRect = frame;
    tmpRect.origin.x += offset;
    tmpRect.origin.y += offset;
    tmpRect.size.width -= offset * 2;
    tmpRect.size.height -= offset * 2;
    
     UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:tmpRect cornerRadius:10.0f];
    [roundedRect fillWithBlendMode:kCGBlendModeNormal alpha:1];
   
#if 0
    CGContextMoveToPoint(context, frame.origin.x + 1, frame.origin.y + frame.size.height / 2);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width - 1, frame.origin.y + frame.size.height / 2);
    CGContextStrokePath(context);
    
    [[UIColor whiteColor] set];
    CGContextSetLineWidth(context, 1);
    CGContextAddRect(context, frame);
    CGContextStrokePath(context);
#endif

}

@end
