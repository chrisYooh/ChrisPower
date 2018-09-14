//
//  ChrisTower.m
//  ChrisPower
//
//  Created by Chris on 14/12/10.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "ChrisMap.h"
#import "ChrisMapBox.h"
#import "ChrisMonster.h"
#import "ChrisCannon.h"

#import "Player.h"
#import "DynamicTower.h"

#import "ChrisTower.h"

BOOL (^mapBoxFilter)(ChrisMapBox *box) = ^(ChrisMapBox *box)
{
    if (MAP_BOX_TYPE_WALKWAY != [box type]) {
        return NO;
    }
    
    /*Pass the filter */
    return YES;
};

@interface ChrisTower ()

- (void)preparing;
- (void)operateSleepStatus;
- (void)operateAttackStatus;

@end

@implementation ChrisTower
@synthesize delegate;
@synthesize frame;

@synthesize type, attack, ignoreArmor;
@synthesize attackInterval, attackRadius, speedAddition;
@synthesize valueOfGold;
@synthesize cannonSlotNumber;
@synthesize lvUpGold;

@synthesize lv;

@synthesize cannonSlotUsedNumber;
@synthesize installedCannons;

@synthesize imageArray;
@synthesize iconImage;

@synthesize status;
@synthesize attackScopeHelper;
@synthesize locatedMapBox;

+ (NSString *)towerKeyWithType:(int)type
{
    return [NSString stringWithFormat:@"tower%d", type];
}

+ (NSString *)getImagePathByType:(int)type
{
    return [NSString stringWithFormat:@"tower%d.png", type];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        
        type = [aDecoder decodeIntForKey:@"type"];
        
        attack = [aDecoder decodeIntForKey:@"attack"];
        ignoreArmor = [aDecoder decodeIntForKey:@"ignoreArmor"];
        attackInterval = [aDecoder decodeIntForKey:@"attackInterval"];
        attackRadius = [aDecoder decodeIntForKey:@"attackRadius"];
        
        speedAddition = [aDecoder decodeIntForKey:@"speedAddition"];
        valueOfGold = [aDecoder decodeIntForKey:@"valueOfGold"];
        cannonSlotNumber = [aDecoder decodeIntForKey:@"cannonSlotNumber"];
    
        lvUpGold = [aDecoder decodeIntForKey:@"lvUpGold"];
        
        [self createImage];
    }
    
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (id)initWithInstance:(ChrisTower *)otherTower
{
    self = [super init];
    
    if (self) {
        [self forceCopyBasicInfoFromTower:otherTower];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Tower%d\n"
            "Attack: %d\n"
            "IgnoreArmor: %d\n"
            "AttackInterval: %d\n"
            "AttackRatdius: %d\n"
            "speedAddition: %d\n"
            "Gold: %d\n"
            "CannonSlotNumber: %d"
            "LvUpGold: %d",
            type, attack, ignoreArmor,
            attackInterval, attackRadius,
            speedAddition, valueOfGold, cannonSlotNumber,
            lvUpGold];
}

#pragma mark 1. Attributes Basic Operations
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:type forKey:@"type"];
    
    [aCoder encodeInt:attack forKey:@"attack"];
    [aCoder encodeInt:ignoreArmor forKey:@"ignoreArmor"];
    [aCoder encodeInt:attackInterval forKey:@"attackInterval"];
    [aCoder encodeInt:attackRadius forKey:@"attackRadius"];
    
    [aCoder encodeInt:speedAddition forKey:@"speedAddition"];
    [aCoder encodeInt:valueOfGold forKey:@"valueOfGold"];
    [aCoder encodeInt:cannonSlotNumber forKey:@"cannonSlotNumber"];
    [aCoder encodeInt:lvUpGold forKey:@"lvUpGold"];
}

- (BOOL)updateWithInstance:(ChrisTower *)otherTower
{
    [self forceCopyBasicInfoFromTower:otherTower];
    return YES;
}

