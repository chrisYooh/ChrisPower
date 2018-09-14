//
//  ShopViewController.m
//  ChrisPower
//
//  Created by Chris on 15/1/13.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "InAppRageIAPHelper.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

#import "UIViewController+SpecialScreenShot.h"

#import "GameConfig.h"
#import "Player.h"

#import "ChrisMonster.h"
#import "ChrisTower.h"
#import "ChrisCannon.h"

#import "Player.h"
#import "DynamicMonster.h"
#import "DynamicTower.h"
#import "DynamicCannon.h"

#import "Goods.h"
#import "GoodsDetailView.h"

#import "ShareViewController.h"

#import "ShopViewController.h"

#define CGOLD_GOODS_OFFSET      0
#define GOLD_GOODS_OFFSET       7

@interface ShopViewController ()

@end

/* Add a new shop need do following things 
 1. shopChanged
 2. goodsViewDidTouched
 3. buyGoods
 */

/* CreateViews
        Alloc the views which needed.
   Localized vies;
        Localized the views need display.
 */

@implementation ShopViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createViews];
    [self localizeViews];
    
    currentArray = playerArray;
    currentShopType = SHOP_TYPE_PLAYER;
    [self updateGoodsViewsWithNewGoodsArray:currentArray];

    Player *player = [Player currentPlayer];
    [playerGold setText:[NSString stringWithFormat:@"%d", player.gold]];
    [playerCGold setText:[NSString stringWithFormat:@"%d", player.cGold]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    
    [super viewWillAppear:animated];
}

#pragma mark GoodsViewDelegate
- (void)GoodsViewDidTouched:(GoodsView *)view
{
    [goodsDetailView setNeedsDisplay];

    if (nil == currentGoods) {
        currentGoods = [[Goods alloc] init];
    }
    
    [currentGoods setShopType:currentShopType];
    [currentGoods setGoodsIndex:view.index];
    [currentGoods setCanBuy:YES];
    [currentGoods setImage:view.image];
    
    [self updateCurrentGoodsWithShop:currentShopType index:view.index];
    
    [self addSpinAnimationToLayer:view.layer];
}

#pragma mark GoodsDetailViewDataSource
- (Goods *)goodsDetailViewGoods:(GoodsDetailView *)view
{
    return currentGoods;
}

#pragma mark CreateViews
/*       1----------------------------View----------------------------------
       1.1---------GoodsSelectBgView--------------------------------------
     1.1.1--GoodsSelectView--|--shopButtons---|---PointButtons--|--GoodsDetailScrollView---
   1.1.1.1-----GoodsViews----|                                  |--GoodsDetailView---
 */
