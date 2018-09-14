//
//  DynamicCannon.m
//  ChrisPower
//
//  Created by Chris on 15/1/3.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "DynamicCannon.h"

@implementation DynamicCannon
@synthesize lv;
@synthesize experience;
@synthesize currentExperience;

+ (double)attackAdditionPerLv
{
    return 0.03;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        lv = [aDecoder decodeIntForKey:@"lv"];
        experience = [aDecoder decodeIntForKey:@"experience"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:lv forKey:@"lv"];
    [aCoder encodeInt:experience forKey:@"experience"];
}

- (void)infoUpdateWithCurrentValue
{
    experience += currentExperience;
    
    if (experience >= lvUpExp[lv] && lv < DYN_LV_MAX) {
        experience -= lvUpExp[lv];
        lv++;
    }
    
    currentExperience = 0;
}

- (int)updateCurrentExperienceByValue:(int)value
{
    currentExperience += value;
    return 0;
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"Lv: %d\n"
            "Experience: %d\n"
            "Current Experience: %d\n",
            lv,
            experience,
            currentExperience];
}

@end