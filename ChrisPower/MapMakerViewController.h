//
//  MapMakerViewController.h
//  ChrisPower
//
//  Created by Chris on 14/12/22.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "ViewController.h"
#import "MapMakerView.h"

@class ChrisMap;

@interface MapMakerViewController : ViewController <MapMakerViewDelegate>
{
    ChrisMap *map;
    MapMakerView *displayView;
    
    int currentMapType;
    
    __weak IBOutlet UITextField *mapWidth;
    __weak IBOutlet UITextField *mapHeight;
    __weak IBOutlet UIScrollView *scrollView;
    
    __weak IBOutlet UITextField *secondaryLevel;
    
    __weak IBOutlet UITextField *monster1;
    __weak IBOutlet UITextField *monster2;
    __weak IBOutlet UITextField *monster3;
}

@end
