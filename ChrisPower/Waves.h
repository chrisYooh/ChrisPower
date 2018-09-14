//
//  Waves.h
//  ChrisPower
//
//  Created by Chris on 14/12/29.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameConfig.h"

@class WaveItem;

@interface Waves : NSObject <NSCoding, GameConfigProtocol>
{
    int waveNumber;
    NSMutableArray *wavesInfo;
}
@property (nonatomic) int waveNumber;
@property (nonatomic, retain) NSMutableArray *wavesInfo;

- (id)initWithLevelPrimaryIndex:(int)priIndex secondaryIndex:(int)index;

- (id)initWithWaveNumber:(int)wNumber
      monterPerWaveBasic:(int)monsterNumber
                   type1:(int)type1
                percent1:(int)percent1
                   type2:(int)type2
                percent2:(int)percent2
                   type3:(int)type3;

- (const WaveItem *)getWaveByIndex:(int)index;

@end
