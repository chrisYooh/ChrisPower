//
//  LevelSelectViewController.h
//  ChrisPower
//
//  Created by Chris on 14/12/23.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "ViewController.h"
#import "LevelDisplayView.h"

@class LevelDisplayView;

enum {
    PCLEVEL_TYPE_TEACH = 0,
    PCLEVEL_TYPE_CLASSICAL,
    PCLEVEL_TYPE_USER_CREATE,
};

@interface LevelSelectViewController : UIViewController
<UIScrollViewDelegate, LevelDisplayViewDatasource>
{
    __weak IBOutlet UIScrollView *scrollView;
    NSArray *classicalLevels;
    NSArray *testLevels;
    NSArray *userCreateLevels;
    __weak IBOutlet UIPageControl *levelType;
    __weak IBOutlet UILabel *levelTypeLabel;
    
    LevelDisplayView *currentLevel;
    NSArray *currentArray;
}

@end
