//
//  ChrisMonster.m
//  ChrisPower
//
//  Created by Chris on 14/12/10.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "ChrisMap.h"
#import "ChrisMapBox.h"
#import "ChrisMapPathItem.h"

#import "Player.h"
#import "DynamicMonster.h"

#import "ChrisMonster.h"

@interface ChrisMonster ()

- (void)preparing;

- (void)move;
- (int)moveInBox;
- (BOOL)moveNextBox;

- (void)attack;

@end

@implementation ChrisMonster
@synthesize delegate;
@synthesize frame;

@synthesize type, healthPointMax, armor, moveSpeed;
@synthesize killedGoldAward;

@synthesize status;
@synthesize prepareTime;
@synthesize locatedMapBox;
@synthesize currentPathIndex;
@synthesize currentMoveDirection;

@synthesize moveMask;
@synthesize singleHurt;

@synthesize imageArray;
@synthesize iconImage;

@synthesize currentHealthPoint;

+ (NSString *)monsterKeyWithType:(int)type
{
    return [NSString stringWithFormat:@"monster%d", type];
}

+ (NSString *)getImagePathByType:(int)type
{
    return [NSString stringWithFormat:@"monster%d.png", type];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        type = [aDecoder decodeIntForKey:@"type"];
        
        healthPointMax = [aDecoder decodeIntForKey:@"healthPoint"];
        armor = [aDecoder decodeIntForKey:@"armor"];
        moveSpeed = [aDecoder decodeIntForKey:@"moveSpeed"];
        killedGoldAward = [aDecoder decodeIntForKey:@"killedGoldAward"];
        
        [self createImage];
    }
    
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (id)initWithInstance:(ChrisMonster *)otherMonster
{
    self = [super init];
    
    if (self) {
        [self forceCopyBasicInfoFromMonster:otherMonster];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Monster%d\n"
            "HP: %d\n"
            "Armor: %d\n"
            "MoveSpeed: %d\n"
            "Gold: %d",
            type, healthPointMax, armor, moveSpeed, killedGoldAward];
}

#pragma mark 1. Attributes Basic Operations
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:type forKey:@"type"];
    
    [aCoder encodeInt:healthPointMax forKey:@"healthPoint"];
    [aCoder encodeInt:armor forKey:@"armor"];
    [aCoder encodeInt:moveSpeed forKey:@"moveSpeed"];
    [aCoder encodeInt:killedGoldAward forKey:@"killedGoldAward"];
}

- (BOOL)updateWithInstance:(ChrisMonster *)otherMonster
{
    [self forceCopyBasicInfoFromMonster:otherMonster];
    return YES;
}

- (void)forceCopyBasicInfoFromMonster:(ChrisMonster *)otherMonster
{
    type = otherMonster.type;
    healthPointMax = otherMonster.healthPointMax;
    armor = otherMonster.armor;
    moveSpeed = otherMonster.moveSpeed;
    killedGoldAward = otherMonster.killedGoldAward;
    
    imageArray = [NSMutableArray arrayWithArray:otherMonster.imageArray];
    iconImage = otherMonster.iconImage;
    frame.size = otherMonster.frame.size;
}

#pragma mark 2. Self AI Control
- (void)selfStatusHandle
{
    if (MONSTER_STATUS_PREPARE == status) {
        [self preparing];
    } else if (MONSTER_STATUS_MOVE == status) {
        [self move];
    } else if (MONSTER_STATUS_ANGRY == status) {
        [self angry];
    } else if (MONSTER_STATUS_CRAZY == status) {
        [self crazy];
    } else if (MONSTER_STATUS_KILLED == status) {
        [self killed];
    } else if (MONSTER_STATUS_ATTACK == status) {
        [self attack];
    } else if (MONSTER_STATUS_REMOVED == status) {
        [self remove];
    } else {
        NSLog(@"<%s:%d> Error status %d", __func__, __LINE__, status);
    }
}

#pragma mark Monster handle status prepare
- (void)preparing
{
    if (0 >= prepareTime) {
        
        currentHealthPoint = healthPointMax;
        currentMoveCounter = 0;
        
        /* Move to first box */
        currentPathIndex = 0;
        locatedMapBox = [[[self delegate] monsterMap:self] getMapBoxByPathIndex:currentPathIndex];
        currentMoveRect = [[[self delegate] monsterMap:self] getMapBoxByPathIndex:currentPathIndex].frame;
        currentMoveDirection = [[[self delegate] monsterMap:self] pathItemAtIndex:currentPathIndex].direction;
        
        frame.origin = currentMoveRect.origin;
        
        status = MONSTER_STATUS_MOVE;
        [[self delegate] monsterDidStartMove:self];
    }
    
    prepareTime--;
}