- (void)createViews
{
    /* 1.1 GoodsSelectBgView */
    goodsSelectBgView = [[UIView alloc] initWithFrame:CGRectZero];
    
    /* 1.1.1 GoodsSelecteView */
    goodsSelectView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [goodsSelectView setBackgroundColor:[UIColor clearColor]];
    [goodsSelectView setPagingEnabled:YES];
    
    /* 1.1.1.1 GoodsViews */
    [self createPlayerShowGoodsViews];
    [self createMonsterShopGoodsViews];
    [self createTowerShopGoodsViews];
    [self createCannonShopGoodsViews];
//    [self createMiscShopGoodsViews];
//    [self createMoneyShopGoodsViews];
    
    /* 1.1.2 shopButtons */
    [self createShopButtons];
    
    /* 1.1.3 PointViews */
    toLeftButton = [[UIButton alloc] init];
    [toLeftButton setImage:[UIImage imageNamed:@"button_toLeft50X150.png"] forState:UIControlStateNormal];
    [toLeftButton addTarget:self action:@selector(lastPage:) forControlEvents:UIControlEventTouchUpInside];
    
    toRightButton = [[UIButton alloc] init];
    [toRightButton setImage:[UIImage imageNamed:@"button_toRight50X150.png"] forState:UIControlStateNormal];
    [toRightButton addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
    
    /* 1.1.4 GoodsDetaiScrolllView */
    goodsDetailScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [goodsDetailScrollView setBackgroundColor:[UIColor clearColor]];
    [goodsDetailScrollView setPagingEnabled:YES];
    
    /* 1.1.4.1 GoodsDetailView */
    goodsDetailView = [[GoodsDetailView alloc] initWithFrame:CGRectZero];
    [goodsDetailView setBackgroundColor:[UIColor clearColor]];
    [goodsDetailView setDelegate:self];
}

- (void)createShopButtons
{
    playerShop = [[UIButton alloc] init];
    [playerShop setImage:[UIImage imageNamed:@"shop_button_player100X100.png"] forState:UIControlStateNormal];
    [playerShop.titleLabel setText:@"player"];
    [playerShop addTarget:self action:@selector(shopChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    monsterShop = [[UIButton alloc] init];
    [monsterShop setImage:[UIImage imageNamed:@"shop_button_monster100X100.png"] forState:UIControlStateNormal];
    [monsterShop.titleLabel setText:@"monster"];
    [monsterShop addTarget:self action:@selector(shopChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    towerShop = [[UIButton alloc] init];
    [towerShop setImage:[UIImage imageNamed:@"shop_button_tower100X100.png"] forState:UIControlStateNormal];
    [towerShop.titleLabel setText:@"tower"];
    [towerShop addTarget:self action:@selector(shopChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    cannonShop = [[UIButton alloc] init];
    [cannonShop setImage:[UIImage imageNamed:@"shop_button_cannon100X100.png"] forState:UIControlStateNormal];
    [cannonShop.titleLabel setText:@"cannon"];
    [cannonShop addTarget:self action:@selector(shopChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    miscShop = [[UIButton alloc] init];
    [miscShop setImage:[UIImage imageNamed:@"shop_button_misc100X100.png"] forState:UIControlStateNormal];
    [miscShop.titleLabel setText:@"misc"];
    [miscShop addTarget:self action:@selector(shopChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    moneyShop = [[UIButton alloc] init];
    [moneyShop setImage:[UIImage imageNamed:@"shop_button_money100X100.png"] forState:UIControlStateNormal];
    [moneyShop.titleLabel setText:@"money"];
    [moneyShop addTarget:self action:@selector(shopChanged:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark localizedViews
/*       1----------------------------View----------------------------------
       1.1---------GoodsSelectBgView--------------------------------------
     1.1.1--GoodsSelectView--|--shopButtons---|---PointButtons--|--GoodsDetailScrollView---
   1.1.1.1-----GoodsViews----|                                  |--GoodsDetailView---
 */
- (void)localizeViews
{
    /* 1.1 GoodsSelectBgView */
    [self localizedBackgroundViewInView:self.view];
    
    /* 1.1.1 GoodsSelectView */
    [self localizedGoodsSelectViewInView:goodsSelectBgView];
    
    /* 1.1.2 shopButtons */
    [self localizedShopButtonsInView:goodsSelectBgView];
    
    /* 1.1.3 PointViews */
    [self localizedPointerViewsInView:goodsSelectBgView];
    
    /* 1.1.4 GoodsDetailScrollView */
    [self localizedGoodsDetailScrollViewInView:goodsSelectBgView];
    
    /* 1.1.4.1 GoodsDetailView */
    [self localizedGoodsDetailViewInView:goodsDetailScrollView];
}

- (void)localizedBackgroundViewInView:(UIView *)superView
{
    CGRect wholeWindow = [UIScreen mainScreen].bounds;
    CGRect tmpRect = CGRectZero;
    int sideSpace = 30;
    int detailWidth = 50;
    
    tmpRect.origin.x = sideSpace;
    tmpRect.origin.y = sideSpace;
    tmpRect.size.width = wholeWindow.size.width - detailWidth - sideSpace * 3;
    tmpRect.size.height = wholeWindow.size.height - sideSpace * 2;
    [goodsSelectBgView setFrame:tmpRect];
    
    /* Set background image*/
    UIImage *tmpImage = [UIImage imageNamed:@"bg_shop400X300.png"];
    UIImage *suitImage = [self originImage:tmpImage scaleToSize:goodsSelectBgView.bounds.size];
    [goodsSelectBgView setBackgroundColor:[UIColor colorWithPatternImage:suitImage]];
    
    [superView addSubview:goodsSelectBgView];
}

- (void)localizedGoodsSelectViewInView:(UIView *)superView
{
    CGSize size = superView.bounds.size;
    CGRect tmpRect = CGRectZero;
    
    tmpRect.origin.x = size.width * (0.09 + 0.1);
    tmpRect.origin.y = size.height * 0.42;
    tmpRect.size.width = size.width * (0.83 - 0.2);
    tmpRect.size.height = size.height * 0.3;
    
    [goodsSelectView setFrame:tmpRect];
    [superView addSubview:goodsSelectView];
}

- (void)localizedPointerViewsInView:(UIView *)superView
{
    CGSize size = superView.bounds.size;
    CGRect tmpRect = CGRectZero;
    
    tmpRect.origin.x = size.width * 0.11;
    tmpRect.origin.y = size.height * (0.42 + 0.05);
    tmpRect.size.width = size.width * 0.06;
    tmpRect.size.height = size.height * (0.3 - 0.1);
    [toLeftButton setFrame:tmpRect];
    [superView addSubview:toLeftButton];
    
    tmpRect.origin.x = size.width * 0.83;
    [toRightButton setFrame:tmpRect];
    [superView addSubview:toRightButton];
}

- (void)localizedGoodsDetailScrollViewInView:(UIView *)superView
{
    CGSize size = superView.bounds.size;
    CGRect tmpRect = CGRectZero;
    
    tmpRect.origin.x = size.width * 0.09;
    tmpRect.origin.y = size.height * 0.1;
    tmpRect.size.width = size.width * 0.83;
    tmpRect.size.height = size.height * 0.3;
    
    [goodsDetailScrollView setFrame:tmpRect];
    
    tmpRect.size.height *= 2;
    [goodsDetailScrollView setContentSize:tmpRect.size];
    
    [superView addSubview:goodsDetailScrollView];
}

- (void)localizedGoodsDetailViewInView:(UIView *)superView
{
    [self updateGoodsDetailView];
    [superView addSubview:goodsDetailView];
}

- (void)localizedShopButtonsInView:(UIView *)superView
{
    CGRect tmpRect = CGRectZero;
    CGSize size = superView.bounds.size;
    int sideLength = size.height * 0.09;
    int sideSpace = 12;
    
    tmpRect.origin.x = size.width * 0.12;
    tmpRect.origin.y = size.height * 0.79;
    tmpRect.size.width = sideLength;
    tmpRect.size.height = sideLength;
    
    [playerShop setFrame:tmpRect];
    [superView addSubview:playerShop];
    
    tmpRect.origin.x += (sideSpace + sideLength);
    [monsterShop setFrame:tmpRect];
    [superView addSubview:monsterShop];
    
    tmpRect.origin.x += (sideSpace + sideLength);
    [towerShop setFrame:tmpRect];
    [superView addSubview:towerShop];

    tmpRect.origin.x += (sideSpace + sideLength);
    [cannonShop setFrame:tmpRect];
    [superView addSubview:cannonShop];

    tmpRect.origin.x += (sideSpace + sideLength);
    [miscShop setFrame:tmpRect];
    [superView addSubview:miscShop];

    tmpRect.origin.x += (sideSpace + sideLength);
    [moneyShop setFrame:tmpRect];
    [superView addSubview:moneyShop];
}

#pragma mark Dynamic views update
- (void)updateGoodsViewsWithNewGoodsArray:(NSArray *)newArray
{
    /* Clear currentViews */
    for (GoodsView *view in currentArray) {
        [view removeFromSuperview];
    }
    currentArray = newArray;

    CGRect tmpRect = CGRectZero;
    int sideSpace = 10;
    int goodsWidth = 60;
    int goodsOneLineNumber = ((goodsWidth * 4 + sideSpace * 4) <= goodsSelectView.bounds.size.width) ? 4 : 3;
    goodsWidth = (goodsSelectView.bounds.size.width - sideSpace * goodsOneLineNumber) / goodsOneLineNumber;
    int goodsHeight = goodsWidth;
    
    tmpRect.origin.x = 0;
    tmpRect.origin.y = sideSpace;
    tmpRect.size.width = goodsWidth;
    tmpRect.size.height = goodsHeight;
    
    for (GoodsView *view in currentArray) {
        [view setFrame:tmpRect];
        [goodsSelectView addSubview:view];
        tmpRect.origin.x += (goodsWidth + sideSpace);
    }
    
    /* Reset scorllView size */
    tmpRect = goodsSelectView.frame;
    tmpRect.size.width = (goodsWidth + sideSpace) * goodsOneLineNumber;
    [goodsSelectView setFrame:tmpRect];
    
    /* Reset scrollView content size */
    int pageNumber = ((int)currentArray.count - 1) / goodsOneLineNumber + 1;
    CGSize tmpSize = goodsSelectView.bounds.size;
    tmpSize.width *= pageNumber;
    [goodsSelectView setContentSize:tmpSize];
    
    /* Rest scrollView offset */
    [goodsSelectView setContentOffset:CGPointZero];
}

- (void)updateGoodsDetailView
{
    int sideSpace = 2;
    CGRect tmpRect = goodsDetailScrollView.bounds;
    
    tmpRect.origin.x = sideSpace;
    tmpRect.origin.y = sideSpace;
    tmpRect.size.width -= (sideSpace * 2);
    tmpRect.size.height *= 2;
    [goodsDetailView setFrame:tmpRect];
}

#pragma mark Shop operate
- (void)shopChanged:(UIButton *)sender
{
    int type = 0;
    
    if ([@"player" isEqualToString:sender.titleLabel.text]) {
        type = SHOP_TYPE_PLAYER;
    } else if ([@"monster" isEqualToString:sender.titleLabel.text]) {
        type = SHOP_TYPE_MONSTER;
    } else if ([@"tower" isEqualToString:sender.titleLabel.text]) {
        type = SHOP_TYPE_TOWER;
    } else if ([@"cannon" isEqualToString:sender.titleLabel.text]) {
        type = SHOP_TYPE_CANNON;
    } else if ([@"misc" isEqualToString:sender.titleLabel.text]) {
        type = SHOP_TYPE_MISC;
    } else if ([@"money" isEqualToString:sender.titleLabel.text]) {
        type = SHOP_TYPE_MONEY;
    }
    
    [self updateCurrentShop:type];
    [self addSpinAnimationToLayer:sender.imageView.layer];
}

- (void)updateCurrentGoodsWithShop:(int)shopType index:(int)index
{
    switch (shopType) {
        case SHOP_TYPE_PLAYER:
            [self updateCurrentGoodsWithPlayerShopIndex:index];
            break;
        case SHOP_TYPE_MONSTER:
            [self updateCurrentGoodsWithMonsterType:index];
            break;
        case SHOP_TYPE_TOWER:
            [self updateCurrentGoodsWithTowerType:index];
            break;
        case SHOP_TYPE_CANNON:
            [self updateCurrentGoodsWithCannonShopIndex:index];
            break;
        case SHOP_TYPE_MISC:
            [self updateCurrentGoodsWithMiscShopIndex:index];
            break;
        case SHOP_TYPE_MONEY:
            [self updateCurrentGoodsWithMoneyShopIndex:index];
            break;
            
        default:
            break;
    }
}

- (void)shop:(int)shopType sellingGoodsWithIndex:(int)index
{
    switch (shopType) {
        case SHOP_TYPE_PLAYER:
            [self gotGoodsFromPlayerShopWithIndex:index];
            break;
        case SHOP_TYPE_MONSTER:
            [self gotGoodsFromMonsterShopWithIndex:index];
            break;
        case SHOP_TYPE_TOWER:
            [self gotGoodsFromTowerShopWithIndex:index];
            break;
        case SHOP_TYPE_CANNON:
            [self gotGoodsFromCannonShopWithIndex:index];
            break;
        case SHOP_TYPE_MISC:
            [self gotGoodsFromMiscShopWithIndex:index];
            break;
        case SHOP_TYPE_MONEY:
            [self gotGoodsFromMoneyShopWithIndex:index];
            break;
            
        default:
            break;
    }
}

- (void)updateCurrentShop:(int)type
{
    NSArray *newGoodsArray = nil;
    
    if (type == currentShopType) {
        return;
    }
    
    switch (type) {
        case SHOP_TYPE_PLAYER:
            newGoodsArray = playerArray;
            break;
        case SHOP_TYPE_MONSTER:
            newGoodsArray = monstersArray;
            break;
        case SHOP_TYPE_TOWER:
            newGoodsArray = towersArray;
            break;
        case SHOP_TYPE_CANNON:
            newGoodsArray = cannonsArray;
            break;
        case SHOP_TYPE_MISC:
            if (nil == miscArray) {
                if (1 == [self requestIAPGoods]) {
                    [self createMiscShopGoodsViews];
                }
            }
            newGoodsArray = miscArray;
            break;
        case SHOP_TYPE_MONEY:
            /* Request products */
            if (nil == moneyArray) {
                if (1 == [self requestIAPGoods]) {
                    [self createMoneyShopGoodsViews];
                }
            }
            newGoodsArray = moneyArray;
            break;
            
        default:
            newGoodsArray = nil;
            break;
    }
    currentShopType = type;
    currentGoods = nil;
    [goodsDetailView setNeedsDisplay];
    
    [self updateGoodsViewsWithNewGoodsArray:newGoodsArray];
}

#pragma mark Goods operate
/* Add a new goods need do following things
 1. updateCurrentGoodsWith----ShopIndex:(int)index
 When click a goodsView, do update
 When buy goods, may need do update
 */

enum {
    PLAYER_SHOP_GOODS_INDEX_MAPMAKER = 1,

    PLAYER_SHOP_GOODS_INDEX_ATTACK_POWER,
    PLAYER_SHOP_GOODS_INDEX_IG_POWER,
    PLAYER_SHOP_GOODS_INDEX_ATTACK_RANGE_POWER,
    PLAYER_SHOP_GOODS_INDEX_ATTACK_INTERVAL_POWER,
    PLAYER_SHOP_GOODS_INDEX_SPADDITION_POWER,
    
    PLAYER_SHOP_GOODS_INDEX_ATTACK_PERCENT,
    PLAYER_SHOP_GOODS_INDEX_IG_PERCENT,
    PLAYER_SHOP_GOODS_INDEX_ATTACK_RANGE_PERCENT,
    PLAYER_SHOP_GOODS_INDEX_ATTACK_INTERVAL_PERCENT,
    PLAYER_SHOP_GOODS_INDEX_SPADDITION_PERCENT,
    
    PLAYER_SHOP_GOODS_INDEX_TOWER_MAGIC_SLOT,
    
    TOWER_ATTRIBUTE_NUMBER = 5,
};

enum {
    CANNON_SHOP_GOODS_INDEX_TRACE = 1,
    CANNON_SHOP_GOODS_INDEX_SPUP,
    CANNON_SHOP_GOODS_INDEX_FIRE,
    CANNON_SHOP_GOODS_INDEX_ICE,
    CANNON_SHOP_GOODS_INDEX_GAS,
};

- (void)updateCurrentGoodsWithPlayerShopIndex:(int)index
{
    Player *player = [Player currentPlayer];
    
    switch (index) {
        case PLAYER_SHOP_GOODS_INDEX_MAPMAKER:
            [currentGoods setName:[NSString stringWithFormat:@"自制地图纸(%d张-->%d张)",
                                   player.diyMapNumberMax, player.diyMapNumberMax + 1]];
            [currentGoods setPrice:player.diyMapLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"你可以用这些地图纸自己绘制地图哦！\n"
             "地图纸越多，你能同时保存的自制地图个数也越多！\n"
             "发挥你的创造力，玩自己的塔防吧！"];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_POWER:
            [currentGoods setName:[NSString stringWithFormat:@"战塔个性话升级攻击提升(Lv%d-->%d)",
                                   player.randAttackPowerLv, player.randAttackPowerLv + 1]];
            [currentGoods setPrice:player.towerPowerCurrentAttackLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"战塔升级时，会随机地额外提升一项能力属性\n"
             "当提升属性为攻击力时，其提升值取决于该商品等级"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"额外攻击力提升概率：%d%%\n"
                                         "额外攻击力提升值：%d\n",
                                         player.towerPercentCurrentAttack,
                                         player.towerPowerCurrentAttack]];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_IG_POWER:
            [currentGoods setName:[NSString stringWithFormat:@"战塔个性话升级破甲提升(Lv%d-->%d)",
                                   player.randIgPowerLv, player.randIgPowerLv + 1]];
            [currentGoods setPrice:player.towerPowerCurrentIgLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"战塔升级时，会随机地额外提升一项能力属性\n"
             "当提升属性为破甲值时，其提升值取决于该商品等级"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"额外破甲值提升概率：%d%%\n"
                                         "额外破甲值提升值：%d\n",
                                         player.towerPercentCurrentIg,
                                         player.towerPowerCurrentIg]];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_RANGE_POWER:
            [currentGoods setName:[NSString stringWithFormat:@"战塔个性话升级攻击范围提升(Lv%d-->%d)",
                                   player.randAttackRangePowerLv, player.randAttackRangePowerLv + 1]];
            [currentGoods setPrice:player.towerPowerCurrentAttackRangeLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"战塔升级时，会随机地额外提升一项能力属性\n"
             "当提升属性为攻击范围时，其提升值取决于该商品等级"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"额外攻击范围提升概率：%d%%\n"
                                         "额外攻击范围提升值：%d\n",
                                         player.towerPercentCurrentAttackRange,
                                         player.towerPowerCurrentAttackRange]];
            break;
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_INTERVAL_POWER:
            [currentGoods setName:[NSString stringWithFormat:@"战塔个性话升级攻击频率提升(Lv%d-->%d)",
                                   player.randAttackIntervalPowerLv, player.randAttackIntervalPowerLv + 1]];
            [currentGoods setPrice:player.towerPowerCurrentAttackIntervalLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"战塔升级时，会随机地额外提升一项能力属性\n"
             "当提升属性为攻击频率时，其提升值取决于该商品等级"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"额外攻击频率提升概率：%d%%\n"
                                         "额外攻击频率提升值：%d\n",
                                         player.towerPercentCurrentAttackInterval,
                                         player.towerPowerCurrentAttackInterval]];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_SPADDITION_POWER:
            [currentGoods setName:[NSString stringWithFormat:@"战塔个性话升级后座力提升(Lv%d-->%d)",
                                   player.randSpadditionPowerLv, player.randSpadditionPowerLv + 1]];
            [currentGoods setPrice:player.towerPowerCurrentSpAdditionLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"战塔升级时，会随机地额外提升一项能力属性\n"
             "当提升属性为后座力时，其提升值取决于该商品等级"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"额外炮弹附加速度提升概率：%d%%\n"
                                         "额外炮弹附加速度提升值：%d\n",
                                         player.towerPercentCurrentSpAddition,
                                         player.towerPowerCurrentSpAddition]];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_PERCENT:
            [currentGoods setName:[NSString stringWithFormat:@"战塔个性话升级攻击概率提升(Lv%d-->%d)",
                                   player.randAttackPercentLv, player.randAttackPercentLv + 1]];
            [currentGoods setPrice:player.towerPercentCurrentAttackLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"战塔升级时，会随机地额外提升一项能力属性\n"
             "该商品等级决定着战塔个性化升级提升攻击能力的概率"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"额外攻击力提升概率：%d%%\n"
                                         "额外攻击力提升值：%d\n",
                                         player.towerPercentCurrentAttack,
                                         player.towerPowerCurrentAttack]];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_IG_PERCENT:
            [currentGoods setName:[NSString stringWithFormat:@"战塔个性话升级破甲概率提升(Lv%d-->%d)",
                                   player.randIgPercentLv, player.randIgPercentLv + 1]];
            [currentGoods setPrice:player.towerPercentCurrentIgLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"战塔升级时，会随机地额外提升一项能力属性\n"
             "该商品等级决定着战塔个性化升级提升破甲能力的概率"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"额外破甲值提升概率：%d%%\n"
                                         "额外破甲值提升值：%d\n",
                                         player.towerPercentCurrentIg,
                                         player.towerPowerCurrentIg]];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_RANGE_PERCENT:
            [currentGoods setName:[NSString stringWithFormat:@"战塔个性话升级攻击范围概率提升(Lv%d-->%d)",
                                   player.randAttackRangePercentLv, player.randAttackRangePercentLv + 1]];
            [currentGoods setPrice:player.towerPercentCurrentAttackRangeLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"战塔升级时，会随机地额外提升一项能力属性\n"
             "该商品等级决定着战塔个性化升级提升攻击范围的概率"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"额外攻击范围提升概率：%d%%\n"
                                         "额外攻击范围提升值：%d\n",
                                         player.towerPercentCurrentAttackRange,
                                         player.towerPowerCurrentAttackRange]];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_INTERVAL_PERCENT:
            [currentGoods setName:[NSString stringWithFormat:@"战塔个性话升级攻击频率概率提升(Lv%d-->%d)",
                                   player.randAttackIntervalPercentLv, player.randAttackIntervalPercentLv + 1]];
            [currentGoods setPrice:player.towerPercentCurrentAttackIntervalLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"战塔升级时，会随机地额外提升一项能力属性\n"
             "该商品等级决定着战塔个性化升级提升攻击频率的概率"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"额外攻击频率提升概率：%d%%\n"
                                         "额外攻击频率提升值：%d\n",
                                         player.towerPercentCurrentAttackInterval,
                                         player.towerPowerCurrentAttackInterval]];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_SPADDITION_PERCENT:
            [currentGoods setName:[NSString stringWithFormat:@"战塔个性话升级后座力概率提升(Lv%d-->%d)",
                                   player.randSpadditionPercentLv, player.randSpadditionPercentLv + 1]];
            [currentGoods setPrice:player.towerPercentCurrentSpAdditionLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"战塔升级时，会随机地额外提升一项能力属性\n"
             "该商品等级决定着战塔个性化升级提升后座力的概率"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"额外炮弹附加速度提升概率：%d%%\n"
                                         "额外炮弹附加速度提升值：%d\n",
                                         player.towerPercentCurrentSpAddition,
                                         player.towerPowerCurrentSpAddition]];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_TOWER_MAGIC_SLOT:
            [currentGoods setName:[NSString stringWithFormat:@"战塔魔法槽(%d个-->%d个)",
                                   player.towerMagicSlot, player.towerMagicSlot + 1]];
            [currentGoods setPrice:player.towerMagicSlotAddOneCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"战塔可同时装载战塔魔法的个数\n"
             "购买该商品后，战塔可同时状态多个炮弹魔法\n"
             "注：请至少购买两个战塔魔法后再考虑购买该商品"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"当前战塔魔法槽数量：%d/%d\n",
                                         player.towerMagicSlot,
                                         TOWER_MAGIC_SLOT_NUM_MAX]];
            break;
            
        default:
            break;
    }
    
    [goodsDetailView setNeedsDisplay];
}

- (void)updateCurrentGoodsWithMonsterType:(int)type
{
    ChrisMonster *tmpMonster = [[GameConfig globalConfig] getTemplateMonsterFromStoreWithType:type];
    DynamicMonster *dynMonster = [[Player currentPlayer] getDynamicMonsterByType:type];
 
    int price = lvUpExp[dynMonster.lv] - dynMonster.experience;
    price = price > 0 ? price : 0;
 
    [currentGoods setName:[NSString stringWithFormat:@"怪物克制训练(Lv%d-->%d)", dynMonster.lv, dynMonster.lv + 1]];
    [currentGoods setPrice:price];
    [currentGoods setPriceType:PRICE_TYPE_GOLD];
    [currentGoods setDescreption:[NSString stringWithFormat:@"提升对怪物的克制能力\n"
                                    "每级对该怪物造成的伤害增加%d%%",
                                  (int)([DynamicMonster hurtAdditionPerLevel] * 100)]];
    [currentGoods setDetailInfo:[NSString stringWithFormat:
                                @"生命: %d   护甲: %d   移动速度: %d\n"
                                 "击杀奖励: %d   等级: %d   击杀经验: %d\n",
                                 tmpMonster.healthPointMax,
                                 tmpMonster.armor,
                                 tmpMonster.moveSpeed,
                                 tmpMonster.killedGoldAward,
                                 dynMonster.lv,
                                 dynMonster.experience]];
    
    [goodsDetailView setNeedsDisplay];
}

- (void)updateCurrentGoodsWithTowerType:(int)type
{
    ChrisTower *tmpTower = [[GameConfig globalConfig] getTemplateTowerFromStoreWithType:type];
    DynamicTower *dynTower = [[Player currentPlayer] getDynamicTowerByType:type];
    
    int price = lvUpExp[dynTower.lv] - dynTower.experience;
    price = price > 0 ? price : 0;
    
    [currentGoods setName:[NSString stringWithFormat:@"战塔训练(Lv%d-->%d)", dynTower.lv, dynTower.lv + 1]];
    [currentGoods setPrice:price];
    [currentGoods setPriceType:PRICE_TYPE_GOLD];
    [currentGoods setDescreption:[NSString stringWithFormat:@"增强战塔的的能力\n"
     "每级增加战塔%d%%攻击力, %d%%攻击范围",
                                  (int)([DynamicTower attackAdditionPerLv] * 100),
                                  (int)([DynamicTower attackRangeAdditionPerLv] * 100)]];
    [currentGoods setDetailInfo:[NSString stringWithFormat:
                                 @"攻击力: %d   破甲量: %d   攻击间隔: %d\n"
                                 "攻击范围: %d   速度加成: %d   等级: %d\n"
                                 "经验值: %d\n",
                                 tmpTower.attack,
                                 tmpTower.ignoreArmor,
                                 tmpTower.attackInterval,
                                 tmpTower.attackRadius,
                                 tmpTower.speedAddition,
                                 dynTower.lv,
                                 dynTower.experience]];
    
    [goodsDetailView setNeedsDisplay];
}

- (void)updateCurrentGoodsWithCannonShopIndex:(int)index
{
    Player *player = [Player currentPlayer];
    
    switch (index) {
        case CANNON_SHOP_GOODS_INDEX_TRACE:
            if (0 == player.cannonTraceLv) {
                [currentGoods setName:@"炮弹魔法-追踪"];
            } else {
                [currentGoods setName:@"炮弹魔法-追踪（已购买）"];
            }
            [currentGoods setPrice:player.cannonMagicCurrentTraceLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"为战塔添加该炮弹魔法后，战塔发射的炮弹附加追踪效果\n"
             "炮弹魔法可以相互叠加"];
            break;
            
        case CANNON_SHOP_GOODS_INDEX_SPUP:
            if (0 == player.cannonSpUpLv) {
                [currentGoods setName:@"炮弹魔法-加速"];
            } else {
                [currentGoods setName:@"炮弹魔法-加速（已购买）"];
            }
            [currentGoods setPrice:player.cannonMagicCurrentSpUpLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"为战塔添加该炮弹魔法后，战塔发射的炮弹附加加速效果\n"
             "即移动过程中速度会不断增加\n"
             "炮弹魔法可以相互叠加"];
            break;
            
        case CANNON_SHOP_GOODS_INDEX_FIRE:
            if (player.cannonFireLv >= CANNON_MAGIC_LV_MAX) {
                [currentGoods setName:[NSString stringWithFormat:@"炮弹魔法-火焰(Lv%d)", player.cannonFireLv]];
            } else {
                [currentGoods setName:[NSString stringWithFormat:@"炮弹魔法-火焰(Lv%d-->%d)",
                                       player.cannonFireLv, player.cannonFireLv + 1]];
            }
            [currentGoods setPrice:player.cannonMagicCurrentFireLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"为战塔添加该炮弹魔法后，战塔发射的炮弹附加溅射效果\n"
             "即炮弹爆炸时会对爆炸范围内的怪物造成群体伤害\n"
             "炮弹魔法可以相互叠加"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"溅射范围：%d\n"
                                         "溅射伤害比率：%.2f\n",
                                         player.cannonMagicCurrentFireRange,
                                         player.cannonMagicFireHurtRatio]];
            break;
            
        case CANNON_SHOP_GOODS_INDEX_ICE:
            if (player.cannonIceLv >= CANNON_MAGIC_LV_MAX) {
                [currentGoods setName:[NSString stringWithFormat:@"炮弹魔法-寒冰(Lv%d)", player.cannonIceLv]];
            } else {
                [currentGoods setName:[NSString stringWithFormat:@"炮弹魔法-寒冰(Lv%d-->%d)",
                                   player.cannonIceLv, player.cannonIceLv + 1]];
            }
            [currentGoods setPrice:player.cannonMagicCurrentIceLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"为战塔添加该炮弹魔法后，战塔发射的炮弹附减速效果\n"
             "即炮弹爆炸时会在一定时间内降低目标怪物的速度\n"
             "炮弹魔法可以相互叠加"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"减速时间：%d\n"
                                         "减速比率：%.2f\n",
                                         player.cannonMagicCurrentIceTime,
                                         player.cannonMagicIceSpeedDownRatio]];
            break;
            
        case CANNON_SHOP_GOODS_INDEX_GAS:
            if (player.cannonGasLv >= CANNON_MAGIC_LV_MAX) {
                [currentGoods setName:[NSString stringWithFormat:@"炮弹魔法-毒气(Lv%d)", player.cannonGasLv]];
            } else {
                [currentGoods setName:[NSString stringWithFormat:@"炮弹魔法-毒气(Lv%d-->%d)",
                                   player.cannonGasLv, player.cannonGasLv + 1]];
            }
            [currentGoods setPrice:player.cannonMagicCurrentGasLvUpCost];
            [currentGoods setPriceType:PRICE_TYPE_CGOLD];
            [currentGoods setDescreption:@"为战塔添加该炮弹魔法后，战塔发射的炮弹附减速效果\n"
             "即炮弹爆炸时会使目标怪物在一定时间内受到持续伤害\n"
             "炮弹魔法可以相互叠加"];
            [currentGoods setDetailInfo:[NSString stringWithFormat:
                                         @"持续伤害时间：%d\n"
                                         "伤害间隔：%d\n"
                                         "每次伤害百分比：%d%%\n",
                                         player.cannonMagicCurrentGasTime,
                                         player.cannonMagicCurrentGasHurtInterval,
                                         player.cannonMagicCurrentGasHurtPercent]];
            break;
            
        default:
            break;
    }
    
    [goodsDetailView setNeedsDisplay];
}

- (void)updateCurrentGoodsWithMiscShopIndex:(int)index
{
    SKProduct *product = [[InAppRageIAPHelper sharedHelper].products objectAtIndex:(index + GOLD_GOODS_OFFSET - 1)];
    
    NSString *goldName = product.localizedTitle;
    NSString *detailInfo = nil;
    
    int priceType = PRICE_TYPE_RMB;
    int price = product.price.intValue;
    NSString *descreption = product.localizedDescription;
    detailInfo = descreption;
    
    [currentGoods setName:goldName];
    [currentGoods setPrice:price];
    [currentGoods setPriceType:priceType];
    [currentGoods setDescreption:descreption];
    [currentGoods setDetailInfo:detailInfo];
    
    [goodsDetailView setNeedsDisplay];
}

- (void)updateCurrentGoodsWithMoneyShopIndex:(int)index
{
    SKProduct *product = [[InAppRageIAPHelper sharedHelper].products objectAtIndex:(index + CGOLD_GOODS_OFFSET - 1)];
    
    NSString *goldName = product.localizedTitle;
    NSString *detailInfo = nil;
    
    int priceType = PRICE_TYPE_RMB;
    int price = product.price.intValue;
    NSString *descreption = product.localizedDescription;
    detailInfo = descreption;

    [currentGoods setName:goldName];
    [currentGoods setPrice:price];
    [currentGoods setPriceType:priceType];
    [currentGoods setDescreption:descreption];
    [currentGoods setDetailInfo:detailInfo];
    
    [goodsDetailView setNeedsDisplay];
}

/*
 2. buyGoodsIn----ShopWithIndex:(int)index
 When buy goods, need these functions to give goods.
 */
- (void)gotGoodsFromPlayerShopWithIndex:(int)index
{
    Player *player = [Player currentPlayer];
    
    switch (index) {
        case PLAYER_SHOP_GOODS_INDEX_MAPMAKER:
            [player getNewMapPaper];
            break;
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_POWER:
            [player towerPowerAttackLvUp];
            break;
        case PLAYER_SHOP_GOODS_INDEX_IG_POWER:
            [player towerPowerIgLvUp];
            break;
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_RANGE_POWER:
            [player towerPowerAttackRangeLvUp];
            break;
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_INTERVAL_POWER:
            [player towerPowerAttackIntervalLvUp];
            break;
        case PLAYER_SHOP_GOODS_INDEX_SPADDITION_POWER:
            [player towerPowerSpAdditionLvUp];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_PERCENT:
            [player towerPercentAttackLvUp];
            break;
        case PLAYER_SHOP_GOODS_INDEX_IG_PERCENT:
            [player towerPercentIgLvUp];
            break;
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_RANGE_PERCENT:
            [player towerPercentAttackRangeLvUp];
            break;
        case PLAYER_SHOP_GOODS_INDEX_ATTACK_INTERVAL_PERCENT:
            [player towerPercentAttackIntervalLvUp];
            break;
        case PLAYER_SHOP_GOODS_INDEX_SPADDITION_PERCENT:
            [player towerPercentSpAdditionLvUp];
            break;
            
        case PLAYER_SHOP_GOODS_INDEX_TOWER_MAGIC_SLOT:
            [player towerMagicSlotAddOne];
            break;
            
        default:
            break;
    }
    
    [NSKeyedArchiver archiveRootObject:player toFile:[Player gamePlayerFilePath]];
    [self updateCurrentGoodsWithPlayerShopIndex:index];
}

- (void)gotGoodsFromMonsterShopWithIndex:(int)index
{
    Player *player = [Player currentPlayer];
    DynamicMonster *dynMonster = [player getDynamicMonsterByType:index];
    
    [dynMonster updateCurrentExperienceByValue:currentGoods.price];
    [dynMonster infoUpdateWithCurrentValue];
    
    [NSKeyedArchiver archiveRootObject:player toFile:[Player gamePlayerFilePath]];

    [self updateCurrentGoodsWithMonsterType:index];
}

- (void)gotGoodsFromTowerShopWithIndex:(int)index
{
    Player *player = [Player currentPlayer];
    DynamicTower *dynTower = [player getDynamicTowerByType:index];
    
    [dynTower updateCurrentExperienceByValue:currentGoods.price];
    [dynTower infoUpdateWithCurrentValue];
    
    [NSKeyedArchiver archiveRootObject:player toFile:[Player gamePlayerFilePath]];
    
    [self updateCurrentGoodsWithTowerType:index];
}

- (void)gotGoodsFromCannonShopWithIndex:(int)index
{
    Player *player = [Player currentPlayer];
    
    switch (index) {
        case CANNON_SHOP_GOODS_INDEX_TRACE:
            [player cannonMagicTraceLvUp];
            break;
        case CANNON_SHOP_GOODS_INDEX_SPUP:
            [player cannonMagicSpUpLvUp];
            break;
        case CANNON_SHOP_GOODS_INDEX_FIRE:
            [player cannonMagicFireLvUp];
            break;
        case CANNON_SHOP_GOODS_INDEX_ICE:
            [player cannonMagicIceLvUp];
            break;
        case CANNON_SHOP_GOODS_INDEX_GAS:
            [player cannonMagicGasLvUp];
            break;
            
        default:
            break;
    }
    
    [NSKeyedArchiver archiveRootObject:player toFile:[Player gamePlayerFilePath]];
    [self updateCurrentGoodsWithCannonShopIndex:index];
}

- (void)gotGoodsFromMiscShopWithIndex:(int)index
{
    Player *player = [Player currentPlayer];
    int tmpIndex = index;
    
    if  (1 == tmpIndex) {
        [player earnGold:660];
    } else if (2 == tmpIndex) {
        [player earnGold:3600];
    } else if (3 == tmpIndex) {
        [player earnGold:8800];
    } else if (4 == tmpIndex) {
        [player earnGold:15800];
    } else if (5 == tmpIndex) {
        [player earnGold:28800];
    } else if (6 == tmpIndex) {
        [player earnGold:48800];
    } else if (7 == tmpIndex) {
        [player earnGold:98800];
    }
    
    [playerGold setText:[NSString stringWithFormat:@"%d", player.gold]];
}

- (void)gotGoodsFromMoneyShopWithIndex:(int)index
{
    Player *player = [Player currentPlayer];
    int tmpIndex = index;
    
    if  (1 == tmpIndex) {
        [player earnCGold:60];
    } else if (2 == tmpIndex) {
        [player earnCGold:318];
    } else if (3 == tmpIndex) {
        [player earnCGold:728];
    } else if (4 == tmpIndex) {
        [player earnCGold:1268];
    } else if (5 == tmpIndex) {
        [player earnCGold:2138];
    } else if (6 == tmpIndex) {
        [player earnCGold:3548];
    } else if (7 == tmpIndex) {
        [player earnCGold:7068];
    }
    
    [playerCGold setText:[NSString stringWithFormat:@"%d", player.cGold]];
}

/*
 3. create----ShopGoodsViews
 */
- (void)createPlayerShowGoodsViews
{
    GoodsView *view = nil;
    NSMutableArray *tmpShopArray = [[NSMutableArray alloc] init];
    
    /* Map Maker */
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_MAPMAKER];
    [view setImage:[UIImage imageNamed:@"map_maker100X100.png"]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
    
    /* Power */
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_ATTACK_POWER];
    [view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"rand_attack_power100X100.png"]]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
    
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_IG_POWER];
    [view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"rand_igarmor_power100X100.png"]]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
    
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_ATTACK_RANGE_POWER];
    [view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"rand_attack_range_power100X100.png"]]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
    
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_ATTACK_INTERVAL_POWER];
    [view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"rand_attack_ratio_power100X100.png"]]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
    
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_SPADDITION_POWER];
    [view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"rand_spaddition_power100X100.png"]]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];

    /* Ratio */
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_ATTACK_PERCENT];
    [view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"rand_attack_percent100X100.png"]]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
    
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_IG_PERCENT];
    [view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"rand_igarmor_percent100X100.png"]]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
    
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_ATTACK_RANGE_PERCENT];
    [view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"rand_attack_range_percent100X100.png"]]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
    
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_ATTACK_INTERVAL_PERCENT];
    [view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"rand_attack_ratio_percent100X100.png"]]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
    
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_SPADDITION_PERCENT];
    [view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"rand_spaddition_percent100X100.png"]]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
    
    /* Magic Slot */
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:PLAYER_SHOP_GOODS_INDEX_TOWER_MAGIC_SLOT];
    [view setImage:[UIImage imageNamed:@"tower_magic_slot100X100.png"]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
    
#if 0
    /* Chris Memory */
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_PLAYER index:50];
    [view setImage:[UIImage imageNamed:@"spmap_chris_memory100X100.png"]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];
