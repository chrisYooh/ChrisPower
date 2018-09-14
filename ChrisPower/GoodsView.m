//
//  GoodsView.m
//  ChrisPower
//
//  Created by Chris on 15/1/14.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "GoodsView.h"

static NSComparator compareBlock = ^(GoodsView *obj1,  GoodsView *obj2)
{
    if ( obj1.showType > obj2.showType) {
        return (NSComparisonResult)NSOrderedDescending;
    } else if ( obj1.showType > obj2.showType) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    
    if ( obj1.index > obj2.index) {
        return (NSComparisonResult)NSOrderedDescending;
    } else if ( obj1.index > obj2.index) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    
    return (NSComparisonResult)NSOrderedSame;
};

@implementation GoodsView
@synthesize showType;
@synthesize index;
@synthesize image;

+ (NSComparator)comparator
{
    return compareBlock;
}

- (id)initWithType:(int)inputType index:(int)inputIndex
{
    self = [super init];
    
    if (self) {
        showType = inputType;
        index = inputIndex;
        
        switch (inputType) {
            case SHOP_TYPE_MONSTER:
                goodsName = [NSString stringWithFormat:@"Monster%d", inputIndex];
                break;
            case SHOP_TYPE_TOWER:
                goodsName = [NSString stringWithFormat:@"Tower%d", inputIndex];
                break;
            case SHOP_TYPE_CANNON:
                goodsName = [NSString stringWithFormat:@"Cannon%d", inputIndex];
                break;
            case SHOP_TYPE_HOME:
                goodsName = [NSString stringWithFormat:@"Home%d", inputIndex];
                break;
            case SHOP_TYPE_DEFENDER:
                goodsName = [NSString stringWithFormat:@"Defender%d", inputIndex];
                break;
                
            default:
                break;
        }
        
        [self setBackgroundColor:[UIColor clearColor]];
    }

    return self;
}

- (NSDictionary *)goodsStrAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [UIFont systemFontOfSize:12.0f], NSFontAttributeName,
            [UIColor whiteColor], NSForegroundColorAttributeName,
            nil];
    
}

// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    int sideSpace = 0;
    if (rect.size.width <= 70) {
        sideSpace = ((70 - rect.size.width) > 10) ? 10 : (70 - rect.size.width);
    } else {
        sideSpace = 10;
    }
    
    CGRect tmpRect = self.bounds;
    tmpRect.origin.x = sideSpace;
    tmpRect.origin.y = sideSpace;
    tmpRect.size.width = tmpRect.size.width - sideSpace * 2;
    tmpRect.size.height = tmpRect.size.width;
    
    [image drawInRect:tmpRect];
    
    tmpRect.origin.y = tmpRect.size.height + sideSpace;
    tmpRect.size.height = rect.size.height - tmpRect.size.height;
//    [goodsName drawInRect:tmpRect withAttributes:[self goodsStrAttributes]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Goods %d in shop %d touched", index, showType);
    
    [[self delegate] GoodsViewDidTouched:self];
}

@end
