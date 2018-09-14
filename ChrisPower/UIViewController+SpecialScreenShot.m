//
//  UIViewController+SpecialScreenShot.m
//  ChrisPower
//
//  Created by Chris on 15/3/19.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "UIViewController+SpecialScreenShot.h"

@implementation UIViewController(SpecialScreenShot)

- (UIImage *)specialScreenShot
{
    UIImage *baseImage = [UIImage imageNamed:@"share_bg667X375.png"];
    
    NSArray *imageArray = [NSArray arrayWithObjects:
                           [self dealedScreenShot],
//                           [self cuteImage],
                           nil];
    
    NSArray *pointArray = [NSArray arrayWithObjects:
                           @"0", @"0",
//                           @"0", @"0",
                           nil];
    
    UIImage *mergeImage = [self mergedImageOnMainImage:baseImage WithImageArray:imageArray AndImagePointArray:pointArray];
    
    return mergeImage;
}

- (UIImage *)mergeCuteImageBasedOnImage:(UIImage *)image
{
    NSArray *imageArray = [NSArray arrayWithObjects:
                           [self cuteImage],
                           nil];
    
    NSArray *pointArray = [NSArray arrayWithObjects:
                           @"0", @"0",
                           nil];
    
    UIImage *mergeImage = [self mergedImageOnMainImage:image WithImageArray:imageArray AndImagePointArray:pointArray];
    
    return mergeImage;
}

- (UIImage *)screenShot
{
    CGRect wholeWindow = [UIScreen mainScreen].bounds;
    
    UIGraphicsBeginImageContextWithOptions(wholeWindow.size, NO, 0);
    [[self.view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenShot;
}

- (UIImage *)dealedScreenShot
{
    UIImage *screenShot = [self screenShot];
    
    CGRect tmpRect = CGRectMake(0, 0, 667, 375);
    
    UIGraphicsBeginImageContextWithOptions(tmpRect.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, tmpRect);
    
    /* 1. Rotate the context */
    CGContextRotateCTM(context, -0.1745); /* About -10° */
    
    /* 2. Move the context to the correct position */
    CGContextTranslateCTM(context, 17, 98);
    
    /* 3. Draw image */
    tmpRect.size.width *= 0.8;
    tmpRect.size.height *= 0.8;
    [screenShot drawInRect:tmpRect];
    
    /* 4. Get the image */
    UIImage * dealedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return dealedImage;
}

- (UIImage *)cuteImage
{
    NSString *imageStr = [NSString stringWithFormat:@"cute%d_667X375.png", (rand() % CUTE_IMAGE_NUM + 1)];
    UIImage *orgCuteImage = [UIImage imageNamed:imageStr];
    
    CGRect tmpRect = CGRectMake(0, 0, 667, 375);
    
    UIGraphicsBeginImageContextWithOptions(tmpRect.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, tmpRect);
    
    /* 2. Move the context to the correct position */
    int xOffset = 400;
    int yOffset = 220;
    CGContextTranslateCTM(context, xOffset, yOffset);
    
    /* 3. Draw image */
    int sideSpace = 10;
    tmpRect.size.width -= (xOffset + sideSpace);
    tmpRect.size.height -= (yOffset + sideSpace);
    [orgCuteImage drawInRect:tmpRect];
    
    /* 4. Get the image */
    UIImage * cuteImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return cuteImage;
}

- (UIImage *) mergedImageOnMainImage:(UIImage *)mainImg WithImageArray:(NSArray *)imgArray AndImagePointArray:(NSArray *)imgPointArray
{
    
    UIGraphicsBeginImageContext(mainImg.size);
    
    [mainImg drawInRect:CGRectMake(0, 0, mainImg.size.width, mainImg.size.height)];
    int i = 0;
    for (UIImage *img in imgArray) {
        [img drawInRect:CGRectMake([[imgPointArray objectAtIndex:i] floatValue],
                                   [[imgPointArray objectAtIndex:i+1] floatValue],
                                   img.size.width,
                                   img.size.height)];
        
        i+=2;
    }
    
    CGImageRef NewMergeImg = CGImageCreateWithImageInRect(UIGraphicsGetImageFromCurrentImageContext().CGImage,
                                                          CGRectMake(0, 0, mainImg.size.width, mainImg.size.height));
    
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:NewMergeImg];
}


@end