#endif
    
    playerArray = [tmpShopArray sortedArrayUsingComparator:[GoodsView comparator]];
}

- (void)createMonsterShopGoodsViews
{
    /* MonsterViews */
    NSMutableArray *tmpMonsterArray = [[NSMutableArray alloc] init];
    [[GameConfig globalConfig] readOnlyEnumMonsterWithBlock:^(const ChrisMonster *monster, const NSString *key) {
        GoodsView *view = [[GoodsView alloc] initWithType:SHOP_TYPE_MONSTER index:monster.type];
        [view setImage:monster.iconImage];
        [view setDelegate:self];
        [tmpMonsterArray addObject:view];
    }];
    monstersArray = [tmpMonsterArray sortedArrayUsingComparator:[GoodsView comparator]];
}

- (void)createTowerShopGoodsViews
{
    /* TowerViews */
    NSMutableArray *tmpTowerArray = [[NSMutableArray alloc] init];
    [[GameConfig globalConfig] readOnlyEnumTowerWithBlock:^(const ChrisTower *tower, const NSString *key) {
        GoodsView *view = [[GoodsView alloc] initWithType:SHOP_TYPE_TOWER index:tower.type];
        [view setImage:tower.iconImage];
        [view setDelegate:self];
        [tmpTowerArray addObject:view];
    }];
    towersArray = [tmpTowerArray sortedArrayUsingComparator:[GoodsView comparator]];
}