#pragma mark Monster handle status move/angay/crazy
- (void)basicMove
{
    if (MONSTER_MOVE_MASK_CHECK(moveMask, MONSTER_MOVE_MASK_FREEZING)) {
        if (freezeCounter-- <= 0) {
            moveSpeed += speedDown;
            freezeCounter = 0;
            MONSTER_MOVE_MASK_CLEAR(moveMask, MONSTER_MOVE_MASK_FREEZING);
        }
    }
    
    if (MONSTER_MOVE_MASK_CHECK(moveMask, MONSTER_MOVE_MASK_POISONING)) {
        
        if (poisoningCounter-- <= 0) {
            poisoningCounter = 0;
            poisonHurtCounter = 0;
            MONSTER_MOVE_MASK_CLEAR(moveMask, MONSTER_MOVE_MASK_POISONING);
        } else if (poisonHurtCounter-- <= 0) {
            [self getHurtWithAttack:singleHurt];
            poisonHurtCounter = [[Player currentPlayer] cannonMagicCurrentGasHurtInterval];
        }
    }
    
    if ( MONSTER_MOVE_NEW_BOX == [self moveInBox]) {
        [self moveNextBox];
    }
}

- (void)move
{
    if (currentHealthPoint < healthPointMax / 10) {
        armor += 10;
        moveSpeed += 4;
        status = MONSTER_STATUS_CRAZY;
    } else if((rand() % 10000) < 1) {
        moveSpeed += 2;
        extraCounter = 100;
        status = MONSTER_STATUS_ANGRY;
    }
    
    /* There the monster status may change to MONSTER_STATUS_ATTACK */
    [self basicMove];
}

- (void)angry
{
    extraCounter--;
    if (extraCounter < 0) {
        moveSpeed -= 2;
        status = MONSTER_STATUS_MOVE;
    }
    
    /* There the monster status may change to MONSTER_STATUS_ATTACK */
    [self basicMove];
}

- (void)crazy
{
    [self basicMove];
}

- (int)moveInBox
{
    if ((DIRECTION_OUT_LANDSCAPE(currentMoveDirection) && (currentMoveCounter >= currentMoveRect.size.width))
        || ((DIRECTION_OUT_PORTRAIT(currentMoveDirection) && (currentMoveCounter >= currentMoveRect.size.height)))) {
        
        NSLog(@"<%s:%d> Move stem count %d need be reset, direction = %x, move rect = %f, %f, %f, %f",
              __func__, __LINE__, currentMoveCounter, currentMoveDirection,
              currentMoveRect.origin.x, currentMoveRect.origin.y, currentMoveRect.size.width, currentMoveRect.size.height);
        return -1;
    }
    
    currentMoveCounter += moveSpeed;
    
    /* Set draw offset */
    int outDirection = DIRECTION_OUT(currentMoveDirection);
    if (LEFT == outDirection) {
        frame.origin.x = currentMoveRect.origin.x - currentMoveCounter;
    } else if (RIGHT == outDirection) {
        frame.origin.x = currentMoveRect.origin.x + currentMoveCounter;
    } else if (UP == outDirection) {
        frame.origin.y = currentMoveRect.origin.y - currentMoveCounter;
    } else if (DOWN == outDirection) {
        frame.origin.y = currentMoveRect.origin.y + currentMoveCounter;
    } else {
        NSLog(@"<%s:%d> Invalid out direction %d!", __func__, __LINE__, outDirection);
        return -1;
    }
    
    if ((DIRECTION_OUT_LANDSCAPE(currentMoveDirection) && (currentMoveCounter >= currentMoveRect.size.width))
        || ((DIRECTION_OUT_PORTRAIT(currentMoveDirection) && (currentMoveCounter >= currentMoveRect.size.height)))) {
        
        return MONSTER_MOVE_NEW_BOX;
    } else {
        return MONSTER_MOVE_OLD_BOX;
    }
}

