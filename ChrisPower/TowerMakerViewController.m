//
//  TowerMakerViewController.m
//  ChrisPower
//
//  Created by Chris on 14/12/25.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "GameConfig.h"
#import "ChrisTower.h"

#import "TowerMakerViewController.h"

@interface TowerMakerViewController ()

@end

@implementation TowerMakerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveTower:(id)sender
{
    ChrisTower *tower = [[ChrisTower alloc] init];
    
    [tower setType:[[type text] intValue]];
    [tower setAttack:[[attack text] intValue]];
    [tower setIgnoreArmor:[[ignoreArmor text] intValue]];
    [tower setAttackInterval:[[attackInterval text] intValue]];
    [tower setAttackRadius:[[attackRadius text] intValue]];
    
    [tower setSpeedAddition:[[speedAddition text] intValue]];
    /* Value of gold */ [tower setValueOfGold:[tower recommendValueOfGold]];
    /* Cannon Slot */ [tower setCannonSlotNumber:3];
    [tower createImage];
    
    [[GameConfig globalConfig] updateStoreWithTower:tower];
}

- (IBAction)showConfig:(id)sender
{
    NSLog(@"%@", [GameConfig globalConfig]);
}

- (IBAction)touchUpInside:(id)sender
{
    [[self view] endEditing:YES];
}

- (IBAction)returnBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loadSavedTower:(id)sender
{
    ChrisTower *tmpTower = [[GameConfig globalConfig] getTemplateTowerFromStoreWithType:[type.text intValue]];
    
    if (nil == tmpTower) {
        UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"加载失败"
                                                               message:@"找不到对应的战塔"
                                                          cancelButton:@"我知道了"];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [attack setText:[NSString stringWithFormat:@"%d", tmpTower.attack]];
        [ignoreArmor setText:[NSString stringWithFormat:@"%d", tmpTower.ignoreArmor]];
        [attackInterval setText:[NSString stringWithFormat:@"%d", tmpTower.attackInterval]];
        [attackRadius setText:[NSString stringWithFormat:@"%d", tmpTower.attackRadius]];
        [speedAddition setText:[NSString stringWithFormat:@"%d", tmpTower.speedAddition]];
    }
}

@end
