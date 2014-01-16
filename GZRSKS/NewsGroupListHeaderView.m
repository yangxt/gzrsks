//
//  NewsGroupListHeaderView.m
//  GZRSKS
//
//  Created by LiHong on 13-12-22.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import "NewsGroupListHeaderView.h"
#import "News.h"

@implementation NewsGroupListHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame andNewsGroup:(NewsGroup *)newsGroup
{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor colorWithWhite:0.962 alpha:1.0];
        self.layer.shadowColor = [UIColor colorWithWhite:0.83 alpha:1.0].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 3);
        self.layer.shadowOpacity = 0.7;
        
        UILabel *lable = [[UILabel alloc] initWithFrame:frame];
        lable.backgroundColor = [UIColor clearColor];
        lable.font = [UIFont systemFontOfSize:16];
        lable.textColor = [UIColor blackColor];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.text = [NSString stringWithFormat:@"日期:%@  发布:%d条",newsGroup.publishDate,(int)newsGroup.count];
        
        [self addSubview:lable];
    }
    return self;
}
@end
