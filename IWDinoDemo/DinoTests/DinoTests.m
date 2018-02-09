//
//  DinoTests.m
//  DinoTests
//
//  Created by Devin Zhang on 12/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IWDinoService.h"
#import "OCMockito.h"
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>

@interface DinoTests : XCTestCase<IWDinoServiceDelegate, XCTWaiterDelegate>
@property (nonatomic, strong) IWDinoService         *dinoService;
@property (nonatomic, strong) SocketIOClient        *socketClient;
@property (nonatomic, strong) XCTestExpectation     *connectExpectation;
@property (nonatomic, strong) XCTestExpectation     *loginExpectation;
@property (nonatomic, strong) NSDictionary          *fakeErrorDic;
@property (nonatomic, strong) IWDError              *fakeError;
@end

@implementation DinoTests

- (void)setUp {
    [super setUp];
    
    self.dinoService = [IWDinoService sharedInstance];
    self.socketClient = mock([SocketIOClient class]);
    self.dinoService.socketClient = self.socketClient;
    self.fakeErrorDic = @{@"error" : @"fake error", @"status_code" : @"1"};
    self.fakeError = [[IWDError alloc] initWithDomain:@"fake error" code:1 userInfo:nil];
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

- (void)testMockConnect {
    id<IWDinoServiceDelegate> delegate = mockProtocol(@protocol(IWDinoServiceDelegate));
    self.dinoService.delegate = delegate;
    HCArgumentCaptor *captor = [[HCArgumentCaptor alloc] init];
    [self.dinoService connectWithServerAddress:anything() nameSpace:anything()];
    [verify(self.socketClient) on:@"gn_connect" callback:(id)captor];
    void (^block)(NSArray *data, SocketAckEmitter *ack) = captor.value;
    block(@[self.fakeErrorDic], nil);
    [verify(self.dinoService.delegate) didConnected:self.fakeError];
    
    block(@[@{}], nil);
    [verify(self.dinoService.delegate) didConnected:nil];
}


- (void)testMockLogin {
    id<IWDinoServiceDelegate> delegate = mockProtocol(@protocol(IWDinoServiceDelegate));
    self.dinoService.delegate = delegate;
    HCArgumentCaptor *captor = [[HCArgumentCaptor alloc] init];
    IWDLoginModel *model = [[IWDLoginModel alloc] initWithToken:@"" userId:@"" displayName:@""];
    [self.dinoService loginWithLoginModel:model];
    [verify(self.socketClient) once:@"gn_login" callback:(id)captor];
    void (^block)(NSArray *data, SocketAckEmitter *ack) = captor.value;
    
    block(@[@{}], nil);
    [verify(self.dinoService.delegate) didLogin:nil];
    [verify(delegate) df_didLogin:anything()];
    
    block(@[self.fakeErrorDic], nil);
    [verify(self.dinoService.delegate) didLogin:self.fakeError];
}

- (void)testMockListChannels {
    id<IWDinoServiceDelegate> delegate = mockProtocol(@protocol(IWDinoServiceDelegate));
    self.dinoService.delegate = delegate;
    HCArgumentCaptor *captor = [[HCArgumentCaptor alloc] init];
    [self.dinoService listChannels];
    [verify(self.socketClient) once:@"gn_list_channels" callback:(id)captor];
    void (^block)(NSArray *data, SocketAckEmitter *ack) = captor.value;
    block(@[@{}], anything());
    [verify(delegate) df_didReceiveChannels:anything()];
    [verify(delegate) didReceiveChannels:@[] error:nil];
    
    block(@[self.fakeErrorDic], anything());
    [verify(self.dinoService.delegate) didReceiveChannels:@[] error:self.fakeError];
}

- (void)testMockListRooms {
    id<IWDinoServiceDelegate> delegate = mockProtocol(@protocol(IWDinoServiceDelegate));
    self.dinoService.delegate = delegate;
    HCArgumentCaptor *captor = [[HCArgumentCaptor alloc] init];
    [self.dinoService listRoomsWithChannelId:anything()];
    [verify(self.socketClient) once:@"gn_list_rooms" callback:(id)captor];
    void (^block)(NSArray *data, SocketAckEmitter *ack) = captor.value;
    block(@[@{}], anything());
    [verify(delegate) df_didReceiveRooms:anything()];
    [verify(delegate) didReceiveRooms:@[] error:nil];
    
    block(@[self.fakeErrorDic], anything());
    [verify(self.dinoService.delegate) didReceiveRooms:@[] error:self.fakeError];
}

- (void)testMockCreateRoom {
    id<IWDinoServiceDelegate> delegate = mockProtocol(@protocol(IWDinoServiceDelegate));
    self.dinoService.delegate = delegate;
    
    [self.dinoService createPrivateRoomWithChannelId:@"1" userId:@"1" userId2:@"1" roomName:@"1" completion:^(IWDRoomModel *room, IWDError *error) {
        
    }];
    HCArgumentCaptor *captor = [[HCArgumentCaptor alloc] init];
    [verify(self.socketClient) once:@"gn_create" callback:(id)captor];
}

- (void)testMockRemoveRoom {
    id<IWDinoServiceDelegate> delegate = mockProtocol(@protocol(IWDinoServiceDelegate));
    self.dinoService.delegate = delegate;
    [self.dinoService removeRoom:@"1" completion:^(IWDError *error) {
        
    }];
    HCArgumentCaptor *captor = [[HCArgumentCaptor alloc] init];
    [verify(self.socketClient) once:@"gn_remove_room" callback:(id)captor];
}

- (void)testMockJoinRoom {
    id<IWDinoServiceDelegate> delegate = mockProtocol(@protocol(IWDinoServiceDelegate));
    self.dinoService.delegate = delegate;
    HCArgumentCaptor *captor = [[HCArgumentCaptor alloc] init];
    [self.dinoService joinRoom:anything()];
    [verify(self.socketClient) once:@"gn_join" callback:(id)captor];
    
    void (^block)(NSArray *data, SocketAckEmitter *ack) = captor.value;
    block(@[@{}], anything());
    [verify(delegate) df_didJoin:anything()];
    [verify(delegate) didJoin:nil];
    
    block(@[self.fakeErrorDic], anything());
    [verify(self.dinoService.delegate) didJoin:self.fakeError];
}

- (void)testMockSendMessage {
    id<IWDinoServiceDelegate> delegate = mockProtocol(@protocol(IWDinoServiceDelegate));
    self.dinoService.delegate = delegate;
    HCArgumentCaptor *captor = [[HCArgumentCaptor alloc] init];
    [self.dinoService sendMessageWithRoomId:@"1" objectType:@"private" message:@"msg" completion:^(IWDMessageModel *message, IWDError *error) {
        
    }];
    [verify(self.socketClient) once:@"gn_message" callback:(id)captor];
}






@end
