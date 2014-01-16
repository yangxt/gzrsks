//
//  NetAPI.m
//  ExamInfo
//
//  Created by LiHong on 13-12-17.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import "NetAPI.h"
#import "Config.h"
#import "UIColor+HexString.h"

NSString  *const kNetAPIErorDomain = @"NetAPIErorDomain";
NSInteger  const kNetAPIErrorCode = 19860826;
NSString  *const kNetAPIErrorDesc = @"kNetAPIErrorDesc";

#define NewError(m) \
[NSError errorWithDomain:kNetAPIErorDomain code:kNetAPIErrorCode userInfo:@{kNetAPIErrorDesc:m}]


#define MThread(func) \
dispatch_sync(dispatch_get_main_queue(), ^{\
func; \
})


@implementation NetAPI

+ (instancetype)sharedInstance
{
    static NetAPI *net;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        net = [[NetAPI alloc] init];
    });
    return net;
}

- (instancetype)init
{
    if(self = [super init])
    {
        self->_queueTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(scheduleTaskQueue) userInfo:nil repeats:YES];
        self->_parseTitleTaskQueue = [NSMutableArray new];
        NSURLSessionConfiguration *con = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        con.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData; // 不使用缓存
        self->_dataSession = [NSURLSession sessionWithConfiguration:con];
    }
    return self;
}


- (void)scheduleTaskQueue
{
    @synchronized(self->_parseTitleTaskQueue){
        if(self->_parseTitleTaskQueue.count == 0)
            return;
        
        
        NSURLSessionDataTask *task = [self->_parseTitleTaskQueue firstObject];
        if(task.state == NSURLSessionTaskStateSuspended)
        {
            [task resume];
            
        }else if(task.state == NSURLSessionTaskStateCompleted)
        {
            [self->_parseTitleTaskQueue removeObject:task];
            if(self->_parseTitleTaskQueue.count)
            {
                task = [self->_parseTitleTaskQueue firstObject];
                [task resume];
            }
        }
    }
}

