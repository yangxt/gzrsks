//
//  MessageBox.m
//  GZRSKS
//
//  Created by LiHong on 14-1-15.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "MessageBox.h"



@implementation MessageBox

+ (void)showWithMessage:(NSString *)message handler:(void(^)())handler
{
    static MessageBox *msgBox = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        msgBox =  [MessageBox new];
    });
    
    [msgBox showWithMessage:message handler:handler];
}

- (void)showWithMessage:(NSString *)message handler:(void(^)())handler
{
    self->_retryHandler = [handler copy];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:@"注意" message:message delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"重试", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1 && self->_retryHandler){
        self->_retryHandler();
        self->_retryHandler = nil;
    }
}

@end
