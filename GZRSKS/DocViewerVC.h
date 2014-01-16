//
//  DocViewerVC.h
//  GZRSKS
//
//  Created by LiHong on 14-1-16.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocTypeDetector.h"

@interface DocViewerVC : UIViewController
{
    @private
    UIButton *_sendOutButton;
    UIActivityIndicatorView *_loadingActivityIndicator;
    NSURL *_docURL;
    DocType _docType;
}

- (id)initWithDocType:(DocType)type docURL:(NSURL *)url;

@end
