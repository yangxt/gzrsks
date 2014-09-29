//
//  ContactUsController.m
//  GZRSKS
//
//  Created by lihong on 14-9-26.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "ContactUsController.h"
#import "RESideMenu.h"

 static NSString *const kUrl = @"http://rsks.qiniudn.com/AboutUs.html";

@interface ContactUsController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *loadingIndiatorView;
@property (weak, nonatomic) IBOutlet UIView *loadingFailView;
@property (weak, nonatomic) IBOutlet UILabel *loadingFailInfoLabel;

@end

@implementation ContactUsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"联系我们";
    
    // 左边
    UIImage *image = [UIImage imageNamed:@"SideMenu"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(openSideMenu)];
    self.navigationItem.leftBarButtonItem = item;
    
    [self loadRemoteHtmlPage];
}

- (void)loadRemoteHtmlPage
{
    self.loadingFailView.hidden = YES;
    self.loadingIndiatorView.hidden = NO;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?t=%f",kUrl,[NSDate timeIntervalSinceReferenceDate]];
    NSURL *url = [NSURL URLWithString:urlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

// 打开侧边栏
- (void)openSideMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
