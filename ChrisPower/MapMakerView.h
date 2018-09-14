//
//  MapMakerView.h
//  ChrisPower
//
//  Created by Chris on 14/12/22.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChrisMap;
@class MapMakerView;

@protocol MapMakerViewDelegate <NSObject>

- (ChrisMap *)MapMakerViewGetMap:(MapMakerView *)view;
- (void)MapMakerView:(MapMakerView *)view beenTouchedWithTouch:(UITouch *)touch;
@end

@interface MapMakerView : UIView

@property (nonatomic,weak) id<MapMakerViewDelegate> delegate;

- (void)drawMapWithContext:(CGContextRef)context;

@end
