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

// 夜间模式
@property (nonatomic, assign) BOOL NightModal;

// 查看附件时是否启用自动旋转视图,默认YES,启用.
@property (nonatomic, assign) BOOL shouldAutorotateDocViewer;


@end
