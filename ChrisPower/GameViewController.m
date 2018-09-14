//
//  GameViewController.m
//  ChrisPower
//
//  Created by Chris on 14/12/5.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "GameConfig.h"
#import "TimerControlRect.h"
#import "GameDefination.h"
#import "ChrisTips.h"

#import "UIViewController+SpecialScreenShot.h"

#import "GameView.h"
#import "GameInfoView.h"

#import "ChrisMap.h"
#import "ChrisMapBox.h"
#import "ChrisMonster.h"
#import "ChrisTower.h"
#import "ChrisCannon.h"
#import "Level.h"
#import "Home.h"
#import "Waves.h"
#import "WaveItem.h"

#import "Player.h"
#import "DynamicLevel.h"   /* TODO: descreption used, move to GameView later */

#import "ShareViewController.h"

#import "GameViewController.h"

static int currentTowerSetType = 2;

static int currentCannonSetType = 0;
static int speedStatus = 0;
static BOOL timerOn = NO;
UIImage *level1Image = nil;

@interface GameViewController ()

@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        game = [[Game alloc] init];
        [game setDelegate:self];
        gameFrameInterval = 0.03;
        
        selectedRect = [[TimerControlRect alloc] init];
        selectedRedrawRect = CGRectZero;
        selectedCenter = CGPointZero;
        selectedRatio = 0;
        
        /* Create Monsters */
        [self createMonsterByWaveInfo:[game currentWave]];
        
        [self timerStart];
        
        _status = GAME_STATUS_PREPARING;
    }
    
    return self;
}

- (void)gameViewsReset
{
    /* GameView setting */
    CGRect mapRect = game.map.frame;
    CGRect tmpRect;
    tmpRect.origin = CGPointZero;
    tmpRect.size.width = mapRect.origin.x + mapRect.size.width + game.map.frameLineWidth;
    tmpRect.size.height = mapRect.origin.y + mapRect.size.height + game.map.frameLineWidth;
    [gameMapView setFrame:tmpRect];
    
    tmpRect.origin = CGPointZero;
    [gameView setFrame:tmpRect];
    
    /* Reset levelRect */
    int lvWidth = 200;
    int lvHeight = 50;
    levelRect = CGRectMake(20, 40, lvWidth, lvHeight);
}

/* ------------------GameBackgroundView--------------------------------
   ---InfoView---|---UIScrollView---|---DynamicViews---| ControlButtons
   金|魔|波|血|分--|---GameMapView----|
                 |---GameView-------|
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect wholeWindow = [UIScreen mainScreen].bounds;

    /* 1 GameBackgroundView */
    [gameBackgroundView setDelegate:self];
    [gameBackgroundView setFrame:wholeWindow];
    
    /* 1.1 GameInfoView setting */
    infoView = [[GameInfoView alloc] initWithFrame:CGRectMake(0, 0, wholeWindow.size.width, 50)];
    [infoView setDelegate:self];
    [gameBackgroundView addSubview:infoView];
    
    /* 1.2 UIScrollView */
    
    /* 1.2.1 GameMapView */
    gameMapView = [[GameMapView alloc] initWithFrame:CGRectZero];
    [gameMapView setDelegate:self];
    [gameMapView setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:gameMapView];
    
    /* 1.2.1.1 GameView */
    gameView = [[GameView alloc] init];
    [gameView setBackgroundColor:[UIColor clearColor]];
    [gameView setDelegate:self];
    [gameMapView addSubview:gameView];
    
    /* Localized gameViews */
    [self gameViewsReset];
    
    /* ScrollView setting( After game view ) */
    [scrollView setContentSize:gameView.frame.size];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [gameTimer invalidate];
    gameTimer = nil;   
}

- (void)clearObjectRelationship:(id)object
{
    if ([object isKindOfClass:[ChrisMonster class]]) {
        ChrisMonster *monster = object;
        
        [[monster locatedMapBox] removeMonster:monster];
        
    } else if([object isKindOfClass:[ChrisTower class]]) {
        ChrisTower *tower = object;
        
        [[tower locatedMapBox] setTower:nil];
        
    } else if([object isKindOfClass:[ChrisCannon class]]) {
        
    }
}

- (void)resetAllModels
{
    /* Reset Game */
    [game reset];
    
    /* TODO: GameView should reset itself */
    [self gameViewsReset];
    
    /* UIScrollView reset */
    [scrollView setZoomScale:1.0];
    [scrollView setContentSize:gameView.frame.size];
    
    /* Recreate monsters */
    [self createMonsterByWaveInfo:[game currentWave]];
    
    _status = GAME_STATUS_PREPARING;
}


