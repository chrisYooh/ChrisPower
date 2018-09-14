//
//  PlayerViewController.h
//  ChrisPower
//
//  Created by Chris on 15/1/5.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "AMPopTip.h"
#import "ViewController.h"

#import "AsyncSocket.h"

@interface PlayerViewController : ViewController <AsyncSocketDelegate>
{
    UIPickerView *pickerView;
    __weak IBOutlet UITextView *infoText;
    
    BOOL socketConnected;
    AsyncSocket *playerSocket;
    
    AsyncSocket *serverSocket;
}
@property (weak, nonatomic) IBOutlet UILabel *labelLv;
@property (weak, nonatomic) IBOutlet UILabel *labelExp;
@property (weak, nonatomic) IBOutlet UILabel *labelShopGold;
@property (weak, nonatomic) IBOutlet UILabel *labelShopCGold;
@property (weak, nonatomic) IBOutlet UILabel *labelHomeGold;
@property (weak, nonatomic) IBOutlet UILabel *labelHomeHp;
@property (weak, nonatomic) IBOutlet UILabel *labelHomeArmor;
@property (weak, nonatomic) IBOutlet UILabel *labelTowerAttackUpper;

@property (weak, nonatomic) IBOutlet UIButton *whatIsHomeGold;
@property (weak, nonatomic) IBOutlet UIButton *whatIsHomeHp;
@property (weak, nonatomic) IBOutlet UIButton *whatIsHomeArmor;
@property (weak, nonatomic) IBOutlet UIButton *whatIsTowerAttackUpper;


@property (nonatomic, strong) AMPopTip *popTip;

@end
