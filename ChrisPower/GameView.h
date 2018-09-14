//
//  GameView.h
//  ChrisPower
//
//  Created by Chris on 14/12/5.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Game;
@class GameView;

@protocol GameViewDatasource <NSObject>

- (Game *)gameViewRunningGame:(GameView *)view;

@end

@protocol GameViewDelegate <NSObject>

#if 1
- (void)gameView:(GameView *)gameView drawExtraWithContext:(CGContextRef)context;
#endif

- (void)gameView:(GameView *)gameView didBeginTouchPointWithTouch:(UITouch *)touch;
- (void)gameView:(GameView *)gameView didEndTouchPointWithTouch:(UITouch *)touch;

@end

@interface GameView : UIView

@property (nonatomic,weak) id<GameViewDatasource, GameViewDelegate> delegate;

@end
