//
//  WaveItem.h
//  ChrisPower
//
//  Created by Chris on 15/1/20.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaveItem : NSObject<NSCoding>
@property (nonatomic) int monsterNumber;
@property (nonatomic) int monsterType1;
@property (nonatomic) int monsterPercents1;
@property (nonatomic) int monsterType2;
@property (nonatomic) int monsterPercents2;
@property (nonatomic) int monsterType3;
@property (nonatomic) int monsterPercents3;

- (id)initWithMonterNumber:(int)number
                    percent1:(int)percent1
                    percent2:(int)percent2;

- (id)initWithMonterNumber:(int)number
                     type1:(int)type1
                  percent1:(int)percent1
                     type2:(int)type2
                  percent2:(int)percent2
                     type3:(int)type3;

- (id)initWithWaveItem:(WaveItem *)item;

@end
