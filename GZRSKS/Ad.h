//
//  Ad.h
//  GZRSKS
//
//  Created by lihong on 14-9-26.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ad : NSObject
@property (nonatomic, strong) NSString *adImageUrl;
@property (nonatomic, strong) NSString *adDetailUrl;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
