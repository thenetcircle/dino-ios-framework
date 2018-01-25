//
//  IWDinoService.m
//  Dino
//
//  Created by Devin Zhang on 19/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import "IWDinoService.h"
@import SocketIO;

@interface IWDinoService ()
@property (nonatomic, strong) NSString *serverAddress;
@property (nonatomic, strong) NSString *nameSpace;
@property (nonatomic, strong) SocketManager     *socketManager;
@property (nonatomic, strong) SocketIOClient    *socketClient;
@property (nonatomic, strong) IWDLoginModel     *loginModel;
@property (nonatomic, strong) NSDateFormatter   *rcfDateFormatter;

@end

@implementation IWDinoService

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id singleton;
    dispatch_once( &once, ^{ singleton = [[self alloc] init]; } );
    return singleton;
};

- (void)connectWithServerAddress:(NSString *)address nameSpace:(NSString *)nameSpace {
    self.serverAddress = address;
    self.nameSpace = nameSpace;
    if (self.socketClient.status == SocketIOStatusConnecting || self.socketClient.status == SocketIOStatusConnected) {
        return;
    }
    
    [self addListeners];
    [self.socketClient connect];
}

- (void)disconnect {
    if (self.socketClient.status == SocketIOStatusConnected) {
        [self.socketClient disconnect];
    }
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
    
    [self.socketClient on:@"gn_message_received" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_message_received  <<<<<<<<<<<<<<<<<<<<<<<<<");
        if (_delegate && [_delegate respondsToSelector:@selector(df_didMessagesRead:)]) {
            [_delegate df_didMessagesRead:data];
        }
        IWDError *error = [self errorFromResponse:data];
        if (error) {
            if (_delegate && [_delegate respondsToSelector:@selector(didMessagesDelivered: error:)]) {
                [_delegate didMessagesDelivered:@[] error:error];
            }
            return;
        }
        NSMutableArray *messages = [@[] mutableCopy];
        for (NSDictionary *dic in data[0][@"object"][@"attachments"]) {
            IWDMessageModel *message = [[IWDMessageModel alloc] initWithDic:dic];
            [messages addObject:message];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(didMessagesDelivered: error:)]) {
            [_delegate didMessagesDelivered:messages error:nil];
        }
    }];
    
    [self.socketClient on:@"gn_message_read" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_message_read  <<<<<<<<<<<<<<<<<<<<<<<<<");
        if (_delegate && [_delegate respondsToSelector:@selector(df_didMessagesRead:)]) {
            [_delegate df_didMessagesRead:data];
        }
        IWDError *error = [self errorFromResponse:data];
        if (error) {
            if (_delegate && [_delegate respondsToSelector:@selector(df_didMessagesRead:)]) {
                [_delegate didMessagesRead:@[] error:error];
            }
            return;
        }
        NSMutableArray *messages = [@[] mutableCopy];
        for (NSDictionary *dic in data[0][@"object"][@"attachments"]) {
            IWDMessageModel *message = [[IWDMessageModel alloc] initWithDic:dic];
            [messages addObject:message];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(didMessagesRead: error:)]) {
            [_delegate didMessagesRead:messages error:nil];
        }
    }];
    
    [self.socketClient on:@"message" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  message received  <<<<<<<<<<<<<<<<<<<<<<<<<");
        if (_delegate && [_delegate respondsToSelector:@selector(df_didReceiveMessages:)]) {
            [_delegate df_didReceiveMessages:data];
        }
        IWDError *error = [self errorFromResponse:data];
        if (_delegate && [_delegate respondsToSelector:@selector(didReceiveMessages:error:)]) {
            if (error) {
                [_delegate didReceiveMessages:[NSArray array] error:error];
                return;
            }
            IWDMessageModel *message = [[IWDMessageModel alloc] initWithDinoResponse:data[0]];
            NSString *roomId = data[0][@"target"][@"id"];
            message.roomId = roomId;
            [_delegate didReceiveMessages:@[message] error:nil];
        }
    }];
}


- (void)loginWithLoginModel:(IWDLoginModel *)loginModel {
    [self.socketClient once:@"gn_login" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_login  <<<<<<<<<<<<<<<<<<<<<<<<<");
        if (_delegate && [_delegate respondsToSelector:@selector(df_didLogin:)]) {
            [_delegate df_didLogin:data];
        }
        IWDError *error = [self errorFromResponse:data];
        if (_delegate && [_delegate respondsToSelector:@selector(didLogin:)]) {
            if ([_delegate respondsToSelector:@selector(didLogin:)]) {
                [_delegate didLogin:error];
            }
        }
    }];
    [self.socketClient emit:@"login" with:@[loginModel.dictionary]];
}


