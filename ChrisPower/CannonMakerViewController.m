//
//  CannonMakerViewController.m
//  ChrisPower
//
//  Created by Chris on 14/12/25.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "GameConfig.h"
#import "ChrisCannon.h"

#import "CannonMakerViewController.h"

@interface CannonMakerViewController ()

@end

@implementation CannonMakerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveCannon:(id)sender
{
    ChrisCannon *cannon = [[ChrisCannon alloc] init];
    
    [cannon setType:[[type text] intValue]];
    [cannon setAttack:[[attack text] intValue]];
    [cannon setIgnoreArmor:[[ignoreArmor text] intValue]];
    [cannon setMoveSpeed:[[moveSpeed text] intValue]];
    [cannon createImage];
    
    [[GameConfig globalConfig] updateStoreWithCannon:cannon];
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

- (IBAction)loadSavedCannon:(id)sender
{
    ChrisCannon *tmpCannon = [[GameConfig globalConfig] getTemplateCannonFromStoreWithType:[type.text intValue]];
    
    if (nil == tmpCannon) {
        
        UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"Load Failed"
                                                               message:@"No cannon info for selected type"
                                                          cancelButton:@"I Know"];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [attack setText:[NSString stringWithFormat:@"%d", tmpCannon.attack]];
        [ignoreArmor setText:[NSString stringWithFormat:@"%d", tmpCannon.ignoreArmor]];
        [moveSpeed setText:[NSString stringWithFormat:@"%d", tmpCannon.moveSpeed]];
    }
}

@end