- (void)forceCopyBasicInfoFromTower:(ChrisTower *)otherTower
{
    type = otherTower.type;
    
    attack = otherTower.attack;
    ignoreArmor = otherTower.ignoreArmor;
    attackInterval = otherTower.attackInterval;
    attackRadius = otherTower.attackRadius;
    speedAddition = otherTower.speedAddition;
    
    valueOfGold = otherTower.valueOfGold;
    cannonSlotNumber = otherTower.cannonSlotNumber;
    lvUpGold = otherTower.lvUpGold;
    
    imageArray = [NSMutableArray arrayWithArray:otherTower.imageArray];
    iconImage = otherTower.iconImage;
    frame.size = otherTower.frame.size;
}

#pragma mark Tower handler
- (void)selfStatusHandle
{
    if (TOWER_STATUS_PREPARE == status) {
        [self preparing];
    } else if (TOWER_STATUS_OBSERVE == status) {
        [self operateSleepStatus];
    } else if (TOWER_STATUS_ATTACK == status) {
        [self operateAttackStatus];
    } else if (TOWER_STATUS_REMOVE == status) {
        [self remove];
    } else {
        NSLog(@"<%s:%d> Error status %d", __func__, __LINE__, status);
    }
}

#pragma mark 2. Self AI Control

- (void)preparing
{
    frame.origin = locatedMapBox.frame.origin;
    
    attackScopeHelper = [[[self delegate] towerMap:self] getCircleScopeMapBoxesWithCenter:locatedMapBox.center
                                                                                   radius:attackRadius
                                                                                    order:MAP_BOX_SCOPE_ORDER_IN2OUT
                                                                                boxFilter:mapBoxFilter];
    
    status = TOWER_STATUS_OBSERVE;
    
    [[self delegate] towerDidStartObserve:self];
}

#pragma mark Tower handle status sleep
- (void)operateSleepStatus
{
    attackCheckIntervalCounter--;
    if (0 < attackCheckIntervalCounter) {
        return;
    }
    
    ChrisMonster *attackTarget = [self nearestAttackTarget];
    if (attackTarget) {
        status = TOWER_STATUS_ATTACK;
    }
    
    attackCheckIntervalCounter = attackCheckInterval;
}

- (ChrisMonster *)nearestAttackTarget
{
    for (ChrisMapBox *box in attackScopeHelper) {
        
        ChrisMonster *monster = [box headerMonster];
        
        if (monster && [monster isActive]) {
            return monster;
        }
    }
    
    return nil;
}

#pragma mark Tower handle status attack
- (void)operateAttackStatus
{
    attackIntervalCounter--;
    if (0 < attackIntervalCounter) {
        return;
    }
    attackIntervalCounter = attackInterval;

    /* Create a cannon to do attack */
    ChrisMonster *target = [self nearestAttackTarget];
    if (!target) {
//        NSLog(@"Tower at %d, %d target nil", (int)(frame.origin.x) / 50, (int)(frame.origin.y) / 50);
        status = TOWER_STATUS_OBSERVE;
        return;
    }
    
    NSLog(@"Tower at %d, %d attack", (int)(frame.origin.x) / 50, (int)(frame.origin.y) / 50);
    
    for (ChrisCannon *tmpCannon in installedCannons) {
        
        ChrisCannon *cannon = [[ChrisCannon alloc] initWithInstance:tmpCannon];
        
        [[self delegate] tower:self didCreateCannon:cannon];
        
        [cannon startWithTarget:target tower:self];
    }
    
}

#pragma mark Tower handle status remove
- (void)remove
{
    [[self delegate] towerDidRemoved:self];
}

