//
//  GZRSKSTests.m
//  GZRSKSTests
//
//  Created by LiHong on 13-12-21.
//  Copyright (c) 2013年 李红(410139419@qq.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DocTypeDetector.h"

@interface GZRSKSTests : XCTestCase

@end

@implementation GZRSKSTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    [DocTypeDetector dectectWithURL:[NSURL URLWithString:@"http://www.baidu.com/myDoc.XSL"]];
    [DocTypeDetector dectectWithURL:[NSURL URLWithString:@"http://www.baidu.com/myDoc.Doc"]];
    [DocTypeDetector dectectWithURL:[NSURL URLWithString:@"http://www.baidu.com/myDoc.Ppt"]];
    [DocTypeDetector dectectWithURL:[NSURL URLWithString:@"http://www.baidu.com/myDoc.zip"]];
    [DocTypeDetector dectectWithURL:[NSURL URLWithString:@"http://www.baidu.com/myDoc.rar"]];
    [DocTypeDetector dectectWithURL:[NSURL URLWithString:@"http://www.baidu.com/myDoc.txt"]];
    [DocTypeDetector dectectWithURL:[NSURL URLWithString:@"http://www.baidu.com/myDoc.."]];
}

@end
