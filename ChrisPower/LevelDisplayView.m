//
//  LevelDisplayView.m
//  ChrisPower
//
//  Created by Chris on 15/1/13.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "Player.h"

#import "Level.h"
#import "DynamicLevel.h"

#import "LevelDisplayView.h"

static NSComparator compareBlock = ^(LevelDisplayView *obj1,  LevelDisplayView *obj2)
{
    if ( obj1.levelPrimaryIndex > obj2.levelPrimaryIndex) {
        return (NSComparisonResult)NSOrderedDescending;
    } else if ( obj1.levelPrimaryIndex < obj2.levelPrimaryIndex) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    
    if ( obj1.levelSecondaryIndex > obj2.levelSecondaryIndex) {
        return (NSComparisonResult)NSOrderedDescending;
    } else if ( obj1.levelSecondaryIndex < obj2.levelSecondaryIndex) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    
    return (NSComparisonResult)NSOrderedSame;
};

@implementation LevelDisplayView
@synthesize delegate;
@synthesize levelPrimaryIndex;
@synthesize levelSecondaryIndex;

@synthesize locked;

+ (NSComparator)comparator
{
    return compareBlock;
}

- (id)initWithLevelPrimaryIndex:(int)priIndex secondaryIndex:(int)secIndex
{
    self = [super init];
    
    if (self) {
        levelPrimaryIndex = priIndex;
        levelSecondaryIndex = secIndex;
        
        locked = ![[Player currentPlayer] getDynamicLevelByPriIndex:levelPrimaryIndex secIndex:levelSecondaryIndex].valid;
        [self createImage];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updateRects];
}

- (void)createImage
{
    image = [UIImage imageNamed:@"lock.png"];
}

- (void)updateRects
{
    frameLineWidth = 10;
    suggestSpace = 10;
    
    /* levelInfoRect */
    levelInfoRect.size.width = 100;
    levelInfoRect.size.height = 40;
    
    if ((self.bounds.size.width < (levelInfoRect.size.width + suggestSpace * 2))
        || (self.bounds.size.height < (levelInfoRect.size.height + suggestSpace * 2))) {
        levelInfoRect = CGRectZero;
        imageRect = CGRectZero;
        return;
    }
    
    levelInfoRect.origin.x = suggestSpace;
    levelInfoRect.origin.y = self.bounds.size.height - levelInfoRect.size.height - suggestSpace;
    
    /* Image rect */
    int imageSpace = 40;
    int imageWidth = self.bounds.size.width - imageSpace * 2;
    int imageHeight = self.bounds.size.height - suggestSpace * 3 - levelInfoRect.size.height;
    
    if (10 > imageWidth || 10 > imageHeight) {
        imageRect = CGRectZero;
    } else {
        imageRect = CGRectMake(imageSpace, suggestSpace, imageWidth, imageHeight);
    }
}

- (void)levelLockedStatusUpdate
{
    locked = ![[Player currentPlayer] getDynamicLevelByPriIndex:levelPrimaryIndex secIndex:levelSecondaryIndex].valid;
    [self setNeedsDisplay];
}

- (NSDictionary *)levelStrAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [UIFont systemFontOfSize:30], NSFontAttributeName,
            [UIColor blackColor], NSForegroundColorAttributeName,
            nil];

}

- (void)drawViewFrame
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect tmpRect = self.bounds;
    
    /* 1. Black Line */
    CGContextSetLineWidth(context, frameLineWidth);
    [[UIColor blackColor] set];
    CGContextAddRect(context, tmpRect);
    CGContextDrawPath(context, kCGPathStroke);
    
    /* 2. White line */
    CGContextSetLineWidth(context, frameLineWidth * 0.75);
    [[UIColor whiteColor] set];
    CGContextAddRect(context, tmpRect);
    CGContextDrawPath(context, kCGPathStroke);
    
    /* 3. Black Line */
    CGContextSetLineWidth(context, frameLineWidth * 0.25);
    [[UIColor blackColor] set];
    CGContextAddRect(context, tmpRect);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawRect:(CGRect)rect
{
    [self drawViewFrame];
    
    NSString *str = nil;
    
    if (TEACH_LEVEL_PIRMARY_INDEX == levelPrimaryIndex) {
        str = [NSString stringWithFormat:@"试玩%d", levelSecondaryIndex];
    } else if (USER_CREATE_LEVEL_PRIMARY_INDEX == levelPrimaryIndex) {
        str = [NSString stringWithFormat:@"DIY%d", levelSecondaryIndex];
    } else if (TEST_LEVEL_PRIMARY_INDEX == levelPrimaryIndex) {
        str = [NSString stringWithFormat:@"测试%d", levelSecondaryIndex];
    } else if (1 == levelPrimaryIndex){
        str = [NSString stringWithFormat:@"第%d关", levelSecondaryIndex];
    }
    
    [str drawInRect:levelInfoRect withAttributes:[self levelStrAttributes]];
    
    if (NO == locked) {
        [self drawShowedMonsters];
    } else {
        [image drawInRect:imageRect];
    }
}

- (void)drawShowedMonsters
{
    CGRect tmpRect = CGRectZero;
    NSArray *monsterImages = [[self delegate] LevelDisplayViewLevelMonsters:self];
 
    int sideSpace = 8;
    int smaller = 5;
    tmpRect.origin.x = levelInfoRect.origin.x + levelInfoRect.size.width + sideSpace;
    tmpRect.origin.y = levelInfoRect.origin.y + smaller;
    tmpRect.size.width = levelInfoRect.size.height - smaller * 2;
    tmpRect.size.height = levelInfoRect.size.height - smaller * 2;
    
    for (UIImage *tmpImage in monsterImages) {
        [tmpImage drawInRect:tmpRect];
        tmpRect.origin.x += (tmpRect.size.width + sideSpace);
    }
}

@end
