//
//  GameView.m
//  ChrisPower
//
//  Created by Chris on 14/12/5.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "GameConfig.h"

#import "Game.h"
#import "ChrisMonster.h"
#import "ChrisTower.h"
#import "ChrisCannon.h"

#import "Level.h"
#import "Player.h"
#import "DynamicLevel.h"

#import "GameView.h"

static UIImage *level1Image = nil;

@implementation GameView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self drawRunningGame];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[self delegate] gameView:self drawExtraWithContext:context];
}

- (void)drawRunningGame
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    Game *game = [[self delegate] gameViewRunningGame:self];
    
    /* Monster */
    [game monstersDrawOrderEnumWithOperation:^(ChrisMonster *monster) {
        [monster drawMonsterWithContext:context];
    }];
    
    /* Tower */
    [game towersDrawOrderEnumWithOperation:^(ChrisTower *tower) {
        [tower drawTowerWithContext:context];
    }];
    
    /* Cannon */
    [game cannonsDrawOrderEnumWithOperation:^(ChrisCannon *cannon) {
        [cannon drawCannonWithContext:context];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        [[self delegate] gameView:self didBeginTouchPointWithTouch:touch];
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        [[self delegate] gameView:self didEndTouchPointWithTouch:touch];
    }
}

@end
