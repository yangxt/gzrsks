//
//  NewsGroupListHeaderView.h
//  GZRSKS
//
//  Created by LiHong on 13-12-22.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsGroup;
@interface NewsGroupListHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame andNewsGroup:(NewsGroup *)newsGroup;

@end
