//
//  NoteView.m
//  ChrisPower
//
//  Created by Chris on 15/3/5.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "NoteView.h"

@implementation NoteView

+ (NSDictionary *)stringAttribute
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIFont systemFontOfSize:15.0f], NSFontAttributeName,
                         [UIColor blackColor], NSForegroundColorAttributeName,
                         nil];
}

- (void)drawRect:(CGRect)rect
{
    CGRect tmpRect = rect;
    
    tmpRect.origin.y += 13;
    tmpRect.size.height = 20;
    
    [note drawInRect:tmpRect withAttributes:[NoteView stringAttribute]];
}

- (void)noteDisplayWithNote:(NSString *)inputNote
{
    note = inputNote;
    
    [self resetAnimation];
}

- (void)resetAnimation
{
    [self setHidden:NO];
    
    if (nil != animationTimer)
    {
        animationTimer = nil;
    }
    
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:DISPLAY_DURATION
                                                        target:self
                                                    selector:@selector(timerCallBack)
                                                    userInfo:nil
                                                        repeats:NO];
    
    [self setNeedsDisplay];
}

- (void)timerCallBack
{
    /* Hidden animation */
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 1;
    [self.layer addAnimation:animation forKey:nil];
    
    [self setHidden:YES];
}

@end
