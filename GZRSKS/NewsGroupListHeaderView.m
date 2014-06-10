//
//  NewsGroupListHeaderView.m
//  GZRSKS
//
//  Created by LiHong on 13-12-22.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import "NewsGroupListHeaderView.h"
#import "News.h"
#import "NewsGroup.h"

@implementation NewsGroupListHeaderView

- (instancetype)initWithFrame:(CGRect)frame andNewsGroup:(NewsGroup *)newsGroup
{
    if(self = [super initWithFrame:frame])
    {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateStyle:NSDateFormatterLongStyle];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString *dateStr = [formatter stringFromDate:[NSDate new]];
        dateStr = [NSString stringWithFormat:@"%@年%@",[dateStr substringToIndex:4],newsGroup.publishDate];
        NSMutableString *now = [NSMutableString stringWithString:dateStr];
        [now replaceCharactersInRange:NSMakeRange(7, 1) withString:@"月"];
        
        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        self.layer.shadowColor = [UIColor colorWithWhite:0.7 alpha:1.0].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowOpacity = 0.9;
        
        UILabel *lable = [[UILabel alloc] initWithFrame:frame];
        lable.backgroundColor = [UIColor clearColor];
        lable.font = [UIFont systemFontOfSize:18.5];
        lable.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.text = [NSString stringWithFormat:@"%@日 发布%d条",now,(int)newsGroup.count];
        
        [self addSubview:lable];
    }
    return self;
}
@end
