//
//  Level.m
//  ChrisPower
//
//  Created by Chris on 14/12/16.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "ChrisMap.h"
#import "Home.h"
#import "Waves.h"

#import "Level.h"

@implementation Level
@synthesize primaryIndex;
@synthesize secondaryIndex;
@synthesize type;
@synthesize map, home, waves;
@synthesize monsterExistNumberMax, towerExistNumberMax;

+ (NSString *)levelKeyWithPrimaryIndex:(int)priLevel secondaryIndex:(int)secLevel
{
    return [NSString stringWithFormat:@"level%d_%d", priLevel, secLevel];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        primaryIndex = [aDecoder decodeIntForKey:@"primaryIndex"];
        secondaryIndex = [aDecoder decodeIntForKey:@"secondaryIndex"];
        type = [aDecoder decodeIntForKey:@"type"];
        
        map = [aDecoder decodeObjectForKey:@"map"];
        home = [aDecoder decodeObjectForKey:@"home"];
        waves = [aDecoder decodeObjectForKey:@"waves"];
        
        monsterExistNumberMax = [aDecoder decodeIntForKey:@"monsterExistNumberMax"];
        towerExistNumberMax = [aDecoder decodeIntForKey:@"towerExistNumberMax"];
    }
 
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (id)initWithInstance:(id)object
{
    self = [super init];
    
    if (self) {
        [self forceCopyBasicInfoFromLevel:object];
    }
 
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:primaryIndex forKey:@"primaryIndex"];
    [aCoder encodeInt:secondaryIndex forKey:@"secondaryIndex"];
    
    [aCoder encodeInt:type forKey:@"type"];
    
    [aCoder encodeObject:map forKey:@"map"];
    [aCoder encodeObject:home forKey:@"home"];
    [aCoder encodeObject:waves forKey:@"waves"];
    
    [aCoder encodeInt:monsterExistNumberMax forKey:@"monsterExistNumberMax"];
    [aCoder encodeInt:towerExistNumberMax forKey:@"towerExistNumberMax"];
}

- (BOOL)updateWithInstance:(Level *)otherLevel
{
    [self forceCopyBasicInfoFromLevel:otherLevel];
    return YES;
}

- (void)forceCopyBasicInfoFromLevel:(Level *)otherLevel
{
    primaryIndex = otherLevel.primaryIndex;
    secondaryIndex = otherLevel.secondaryIndex;
    type = otherLevel.type;
    
    map = [[ChrisMap alloc] initWithInstance:otherLevel.map];
    home = [[Home alloc] initWithInstance:otherLevel.home];
    waves = [[Waves alloc] initWithInstance:otherLevel.waves];
    
    monsterExistNumberMax = otherLevel.monsterExistNumberMax;
    towerExistNumberMax = otherLevel.towerExistNumberMax;
}

- (void)extraInit
{
    [self.map extraInit];
}

- (NSString *)description
{
    NSString *str = [NSString stringWithFormat:@"Level%d_%d\n", primaryIndex, secondaryIndex];
    
//    str = [str stringByAppendingString:[map description]];
    str = [str stringByAppendingString:[home description]];
    str = [str stringByAppendingString:[waves description]];
    str = [str stringByAppendingString:[NSString stringWithFormat:
                                        @"Monster Limit: %d\n"
                                        "Tower Limit: %d\n",
                                        monsterExistNumberMax,
                                        towerExistNumberMax]];
    return str;
}

@end
