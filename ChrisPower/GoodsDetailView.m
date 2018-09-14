//
//  GoodsDetailView.m
//  ChrisPower
//
//  Created by Chris on 15/1/14.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "Player.h"

#import "ChrisMonster.h"
#import "ChrisTower.h"
#import "ChrisCannon.h"

#import "DynamicMonster.h"
#import "DynamicTower.h"
#import "DynamicCannon.h"

#import "Goods.h"
#import "GoodsDetailView.h"

@implementation GoodsDetailView
@synthesize delegate;

- (void)drawRect:(CGRect)rect
{
    Goods *goods = [[self delegate] goodsDetailViewGoods:self];
    
    if (nil == goods) {
        [self drawNoGoods];
    } else {
        [self drawGoodsInfo:goods];
    }
}

- (void)drawNoGoods
{
    int sideSpace = 30;
    int topSpace = 10;
    CGRect tmpRect = self.bounds;
    
    tmpRect.origin.x = sideSpace;
    tmpRect.origin.y = topSpace;
    tmpRect.size.width -= sideSpace * 2;
    tmpRect.size.height = tmpRect.size.height / 2 - topSpace;
    
    [[UIImage imageNamed:@"goods_select300X70.png"] drawInRect:tmpRect];
}

- (void)drawGoodsInfo:(Goods *)goods
{
    int sideSpace = 3;
    int objectSpace = 5;
    int sideLength = 40;
    CGRect tmpRect = CGRectZero;
    NSString *tmpString = nil;
    
    tmpRect.origin.x = sideSpace;
    tmpRect.origin.y = sideSpace;
    tmpRect.size.width = sideLength - 2 * sideSpace;
    tmpRect.size.height = sideLength - 2 * sideSpace;
    
    /* Goods image */
    [goods.image drawInRect:tmpRect];
    
    /* Name */
    tmpRect.origin.x += (tmpRect.size.width + objectSpace);
    tmpRect.origin.y = sideSpace;
    [goods.name drawAtPoint:tmpRect.origin withAttributes:nil];

    /* Price */
    tmpRect.origin.y += (15);
    
    if (0 == goods.price) {
        tmpString = @"已完全购买";
    } else {
        if (PRICE_TYPE_GOLD == goods.priceType) {
            tmpString = [NSString stringWithFormat:@"价格: %d金币", goods.price];
        } else if (PRICE_TYPE_CGOLD == goods.priceType) {
            tmpString = [NSString stringWithFormat:@"价格: %dC币", goods.price];
        } else if (PRICE_TYPE_RMB == goods.priceType) {
            tmpString = [NSString stringWithFormat:@"价格: ￥%d", goods.price];
        }
    }
    
    [tmpString drawAtPoint:tmpRect.origin withAttributes:nil];
    
    /* Descreption */
    tmpRect.origin.y += (15);
    [goods.descreption drawAtPoint:tmpRect.origin withAttributes:nil];

    /* DetailInfo */
    tmpRect.origin.y = self.bounds.size.height / 2 + sideSpace;
    [goods.detailInfo drawAtPoint:tmpRect.origin withAttributes:nil];
}

- (CGRect)imageRect
{
    int sideSpace = 3;
    int sideLength = 30;
    
    CGRect tmpRect = CGRectZero;
    tmpRect.origin.x = sideSpace;
    tmpRect.origin.y = sideSpace;
    tmpRect.size.width = sideLength - sideSpace * 2;
    tmpRect.size.height = sideLength - sideSpace * 2;
    
    return tmpRect;
}

- (NSDictionary *)goodsStrAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [UIFont systemFontOfSize:15.0f], NSFontAttributeName,
            [UIColor whiteColor], NSForegroundColorAttributeName,
            nil];
}

@end