- (void)createCannonShopGoodsViews
{
    GoodsView *view = nil;
    NSMutableArray *tmpShopArray = [[NSMutableArray alloc] init];
    
    /* Magic Cannons */
    view = [[GoodsView alloc] initWithType:SHOP_TYPE_CANNON index:CANNON_SHOP_GOODS_INDEX_TRACE];
    [view setImage:[UIImage imageNamed:@"cannon_trace100X100.png"]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];

    view = [[GoodsView alloc] initWithType:SHOP_TYPE_CANNON index:CANNON_SHOP_GOODS_INDEX_SPUP];
    [view setImage:[UIImage imageNamed:@"cannon_spup100X100.png"]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];

    view = [[GoodsView alloc] initWithType:SHOP_TYPE_CANNON index:CANNON_SHOP_GOODS_INDEX_FIRE];
    [view setImage:[UIImage imageNamed:@"cannon_fire100X100.png"]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];

    view = [[GoodsView alloc] initWithType:SHOP_TYPE_CANNON index:CANNON_SHOP_GOODS_INDEX_ICE];
    [view setImage:[UIImage imageNamed:@"cannon_ice100X100.png"]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];

    view = [[GoodsView alloc] initWithType:SHOP_TYPE_CANNON index:CANNON_SHOP_GOODS_INDEX_GAS];
    [view setImage:[UIImage imageNamed:@"cannon_gas100X100.png"]];
    [view setDelegate:self];
    [tmpShopArray addObject:view];

    cannonsArray = [tmpShopArray sortedArrayUsingComparator:[GoodsView comparator]];
    
}