- (void)listChannels {
    
    [self.socketClient once:@"gn_list_channels" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_list_channels  <<<<<<<<<<<<<<<<<<<<<<<<<");
        if (_delegate && [_delegate respondsToSelector:@selector(df_didReceiveChannels:)]) {
            [_delegate df_didReceiveMessages:data];
        }
        IWDError *error = [self errorFromResponse:data];
        if (error) {
            if ([_delegate respondsToSelector:@selector(didReceiveChannels:error:)]) {
                [_delegate didReceiveChannels:@[] error:error];
            }
            return;
        }
        
        NSArray *channelArray = data[0][@"data"][@"object"][@"attachments"];
        NSMutableArray *channels = [@[] mutableCopy];
        for (NSDictionary *dic in channelArray) {
            IWDChannelModel *channel = [[IWDChannelModel alloc] initWithDinoResponse:dic];
            [channels addObject:channel];
        }
        
        if ([_delegate respondsToSelector:@selector(didReceiveChannels:error:)]) {
            [_delegate didReceiveChannels:channels error:nil];
        }
    }];
    
    [self.socketClient emit:@"list_channels" with:@[@{@"verb":@"list"}]];
}

- (void)listRoomsWithChannelId:(NSString *)channelId {
    
    [self.socketClient once:@"gn_list_rooms" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_list_rooms  <<<<<<<<<<<<<<<<<<<<<<<<<");
        if (_delegate && [_delegate respondsToSelector:@selector(df_didReceiveRooms:)]) {
            [_delegate df_didReceiveRooms:data];
        }
        IWDError *error = [self errorFromResponse:data];
        if (error) {
            if ([_delegate respondsToSelector:@selector(didReceiveRooms: error:)]) {
                [_delegate didReceiveRooms:@[] error:error];
            }
            return;
        }
        
        NSArray *roomArray = data[0][@"data"][@"object"][@"attachments"];
        NSMutableArray *rooms = [@[] mutableCopy];
        for (NSDictionary *dic in roomArray) {
            IWDRoomModel *room = [[IWDRoomModel alloc] initWithDinoResponse:dic];
            [rooms addObject:room];
        }
        if ([_delegate respondsToSelector:@selector(didReceiveRooms: error:)]) {
            [_delegate didReceiveRooms:rooms error:nil];
        }
    }];
    
    [self.socketClient emit:@"list_rooms" with:@[@{@"verb":@"list", @"object":@{@"url":channelId}}]];
}

- (void)sendMessageWithRoomId:(NSString *)roomId
                   objectType:(NSString *)objectType
                      message:(NSString *)message
                   completion:(void (^)(IWDMessageModel *message, IWDError *error))completion {
    [self sendMessageWithRoomId:roomId
                     objectType:objectType
                        message:message
                   dfCompletion:nil
                     completion:completion];
}

- (void)df_sendMessageWithRoomId:(NSString *)roomId
                   objectType:(NSString *)objectType
                      message:(NSString *)message
                   completion:(IWDBlock_DF)completion {
    [self sendMessageWithRoomId:roomId
                     objectType:objectType
                        message:message
                   dfCompletion:completion
                     completion:nil];
}


