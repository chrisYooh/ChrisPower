//
//  CPMiscSupport.h
//  ChrisPower
//
//  Created by Chris on 15/12/24.
//  Copyright © 2015年 CHRIS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPMiscSupport : NSObject

+ (UIAlertController *)singleAlertWithTitle:(NSString *)title
                                    message:(NSString *)message
                               cancelButton:(NSString *)cancelButton;
+ (UIAlertAction *)singleActionWithTitle:(NSString *)title;

@end
