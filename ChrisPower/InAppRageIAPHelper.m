//
//  InAppRageIAPHelper.m
//  InAppRage
//
//  Created by Ray Wenderlich on 2/28/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "InAppRageIAPHelper.h"

@implementation InAppRageIAPHelper

static InAppRageIAPHelper * _sharedHelper;

+ (InAppRageIAPHelper *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[InAppRageIAPHelper alloc] init];
    return _sharedHelper;
    
}

- (id)init {
    
#if 0
    NSSet *productIdentifiers = [NSSet setWithObjects:
                                 //                                 @"com.ChrisTestAppID.inAppPurchasesAppPurchaseTest.test6RMB",
                                 @"com.ChrisTestAppID.inAppPurchasesAppPurchaseTest.liuzhengyang",
                                 @"com.ChrisTestAppID.inAppPurchasesAppPurchaseTest.zhouyulong",
                                 @"com.ChrisTestAppID.inAppPurchasesAppPurchaseTest.licong",
                                 @"com.ChrisTestAppID.inAppPurchasesAppPurchaseTest.huying",
                                 nil];
#endif
#if 1
    NSSet *productIdentifiers = [NSSet setWithObjects:
                                 @"com.chris.chrispower.cgold01",
                                 @"com.chris.chrispower.cgold05",
                                 @"com.chris.chrispower.cgold10",
                                 @"com.chris.chrispower.cgold18",
                                 @"com.chris.chrispower.cgold30",
                                 @"com.chris.chrispower.cgold50",
                                 @"com.chris.chrispower.cgold60",
                                 
                                 @"com.chris.chrispower.gold01",
                                 @"com.chris.chrispower.gold05",
                                 @"com.chris.chrispower.gold10",
                                 @"com.chris.chrispower.gold18",
                                 @"com.chris.chrispower.gold30",
                                 @"com.chris.chrispower.gold50",
                                 @"com.chris.chrispower.gold60",
                                 nil];
#endif
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers])) {                
        
    }
    return self;
    
}

@end
