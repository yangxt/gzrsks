//
//  NewsListVC.h
//  ExamInfo
//
//  Created by LiHong on 13-12-17.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NewsTypeRealtime,
    NewsTypeFavorite
}NewsType;

@interface NewsGroupListVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    @private
    NewsType _newsType;
    UIButton *_loadMoreButton;
    UIButton *_refreshButton;
    UIButton *_favoriteButton;
    UIButton *_shareButton;
    UIButton *_themeButton;
    UIActivityIndicatorView *_loadMoreActivityIndicator;
    UIActivityIndicatorView *_refreshActivityIndicator;
    NSURLSessionTask *_fetchNewsTask;
    NSArray *_favortesNews;
}
@end
