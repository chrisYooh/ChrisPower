//
//  HelpViewController.m
//  ChrisPower
//
//  Created by Chris on 15/3/6.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "HelpViewController.h"

#define HELP_VIEW_NUMBER    9

@interface HelpViewController ()

@end

@implementation HelpViewController

- (CGRect)singleRect
{
    CGRect tmpRect = [[UIScreen mainScreen] applicationFrame];
    tmpRect.size.width -= 74;
    
    return tmpRect;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect tmpRect = [self singleRect];
    
    for (int i = 0; i < HELP_VIEW_NUMBER; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"help%d.png", i + 1]]];
        
        [imageView setFrame:tmpRect];
        [scrollView addSubview:imageView];
        tmpRect.origin.x += tmpRect.size.width;
    }
    
    tmpRect = [self singleRect];
    tmpRect.size.width *= HELP_VIEW_NUMBER;
    [scrollView setContentSize:tmpRect.size];
}

- (IBAction)returnBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
