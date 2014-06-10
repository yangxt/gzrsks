//
//  NewsProvider.m
//  GZRSKS
//
//  Created by lihong on 14-6-10.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "NewsProvider.h"
#import "NetAPI.h"
#import "NewsGroup.h"

@implementation NewsProvider

#pragma mark - 初始化
+ (instancetype)shared
{
    static NewsProvider *instance = nil;
    if(instance == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[NewsProvider alloc] init];
        });
    }
    return instance;
}

- (instancetype)init
{
    if(self = [super init])
    {
        _pageIndex = 0;
        _newsGroupArray = [NSMutableArray new];
    }
    return self;
}

#pragma mark - 访问器
- (NSUInteger)allNewsCount
{
    NSInteger count = 0;
    for(NewsGroup *ng in _newsGroupArray) count += ng.count;
    return count;
}

- (NSUInteger)newsGroupCount
{
    return _newsGroupArray.count;
}

#pragma mark - 接口
- (NewsGroup *)getNewsGroupByIndex:(NSInteger)index
{
    return _newsGroupArray[index];
}

- (NSURLSessionTask *)fetchNewsWithRefreshFlag:(BOOL)isRefresh OnCompletedHandler:(void(^)(void))completedHandler onFail:(void(^)(NSError *error))failHandler
{
    _pageIndex++;
    if(isRefresh) _pageIndex = 1;
    
    NSURLSessionTask *task =
    [[NetAPI sharedInstance] parseTitleWithIndex:_pageIndex onSuccessed:^(NSMutableArray *newsArray) {
        
        if(newsArray.count == 0)
        {
            completedHandler();
            return;
        }
        
        // 对获得的考试信息进行分组：将同一天发布的考试信息分到一个组
        NSMutableArray *tempNewsGroupArray = [NSMutableArray new];
        
        NewsGroup *newsGroup = [[NewsGroup alloc] init];
        [newsGroup setPublishDate:((News*)newsArray[0]).publishDate];
        [tempNewsGroupArray addObject:newsGroup];
        
        for(News *news in newsArray)
        {
            NewsGroup *oldNewsGroup = [tempNewsGroupArray lastObject];
            if([oldNewsGroup.publishDate isEqualToString:news.publishDate])
            {
                [oldNewsGroup addNewsToGroup:news];
                continue;
            }
            
            NewsGroup *newsGroup = [[NewsGroup alloc] init];
            [newsGroup setPublishDate:news.publishDate];
            [newsGroup addNewsToGroup:news];
            [tempNewsGroupArray addObject:newsGroup];
        }
        
        if(isRefresh)
        {
            [_newsGroupArray removeAllObjects];
            
        }else
        {
            // 比较前一次获取的最后一组新闻和现在加载的第一组新闻是否时同一天发布，如果时就合并为一个组
            NewsGroup *newsGroup1 = [_newsGroupArray lastObject];
            NewsGroup *newsGroup2 = [tempNewsGroupArray firstObject];
            if([newsGroup1.publishDate isEqualToString:newsGroup2.publishDate])
            {
                [newsGroup1.newsArray addObjectsFromArray:newsGroup2.newsArray];
                [tempNewsGroupArray removeObject:newsGroup2];
            }
        }
        
        [_newsGroupArray addObjectsFromArray:tempNewsGroupArray];

        if(completedHandler) completedHandler();
        
    } onError:^(NSError *error) {
        if(self->_pageIndex >= 0){
            self->_pageIndex--;
        }
        if(failHandler) failHandler(error);
    }];
    
    return task;
}

- (NSURLSessionTask *)fetchNewsContentWithURL:(NSURL *)url onCompleted:(void(^)(NSString *))completedHandler onFail:(void(^)(NSError *error))failHandler
{
    NSURLSessionTask *task =
    [[NetAPI sharedInstance] parseContentWithContentURL:url OnSuccessed:^(NSString *content) {
        if(completedHandler)  completedHandler(content);

    } onError:^(NSError *error) {
        if(failHandler) failHandler(error);
    }];
    
    return task;
}

@end
