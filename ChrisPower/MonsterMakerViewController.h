//
//  MonsterMakerViewController.h
//  ChrisPower
//
//  Created by Chris on 14/12/25.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "ViewController.h"

@interface MonsterMakerViewController : ViewController
{
    __weak IBOutlet UITextField *type;
    __weak IBOutlet UITextField *healthPoint;
    __weak IBOutlet UITextField *armor;
    __weak IBOutlet UITextField *moveSpeed;
}

@end
