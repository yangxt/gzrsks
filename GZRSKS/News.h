//
//  News.h
//  GuiZhouRenShiKaoShi
//
//  Created by xcode on 13-3-15.
//  Copyright (c) 2013年 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    NewsTypeNews, // 新闻
    NewsTypeAd    // 广告
} NewsType;

// 考试信息实体
@interface News : NSObject<NSCoding, NSCopying>

@property (nonatomic, copy) NSString *title,*publishDate,*content;
@property (nonatomic, copy) UIColor  *titleColor;
@property (nonatomic, copy) NSURL    *contentUrl;
@property (nonatomic, assign) NewsType type;

@end
