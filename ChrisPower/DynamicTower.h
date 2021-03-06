//
//  DynamicTower.h
//  ChrisPower
//
//  Created by Chris on 15/1/3.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DynamicProtocol.h"
#import "DateLimitObject.h"

@interface DynamicTower : DateLimitObject<NSCoding, DynamicProtocol>
{
    int lv;
    int experience;
    
    int currentExperience;
}
@property (nonatomic, readonly) int lv;
@property (nonatomic, readonly) int experience;
@property (nonatomic, readonly) int currentExperience;

+ (double)attackAdditionPerLv;
+ (double)attackRangeAdditionPerLv;

- (void)infoUpdateWithCurrentValue;
- (int)updateCurrentExperienceByValue:(int)value;

@end
