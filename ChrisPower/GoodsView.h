//
//  GoodsView.h
//  ChrisPower
//
//  Created by Chris on 15/1/14.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    SHOP_TYPE_PLAYER = 0,
    SHOP_TYPE_MONSTER,
    SHOP_TYPE_TOWER,
    SHOP_TYPE_CANNON,
    SHOP_TYPE_MISC,
    SHOP_TYPE_MONEY,
    
    SHOP_TYPE_HOME,
    SHOP_TYPE_DEFENDER,
};

@class GoodsView;

@protocol GoodsViewDelegate <NSObject>

- (void)GoodsViewDidTouched:(GoodsView *)view;

@end

@interface GoodsView : UIView
{
    int showType;
    int index;
    
    UIImage *image;
    NSString *goodsName;
}
@property (nonatomic, weak) id<GoodsViewDelegate> delegate;
@property (nonatomic) int showType;
@property (nonatomic) int index;
@property (nonatomic, retain) UIImage *image;

+ (NSComparator)comparator;

- (id)initWithType:(int)type index:(int)index;

@end
