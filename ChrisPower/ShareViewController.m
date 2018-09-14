//
//  ShareViewController.m
//  ChrisPower
//
//  Created by Chris on 15/3/19.
//  Copyright (c) 2015年 CHRIS. All rights reserved.
//

#import "UIViewController+SpecialScreenShot.h"

#import "WXApi.h"
#import "WXApiObject.h"

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController
@synthesize specialScreenShot;
@synthesize demoView;
@synthesize weChatButtonFriends;
@synthesize weChatButtonFriendsScope;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [self mergeCuteImageBasedOnImage:specialScreenShot];
    [demoView setImage:image];
    
    /* Hide weChat interface if weChat not installed */
    if (NO == [WXApi isWXAppInstalled]) {
        [weChatButtonFriends setHidden:YES];
        [weChatButtonFriendsScope setHidden:YES];
    }
}

- (IBAction)saveAlbum:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(demoView.image, nil, nil, nil);//保存图片到照片库
}

- (void)shareImageWithScene:(enum WXScene)scene
{
    UIImage *targetImage = demoView.image;
    /* 0.18can, 0.19can't */
    UIImage *thumbImage = [UIImage imageWithData:UIImageJPEGRepresentation(targetImage, 0.1)];
    
    /* Orginize message */
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:thumbImage];
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImagePNGRepresentation(targetImage);
    message.mediaObject = ext;
    
    /* Orginize Req */
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIImage *image = [self mergeCuteImageBasedOnImage:specialScreenShot];
    [demoView setImage:image];
}

- (IBAction)shareToWeChatFriends:(id)sender
{
    if (YES == [WXApi isWXAppInstalled]) {
        [self shareImageWithScene:WXSceneSession];
    }else{
        
        UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"分享微信好友失败"
                                                               message:@"您需要安装微信才能于使用该功能"
                                                          cancelButton:@"我明白了"];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)shareToWeChatFrendsScope:(id)sender
{
    if (YES == [WXApi isWXAppInstalled]) {
       [self shareImageWithScene:WXSceneTimeline];
    }else{
        UIAlertController *alert = [CPMiscSupport singleAlertWithTitle:@"分享微信好友失败"
                                                               message:@"您需要安装微信才能于使用该功能"
                                                          cancelButton:@"我明白了"];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)returnBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
