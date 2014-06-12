//
//  WebSiteViewController.h
//  GZRSKS
//
//  Created by lihong on 14-6-12.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocViewerVC.h"

// 用于打开外部网站
@interface WebSiteViewController : DocViewerVC


- (id)initWithURL:(NSURL *)url;

@end