- (BOOL)moveNextBox
{
    [[self delegate] monsterWillMoveToNewRect:self];
    
    int out = DIRECTION_OUT(currentMoveDirection);
    if ((LEFT == out) || (RIGHT == out)) {
        currentMoveCounter %= (int)currentMoveRect.size.width;
    } else {
        currentMoveCounter %= (int)currentMoveRect.size.height;
    }
    
    /* If the direction turned( landscape <--> portrait), reset draw offset */
    if (DIRECTION_TURN(currentMoveDirection)) {
        if (DIRECTION_OUT_LANDSCAPE(currentMoveDirection)) {
            frame.origin.y = locatedMapBox.frame.origin.y;
        } else {
            frame.origin.x = locatedMapBox.frame.origin.x;
        }
    }
    
    /* Next move rect setting */
    currentPathIndex = [[[self delegate] monsterMap:self] getNextPathIndexByCurrentPathIndex:currentPathIndex];
    
    if (YES == [[[self delegate] monsterMap:self] isEndPath:currentPathIndex]) {
        status = MONSTER_STATUS_ATTACK;
        return NO;
    }
    
    locatedMapBox = [[[self delegate] monsterMap:self] getMapBoxByPathIndex:currentPathIndex];
    currentMoveRect = [[[self delegate] monsterMap:self] getMapBoxByPathIndex:currentPathIndex].frame;
    currentMoveDirection = [[[self delegate] monsterMap:self] pathItemAtIndex:currentPathIndex].direction;
    
    [[self delegate] monsterDidMoveToNewRect:self];
    
    return YES;
}

#pragma mark Monster handle status dead
- (void)killed
{
    [[self delegate] monsterDidDead:self withReason:MONSTER_DIE_REASON_KILLED];
    [self monsterDead];
}

- (void)monsterDead
{
    NSNotification *note = [NSNotification notificationWithName:@"MonsterDead" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:note];
    status = MONSTER_STATUS_REMOVED;
}

#pragma mark Monster handle status attack
- (void)attack
{
    [[self delegate] monsterDidDead:self withReason:MONSTER_DIE_REASON_ATTACK_HOME];
    
    [self monsterDead];
}

- (void)remove
{
    
}

#pragma mark 3. Other User Interface
- (BOOL)createImage
{
    if (0 == type) {
        return NO;
    }

    /* icon image */
    iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"show_monster%d_100X100.png", type]];

    /* Animation images */
    UIImage *wholeImage = [UIImage imageNamed:[ChrisMonster getImagePathByType:type]];
    
    if (nil == imageArray) {
        imageArray = [[NSMutableArray alloc] init];
    }
    
    if (1 == type) {
        CGImageRef subImageRef = nil;
        UIImage *subImage = nil;
        
        subImageRef = CGImageCreateWithImageInRect(wholeImage.CGImage, CGRectMake(0, 0, 100, 100));
        subImage = [UIImage imageWithCGImage:subImageRef];
        [imageArray addObject:subImage];
        
        subImageRef = CGImageCreateWithImageInRect(wholeImage.CGImage, CGRectMake(100, 0, 100, 100));
        subImage = [UIImage imageWithCGImage:subImageRef];
        [imageArray addObject:subImage];
        
        subImageRef = CGImageCreateWithImageInRect(wholeImage.CGImage, CGRectMake(0, 100, 100, 100));
        subImage = [UIImage imageWithCGImage:subImageRef];
        [imageArray addObject:subImage];

        subImageRef = CGImageCreateWithImageInRect(wholeImage.CGImage, CGRectMake(100, 100, 100, 100));
        subImage = [UIImage imageWithCGImage:subImageRef];
        [imageArray addObject:subImage];

    } else if (2 == type) {
        CGImageRef subImageRef = nil;
        UIImage *subImage = nil;
        CGRect rect = CGRectMake(5, 5, 90, 90);
        
        for (int i = 0; i < 4; i++) {
            subImageRef = CGImageCreateWithImageInRect(wholeImage.CGImage, rect);
            subImage = [UIImage imageWithCGImage:subImageRef];
            [imageArray addObject:subImage];
            
            rect.origin.x += 100;
        }
    } else {
        int sideSpace = 3;
        CGImageRef subImageRef = nil;
        UIImage *subImage = nil;
        CGRect rect = CGRectMake(sideSpace, sideSpace, 100 - sideSpace * 2, 100 - sideSpace * 2);
        
        /* Row 1 */
        for (int i = 0; i < 4; i++) {
            subImageRef = CGImageCreateWithImageInRect(wholeImage.CGImage, rect);
            subImage = [UIImage imageWithCGImage:subImageRef];
            [imageArray addObject:subImage];
            
            rect.origin.x += 100;
        }
        
        /* Row 2 */
        rect.origin.x = sideSpace;
        rect.origin.y += 100;
        for (int i = 0; i < 4; i++) {
            subImageRef = CGImageCreateWithImageInRect(wholeImage.CGImage, rect);
            subImage = [UIImage imageWithCGImage:subImageRef];
            [imageArray addObject:subImage];
            
            rect.origin.x += 100;
        }
    }
    
    frame.size.width = 50;
    frame.size.height = 50;
    return YES;
}

- (BOOL)isActive
{
    if (MONSTER_STATUS_KILLED == status || MONSTER_STATUS_PREPARE == status || MONSTER_STATUS_REMOVED == status) {
        return NO;
    }
    
    return YES;
}

