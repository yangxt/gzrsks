//
//  BaseController.m
//  GZRSKS
//
//  Created by lihong on 14-6-10.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "BaseController.h"
#import "RESideMenu.h"


@interface BaseController ()

@end

@implementation BaseController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"SideMenu"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(openSideMenu)];
    self.navigationItem.leftBarButtonItem = item;
}

// 打开侧边栏
- (void)openSideMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}


@end
