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
        self.title = @"私货";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFavoriteCellReuseId];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setFrame:CGRectMake(0, 0, 44, 44)];
    [clearButton setTitle:@"清除" forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [clearButton addTarget:self action:@selector(deleteAllFavoriteNews) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
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
                [self.navigationItem.rightBarButtonItem.customView setHidden:YES];
            }
            
            [self.tableView reloadData];
        });
    }];
}

// 删除所有收藏的考试信息
- (void)deleteAllFavoriteNews
{
    [MessageBox showWithMessage:@"你确定要这么干?" buttonTitle:@"确定" handler:^{
        [[TMCache sharedCache] removeAllObjects:^(TMCache *cache) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.navigationItem.rightBarButtonItem.customView setHidden:YES];
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
        cell.textLabel.text = @"\t\t\t   ..空空如也..";
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
