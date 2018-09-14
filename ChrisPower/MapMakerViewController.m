//
//  MapMakerViewController.m
//  ChrisPower
//
//  Created by Chris on 14/12/22.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "MapMakerView.h"
#import "Player.h"

#import "Level.h"
#import "ChrisMap.h"
#import "ChrisMapBox.h"
#import "ChrisMonster.h"

#import "MapMakerViewController.h"

#define MAP_WIDTH_MAX       20  
#define MAP_HEIGHT_MAX      20

@interface MapMakerViewController ()

@end

@implementation MapMakerViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        map = [[ChrisMap alloc] initWithMapBoxColNumber:5 rolNumber:5];
        
        currentMapType = 0;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [secondaryLevel setText:@"1"];
    
    [monster1 setText:@"1"];
    [monster2 setText:@"1"];
    [monster3 setText:@"1"];
    
    [mapWidth setText:[NSString stringWithFormat:@"8"]];
    [mapHeight setText:[NSString stringWithFormat:@"5"]];
    [map resetMapWithMapBoxColNumber:[[mapWidth text] intValue] rolNumber:[[mapHeight text] intValue]];
    
    /* 1. Get Windows bounds */

    /* 2. Set GameView frame */
    CGRect mapMakerViewFrame;
    mapMakerViewFrame.origin = CGPointZero;
    mapMakerViewFrame.size.width = 1050;/* 50 * 20 + x */
    mapMakerViewFrame.size.height = 1050;/* 50 * 20 + x */
    
    displayView = [[MapMakerView alloc] initWithFrame:mapMakerViewFrame];
    
    [displayView setBackgroundColor:[UIColor clearColor]];
    
    [displayView setDelegate:self];
    
    [displayView setNeedsDisplay];
    
    /* 3. Use GameView frame size to set ScrollView content */
    [scrollView setContentSize:displayView.frame.size];
    
    /* Add View relationship */
    [scrollView addSubview:displayView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Map maker view delegate
- (ChrisMap *)MapMakerViewGetMap:(MapMakerView *)view
{
    return map;
}

- (void)MapMakerView:(MapMakerView *)view beenTouchedWithTouch:(UITouch *)touch
{
    [[self view] endEditing:YES];
    
    if (nil == map) {
        return;
    }
    
    CGPoint touchPoint = [touch locationInView:view];
    [map setMapBoxType:currentMapType atTouchPoint:touchPoint];
    [displayView setNeedsDisplay];
}

- (IBAction)touchUpInside:(id)sender
{
    [[self view] endEditing:YES];
}

- (IBAction)selectMapBox:(id)sender
{
    UIButton *button = sender;
    
    if ([button.titleLabel.text isEqualToString:@"路径"]) {
        
        currentMapType = MAP_BOX_TYPE_WALKWAY;
    } else if ([button.titleLabel.text isEqualToString:@"摆塔"]) {
        
        currentMapType = MAP_BOX_TYPE_HILL;
    } else if ([button.titleLabel.text isEqualToString:@"S"]) {
        
        currentMapType = MAP_BOX_TYPE_STONE;
    } else if ([button.titleLabel.text isEqualToString:@"起点"]) {
        
        currentMapType = MAP_BOX_TYPE_START;
    } else if ([button.titleLabel.text isEqualToString:@"终点"]) {
        
        currentMapType = MAP_BOX_TYPE_END;
    }
}

- (IBAction)createEmptyMap:(id)sender
{
    if (NO == [self canCreateTemplateMap]) {
        return;
    }
    
    if (nil == map)
    {
        map = [[ChrisMap alloc] initWithMapBoxColNumber:[[mapWidth text] intValue] rolNumber:[[mapHeight text] intValue]];
    } else {
        [map resetMapWithMapBoxColNumber:[[mapWidth text] intValue] rolNumber:[[mapHeight text] intValue]];
    }
    
    [displayView setNeedsDisplay];
}

static NSString *pathInDocumentDirectory(NSString *filename)
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSString *wholePath = [documentDirectory stringByAppendingString:filename];
    
    NSLog(@"%@", wholePath);
    
    return wholePath;
}

