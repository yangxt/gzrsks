//
//  HaveReadNews.m
//  GZRSKS
//
//  Created by LiHong on 14-1-21.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "HaveReadNews.h"
#import "TMCache.h"
#import "News.h"

static NSString *const kHaveReadNewsURLSet = @"HaveReadNewsURLSet";

@implementation HaveReadNews

+ (BOOL) isRead:(News *)news
{
    NSSet *set = [[TMCache sharedCache] objectForKey:kHaveReadNewsURLSet];
    return [set containsObject:news.contentUrl.absoluteString];
}

+ (void) markAsReaded:(News *)news
{
    [[TMCache sharedCache] objectForKey:kHaveReadNewsURLSet block:^(TMCache *cache, NSString *key, id object) {
        NSMutableSet *set = object;
        if(set)
        {
            [set addObject:news.contentUrl.absoluteString];
        }else{
             set  = [NSMutableSet setWithObject:news.contentUrl.absoluteString];
        }
        
        [[TMCache sharedCache] setObject:set forKey:kHaveReadNewsURLSet block:NULL];
        
    }];
}

@end
