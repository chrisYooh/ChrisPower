//
//  GameViewController.h
//  ChrisPower
//
//  Created by Chris on 14/12/5.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameView.h"
#import "GameMapView.h"
#import "GameBackGroundView.h"
#import "GameInfoView.h"

#import "Game.h"
#import "ChrisMonster.h"
#import "ChrisTower.h"
#import "ChrisCannon.h"

@class Player;
@class TimerControlRect;

typedef enum game_status_ {
    GAME_STATUS_PREPARING = 0,
    GAME_STATUS_RUNNING = 1,
    GAME_STATUS_PAUSE = 2,
    GAME_STATUS_LEVEL_PASSED = 3,
    GAME_STATUS_LEVEL_FAILED = 4,
    GAME_STATUS_LEVEL_RESET = 5,
    GAME_STATUS_WAVE_PREPARING = 6,
    GAME_STATUS_STOPING = 7,
    GAME_STATUS_NONE = 8,
} game_status_e;

typedef enum game_operation_status_ {
    GAME_OPERATION_STATUS_NONE = 0,
//    GAME_OPERATION_STATUS_BOX_SELECTED = 1,
    GAME_OPERATION_STATUS_TOWER_SETTING = 2,
    GAME_OPERATION_STATUS_TOWER_SELECTED = 3,
//    GAME_OPERATION_STATUS_TOWER_UPDATED = 4,
//    GAME_OPERATION_STATUS_TOWER_REMOVED = 5,
    GAME_OPERATION_STATUS_CANNON_SETTING = 6,
//    GAME_OPERATION_STATUS_CANNON_UPDATE = 7,
    GAME_OPERATION_STATUS_QUICK_SETTING_TOWER = 8,
    GAME_OPERATION_STATUS_QUICK_SETTING_CANNON = 9,
    GAME_OPERATION_STATUS_QUICK_REMOVE_TOWER = 10,
    GAME_OPERATION_STATUS_CLEARING = 11,
} game_operation_status_e;

@interface GameViewController : UIViewController
<UIScrollViewDelegate,
GameViewDatasource, GameViewDelegate,
GameMapViewDatasource,
GameDelegate,
ChrisMonsterDatasource, ChrisMonsterDelegate,
ChrisTowerDatasource, ChrisTowerDelegate,
ChrisCannonDatasource, ChrisCannonDelegate,
GameBackGroundViewDataSource, GameBackGroundViewDelegate,
GameInfoViewDataSource,
UIAlertViewDelegate>
{
    NSTimer *gameTimer;
    NSThread *gameThread;
    
    float gameFrameInterval;
    
//    game_status_e status;
    game_operation_status_e opStatus;
    
    __weak IBOutlet GameBackGroundView *gameBackgroundView;
    GameInfoView *infoView;
    __weak IBOutlet UIScrollView *scrollView;
    GameView *gameView;
    GameMapView *gameMapView;
    UIAlertController *gameAlert;

    Game *game;
    
    __weak ChrisMapBox *selectedBox;
    TimerControlRect *selectedRect;
    CGRect selectedRedrawRect;
    CGPoint selectedCenter;
    float selectedRatio;
    
    CGRect levelRect;
}
@property (nonatomic) game_status_e status;

- (void)gameTimerCallback;

@end
