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

NSString *const kNewsCacheKey = @"NewsCacheKey";

extern NSString  *const kNetAPIErorDomain;
extern NSInteger const kNetAPIErrorCode;
extern NSString  *const kNetAPIErrorDesc;

@interface NewsContentVC ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong,nonatomic) News *news;
@end

@implementation NewsContentVC

- (id)initWithNews:(News *)news
{
    self = [super initWithNibName:@"NewsContentVC" bundle:nil];
    if (self) {
        self.news = news;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // 导航栏右边按钮
    self->_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_refreshButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
    [self->_refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_refreshButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self->_refreshButton addTarget:self action:@selector(refreshNewsContent) forControlEvents:UIControlEventTouchUpInside];
    
    self->_favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_favoriteButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_favoriteButton setEnabled:NO];
    [self->_favoriteButton setTitle:@"收藏" forState:UIControlStateNormal];
    [self->_favoriteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_favoriteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self->_favoriteButton addTarget:self action:@selector(addThisNewsToMyFavorite) forControlEvents:UIControlEventTouchUpInside];
    
    self->_refreshActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self->_refreshActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self->_refreshActivityIndicator.hidesWhenStopped = YES;
    
    NSArray *rightItems = @[[[UIBarButtonItem alloc] initWithCustomView:self->_favoriteButton],
                            [[UIBarButtonItem alloc] initWithCustomView:self->_refreshButton],
                            [[UIBarButtonItem alloc] initWithCustomView:self->_refreshActivityIndicator]];
    self.navigationItem.rightBarButtonItems = rightItems;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshNewsContent];
}

// 获取新闻内容
- (void)refreshNewsContent
{
    [self->_refreshButton setEnabled:NO];
    [self->_refreshActivityIndicator startAnimating];
    
    if(self.news.content)
    {
        [self->_favoriteButton setEnabled:YES];
        [self.webView loadHTMLString:self.news.content baseURL:nil];
        return;
    }
    
    [[NewsProvider sharedInstance] fetchNewsContentWithURL:self.news.contentUrl onCompleted:^(NSString *content) {
        
        [self->_favoriteButton setEnabled:YES];
        [self.news setContent:content];
        [self->_refreshButton setEnabled:YES];
        [self.webView loadHTMLString:content baseURL:nil];
        
    } onFail:^(NSError *error) {
        [self->_refreshButton setEnabled:NO];
        [self->_refreshActivityIndicator stopAnimating];
        
        NSString *desc = @"网络链接断开或过慢";
        if([error.domain isEqualToString:kNetAPIErorDomain])
            desc = @"很抱歉，出错啦。请告知我(QQ:410139419)必将尽快修复!";
        [MessageBox showWithMessage:desc handler:^{
            [self refreshNewsContent];
        }];
    }];
}

// 收藏
- (void)addThisNewsToMyFavorite
{
   [[TMCache sharedCache] objectForKey:kNewsCacheKey block:^(TMCache *cache, NSString *key, id object) {
       NSDictionary *dict = object;
       if(!dict)
           dict = [NSMutableDictionary new];
       [dict setValue:self.news forKey:self.news.contentUrl.absoluteString];
       
       [[TMCache sharedCache] setObject:dict forKey:kNewsCacheKey block:^(TMCache *cache, NSString *key, id object) {
           NSLog(@"收藏成功");
       }];
    }];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(self.news.content)
    {
        [self->_refreshButton setEnabled:NO];
        [self->_refreshActivityIndicator startAnimating];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self->_refreshButton setEnabled:YES];
    [self->_refreshActivityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self->_refreshButton setEnabled:YES];
    [self->_refreshActivityIndicator stopAnimating];
}
@end
