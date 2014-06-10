//
//  News.m
//  GuiZhouRenShiKaoShi
//
//  Created by xcode on 13-3-15.
//  Copyright (c) 2013年 xcode. All rights reserved.
//

#import "News.h"

static NSString *kTitle      = @"title";
static NSString *kTitleColor = @"titleColor";
static NSString *kDate       = @"date";
static NSString *kUrl        = @"url";
static NSString *kContext    = @"content";

#pragma mark -
@implementation News

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:kTitle];
    [aCoder encodeObject:self.titleColor forKey:kTitleColor];
    [aCoder encodeObject:self.publishDate forKey:kDate];
    [aCoder encodeObject:self.contentUrl forKey:kUrl];
    [aCoder encodeObject:self.content forKey:kContext];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]){
        self.title       = [aDecoder decodeObjectForKey:kTitle];
        self.titleColor  = [aDecoder decodeObjectForKey:kTitleColor];
        self.publishDate = [aDecoder decodeObjectForKey:kDate];
        self.contentUrl  = [aDecoder decodeObjectForKey:kUrl];
        self.content     = [aDecoder decodeObjectForKey:kContext];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    if(copy){
        [copy setTitle:[self.title copyWithZone:zone]];
        [copy setContent:[self.content copyWithZone:zone]];
        [copy setTitleColor:[self.titleColor copyWithZone:zone]];
        [copy setContentUrl:[self.contentUrl copyWithZone:zone]];
        [copy setPublishDate:[self.publishDate copyWithZone:zone]];
    }
    return copy;
}
@end
