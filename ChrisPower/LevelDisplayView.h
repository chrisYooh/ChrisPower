//
//  LevelDisplayView.h
//  ChrisPower
//
//  Created by Chris on 15/1/13.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LevelDisplayView;

@protocol LevelDisplayViewDatasource <NSObject>

- (NSArray *)LevelDisplayViewLevelMonsters:(LevelDisplayView *)view;

@end

@interface LevelDisplayView : UIView
{
    BOOL locked;
    
    int levelPrimaryIndex;
    int levelSecondaryIndex;
    
    UIImage *image;
    
    CGRect imageRect;
    CGRect levelInfoRect;
    
    int frameLineWidth;
    int suggestSpace;
}
@property (nonatomic, weak) id<LevelDisplayViewDatasource> delegate;
@property (nonatomic) int levelPrimaryIndex;
@property (nonatomic) int levelSecondaryIndex;

@property (nonatomic, readonly) BOOL locked;

+ (NSComparator)comparator;

- (id)initWithLevelPrimaryIndex:(int)priIndex secondaryIndex:(int)secIndex;

- (void)updateRects;
- (void)levelLockedStatusUpdate;

@end
