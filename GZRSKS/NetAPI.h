//
//  NetAPI.h
//  ExamInfo
//
//  Created by LiHong on 13-12-17.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

typedef void(^NewsArrayBlock)(NSMutableArray *);
typedef void(^ErrorBlock)(NSError *);
typedef void(^StringBlok)(NSString *);

#import <Foundation/Foundation.h>
#import "News.h"

@interface NetAPI : NSObject
{
    @private
    NSTimer *_queueTimer;
    NSURLSession *_dataSession;
    NSMutableArray *_parseTitleTaskQueue;
}

+ (instancetype)sharedInstance;

/**
 * @brief 解析考试信息列表.若多次调用此方法，那么会将此方法放入任务队列，只有前一个队列的任务指向完(解析完数据)后，后一个任务才会
 *        执行,参考:scheduleTaskQueue方法的实现。
 * @param index 分页所以，从1开始
 * @param completedHandler 解析完成调用此Block,将一个News的数组传递给Block,此参数不能为NULL.
 * @param errorHandler 解析失败时回掉此块,此参数不能为NULL.
 */
- (NSURLSessionTask *)parseTitleWithIndex:(NSUInteger)index
                              onSuccessed:(NewsArrayBlock)completedHandler
                                  onError:(ErrorBlock)errorHandler;

/**
 * @brief 解析考试信息内容
 * @param url 获取考试信息内容的url
 * @param completedHandler 解析完成时候回掉此块，参数为解析所得的考试内容.此参数不能为NULL.
 * @param errorHandler 解析失败时回掉此块,此参数不能为NULL.
 */
- (NSURLSessionTask *)parseContentWithContentURL:(NSURL *)url
                                     OnSuccessed:(StringBlok)completedHandler
                                         onError:(ErrorBlock)errorHandler;

@end

