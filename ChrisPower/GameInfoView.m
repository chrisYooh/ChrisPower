//
//  GameInfoView.m
//  ChrisPower
//
//  Created by Chris on 15/1/12.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "Game.h"
#import "Home.h"
#import "Waves.h"
#import "Player.h"
#import "DynamicLevel.h"  /* TODO: Current grade is better moved to Game */

#import "GameInfoView.h"

@implementation GameInfoView
@synthesize delegate;

static CGRect firstRect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        goldImage = [UIImage imageNamed:@"label_gold250X100.png"];
//        mpImage = [UIImage imageNamed:@"label_mp250X100.png"];
        waveImage = [UIImage imageNamed:@"label_wave250X100.png"];
        hpImage = [UIImage imageNamed:@"label_hp250X100.png"];
        scoreImage = [UIImage imageNamed:@"label_score250X100.png"];
        
        itemSpace = 10;
        
        firstRect = CGRectMake(50, 18, 75, 30);
        
        /* Use for update dynamic game value */
        CGRect tmpRect = firstRect;
        goldRedrawRect = tmpRect;
        tmpRect.origin.x += (tmpRect.size.width + itemSpace);
//        mpRedrawRect = tmpRect;
//        tmpRect.origin.x += (tmpRect.size.width + itemSpace);
        waveRedrawRect = tmpRect;
        tmpRect.origin.x += (tmpRect.size.width + itemSpace);
        hpRedrawRect = tmpRect;
        tmpRect.origin.x += (tmpRect.size.width + itemSpace);
        scoreRedrawRect = tmpRect;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /* Use for localized image */
    CGRect tmpRect = firstRect;
    tmpRect.origin.x -= 28;
    tmpRect.origin.y -= 9;
    int tmpSpace = itemSpace;
    NSString *tmpStr = nil;
    
    Game *tmpGame = [[self delegate] GameInfoViewGetGameInfo:self];
    /* TODO: current score should be in gameinfo */
    Player *tmpPlayer = [Player currentPlayer];
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIFont systemFontOfSize:12.0f], NSFontAttributeName,
                         [UIColor whiteColor], NSForegroundColorAttributeName,
                         nil];
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    /* gold */
    [goldImage drawInRect:tmpRect];
    tmpStr = [NSString stringWithFormat:@"%d", tmpGame.home.gold];
    [tmpStr drawInRect:goldRedrawRect withAttributes:dic];
    
#if 0
    /* mp */;
    tmpRect.origin.x += (tmpRect.size.width + tmpSpace);
    [mpImage drawInRect:tmpRect];
    tmpStr = [NSString stringWithFormat:@"%d", tmpGame.home.magicPoint];
    [tmpStr drawInRect:mpRedrawRect withAttributes:dic];
#endif
    
    /* wave */
    tmpRect.origin.x += (tmpRect.size.width + tmpSpace);
    [waveImage drawInRect:tmpRect];
    tmpStr = [NSString stringWithFormat:@"%d/%d", tmpGame.currentWaveIndex, tmpGame.wavesInfo.waveNumber];
    [tmpStr drawInRect:waveRedrawRect withAttributes:dic];
    
    /* hp */
    tmpRect.origin.x += (tmpRect.size.width + tmpSpace);
    [hpImage drawInRect:tmpRect];
    tmpStr = [NSString stringWithFormat:@"%d", tmpGame.home.healthPoint];
    [tmpStr drawInRect:hpRedrawRect withAttributes:dic];
  
    /* score */
    tmpRect.origin.x += (tmpRect.size.width + tmpSpace);
    if ((tmpRect.origin.x + tmpRect.size.width + tmpSpace) < self.bounds.size.width) {
        [scoreImage drawInRect:tmpRect];
        tmpStr = [NSString stringWithFormat:@"%d", tmpPlayer.currentDynamicLevel.currentGrade];
        [tmpStr drawInRect:scoreRedrawRect withAttributes:dic];
    }
}

- (void)setGoldNeedDisplay
{
    [self setNeedsDisplayInRect:goldRedrawRect];
}

#if 0
- (void)setMagicPointNeedDisplay
{
    [self setNeedsDisplayInRect:mpRedrawRect];
}
#endif

- (void)setWaveNeedDisplay
{
    [self setNeedsDisplayInRect:waveRedrawRect];
}

- (void)setHealthPointNeedDisplay
{
    [self setNeedsDisplayInRect:hpRedrawRect];
}

- (void)setScoreNeedDisplay
{
    [self setNeedsDisplayInRect:scoreRedrawRect];
}

@end
