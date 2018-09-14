//
//  GameBackGroundView.m
//  ChrisPower
//
//  Created by Chris on 14/12/28.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "GameConfig.h"
#import "Player.h"

#import "ChrisTower.h"
#import "ChrisCannon.h"

#import "NoteView.h"
#import "GameOpItemView.h"

#import "GameBackGroundView.h"

enum {
    MENU_NONE = 0,
    MENU_TOWERS = 1,
    MENU_TOWER_OPERATION = 2,
    MENU_CANNONS = 3,
};

#define NOTE_VIEW_WIDTH     150

@implementation GameBackGroundView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        menuType = MENU_NONE;
        dynamicArray = [[NSMutableArray alloc] init];
        
        noteView = [[NoteView alloc] init];
        [noteView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:noteView];
        
        CGRect wholeWindow = [UIScreen mainScreen].bounds;
        int buttonWidth = 40;
        int buttonHeight = 42;
        suggestButtonSpace = 8;
        
        firstButtonRect.origin.x = suggestButtonSpace;
        firstButtonRect.origin.y = wholeWindow.size.height - buttonHeight - suggestButtonSpace;
        firstButtonRect.size.width = buttonWidth;
        firstButtonRect.size.height = buttonHeight;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [[UIImage imageNamed:@"bg_empty.png"] drawInRect:self.bounds];
}

- (void)clearDynamicObjects
{
    for (id obj in dynamicArray) {
        [obj removeFromSuperview];
    }
    
    [dynamicArray removeAllObjects];
}

- (void)showTowersMenu
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    
    if (MENU_TOWERS == menuType) {
        return;
    }
    menuType = MENU_TOWERS;
    
    [self clearDynamicObjects];
    
    /* Create tower buttons */
    GameConfig *config = [GameConfig globalConfig];

    [config readOnlyEnumTowerWithBlock:^(const ChrisTower *tower, const NSString *key) {
        
        /* 1. Tower lv up */
        GameOpItemView *item = [[GameOpItemView alloc] initWithIndex:tower.type
                                               image:[tower displayImage]
                                               value:[tower valueOfGold]];
        [item setDelegate:self];
        [self addSubview:item];
        [tmpArray addObject:item];
    }];
    dynamicArray = [NSMutableArray arrayWithArray:[tmpArray sortedArrayUsingComparator:[GameOpItemView comparator]]];
    
    /* Localize buttons */
    CGRect rect = firstButtonRect;

    for (GameOpItemView *button in dynamicArray) {
        [button setFrame:rect];
        rect.origin.x += (rect.size.width + suggestButtonSpace);
    }
    
    [self noteViewUpdateWithRect:rect note:@"请选择一个战塔摆放！"];
}

- (void)showTowerOperationMenu
{
#if 0
    if (MENU_TOWER_OPERATION == menuType) {
        return;
    }
#endif
    menuType = MENU_TOWER_OPERATION;
    
    [self clearDynamicObjects];
    
    CGRect tmpRect = firstButtonRect;
    
    GameOpItemView *item = nil;
    ChrisTower *tower = [[self delegate] gameBackGroundViewOperatedTower:self];
    
    /* 1. Tower lv up */
    item = [[GameOpItemView alloc] initWithIndex:1
                                           image:[UIImage imageNamed:@"button_lvup100X100.png"]
                                           value:tower.lvUpGold];
    [item setDelegate:self];
    [item setFrame:tmpRect];
    [self addSubview:item];
    [dynamicArray addObject:item];
    tmpRect.origin.x += (tmpRect.size.width + suggestButtonSpace);
 
    /* 2. Tower remove */
    item = [[GameOpItemView alloc] initWithIndex:2
                                           image:[UIImage imageNamed:@"button_remove_tower100X100.png"]
                                           value:(-1) * tower.saleGold];
    [item setDelegate:self];
    [item setFrame:tmpRect];
    [self addSubview:item];
    [dynamicArray addObject:item];
    tmpRect.origin.x += (tmpRect.size.width + suggestButtonSpace);
    
    /* 3. Cannons*/
    item = [[GameOpItemView alloc] initWithIndex:3
                                           image:[UIImage imageNamed:@"button_setting_cannon100X100.png"]
                                           value:0];
    [item setDelegate:self];
    [item setFrame:tmpRect];
    [self addSubview:item];
    [dynamicArray addObject:item];
    tmpRect.origin.x += (tmpRect.size.width + suggestButtonSpace);
    
    [self noteViewUpdateWithRect:tmpRect note:@"请操作战塔！"];
}

