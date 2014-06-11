//
//  NewsContentVC.m
//  GZRSKS
//
//  Created by LiHong on 14-1-14.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "NewsContentVC.h"
#import "News.h"
#import "MessageBox.h"
#import "TMCache.h"
#import "DocTypeDetector.h"
#import "DocViewerVC.h"
#import "NewsGroup.h"
#import "NewsProvider.h"
#import "UIColor+HexString.h"
#import <objc/message.h>


extern NSString *const UMAppKey;

NSString *const kNewsCacheKey = @"NewsCacheKey";

extern NSString  *const kNetAPIErorDomain;
extern NSInteger const kNetAPIErrorCode;
extern NSString  *const kNetAPIErrorDesc;
extern NSString  *const kAppDownloadAddress;

@interface NewsContentVC ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong,nonatomic) News *news;
@end

@implementation NewsContentVC

- (id)initWithNews:(News *)news
{
    self = [super initWithNibName:@"NewsContentVC" bundle:nil];
    if (self)
    {
        self.title = @"详情";
        self.news = news;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%f",self.view.bounds.size.height);
    // 收藏按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStylePlain target:self action:@selector(favoriteNews)];
    item.enabled = NO;
    self->_refreshActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self->_refreshActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self->_refreshActivityIndicator.hidesWhenStopped = YES;
    NSArray *rightItems = @[item,
                            [[UIBarButtonItem alloc] initWithCustomView:self->_refreshActivityIndicator]];
    self.navigationItem.rightBarButtonItems = rightItems;
    
    // 用于滚动内容到底部按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(320-50.0, self.view.frame.size.height/2.0, 50.0, 50.0);
    [button addTarget:self action:@selector(scrollNewsContentToBottom) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"ScrollBottom"] forState:UIControlStateNormal];
    button.transform = CGAffineTransformMakeRotation(-M_PI_2);
    button.showsTouchWhenHighlighted = YES;
    [self.view insertSubview:button aboveSubview:self.webView];
    
    [self fetchNewsContent];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
      // 强制旋转视图
      objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIDeviceOrientationPortrait);
}

// 滚动新闻内容到底部
- (void)scrollNewsContentToBottom
{
    CGSize size = self.webView.scrollView.contentSize;
    CGPoint offset = self.webView.scrollView.contentOffset;
     offset.y = abs(size.height-self.webView.bounds.size.height);
    [self.webView.scrollView setContentOffset:offset animated:YES];
}

// 获取新闻内容
- (void)fetchNewsContent
{
    [self->_refreshActivityIndicator startAnimating];

    if(self.news.content)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.webView loadHTMLString:self.news.content baseURL:nil];
        
        if([self theNewsIsFavorited:self.news])
            self.navigationItem.rightBarButtonItem.title = @"已收藏";
        
        return;
    }
    
    [[NewsProvider shared] fetchNewsContentWithURL:self.news.contentUrl onCompleted:^(NSString *content) {
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.news setContent:content];
        [self.webView loadHTMLString:content baseURL:nil];
        
        if([self theNewsIsFavorited:self.news])
            self.navigationItem.rightBarButtonItem.title = @"已收藏";
        
    } onFail:^(NSError *error) {
        [self->_refreshActivityIndicator stopAnimating];
        [MessageBox showWithMessage:[error localizedDescription] buttonTitle:@"重试" handler:^{
            [self fetchNewsContent];
        }];
    }];
}

#pragma mark - 收藏或取消收藏

- (void)favoriteNews
{
    [[TMCache sharedCache] objectForKey:kNewsCacheKey block:^(TMCache *cache, NSString *key, id object) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSMutableArray *array = object;
            if(array)
            {
                // 如果新闻存在于已收藏的新闻集合中，就执行取消收藏的操作
                if([self theNewsIsFavorited:self.news])
                {
                    for(News *n in array)
                    {
                        if([n.contentUrl.absoluteString isEqualToString:self.news.contentUrl.absoluteString])
                        {
                            [array removeObject:n];
                            self.navigationItem.rightBarButtonItem.title = @"收藏";
                            break;
                        }
                    }
                }
                else
                {
                    [array insertObject:self.news atIndex:0];
                    self.navigationItem.rightBarButtonItem.title = @"已收藏";
                }
                
            }
            else
            {
                array = [NSMutableArray new];
                [array insertObject:self.news atIndex:0];
                self.navigationItem.rightBarButtonItem.title = @"已收藏";
            }
            
            [[TMCache sharedCache] setObject:array forKey:kNewsCacheKey];
        });
    }];
}

- (BOOL)theNewsIsFavorited:(News *)news
{
    NSArray *array = [[TMCache sharedCache] objectForKey:kNewsCacheKey];
    for(News *n in array)
        if([n.contentUrl.absoluteString isEqualToString:news.contentUrl.absoluteString])
            return YES;

    return NO;
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DocType type = [DocTypeDetector dectectWithURL:request.URL];
    switch(type)
    {
        case DocTypeDoc:
        case DocTypeXls:
        case DocTypeTxt:
        {
            DocViewerVC *vc = [[DocViewerVC alloc] initWithDocType:type docURL:request.URL];
            [self.navigationController pushViewController:vc animated:YES];
            
            [self->_refreshActivityIndicator stopAnimating];
            return NO;
        }
         
        case DocTypeHTML:  // 不允许打开网站，是因为网页含有多个链接，会导致递归打开，导致程序崩溃.
        case DocTypePPT:
        case DocTypeZip:
        {
           // NSString *dtName = [DocTypeDetector docTypeName:type];
      
            [self->_refreshActivityIndicator stopAnimating];
            return NO;
        }
            
        case DocTypeNewsContent:
            return YES;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(self.news.content)
    {
        [self->_refreshActivityIndicator startAnimating];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self->_refreshActivityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self->_refreshActivityIndicator stopAnimating];
}

@end
