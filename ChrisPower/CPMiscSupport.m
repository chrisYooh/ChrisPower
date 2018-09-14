//
//  CPMiscSupport.m
//  ChrisPower
//
//  Created by Chris on 15/12/24.
//  Copyright © 2015年 CHRIS. All rights reserved.
//

#import "CPMiscSupport.h"

@implementation CPMiscSupport

+ (UIAlertController *)singleAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancelButton
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [self singleActionWithTitle:cancelButton];
    [alert addAction:defaultAction];
    
    return alert;
}

+ (UIAlertAction *)singleActionWithTitle:(NSString *)title
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    
    return action;
}

@end
