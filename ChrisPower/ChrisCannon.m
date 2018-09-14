//
//  ChrisCannon.m
//  ChrisPower
//
//  Created by Chris on 14/12/10.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "ChrisMap.h"
#import "ChrisMapBox.h"
#import "ChrisMonster.h"
#import "ChrisTower.h"

#import "Player.h"
#import "DynamicCannon.h"

#import "ChrisCannon.h"

@interface ChrisCannon ()

- (void)preparing;
- (void)operateMoveStatus;
- (void)operateBlustStatus;

@end

@implementation ChrisCannon
@synthesize target;
@synthesize frame;
@synthesize status;
@synthesize delegate;

@synthesize type;
@synthesize magicMask;
@synthesize attack;
@synthesize ignoreArmor;
@synthesize moveSpeed;
@synthesize imageArray;
@synthesize iconImage;

+ (NSString *)cannonKeyWithType:(int)type
{
    return [NSString stringWithFormat:@"cannon%d", type];
}

+ (NSString *)getImagePathByType:(int)type
{
    return [NSString stringWithFormat:@"cannon%d.png", type];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        
        type = [aDecoder decodeIntForKey:@"type"];
        
        attack = [aDecoder decodeIntForKey:@"attack"];
        ignoreArmor = [aDecoder decodeIntForKey:@"ignoreArmor"];
        moveSpeed = [aDecoder decodeIntForKey:@"moveSpeed"];
        
        [self createImage];
    }
    
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (id)initWithInstance:(ChrisCannon *)otherCannon
{
    self = [super init];
    
    if (self) {
        [self forceCopyBasicInfoFromCannon:otherCannon];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Cannon%d\n"
            "Attack: %d\n"
            "IgnoreArmor: %d\n"
            "MoveSpeed: %d"
            "MoveStype: %x",
            type, attack, ignoreArmor, moveSpeed, magicMask];
}


#pragma mark 1. Attributes Basic Operations
- (void)setTarget:(ChrisMonster *)targetMonster
{
    target = targetMonster;
    
    if (nil == targetMonster) {
        return;
    }
    
    /* Reset xSpeed and ySpeed */
    float xLen = targetMonster.frame.origin.x - frame.origin.x;
    float yLen = targetMonster.frame.origin.y - frame.origin.y;
    float zLen = sqrtf(powf(xLen, 2) + powf(yLen, 2));
    
    moveSpeedX = moveSpeed * xLen / zLen;
    moveSpeedY = moveSpeed * yLen / zLen;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:type forKey:@"type"];
    
    [aCoder encodeInt:attack forKey:@"attack"];
    [aCoder encodeInt:ignoreArmor forKey:@"ignoreArmor"];
    [aCoder encodeInt:moveSpeed forKey:@"moveSpeed"];
}

- (BOOL)updateWithInstance:(ChrisCannon *)otherCannon
{
    [self forceCopyBasicInfoFromCannon:otherCannon];
    return YES;
}

- (void)forceCopyBasicInfoFromCannon:(ChrisCannon *)otherCannon
{
    type = otherCannon.type;
    attack = otherCannon.attack;
    ignoreArmor = otherCannon.ignoreArmor;
    moveSpeed = otherCannon.moveSpeed;
    magicMask = otherCannon.magicMask;
    
    imageArray = [NSMutableArray arrayWithArray:otherCannon.imageArray];
    iconImage = otherCannon.iconImage;
    frame.size = otherCannon.frame.size;
}

#pragma mark 2. Self AI Control
- (void)selfStatusHandle
{
    if (CANNON_STATUS_PREPARE == status) {
        [self preparing];
    } else if (CANNON_STATUS_MOVE == status) {
        [self operateMoveStatus];
    } else if (CANNON_STATUS_BLAST == status) {
        [self operateBlustStatus];
    } else if (CANNON_STATUS_REMOVE == status) {
        
    } else {
        NSLog(@"<%s:%d> Error status %d", __func__, __LINE__, status);
    }
}

#pragma mark Cannon handle prepare
- (void)preparing
{
    if (nil == target) {
        return;
    }

    [self resetXYSpeed];
    
    status = CANNON_STATUS_MOVE;
}

- (void)resetXYSpeed
{
    /* Reset xSpeed and ySpeed */
    CGPoint targetCenter = CGPointZero;
    targetCenter.x = target.frame.origin.x + target.frame.size.width / 2;
    targetCenter.y = target.frame.origin.y + target.frame.size.height / 2;
    
    float xLen = targetCenter.x - frame.origin.x;
    float yLen = targetCenter.y - frame.origin.y;
    float zLen = sqrtf(powf(xLen, 2) + powf(yLen, 2));
    
    moveSpeedX = moveSpeed * xLen / zLen;
    moveSpeedY = moveSpeed * yLen / zLen;
}

