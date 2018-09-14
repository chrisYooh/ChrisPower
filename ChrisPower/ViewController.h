//
//  ViewController.h
//  ChrisPower
//
//  Created by Chris on 14/12/5.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

enum {
    /* Monster size:  30---80
     * Monster position: size / 2 --- MAX - size / 2
     * Monster fall: 50 --- MAX - size / 2*/
    BG_MONSTER_SIZE_MIN = 20,
    BG_MONSTER_SIZE_MAX = 120,
    BG_MONSTER_FALL_MIN = 50,
    
    BG_MONSTER_DURATION_MIN = 2,
    BG_MONSTER_DURATION_MAX = 6,
};

@class ChrisMonster;
@class GameViewController;

@interface ViewController : UIViewController<AVAudioPlayerDelegate>
{
    ChrisMonster *bgMonster;
    CALayer *bgMonsterLayer;
    
    GameViewController *gameViewController;
    
    __weak IBOutlet UITextField *awardCode;
}

@end

