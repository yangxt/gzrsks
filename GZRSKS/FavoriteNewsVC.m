//
//  FavoriteNewsVC.m
//  GZRSKS
//
//  Created by LiHong on 14-1-15.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "FavoriteNewsVC.h"
#import "TMCache.h"
#import "News.h"
#import "NewsContentVC.h"
#import "MessageBox.h"
#import "RESideMenu.h"


extern NSString  *const kNewsCacheKey;

static NSString *const kFavoriteCellReuseId = @"FavoriteCellReuseId";

@interface FavoriteNewsVC ()<UITableViewDataSource,UITabBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation FavoriteNewsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我的收藏";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFavoriteCellReuseId];
    
    UIImage *image = [UIImage imageNamed:@"SideMenu"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(openSideMenu)];
    self.navigationItem.leftBarButtonItem = item;
    
    self->_clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self->_clearButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self->_clearButton setTitle:@"清除" forState:UIControlStateNormal];
    [self->_clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self->_clearButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self->_clearButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self->_clearButton addTarget:self action:@selector(deleteAllFavoriteNews) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self->_clearButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[TMCache sharedCache] objectForKey:kNewsCacheKey block:^(TMCache *cache, NSString *key, id object) {
       
        dispatch_sync(dispatch_get_main_queue(), ^{
            self->_favoriteNewsArray = object;
            if(self->_favoriteNewsArray == nil || self->_favoriteNewsArray.count == 0)
            {
                self->_favoriteNewsArray = [NSMutableArray new];
                [self->_clearButton setEnabled:NO];
            }
            
            [self.tableView reloadData];
        });
    }];
}

// 打开侧边栏
- (void)openSideMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}


// 删除所有收藏的考试信息
- (void)deleteAllFavoriteNews
{
    [MessageBox showWithMessage:@"你确定要这么干?" buttonTitle:@"确定" handler:^{
        [[TMCache sharedCache] removeAllObjects:^(TMCache *cache) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self->_clearButton setEnabled:NO];
                self->_favoriteNewsArray = [NSArray new];
                [self.tableView reloadData];
            });
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self->_favoriteNewsArray.count ? self->_favoriteNewsArray.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFavoriteCellReuseId];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor blackColor];
    
    if(self->_favoriteNewsArray.count == 0)
    {
        cell.textLabel.text = @"您知道吗？离线也能查看收藏的信息!";
        cell.textLabel.textColor = [UIColor lightGrayColor];
        return cell;
    }
    
    News *news = self->_favoriteNewsArray[indexPath.row];
    cell.textLabel.text = news.title;
    return cell;
}

#pragma mark - UITabBarDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self->_favoriteNewsArray.count == 0) return;
    
    NewsContentVC *vc = [[NewsContentVC alloc] initWithNews:self->_favoriteNewsArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
