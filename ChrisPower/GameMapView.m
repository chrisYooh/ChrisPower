//
//  GameMapView.m
//  ChrisPower
//
//  Created by Chris on 15/2/4.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "ChrisMap.h"

#import "GameMapView.h"

static UIImage *level1Image = nil;

@implementation GameMapView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    ChrisMap *map = [[self delegate] gameMapViewMap:self];
    
/* TODO: use map box to draw map, the picture will used for draw special map */
#if 0
    if ((1 == [[GameConfig globalConfig] currentLevelPrimaryType])
        && (1 <= [[GameConfig globalConfig] currentLevelSecondaryType])
        && (5 >= [[GameConfig globalConfig] currentLevelSecondaryType])) {
        /* Draw bg */
        if (nil == level1Image) {
            level1Image = [UIImage imageNamed:@"bg_level1.png"];
        }
        [level1Image drawInRect:map.frame];
        [map drawMapFrameWithContext:context];
    } else {
        [map drawMapBoxesWithContext:context];
    }
#else
    [map drawMapBoxesWithContext:context];
    [map drawMapFrameWithContext:context];
#endif
    

    //    [map drawMapPathWithContext:context];
}

@end
