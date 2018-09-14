//
//  Goods.h
//  ChrisPower
//
//  Created by Chris on 15/2/5.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum {
    PRICE_TYPE_GOLD = 0,
    PRICE_TYPE_CGOLD,
    PRICE_TYPE_RMB,
};

@interface Goods : NSObject

@property (nonatomic) int shopType;
@property (nonatomic) int goodsIndex;

@property (nonatomic) BOOL canBuy;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic) int price;
@property (nonatomic) int priceType;
@property (nonatomic, retain) NSString *descreption;
@property (nonatomic, retain) NSString *detailInfo;

@end
