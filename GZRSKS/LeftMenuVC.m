//
//  LeftMenuVC.m
//  GZRSKS
//
//  Created by lihong on 14-6-12.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "LeftMenuVC.h"
#import "NewsGroupListViewController.h"
#import "FavoriteNewsVC.h"
#import "SubNavigationController.h"
#import "RESideMenu.h"
#import "Config.h"

static UIWindow *nightModelWindow;

@interface LeftMenuVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISwitch *nightModeSwitch;

@end

@implementation LeftMenuVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!nightModelWindow)
    {
        nightModelWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        nightModelWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        nightModelWindow.windowLevel = UIWindowLevelStatusBar+1;
        nightModelWindow.userInteractionEnabled = NO;
    }
    
    // 这部分语句要放到nightModelWindow初始化的后面
    [self.nightModeSwitch setOn:[[Config shared] getNightModal] animated:YES];
    [self openNightModal:self.nightModeSwitch];
}

// 开启或关闭夜间模式
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

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = nil;
    switch(indexPath.row)
    {
        case 0:
            vc = [[NewsGroupListViewController alloc] initWithStyle:UITableViewStylePlain];
            break;
            
        case 1:
            vc = [[FavoriteNewsVC alloc] initWithNibName:@"FavoriteNewsVC" bundle:nil];
            break;
            
        default:break;
    }
    
    if(vc)
    {
        SubNavigationController *nav = [[SubNavigationController alloc] initWithRootViewController:vc];
        [self.sideMenuViewController setContentViewController:nav];
    }
    [self.sideMenuViewController hideMenuViewController];
    
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSArray *titles = @[@"招考信息", @"我的收藏", @"设置"];
    NSArray *images = @[@"IconHome", @"IconCalendar",@"IconSettings"];
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    
    return cell;
}

@end
