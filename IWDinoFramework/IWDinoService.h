//
//  IWDinoService.h
//  Dino
//
//  Created by Devin Zhang on 19/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWRoomModel.h"
#import "IWChannelModel.h"
#import "IWMessageModel.h"
#import "IWLoginModel.h"

@interface IWDError : NSError
@end

@protocol IWDinoServiceDelegate

@optional
- (void)didReceiveChannels:(NSArray<IWChannelModel *> *)channels error:(IWDError *)error;
- (void)didReceiveRooms:(NSArray<IWRoomModel *> *)rooms error:(IWDError *)error;
- (void)didReceiveMessages:(NSArray<IWMessageModel *> *)messages error:(IWDError *)error;
- (void)didMessagesDelivered:(NSArray<IWMessageModel *> *)messages error:(IWDError *)error;
- (void)didMessagesRead:(NSArray<IWMessageModel *> *)messages error:(IWDError *)error;
- (void)didLogin:(IWDError *)error;
- (void)didJoin:(IWDError *)error;
@end

typedef void (^IWDBlock)(IWDError *error);
typedef void (^IWDRoomCreateBlock)(IWRoomModel *room, IWDError *error);
@interface IWDinoService : NSObject

+ (instancetype)sharedInstance;
- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;
- (void)removeAllDelegates;

- (void)connect;
- (void)disconnect;

- (void)loginWithLoginModel:(IWLoginModel *)loginModel;
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
                   completion:(void (^)(IWMessageModel *message, IWDError *error))completion;
- (void)getHistoryWithRoomId:(NSString *)roomId updatedTime:(NSString *)updateTime;

- (void)sentAckReceived:(NSString *)roomId messages:(NSArray<IWMessageModel *> *)messages;
- (void)sentAckRead:(NSString *)roomId messages:(NSArray<IWMessageModel *> *)messages;
@end
