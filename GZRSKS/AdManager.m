//
//  AdManager.m
//  GZRSKS
//
//  Created by lihong on 14-9-26.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "Ad.h"
#import "TMCache.h"
#import "AdManager.h"

// ToDo:用户启动8次后才显示广告
// ToDo:点击次数统计

static NSString * const kAdConfigFileUrl = @"http://rsks.qiniudn.com/AdConfig.json";
static NSString * const kAdCacheKey = @"AdCacheKey";

@implementation AdManager

+ (instancetype)sharedInstance
{
    static AdManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AdManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        urlSessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        _urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration];
    }
    
    return self;
}

- (NSURLSessionDataTask *)requestAdData:(AdManagerRequestCompletedBlock)completedHandler
{
    // 使用缓存响应请求
   /* NSDictionary *cacheData = [[TMCache sharedCache] objectForKey:kAdCacheKey];
    BOOL hasCacheData = (cacheData != nil);
    if(hasCacheData) {
        completedHandler([self buildAdConfigEntity:cacheData]);
    }*/
    
    //加参数t是为了强制CDN每次都到七牛服务器读数据。否则有可能七牛上的文件更新了，但客户端拿到是CDN缓存的数据。
    NSString *urlStr =[NSString stringWithFormat:@"%@?t=%f",kAdConfigFileUrl,[NSDate timeIntervalSinceReferenceDate]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLSessionDataTask *urlSessionDataTask =
    [_urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"AdManager request data error:%@", error);
            completedHandler(Nil);
            return;
        }
        
        if (data.length == 0) {
            NSLog(@"AdMananger server response zero byte data!");
            completedHandler(nil);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *dict =
        [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        if (jsonError) {
            NSLog(@"AdManager JSON error:%@", jsonError);
            completedHandler(nil);
            return;
        }
        
        // 若之前没缓存有数据，则使用新的数据响应请求.
        /*if (hasCacheData == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completedHandler([self buildAdConfigEntity:dict]);
            });
        }*/
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completedHandler([self buildAdConfigEntity:dict]);
        });
        
        // 更新本地缓存
        [[TMCache sharedCache] setObject:dict forKey:kAdCacheKey block:NULL];
        
    }];
    
    [urlSessionDataTask resume];
    return urlSessionDataTask;
}

- (AdConfig *)buildAdConfigEntity:(NSDictionary *)dict
{
    NSDictionary *copyDict = [dict copy];
    NSDictionary *luanchAdDict = [copyDict objectForKey:@"launch"];
    NSArray *homeAdArray = [copyDict objectForKey:@"home"];
    NSArray *pageAdArray = [copyDict objectForKey:@"page"];
    
    Ad *luanchAdEntity = nil;
    NSMutableArray *homeAdEntityArray = nil;
    NSMutableArray *pageAdEntityArray = nil;
    
    if (luanchAdDict) {
        luanchAdEntity = [[Ad alloc] initWithDictionary:luanchAdDict];
    }
    
    if (homeAdArray) {
        homeAdEntityArray = [NSMutableArray arrayWithCapacity:homeAdArray.count];
        for (NSDictionary *dict in homeAdArray) {
            [homeAdEntityArray addObject:[[Ad alloc] initWithDictionary:dict]];
        }
    }
    
    if (pageAdArray) {
        pageAdEntityArray = [NSMutableArray arrayWithCapacity:pageAdArray.count];
        for (NSDictionary *dict in pageAdArray) {
            [pageAdEntityArray addObject:[[Ad alloc] initWithDictionary:dict]];
        }
    }
    
    self.adConfig = [AdConfig new];
    self.adConfig.luanchAdEntity = luanchAdEntity;
    self.adConfig.homeAdEntityArray = homeAdEntityArray;
    self.adConfig.pageAdEntityArray = pageAdEntityArray;
    
    return self.adConfig;
}

#pragma mark - 接口
+ (NSURLSessionDataTask *)requestAdData:(AdManagerRequestCompletedBlock)completedHandler
{
    return [[AdManager sharedInstance] requestAdData:completedHandler];
}

+ (AdConfig *)getAdConfig
{
    return [AdManager sharedInstance].adConfig;
}
@end