#pragma mark Button click message
- (void)lastPage:(UIButton *)sender
{
    CGPoint tmpOffset = goodsSelectView.contentOffset;
    int currentPage = goodsSelectView.contentOffset.x /goodsSelectView.bounds.size.width;

    currentPage = currentPage > 0 ? currentPage - 1 : 0;
    tmpOffset.x = goodsSelectView.bounds.size.width * currentPage;
    [goodsSelectView setContentOffset:tmpOffset];
}

- (void)nextPage:(UIButton *)sender
{
    CGPoint tmpOffset = goodsSelectView.contentOffset;
    int pageNumber = goodsSelectView.contentSize.width / goodsSelectView.bounds.size.width;
    int currentPage = goodsSelectView.contentOffset.x /goodsSelectView.bounds.size.width;
    
    currentPage = currentPage < pageNumber - 1 ? currentPage + 1 : pageNumber - 1;
    tmpOffset.x = goodsSelectView.bounds.size.width * currentPage;
    [goodsSelectView setContentOffset:tmpOffset];
}

- (IBAction)buy:(id)sender
{
    if (NO == [self buyCheck]) {
        return;
    }

    if (PRICE_TYPE_RMB == currentGoods.priceType) {
        [self CnyBuy];
    } else {
        
        /* User Alert View to buy gold/cGold goods */
        NSString *checkInfo = nil;
        
        if (PRICE_TYPE_GOLD == currentGoods.priceType) {
            checkInfo = [NSString stringWithFormat:@"以【%d金币】购买该商品", currentGoods.price];
        } else if (PRICE_TYPE_CGOLD == currentGoods.priceType) {
            checkInfo = [NSString stringWithFormat:@"以【%dC币】购买该商品", currentGoods.price];
        } else {
            checkInfo = @"购买确认信息错误\n";
        }
        
        UIAlertAction *buyAction = [UIAlertAction actionWithTitle:@"确定购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self singleBuy];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"再逛逛" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"User stop buying");
        }];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"购买确认"
                                                                       message:checkInfo
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:buyAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (BOOL)buyCheck
{
    Player *player = [Player currentPlayer];
    NSString *alertStr = nil;
    BOOL ret = NO;
    
    if (nil == currentGoods) {
        alertStr = @"没有选中一个商品";
    } else if (NO == currentGoods.canBuy) {
        alertStr = @"商品不可再次购买";
    } else if (0 == currentGoods.price) {
        alertStr = @"商品已经完全购买，无需再次购买";
    } else if (PRICE_TYPE_GOLD == currentGoods.priceType && currentGoods.price > player.gold) {
        alertStr = @"金币不足，不可购买";
    } else if (PRICE_TYPE_CGOLD == currentGoods.priceType && currentGoods.price > player.cGold) {
        alertStr = @"C币不足，不可购买";
    } else if (PRICE_TYPE_RMB == currentGoods.priceType) {
        ret = YES;
    } else {
        ret = YES;
    }
    
    if (NO == ret) {
        
        UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"不可购买"
                                                               message:alertStr
                                                          cancelButton:@"我知道了"];
        [self presentViewController:alert animated:YES completion:nil];
    }

    return ret;
}

