//
//  AppDelegate.m
//  ExamInfo
//
//  Created by LiHong on 13-12-17.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import "Config.h"
#import "AppDelegate.h"
#import "NewsGroupListViewController.h"
#import "FavoriteNewsVC.h"
#import "MessageBox.h"
#import "RESideMenu.h"
#import "LeftMenuVC.h"
#import "SubNavigationController.h"
#import "AdVC.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configAppAppearance];
    
    AdVC *advc = [[AdVC alloc] initWithNibName:@"AdVC" bundle:nil];
    self.appWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.appWindow.rootViewController = advc;
    [self.appWindow makeKeyAndVisible];
    
    return YES;
}

- (void)configAppAppearance
{
    //http://beyondvincent.com/blog/2013/11/03/120-customize-navigation-status-bar-ios-7/
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIImage *navigationBarImage = [UIImage imageNamed:@"NavigationBar_iOS7"];
    navigationBarImage = [navigationBarImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 3, 3, 3)];
    [[UINavigationBar appearance] setBackgroundImage:navigationBarImage forBarMetrics:UIBarMetricsDefault];
    //NSFontAttributeName
    NSMutableDictionary *dict =
    [NSMutableDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [[UITabBarItem appearance] setTitleTextAttributes:dict forState:UIControlStateNormal];
    
    [dict setValue:[UIFont systemFontOfSize:20.0] forKeyPath:NSFontAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:dict];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UITabBar appearance] setBackgroundImage:navigationBarImage];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
}
@end
