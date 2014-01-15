//
//  News.m
//  GuiZhouRenShiKaoShi
//
//  Created by xcode on 13-3-15.
//  Copyright (c) 2013年 xcode. All rights reserved.
//

#import "News.h"

static NSString *kTitle      = @"title";
static NSString *kTitleColor = @"titleColor";
static NSString *kDate       = @"date";
static NSString *kUrl        = @"url";
static NSString *kContext    = @"content";

#pragma mark -
@implementation News

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:kTitle];
    [aCoder encodeObject:self.titleColor forKey:kTitleColor];
    [aCoder encodeObject:self.publishDate forKey:kDate];
    [aCoder encodeObject:self.contentUrl forKey:kUrl];
    [aCoder encodeObject:self.content forKey:kContext];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]){
        self.title       = [aDecoder decodeObjectForKey:kTitle];
        self.titleColor  = [aDecoder decodeObjectForKey:kTitleColor];
        self.publishDate = [aDecoder decodeObjectForKey:kDate];
        self.contentUrl  = [aDecoder decodeObjectForKey:kUrl];
        self.content     = [aDecoder decodeObjectForKey:kContext];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    if(copy){
        [copy setTitle:[self.title copyWithZone:zone]];
        [copy setContent:[self.content copyWithZone:zone]];
        [copy setTitleColor:[self.titleColor copyWithZone:zone]];
        [copy setContentUrl:[self.contentUrl copyWithZone:zone]];
        [copy setPublishDate:[self.publishDate copyWithZone:zone]];
    }
    return copy;
}
@end


#pragma mark -
@implementation NewsGroup

- (instancetype)init
{
    if(self = [super init])
        self->_newsGroup = [NSMutableArray new];

    return self;
}

- (void)setPublishDate:(NSString *)date;
{
    self->_publishDate = date;
}

- (void)addNewsToGroup:(News *)news
{
    [self->_newsGroup addObject:news];
}

- (NSString *)publishDate
{
    return self->_publishDate;
}

- (NSInteger)count
{
    return self->_newsGroup.count;
}

- (NSMutableArray *)newsArray
{
    return self->_newsGroup;
}

@end


#pragma mark -
#import "NetAPI.h"

@interface NewsProvider()
@property (atomic, strong) NSMutableArray *newsGroupArray; // NewsGroup实体容器
@end

@implementation NewsProvider

+ (instancetype)sharedInstance
{
    static NewsProvider *provider = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        provider = [[NewsProvider alloc] init];
    });
    return provider;
}

- (instancetype)init
{
    if(self = [super init]){
        self->_pageIndex = 0;
        self.newsGroupArray = [NSMutableArray new];
    }
    return self;
}

- (NSInteger)allNewsCount
{
    NSInteger res = 0;
    for(NewsGroup *ng in self->_newsGroupArray){
        res += ng.count;
    }
    return res;
}

- (NSInteger)newsGroupCount
{
    return self->_newsGroupArray.count;
}

- (NewsGroup *)getNewsGroupByIndex:(NSInteger)index
{
    return self->_newsGroupArray[index];
}

- (NSURLSessionTask *)fetchNewsWithRefreshFlag:(BOOL)isRefresh OnCompletedHandler:(void(^)(void))completedHandler onFail:(void(^)(NSError *error))failHandler
{
    self->_pageIndex++;
    if(isRefresh)
        self->_pageIndex = 1;
    
    NSURLSessionTask *task =
    [[NetAPI sharedInstance] parseTitleWithIndex:self->_pageIndex onSuccessed:^(NSMutableArray *newsArray) {
        
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
            NewsGroup *newsGroup = [tempNewsGroupArray lastObject];
            if([newsGroup.publishDate isEqualToString:news.publishDate])
            {
                [newsGroup addNewsToGroup:news];
                
            }else
            {
                NewsGroup *newsGroup = [[NewsGroup alloc] init];
                [newsGroup setPublishDate:news.publishDate];
                [newsGroup addNewsToGroup:news];
                [tempNewsGroupArray addObject:newsGroup];
            }
        }
        
        if(isRefresh)
        {
            [self releaseMemory];
            [self.newsGroupArray addObjectsFromArray:tempNewsGroupArray];
            
        }else
        {
            NewsGroup *newsGroup1 = [self.newsGroupArray lastObject];
            NewsGroup *newsGroup2 = [tempNewsGroupArray firstObject];
            if([newsGroup1.publishDate isEqualToString:newsGroup2.publishDate])
            {
                [newsGroup1.newsGroup addObjectsFromArray:newsGroup2.newsGroup];
                [tempNewsGroupArray removeObject:newsGroup2];
            }
            
            [self.newsGroupArray addObjectsFromArray:tempNewsGroupArray];
        }
        
        if(completedHandler)
            completedHandler();
        
    } onError:^(NSError *error) {
        if(self->_pageIndex >= 0){
            self->_pageIndex--;
        }
        if(failHandler){
            failHandler(error);
        }
    }];
    
    return task;
}

- (NSURLSessionTask *)fetchNewsContentWithURL:(NSURL *)url onCompleted:(void(^)(NSString *))completedHandler onFail:(void(^)(NSError *error))failHandler
{
    NSURLSessionTask *task =
    [[NetAPI sharedInstance] parseContentWithContentURL:url OnSuccessed:^(NSString *content) {
        if(completedHandler)
            completedHandler(content);
        
    } onError:^(NSError *error) {
        if(failHandler)
            failHandler(error);
    }];
    
    return task;
}

- (void)releaseMemory
{
    [self->_newsGroupArray removeAllObjects];
}
@end