- (void)singleBuy
{
    Player *player = [Player currentPlayer];
    
    /* Pay money */
    if (PRICE_TYPE_GOLD == currentGoods.priceType) {
        
        /* Buy use Gold */
        if (NO == [player spendGold:currentGoods.price]) {
            NSLog(@"Not enough gold to pay");
            return;
        }
        [playerGold setText:[NSString stringWithFormat:@"%d", player.gold]];
        
    } else if (PRICE_TYPE_CGOLD == currentGoods.priceType) {
        
        /* Buy use cGold */
        if (NO == [player spendCGold:currentGoods.price]) {
            NSLog(@"Not enough cGold to pay");
            return;
        }
        [playerCGold setText:[NSString stringWithFormat:@"%d", player.cGold]];
        
    } else if (PRICE_TYPE_RMB == currentGoods.priceType) {
        return;
    }
    
    /* Give goods */
    [self shop:currentShopType sellingGoodsWithIndex:currentGoods.goodsIndex];
}

- (void)CnyBuy
{
    /* get the product */
    SKProduct *product = nil;
    if (nil != [InAppRageIAPHelper sharedHelper].products) {
        
        if (SHOP_TYPE_MISC == currentShopType) {
            product = [[InAppRageIAPHelper sharedHelper].products objectAtIndex:(currentGoods.goodsIndex + GOLD_GOODS_OFFSET - 1)];
        } else if (SHOP_TYPE_MONEY == currentShopType) {
            product = [[InAppRageIAPHelper sharedHelper].products objectAtIndex:(currentGoods.goodsIndex + CGOLD_GOODS_OFFSET - 1)];
        }

        //            NSLog(@"Buying %d, %@... ", currentGoods.goodsIndex, product.productIdentifier);
    }
    
    /* Buy use money */
    if (nil != product) {
        [[InAppRageIAPHelper sharedHelper] buyProductIdentifier:product.productIdentifier];
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"链接中...";
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:50];
    }
    
    /* The CNY goods is given by the notification */
}