- (void)sendMessageWithRoomId:(NSString *)roomId
                   objectType:(NSString *)objectType
                      message:(NSString *)message
                 dfCompletion:(IWDBlock_DF)dfCompletion
                   completion:(void (^)(IWDMessageModel *message, IWDError *error))completion {
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  send_message  <<<<<<<<<<<<<<<<<<<<<<<<<");
    NSString *base64Message = [[message dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    [self.socketClient once:@"gn_message" callback:^(NSArray *data, SocketAckEmitter *ack) {
        if(dfCompletion) {
            dfCompletion(data);
        }
        
        if (completion) {
            IWDError *error = [self errorFromResponse:data];
            if(error){
                completion(nil, error);
            }else {
                IWDMessageModel *message = [[IWDMessageModel alloc] initWithDinoResponse:data[0][@"data"]];
                completion(message, nil);
            }
        }
    }];
    NSArray *dataArray = @[@{@"verb":@"send", @"target":@{@"id":roomId, @"objectType":objectType}, @"object":@{@"content":base64Message}}];
    [self.socketClient emit:@"message" with:dataArray];
}

- (void)createPrivateRoomWithChannelId:(NSString *)channelId
                                userId:(NSString *)userId1
                               userId2:(NSString *)userId2
                              roomName:(NSString *)roomName
                            completion:(IWDRoomCreateBlock)completion {
    
    [self.socketClient once:@"gn_create" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_create  <<<<<<<<<<<<<<<<<<<<<<<<<");
        IWDError *error = [self errorFromResponse:data];
        if (completion) {
            if (!error) {
                IWDRoomModel *room = [[IWDRoomModel alloc] initWithDinoResponse:data[0][@"data"][@"target"]];
                completion(room, nil);
            }else {
                completion(nil, error);
            }
        }
    }];
    
    
    NSMutableString *summary = [NSMutableString stringWithFormat:@"%@,%@", userId1, userId2];
    NSDictionary *createModel = @{ @"verb":@"create",
                                   @"object":@{@"url":channelId},
                                   @"target": @{@"displayName"  : [[roomName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                                                @"objectType"   : @"private",
                                                @"attachments" : @[@{@"objectType" : @"owners",
                                                                     @"summary"    : summary
                                                                     }]
                                                }
                                   };
    [self.socketClient emit:@"create" with:@[createModel]];
}

- (void)removeRoom:(NSString *)roomId completion:(IWDBlock)completion {
    [self.socketClient once:@"gn_remove_room" callback:^(NSArray *data, SocketAckEmitter *ack) {
        if (completion) {
            IWDError *error = [self errorFromResponse:data];
            completion(error);
        }
    }];
    
    [self.socketClient emit:@"remove_room" with: @[@{@"verb" : @"remove", @"target" : @{@"id" : roomId}}]];
}


- (void)joinRoom:(NSString *)roomId {
    [self.socketClient once:@"gn_join" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_join  <<<<<<<<<<<<<<<<<<<<<<<<<");
        if (_delegate && [_delegate respondsToSelector:@selector(df_didJoin:)]) {
            [_delegate df_didJoin:data];
        }
        IWDError *error = [self errorFromResponse:data];
    
        if (_delegate && [_delegate respondsToSelector:@selector(didJoin:)]) {
            [_delegate didJoin:error];
        }
    }];
    
    [self.socketClient emit:@"join" with:@[@{@"verb":@"join", @"target":@{@"id":roomId}}]];
}

- (void)getHistoryWithRoomId:(NSString *)roomId updatedTime:(NSString *)updateTime {
    [self.socketClient once:@"gn_history" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_create  <<<<<<<<<<<<<<<<<<<<<<<<<");
    }];
    updateTime = updateTime ? : [self.rcfDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-3600]];
    [self.socketClient emit:@"history" with:@[@{@"verb":@"list", @"updated":updateTime ,@"target":@{@"id":roomId, @"objectType":@"private"}}]];
}

- (void)sentAckReceived:(NSString *)roomId messages:(NSArray *)messages {
    
    NSMutableArray *messageArray = [@[] mutableCopy];
    for (id obj in messages) {
        if ([obj isKindOfClass:[IWDMessageModel class]]) {
            [messageArray addObject:@{@"id" : ((IWDMessageModel *)obj).uid}];
        }
        if ([obj isKindOfClass:[NSString class]]) {
            [messageArray addObject:@{@"id" : obj}];
        }
    }
    NSDictionary *emitObject = @{@"verb" : @"receive", @"target" : @{@"id" : roomId}, @"object":@{@"attachments" : messageArray}};
    [self.socketClient emit:@"received" with: @[emitObject]];
}

- (void)sentAckRead:(NSString *)roomId messages:(NSArray<IWDMessageModel *> *)messages {
    
    NSMutableArray *messageArray = [@[] mutableCopy];
    for (id obj in messages) {
        if ([obj isKindOfClass:[IWDMessageModel class]]) {
            [messageArray addObject:@{@"id" : ((IWDMessageModel *)obj).uid}];
        }
        if ([obj isKindOfClass:[NSString class]]) {
            [messageArray addObject:@{@"id" : obj}];
        }
    }
    NSDictionary *emitObject = @{@"verb" : @"read", @"target" : @{@"id" : roomId}, @"object":@{@"attachments" : messageArray}};
    [self.socketClient emit:@"read" with: @[emitObject]];
}

- (IWDError *)errorFromResponse:(NSArray *)data {
    IWDError *error = nil;
    if (data[0] && data[0][@"error"]) {
        error = [[IWDError alloc] initWithDomain:data[0][@"error"] code:[data[0][@"status_code"] integerValue] userInfo:nil];
    }
    return error;
}

#pragma mark - getter / setter
- (SocketManager *)socketManager {
    if (!_socketManager) {
        NSURL* url = [[NSURL alloc] initWithString:self.serverAddress];
        _socketManager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log":@NO,
                                                                               @"forcePolling":@NO,
                                                                               @"transports":@[@"websocket"]}];
    }
    return _socketManager;
}

- (SocketIOClient *)socketClient {
    if (!_socketClient) {
        _socketClient = [self.socketManager socketForNamespace:self.nameSpace];
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


@implementation IWDError

@end
