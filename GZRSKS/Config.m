//
//  Config.m
//  ExamInfo
//
//  Created by LiHong on 13-12-19.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import "Config.h"

static NSString *const kNightModal = @"NIGHTMODEL";

#define  UDSET(obj,key)  [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];\
                         [[NSUserDefaults standardUserDefaults] synchronize]

#define  UDGET(key)      [[NSUserDefaults standardUserDefaults] objectForKey:key]

@implementation Config

+ (id)shared
{
    static Config *instance = nil;
    if(instance == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[Config alloc] init];
        });
    }
    return instance;
}

- (void)setNightModal:(BOOL)nightModal
{
    [[NSUserDefaults standardUserDefaults] setBool:nightModal forKey:kNightModal];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)getNightModal
{
    return   [[NSUserDefaults standardUserDefaults] boolForKey:kNightModal];
}

@end