- (void)showCannonsMenu
{
    if (MENU_CANNONS == menuType) {
        return;
    }
    menuType = MENU_CANNONS;
    [self clearDynamicObjects];
    
    Player *tmpPlayer = [Player currentPlayer];
    CGRect tmpRect = firstButtonRect;
    GameOpItemView *item = nil;
    
    ChrisTower *tmpTower = [[self delegate] gameBackGroundViewOperatedTower:self];
    ChrisCannon *tmpCannon = [tmpTower.installedCannons firstObject];
    
    if (0 != tmpPlayer.cannonTraceLv) {
        /* 1. Cannon Trace */
        item = [[GameOpItemView alloc] initWithIndex:CANNON_MAGIC_MASK_TRACE
                                               image:[UIImage imageNamed:@"button_trace100X100.png"]
                                               value:CANNON_TRACE_COST];
        if (CANNON_MAGIC_MASK_CHECK(tmpCannon.magicMask, CANNON_MAGIC_MASK_TRACE)) {
            [item setValue:0];
        }
        [item setDelegate:self];
        [item setFrame:tmpRect];
        [self addSubview:item];
        [dynamicArray addObject:item];
        tmpRect.origin.x += (tmpRect.size.width + suggestButtonSpace);
    }

    if (0 != tmpPlayer.cannonSpUpLv) {
        /* 2. Cannon speed Up */
        item = [[GameOpItemView alloc] initWithIndex:CANNON_MAGIC_MASK_SPEEDUP
                                               image:[UIImage imageNamed:@"button_cannon_spup100X100.png"]
                                               value:CANNON_SPEEDUP_COST];
        if (CANNON_MAGIC_MASK_CHECK(tmpCannon.magicMask, CANNON_MAGIC_MASK_SPEEDUP)) {
            [item setValue:0];
        }
        [item setDelegate:self];
        [item setFrame:tmpRect];
        [self addSubview:item];
        [dynamicArray addObject:item];
        tmpRect.origin.x += (tmpRect.size.width + suggestButtonSpace);
    }
    
    if (0 != tmpPlayer.cannonFireLv) {
        /* 3. Fire */
        item = [[GameOpItemView alloc] initWithIndex:CANNON_MAGIC_MASK_FIRE
                                               image:[UIImage imageNamed:@"button_fire100X100.png"]
                                               value:CANNON_FIRE_COST];
        if (CANNON_MAGIC_MASK_CHECK(tmpCannon.magicMask, CANNON_MAGIC_MASK_FIRE)) {
            [item setValue:0];
        }
        [item setDelegate:self];
        [item setFrame:tmpRect];
        [self addSubview:item];
        [dynamicArray addObject:item];
        tmpRect.origin.x += (tmpRect.size.width + suggestButtonSpace);
    }

    if (0 != tmpPlayer.cannonIceLv) {
        /* 4. Ice */
        item = [[GameOpItemView alloc] initWithIndex:CANNON_MAGIC_MASK_ICE
                                               image:[UIImage imageNamed:@"button_ice100X100.png"]
                                               value:CANNON_ICE_COST];
        if (CANNON_MAGIC_MASK_CHECK(tmpCannon.magicMask, CANNON_MAGIC_MASK_ICE)) {
            [item setValue:0];
        }
        [item setDelegate:self];
        [item setFrame:tmpRect];
        [self addSubview:item];
        [dynamicArray addObject:item];
        tmpRect.origin.x += (tmpRect.size.width + suggestButtonSpace);
    }
    
    if (0 != tmpPlayer.cannonGasLv) {
        /* 5. Gas */
        item = [[GameOpItemView alloc] initWithIndex:CANNON_MAGIC_MASK_GAS
                                               image:[UIImage imageNamed:@"button_gas100X100.png"]
                                               value:CANNON_GAS_COST];
        if (CANNON_MAGIC_MASK_CHECK(tmpCannon.magicMask, CANNON_MAGIC_MASK_GAS)) {
            [item setValue:0];
        }
        [item setDelegate:self];
        [item setFrame:tmpRect];
        [self addSubview:item];
        [dynamicArray addObject:item];
        tmpRect.origin.x += (tmpRect.size.width + suggestButtonSpace);
    }
    
    NSString *note = nil;
    
    if (tmpRect.origin.x == firstButtonRect.origin.x) {
        note = @"未购买任何炮弹魔法";
    } else {
        note = @"请选择一个炮弹魔法！";
    }
    
    [self noteViewUpdateWithRect:tmpRect note:note];
}

- (void)hideMenu
{
    [self clearDynamicObjects];
    menuType = MENU_NONE;
}

#pragma mark NoteView
- (void)noteViewUpdateWithRect:(CGRect)rect note:(NSString *)note
{
    rect.size.width = NOTE_VIEW_WIDTH;
    [noteView setFrame:rect];
    [noteView noteDisplayWithNote:note];
}

- (void)noteViewUpdateWithNote:(NSString *)note
{
    [noteView noteDisplayWithNote:note];
}

#pragma mark GameOpItemView Delegate
- (void)GameOpItemViewDidEndedTouch:(GameOpItemView *)view
{
    NSLog(@"<%s:%d> %d", __func__, __LINE__, view.index);
    
    switch (menuType) {
        case MENU_TOWERS:
            [[self delegate] gameBackGroundView:self didSelectTowerWithIndex:view.index];
            break;
        case MENU_TOWER_OPERATION:
            [[self delegate] gameBackGroundView:self didSelectTowerOperationWithIndex:view.index];
            
            if (TOWER_OPMENU_TOWER_LVUP == view.index) {
                /* Update LvUp cost */
                [view setValue:[[self delegate] gameBackGroundViewOperatedTower:self].lvUpGold];
                [view setNeedsDisplay];
                
                /* Update sale value */
                GameOpItemView *removeView = [dynamicArray objectAtIndex:TOWER_OPMENU_TOWER_REMOVE - 1];
                [removeView setValue:[[self delegate] gameBackGroundViewOperatedTower:self].saleGold];
                [removeView setNeedsDisplay];
            }
            
            break;
        case MENU_CANNONS:
            if (YES == [[self delegate] gameBackGroundView:self didSelectCannonWithIndex:view.index cost:view.value]) {
                [view setValue:0];
            }
            break;
            
        default:
            break;
    }
}

@end
