//
//  NewsGroup.h
//  GZRSKS
//
//  Created by lihong on 14-6-10.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import <Foundation/Foundation.h>
@class News;

// 此类包含了某一天发布的所有考试信息
@interface NewsGroup : NSObject

@property (nonatomic, strong) NSString *publishDate;
@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, strong) NSMutableArray *newsArray;

- (void)setPublishDate:(NSString *)date;
- (void)addNewsToGroup:(News *)news;

@end