#pragma mark 3. Other User Interface
- (BOOL)createImage
{
    if (0 == type) {
        return NO;
    }
    
    /* icon image */
    iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"show_tower%d_100X100.png", type]];
    
    /* Animation images */
    UIImage *wholeImage = [UIImage imageNamed:[ChrisTower getImagePathByType:type]];
    
    if (nil == imageArray) {
        imageArray = [[NSMutableArray alloc] init];
    }
    

    /* Create tower litter image begin */
    CGImageRef subImageRef = nil;
    UIImage *subImage = nil;
    CGRect rect = CGRectMake(2, 2, 96, 96);
    
    /* Row 1 */
    for (int i = 0; i < 4; i++) {
        subImageRef = CGImageCreateWithImageInRect(wholeImage.CGImage, rect);
        subImage = [UIImage imageWithCGImage:subImageRef];
        [imageArray addObject:subImage];
            
        rect.origin.x += 100;
    }
    
    /* Row 2 */
    rect.origin.x = 2;
    rect.origin.y += 100;
    for (int i = 0; i < 4; i++) {
        subImageRef = CGImageCreateWithImageInRect(wholeImage.CGImage, rect);
        subImage = [UIImage imageWithCGImage:subImageRef];
        [imageArray addObject:subImage];
            
        rect.origin.x += 100;
    }
    /* Chreate tower little image end */

    
    frame.size.width = 50;
    frame.size.height = 50;
    return YES;
}

- (void)startWithMapBox:(ChrisMapBox *)box
{
    [self setCannonWithCannonType:1];
    
    locatedMapBox = box;
    status = TOWER_STATUS_PREPARE;
    
    /* Runtime attributes */
    attackCheckIntervalCounter = 0;
    attackIntervalCounter = 0;
}

- (int)saleGold
{
    return valueOfGold * (1 - TOWER_SALE_CUTOFF);
}

- (BOOL)canLvUp
{
    if ((lv >= TOWER_LV_MAX) || (lv < 0)) {
        return NO;
    }
    
    return YES;
}

/* TODO: All addition value need get from user */
- (void)randomPowerUp
{
    Player *player = [Player currentPlayer];
    int randValue = rand() % 100;
    int tmpPercent = [player towerPercentCurrentAttack];
    
    if (tmpPercent = [player towerPercentCurrentAttack], randValue <= tmpPercent) {
        attack += [player towerPowerCurrentAttack];
        randLvUpPower[lv] = TOWER_POWER_ATTACK;
        
    } else if (tmpPercent += [player towerPercentCurrentIg], randValue <= tmpPercent){
        ignoreArmor += [player towerPowerCurrentIg];
        randLvUpPower[lv] = TOWER_POWER_IGNORE_ARMOR;
        
    } else if (tmpPercent += [player towerPercentCurrentAttackRange], randValue <= tmpPercent) {
        attackRadius += [player towerPowerCurrentAttackRange];
        randLvUpPower[lv] = TOWER_POWER_ATTACK_RADIUS;
        
    } else if (tmpPercent += [player towerPercentCurrentAttackInterval], randValue <= tmpPercent) {
        attackInterval -= [player towerPowerCurrentAttackInterval];
        randLvUpPower[lv] = TOWER_POWER_ATTACK_INTERVAL;
        
    } else if (tmpPercent += [player towerPercentCurrentSpAddition], randValue <= tmpPercent) {
        speedAddition += [player towerPowerCurrentSpAddition];
        randLvUpPower[lv] = TOWER_POWER_SPEED_ADDITION;
        
    } else {
        randLvUpPower[lv] = TOWER_POWER_NONE;
    }
}

- (int)lvUp
{
    float upper = 1.1;
    
    attack *= upper;
    ignoreArmor += 1;
    attackInterval -= 2;
    attackInterval = (attackInterval < 5) ? 5 : attackInterval;
    attackRadius *= upper;
    valueOfGold += lvUpGold * 0.6;
    lvUpGold *= 1.3;
    
    [self randomPowerUp];
    
    /* attack range reset */
    [[[self delegate] towerMap:self] resetCircleScopeMapBoxes:attackScopeHelper
                                                                     withCenter:locatedMapBox.center
                                                                         radius:attackRadius
                                                                          order:MAP_BOX_SCOPE_ORDER_IN2OUT
                                                                         boxFilter:mapBoxFilter];
    
    lv += 1;
    
    if (lv >= TOWER_LV_MAX) {
        lvUpGold = 0;
    }
    
    return 0;
}

- (void)setRemove
{
    status = TOWER_STATUS_REMOVE;
}

- (int)recommendValueOfGold
{
    return attack + 1000 / attackInterval + attackRadius / 3 +speedAddition * 20;
}

