//
//  GameOpItemView.h
//  ChrisPower
//
//  Created by Chris on 15/2/27.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameOpItemView;

@protocol GameOpItemVieDelegate <NSObject>

- (void)GameOpItemViewDidEndedTouch:(GameOpItemView *)view;

@end

@interface GameOpItemView : UIView
{
    int index;
    UIImage *image;
    int value;
}
@property (nonatomic, weak) id<GameOpItemVieDelegate> delegate;
@property (nonatomic, readonly) int index;
@property (nonatomic) int value;

+ (NSComparator)comparator;

- (id)initWithIndex:(int)inputIndex
              image:(UIImage *)inputImage
              value:(int)inputValue;

@end
