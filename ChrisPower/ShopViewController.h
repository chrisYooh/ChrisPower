//
//  ShopViewController.h
//  ChrisPower
//
//  Created by Chris on 15/1/13.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "GoodsView.h"
#import "ViewController.h"

@interface ShopViewController : ViewController
<GoodsViewDelegate,
GoodsDetailViewDataSource,
UIAlertViewDelegate>
{
    __weak IBOutlet UILabel *playerGold;
    __weak IBOutlet UILabel *playerCGold;
    
    UIView *goodsSelectBgView;
    UIScrollView *goodsSelectView;
    
    UIButton *toLeftButton;
    UIButton *toRightButton;
    
    /* monster */
    NSArray *playerArray;
    NSArray *monstersArray;
    NSArray *towersArray;
    NSArray *cannonsArray;
    NSArray *miscArray;
    NSArray *moneyArray;
    
    UIScrollView *goodsDetailScrollView;
    GoodsDetailView *goodsDetailView;

    /* Shop select buttons */
    UIButton *playerShop;
    UIButton *monsterShop;
    UIButton *towerShop;
    UIButton *cannonShop;
    UIButton *miscShop;
    UIButton *moneyShop;
    
    int currentShopType;
    Goods *currentGoods;
    
    /* In-App Purchases */
    MBProgressHUD *hud;

    __weak NSArray *currentArray;
}

@end
