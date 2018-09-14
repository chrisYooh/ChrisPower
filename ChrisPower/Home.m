//
//  Home.m
//  ChrisPower
//
//  Created by Chris on 14/12/16.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "Player.h"

#import "Level.h"

#import "Home.h"

@implementation Home
@synthesize status;
@synthesize gold;
@synthesize healthPoint;
@synthesize magicPoint;
@synthesize armor;
@synthesize beatBackPercents;

- (void)basicInit;
{
    gold = 300;
    healthPoint = 10;
    magicPoint = 0;
    armor = 10;
    beatBackPercents = 0;
}

- (id)initWithLevelPrimaryIndex:(int)priIndex secondaryIndex:(int)secIndex
{
    self = [super init];
    
    if (self) {
        
        [self basicInit];
        
        if (TEACH_LEVEL_PIRMARY_INDEX == priIndex) {
            gold = 99999;
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        gold = [aDecoder decodeIntForKey:@"gold"];
        healthPoint = [aDecoder decodeIntForKey:@"healthPoint"];
        magicPoint = [aDecoder decodeIntForKey:@"magicPoint"];
        armor = [aDecoder decodeIntForKey:@"armor"];
        beatBackPercents = [aDecoder decodeIntForKey:@"beatBackPercents"];
    }
    
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (id)initWithInstance:(id)object
{
    self = [super init];
    
    if (self) {
        [self forceCopyBasicInfoFromHome:object];
    }
    
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:gold forKey:@"gold"];
    [aCoder encodeInt:healthPoint forKey:@"healthPoint"];
    [aCoder encodeInt:magicPoint forKey:@"magicPoint"];
    [aCoder encodeInt:armor forKey:@"armor"];
    [aCoder encodeInt:beatBackPercents forKey:@"beatBackPercents"];
}

- (BOOL)updateWithInstance:(id)object
{
    [self forceCopyBasicInfoFromHome:object];
    status = HOME_STATUS_PREPARE;
    return YES;
}

- (void)forceCopyBasicInfoFromHome:(Home *)otherHome
{
    self.gold = otherHome.gold;
    self.healthPoint = otherHome.healthPoint;
    self.magicPoint = otherHome.magicPoint;
    self.armor = otherHome.armor;
    self.beatBackPercents = otherHome.beatBackPercents;
}

- (int)getHurtWithAttack:(int)atk
{
    int realAttack = atk - armor;
    int hurt = 0;
    
    if (realAttack < 10) {
        hurt = 0;
    } else if (realAttack < 500) {
        hurt = 1;
    } else if (realAttack < 5000) {
        hurt = 2;
    } else {
        hurt = 3;
    }
    
    healthPoint -= hurt;
    NSLog(@"Home get %d hurt\n", hurt);
    
    if (healthPoint <= 0) {
        status = HOME_STATUS_DESTROY;
    }

    return hurt;
}

- (void)earnGold:(int)inputGold
{
    gold += inputGold;
}

- (BOOL)spendGold:(int)inputGold
{
    if (gold < inputGold) {
        return NO;
    }
    
    gold -= inputGold;
    return YES;
}

- (void)strengthenWithPlayer:(Player *)player
{
    healthPoint = [player currentHomeHp];
    gold = [player currentHomeInitialGold];
    armor = [player currentHomeArmor];
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"Current Gold: %d\n"
            "Health Point: %d\n"
            "Magic Point: %d\n"
            "Armor: %d\n"
            "Beat Back Percents: %d\n",
            gold, healthPoint, magicPoint, armor, beatBackPercents];
}

@end
