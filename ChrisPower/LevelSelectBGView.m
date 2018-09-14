//
//  LevelSelectBGView.m
//  ChrisPower
//
//  Created by Chris on 15/2/11.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "LevelSelectBGView.h"

@implementation LevelSelectBGView

- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"bg_empty.png"];
    
    [image drawInRect:rect];
}

@end
