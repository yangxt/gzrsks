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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

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
    
    CGRect rect = CGRectMake(0, self.view.bounds.size.height -200.0, 320, 44);
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
    
    NSString *imageName = nil;
    CGRect bound = [[UIScreen mainScreen] bounds];
    if(bound.size.height == 568.0)         imageName = @"ad3.png";
    else
    if([UIScreen mainScreen].scale == 2) imageName = @"ad1.png";
    else imageName = @"ad0.png";
            
    UIImage *image = [UIImage imageNamed:imageName];
    self.imageView.image = image;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NewsGroupListViewController *vc1 =
        [[NewsGroupListViewController alloc] initWithStyle:UITableViewStylePlain];
        SubNavigationController *nav = [[SubNavigationController alloc] initWithRootViewController:vc1];
        LeftMenuVC *leftVC = [[LeftMenuVC alloc] initWithNibName:@"LeftMenuVC" bundle:nil];
        
        RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:nav leftMenuViewController:leftVC rightMenuViewController:nil];
        sideMenuViewController.backgroundImage = [UIImage imageNamed:@"Dandelion"];
        sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
        sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
        sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
        sideMenuViewController.contentViewShadowOpacity = 0.6;
        sideMenuViewController.contentViewShadowRadius = 12;
        sideMenuViewController.contentViewShadowEnabled = YES;
        
        self.view.window.rootViewController = sideMenuViewController;
    });
}

- (void)getApp //15685138058
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
