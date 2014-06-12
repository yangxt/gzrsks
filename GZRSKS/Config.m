//
//  Config.m
//  ExamInfo
//
//  Created by LiHong on 13-12-19.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import "Config.h"

static NSString *const kNightModal = @"NIGHTMODEL";
static NSString *const kshouldAutorotateDocViewer = @"AUTOROTATE";

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
            instance = [Config new];
            instance.NightModal = NO;
            instance.shouldAutorotateDocViewer = YES;
        });
    }
    return instance;
}

- (void)setNightModal:(BOOL)aBool
{
    UDSET(@(aBool), kNightModal);
}

- (BOOL)NightModal
{
    NSNumber *boolNumber = UDGET(kNightModal);
    return [boolNumber boolValue];
}

- (void)setShouldAutorotateDocViewer:(BOOL)aBool
{
    UDSET(@(aBool), kshouldAutorotateDocViewer);
}

- (BOOL)shouldAutorotateDocViewer
{
    NSNumber *boolNumber = UDGET(kshouldAutorotateDocViewer);
    return [boolNumber boolValue];
}
@end