- (BOOL)setCannonWithCannonType:(int)cannonType
{
    if (nil == installedCannons) {
        installedCannons = [[NSMutableArray alloc] init];
    }

    /* TODO for test */
    [installedCannons removeAllObjects];
    
    ChrisCannon *tmpCannon = [[GameConfig globalConfig] getTemplateCannonFromStoreWithType:cannonType];
    ChrisCannon *cannon = [[ChrisCannon alloc] initWithInstance:tmpCannon];
    [installedCannons addObject:cannon];
    
    return YES;
}

- (NSString *)randPowerStr
{
    NSString *tmpStr = @"      随机加成\n";
    
    for (int i = 0; i < TOWER_LV_MAX; i++) {
        switch (randLvUpPower[i]) {
            case TOWER_POWER_NONE:
                tmpStr = [tmpStr stringByAppendingString:@"无  "];
                break;
            case TOWER_POWER_ATTACK:
                tmpStr = [tmpStr stringByAppendingString:@"攻  "];
                break;
            case TOWER_POWER_IGNORE_ARMOR:
                tmpStr = [tmpStr stringByAppendingString:@"破  "];
                break;
            case TOWER_POWER_ATTACK_INTERVAL:
                tmpStr = [tmpStr stringByAppendingString:@"广  "];
                break;
            case TOWER_POWER_ATTACK_RADIUS:
                tmpStr = [tmpStr stringByAppendingString:@"频  "];
                break;
            case TOWER_POWER_SPEED_ADDITION:
                tmpStr = [tmpStr stringByAppendingString:@"速  "];
                break;
                
            default:
                break;
        }
    }
    
    return tmpStr;
}

- (void)strengthenWithPlayer:(Player *)player
{
    /* Player Level Addition */
    attack *= (1 + [player currentTowerAttackUpPercent] / 100.0 );
    
    /* Special Tower Addition */
    DynamicTower *dynTower = [player getDynamicTowerByType:self.type];
    attackMul = 1 + dynTower.lv * [DynamicTower attackAdditionPerLv];
    attackRangeMul =  1 + dynTower.lv * [DynamicTower attackRangeAdditionPerLv];
    
    attack *= attackMul;
    attackRadius *= attackRangeMul;
}

- (BOOL)canNewMagicSet
{
    if (cannonSlotUsedNumber >= [Player currentPlayer].towerMagicSlot) {
        NSLog(@"Slot use up\n");
        return  NO;
    }
    
    return YES;
}

- (void)setMagicWithFlag:(int)flag
{
    ChrisCannon *tmpCannon = [installedCannons firstObject];
    
    CANNON_MAGIC_MASK_SET(tmpCannon.magicMask, flag);
    cannonSlotUsedNumber++;
}

#pragma mark Draw related functions
- (void)drawTowerWithContext:(CGContextRef)context
{
    if (TOWER_STATUS_REMOVE == status) {
        return;
    }
    
    CGRect tmpRect = frame;
    int lvMax = 5;
    int sideSpace = 2;
    int tmpLength = (frame.size.width - sideSpace * (lvMax - 1)) / (lvMax + 1);
    
    /* Draw image */
    tmpRect.origin.x += tmpLength / 2;
    tmpRect.size.width -= tmpLength;
    tmpRect.size.height -= tmpLength;
    [[self currentImage] drawInRect:tmpRect];

    /* Draw Level */
    tmpRect = frame;
    tmpRect.origin.x += tmpLength / 2;
    tmpRect.origin.y += (self.frame.size.height - tmpLength) ;
    tmpRect.size.width = tmpLength;
    tmpRect.size.height = tmpLength;
    for (int i = 0; i < lv; i++) {
        [[UIImage imageNamed:@"lv_star30X30.png"] drawInRect:tmpRect];
        tmpRect.origin.x += (tmpLength + sideSpace);
    }
}

- (UIImage *)currentImage
{
    int slowDownValue = 3;
    
    UIImage *currImage = [imageArray objectAtIndex:imageCounter / slowDownValue];
    
    imageCounter = (imageCounter + 1) % (imageArray.count * slowDownValue);
    return currImage;
}

- (UIImage *)displayImage
{
    return iconImage;
}

@end
