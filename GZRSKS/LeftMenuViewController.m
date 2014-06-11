//
//  DEMOMenuViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "NewsGroupListViewController.h"
#import "FavoriteNewsVC.h"
#import "AboutUsVC.h"
#import "SettingVC.h"
#import "SubNavigationController.h"

@interface LeftMenuViewController ()

@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 54 * 5) / 2.0f, self.view.frame.size.width, 54 * 5) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
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
            
        case 2:
            vc = [[AboutUsVC alloc] initWithNibName:@"AboutUsVC" bundle:nil];
            break;
            
        case 3:
            vc = [[SettingVC alloc] initWithNibName:@"SettingVC" bundle:nil];
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
    return 4;
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
    
    NSArray *titles = @[@"招考信息", @"我的收藏", @"关于我们",@"设置"];
    NSArray *images = @[@"IconHome", @"IconCalendar", @"IconProfile",@"IconSettings"];
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    
    return cell;
}


@end
