//
//  Config.h
//  ExamInfo
//
//  Created by LiHong on 13-12-19.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import <Foundation/Foundation.h>

/// 提供App配置信息
@interface Config : NSObject

+ (id)shared;

- (void)setNightModal:(BOOL)nightModal;
- (BOOL)getNightModal;

@end
