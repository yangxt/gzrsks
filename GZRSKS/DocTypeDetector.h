//
//  DocTypeDetector.h
//  GZRSKS
//
//  Created by LiHong on 14-1-16.
//  Copyright (c) 2014年 李红(410139419@qq.com). All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DocTypeHTML,
    DocTypeDoc,
    DocTypeXls,
    DocTypePPT,
    DocTypeTxt,
    DocTypeZip,
    DocTypeNewsContent
}DocType;

@interface DocTypeDetector : NSObject

+ (DocType)dectectWithURL:(NSURL *)url;

+ (NSString *)docTypeName:(DocType)type;

@end
