//
//  ViewController.m
//  ChrisPower
//
//  Created by Chris on 14/12/5.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "GameConfig.h"

#import "Player.h"

#import "GameViewController.h"
#import "GameView.h"

#import "ViewController.h"

static AVAudioPlayer *audioPlayer = nil;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /* Play music test */
#if 0
    if (nil == audioPlayer) {
        NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"复刻回忆" ofType:@"mp3"];
        if (musicPath) {
            NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
            [audioPlayer setDelegate:self];
        }
    }
    
    if (NO == [audioPlayer isPlaying]) {
        [audioPlayer play];
    }
#endif
    
    /* Animation Start */
    [self bgMonsterAnimationStart];
}

- (void)bgMonsterAnimationStart
{
    if (nil == bgMonsterLayer) {
        bgMonsterLayer = [[CALayer alloc] init];
        [bgMonsterLayer setBackgroundColor:[UIColor clearColor].CGColor];
        [bgMonsterLayer setDelegate:self];
    }
    
    bgMonster = [[GameConfig globalConfig] getTemplateMonsterFromStoreWithType:1];
    
    [[[self view] layer] addSublayer:bgMonsterLayer];

    [self bgMonsterCreating];
}

- (void)bgMonsterAnimationStop
{
    [bgMonsterLayer removeAllAnimations];
    bgMonster = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Background Timer Operation
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if (bgMonsterLayer == layer) {
        [bgMonsterLayer setBackgroundColor:[UIColor clearColor].CGColor];
        
        /* Adjust the image draw */
        CGContextTranslateCTM(ctx, 0.0, layer.bounds.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        CGContextDrawImage(ctx, layer.bounds, [bgMonster currentImage].CGImage);
    }
}
- (void)bgMonsterCreating
{
    int monsterNumber = [[GameConfig globalConfig] monsterNumber];
    int monsterType = rand() % monsterNumber + 1;
    
    bgMonster = [[GameConfig globalConfig] getTemplateMonsterFromStoreWithType:monsterType];
    
    /* 1. Set Monster show position */
    [CATransaction setDisableActions:YES];
    int tmpLength = (rand() %  (BG_MONSTER_SIZE_MAX - BG_MONSTER_SIZE_MIN)) + BG_MONSTER_SIZE_MIN;
    int posX = rand() % (int)([UIScreen mainScreen].applicationFrame.size.width - tmpLength) + tmpLength / 2;
    CGRect tmpRect = CGRectMake(posX, 0 - tmpLength, tmpLength, tmpLength);
    [bgMonsterLayer setFrame:tmpRect];
    [bgMonsterLayer setNeedsDisplay];
    
    [self bgMonsterFallDown];

}

- (void)bgMonsterFallDown
{
    int animationDuration = rand() % (BG_MONSTER_DURATION_MAX - BG_MONSTER_DURATION_MIN) + BG_MONSTER_DURATION_MIN;
    CGPoint tmpPoint = bgMonsterLayer.position;
    tmpPoint.y = [UIScreen mainScreen].applicationFrame.size.height + bgMonsterLayer.bounds.size.height;
    
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    [CATransaction setAnimationDuration:animationDuration];
    [bgMonsterLayer setPosition:tmpPoint];
    [CATransaction setCompletionBlock:^{
        [NSTimer scheduledTimerWithTimeInterval:animationDuration
                                                          target:self
                                                        selector:@selector(bgMonsterCreating) userInfo:nil
                                                         repeats:NO];
    }];
    [CATransaction commit];
    
    [bgMonsterLayer setNeedsDisplay];
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [audioPlayer play];
}

- (IBAction)configWriteToFile:(id)sender
{
    [GameConfig saveConfigToFile];
}
- (IBAction)configReadLocal:(id)sender
{
    [GameConfig configReadFromLocal];
}

- (IBAction)playButtonTouchUp:(id)sender
{
    [self bgMonsterAnimationStop];
}

- (IBAction)resetPlayer:(id)sender
{
    [Player reset];
    [GameConfig reset];
}

- (IBAction)award:(id)sender
{
    NSString *alertStr = nil;
    
    alertStr = [[Player currentPlayer] awardWithCodeString:awardCode.text];
    [awardCode setText:@""];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"兑奖"
                                                        message:alertStr
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