- (NSURLSessionTask *)parseTitleWithIndex:(NSUInteger)index
                              onSuccessed:(NewsArrayBlock)successedBlock
                                  onError:(ErrorBlock)errorBlock
{
    NSAssert(index >= 1, @"索引必须从1开始(>=1)");
    
    NSURL *url =
    [NSURL URLWithString:[NSString stringWithFormat:@"http://www.163gz.com/gzzp8/zkxx/zkxx_%d.shtml",(int)index]];
    if(index == 1)
        url = [NSURL URLWithString:@"http://www.163gz.com/gzzp8/zkxx/"];
    
    NSURLSessionDataTask *dataTask =
    [self->_dataSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(error)
        {
            MThread(errorBlock(error));
            return;
        }
        
        if(!error && !data.length)
        {
            MThread(errorBlock(NewError(@"获取数据为空")));
            return;
        }
        
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
        if(!string)
        {
            MThread(errorBlock(NewError(@"数据转码出错")));
            return;
        }
        
        NSError *regExError = nil;
        NSString *pattern = @"<a.*http://www.163gz.com/gzzp8/zkxx/.+shtml.*</a>";
        NSRegularExpression *regEx =
        [NSRegularExpression regularExpressionWithPattern:pattern
                                                  options:NSRegularExpressionAllowCommentsAndWhitespace
                                                    error:&regExError];
        if(regExError)
        {
            MThread(successedBlock(NewError(@"正则错误")));
            return;
        }
        
        NSMutableArray *newsObjectContainer = [NSMutableArray new];
        
        NSArray *newsArray =
        [regEx matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length-1)];
        for (NSTextCheckingResult *tcr in newsArray)
        {
            News *news = [[News alloc] init];
            
            NSRange range = [tcr range];
            NSString *newsStr = [string substringWithRange:range];
            
            //1.抓取新闻内容地址
            pattern = @"http.+shtml";
            regEx =
            [NSRegularExpression regularExpressionWithPattern:pattern
                                                      options:NSRegularExpressionAllowCommentsAndWhitespace
                                                        error:&regExError];
            if(regExError)
            {
                MThread(errorBlock(NewError(@"正则错误(url)")));
                return;
            }
            NSArray *urlArray =
            [regEx matchesInString:newsStr options:NSMatchingReportProgress
                             range:NSMakeRange(0, newsStr.length-1)];
            NSTextCheckingResult *urlCR = urlArray[0];
            NSRange urlRange = [urlCR range];
            NSString *urlStr = [newsStr substringWithRange:urlRange];
            news.contentUrl = [NSURL URLWithString:urlStr];
            
            //2.抓取日期
            pattern = @"[0-9]{2}-[0-9]{2}";
            regEx =
            [NSRegularExpression regularExpressionWithPattern:pattern
                                                      options:NSRegularExpressionAllowCommentsAndWhitespace
                                                        error:&regExError];
            if(regExError)
            {
                MThread(errorBlock(NewError(@"正则错误(日期)")));
                return;
            }
            NSArray *dataArray =
            [regEx matchesInString:newsStr
                           options:NSMatchingReportProgress
                             range:NSMakeRange(0, newsStr.length-1)];
            NSTextCheckingResult *dateCR = dataArray[0];
            NSRange dateRange = [dateCR range];
            NSString *dateStr = [newsStr substringWithRange:dateRange];
            news.publishDate = dateStr;
            
            //3.抓取新闻标题文字的颜色
            pattern = @"color.*=.*[0-9a-fA-f]{6}";
            regEx =
            [NSRegularExpression regularExpressionWithPattern:pattern
                                                      options:NSRegularExpressionAllowCommentsAndWhitespace
                                                        error:&regExError];
            if(regExError)
            {
                MThread(errorBlock(NewError(@"正则错误(颜色)")));
                return;
            }
            NSInteger macthCount =
            [regEx numberOfMatchesInString:newsStr
                                   options:NSMatchingReportProgress
                                     range:NSMakeRange(0, newsStr.length-1)];
            NSArray *colorArray = [regEx matchesInString:newsStr
                                                 options:NSMatchingReportProgress
                                                   range:NSMakeRange(0, newsStr.length-1)];
            if(macthCount != 0)
            {
                NSTextCheckingResult *colorCR = colorArray[0];
                NSRange colorRange = [colorCR range];
                NSString *colorStr = [newsStr substringWithRange:colorRange];
                news.titleColor = [UIColor colorWithHexString:[colorStr substringFromIndex:8]];
            }else
            {
                // 有些标题没有指定的颜色,所以匹配数可能为0
                news.titleColor = [Config defaultNewsTitleColor];
            }
            
            //4.抓取标题 (忽略此处编译器的警告,\用来转义正则表达式元字符.)
            pattern = (macthCount == 0 ? @"[0-9]{2}-[0-9]{2}.*\..*<" : @"color=.*>.*</font>");
            regEx =
            [NSRegularExpression regularExpressionWithPattern:pattern
                                                      options:NSRegularExpressionAllowCommentsAndWhitespace
                                                        error:&regExError];
            if(regExError)
            {
                MThread(errorBlock(NewError(@"正则错误(标题)")));
                return;
            }
            NSArray *titleArray = [regEx matchesInString:newsStr
                                                 options:NSMatchingReportProgress
                                                   range:NSMakeRange(0, newsStr.length-1)];
            NSTextCheckingResult *titleCR = titleArray[0];
            NSRange titleRange = [titleCR range];
            NSString *titleStr = [newsStr substringWithRange:titleRange];
            news.title = [self subString:titleStr color:(macthCount != 0 ? YES : NO)];
            
            [newsObjectContainer addObject:news];
        }
        
        MThread(successedBlock(newsObjectContainer));
    }];
    
    @synchronized(self->_parseTitleTaskQueue){
        [self->_parseTitleTaskQueue addObject:dataTask];
    }
    return dataTask;
}

- (NSURLSessionTask *)parseContentWithContentURL:(NSURL *)url
                                     OnSuccessed:(StringBlok)successedBlock
                                         onError:(ErrorBlock)errorBlock
{
    NSURLSessionDataTask *dataTask =
    [self->_dataSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error)
        {
            MThread(errorBlock(error));
            return;
        }
        
        if(!error && data.length == 0)
        {
            MThread(errorBlock(NewError(@"获取数据为空")));
            return;
        }
        
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
        if(!string)
        {
            MThread(errorBlock(NewError(@"数据转码出错")));
            return;
        }
        
        NSError *regExError = nil;
        NSString *pattern = @"<!--Content Start-->.*<!--Content End-->";
        NSRegularExpression *regEx
        = [NSRegularExpression regularExpressionWithPattern:pattern
                                                    options:NSRegularExpressionDotMatchesLineSeparators
                                                      error:&regExError];
        if(regExError)
        {
            MThread(errorBlock(NewError(@"正则错误")));
            return;
        }
        
        NSArray *titleArray =
        [regEx matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length-1)];
        if(!titleArray.count)
        {
            MThread(errorBlock(NewError(@"未找到匹配项")));
            return;
        }
        
        NSTextCheckingResult *newsContentCR = titleArray[0];
        NSRange newsContentRange = [newsContentCR range];
        NSString *newsContentFullStr = [string substringWithRange:newsContentRange];
        NSString *context =
        [newsContentFullStr substringWithRange:NSMakeRange(20, newsContentFullStr.length-(20+18))];
        
        MThread(successedBlock(context));
    }];
    
    [dataTask resume];
    return dataTask;
}


- (NSString *)subString:(NSString *)str color:(BOOL)aBool
{
    NSRange range;
    if(aBool)
        range = NSMakeRange(16, str.length - (16+7));
    else
        range = NSMakeRange(7, str.length - 8);
    
    return [str substringWithRange:range];
}

@end

