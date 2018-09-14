//
//  PlayerViewController.m
//  ChrisPower
//
//  Created by Chris on 15/1/5.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "Player.h"

#import "PlayerViewController.h"

@implementation PlayerViewController
@synthesize popTip;

@synthesize labelLv;
@synthesize labelExp;
@synthesize labelShopGold;
@synthesize labelShopCGold;
@synthesize labelHomeHp;
@synthesize labelHomeGold;
@synthesize labelHomeArmor;
@synthesize labelTowerAttackUpper;

@synthesize whatIsHomeHp;
@synthesize whatIsHomeArmor;
@synthesize whatIsHomeGold;
@synthesize whatIsTowerAttackUpper;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        playerSocket = [[AsyncSocket alloc] initWithDelegate:self];
        socketConnected = NO;
        
        serverSocket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [self viewDidLoad];
    
#if 0
    /* Set background image */
    UIImageView *imageView = (UIImageView *)self.view;
    [imageView setImage:[UIImage imageNamed:@"bg_book667X375.png"]];
#endif
    
    /* Set AMPopTip */
    [[AMPopTip appearance] setFont:[UIFont fontWithName:@"Avenir-Medium" size:12]];
    
    self.popTip = [AMPopTip popTip];
    self.popTip.shouldDismissOnTap = YES;
    self.popTip.edgeMargin = 5;
    self.popTip.offset = 2;
    self.popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    self.popTip.tapHandler = ^{
        NSLog(@"Tap!");
    };
    self.popTip.dismissHandler = ^{
        NSLog(@"Dismiss!");
    };
    
    
    /* Set information */
    Player *player = [Player currentPlayer];

    [labelLv setText:[NSString stringWithFormat:@"等级:%d", player.lv]];
    [labelExp setText:[NSString stringWithFormat:@"经验:%d/%d", player.experience, player.currentLvUpExperience]];
    [labelShopGold setText:[NSString stringWithFormat:@"商店金币:%d", player.gold]];
    [labelShopCGold setText:[NSString stringWithFormat:@"商店C币:%d", player.cGold]];
    [labelHomeGold setText:[NSString stringWithFormat:@"%d", player.currentHomeInitialGold]];
    [labelHomeHp setText:[NSString stringWithFormat:@"%d", player.currentHomeHp]];
    [labelHomeArmor setText:[NSString stringWithFormat:@"%d", player.currentHomeArmor]];
    [labelTowerAttackUpper setText:[NSString stringWithFormat:@"+%d%%", player.currentTowerAttackUpPercent]];

}

- (IBAction)returnBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buttonTip:(id)sender
{
    UIButton *button = sender;
    
    [self.popTip hide];
    
    if ([self.popTip isVisible]) {
        return;
    }
    
    NSString *infoStr = @"";
    if (button == self.whatIsHomeGold) {
        infoStr = [NSString stringWithFormat:@"玩家每升1级，游戏初始金币量增加5。  游戏初始金币量的增加，让你在游戏初期即可配置更高的战力！"];
        self.popTip.popoverColor = [UIColor darkGrayColor];
        [self.popTip showText:infoStr direction:AMPopTipDirectionDown maxWidth:200 inView:self.view fromFrame:button.frame];
    } else if (button == self.whatIsHomeHp) {
        infoStr = [NSString stringWithFormat:@"玩家每升5级，家的生命值会增加1。  家生命值的提升，可以让你抵御更过的怪物伤害！"];
        self.popTip.popoverColor = [UIColor darkGrayColor];
        [self.popTip showText:infoStr direction:AMPopTipDirectionLeft maxWidth:200 inView:self.view fromFrame:button.frame];
    } else if (button == self.whatIsHomeArmor) {
        infoStr = [NSString stringWithFormat:@"玩家每升1级，家的护甲值会增加1。  生命低于护甲值的怪物，它的攻击不会对家造成伤害哦！"];
        self.popTip.popoverColor = [UIColor darkGrayColor];
        [self.popTip showText:infoStr direction:AMPopTipDirectionUp maxWidth:200 inView:self.view fromFrame:button.frame];
    } else if (button == self.whatIsTowerAttackUpper) {
        infoStr = [NSString stringWithFormat:@"玩家每升1级，其摆放的战塔的攻击力增加1%%。  战塔攻击力增强的好处，不言而喻！"];
        self.popTip.popoverColor = [UIColor darkGrayColor];
        [self.popTip showText:infoStr direction:AMPopTipDirectionUp maxWidth:200 inView:self.view fromFrame:button.frame];
    }
    
#if 0
    if (sender == self.buttonBottomLeft) {
        self.popTip.popoverColor = [UIColor colorWithRed:0.73 green:0.91 blue:0.55 alpha:1];
        [self.popTip showText:@"I'm a popover popping over" direction:AMPopTipDirectionUp maxWidth:200 inView:self.view fromFrame:sender.frame];
    }
    if (sender == self.buttonBottomRight) {
        self.popTip.popoverColor = [UIColor colorWithRed:0.81 green:0.04 blue:0.14 alpha:1];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"I'm a popover popping over " attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Medium" size:12], NSForegroundColorAttributeName: [UIColor whiteColor]}];
        [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"with attributes!" attributes:@{
                                                                                                                           NSFontAttributeName: [UIFont fontWithName:@"Avenir-Medium" size:14],
                                                                                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                                           NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                                                                                                           }]];
        [self.popTip showAttributedText:attributedText direction:AMPopTipDirectionUp maxWidth:200 inView:self.view fromFrame:sender.frame];
    }
    if (sender == self.buttonCenter) {
        self.popTip.popoverColor = [UIColor colorWithRed:0.31 green:0.57 blue:0.87 alpha:1];
        static int direction = 0;
        [self.popTip showText:@"Animated popover, great for subtle UI tips and onboarding" direction:direction maxWidth:200 inView:self.view fromFrame:sender.frame duration:0];
        direction = (direction + 1) % 4;
    }
#endif

}

/* Net connect related */
/*
- (IBAction)signIn:(id)sender
{
    
}

- (IBAction)login:(id)sender
{
    if (YES == socketConnected) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Info"
                                                            message:@"You are online"
                                                           delegate:nil
                                                  cancelButtonTitle:@"I KNOW"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSError *err = nil;
//    [playerSocket connectToHost:@"49.4.177.211" onPort:8888 error:&err];
//    [playerSocket connectToHost:@"117.135.69.115" onPort:8788 error:&err];
//     [playerSocket connectToHost:@"192.168.1.100" onPort:8788 error:&err];
 [playerSocket connectToHost:@"123.56.111.148" onPort:8788 error:&err];
}

- (IBAction)testMessage:(id)sender
{	NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
    NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
    
    [playerSocket writeData:welcomeData withTimeout:-1 tag:10];
}

- (IBAction)testServer:(id)sender
{
    int port = 8888;
    
    NSError *error = nil;
    if(![serverSocket acceptOnPort:port error:&error])
    {
        NSLog(@"Error starting server: %@", error);
        return;
    }
    
    NSLog(@"Echo server started on port %hu", [serverSocket localPort]);
}

#pragma mark AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    socketConnected = YES;
    NSLog(@"Connect to host: %@:%d succeed", host, port);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Info"
                                                        message:@"Login succeed"
                                                       delegate:nil
                                              cancelButtonTitle:@"NICE"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"%s:%@", __func__, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    socketConnected = NO;
    NSLog(@"Connect end");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Socket Info"
                                                        message:@"Socket did disconnect"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}
*/

@end
