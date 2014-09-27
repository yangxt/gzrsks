//
//  NewsGroupListViewController.m
//  GZRSKS
//
//  Created by lihong on 14-6-10.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "News.h"
#import "NewsGroup.h"
#import "AdManager.h"
#import "AdDetailVC.h"
#import "RESideMenu.h"
#import "AdScrollView.h"
#import "HaveReadNews.h"
#import "NewsProvider.h"
#import <objc/message.h>
#import "NewsContentVC.h"
#import "TWMessageBarManager.h"
#import "NewsGroupListHeaderView.h"
#import "NewsGroupListViewController.h"

@interface NewsGroupListViewController ()
@property (nonatomic, strong) UIButton *loadMoreButton;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) AdScrollView *adScrollView;
@property (nonatomic, assign) NSTimeInterval lastRefreshTime;
@end

@implementation NewsGroupListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"招考信息";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lastRefreshTime = [NSDate timeIntervalSinceReferenceDate];
    
    self.tableView.rowHeight = 80.0;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseUIApplicationNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 侧边栏按钮
    UIImage *image = [UIImage imageNamed:@"SideMenu"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(openSideMenu)];
    self.navigationItem.leftBarButtonItem = item;
    
    // 搜索按钮
    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(pushSearchController)];
    self.navigationItem.rightBarButtonItem = item;
    
    // 加载更多按钮
    _loadMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320.0, 44.0)];
    [_loadMoreButton setTitle:@"查看更多招考信息" forState:UIControlStateNormal];
    [_loadMoreButton setTitle:@"正在加载，请稍后.." forState:UIControlStateDisabled];
    [_loadMoreButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_loadMoreButton setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    [_loadMoreButton addTarget:self action:@selector(loadMorNews) forControlEvents:UIControlEventTouchUpInside];
    [_loadMoreButton setBackgroundColor:[UIColor clearColor]];
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_indicator setFrame:CGRectMake(44, 0, 44, 44)];
    [_indicator setHidesWhenStopped:YES];
    UIView *footer = [[UIView alloc] initWithFrame:_loadMoreButton.bounds];
    [footer setBackgroundColor:[UIColor clearColor]];
    [footer addSubview:_indicator];
    [footer addSubview:_loadMoreButton];
    self.tableView.tableFooterView = footer;
    [self.tableView.tableFooterView setHidden:YES];
    
    [self requestAdData];

    // 刷新控件
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshNewsGroupList) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [self refreshNewsGroupList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIDeviceOrientationPortrait);
}

#define HalfHour (60 * 30)

- (void)responseUIApplicationNotification:(NSNotification *)notification
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (abs(now - self.lastRefreshTime) > HalfHour) {
        [self requestAdData];
        [self.refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self refreshNewsGroupList];
    }
}

- (void)requestAdData
{
    CGRect frame = self.tableView.bounds;
    frame.size.height = 60.0;
    self.adScrollView = [[AdScrollView alloc] initWithFrame:frame];
    [self.adScrollView addTarget:self action:@selector(toucheOnAdScrollView:) forControlEvents:UIControlEventTouchUpInside];
    
    [AdManager requestAdData:^(AdConfig *adConfig) {
        [self.adScrollView setDataSource:adConfig.homeAdEntityArray];
        self.tableView.tableHeaderView = self.adScrollView;
    }];
}

// 点击广告.TODO:加入统计
- (void)toucheOnAdScrollView:(AdScrollView *)adScrollView
{
    Ad *ad = [[AdManager getAdConfig].homeAdEntityArray objectAtIndex:adScrollView.pageIndex];
    AdDetailVC *vc = [[AdDetailVC alloc] initWithAd:ad];
    [self.navigationController pushViewController:vc animated:YES];
}

// 打开侧边栏
- (void)openSideMenu
{
    [self.refreshControl beginRefreshing];
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)pushSearchController
{
    //UISearchDisplayController *vc = [[UISearchDisplayController alloc] ini]
}

// 刷新列表
- (void)refreshNewsGroupList
{
    [[NewsProvider shared] fetchNewsWithRefreshFlag:YES OnCompletedHandler:^{
        [self.tableView.tableFooterView setHidden:NO];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    } onFail:^(NSError *error) {
        [self.refreshControl endRefreshing];
        [TWMessageBarManager showInfoMessage:@"刷新失败" description:error.localizedDescription];
    }];;
}

// 加载更多
- (void)loadMorNews
{
    [_loadMoreButton setEnabled:NO];
    [_indicator startAnimating];
    
    [[NewsProvider shared] fetchNewsWithRefreshFlag:NO OnCompletedHandler:^{
        [_loadMoreButton setEnabled:YES];
        [_indicator stopAnimating];
        [self.tableView reloadData];
        
    } onFail:^(NSError *error) {
        [_loadMoreButton setEnabled:YES];
        [_indicator stopAnimating];
        [TWMessageBarManager showInfoMessage:@"加载失败" description:error.localizedDescription ];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[NewsProvider shared] newsGroupCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NewsGroup *newsGroup = [[NewsProvider shared] getNewsGroupByIndex:section];
    return newsGroup.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CID"];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CID"];
        cell.backgroundColor = tableView.backgroundColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        cell.accessoryView.layer.cornerRadius = 5;
    }
    
    NewsGroup *newsGroup = [[NewsProvider shared] getNewsGroupByIndex:indexPath.section];
    News *news = newsGroup.newsArray[indexPath.row];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = news.title;
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textColor = [HaveReadNews isRead:news] ? [UIColor lightGrayColor] : [UIColor blackColor];
    cell.accessoryView.backgroundColor = [news.titleColor colorWithAlphaComponent:0.5];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NewsGroup *newsGroup = [[NewsProvider shared] getNewsGroupByIndex:section];
    CGRect newRect = CGRectMake(0, 0, 320, 40.0);
    return [[NewsGroupListHeaderView alloc] initWithFrame:newRect andNewsGroup:newsGroup];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return  40.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NewsGroup *newsGroup = [[NewsProvider shared] getNewsGroupByIndex:indexPath.section];
    News *news = newsGroup.newsArray[indexPath.row];
    
    [HaveReadNews markAsReaded:news];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    
    NewsContentVC *vc = [[NewsContentVC alloc] initWithNews:news];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIDeviceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}
@end
