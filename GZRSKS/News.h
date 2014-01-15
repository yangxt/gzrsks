//
//  News.h
//  GuiZhouRenShiKaoShi
//
//  Created by xcode on 13-3-15.
//  Copyright (c) 2013年 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 考试信息实体
@interface News : NSObject<NSCoding, NSCopying>

@property (nonatomic, copy) NSString *title,*publishDate,*content;
@property (nonatomic, copy) UIColor  *titleColor;
@property (nonatomic, copy) NSURL    *contentUrl;

@end


/// 此类包含了某一天发布的所有考试信息
@interface NewsGroup : NSObject
{
    @private
    NSString *_publishDate;
    NSMutableArray *_newsGroup; // News实体容器
}

@property (nonatomic, readonly) NSString *publishDate;
@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) NSMutableArray *newsGroup;

- (void)setPublishDate:(NSString *)date;
- (void)addNewsToGroup:(News *)news;

@end


/// 此类负责管理考信息的获取和分组工作
@interface NewsProvider : NSObject
{
    @private
    NSInteger _pageIndex;
}

+ (instancetype)sharedInstance;

- (NSInteger)allNewsCount;
- (NSInteger)newsGroupCount;
- (NewsGroup *)getNewsGroupByIndex:(NSInteger)index;

/**
 * @brief 获取考试信息，每调用此方法一次，他会自动回去下一页的内容。此方法在获取考试信息后，会将
 *        考试信息分组，最终将分组(NewsGruop)存放到_newsGroupArray中。
 * @param completedHandler 完成数据获取和分组后调用此Block通知用户
 */
- (NSURLSessionTask *)fetchNewsWithRefreshFlag:(BOOL)isRefresh OnCompletedHandler:(void(^)(void))completedHandler onFail:(void(^)(NSError *error))failHandler;

- (NSURLSessionTask *)fetchNewsContentWithURL:(NSURL *)url onCompleted:(void(^)(NSString *))completedHandler onFail:(void(^)(NSError *error))failHandler;

- (void)releaseMemory;
@end