#pragma mark gameTimer
- (void)timerStop
{
    [gameTimer invalidate];
    gameTimer = nil;
    
    timerOn = NO;
}

- (void)timerStart
{
    if (gameTimer) {
        NSLog(@"Game is on running status.");
        return;
    }
    
    gameThread = [[NSThread alloc] initWithTarget:self selector:@selector(gameThreadCallback) object:nil];
    [gameThread start];
    
    timerOn = YES;
}

- (void)gameThreadCallback
{
    NSLog(@"Thread callback");
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:gameFrameInterval target:self selector:@selector(gameTimerCallback) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:gameTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

- (void)SetGameViewNeedDisplayInRect:(CGRect)rect
{    
    [gameView setNeedsDisplayInRect:rect];
}

- (void)gameTimerCallback
{
    /* Game AI Status */
    [self aiStatusHandle];
    
    [selectedRect nextFrame];
    [selectedRect setNeedDisplayInView:gameView];
}

#pragma mark -------DATA SOURCE-------
/* GameView */
- (Game *)gameViewRunningGame:(GameView *)view
{
    return game;
}

- (ChrisTower *)gameBackGroundViewOperatedTower:(GameBackGroundView *)view
{
    return selectedBox.tower;
}

/* GameMapView */
- (ChrisMap *)gameMapViewMap:(GameMapView *)view
{
    return game.map;
}

/* GameInfoView */
- (Game *)GameInfoViewGetGameInfo:(GameInfoView *)view
{
    return game;
}

/* ChrisMonster */
- (ChrisMap *)monsterMap:(ChrisMonster *)monster
{
    return game.map;
}

/* ChrisTower */
- (ChrisMap *)towerMap:(ChrisTower *)tower
{
    return game.map;
}

/* ChrisCannon */
- (ChrisMap *)cannonMap:(ChrisCannon *)cannon
{
    return game.map;
}

#pragma mark -------VIEW DELEGATE-------
/* UIScrollView */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return gameMapView;
}

/* GameView */
- (void)gameView:(GameView *)gameView drawExtraWithContext:(CGContextRef)context
{
    if (0 == selectedRatio) {
        [selectedRect drawRectWithContext:context];
    } else {
        [[UIColor whiteColor] setFill];
        CGContextSetAlpha(context, 0.2);
        CGContextAddArc(context, selectedCenter.x, selectedCenter.y, selectedRatio, 0, 2 * 3.15, 0);
        CGContextDrawPath(context, kCGPathFill);
        
        NSString *str = [NSString stringWithFormat:@"出售价格: %d\n", selectedBox.tower.saleGold];
        [str drawAtPoint:CGPointMake(selectedCenter.x - 30, selectedCenter.y - 60) withAttributes:nil];
        
        ChrisTower *tower = selectedBox.tower;
        [[tower randPowerStr] drawAtPoint:CGPointMake(selectedCenter.x - 40, selectedCenter.y + 30) withAttributes:nil];
    }
    
    /* Draw Level */
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIFont systemFontOfSize:40.0f], NSFontAttributeName,
                         [UIColor whiteColor], NSForegroundColorAttributeName,
                         nil];
    
    if (USER_CREATE_LEVEL_PRIMARY_INDEX == game.currentLevelPrimaryIndex) {
            [[NSString stringWithFormat:@"DIY%d", game.currentLevelSecondaryIndex] drawInRect:levelRect withAttributes:dic];
    } else if (TEST_LEVEL_PRIMARY_INDEX == game.currentLevelPrimaryIndex) {
            [[NSString stringWithFormat:@"测试%d", game.currentLevelSecondaryIndex] drawInRect:levelRect withAttributes:dic];
    } else if (1 == game.currentLevelPrimaryIndex){
            [[NSString stringWithFormat:@"第%d关", game.currentLevelSecondaryIndex] drawInRect:levelRect withAttributes:dic];
    }
}

- (void)gameView:(GameView *)gameView didBeginTouchPointWithTouch:(UITouch *)touch
{
}

- (void)gameView:(GameView *)inputGameView didEndTouchPointWithTouch:(UITouch *)touch
{
    CGPoint touchPos = [touch locationInView:inputGameView];
    
    NSLog(@"Touch position : %f, %f", touchPos.x, touchPos.y);

    [self operationStatusTransformByGameViewClick:touchPos];
}

