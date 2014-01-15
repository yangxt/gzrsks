//
//  NewsListVC.m
//  ExamInfo
//
//  Created by LiHong on 13-12-17.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import "News.h"
#import "Config.h"
#import "UIScreen+Size.h"
#import "NewsGroupListVC.h"
#import "NewsGroupListHeaderView.h"
#import "NewsContentVC.h"
#import "MessageBox.h"
#import "UMSocial.h"

extern NSString  *const UMAppKey;
extern NSString  *const kNetAPIErorDomain;
extern NSString  *const kNetAPIErrorDesc;
extern NSInteger const kNetAPIErrorCode;

static const CGFloat kNewsGroupTableViewHeaderViewHeight = 35.0;
static NSString *const kNewsListCellReuseableIdentifier = @"NewsListCellReuseableIdentifier";

@interface NewsGroupListVC()
@property (weak, nonatomic) IBOutlet UITableView *newsGroupListView;
@end

@implementation NewsGroupListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 每次程序从后台切换到前台时重新刷新列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewsList) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 导航栏左边按钮
    self->_themeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_themeButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_themeButton setTitle:@"白天" forState:UIControlStateNormal];
    [self->_themeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_themeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self->_themeButton addTarget:self action:@selector(changeTheme) forControlEvents:UIControlEventTouchUpInside];
    
    self->_favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_favoriteButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_favoriteButton setTitle:@"私货" forState:UIControlStateNormal];
    [self->_favoriteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_favoriteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self->_favoriteButton addTarget:self action:@selector(myFavoriteNews) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *leftItems = @[[[UIBarButtonItem alloc] initWithCustomView:self->_favoriteButton],
                           [[UIBarButtonItem alloc] initWithCustomView:self->_themeButton]];
    [self.navigationItem setLeftBarButtonItems:leftItems];
    
    
    // 导航栏右边按钮
    self->_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_refreshButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
    [self->_refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_refreshButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self->_refreshButton addTarget:self action:@selector(refreshNewsList) forControlEvents:UIControlEventTouchUpInside];
    
    self->_shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_shareButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [self->_shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_shareButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self->_shareButton addTarget:self action:@selector(shareThisAppToFriends) forControlEvents:UIControlEventTouchUpInside];
    
    self->_refreshActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self->_refreshActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self->_refreshActivityIndicator.hidesWhenStopped = YES;

    NSArray *rightItems = @[[[UIBarButtonItem alloc] initWithCustomView:self->_shareButton],
                            [[UIBarButtonItem alloc] initWithCustomView:self->_refreshButton],
                            [[UIBarButtonItem alloc] initWithCustomView:self->_refreshActivityIndicator]];
    [self.navigationItem setRightBarButtonItems:rightItems];
    
    
    // 载入更多UI
    self->_loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self->_loadMoreButton.frame = CGRectMake(0, 0, 320, 50);
    [self->_loadMoreButton setTitle:@"查看更多" forState:UIControlStateNormal];
    [self->_loadMoreButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self->_loadMoreButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self->_loadMoreButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self->_loadMoreButton addTarget:self action:@selector(loadMoreNews) forControlEvents:UIControlEventTouchUpInside];
    
    self->_loadMoreActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(70, 0, 60, 50)];
    self->_loadMoreActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self->_loadMoreActivityIndicator.hidesWhenStopped = YES;
    
    UIView *view = [[UIView alloc] initWithFrame:self->_loadMoreButton.bounds];
    [view addSubview:self->_loadMoreButton];
    [view addSubview:self->_loadMoreActivityIndicator];
    
    self.newsGroupListView.tableFooterView = view;
    self.newsGroupListView.tableFooterView.hidden = YES;
    
    [self.newsGroupListView registerClass:[UITableViewCell class] forCellReuseIdentifier:kNewsListCellReuseableIdentifier];
}

// 接收到内存警告后重新刷新列表，刷新列表的操作会释放掉之前所有的News对象
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self->_fetchNewsTask cancel];
    [self refreshNewsList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([NewsProvider sharedInstance].newsGroupCount == 0)
        [self refreshNewsList];
}

#pragma mark - 刷新、加载更多

