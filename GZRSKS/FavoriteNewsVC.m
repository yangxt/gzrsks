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
@property (strong, nonatomic) NSMutableArray *newsArray;
@end

@implementation FavoriteNewsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"我的收藏";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFavoriteCellReuseId];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllFavoriteNews)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[TMCache sharedCache] objectForKey:kNewsCacheKey block:^(TMCache *cache, NSString *key, id object) {
       
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.newsArray = object;
            BOOL aBool = (self.newsArray == nil || self.newsArray.count == 0);
            self.navigationItem.rightBarButtonItem.enabled = !aBool;
            if(aBool)self.newsArray = [NSMutableArray new];
            [self.tableView reloadData];
        });
    }];
}

// 删除所有收藏的考试信息
- (void)deleteAllFavoriteNews
{
    [MessageBox showWithMessage:@"这会删除你收藏的所有内容!" buttonTitle:@"确定" handler:^{
        [[TMCache sharedCache] removeAllObjects:^(TMCache *cache) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem.enabled = NO;
                [self.newsArray removeAllObjects];
                [self.tableView reloadData];
            });
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.newsArray.count==0 ? 1:self.newsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFavoriteCellReuseId];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor blackColor];
    
    if(self.newsArray.count == 0)
    {
        cell.textLabel.text = @"你知道吗？可离线查看收藏的内容!";
        cell.textLabel.textColor = [UIColor lightGrayColor];
        return cell;
    }
    
    News *news = self.newsArray[indexPath.row];
    cell.textLabel.text = news.title;
    return cell;
}

#pragma mark - UITabBarDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.newsArray.count == 0) return;
    
    NewsContentVC *vc = [[NewsContentVC alloc] initWithNews:self.newsArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