/* GameBackgoundView */
- (void)gameBackGroundView:(GameBackGroundView *)view didSelectTowerWithIndex:(int)index
{
    /* Money Check */
    ChrisTower *tmpTower = [[GameConfig globalConfig] getTemplateTowerFromStoreWithType:index];
    if (tmpTower.valueOfGold > game.home.gold) {
        [view noteViewUpdateWithNote:@"金币不足！"];
        return;
    }
    
    currentTowerSetType = index;
    if (YES == [self createTowerInMapBox:selectedBox]) {
        [self clearOpStatus];
    }
}

- (void)gameBackGroundView:(GameBackGroundView *)view didSelectTowerOperationWithIndex:(int)index
{
    ChrisTower *tmpTower = selectedBox.tower;
    
    if (TOWER_OPMENU_TOWER_LVUP == index) {
        
        /* TODO: Dup check there */
        if (NO == [tmpTower canLvUp]) {
            [view noteViewUpdateWithNote:@"战塔已满级！"];
        } else  if (tmpTower.lvUpGold > game.home.gold) {
            [view noteViewUpdateWithNote:@"金币不足！"];
        } else {
            [self selectedTowerLvUp];
        }

    } else if (TOWER_OPMENU_TOWER_REMOVE == index) {
        [tmpTower setRemove];
        /* Just across the remove status */
        [tmpTower selfStatusHandle];
        [self clearOpStatus];
        [game.home earnGold:tmpTower.saleGold];
    } else if (TOWER_OPMENU_CANNONS == index) {
        
        [gameBackgroundView showCannonsMenu];
        opStatus = GAME_OPERATION_STATUS_CANNON_SETTING;
    } else if (TOWER_OPMENU_CANNON_LVUP == index) {
        
    }
    
    /* when in PAUSE status, we need do this to keep the gold right. */
    [infoView setNeedsDisplay];
}

- (BOOL)gameBackGroundView:(GameBackGroundView *)view didSelectCannonWithIndex:(int)index cost:(int)cost
{
    ChrisTower *tmpTower = selectedBox.tower;
    
    if (0 == cost) {
        NSLog(@"The cannon magic with index %d already buy.", index);
        [view noteViewUpdateWithNote:@"已经装备了该炮弹魔法！"];
        return NO;
    }
    
    if (NO == [tmpTower canNewMagicSet]) {
        NSLog(@"Tower slot use up\n");
        [view noteViewUpdateWithNote:@"魔法槽位不足！"];
        return NO;
    }
    
    if (NO == [game.home spendGold:cost]) {
        NSLog(@"Not enough gold to set cannon magic");
        [view noteViewUpdateWithNote:@"金币不足！"];
        return NO;
    }
 
    [tmpTower setMagicWithFlag:index];
    [self clearOpStatus];
    
    return YES;
}

#pragma mark -------GAME OBJECT DELEGATE-------
- (void)Game:(Game *)game monsterWillGoToNextPiece:(ChrisMonster *)monster;
{
    [self SetGameViewNeedDisplayInRect:monster.frame];
}

- (void)Game:(Game *)game monsterDidGoneToNextPiece:(ChrisMonster *)monster
{
    [self SetGameViewNeedDisplayInRect:monster.frame];
}

- (void)Game:(Game *)game towerWillGoToNextPiece:(ChrisTower *)tower
{
    [self SetGameViewNeedDisplayInRect:tower.frame];
}

- (void)Game:(Game *)game towerDidGoneToNextPiece:(ChrisTower *)tower
{
    [self SetGameViewNeedDisplayInRect:tower.frame];
}

- (void)Game:(Game *)game cannonWillGoToNextPiece:(ChrisCannon *)cannon
{
    [self SetGameViewNeedDisplayInRect:cannon.frame];
}

- (void)Game:(Game *)game cannonDidGoneToNextPiece:(ChrisCannon *)cannon
{
    [self SetGameViewNeedDisplayInRect:cannon.frame];
}


/* Chris Monster */
- (void)monsterDidStartMove:(ChrisMonster *)monster
{
    [[monster locatedMapBox] addMonsterAtHead:monster];
    
    int out = DIRECTION_OUT([monster currentMoveDirection]);
    if (UP == out) {
        [game monsterMoveToUpDrawArray:monster];
    }
}