// 刷新考信息
- (void)refreshNewsList
{
    [self->_refreshButton setEnabled:NO];
    [self->_refreshActivityIndicator startAnimating];
    
    self->_fetchNewsTask =
    [[NewsProvider sharedInstance] fetchNewsWithRefreshFlag:YES OnCompletedHandler:^{
        
        [self.newsGroupListView reloadData];
        [self.newsGroupListView.tableFooterView setHidden:NO];
        [self.newsGroupListView setContentOffset:CGPointMake(0, -60) animated:YES];
        [self->_refreshActivityIndicator stopAnimating];
        [self->_refreshButton setEnabled:YES];

    } onFail:^(NSError *error) {
        [self->_refreshActivityIndicator stopAnimating];
        [self->_refreshButton setEnabled:YES];
        
        NSString *desc = @"网络链接断开或过慢";
        if([error.domain isEqualToString:kNetAPIErorDomain])
            desc = @"很抱歉，出错啦。请告知我(QQ:410139419)必将尽快修复!";
        [MessageBox showWithMessage:desc handler:^{
            [self refreshNewsList];
        }];
    }];

}

// 加载更多考试信息
- (void)loadMoreNews
{
    [self->_loadMoreActivityIndicator startAnimating];
    [self->_loadMoreButton setTitle:@"正在载入..." forState:UIControlStateNormal];
    [self->_loadMoreButton setEnabled:NO];
    
    self->_fetchNewsTask =
    [[NewsProvider sharedInstance] fetchNewsWithRefreshFlag:NO OnCompletedHandler:^{
        
        [self.newsGroupListView reloadData];
        [self->_loadMoreActivityIndicator stopAnimating];
        [self->_loadMoreButton setTitle:@"查看更多" forState:UIControlStateNormal];
        [self->_loadMoreButton setEnabled:YES];
        
    } onFail:^(NSError *error) {
        [self->_loadMoreActivityIndicator stopAnimating];
        [self->_loadMoreButton setTitle:@"网络链接断开或过慢，请重试." forState:UIControlStateNormal];
        [self->_loadMoreButton setEnabled:YES];
    }];
}

#pragma mark - 收藏,分享
- (void)myFavoriteNews
{
    
}

- (void)shareThisAppToFriends
{
    NSArray *snsNames = @[UMShareToQQ,UMShareToQzone,UMShareToWechatTimeline,UMShareToWechatSession,UMShareToSina,UMShareToTencent,UMShareToSms,UMShareToEmail];
    [UMSocialSnsService presentSnsIconSheetView:self appKey:UMAppKey shareText:@"s" shareImage:nil shareToSnsNames:snsNames delegate:nil];
}

#pragma mark - 调节屏幕亮度
- (void)changeTheme
{
    static BOOL isNight = NO;
    isNight = !isNight;
    [self->_themeButton setTitle:isNight?@"夜晚":@"白天" forState:UIControlStateNormal];
    [[UIScreen mainScreen] setBrightness:isNight?0.05:0.8];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[NewsProvider sharedInstance] newsGroupCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NewsGroup *newsGroup = [[NewsProvider sharedInstance] getNewsGroupByIndex:section];
    return newsGroup.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewsListCellReuseableIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NewsGroup *newsGroup = [[NewsProvider sharedInstance] getNewsGroupByIndex:indexPath.section];
    News *news = newsGroup.newsGroup[indexPath.row];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = news.title;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor blackColor];
    
    if(!cell.accessoryView)
    {
        cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        cell.accessoryView.layer.cornerRadius = 5;
    }
    cell.accessoryView.backgroundColor = [news.titleColor colorWithAlphaComponent:0.5];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NewsGroup *newsGroup = [[NewsProvider sharedInstance] getNewsGroupByIndex:section];
    CGRect newRect = CGRectMake(0, 0, 320, kNewsGroupTableViewHeaderViewHeight);
    return [[NewsGroupListHeaderView alloc] initWithFrame:newRect andNewsGroup:newsGroup];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kNewsGroupTableViewHeaderViewHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NewsGroup *newsGroup = [[NewsProvider sharedInstance] getNewsGroupByIndex:indexPath.section];
    News *news = newsGroup.newsGroup[indexPath.row];
    NewsContentVC *vc = [[NewsContentVC alloc] initWithNews:news];
    
    [self.navigationController pushViewController:vc animated:YES];
}
@end
