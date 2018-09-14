//
//  ShareViewController.h
//  ChrisPower
//
//  Created by Chris on 15/3/19.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController

@property (nonatomic, retain) UIImage *specialScreenShot;
@property (weak, nonatomic) IBOutlet UIImageView *demoView;

@property (weak, nonatomic) IBOutlet UIButton *weChatButtonFriends;
@property (weak, nonatomic) IBOutlet UIButton *weChatButtonFriendsScope;
@end
