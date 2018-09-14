//
//  MapMakerView.m
//  ChrisPower
//
//  Created by Chris on 14/12/22.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "ChrisMap.h"
#import "ChrisMapBox.h"

#import "MapMakerView.h"

@implementation MapMakerView
@synthesize delegate;

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    [self drawMapWithContext:context];
}

- (void)drawMapWithContext:(CGContextRef)context
{
    ChrisMap *tmpMap = [[self delegate] MapMakerViewGetMap:self];
    
    if (nil == tmpMap) {
        return;
    }
    
    [[UIColor blackColor] set];
    
    float mapBoxLineWidth = tmpMap.mapBoxLineWidth;
    int width = tmpMap.mapBoxColNumber;
    int height = tmpMap.mapBoxRolNumber;
    int boxXLength = tmpMap.mapBoxWidthBits;
    int boxYLength = tmpMap.mapBoxHeightBits;
    int *mapInfo = tmpMap.mapInfo;
    
    /* Draw frame rect */
    float frameLineWidth = tmpMap.frameLineWidth;
    CGRect frame = tmpMap.frame;
    frame.size.width = width * boxXLength;
    frame.size.height = height * boxYLength;
    
    CGContextSetLineWidth(context, frameLineWidth);
    float lineWidthFixOffset = frameLineWidth / 2;
    
    CGContextMoveToPoint(context, frame.origin.x - frameLineWidth, frame.origin.y - lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width + lineWidthFixOffset, frame.origin.y - lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width + lineWidthFixOffset, frame.origin.y + frame.size.height + lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x - lineWidthFixOffset, frame.origin.y + frame.size.height + lineWidthFixOffset);
    CGContextAddLineToPoint(context, frame.origin.x - lineWidthFixOffset, frame.origin.y - lineWidthFixOffset);
    CGContextStrokePath(context);
    
    /* Draw net lines */
    CGContextSetLineWidth(context, mapBoxLineWidth);
    for (int i = 0; i < height; i++) {
        CGContextMoveToPoint(context, frame.origin.x, frame.origin.y + boxYLength * i);
        CGContextAddLineToPoint(context, frame.origin.x + frame.size.width, frame.origin.y + boxYLength * i);
    }
    
    for (int i = 0; i < width; i++) {
        CGContextMoveToPoint(context, frame.origin.x + boxXLength * i, frame.origin.y);
        CGContextAddLineToPoint(context, frame.origin.x + boxXLength * i, frame.origin.y + frame.size.height);
    }
    CGContextStrokePath(context);

    int tx = 0, ty = 0;
    
    CGContextSetLineWidth(context, boxYLength - 2);
    
    for (int i = 0; i < height; i++) {
        
        for (int j = 0; j < width; j++) {
            
            tx = frame.origin.x + j * boxXLength;
            ty = frame.origin.y + i * boxYLength;
            
            int type = mapInfo[i * width + j];
            
            switch (type) {
                case MAP_BOX_TYPE_WALKWAY:
                    [[UIColor greenColor] set];
                    break;
                case MAP_BOX_TYPE_HILL:
                    [[UIColor purpleColor] set];
                    break;
                case MAP_BOX_TYPE_STONE:
                    [[UIColor yellowColor] set];
                    break;
                case MAP_BOX_TYPE_START:
                    [[UIColor orangeColor] set];
                    break;
                case MAP_BOX_TYPE_END:
                    [[UIColor blueColor] set];
                    break;

                default:
                    break;
            }

            CGContextMoveToPoint(context, tx + 1, ty + boxYLength / 2);
            CGContextAddLineToPoint(context, tx + boxXLength - 1, ty + boxYLength / 2);
            CGContextStrokePath(context);

        } /* for j */
        
    } /* for i */

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint touchPos = [touch locationInView:self];
        NSLog(@"1touch number: %d, Loc pos : %f, %f", (int)touches.count, touchPos.x, touchPos.y);
        
        [[self delegate] MapMakerView:self beenTouchedWithTouch:touch];
    }
}

@end
