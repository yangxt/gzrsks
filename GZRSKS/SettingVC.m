//
//  SettingVC.m
//  GZRSKS
//
//  Created by lihong on 14-6-10.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "SettingVC.h"
#import "Config.h"

static UIWindow *nightModelWindow;

// 设置
@interface SettingVC ()
@end

@implementation SettingVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"设置";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(!nightModelWindow)
    {
        nightModelWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        nightModelWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        nightModelWindow.windowLevel = UIWindowLevelAlert-0.01;
        nightModelWindow.userInteractionEnabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 开启活关闭夜间模式
- (IBAction)openNightModal:(UISwitch *)sender
{
    [[Config shared] setNightModal:sender.on];
    
    if(sender.on)
    {
        [nightModelWindow makeKeyAndVisible];
    }
    else
    {
        nightModelWindow.hidden = YES;
        [self.view.window  becomeKeyWindow];
    }
}

@end