- (void)monsterWillMoveToNewRect:(ChrisMonster *)monster
{
    [[monster locatedMapBox] removeMonster:monster];
}

- (void)monsterDidMoveToNewRect:(ChrisMonster *)monster
{
    [[monster locatedMapBox] addMonsterAtTail:monster];
    
    /* Update monsters draw related queue */
    int newDirection = [monster currentMoveDirection];
    int in = DIRECTION_IN(newDirection);
    int out = DIRECTION_OUT(newDirection);
    
    if (DOWN == in && UP != out) {
        
        [game monsterMoveToNormalDrawArray:monster];
        
    } else if (DOWN != in && UP == out) {
        
        [game monsterMoveToUpDrawArray:monster];
    }
}

- (void)monsterDidDead:(ChrisMonster *)monster withReason:(int)reason
{
    if (MONSTER_DIE_REASON_KILLED == reason) {
        [game monsterBeKilled:monster];
        [game.home earnGold:monster.killedGoldAward];
        [[Player currentPlayer] monsterBeenKilled:monster];
    } else if (MONSTER_DIE_REASON_ATTACK_HOME == reason) {
        [game monsterAttack:monster];
        [game.home getHurtWithAttack:monster.currentHealthPoint];
    } else {
        NSLog(@"<%s:%d> Monster die with unknown reason %d", __func__, __LINE__, reason);
        return;
    }
    
    [self clearObjectRelationship:monster];
}

/* Chris Tower */
- (void)tower:(ChrisTower *)tower didCreateCannon:(ChrisCannon *)cannon
{
    [cannon setDelegate:self];
    [game addCannon:cannon];
}

- (void)towerDidStartObserve:(ChrisTower *)tower
{
    [[tower locatedMapBox] setTower:tower];
}

- (void)towerDidRemoved:(ChrisTower *)tower
{
    [self clearObjectRelationship:tower];
}

/* Chris Cannon */
- (void)cannon:(ChrisCannon *)cannon didHurtTarget:(ChrisMonster *)monster withAttack:(int)attack
{
    [monster getHurtWithAttack:attack];
    
    if (CANNON_MAGIC_MASK_CHECK(cannon.magicMask, CANNON_MAGIC_MASK_ICE)) {
        [monster freezing];
    }
    
    if (CANNON_MAGIC_MASK_CHECK(cannon.magicMask, CANNON_MAGIC_MASK_GAS)) {
        [monster poisoningWithAttack:attack];
    }
}

- (void)cannonDidRemove:(ChrisCannon *)cannon
{
    /* Cannon do not have relationship, so do nothing */
}

#pragma mark GameStatus AI handle
- (void)aiStatusHandle
{
    if (GAME_STATUS_PREPARING == _status) {
        
        [self preparing];
        
    } else if (GAME_STATUS_PAUSE == _status) {
        
        [self pause];
        
    } else if (GAME_STATUS_LEVEL_RESET == _status) {
        
        [self levelReset];
        
    } else if (GAME_STATUS_RUNNING == _status) {
        
        [self running];
        
    } else if (GAME_STATUS_LEVEL_PASSED == _status) {
        
        [self levelPassed];
        
    } else if (GAME_STATUS_LEVEL_FAILED == _status) {
        
        [self levelFailed];
        
    } else if (GAME_STATUS_WAVE_PREPARING == _status) {
        
        [self wavePreparing];
        
    } else if (GAME_STATUS_STOPING == _status) {
        
        [self stop];
        
    } else {
        
    }
}

- (void)preparing
{
    _status = GAME_STATUS_WAVE_PREPARING;
    opStatus = GAME_OPERATION_STATUS_NONE;
}

- (void)wavePreparing
{
    _status = GAME_STATUS_RUNNING;
}

- (void)runningNormalOperation
{
    [game nextPiece];
    
    /* Set game informations need display */
    [self SetGameViewNeedDisplayInRect:selectedRedrawRect];
    [infoView setGoldNeedDisplay];
//    [infoView setMagicPointNeedDisplay];
    [infoView setWaveNeedDisplay];
    [infoView setHealthPointNeedDisplay];
    [infoView setScoreNeedDisplay];
    
    if (HOME_STATUS_DESTROY == game.home.status) {
        
        _status = GAME_STATUS_LEVEL_FAILED;
        
    } else if (YES == [game nextWave]) {
        
        if ([game currentWaveIndex] == game.wavesInfo.waveNumber) {
            
            _status = GAME_STATUS_LEVEL_PASSED;
            
        } else {
            
            /* Next wave */
            [self createMonsterByWaveInfo:[game currentWave]];
            _status = GAME_STATUS_WAVE_PREPARING;
        }
    }
}

