//
//  NoteView.h
//  ChrisPower
//
//  Created by Chris on 15/3/5.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DISPLAY_DURATION    1

@interface NoteView : UIView
{
    NSString *note;
    
    NSTimer *animationTimer;
}

- (void)resetAnimation;
- (void)noteDisplayWithNote:(NSString *)note;

@end
