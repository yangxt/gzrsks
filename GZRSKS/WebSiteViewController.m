//
//  WebSiteViewController.m
//  GZRSKS
//
//  Created by lihong on 14-6-12.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "WebSiteViewController.h"
#import "TWMessageBarManager.h"

@interface WebSiteViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
//@property (strong, nonatomic)     UIActivityIndicatorView *refreshActivityIndicator;
@property (strong, nonatomic) NSURL *url;
@end

@implementation WebSiteViewController

- (id)initWithURL:(NSURL *)url
{
    self = [super initWithNibName:@"WebSiteViewController" bundle:nil];
    if(self)
    {
        self.title = @"外部网站";
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:self.url];
    [self.webView loadRequest:urlRequest];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_loadingActivityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_loadingActivityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_loadingActivityIndicator stopAnimating];
}

@end
