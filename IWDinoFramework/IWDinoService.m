//
//  IWDinoService.m
//  Dino
//
//  Created by Devin Zhang on 19/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import "IWDinoService.h"
@import SocketIO;

#define IW_DINO_SERVICE_ADDRESS @"http://10.60.1.124:9210/ws"


@interface IWDinoService ()
@property (nonatomic, strong) SocketManager     *socketManager;
@property (nonatomic, strong) SocketIOClient    *socketClient;
@property (nonatomic, strong) IWDLoginModel      *loginModel;
@property (nonatomic, strong) NSDateFormatter   *rcfDateFormatter;

@property (nonatomic, strong) NSMutableArray    *delegates;
@end

@implementation IWDinoService

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id singleton;
    dispatch_once( &once, ^{ singleton = [[self alloc] init]; } );
    return singleton;
};

- (instancetype)init {
    if (self = [super init]) {
        [self connect];
    }
    return self;
}

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
        IWDError *error = [self errorFromResponse:data];
        if (error) {
            for (id delegate in self.delegates) {
                [delegate didMessagesDelivered:@[] error:error];
            }
            return;
        }
        NSMutableArray *messages = [@[] mutableCopy];
        for (NSDictionary *dic in data[0][@"object"][@"attachments"]) {
            IWDMessageModel *message = [[IWDMessageModel alloc] initWithDic:dic];
            [messages addObject:message];
        }
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didMessagesDelivered: error:)]) {
                [delegate didMessagesDelivered:messages error:nil];
            }
        }
    }];
    
    [self.socketClient on:@"gn_message_read" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_message_read  <<<<<<<<<<<<<<<<<<<<<<<<<");
        IWDError *error = [self errorFromResponse:data];
        if (error) {
            for (id delegate in self.delegates) {
                [delegate didMessagesRead:@[] error:error];
            }
            return;
        }
        NSMutableArray *messages = [@[] mutableCopy];
        for (NSDictionary *dic in data[0][@"object"][@"attachments"]) {
            IWDMessageModel *message = [[IWDMessageModel alloc] initWithDic:dic];
            [messages addObject:message];
        }
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didMessagesRead: error:)]) {
                [delegate didMessagesRead:messages error:nil];
            }
        }
    }];
    
    [self.socketClient on:@"message" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  message received  <<<<<<<<<<<<<<<<<<<<<<<<<");
        IWDError *error = [self errorFromResponse:data];
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didReceiveMessages:error:)]) {
                if (error) {
                    [delegate didReceiveMessages:[NSArray array] error:error];
                    return;
                }
                IWDMessageModel *message = [[IWDMessageModel alloc] initWithDinoResponse:data[0]];
                NSString *roomId = data[0][@"target"][@"id"];
                message.roomId = roomId;
                [delegate didReceiveMessages:@[message] error:nil];
            }
        }
    }];
}


- (void)loginWithLoginModel:(IWDLoginModel *)loginModel {
    [self.socketClient on:@"gn_login" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_login  <<<<<<<<<<<<<<<<<<<<<<<<<");
        IWDError *error = [self errorFromResponse:data];
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didLogin:)]) {
                [delegate didLogin:error];
            }
        }
        [self.socketClient off:@"gn_login"];
    }];
    [self.socketClient emit:@"login" with:@[loginModel.dictionary]];
}


- (void)listChannels {
    
    [self.socketClient on:@"gn_list_channels" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_list_channels  <<<<<<<<<<<<<<<<<<<<<<<<<");
        IWDError *error = [self errorFromResponse:data];
        if (error) {
            for (id delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(didReceiveChannels:error:)]) {
                    [delegate didReceiveChannels:@[] error:error];
                }
            }
            [self.socketClient off:@"gn_list_channels"];
            return;
        }
        
        NSArray *channelArray = data[0][@"data"][@"object"][@"attachments"];
        NSMutableArray *channels = [@[] mutableCopy];
        for (NSDictionary *dic in channelArray) {
            IWDChannelModel *channel = [[IWDChannelModel alloc] initWithDinoResponse:dic];
            [channels addObject:channel];
        }
        
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didReceiveChannels:error:)]) {
                [delegate didReceiveChannels:channels error:nil];
            }
        }
        [self.socketClient off:@"gn_list_channels"];
    }];
    
    [self.socketClient emit:@"list_channels" with:@[@{@"verb":@"list"}]];
}

- (void)listRoomsWithChannelId:(NSString *)channelId {
    
    [self.socketClient on:@"gn_list_rooms" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_list_rooms  <<<<<<<<<<<<<<<<<<<<<<<<<");
        IWDError *error = [self errorFromResponse:data];
        if (error) {
            for (id delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(didReceiveRooms: error:)]) {
                    [delegate didReceiveRooms:@[] error:error];
                }
            }
            [self.socketClient off:@"gn_list_rooms"];
            return;
        }
        
        NSArray *roomArray = data[0][@"data"][@"object"][@"attachments"];
        NSMutableArray *rooms = [@[] mutableCopy];
        for (NSDictionary *dic in roomArray) {
            IWDRoomModel *room = [[IWDRoomModel alloc] initWithDinoResponse:dic];
            [rooms addObject:room];
        }
        
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didReceiveRooms: error:)]) {
                [delegate didReceiveRooms:rooms error:nil];
            }
        }
        [self.socketClient off:@"gn_list_rooms"];
    }];
    
    [self.socketClient emit:@"list_rooms" with:@[@{@"verb":@"list", @"object":@{@"url":channelId}}]];
}

