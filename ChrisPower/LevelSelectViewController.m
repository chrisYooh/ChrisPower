//
//  LevelSelectViewController.m
//  ChrisPower
//
//  Created by Chris on 14/12/23.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//
#import "GameConfig.h"

#import "GameViewController.h"
#import "LevelDisplayView.h"

#import "Level.h"
#import "DynamicLevel.h"
#import "Waves.h"
#import "WaveItem.h"

#import "LevelSelectViewController.h"

@interface LevelSelectViewController ()

@end

@implementation LevelSelectViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createLevels];
    
    [levelType setCurrentPage:PCLEVEL_TYPE_CLASSICAL];
    currentArray = classicalLevels;
    
    [self updateLevelViews];
    
    /* Add guesture */
    UISwipeGestureRecognizer *recognizer = nil;
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(gestureDidSwiped:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(gestureDidSwiped:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(levelLockedStatusUpdate)
                                                 name:@"LevelLockedStatusUpdate"
                                               object:nil];
}

- (void)createLevels
{
    GameConfig *config = [GameConfig globalConfig];
    
    NSMutableArray *tmpClassicalLevels = [[NSMutableArray alloc] init];
    NSMutableArray *tmpTestLevels = [[NSMutableArray alloc] init];
    NSMutableArray *tmpUserCreateLevels = [[NSMutableArray alloc] init];
    
    [config readOnlyEnumLevelWithBlock:^(const Level *level, const NSString *key) {
        LevelDisplayView *view = [[LevelDisplayView alloc] initWithLevelPrimaryIndex:level.primaryIndex
                                                                      secondaryIndex:level.secondaryIndex];
        [view setBackgroundColor:[UIColor clearColor]];
        [view setDelegate:self];
        [view levelLockedStatusUpdate];
        
        if (TEACH_LEVEL_PIRMARY_INDEX == level.primaryIndex) {
            [tmpTestLevels addObject:view];
        } else if (USER_CREATE_LEVEL_PRIMARY_INDEX == level.primaryIndex) {
            [tmpUserCreateLevels addObject:view];
        } else {
            [tmpClassicalLevels addObject:view];
        }
    }];
    
    classicalLevels = [tmpClassicalLevels sortedArrayUsingComparator:[LevelDisplayView comparator]];
    testLevels = [tmpTestLevels sortedArrayUsingComparator:[LevelDisplayView comparator]];
    userCreateLevels = [tmpUserCreateLevels sortedArrayUsingComparator:[LevelDisplayView comparator]];
}

- (void)updateLevelViews
{
    if (nil == scrollView) {
        return;
    }
    
    /* Clear scrollView subviews */
    for (UIView *view in currentArray) {
        [view removeFromSuperview];
    }
    
    /* Get View array */
    switch (levelType.currentPage) {
        case PCLEVEL_TYPE_TEACH:
            [levelTypeLabel setText:@"试玩关卡"];
            currentArray = testLevels;
            break;
        case PCLEVEL_TYPE_CLASSICAL:
            [levelTypeLabel setText:@"经典关卡"];
            currentArray = classicalLevels;
            break;
        case PCLEVEL_TYPE_USER_CREATE:
            [levelTypeLabel setText:@"DIY关卡"];
            currentArray = userCreateLevels;
            break;
            
        default:
            break;
    }
    
    /* Reset ScrollView content */
    CGRect tmpRect = scrollView.bounds;
    tmpRect.size.height *= currentArray.count;
    [scrollView setContentOffset:CGPointZero];
    [scrollView setContentSize:tmpRect.size];
    
    /* Localize subviews in scrollView */
    tmpRect = CGRectMake(10, 10,
                         scrollView.bounds.size.width - 20,
                         scrollView.bounds.size.height - 20);
    
    for (LevelDisplayView *view in currentArray) {
        [view setFrame:tmpRect];
        [scrollView addSubview:view];
        tmpRect.origin.y += scrollView.bounds.size.height;
    }
    
    currentLevel = [currentArray firstObject];
}

-(void)gestureDidSwiped:(UISwipeGestureRecognizer *)recognizer
{
    NSInteger type = levelType.currentPage;
    
    if (UISwipeGestureRecognizerDirectionRight == recognizer.direction) {
        type = (type - 1 >= 0 ) ? (type - 1) : type;
    } else if (UISwipeGestureRecognizerDirectionLeft == recognizer.direction) {
        type = (type + 1 < levelType.numberOfPages) ? (type + 1) : type;
    }
    
    [levelType setCurrentPage:type];
    [self updateLevelViews];
}

#pragma mark UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scView
{
    int index = scView.contentOffset.y / scrollView.bounds.size.height;

    currentLevel = [currentArray objectAtIndex:index];
}

#pragma mark Notification
- (void)levelLockedStatusUpdate;
{
    for (LevelDisplayView *view in classicalLevels) {
        [view levelLockedStatusUpdate];
    }
}

#pragma LevelDisplayView Datasource
- (NSArray *)LevelDisplayViewLevelMonsters:(LevelDisplayView *)view
{
    Level *level = [[GameConfig globalConfig] getTemplateLevelFromStoreWithPrimaryIndex:view.levelPrimaryIndex
                                                                         secondaryIndex:view.levelSecondaryIndex];
    const WaveItem *item = [level.waves getWaveByIndex:0];
    
    return [NSArray arrayWithObjects:
            [self getImageByMonsterType:item.monsterType1],
            [self getImageByMonsterType:item.monsterType2],
            [self getImageByMonsterType:item.monsterType3],
            nil];
}

- (UIImage *)getImageByMonsterType:(int)type
{
    if (MONSTER_TYPE_RANDOM == type) {
        return [UIImage imageNamed:@"random100X100.png"];
    }
    
    return [[GameConfig globalConfig] getTemplateMonsterFromStoreWithType:type].iconImage;
}

#pragma mark target-response message
- (IBAction)gameBegin:(id)sender
{
    GameConfig *config = [GameConfig globalConfig];
    
    if (nil == currentLevel) {
        UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"没有选择关卡"
                                                               message:@"请选择一个关卡"
                                                          cancelButton:@"好的"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (YES == currentLevel.locked) {
        
        UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"关卡未解锁"
                                                               message:@"请通关前置关卡以解锁该关卡"
                                                          cancelButton:@"好的"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [config setCurrentLevelPrimaryType:currentLevel.levelPrimaryIndex];
    [config setCurrentLevelSecondaryType:currentLevel.levelSecondaryIndex];
    
    GameViewController *gvController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    
    [self presentViewController:gvController animated:YES completion:nil];
}

- (IBAction)returnBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)levelTypeDidChange:(id)sender
{
    [self updateLevelViews];
}

- (IBAction)uperLevel:(id)sender
{
    if (nil == currentLevel) {
        return;
    }
    
    int currentIndex = scrollView.contentOffset.y / scrollView.bounds.size.height;
    int newIndex = (currentIndex - 1 > 0) ? (currentIndex - 1) : 0;
    
    currentLevel = [currentArray objectAtIndex:newIndex];
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.bounds.size.height * newIndex)];
}

- (IBAction)downLevel:(id)sender
{
    if (nil == currentLevel) {
        return;
    }
    
    int currentIndex = scrollView.contentOffset.y / scrollView.bounds.size.height;
    int maxIndex = (int)scrollView.subviews.count - 3;
    int newIndex = (currentIndex + 1 < maxIndex) ? (currentIndex + 1) : maxIndex;
    
    currentLevel = [currentArray objectAtIndex:newIndex];
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.bounds.size.height * newIndex)];
}

@end
