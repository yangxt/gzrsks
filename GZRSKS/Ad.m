//
//  Ad.m
//  GZRSKS
//
//  Created by lihong on 14-9-26.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "Ad.h"

static NSString *kImageUrl  = @"ImageUrl";
static NSString *kDetailUrl = @"DetailUrl";

@implementation Ad

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init])
    {
        self.adImageUrl = [dict objectForKey:@"adImageUrl"];
        self.adDetailUrl = [dict objectForKey:@"adDetailUrl"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.adImageUrl forKey:kImageUrl];
    [aCoder encodeObject:self.adDetailUrl forKey:kDetailUrl];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.adImageUrl = [aDecoder decodeObjectForKey:kImageUrl];
        self.adDetailUrl  = [aDecoder decodeObjectForKey:kDetailUrl];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    if(copy)
    {
        [copy setAdImageUrl:[self.adImageUrl copyWithZone:zone]];
        [copy setAdDetailUrl:[self.adDetailUrl copyWithZone:zone]];
    }
    return copy;
}

@end
