//
//  UIViewController+SpecialScreenShot.h
//  ChrisPower
//
//  Created by Chris on 15/3/19.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CUTE_IMAGE_NUM      11

@interface UIViewController(SpecialScreenShot)

/*
 Note：The pic must be 667*375
 
 1、Get the background image;
 2、Get the dealed screen shot image;
    2.1 screen shot;
    2.2 deal the screen shot;
        2.2.1 set the context rotate;
        2.2.2 move the context coodination;
        2.2.3 draw the screen shot in context with size 667*375
 3、Get the cute image;
 4、Compile the images;
 */
- (UIImage *)specialScreenShot;

/* 
  The based image need be 667X375
  */
- (UIImage *)mergeCuteImageBasedOnImage:(UIImage *)image;

@end
