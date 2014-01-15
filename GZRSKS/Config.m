//
//  Config.m
//  ExamInfo
//
//  Created by LiHong on 13-12-19.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import "Config.h"

static NSString *kHostName = @"www.163gz.com";

@implementation Config

+ (NSString *)hostName
{
    return kHostName;
}

+ (UIColor *)defaultNewsTitleColor
{
    return [UIColor darkGrayColor];
}

@end
