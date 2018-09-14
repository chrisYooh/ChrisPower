//
//  GameBackGroundView.h
//  ChrisPower
//
//  Created by Chris on 14/12/28.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameOpItemView.h"

@class ChrisTower;
@class NoteView;
@class GameBackGroundView;

enum {
    TOWER_OPMENU_TOWER_LVUP = 1,
    TOWER_OPMENU_TOWER_REMOVE = 2,
    TOWER_OPMENU_CANNONS = 3,
    TOWER_OPMENU_CANNON_LVUP = 4,
};

@protocol GameBackGroundViewDataSource <NSObject>

- (ChrisTower *)gameBackGroundViewOperatedTower:(GameBackGroundView *)view;

@end

@protocol GameBackGroundViewDelegate <NSObject>

- (void)gameBackGroundView:(GameBackGroundView *)view didSelectTowerWithIndex:(int)index;
- (void)gameBackGroundView:(GameBackGroundView *)view didSelectTowerOperationWithIndex:(int)index;
- (BOOL)gameBackGroundView:(GameBackGroundView *)view didSelectCannonWithIndex:(int)index cost:(int)cost;

@end

@interface GameBackGroundView : UIView <GameOpItemVieDelegate>
{
    int menuType;
    NSMutableArray *dynamicArray; /* Save dynamic buttons */

    NoteView *noteView;
    
    CGRect firstButtonRect;
    int suggestButtonSpace;
}

@property (nonatomic,weak) id<GameBackGroundViewDataSource, GameBackGroundViewDelegate> delegate;

- (void)showTowersMenu;
- (void)showTowerOperationMenu;
- (void)showCannonsMenu;
- (void)hideMenu;

- (void)noteViewUpdateWithNote:(NSString *)note;
@end
