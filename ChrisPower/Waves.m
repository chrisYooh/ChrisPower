//
//  Waves.m
//  ChrisPower
//
//  Created by Chris on 14/12/29.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "WaveItem.h"

#import "ChrisMonster.h"
#import "Level.h"

#import "Waves.h"

@implementation Waves
@synthesize waveNumber;
@synthesize wavesInfo;

- (void)initWavesWithWaveNumber:(int)wNumber
                  monterPerWave:(int)monsterNumber
                       percent1:(int)percent1
                       percent2:(int)percent2
{
    [self initWavesWithWaveNumber:wNumber
                monterPerWaveBasic:monsterNumber
                            type1:1
                         percent1:percent1
                            type2:2
                         percent2:percent2
                            type3:3];
}

- (void)initWavesWithWaveNumber:(int)wNumber
            monterPerWaveBasic:(int)monsterNumber
                          type1:(int)type1
                       percent1:(int)percent1
                          type2:(int)type2
                       percent2:(int)percent2
                          type3:(int)type3
{
    int monsterAdded = 0;
    
    waveNumber = wNumber;
    wavesInfo = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < waveNumber; i++) {
        monsterAdded = i / 5 * 3;
        
        WaveItem *wave = [[WaveItem alloc] initWithMonterNumber:monsterNumber + monsterAdded
                                                          type1:type1
                                                       percent1:percent1
                                                          type2:type2
                                                       percent2:percent2
                                                          type3:type3];
        if (nil == wave) {
            NSLog(@"<%s:%d> Alloc WaveItem Failed!", __func__, __LINE__);
            [wavesInfo removeAllObjects];
            waveNumber = 0;
            return;
        }
        
        [wavesInfo addObject:wave];
    }
}

- (void)initTestWavesWithTestIndex:(int)index
{
    if (3 == index) {
        [self initWavesWithWaveNumber:1 monterPerWaveBasic:10 type1:1 percent1:35 type2:2 percent2:35 type3:3];
    } else if ( 4 == index) {
        [self initWavesWithWaveNumber:1 monterPerWaveBasic:10 type1:4 percent1:35 type2:5 percent2:35 type3:6];
    } else if ( 5 == index) {
        [self initWavesWithWaveNumber:1 monterPerWaveBasic:10 type1:7 percent1:50 type2:8 percent2:50 type3:8];
    } else {
        [self initWavesWithWaveNumber:1 monterPerWave:10 percent1:50 percent2:30];
    }
}

