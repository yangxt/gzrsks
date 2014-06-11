//
//  NewsContentVC.h
//  GZRSKS
//
//  Created by LiHong on 14-1-14.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import <UIKit/UIKit.h>

// 考试信息内容列表
@class News;
@interface NewsContentVC : UIViewController
{
    @private
    UIButton *_refreshButton;
    UIButton *_favoriteButton;
    UIActivityIndicatorView *_refreshActivityIndicator;
}

- (id)initWithNews:(News *)news;

@end