- (IBAction)returnBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark In-App Purchases
- (int)requestIAPGoods
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        NSLog(@"No internet connection!");
    } else {
        if (nil == [InAppRageIAPHelper sharedHelper].products) {
            
            [[InAppRageIAPHelper sharedHelper] requestProducts];
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"商品加载中...";
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
        } else {
            return 1;
        }
    }
    
    return 0;
}

- (void)productsLoaded:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [self createMiscShopGoodsViews];
    [self createMoneyShopGoodsViews];
    
    if (SHOP_TYPE_MISC == currentShopType) {
        [self updateGoodsViewsWithNewGoodsArray:miscArray];
    } else if (SHOP_TYPE_MONEY == currentShopType) {
        [self updateGoodsViewsWithNewGoodsArray:moneyArray];
    }
}


- (void)createMiscShopGoodsViews
{
    /* MiscViews */
    NSMutableArray *tmpMiscArray = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 7; i++) {
        GoodsView *view = [[GoodsView alloc] initWithType:SHOP_TYPE_MISC index:i];
        NSString *imageName = [self goldAggImageNameWithIndex:i];
        [view setImage:[UIImage imageNamed:imageName]];
        [view setDelegate:self];
        [tmpMiscArray addObject:view];
    }
    miscArray = [tmpMiscArray sortedArrayUsingComparator:[GoodsView comparator]];
}

