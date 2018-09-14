//
//  WaveItem.m
//  ChrisPower
//
//  Created by Chris on 15/1/20.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "WaveItem.h"

@implementation WaveItem

@synthesize monsterNumber;
@synthesize monsterType1, monsterPercents1;
@synthesize monsterType2, monsterPercents2;
@synthesize monsterType3, monsterPercents3;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        monsterNumber = [aDecoder decodeIntForKey:@"monsterNumber"];
        
        monsterType1 = [aDecoder decodeIntForKey:@"monsterType1"];
        monsterPercents1 = [aDecoder decodeIntForKey:@"monsterPercents1"];
        monsterType2 = [aDecoder decodeIntForKey:@"monsterType2"];
        monsterPercents2 = [aDecoder decodeIntForKey:@"monsterPercents2"];
        monsterType3 = [aDecoder decodeIntForKey:@"monsterType3"];
        monsterPercents3 = [aDecoder decodeIntForKey:@"monsterPercents3"];
    }
    
    return self;
}

- (id)initWithMonterNumber:(int)number
                    percent1:(int)percent1
                    percent2:(int)percent2
{
    return [self initWithMonterNumber:number type1:1 percent1:percent1 type2:2 percent2:percent2 type3:3];
}

- (id)initWithMonterNumber:(int)number
                     type1:(int)type1
                  percent1:(int)percent1
                     type2:(int)type2
                  percent2:(int)percent2
                     type3:(int)type3
{
    self = [super init];
    
    if (self) {
        self.monsterNumber = number;
        self.monsterType1 = type1;
        self.monsterPercents1 = (percent1 < 100) ? percent1 : 100;
        self.monsterType2 = type2;
        self.monsterPercents2 = ((percent1 + percent2) < 100) ? percent2 : 100 - percent1;
        self.monsterType3 = type3;
        self.monsterPercents3 = 100 - percent1 - percent2;
    }
    
    return self;
}

- (id)initWithWaveItem:(WaveItem *)item
{
    self = [super init];
    
    if (self) {
        self.monsterNumber = item.monsterNumber;
        self.monsterType1 = item.monsterType1;
        self.monsterPercents1 = item.monsterPercents1;
        self.monsterType2 = item.monsterType2;
        self.monsterPercents2 = item.monsterPercents2;
        self.monsterType3 = item.monsterType3;
        self.monsterPercents3 = item.monsterPercents3;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:monsterNumber forKey:@"monsterNumber"];
    
    [aCoder encodeInt:monsterType1 forKey:@"monsterType1"];
    [aCoder encodeInt:monsterPercents1 forKey:@"monsterPercents1"];
    [aCoder encodeInt:monsterType2 forKey:@"monsterType2"];
    [aCoder encodeInt:monsterPercents2 forKey:@"monsterPercents2"];
    [aCoder encodeInt:monsterType3 forKey:@"monsterType3"];
    [aCoder encodeInt:monsterPercents3 forKey:@"monsterPercents3"];
}

@end