- (void)sendMessageWithRoomId:(NSString *)roomId
                   objectType:(NSString *)objectType
                      message:(NSString *)message
                   completion:(void (^)(IWDMessageModel *message, IWDError *error))completion {
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  send_message  <<<<<<<<<<<<<<<<<<<<<<<<<");
    NSString *base64Message = [[message dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    [self.socketClient on:@"gn_message" callback:^(NSArray *data, SocketAckEmitter *ack) {
        if (completion) {
            IWDError *error = [self errorFromResponse:data];
            if(error){
                completion(nil, error);
            }else {
                IWDMessageModel *message = [[IWDMessageModel alloc] initWithDinoResponse:data[0][@"data"]];
                completion(message, nil);
            }
        }
        [self.socketClient off:@"gn_message"];
    }];
    NSArray *dataArray = @[@{@"verb":@"send", @"target":@{@"id":roomId, @"objectType":objectType}, @"object":@{@"content":base64Message}}];
    [self.socketClient emit:@"message" with:dataArray];
}


- (void)createPrivateRoomWithChannelId:(NSString *)channelId
                                userId:(NSString *)userId1
                            userId2:(NSString *)userId2
                           roomName:(NSString *)roomName
                         completion:(IWDRoomCreateBlock)completion {
    
    [self.socketClient on:@"gn_create" callback:^(NSArray *data, SocketAckEmitter *ack) {
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
        [self.socketClient off:@"gn_create"];
    }];
    
    
    NSMutableString *summary = [NSMutableString stringWithFormat:@"%@,%@", userId1, userId2];
    NSDictionary *createModel = @{ @"verb":@"create",
                                   @"object":@{@"url":@"6cba7e00-6b0e-4bee-ad59-98bf90813fd0"},
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
    [self.socketClient on:@"gn_remove_room" callback:^(NSArray *data, SocketAckEmitter *ack) {
        if (completion) {
            IWDError *error = [self errorFromResponse:data];
            completion(error);
        }
        [self.socketClient off:@"gn_remove_room"];
    }];
    
    [self.socketClient emit:@"remove_room" with: @[@{@"verb" : @"remove", @"target" : @{@"id" : roomId}}]];
}


- (void)joinRoom:(NSString *)roomId {
    [self.socketClient on:@"gn_join" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_join  <<<<<<<<<<<<<<<<<<<<<<<<<");
        IWDError *error = [self errorFromResponse:data];
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didJoin:)]) {
                [delegate didJoin:error];
            }
        }
        [self.socketClient off:@"gn_join"];
    }];
    
    [self.socketClient emit:@"join" with:@[@{@"verb":@"join", @"target":@{@"id":roomId}}]];
}

- (void)getHistoryWithRoomId:(NSString *)roomId updatedTime:(NSString *)updateTime {
    [self.socketClient on:@"gn_history" callback:^(NSArray *data, SocketAckEmitter *ack) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_create  <<<<<<<<<<<<<<<<<<<<<<<<<");
        [self.socketClient off:@"gn_history"];
    }];
    updateTime = updateTime ? : [self.rcfDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-3600]];
    [self.socketClient emit:@"history" with:@[@{@"verb":@"list", @"updated":updateTime ,@"target":@{@"id":roomId, @"objectType":@"private"}}]];
}

- (void)sentAckReceived:(NSString *)roomId messages:(NSArray<IWDMessageModel *> *)messages {
    
    NSMutableArray *messageArray = [@[] mutableCopy];
    for (IWDMessageModel *message in messages) {
        [messageArray addObject:@{@"id" : message.uid}];
    }
    NSDictionary *emitObject = @{@"verb" : @"receive", @"target" : @{@"id" : roomId}, @"object":@{@"attachments" : messageArray}};
    [self.socketClient emit:@"received" with: @[emitObject]];
}

- (void)sentAckRead:(NSString *)roomId messages:(NSArray<IWDMessageModel *> *)messages {

    NSMutableArray *messageArray = [@[] mutableCopy];
    for (IWDMessageModel *message in messages) {
        [messageArray addObject:@{@"id" : message.uid}];
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

- (void)addDelegate:(id)delegate {
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id)delegate {
    if ([self.delegates containsObject: delegate]) {
        [self.delegates removeObject: delegate];
    }
}

- (void)removeAllDelegates {
    [self.delegates removeAllObjects];
}


#pragma mark - getter / setter
- (SocketManager *)socketManager {
    if (!_socketManager) {
        NSURL* url = [[NSURL alloc] initWithString:@"http://10.60.1.124:9210/ws"];
        _socketManager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log":@NO,
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


- (NSMutableArray *)delegates {
    if (!_delegates) {
        _delegates = [@[] mutableCopy];
    }
    return _delegates;
}

@end


@implementation IWDError

@end