- (void)createMoneyShopGoodsViews
{
    NSMutableArray *tmpMoneyArray = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 7; i++ ) {
        GoodsView *view = [[GoodsView alloc] initWithType:SHOP_TYPE_MONEY index:i];
        NSString *imageName = [self cGoldTinImageNameWithIndex:i];
        [view setImage:[UIImage imageNamed:imageName]];
        [view setDelegate:self];
        [tmpMoneyArray addObject:view];
    }
    moneyArray = [tmpMoneyArray sortedArrayUsingComparator:[GoodsView comparator]];
}

- (void)productPurchased:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSString *productIdentifier = (NSString *) notification.object;
    NSLog(@"Purchased: %@", productIdentifier);
    
    [self shop:currentShopType sellingGoodsWithIndex:currentGoods.goodsIndex];
//    [self.tableView reloadData];
}

- (void)productPurchaseFailed:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;
    if (transaction.error.code != SKErrorPaymentCancelled) {
        
        UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"Error"
                                                               message:transaction.error.localizedDescription
                                                          cancelButton:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)timeout:(id)arg
{
    hud.labelText = @"Timeout!";
    hud.detailsLabelText = @"Please try again later.";
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
}

- (void)dismissHUD:(id)arg
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    hud = nil;
}

#pragma mark misc
- (NSString *)goldAggImageNameWithIndex:(int)index
{
    return [NSString stringWithFormat:@"gold_agg%d_100X100.png", index];
}

- (NSString *)cGoldTinImageNameWithIndex:(int)index
{
    return [NSString stringWithFormat:@"cgold_tin%d_100X100.png", index];
}

/* image resize */
-(UIImage*)originImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

/* Animation */
- (void)addSpinAnimationToLayer:(CALayer *)layer
{
    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [spin setToValue:[NSNumber numberWithFloat:M_PI * 2.0]];
    [spin setDuration:1.0];
    [spin setDelegate:self];
    
    CAMediaTimingFunction *tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [spin setTimingFunction:tf];
    
    [layer addAnimation:spin forKey:@"spinAnimation"];
}

#pragma mark Shok Detect
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake )
    {
        ShareViewController *gvController = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
        [gvController setSpecialScreenShot:[self specialScreenShot]];
        [self presentViewController:gvController animated:YES completion:nil];
        
    }
}

@end
