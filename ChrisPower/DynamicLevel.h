//
//  DynamicLevel.h
//  ChrisPower
//
//  Created by Chris on 15/1/3.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DynamicProtocol.h"
#import "DateLimitObject.h"

@interface DynamicLevel : DateLimitObject<NSCoding, DynamicProtocol>
{
    int gradeHighest;
    int gradeSecondary;
    int gradeThird;
    
    int currentGrade;
}
@property (nonatomic, readonly) int gradeHighest;
@property (nonatomic, readonly) int gradeSecondary;
@property (nonatomic, readonly) int gradeThird;
@property (nonatomic, readonly) int currentGrade;

- (int)updateCurrentGradeWithValue:(int)value;

@end
