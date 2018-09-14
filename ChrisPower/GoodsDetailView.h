//
//  GoodsDetailView.h
//  ChrisPower
//
//  Created by Chris on 15/1/14.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Goods;
@class GoodsDetailView;

@protocol GoodsDetailViewDataSource <NSObject>

- (Goods *)goodsDetailViewGoods:(GoodsDetailView *)view;

@end

/* -------------GoodsDetailView----------------
   --imageView--|--Value---|---Descreption--- */
@interface GoodsDetailView : UIView

@property (nonatomic, weak) id<GoodsDetailViewDataSource> delegate;

@end
