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
@property (nonatomic, strong) SocketManager     *socketManager;
@property (nonatomic, strong) SocketIOClient    *socketClient;
@property (nonatomic, strong) IWLoginModel      *loginModel;
@property (nonatomic, strong) NSDateFormatter   *rcfDateFormatter;
@end

@implementation IWDinoService


- (void)connect {
    if (self.socketClient.status == SocketIOStatusConnected) {
        [self.socketClient disconnect];
    }
    
    if (self.socketClient.status == SocketIOStatusConnecting) {
        return;
    }
    
    [self addListeners];
    
    [self.socketClient connect];
}


- (void)addListeners {
    
    [self.socketClient on:@"connect_error" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  socket error  <<<<<<<<<<<<<<<<<<<<<<<<<");
    }];
    
    [self.socketClient on:@"disconnect" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  socket disconnect  <<<<<<<<<<<<<<<<<<<<<<<<<");
    }];
    
    [self.socketClient on:@"connect_timeout" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  socket connect timeout  <<<<<<<<<<<<<<<<<<<<<<<<<");
    }];
    
    [self.socketClient on:@"connect" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  socket connected  <<<<<<<<<<<<<<<<<<<<<<<<<");
        
    }];
    
    [self.socketClient onAny:^(SocketAnyEvent * event) {
        NSLog(@"any");
    }];
}


- (void)loginWithLoginModel:(IWLoginModel *)loginModel {
    [self.socketClient on:@"gn_login" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_login  <<<<<<<<<<<<<<<<<<<<<<<<<");
    }];
    [self.socketClient emit:@"login" with:@[loginModel.dictionary]];
}

- (void)listChannels {
    
    [self.socketClient on:@"gn_list_channels" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_list_channels  <<<<<<<<<<<<<<<<<<<<<<<<<");
    }];
    
    [self.socketClient emit:@"list_channels" with:@[@{@"verb":@"list"}]];
    
}

- (void)listRoomsWithChannelId:(NSString *)channelId {
    
    [self.socketClient on:@"gn_list_rooms" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_list_rooms  <<<<<<<<<<<<<<<<<<<<<<<<<");
    }];
    
    [self.socketClient emit:@"list_rooms" with:@[@{@"verb":@"list", @"object":@{@"url":channelId}}]];
}

- (void)sendMessageWithRoomId:(NSString *)roomId objectType:(NSString *)objectType message:(NSString *)message {

    NSString *base64Message = [[message dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    [self.socketClient on:@"gn_message" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_message  <<<<<<<<<<<<<<<<<<<<<<<<<");
    }];
    
    [self.socketClient emit:@"message" with:@[@{@"verb":@"send", @"target":@{@"id":roomId, @"objectType":objectType}, @"object":@{@"content":base64Message}}]];
}


- (void)createPrivateRoomWithUserId:(NSString *)userId1 userId2:(NSString *)userId2 roomName:(NSString *)roomName{
    
    [self.socketClient on:@"gn_create" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_create  <<<<<<<<<<<<<<<<<<<<<<<<<");
    }];
    
    
    NSMutableString *summary = [NSMutableString stringWithFormat:@"%@,%@", userId1, userId2];
    NSDictionary *createModel = @{ @"verb":@"create",
                                   @"object":@{@"url":@"6cba7e00-6b0e-4bee-ad59-98bf90813fd0"},
                                   @"target": @{@"displayName"  : [[roomName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                                                @"objectType"   : @"private",
                                                @"attatchments" : @[@{@"objectType" : @"owners",
                                                                      @"summary"    : summary
                                                                      }]
                                                }
                                   };
    [self.socketClient emit:@"create" with:@[createModel]];
}

- (void)joinRoom:(NSString *)roomId {
    [self.socketClient on:@"gn_join" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_create  <<<<<<<<<<<<<<<<<<<<<<<<<");
    }];
    
    [self.socketClient emit:@"join" with:@[@{@"verb":@"list", @"target":@{@"id":roomId}}]];
}

- (void)getHistoryWithRoomId:(NSString *)roomId updatedTime:(NSString *)updateTime {
    [self.socketClient on:@"gn_history" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_create  <<<<<<<<<<<<<<<<<<<<<<<<<");
    }];
    updateTime = updateTime ? : [self.rcfDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-3600]];
    [self.socketClient emit:@"history" with:@[@{@"verb":@"list", @"updated":updateTime ,@"target":@{@"id":roomId, @"objectType":@"private"}}]];
}

#pragma mark - getter / setter

- (SocketManager *)socketManager {
    if (!_socketManager) {
        NSURL* url = [[NSURL alloc] initWithString:@"http://10.60.1.124:9210/ws"];
        _socketManager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log":@YES,
                                                                               @"forcePolling":@NO,
                                                                               @"transports":@[@"websocket"]}];
    }
    return _socketManager;
}

- (SocketIOClient *)socketClient {
    if (!_socketClient) {
        _socketClient = [self.socketManager socketForNamespace:@"/ws"];
    }
    return _socketClient;
}

- (NSDateFormatter *)rcfDateFormatter {
    if (!_rcfDateFormatter) {
        _rcfDateFormatter = [[NSDateFormatter alloc] init];
        _rcfDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    }
    return _rcfDateFormatter;
}

@end
