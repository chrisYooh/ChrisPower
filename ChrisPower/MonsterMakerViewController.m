//
//  MonsterMakerViewController.m
//  ChrisPower
//
//  Created by Chris on 14/12/25.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "GameConfig.h"
#import "ChrisMonster.h"

#import "MonsterMakerViewController.h"

@interface MonsterMakerViewController ()

@end

@implementation MonsterMakerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveMonster:(id)sender
{
    ChrisMonster *monster = [[ChrisMonster alloc] init];
    
    [monster setType:[[type text] intValue]];
    [monster setHealthPointMax:[[healthPoint text] intValue]];
    [monster setArmor:[[armor text] intValue]];
    [monster setMoveSpeed:[[moveSpeed text] intValue]];
    [monster createImage];
    
    [[GameConfig globalConfig] updateStoreWithMonster:monster];
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

- (IBAction)loadSavedMonster:(id)sender
{
    ChrisMonster *tmpMonster = [[GameConfig globalConfig] getTemplateMonsterFromStoreWithType:[type.text intValue]];
    
    if (nil == tmpMonster) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Load Failed"
                                                            message:@"No monster info for selected type"
                                                           delegate:self
                                                  cancelButtonTitle:@"I Know"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        [healthPoint setText:[NSString stringWithFormat:@"%d", tmpMonster.healthPointMax]];
        [armor setText:[NSString stringWithFormat:@"%d", tmpMonster.armor]];
        [moveSpeed setText:[NSString stringWithFormat:@"%d", tmpMonster.moveSpeed]];
    }
}

@end