- (void)startWithPrepareTime:(int)preTime
{
    DynamicMonster *dynMonster = [[Player currentPlayer] getDynamicMonsterByType:self.type];
    hurtMul = 1 + dynMonster.lv * [DynamicMonster hurtAdditionPerLevel];
    
    status = MONSTER_STATUS_PREPARE;
    prepareTime = preTime;
}

- (void)getHurtWithAttack:(int)atk
{
    int damage = atk * pow( 2, -1 * armor / 40.0 );
    
    damage *= hurtMul;
    
    currentHealthPoint -= damage;
    if (currentHealthPoint < 0)
    {
        status = MONSTER_STATUS_KILLED;
    }
    
    NSLog(@"<%s:%d> damage = %d, hp = %d", __func__, __LINE__, damage, currentHealthPoint);
}

- (void)freezing
{
    Player *tmpPlayer = [Player currentPlayer];
    
    if (MONSTER_MOVE_MASK_CHECK(moveMask, MONSTER_MOVE_MASK_FREEZING)) {
        if (moveSpeed <= 0) {
            freezeCounter = [tmpPlayer cannonMagicCurrentIceStopTime];
        } else {
            freezeCounter = [tmpPlayer cannonMagicCurrentIceTime];
        }
        return;
    }
    
    if (MONSTER_STATUS_ANGRY == status) {
        moveSpeed -= 2;
        extraCounter = 0;
        status = MONSTER_STATUS_MOVE;
    }
    
    speedDown = moveSpeed * [tmpPlayer cannonMagicIceSpeedDownRatio];
    speedDown = speedDown < 1 ? 1 : speedDown;
    moveSpeed -= speedDown;
    
    if (moveSpeed <= 0) {
        freezeCounter = [tmpPlayer cannonMagicCurrentIceStopTime];
    } else {
        freezeCounter = [tmpPlayer cannonMagicCurrentIceTime];
    }
    MONSTER_MOVE_MASK_SET(moveMask, MONSTER_MOVE_MASK_FREEZING);
}

- (void)poisoningWithAttack:(int)atk
{
    Player *tmpPlayer = [Player currentPlayer];
    
    int tmpSingleHurt = atk * [tmpPlayer cannonMagicCurrentGasHurtPercent] / 100;
    singleHurt = tmpSingleHurt > singleHurt ? tmpSingleHurt : singleHurt;
    
    if (MONSTER_MOVE_MASK_CHECK(moveMask, MONSTER_MOVE_MASK_POISONING)) {
        poisoningCounter = [tmpPlayer cannonMagicCurrentGasTime];
        return;
    }
    
    poisoningCounter = [tmpPlayer cannonMagicCurrentGasTime];
    poisonHurtCounter = [tmpPlayer cannonMagicCurrentGasHurtInterval];
    MONSTER_MOVE_MASK_SET(moveMask, MONSTER_MOVE_MASK_POISONING);
}

- (int)recommendKilledGoldAward
{
    return healthPointMax / 50 + armor * 2 + moveSpeed + lv * 3;
}

- (void)strengthenWithWaveIndex:(int)index
{
    healthPointMax *= pow(1.05, index);
    armor += (index / 5 * 2);
}

#pragma mark Draw Related Functions;
- (void)drawMonsterWithContext:(CGContextRef)context
{
    if (NO == [self isActive]) {
        return;
    }

    [[self currentImage] drawInRect:frame];
    
    [self drawMonsterLifeLineWithContext:context];
    
#if 0
    /* Write monster killed award */
    NSString *valueStr = [NSString stringWithFormat:@"%d %d", killedGoldAward, status];
    [valueStr drawAtPoint:CGPointMake(frame.origin.x, frame.origin.y + 35) withAttributes:nil];
#endif
}

- (UIImage *)currentImage
{
    int slowDownValue = 4;
    
    UIImage *currImage = [imageArray objectAtIndex:imageCounter / slowDownValue];
    
    imageCounter = (imageCounter + 1) % (imageArray.count * slowDownValue);
    return currImage;
}

- (UIImage *)displayImage
{
    return iconImage;
}

- (void)drawMonsterLifeLineWithContext:(CGContextRef)context
{
    int lifeLineWidth = 3;
    int tx = frame.origin.x;
    int ty = frame.origin.y + frame.size.height - lifeLineWidth / 2 - 1;
    int lifeLength = frame.size.width * currentHealthPoint / healthPointMax;
    
    [[UIColor redColor] set];
    CGContextSetLineWidth(context, lifeLineWidth);
    
    CGContextMoveToPoint(context, tx, ty);
    CGContextAddLineToPoint(context, tx + lifeLength, ty);
    
    CGContextStrokePath(context);
}

@end
