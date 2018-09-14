//
//  GameMapView.h
//  ChrisPower
//
//  Created by Chris on 15/2/4.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChrisMap;
@class GameMapView;

@protocol GameMapViewDatasource <NSObject>

- (ChrisMap *)gameMapViewMap:(GameMapView *)view;

@end

@interface GameMapView : UIView
@property (nonatomic, weak) id<GameMapViewDatasource> delegate;

@end
