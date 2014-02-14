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
#import "FavoriteNewsVC.h"
#import "PopoverView.h"
#import "UMFeedback.h"
#import "HaveReadNews.h"

extern NSString  *const UMAppKey;
extern NSString  *const kNetAPIErorDomain;
extern NSString  *const kNetAPIErrorDesc;
extern NSInteger const kNetAPIErrorCode;
extern NSString *kAppDownloadAddress;

static const CGFloat kNewsGroupTableViewHeaderViewHeight = 35.0;
static NSString *const kNewsListCellReuseableIdentifier = @"NewsListCellReuseableIdentifier";
static NSString *const kAutoRefreshNewsInterval = @"AutoRefreshNewsInteral";

@interface NewsGroupListVC()
@property (weak, nonatomic) IBOutlet UITableView *newsGroupListView;
@property (strong, nonatomic) IBOutlet UIView *changeBrightnessView;
@property (weak, nonatomic) IBOutlet UISlider *changeBrightnessSlider;

@end

@implementation NewsGroupListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hanleApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // 导航栏左边按钮
    self->_brightnessButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_brightnessButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_brightnessButton setTitle:@"亮度" forState:UIControlStateNormal];
    [self->_brightnessButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_brightnessButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self->_brightnessButton addTarget:self action:@selector(popupChangeBrightnessView:) forControlEvents:UIControlEventTouchUpInside];
    
    self->_feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_feedbackButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_feedbackButton setTitle:@"反馈" forState:UIControlStateNormal];
    [self->_feedbackButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_feedbackButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self->_feedbackButton addTarget:self action:@selector(presentFeedbackVC) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *leftItems = @[[[UIBarButtonItem alloc] initWithCustomView:self->_brightnessButton],
                           [[UIBarButtonItem alloc] initWithCustomView:self->_feedbackButton]];
    [self.navigationItem setLeftBarButtonItems:leftItems];
    
    
    // 导航栏右边按钮
    self->_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_refreshButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
    [self->_refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_refreshButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self->_refreshButton addTarget:self action:@selector(refreshNewsList) forControlEvents:UIControlEventTouchUpInside];
    
    self->_favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_favoriteButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_favoriteButton setTitle:@"收藏" forState:UIControlStateNormal];
    [self->_favoriteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_favoriteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self->_favoriteButton addTarget:self action:@selector(pushFavoriteVC) forControlEvents:UIControlEventTouchUpInside];
    
    self->_refreshActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self->_refreshActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self->_refreshActivityIndicator.hidesWhenStopped = YES;

    NSArray *rightItems = @[[[UIBarButtonItem alloc] initWithCustomView:self->_favoriteButton],
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
    
    [self.changeBrightnessSlider setValue:[[UIScreen mainScreen] brightness]];
    
    // http://beyondvincent.com/blog/2013/11/03/120-customize-navigation-status-bar-ios-7/#1
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
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

#pragma mark - 处理进入前后台通知

- (void)handleApplicationWillEnterForegroundNotification:(NSNotification *)not
{
    [self.changeBrightnessSlider setValue:[[UIScreen mainScreen] brightness]];

    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval bef = [[NSUserDefaults standardUserDefaults] doubleForKey:kAutoRefreshNewsInterval];
    if(now - bef > 60) // 进入前后台间隔60秒才执行刷新
        [self refreshNewsList];
}

- (void)hanleApplicationDidEnterBackgroundNotification:(NSNotification *)not
{
    NSTimeInterval now  = [NSDate timeIntervalSinceReferenceDate];
    [[NSUserDefaults standardUserDefaults] setDouble:now forKey:kAutoRefreshNewsInterval];
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
        // 参考:http://stackoverflow.com/questions/9450302/tell-uiscrollview-to-scroll-to-the-top
        [self.newsGroupListView setContentOffset:CGPointMake(0, -self.newsGroupListView.contentInset.top) animated:YES];
        [self->_refreshActivityIndicator stopAnimating];
        [self->_refreshButton setEnabled:YES];

    } onFail:^(NSError *error) {
        [self->_refreshActivityIndicator stopAnimating];
        [self->_refreshButton setEnabled:YES];
        
        NSString *desc = @"网络链接断开或过慢";
        if([error.domain isEqualToString:kNetAPIErorDomain])
            desc = @"很抱歉，出错啦。请告知我(QQ:410139419)必将尽快修复!";
        [MessageBox showWithMessage:desc buttonTitle:@"重试" handler:^{
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

#pragma mark - 收藏列表,帮助，调节亮度
- (void)pushFavoriteVC
{
    FavoriteNewsVC *vc = [[FavoriteNewsVC alloc] initWithNibName:@"FavoriteNewsVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)presentFeedbackVC
{
    [UMFeedback showFeedback:self withAppkey:UMAppKey];
}

- (void)shareThisAppToFriends
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    NSString *msg = [NSString stringWithFormat:@"考公务员、事业单位等[必备神器]，请用力猛戳:%@ ",kAppDownloadAddress];
    NSArray *snsNames = @[UMShareToQzone,UMShareToSina,UMShareToTencent,UMShareToSms,UMShareToEmail,UMShareToRenren,UMShareToDouban];
    [UMSocialSnsService presentSnsIconSheetView:self appKey:UMAppKey shareText:msg shareImage:nil shareToSnsNames:snsNames delegate:nil];
    
#endif
}

- (void)popupChangeBrightnessView:(UIButton *)sender
{
    CGPoint point = sender.center;
    point.y += (sender.bounds.size.height/1.5);
    point = [self.view convertPoint:point fromView:self.view];
    
    [PopoverView showPopoverAtPoint:point inView:self.view withTitle:@"调节亮度" withContentView:self.changeBrightnessView delegate:nil];
}

- (IBAction)screenBrightnessChange:(UISlider *)sender
{
    [[UIScreen mainScreen] setBrightness:sender.value];
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
    cell.textLabel.textColor = [HaveReadNews isRead:news] ? [UIColor lightGrayColor] : [UIColor blackColor];
    
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
    return  kNewsGroupTableViewHeaderViewHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NewsGroup *newsGroup = [[NewsProvider sharedInstance] getNewsGroupByIndex:indexPath.section];
    News *news = newsGroup.newsGroup[indexPath.row];
    
    [HaveReadNews markAsReaded:news];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    
    NewsContentVC *vc = [[NewsContentVC alloc] initWithNews:news];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
