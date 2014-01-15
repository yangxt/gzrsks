//
//  MessageBox.h
//  GZRSKS
//
//  Created by LiHong on 14-1-15.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageBox : NSObject<UIAlertViewDelegate>
{
    void (^_retryHandler)(void);
}
+ (void)showWithMessage:(NSString *)message handler:(void(^)())handler;

@end
