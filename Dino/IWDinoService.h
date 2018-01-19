//
//  IWDinoService.h
//  Dino
//
//  Created by Devin Zhang on 19/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWCoreService.h"
@class IWLoginModel;
@class IWChannelModel;
@class IWRoomModel;
@class IWMessageModel;

@interface IWDError : NSError
@end

@protocol IWDinoServiceDelegate

@optional
- (void)didReceiveChannels:(NSArray<IWChannelModel *> *)channels;
- (void)didReceiveRooms:(NSArray<IWRoomModel *> *)rooms;
- (void)didReceiveMessages:(NSArray<IWMessageModel *> *)messages;
- (void)didLogin:(BOOL)succeed;
- (void)didJoin:(BOOL)succeed;
@end

typedef void (^IWDAckBlock)(IWDError *error);
@interface IWDinoService : NSObject
AS_SINGLETON;

- (void)addDelegate:(id)delegate;

- (void)connect;
- (void)disconnect;

- (void)loginWithLoginModel:(IWLoginModel *)loginModel;
- (void)listChannels;
- (void)listRoomsWithChannelId:(NSString *)channelId;
- (void)createPrivateRoomWithUserId:(NSString *)userId1 userId2:(NSString *)userId2 roomName:(NSString *)roomName;
- (void)joinRoom:(NSString *)roomId;
- (void)sendMessageWithRoomId:(NSString *)roomId
                   objectType:(NSString *)objectType
                      message:(NSString *)message
                   completion:(void (^)(IWMessageModel *message, IWDError *error))completion;
- (void)getHistoryWithRoomId:(NSString *)roomId updatedTime:(NSString *)updateTime;

- (void)sentAckReceived:(NSString *)roomId messages:(NSArray<IWMessageModel *> *)messages completion:(IWDAckBlock)completion;
- (void)sentAckRead:(NSString *)roomId messages:(NSArray<IWMessageModel *> *)messages completion:(IWDAckBlock)completion;
@end
