//
//  AdManager.h
//  GZRSKS
//
//  Created by lihong on 14-9-26.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "AdConfig.h"
#import <Foundation/Foundation.h>

typedef void (^AdManagerRequestCompletedBlock)(AdConfig *adConfig);

@interface AdManager : NSObject
{
   @private
    NSURLSession *_urlSession;
}

@property (nonatomic, strong) AdConfig *adConfig;

+ (NSURLSessionDataTask *)requestAdData:(AdManagerRequestCompletedBlock)completedHandler;
+ (AdConfig *)getAdConfig;

@end
