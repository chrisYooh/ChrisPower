//
//  GameInfoView.h
//  ChrisPower
//
//  Created by Chris on 15/1/12.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Game;
@class Player;
@class GameInfoView;

@protocol GameInfoViewDataSource <NSObject>

- (Game *)GameInfoViewGetGameInfo:(GameInfoView *)view;

@end

@interface GameInfoView : UIView
{
    UIImage *goldImage;
//    UIImage *mpImage;
    UIImage *waveImage;
    UIImage *hpImage;
    UIImage *scoreImage;
    
    int itemSpace;
    
    CGRect goldRedrawRect;
//    CGRect mpRedrawRect;
    CGRect waveRedrawRect;
    CGRect hpRedrawRect;
    CGRect scoreRedrawRect;
}
@property (nonatomic, weak) id<GameInfoViewDataSource> delegate;

- (void)setGoldNeedDisplay;
//- (void)setMagicPointNeedDisplay;
- (void)setWaveNeedDisplay;
- (void)setHealthPointNeedDisplay;
- (void)setScoreNeedDisplay;

@end
