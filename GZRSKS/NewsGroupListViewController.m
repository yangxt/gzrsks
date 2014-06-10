//
//  NewsGroupListViewController.m
//  GZRSKS
//
//  Created by lihong on 14-6-10.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "NewsGroupListViewController.h"
#import "News.h"
#import "NewsGroup.h"
#import "NewsProvider.h"
#import "HaveReadNews.h"
#import "NewsContentVC.h"
#import "NewsGroupListHeaderView.h"
#import "RESideMenu.h"

@interface NewsGroupListViewController ()
@property (nonatomic, strong) UIButton *loadMoreButton;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
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
    
    self.tableView.rowHeight = 75.0;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    // 左边
    UIImage *image = [UIImage imageNamed:@"SideMenu"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(openSideMenu)];
    self.navigationItem.leftBarButtonItem = item;
    
    // 右边
    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(goBackToTop)];
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
    
    // 刷新控件
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshNewsGroupList) forControlEvents:UIControlEventValueChanged];
    
    // 开始刷新
    [self.refreshControl beginRefreshing];
    [self refreshNewsGroupList];
}

// 打开侧边栏
- (void)openSideMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

// 分享App给朋友
- (void)goBackToTop
{
    [self.tableView setContentOffset:CGPointZero animated:YES];
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

@end
