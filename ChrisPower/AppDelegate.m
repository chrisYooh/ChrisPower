//
//  AppDelegate.m
//  ChrisPower
//
//  Created by Chris on 14/12/5.
//  Copyright (c) 2014年 CHRIS. All rights reserved.
//

#import "InAppRageIAPHelper.h"

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* For IAP */
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[InAppRageIAPHelper sharedHelper]];
    
    /* For WeChat */
    [WXApi registerApp:@"wx4bc1e0de9890200b"];
    [self performSelector:@selector(testLog) withObject:nil afterDelay:3];
    
    return YES;
}

- (void) testLog
{
    NSLog(@"startstart");
    for (int i = 0; i < 1; i++)
    {
        [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"wx4bc1e0de9890200b%d://",i]]];
    }
    NSLog(@"endend");
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark WeChat message
- (void)onResp:(BaseResp *)resp
{
    NSLog(@"<%s:%d>", __func__, __LINE__);
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSLog(@"Send Message To WXResp Message");
        
        NSString *strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];

    } else if ([resp isKindOfClass:[SendAuthReq class]]) {
        NSLog(@"Send Auth Message");
    } else if ([resp isKindOfClass:[PayReq class]]) {
        NSLog(@"Pay Requirement");
    }
    
    
}

@end
