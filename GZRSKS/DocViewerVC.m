//
//  DocViewerVC.m
//  GZRSKS
//
//  Created by LiHong on 14-1-16.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "DocViewerVC.h"
#import "MessageBox.h"
#import <objc/message.h>
#import "SubNavigationController.h"

@interface DocViewerVC ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation DocViewerVC

- (id)initWithDocType:(DocType)type docURL:(NSURL *)url
{
    self = [super initWithNibName:@"DocViewerVC" bundle:nil];
    if (self)
    {
        self->_docURL = url;
        self->_docType = type;
        self.title = [DocTypeDetector docTypeName:type];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->_loadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self->_loadingActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self->_loadingActivityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self->_loadingActivityIndicator];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self->_docURL]];
    
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self->_loadingActivityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self->_loadingActivityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self->_loadingActivityIndicator stopAnimating];
    
    [MessageBox showWithMessage:@"网络链接断开或过慢" buttonTitle:@"重试" handler:^{
        [self.webView loadRequest:[NSURLRequest requestWithURL:self->_docURL]];
    }];
}

#pragma mark - 配置旋转

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SubNavigationController *nav = (SubNavigationController *)self.navigationController;
    nav.shouldAutorotate2 = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIDeviceOrientationLandscapeLeft);
}

- (void)viewWillDisappear:(BOOL)animated
{
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIDeviceOrientationPortrait);
    
    SubNavigationController *nav = (SubNavigationController *)self.navigationController;
    nav.shouldAutorotate2 = NO;
    
    [super viewWillDisappear:animated];
    
}

@end