- (IBAction)writeMapToFile:(id)sender
{
    [NSKeyedArchiver archiveRootObject:map toFile:pathInDocumentDirectory(@"map")];
}

- (BOOL)canCreateTemplateMap
{
    int ret = NO;
    NSString *errInfo = nil;
    
    if ([mapWidth.text intValue] > MAP_WIDTH_MAX) {
        errInfo = @"地图宽度不可超过20";
    } else if ([mapHeight.text intValue] > MAP_HEIGHT_MAX) {
        errInfo = @"地图高度不可超过20";
    } else {
        ret = YES;
    }
    
    if (NO == ret) {
        UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"不可创建地图模板"
                                                               message:errInfo
                                                          cancelButton:@"我知道了"];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    return ret;
}

- (NSString *)pathCheck
{
    if (NO == [map setPathStartEndByMapInfo]) {
        return @"地图中必须存在一个起点和一个终点！";
    } else if (0 != [map createDynamicPath]) {
        return @"不合理的地图设计！\n请保证地图起点、终点之间存在有效路径。\n";
    }
    
    return nil;
}

- (BOOL)canSave
{
    BOOL ret = NO;
    NSString *errInfo = nil;
    int levelSecIndex = [[secondaryLevel text] intValue];
    
    if (([monster1.text intValue] > MONSTER_TYPE_MAX) ||
        ([monster1.text intValue] < MONSTER_TYPE_RANDOM) ||
        ([monster2.text intValue] > MONSTER_TYPE_MAX) ||
        ([monster2.text intValue] < MONSTER_TYPE_RANDOM) ||
        ([monster3.text intValue] > MONSTER_TYPE_MAX) ||
        ([monster3.text intValue] < MONSTER_TYPE_RANDOM)) {
        errInfo = [NSString stringWithFormat:@"怪物索引必须载%d--%d之间", MONSTER_TYPE_RANDOM, MONSTER_TYPE_MAX];;
    } else if (levelSecIndex <= 0 || levelSecIndex > [Player currentPlayer].diyMapNumberMax) {
        errInfo = [NSString stringWithFormat:@"地图纸未解锁，不能保存!\n"
                        "您可以选择已解锁的地图纸（如1）或在商店购买更多的图纸，以同时保存多张地图"];
    } else if ((errInfo = [self pathCheck]) != nil) {
        ret = NO;
    } else {
        ret = YES;
    }
    
    if (NO == ret) {
        UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"不可保存关卡"
                                                               message:errInfo
                                                          cancelButton:@"我知道了"];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    return ret;
}

- (IBAction)saveMap:(id)sender
{
    NSString *alertMessage = nil;
    
    if (NO == [self canSave]) {
        return;
    }

    if (NO == [[Player currentPlayer] updateDIYLevelWithLevelIndex:[[secondaryLevel text] intValue]
                                                               map:map
                                                          monster1:[monster1.text intValue]
                                                          monster2:[monster2.text intValue]
                                                          monster3:[monster3.text intValue]]) {
        
        alertMessage = [NSString stringWithFormat:@"地图保存失败..."];
    } else {
        
        alertMessage = [NSString stringWithFormat:@"地图保存成功!"];
    }
    
    UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"保存DIY地图"
                                                           message:alertMessage
                                                      cancelButton:@"好"];
    [self presentViewController:alert animated:YES completion:nil];
    NSLog(@"%@",[GameConfig globalConfig]);
}

- (IBAction)returnBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loadSavedMap:(id)sender
{
    /* Update view */
    Level *tmpLevel = [[GameConfig globalConfig] getTemplateLevelFromStoreWithPrimaryIndex:USER_CREATE_LEVEL_PRIMARY_INDEX secondaryIndex:[secondaryLevel.text intValue]];
    
    if (nil == tmpLevel) {
        UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"加载失败"
                                                               message:@"选择的关卡没有地图信息"
                                                          cancelButton:@"我知道了"];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        [map updateWithInstance:tmpLevel.map];
        
        [mapWidth setText:[NSString stringWithFormat:@"%d", map.mapBoxColNumber]];
        [mapHeight setText:[NSString stringWithFormat:@"%d", map.mapBoxRolNumber]];
        
        [displayView setNeedsDisplay];
    }
}

@end