- (void)running
{
    [self runningNormalOperation];
}

- (void)pause
{
    [self SetGameViewNeedDisplayInRect:levelRect];
    return;
}

- (void)levelPassed
{
    /* Unlock Level */
    GameConfig *config = [GameConfig globalConfig];
    
    if (config.currentLevelPrimaryType == INITIAL_LEVEL_PRIMARY_INDEX &&
        config.currentLevelSecondaryType >= 1 &&
        config.currentLevelSecondaryType < INITIAL_LEVEL_NUMBER) {
        DynamicLevel *dynLevel = [[Player currentPlayer] getDynamicLevelByPriIndex:config.currentLevelPrimaryType secIndex:config.currentLevelSecondaryType + 1];
        [dynLevel setObjectValidUntilDate:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LevelLockedStatusUpdate" object:nil];
    }
 
    NSString *levelPassedInfo = [self levelPassedAward];
    if (nil == levelPassedInfo) {
        levelPassedInfo = [[NSString alloc] init];
    }
    levelPassedInfo = [levelPassedInfo stringByAppendingString:randonTip()];
    
    /* Pass Level */
    if ((USER_CREATE_LEVEL_PRIMARY_INDEX == config.currentLevelPrimaryType) ||
        ((TEACH_LEVEL_PIRMARY_INDEX == config.currentLevelPrimaryType) && (TEACH_LEVEL_NUMBER == config.currentLevelSecondaryType))||
        ((INITIAL_LEVEL_PRIMARY_INDEX == config.currentLevelPrimaryType) && (INITIAL_LEVEL_NUMBER == config.currentLevelSecondaryType))) {
        
        gameAlert = [UIAlertController alertControllerWithTitle:@"关卡胜利"
                                                        message:levelPassedInfo
                                                 preferredStyle:UIAlertControllerStyleAlert];
        [gameAlert addAction:[self replayAction]];
        [gameAlert addAction:[self levelSelectAction]];
    } else {
        gameAlert = [UIAlertController alertControllerWithTitle:@"关卡胜利"
                                                        message:levelPassedInfo
                                                 preferredStyle:UIAlertControllerStyleAlert];
        [gameAlert addAction:[self replayAction]];
        [gameAlert addAction:[self levelSelectAction]];
        [gameAlert addAction:[self nextLevelAction]];
    }
    _status = GAME_STATUS_STOPING;
}

- (NSString *)levelPassedAward
{
    GameConfig *config = [GameConfig globalConfig];
    
    if (1 == config.currentLevelPrimaryType) {
        return [self classicalAndDIYLevelPassedAward];
    } else if (TEACH_LEVEL_PIRMARY_INDEX == config.currentLevelPrimaryType) {
        return [[Player currentPlayer] teachLevelAwardWithIndex:config.currentLevelSecondaryType];
    } else if (USER_CREATE_LEVEL_PRIMARY_INDEX == config.currentLevelPrimaryType) {
        return [self classicalAndDIYLevelPassedAward];
    }
    
    return nil;
}

- (NSString *)classicalAndDIYLevelPassedAward
{
    Player *tmpPlayer = [Player currentPlayer];
    
    /* 1. Get Gold = LevelGrade / 1000 + totalKilledMonster / 10 + homeHP + gameGold / 50 */
    int goldAward = tmpPlayer.currentDynamicLevel.currentGrade / 1000 +
    game.totalMonsterKilledNumber / 10 +
    game.home.healthPoint +
    game.home.gold / 50;
    [tmpPlayer earnGold:goldAward];
    
    /* 2. Get CGold = LevelWaves / 5 */
    int cGoldAward = game.wavesInfo.waveNumber / 10;
    [tmpPlayer earnCGold:cGoldAward];
    
    /* 3. Player experience */
    int totalValue = 0;
    for (ChrisTower *tmpTower in [game copiedTowerArray]) {
        totalValue += tmpTower.valueOfGold;
    }
    
    int playerExp = tmpPlayer.currentDynamicLevel.currentGrade / 500 +
    game.totalMonsterKilledNumber +
    game.home.healthPoint * 3 +
    totalValue / 50;
    int isLvUp = [tmpPlayer earnExperience:playerExp];
    
    /* Calc monster experience (Already calc) */
    /* Calc tower experience */
    int monsterKilledNumber = game.totalMonsterKilledNumber;
    int towerNumber = [game towerCurrentNumber];
    int singleExperience = monsterKilledNumber / pow(1.1, towerNumber);
    [game towersEnumWithOperation:^(ChrisTower *tower) {
        [tmpPlayer towerWithType:tower.type earnExperience:singleExperience];
    }];
    
    /* Save to file */
    [tmpPlayer infoUpdateWithCurrentValue];
    
    NSString *desc = [NSString stringWithFormat:@"获得金币：%d\n"
                      "获得C币：%d\n"
                      "获得经验：%d\n",
                      goldAward,
                      cGoldAward,
                      playerExp];
    
    if (PLAYER_LVUP == isLvUp) {
        desc = [desc stringByAppendingString:[NSString stringWithFormat:@"【恭喜您升到%d级】\n", tmpPlayer.lv]];
    }
    
    return desc;
}

- (void)levelFailed
{
    NSString *failedInfo = @"胜败家常，重新来过！\n";
    failedInfo = [failedInfo stringByAppendingString:randonTip()];
    
    gameAlert = [UIAlertController alertControllerWithTitle:@"关卡失败"
                                                    message:failedInfo
                                             preferredStyle:UIAlertControllerStyleAlert];
    [gameAlert addAction:[self replayAction]];
    [gameAlert addAction:[self levelSelectAction]];
    
    _status = GAME_STATUS_STOPING;
}

- (void)levelReset
{
    [self resetAllModels];
    [gameMapView setNeedsDisplay];
    [gameView setNeedsDisplay];
    
    [self clearSelectedCircle];
}

- (void)stop
{
    [self timerStop];
    [self presentViewController:gameAlert animated:YES completion:nil];
    
    _status = GAME_STATUS_NONE;
    opStatus = GAME_OPERATION_STATUS_CLEARING;
}

- (void)setNextLevel
{
    int secIndex = game.currentLevelSecondaryIndex;

    if (INITIAL_LEVEL_PRIMARY_INDEX == game.currentLevelPrimaryIndex) {
         secIndex = ((secIndex + 1) <= INITIAL_LEVEL_NUMBER) ? secIndex + 1 : INITIAL_LEVEL_NUMBER;
    } else if (TEACH_LEVEL_PIRMARY_INDEX == game.currentLevelPrimaryIndex ) {
         secIndex = ((secIndex + 1) <= TEACH_LEVEL_NUMBER) ? secIndex + 1 : TEACH_LEVEL_NUMBER;
    }
    
    [[GameConfig globalConfig] setCurrentLevelSecondaryType:secIndex];
    if (nil == [[GameConfig globalConfig] getCurrentTemplateLevelFromStore]) {
        NSLog(@"Level %d-%d not exist", game.currentLevelPrimaryIndex, secIndex);
    }
}

#pragma mark OpStatus AI handle

#pragma mark OpStatus GameViewClick handle
- (void)clearOpStatus
{
    [gameBackgroundView hideMenu];
    
    [selectedRect setNeedDisplayInView:gameView];
    [self selectBox:nil];
    
    [self clearSelectedCircle];
    
    opStatus = GAME_OPERATION_STATUS_NONE;
}

- (void)operationStatusTransformByGameViewClick:(CGPoint)clickPoint
{
    /* Get touched Map Box */
    ChrisMapBox *box = [game.map mapBoxAtTouchPoint:clickPoint];
    if (nil == box) {
        [self clearOpStatus];
        NSLog(@"<%s:%d> Get mapbox failed\n", __func__, __LINE__);
        return;
    }
    
    if ((GAME_OPERATION_STATUS_NONE == opStatus)
        || (GAME_OPERATION_STATUS_TOWER_SETTING == opStatus)
        || (GAME_OPERATION_STATUS_TOWER_SELECTED == opStatus)
        || (GAME_OPERATION_STATUS_CANNON_SETTING == opStatus)) {
        
        [self operationNormalStatusTransformWithClickedBox:box];
        
    } else if (GAME_OPERATION_STATUS_QUICK_SETTING_TOWER == opStatus) {
        
        [self quickSettingTowerInBox:box];
        
    } else if (GAME_OPERATION_STATUS_QUICK_SETTING_CANNON == opStatus) {
        
        [self quickSettingCannonInBox:box];
        
    } else if (GAME_OPERATION_STATUS_QUICK_REMOVE_TOWER == opStatus) {
        
        [self quickRemoveTowerInBox:box];
        
    } else if (GAME_OPERATION_STATUS_CLEARING) {
        
    }
}

- (void)opStatusTransfromByButtonTouch:(UIButton *)button
{
    
}

- (void)operationNormalStatusTransformWithClickedBox:(ChrisMapBox *)box
{
    if (YES == [box canSetTower]) {
        
        [self selectBox:box];
        [self clearSelectedCircle];
        [gameBackgroundView showTowersMenu];
        opStatus = GAME_OPERATION_STATUS_TOWER_SETTING;
    } else if (box.tower) {
        [self selectBox:box];
        [self updateSelectedCircleByBox:box];
        [gameBackgroundView showTowerOperationMenu];
        opStatus = GAME_OPERATION_STATUS_TOWER_SELECTED;
    } else {
        
        [self clearOpStatus];
    }
}

- (void)quickSettingTowerInBox:(ChrisMapBox *)box
{
    if (YES == [box canSetTower]) {
        [self createTowerInMapBox:box];
    }
}

- (void)quickSettingCannonInBox:(ChrisMapBox *)box
{
    [box.tower setCannonWithCannonType:currentCannonSetType];
}

- (void)quickRemoveTowerInBox:(ChrisMapBox *)box
{
    [box.tower setRemove];
}

- (BOOL)createTowerInMapBox:(ChrisMapBox *)box
{
    ChrisTower *tmpTower = [[GameConfig globalConfig] getTemplateTowerFromStoreWithType:currentTowerSetType];
    
    if (NO == [game.home spendGold:tmpTower.valueOfGold]) {
        NSLog(@"<%s:%d> Do not have enough money to by the tower. Current money: %d, tower cost: %d\n",
              __func__, __LINE__, game.home.gold, tmpTower.valueOfGold);
        return NO;
    }
    [infoView setNeedsDisplay];
    
    /* Tower init */
    ChrisTower *tower = [[ChrisTower alloc] initWithInstance:tmpTower];
    [tower strengthenWithPlayer:[Player currentPlayer]];
    [tower setDelegate:self];
    
    [tower startWithMapBox:box];
    /* jump across the preparing status */
    [tower selfStatusHandle];
    
    [game addTower:tower];

    return YES;
}

- (void)selectedTowerLvUp
{
    ChrisTower *tmpTower = selectedBox.tower;
    
    if (NO == [tmpTower canLvUp]) {
        NSLog(@"Tower lv %d max, can't lv up any more", tmpTower.lv);
    } else {
        if (NO ==[game.home spendGold:tmpTower.lvUpGold]) {
            NSLog(@"Not enough gold to lvUp tower");
        } else {
            [tmpTower lvUp];
            [self updateSelectedCircleByBox:selectedBox];
            NSLog(@"Tower lv up succeed, lv: %d", tmpTower.lv);
        }
    }
}

#pragma mark Attribute---Player

#pragma mark Attribute---Level

#pragma mark Attribute---Game
- (void)createMonsterByWaveInfo:(const WaveItem *)wave
{
    GameConfig *config = [GameConfig globalConfig];
    
    int randNumber = 0;
    int p1 = wave.monsterPercents1;
    int p2 = wave.monsterPercents1 + wave.monsterPercents2;
    ChrisMonster *monster = nil;
    int sleepTime = 10;
    int monsterInterval = 30;
    int monsterType = 0;
    
    for (int i = 0; i < wave.monsterNumber; i++) {
        randNumber = rand() % 100;
        
        if (randNumber < p1) {
            monsterType = wave.monsterType1;
        } else if (randNumber < p2) {
            monsterType = wave.monsterType2;
        } else {
            monsterType = wave.monsterType3;
        }
        
        if (MONSTER_TYPE_RANDOM == monsterType) {
            monsterType = rand() % MONSTER_TYPE_NUMBER + MONSTER_TYPE_MIN;
            NSLog(@"Random monster type is %d\n", monsterType);
        }
        
        monster = [[ChrisMonster alloc] initWithInstance:[config getTemplateMonsterFromStoreWithType:monsterType]];
        [monster setDelegate:self];
        [game addMonster:monster];
        
        [monster startWithPrepareTime:monsterInterval * i + sleepTime];
    }
}

#pragma mark Attribute---Selected
- (void)selectBox:(ChrisMapBox *)box
{
    selectedBox = box;
    
    [selectedRect setNeedDisplayInView:gameView];
    [selectedRect setRedisplayRect:box.frame];
    [selectedRect setNeedDisplayInView:gameView];
}

- (void)updateSelectedCircleByBox:(ChrisMapBox *)box
{
    if (nil == box || nil == box.tower) {
        return;
    }
    
    [self SetGameViewNeedDisplayInRect:selectedRedrawRect];
    
    /* Set tower range rect */
    selectedCenter.x = box.frame.origin.x + box.frame.size.width / 2;
    selectedCenter.y = box.frame.origin.y + box.frame.size.height / 2;
    
    selectedRatio = box.tower.attackRadius;
    selectedRedrawRect.origin.x = selectedCenter.x - box.tower.attackRadius ;
    selectedRedrawRect.origin.y = selectedCenter.y - box.tower.attackRadius;
    selectedRedrawRect.size.width = box.tower.attackRadius * 2;
    selectedRedrawRect.size.height = box.tower.attackRadius * 2;
    
    [self SetGameViewNeedDisplayInRect:selectedRedrawRect];
}

- (void)clearSelectedCircle
{
    if (0 == selectedRatio) {
        return;
    }
    
    [self SetGameViewNeedDisplayInRect:selectedRedrawRect];
    
    selectedCenter = CGPointZero;
    selectedRatio = 0;
    selectedRedrawRect = CGRectZero;
}

#pragma mark Click-Response message
- (IBAction)currentLevelReset:(id)sender
{
    if (GAME_STATUS_RUNNING == _status) {
        _status = GAME_STATUS_PAUSE;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重置关卡"
                                                                   message:@"您确定重玩当前关卡么？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[self replayAction]];
    [alert addAction:[self continueAction]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)gameSpeedChange:(id)sender
{
    if (0 == speedStatus) {
        gameFrameInterval = 0.01;
        [gameBackgroundView noteViewUpdateWithNote:@"速度：快"];
    } else if (1 == speedStatus) {
        gameFrameInterval = 0.06;
        [gameBackgroundView noteViewUpdateWithNote:@"速度：慢"];
    } else if (2 == speedStatus) {
        gameFrameInterval = 0.025;
        [gameBackgroundView noteViewUpdateWithNote:@"速度：中"];
    }
    speedStatus = (speedStatus + 1) % 3;
    
    if (YES == timerOn) {
        [self timerStop];
        [self timerStart];
    }
}

- (IBAction)pauseOrContinue:(id)sender
{
    if (GAME_STATUS_RUNNING == _status) {
        _status = GAME_STATUS_PAUSE;
        [gameBackgroundView noteViewUpdateWithNote:@"游戏暂停"];
    } else if (GAME_STATUS_PAUSE == _status) {
        _status = GAME_STATUS_RUNNING;
        [gameBackgroundView noteViewUpdateWithNote:@"游戏继续"];
    }
    
    if (NO == timerOn) {
        [self timerStart];
    }
}

- (IBAction)return:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Shok Detect
- (void)shareScreenShot
{
    _status = GAME_STATUS_PAUSE;
    timerOn = NO;
    
    ShareViewController *gvController = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
    [gvController setSpecialScreenShot:[self specialScreenShot]];
    [self presentViewController:gvController animated:YES completion:nil];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake )
    {
        [self shareScreenShot];
    }
}

#pragma mark - MISC
- (UIAlertAction *)replayAction
{
    __weak GameViewController *tmpVC = self;
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"重玩" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        tmpVC.status = GAME_STATUS_LEVEL_RESET;
        [tmpVC timerStart];
    }];
    
    return action;
}

- (UIAlertAction *)levelSelectAction
{
    __weak GameViewController *tmpVC = self;
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"选关" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [tmpVC dismissViewControllerAnimated:YES completion:nil];
    }];
    return action;
}

- (UIAlertAction *)nextLevelAction
{
    __weak GameViewController *tmpVC = self;
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"下一关" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [tmpVC setNextLevel];
        tmpVC.status = GAME_STATUS_LEVEL_RESET;
        [tmpVC timerStart];
    }];
    return action;
}

- (UIAlertAction *)continueAction
{
    __weak GameViewController *tmpVC = self;
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"继续游戏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        tmpVC.status = GAME_STATUS_RUNNING;
    }];
    return action;
}

@end
