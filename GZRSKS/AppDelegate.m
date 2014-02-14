//
//  AppDelegate.m
//  ExamInfo
//
//  Created by LiHong on 13-12-17.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import "Config.h"
#import "AppDelegate.h"
#import "NewsGroupListVC.h"
#import "UMSocial.h"
#import "MobClick.h"
#import "MessageBox.h"
#import "Crackify.h"

NSString *const UMAppKey = @"51451fe556240b6e59008ee2";
NSString *const kAppDownloadAddress = @"https://itunes.apple.com/cn/app/gui-zhou-ren-shi-kao-shi/id622339104?mt=8";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if !(TARGET_IPHONE_SIMULATOR)
    [UMSocialData setAppKey:UMAppKey];
    [MobClick startWithAppkey:UMAppKey];
    [MobClick checkUpdate];
    
    // 远程关闭应用
    [MobClick updateOnlineConfig];
    NSString *kRC = [[MobClick getConfigParams] objectForKey:@"KRC"];
    if([kRC isEqualToString:@"ON"]){
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"提示" message:@"出问题啦!联系QQ:410139419" delegate:self cancelButtonTitle:@"退出程序" otherButtonTitles:nil];
        alert.tag = 444;
        [alert show];
    }
    
    if([MobClick isPirated] || [MobClick isJailbroken] || [Crackify isJailbroken] || [Crackify isCracked]){
        NSString *msg = @"你正在使用破解或越狱版本!\n无法保证招考信息的真实性!!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"安全警告!!!" message:msg delegate:self cancelButtonTitle:@"获取正版软件" otherButtonTitles:nil];
        [alert show];
    }
    
#endif
    
    NewsGroupListVC *newsGoupListVC = [[NewsGroupListVC alloc] init];
    
    self.appWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.appWindow.rootViewController = [[UINavigationController alloc] initWithRootViewController:newsGoupListVC];
    [self.appWindow makeKeyAndVisible];
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 444){
        exit(EXIT_FAILURE);
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppDownloadAddress]];
    exit(EXIT_FAILURE);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
