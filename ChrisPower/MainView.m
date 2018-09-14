//
//  MainView.m
//  ChrisPower
//
//  Created by Chris on 14/12/31.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "MainView.h"

static UIImage *image = nil;

@implementation MainView

// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (nil == image) {
        image = [UIImage imageNamed:@"bg_main_view.png"];
    }
    
    [image drawInRect:self.bounds];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

@end