- (id)initWithWaveNumber:(int)wNumber
      monterPerWaveBasic:(int)monsterNumber
                   type1:(int)type1
                percent1:(int)percent1
                   type2:(int)type2
                percent2:(int)percent2
                   type3:(int)type3
{
    self = [super init];
    
    if (self) {
        [self initWavesWithWaveNumber:wNumber monterPerWaveBasic:monsterNumber type1:type1 percent1:percent1 type2:type2 percent2:percent2 type3:type3];
    }
    
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        
        waveNumber = [aDecoder decodeIntForKey:@"waveNumber"];
        wavesInfo = [aDecoder decodeObjectForKey:@"wavesInfo"];
    }
    
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (id)initWithLevelPrimaryIndex:(int)priIndex secondaryIndex:(int)secIndex
{
    self = [super init];
    
    if (self) {
        
        if (TEACH_LEVEL_PIRMARY_INDEX == priIndex) {
            [self initTeachLevelWavesWithIndex:secIndex];
        } else if (INITIAL_LEVEL_PRIMARY_INDEX == priIndex) {
            [self initInitialLevelWavesWithIndex:secIndex];
        } else if (USER_CREATE_LEVEL_PRIMARY_INDEX == priIndex) {
            [self initUserCreateLevelWavesWithIndex:secIndex];
        } else {
            [self initTestWavesWithTestIndex:secIndex];
        }
    }
    
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (void)initTeachLevelWavesWithIndex:(int)index
{
    switch (index) {
        case 1:
            [self initWavesWithWaveNumber:1
                       monterPerWaveBasic:5
                                    type1:MONSTER_TYPE_BIGEYE
                                 percent1:100
                                    type2:MONSTER_TYPE_BIGEYE
                                 percent2:0
                                    type3:MONSTER_TYPE_BIGEYE];
            break;
        case 2:
            [self initWavesWithWaveNumber:3
                       monterPerWaveBasic:5
                                    type1:MONSTER_TYPE_BIGEYE
                                 percent1:100
                                    type2:MONSTER_TYPE_BIGEYE
                                 percent2:0
                                    type3:MONSTER_TYPE_BIGEYE];
            break;
        case 3:
            [self initWavesWithWaveNumber:10
                       monterPerWaveBasic:5
                                    type1:MONSTER_TYPE_RANDOM
                                 percent1:100
                                    type2:MONSTER_TYPE_RANDOM
                                 percent2:0
                                    type3:MONSTER_TYPE_RANDOM];
            break;
            
        default:
            break;
    }
}

- (void)initInitialLevelWavesWithIndex:(int)index
{
    switch (index) {
        case 1:
            [self initWavesWithWaveNumber:10
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_BIGEYE
                                 percent1:90
                                    type2:MONSTER_TYPE_ROBOT
                                 percent2:10
                                    type3:MONSTER_TYPE_BIGEYE];
            break;
            
        case 2:
            [self initWavesWithWaveNumber:15
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_BIGEYE
                                 percent1:85
                                    type2:MONSTER_TYPE_ROBOT
                                 percent2:15
                                    type3:MONSTER_TYPE_BIGEYE];
            break;
            
        case 3:
            [self initWavesWithWaveNumber:20
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_BIGEYE
                                 percent1:80
                                    type2:MONSTER_TYPE_ROBOT
                                 percent2:20
                                    type3:MONSTER_TYPE_FLATWORM];
            break;
            
        case 4:
            [self initWavesWithWaveNumber:20
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_BIGEYE
                                 percent1:20
                                    type2:MONSTER_TYPE_ROBOT
                                 percent2:60
                                    type3:MONSTER_TYPE_FLATWORM];
            break;
            
        case 5:
            [self initWavesWithWaveNumber:20
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_ROBOT
                                 percent1:78
                                    type2:MONSTER_TYPE_FLATWORM
                                 percent2:20
                                    type3:MONSTER_TYPE_RANDOM];
            break;
            
        case 6:
            [self initWavesWithWaveNumber:25
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_ROBOT
                                 percent1:20
                                    type2:MONSTER_TYPE_FLATWORM
                                 percent2:40
                                    type3:MONSTER_TYPE_LEAF];
            break;
            
        case 7:
            [self initWavesWithWaveNumber:30
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_FLATWORM
                                 percent1:40
                                    type2:MONSTER_TYPE_LEAF
                                 percent2:50
                                    type3:MONSTER_TYPE_TORNADO];
            break;
            
        case 8:
            [self initWavesWithWaveNumber:35
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_ROBOT
                                 percent1:68
                                    type2:MONSTER_TYPE_SPERM
                                 percent2:30
                                    type3:MONSTER_TYPE_RANDOM];
            break;
            
        case 9:
            [self initWavesWithWaveNumber:35
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_BIGEYE
                                 percent1:53
                                    type2:MONSTER_TYPE_TORNADO
                                 percent2:45
                                    type3:MONSTER_TYPE_RANDOM];
            break;
            
        case 10:
            [self initWavesWithWaveNumber:35
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_FLATWORM
                                 percent1:10
                                    type2:MONSTER_TYPE_LEAF
                                 percent2:30
                                    type3:MONSTER_TYPE_TORNADO];
            break;
            
        case 11:
            [self initWavesWithWaveNumber:40
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_LEAF
                                 percent1:40
                                    type2:MONSTER_TYPE_TORNADO
                                 percent2:30
                                    type3:MONSTER_TYPE_SPERM];
            break;
            
        case 12:
            [self initWavesWithWaveNumber:40
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_TORNADO
                                 percent1:40
                                    type2:MONSTER_TYPE_SPERM
                                 percent2:50
                                    type3:MONSTER_TYPE_RANDOM];
            break;
            
        case 13:
            [self initWavesWithWaveNumber:40
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_FLATWORM
                                 percent1:50
                                    type2:MONSTER_TYPE_SPERM
                                 percent2:40
                                    type3:MONSTER_TYPE_OCTOPUS];
            break;
            
        case 14:
            [self initWavesWithWaveNumber:45
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_LEAF
                                 percent1:60
                                    type2:MONSTER_TYPE_OCTOPUS
                                 percent2:30
                                    type3:MONSTER_TYPE_RANDOM];
            break;
            
        case 15:
            [self initWavesWithWaveNumber:45
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_BIGEYE
                                 percent1:60
                                    type2:MONSTER_TYPE_OCTOPUS
                                 percent2:30
                                    type3:MONSTER_TYPE_STICKS];
            break;
            
        case 16:
            [self initWavesWithWaveNumber:45
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_RANDOM
                                 percent1:100
                                    type2:MONSTER_TYPE_RANDOM
                                 percent2:0
                                    type3:MONSTER_TYPE_RANDOM];
            break;
            
        case 17:
            [self initWavesWithWaveNumber:49
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_TORNADO
                                 percent1:50
                                    type2:MONSTER_TYPE_OCTOPUS
                                 percent2:30
                                    type3:MONSTER_TYPE_STICKS];
            break;
            
        case 18:
            [self initWavesWithWaveNumber:49
                       monterPerWaveBasic:10
                                    type1:MONSTER_TYPE_SPERM
                                 percent1:30
                                    type2:MONSTER_TYPE_OCTOPUS
                                 percent2:40
                                    type3:MONSTER_TYPE_STICKS];
            break;
            
        default:
            break;
    }
}

- (void)initUserCreateLevelWavesWithIndex:(int)index
{
    [self initTestWavesWithTestIndex:index];
}

- (id)initWithInstance:(id)object
{
    self = [super init];
    
    if (self) {
        [self forceCopyBasicInfoFromWaves:object];
    }
    
    NSLog(@"<%s:%d> Init succeed.", __func__, __LINE__);
    return self;
}

- (BOOL)updateWithInstance:(id)object
{
    [self forceCopyBasicInfoFromWaves:object];
    return YES;
}

- (void)forceCopyBasicInfoFromWaves:(Waves *)otherWaves
{
    waveNumber = otherWaves.waveNumber;
    
    [wavesInfo removeAllObjects];
    wavesInfo = [NSMutableArray arrayWithArray:otherWaves.wavesInfo];
}

- (const WaveItem *)getWaveByIndex:(int)index
{
    return [wavesInfo objectAtIndex:index];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:waveNumber forKey:@"waveNumber"];
    [aCoder encodeObject:wavesInfo forKey:@"wavesInfo"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Wave Number: %d\n", waveNumber];
}

@end
