//
//  DinoTests.m
//  DinoTests
//
//  Created by Devin Zhang on 12/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IWDinoService.h"
@interface DinoTests : XCTestCase

@end

@implementation DinoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testDateString {
    NSDateFormatter *rcfDateFormatter = [[NSDateFormatter alloc] init];
    rcfDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    NSString *dateStr = [rcfDateFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@",dateStr);
}

- (void)testListChannels {
    [[IWDinoService sharedInstance] listChannels];
    [NSThread sleepForTimeInterval:10];
}

@end
