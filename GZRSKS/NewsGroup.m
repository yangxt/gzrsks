//
//  NewsGroup.m
//  GZRSKS
//
//  Created by lihong on 14-6-10.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "NewsGroup.h"
#import "News.h"

@implementation NewsGroup
- (id)init
{
    if(self = [super init])
    {
        self.newsArray = [NSMutableArray new];
    }
    
    return self;
}

- (void)addNewsToGroup:(News *)news
{
    [self.newsArray addObject:news];
}

- (NSInteger)count
{
    return self.newsArray.count;
}

@end
