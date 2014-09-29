//
//  AdDetailVC.m
//  GZRSKS
//
//  Created by lihong on 14-9-27.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "AdDetailVC.h"

@interface AdDetailVC ()<UIWebViewDelegate>
@property (strong, nonatomic) Ad *adEntity;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *loadingIndiatorView;
@property (weak, nonatomic) IBOutlet UIView *loadingFailView;
@property (weak, nonatomic) IBOutlet UILabel *loadingFailInfoLabel;
@end

@implementation AdDetailVC

- (instancetype)initWithAd:(Ad *)ad
{
    if (self = [super initWithNibName:@"AdDetailVC" bundle:nil]) {
        self.adEntity = ad;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"推广";
    [self loadRemoteHtmlPage];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRemoteHtmlPage
{
    self.loadingFailView.hidden = YES;
    self.loadingIndiatorView.hidden = NO;
    
    NSURL *url = [NSURL URLWithString:self.adEntity.adDetailUrl];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loadingIndiatorView.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.loadingFailView.hidden = YES;
    self.loadingIndiatorView.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.loadingFailView.hidden = NO;
    self.loadingIndiatorView.hidden = YES;
    self.loadingFailInfoLabel.text = [NSString stringWithFormat:@"点击屏幕重新加载\n\n%@",    [error localizedDescription]];
}

- (IBAction)tapOnLoadingFailView:(UITapGestureRecognizer *)sender
{
    [self loadRemoteHtmlPage];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
