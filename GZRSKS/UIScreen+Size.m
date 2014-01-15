//
//  UIScreen+Size.m
//  GZRSKS
//
//  Created by LiHong on 13-12-23.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import "UIScreen+Size.h"

@implementation UIScreen (Size)

+ (CGFloat)width
{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)height
{
    return [UIScreen mainScreen].bounds.size.height;
}

@end
