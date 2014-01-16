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
#import "UMSocial.h"

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
    if (self) {
        self.news = news;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 导航栏右边按钮
    self->_favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_favoriteButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_favoriteButton setTitle:@"收藏" forState:UIControlStateNormal];
    [self->_favoriteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_favoriteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self->_favoriteButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self->_favoriteButton addTarget:self action:@selector(favoriteNewsOperation) forControlEvents:UIControlEventTouchUpInside];
    
    self->_refreshActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self->_refreshActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self->_refreshActivityIndicator.hidesWhenStopped = YES;
    
    NSArray *rightItems = @[[[UIBarButtonItem alloc] initWithCustomView:self->_favoriteButton],
                            [[UIBarButtonItem alloc] initWithCustomView:self->_refreshActivityIndicator]];
    self.navigationItem.rightBarButtonItems = rightItems;
    
    [self->_favoriteButton setEnabled:NO];
    [self refreshNewsContent];

}

// 获取新闻内容
- (void)refreshNewsContent
{
    [self->_refreshActivityIndicator startAnimating];

    if(self.news.content)
    {
        [self->_favoriteButton setEnabled:YES];
        [self.webView loadHTMLString:self.news.content baseURL:nil];
        
        if([self theNewsIsFavorited:self.news])
            [self->_favoriteButton setTitle:@"取消" forState:UIControlStateNormal];
        
        return;
    }
    
    [[NewsProvider sharedInstance] fetchNewsContentWithURL:self.news.contentUrl onCompleted:^(NSString *content) {
        
        [self->_favoriteButton setEnabled:YES];
        [self.news setContent:content];
        [self.webView loadHTMLString:content baseURL:nil];
        
        if([self theNewsIsFavorited:self.news])
            [self->_favoriteButton setTitle:@"取消" forState:UIControlStateNormal];

        
    } onFail:^(NSError *error) {
        [self->_refreshActivityIndicator stopAnimating];
        
        NSString *desc = @"网络链接断开或过慢";
        if([error.domain isEqualToString:kNetAPIErorDomain])
            desc = @"很抱歉，出错啦。请告知我(QQ:410139419)必将尽快修复!";
        [MessageBox showWithMessage:desc buttonTitle:@"重试" handler:^{
            [self refreshNewsContent];
        }];
    }];
}

#pragma mark - 收藏或取消收藏

- (void)favoriteNewsOperation
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
                            [self->_favoriteButton setTitle:@"收藏" forState:UIControlStateNormal];
                            break;
                        }
                    }
                }else{
                    [array insertObject:self.news atIndex:0];
                    [self->_favoriteButton setTitle:@"取消" forState:UIControlStateNormal];
                }
                
            }else{
                array = [NSMutableArray new];
                [array insertObject:self.news atIndex:0];
                [self->_favoriteButton setTitle:@"取消" forState:UIControlStateNormal];
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
        case DocTypeHTML:
        case DocTypeDoc:
        case DocTypeXls:
        case DocTypeTxt:
        {
            DocViewerVC *vc = [[DocViewerVC alloc] initWithDocType:type docURL:request.URL];
            [self.navigationController pushViewController:vc animated:YES];
            
            [self->_refreshActivityIndicator stopAnimating];
            return NO;
        }
            
        case DocTypePPT:
        case DocTypeZip:
        {
            NSString *dtName = [DocTypeDetector docTypeName:type];
            NSString *msg = [NSString stringWithFormat:@"不能打开%@! 可外发到邮箱、微博、QQ空间等,稍候在电脑上打开.",dtName];
            [MessageBox showWithMessage:msg buttonTitle:@"外发" handler:^{
            
                NSString *msg = [NSString stringWithFormat:@"来自 %@ 的附件: %@",kAppDownloadAddress,request.URL.absoluteString];
                NSArray *snsNames = @[UMShareToQzone,UMShareToSina,UMShareToTencent,UMShareToSms,UMShareToEmail,UMShareToRenren,UMShareToDouban];
                [UMSocialSnsService presentSnsIconSheetView:self appKey:UMAppKey shareText:msg shareImage:nil shareToSnsNames:snsNames delegate:nil];
                
            }];
            
            [self->_refreshActivityIndicator stopAnimating];
            return NO;
        }
            
        case DocTypeUnkonw:
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
