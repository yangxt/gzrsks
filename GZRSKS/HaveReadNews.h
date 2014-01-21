//
//  HaveReadNews.h
//  GZRSKS
//
//  Created by LiHong on 14-1-21.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//


@class News;
@interface HaveReadNews : NSObject

+ (BOOL) isRead:(News *)news;
+ (void) markAsReaded:(News *)news;

@end
