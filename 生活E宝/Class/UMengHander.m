//
//  UMengHander.m
//  生活E宝
//
//  Created by Admin on 16/12/16.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import "UMengHander.h"

@implementation UMengHander
+ (UMengHander *)share{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),
                                                   @(UMSocialPlatformType_WechatTimeLine),
                                                   @(UMSocialPlatformType_WechatFavorite),
                                                   @(UMSocialPlatformType_QQ),
                                                   @(UMSocialPlatformType_Qzone)]];
    });
    return _sharedObject;
}


@end
