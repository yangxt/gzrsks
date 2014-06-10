//
//  NewsProvider.h
//  GZRSKS
//
//  Created by lihong on 14-6-10.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import <Foundation/Foundation.h>
@class NewsGroup;

// 此类负责管理考信息的获取和分组工作
@interface NewsProvider : NSObject
{
    @private
    NSInteger _pageIndex;
    NSMutableArray *_newsGroupArray;
}

@property (nonatomic, readonly) NSUInteger allNewsCount;
@property (nonatomic, readonly) NSUInteger newsGroupCount;

+ (instancetype)shared;
- (NewsGroup *)getNewsGroupByIndex:(NSInteger)index;

- (NSURLSessionTask *)fetchNewsWithRefreshFlag:(BOOL)isRefresh OnCompletedHandler:(void(^)(void))completedHandler onFail:(void(^)(NSError *error))failHandler;

- (NSURLSessionTask *)fetchNewsContentWithURL:(NSURL *)url onCompleted:(void(^)(NSString *))completedHandler onFail:(void(^)(NSError *error))failHandler;

@end

