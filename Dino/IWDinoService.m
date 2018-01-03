//
//  IWDinoService.m
//  Dino
//
//  Created by Devin Zhang on 19/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import "IWDinoService.h"
#import "NSObject+IWJSONTool.h"
#import "IWLoginModel.h"
@import SocketIO;

#define IW_DINO_SERVICE_ADDRESS @"http://10.60.1.124:9210/ws"


@interface IWDinoService ()
@property (nonatomic, strong) SocketManager  *socketManager;
@property (nonatomic, strong) SocketIOClient *socketClient;
@property (nonatomic, strong) IWLoginModel *loginModel;
@end

@implementation IWDinoService

- (void)connectWithLoginModel:(IWLoginModel *)loginModel {
    
    [self connect];
}


- (void)connect {
    [self addListeners];
    
    [self.socketClient connect];
}



- (void)addListeners {
    
    [self.socketClient on:@"connect_error" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@"socket error");
    }];
    
    [self.socketClient on:@"disconnect" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@"socket disconnect");
    }];
    
    [self.socketClient on:@"connect_timeout" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@"socket connect timeout");
    }];
    
    [self.socketClient on:@"connect" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@"socket connected");
        [self.socketClient emit:@"login" with:@[@{@"userId":@3, @"displayName":@"dean", @"token":@"6ef3f8997d085ca0ef1219d852e26b9647741861"}]];
    }];
    
    [self.socketClient on:@"gn_connect" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@"socket gn_connect");
        [self.socketClient emit:@"login" with:@[@{@"userId":@3, @"displayName":@"dean", @"token":@"6ef3f8997d085ca0ef1219d852e26b9647741861"}]];
    }];
    
    [self.socketClient on:@"gn_login" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@"gn_login");
    }];

}

- (void)login {
    
    
    
}


#pragma mark - getter / setter

- (SocketManager *)socketManager {
    if (!_socketManager) {
        NSURL* url = [[NSURL alloc] initWithString:IW_DINO_SERVICE_ADDRESS];
        _socketManager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log":@YES,
                                                                               @"forceNew":@YES,
                                                                               @"forcePolling":@YES,
                                                                               @"transports":@[@"websocket"]}];
    }
    return _socketManager;
}

- (SocketIOClient *)socketClient {
    if (!_socketClient) {
        _socketClient = self.socketManager.defaultSocket;
    }
    return _socketClient;
}

@end
