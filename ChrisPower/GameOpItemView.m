//
//  GameOpItemView.m
//  ChrisPower
//
//  Created by Chris on 15/2/27.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "GameOpItemView.h"

static NSComparator compareBlock = ^(GameOpItemView *obj1,  GameOpItemView *obj2)
{
    if ( obj1.index > obj2.index) {
        return (NSComparisonResult)NSOrderedDescending;
    } else if ( obj1.index < obj2.index) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    
    return (NSComparisonResult)NSOrderedSame;
};

@implementation GameOpItemView
@synthesize delegate;
@synthesize index;
@synthesize value;

+ (NSComparator)comparator
{
    return compareBlock;
}

- (id)initWithIndex:(int)inputIndex
              image:(UIImage *)inputImage
              value:(int)inputValue
{
    self = [super init];
    
    if (self) {
        index = inputIndex;
        image = inputImage;
        value = inputValue;
        
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect tmpRect = CGRectZero;
    tmpRect.size = rect.size;
    
    int smaller = 5;
    tmpRect.size.width -= smaller * 2;
    tmpRect.size.height = tmpRect.size.width;
    
    [image drawInRect:tmpRect];
    
    if (0 != value) {
        tmpRect.origin.x = 0;
        tmpRect.origin.y = tmpRect.size.height;
        tmpRect.size.width = rect.size.width;
        tmpRect.size.height = rect.size.height - tmpRect.origin.y;
        
        NSString *valueStr = nil;
        if (0 > value) {
            valueStr = [NSString stringWithFormat:@"+$%d",value * (-1)];
        } else {
            valueStr = [NSString stringWithFormat:@"$%d",value];
        }
        
        [valueStr drawInRect:tmpRect withAttributes:nil];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self delegate] GameOpItemViewDidEndedTouch:self];
}

@end
