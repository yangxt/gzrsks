//
//  AdVC.m
//  GZRSKS
//
//  Created by lihong on 14-6-12.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "AdVC.h"
#import "SubNavigationController.h"
#import "NewsGroupListViewController.h"
#import "RESideMenu.h"
#import "LeftMenuVC.h"
#import "FBShimmeringView.h"

@interface AdVC ()

@end

@implementation AdVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(0, self.view.bounds.size.height -350.0, 320, 44);
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:rect];
    [self.view addSubview:shimmeringView];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:rect];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"考累了吗？用“减压神器”找回快乐!";
    shimmeringView.contentView = loadingLabel;
    shimmeringView.shimmeringPauseDuration = 0.6;
    shimmeringView.shimmering = YES;
    
    rect.size.height *= 4;
    UIButton *button = [[UIButton alloc] initWithFrame:rect];
    [button addTarget:self action:@selector(getApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self dismissViewControllerAnimated:YES completion:NULL];
    });
}

- (void)getApp 
{
     NSString *urlStr = @"https://itunes.apple.com/cn/app/shou-ji-hao-ma-jiao-you/id645812747?mt=8";
     NSURL *url = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
