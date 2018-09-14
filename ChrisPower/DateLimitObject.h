//
//  DateLimitObject.h
//  ChrisPower
//
//  Created by Chris on 15/1/3.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

/* TODO: May move position */
#define DYN_LV_MAX 15
static int lvUpExp[DYN_LV_MAX] = {
    150, 225, 338, 506, 759,
    1139, 1709, 2563, 3844, 5767,
    8650, 12975, 19462, 29193, 43789
};

@interface DateLimitObject : NSObject
{
    BOOL valid;
    NSDate *validEndDate;  /* nil mean valid forever */
}
@property (nonatomic, readonly) BOOL valid;

/* Unlock an object With an end date,
 * if the date is nill, means unlock the object forever */
- (void)setObjectValidUntilDate:(NSDate *)endDate;

/* Check the object valid end date,
 * if the date is out of time, automatic set the object unvalid */
- (BOOL)autoSetObjectUnvalid;

@end
