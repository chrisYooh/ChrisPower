//
//  TimerControlRect.h
//  ChrisPower
//
//  Created by Chris on 15/1/12.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum {
    ALPHA_UP = 0,
    ALPHA_DOWN = 1,
};

enum {
    TC_COLOR_RED = 0,
    TC_COLOR_GREEN = 1,
    TC_COLOR_BLUE = 2,
};

@interface TimerControlRect : NSObject
{
    int loopCounterNumber;
    
    CGRect redisplayRect;

    int currentCount;
    int changeType;
    
//    int currentColor;
    UIColor *currentColor;
}
@property (nonatomic) CGRect redisplayRect;
//@property (nonatomic) int currentColor;
@property (nonatomic, retain) UIColor *currentColor;

- (void)nextFrame;

- (void)setNeedDisplayInView:(UIView *)view;
- (void)drawRectWithContext:(CGContextRef)context;

@end
