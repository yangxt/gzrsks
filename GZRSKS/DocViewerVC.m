//
//  DocViewerVC.m
//  GZRSKS
//
//  Created by LiHong on 14-1-16.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "DocViewerVC.h"
#import "MessageBox.h"

extern NSString *const UMAppKey;
extern NSString *const kAppDownloadAddress;

static NSString *const kFirstUseSendOutLinkFlag = @"FirstUseSendOutLinkFlag";

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
    
    self->_sendOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_sendOutButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_sendOutButton setTitle:@"外发" forState:UIControlStateNormal];
    [self->_sendOutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_sendOutButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self->_sendOutButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self->_sendOutButton addTarget:self action:@selector(sendOutDocLink) forControlEvents:UIControlEventTouchUpInside];
    
    self->_loadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self->_loadingActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self->_loadingActivityIndicator.hidesWhenStopped = YES;
    
    NSArray *rightItems = @[[[UIBarButtonItem alloc] initWithCustomView:self->_sendOutButton],
                       [[UIBarButtonItem alloc] initWithCustomView:self->_loadingActivityIndicator]];
    self.navigationItem.rightBarButtonItems = rightItems;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self->_docURL]];
    
    self->_sendOutButton.enabled = (self->_docType != DocTypeHTML);
}

- (void)sendOutDocLink
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:kFirstUseSendOutLinkFlag] == NO)
    {
        NSString *msg = @"什么是外发?\n外发是将附件地址分享到您选择的平台，方便之后您通过电脑下载，查看和编辑附件。" ;
        [MessageBox showWithMessage:msg buttonTitle:@"不再提示" handler:^{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstUseSendOutLinkFlag];
        }];
    }
    
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

@end
