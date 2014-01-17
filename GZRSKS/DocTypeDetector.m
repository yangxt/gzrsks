//
//  DocTypeDetector.m
//  GZRSKS
//
//  Created by LiHong on 14-1-16.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import "DocTypeDetector.h"

@implementation DocTypeDetector

+ (DocType)dectectWithURL:(NSURL *)url
{
    NSString *eName = [[url pathExtension] lowercaseString];
    NSString *schmem = [[url scheme] lowercaseString];
    
    if([eName isEqualToString:@"doc"] || [eName isEqualToString:@"docx"])
        return DocTypeDoc;
    
    if([eName isEqualToString:@"xls"] || [eName isEqualToString:@"xlsx"])
        return DocTypeXls;
    
    if([eName isEqualToString:@"ppt"] || [eName isEqualToString:@"pptx"])
        return DocTypePPT;
    
    if([eName isEqualToString:@"zip"] || [eName isEqualToString:@"rar"])
        return DocTypeZip;
    
    if([eName isEqualToString:@"txt"] || [eName isEqualToString:@"rtf"])
        return DocTypeTxt;
    
    if([schmem isEqualToString:@"http"] || [eName isEqualToString:@"shtml"] || [eName isEqualToString:@"html"] ||
       [eName isEqualToString:@"aspx"] || [eName isEqualToString:@"jsp"]   || [eName isEqualToString:@"php"])
        return DocTypeHTML;
    
    return DocTypeNewsContent;

}

+ (NSString *)docTypeName:(DocType)type
{
    switch(type)
    {
        case DocTypeDoc:
            return @"Word文档";
        case DocTypeXls:
            return @"电子表格";
        case DocTypePPT:
            return @"幻灯片文档";
        case DocTypeTxt:
            return @"文本文档";
        case DocTypeZip:
            return @"压缩文件";
        case DocTypeHTML:
            return @"外部网站";
        case DocTypeNewsContent:
            return @"人事考试信息";
    }
    return @"未知类型文件";
}
@end