#pragma mark Cannan handle status move
- (void)operateMoveStatus
{
    if (CANNON_MAGIC_MASK_CHECK(magicMask, CANNON_MAGIC_MASK_TRACE)) {
        [self moveTrace];
    }
    
    if (CANNON_MAGIC_MASK_CHECK(magicMask, CANNON_MAGIC_MASK_SPEEDUP)) {
        [self moveSpeedUp];
    }
    
    /* Move */
    frame.origin.x += moveSpeedX;
    frame.origin.y += moveSpeedY;
    
    /* Check map box */
    ChrisMapBox *locatedBox = [[[self delegate] cannonMap:self] mapBoxAtTouchPoint:frame.origin];
    
    if (nil == locatedBox) {
        /* Out of range */
        status = CANNON_STATUS_REMOVE;
    }
    
    ChrisMonster *monster = [locatedBox headerMonster];
    if (nil != monster) {
        blustMonster = monster;
        status = CANNON_STATUS_BLAST;
    }
}

- (void)moveTrace
{
    if (target) {
        [self resetXYSpeed];
    }
}

- (void)moveSpeedUp
{
    moveSpeedX *= 1.1;
    moveSpeedY *= 1.1;
}

#pragma mark Cannon handle status blust
- (void)operateBlustStatus
{
    if (CANNON_MAGIC_MASK_CHECK(magicMask, CANNON_MAGIC_MASK_FIRE)) {
        
        ChrisMap *tmpMap = [[self delegate] cannonMap:self];
        ChrisMapBox *targetBox = blustMonster.locatedMapBox;
        Player *tmpPlayer = [Player currentPlayer];
        
        NSMutableArray *tmpBoxes = [tmpMap getCircleScopeMapBoxesWithCenter:targetBox.center
                                                                     radius:[tmpPlayer cannonMagicCurrentFireRange]
                                                                      order:0
                                                                  boxFilter:^BOOL(ChrisMapBox *box) {
                                                                      return YES;
                                                                  }];
        
        int blustAttack = attack * [tmpPlayer cannonMagicFireHurtRatio];
        for (ChrisMapBox *tmpBox in tmpBoxes) {
            
            for (ChrisMonster *tmpMonster in tmpBox.monsterArray) {
                
                if (tmpMonster == target) {
                    continue;
                }
                
                [[self delegate] cannon:self didHurtTarget:tmpMonster withAttack:blustAttack];
            }
        }
    }
    
    [[self delegate] cannon:self didHurtTarget:blustMonster withAttack:attack];
    target = nil;
    blustMonster = nil;
    [[self delegate] cannonDidRemove:self];
    
    status = CANNON_STATUS_REMOVE;
}

#pragma mark 3. Other User Interface
- (BOOL)createImage
{
    if (0 == type) {
        return NO;
    }
    
    /* icon image */
    iconImage = nil;
    
    /* Animation images */
    UIImage *wholeImage = [UIImage imageNamed:[ChrisCannon getImagePathByType:type]];
    
    if (nil == imageArray) {
        imageArray = [[NSMutableArray alloc] init];
    }

    if (1 == type) {
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
    } else {
        [imageArray addObject:wholeImage];
    }
    
    frame.size.width = 15;
    frame.size.height = 15;
    return YES;
}

- (void)startWithTarget:(ChrisMonster *)monster tower:(ChrisTower *)tower
{
    /* Player Addition */
    DynamicCannon *dynCannon = [[Player currentPlayer] getDynamicCannonByType:self.type];
    attackMul = 1 + dynCannon.lv * [DynamicCannon attackAdditionPerLv];
    attack *= attackMul;
    
    /* Tower Addition */
    attack = attack + tower.attack/* + level*/;
    ignoreArmor = ignoreArmor + tower.ignoreArmor/* + level*/;
    moveSpeed = moveSpeed + tower.speedAddition/* + level*/;
    
    target = monster;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(targetLost)
                                                 name:@"MonsterDead"
                                               object:target];
    
    status = CANNON_STATUS_PREPARE;
    
    /* Draw attribute */
    frame.origin = CGPointMake(tower.frame.origin.x + tower.frame.size.width / 2,
                               tower.frame.origin.y + tower.frame.size.height /2);
}

- (void)targetLost
{
    target = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Draw related functions
- (void)drawCannonWithContext:(CGContextRef)context
{
    if (CANNON_STATUS_MOVE == status) {
        
        //CGContextDrawImage(context, frame, imageRef);
        [[self currentImage] drawInRect:frame];
        
    } else if (CANNON_STATUS_BLAST == status) {
        
    }
}

- (UIImage *)currentImage
{
    int slowDownValue = 1;
    
    UIImage *currImage = [imageArray objectAtIndex:imageCounter / slowDownValue];
    
    imageCounter = (imageCounter + 1) % (imageArray.count * slowDownValue);
    return currImage;
}

- (UIImage *)displayImage
{
    return iconImage;
}
@end
