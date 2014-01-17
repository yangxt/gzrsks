//
//  MessageBox.m
//  GZRSKS
//
//  Created by LiHong on 14-1-15.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "MessageBox.h"



@implementation MessageBox

+ (void)showWithMessage:(NSString *)message  buttonTitle:(NSString *)title handler:(void(^)(void))handler
{
    static MessageBox *msgBox = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        msgBox =  [MessageBox new];
    });
    
    [msgBox showWithMessage:message buttonTitle:title handler:handler];
}

- (void)showWithMessage:(NSString *)message buttonTitle:(NSString *)title handler:(void(^)(void))handler
{
    self->_handler = [handler copy];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:@"注意" message:message delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:title, nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1 && self->_handler){
        self->_handler();
        self->_handler = nil;
    }
}

@end
