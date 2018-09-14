//
//  DynamicLevel.m
//  ChrisPower
//
//  Created by Chris on 15/1/3.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "DynamicLevel.h"

@implementation DynamicLevel
@synthesize gradeHighest, gradeSecondary, gradeThird;
@synthesize currentGrade;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        valid = [aDecoder decodeBoolForKey:@"valid"];
        validEndDate = [aDecoder decodeObjectForKey:@"validEndDate"];
        
        gradeHighest = [aDecoder decodeIntForKey:@"gradeHighest"];
        gradeSecondary = [aDecoder decodeIntForKey:@"gradeSecondary"];
        gradeThird = [aDecoder decodeIntForKey:@"gradeThird"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:valid forKey:@"valid"];
    [aCoder encodeObject:validEndDate forKey:@"validEndDate"];
    
    [aCoder encodeInt:gradeHighest forKey:@"gradeHighest"];
    [aCoder encodeInt:gradeSecondary forKey:@"gradeSecondary"];
    [aCoder encodeInt:gradeThird forKey:@"gradeThird"];
}

- (void)infoUpdateWithCurrentValue
{
    if (currentGrade > gradeHighest) {
        gradeThird = gradeSecondary;
        gradeSecondary = gradeHighest;
        gradeHighest = currentGrade;
        
    } else if(currentGrade > gradeSecondary) {
        gradeThird = gradeSecondary;
        gradeSecondary = currentGrade;
        
    } else if(currentGrade > gradeThird) {
        gradeThird = currentGrade;
    }
    
    currentGrade = 0;
}

- (int)updateCurrentGradeWithValue:(int)value
{
    currentGrade += value;
    return 0;
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"1. %d\n"
            "2. %d\n"
            "3. %d\n"
            "Current Grade: %d\n",
            gradeHighest,
            gradeSecondary,
            gradeThird,
            currentGrade];
}

@end
