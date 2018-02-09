//
//  IWDinoService.h
//  Dino
//
//  Created by Devin Zhang on 19/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWDRoomModel.h"
#import "IWDChannelModel.h"
#import "IWDMessageModel.h"
#import "IWDLoginModel.h"
@import SocketIO;
@interface IWDError : NSError
@end

@protocol IWDinoServiceDelegate

@optional
- (void)df_didReceiveChannels:(NSArray *)data;
- (void)df_didReceiveRooms:(NSArray *)data;
- (void)df_didReceiveMessages:(NSArray *)data;
- (void)df_didMessagesDelivered:(NSArray *)data;
- (void)df_didMessagesRead:(NSArray *)data;
- (void)df_didLogin:(NSArray *)data;
- (void)df_didJoin:(NSArray *)data;

- (void)didConnected:(IWDError *)error;
- (void)didReceiveChannels:(NSArray<IWDChannelModel *> *)channels error:(IWDError *)error;
- (void)didReceiveRooms:(NSArray<IWDRoomModel *> *)rooms error:(IWDError *)error;
- (void)didReceiveMessages:(NSArray<IWDMessageModel *> *)messages error:(IWDError *)error;
- (void)didMessagesDelivered:(NSArray<IWDMessageModel *> *)messages error:(IWDError *)error;
- (void)didMessagesRead:(NSArray<IWDMessageModel *> *)messages error:(IWDError *)error;
- (void)didLogin:(IWDError *)error;
- (void)didJoin:(IWDError *)error;
@end

typedef void (^IWDBlock_DF)(NSArray *array);
typedef void (^IWDBlock)(IWDError *error);
typedef void (^IWDDataWithErrorBlock)(NSArray *array, IWDError *error);
typedef void (^IWDRoomCreateBlock)(IWDRoomModel *room, IWDError *error);
typedef void (^IWDMessagesBlock)(NSArray<IWDMessageModel *> *messages, IWDError *error);

@interface IWDinoService : NSObject
@property (nonatomic, strong) SocketIOClient    *socketClient;
@property (nonatomic, assign) id delegate;

+ (instancetype)sharedInstance;

- (void)connectWithServerAddress:(NSString *)address nameSpace:(NSString *)nameSpace;
- (void)disconnect;

- (void)addListeners;
- (void)loginWithLoginModel:(IWDLoginModel *)loginModel;
- (void)listChannels;
- (void)listRoomsWithChannelId:(NSString *)channelId;
- (void)createPrivateRoomWithChannelId:(NSString *)channelId
                                userId:(NSString *)userId1
                               userId2:(NSString *)userId2
                              roomName:(NSString *)roomName
                            completion:(IWDRoomCreateBlock)completion;
- (void)joinRoom:(NSString *)roomId;
- (void)removeRoom:(NSString *)roomId completion:(IWDBlock)completion;
- (void)sendMessageWithRoomId:(NSString *)roomId
                   objectType:(NSString *)objectType
                      message:(NSString *)message
                   completion:(void (^)(IWDMessageModel *message, IWDError *error))completion;
- (void)df_sendMessageWithRoomId:(NSString *)roomId
                      objectType:(NSString *)objectType
                         message:(NSString *)message
                      completion:(IWDBlock_DF)completion;
- (void)getHistoryWithRoomId:(NSString *)roomId updatedTime:(NSString *)updateTime completion:(IWDMessagesBlock)completion;
- (void)sentAckReceived:(NSString *)roomId messages:(NSArray *)messages;
- (void)sentAckRead:(NSString *)roomId messages:(NSArray *)messages;
- (void)checkStatusOfMessages:(NSArray *)messageIds targetUserId:(NSString *)userId completion:(IWDDataWithErrorBlock)completion;
@end
