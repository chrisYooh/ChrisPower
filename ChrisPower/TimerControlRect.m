//
//  TimerControlRect.m
//  ChrisPower
//
//  Created by Chris on 15/1/12.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "TimerControlRect.h"

@implementation TimerControlRect
@synthesize redisplayRect;
@synthesize currentColor;

- (id)init
{
    self = [super init];
    
    if (self) {
        loopCounterNumber = 20;
        redisplayRect = CGRectZero;
        
        currentCount = 0;
        changeType = ALPHA_UP;
        currentColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)nextFrame
{
    currentCount = (currentCount + 1) % loopCounterNumber;
    
    if (0 == currentCount) {
        changeType = !changeType;
    }
}

- (void)setNeedDisplayInView:(UIView *)view
{
    [view setNeedsDisplayInRect:redisplayRect];
}

- (void)addRectWithContext:(CGContextRef)context
{
    int lineWidth = redisplayRect.size.height - 2;
    
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context,
                         redisplayRect.origin.x,
                         redisplayRect.origin.y + redisplayRect.size.height / 2);
    CGContextAddLineToPoint(context,
                            redisplayRect.origin.x + redisplayRect.size.width,
                            redisplayRect.origin.y + redisplayRect.size.height / 2);
}

- (void)drawRectWithContext:(CGContextRef)context
{
    if ((0 == redisplayRect.size.height) || (0 == redisplayRect.size.width)) {
        return;
    }
    
    float alpha = (float)currentCount / loopCounterNumber;;
    
    if (ALPHA_DOWN == changeType) {
        alpha = 1 - alpha;
    }
    
    [[UIColor lightGrayColor] set];
    CGContextSetAlpha(context, alpha);
    [self addRectWithContext:context];
    CGContextStrokePath(context);
}

@end
