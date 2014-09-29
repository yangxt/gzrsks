//
//  AdConfig.h
//  GZRSKS
//
//  Created by lihong on 14-9-26.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ad;
@interface AdConfig : NSObject

@property (nonatomic, strong) Ad *luanchAdEntity;
@property (nonatomic, strong) NSArray *homeAdEntityArray;
@property (nonatomic, strong) NSArray *pageAdEntityArray;

@end
