//
//  IWDinoService.h
//  Dino
//
//  Created by Devin Zhang on 19/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IWLoginModel;

@interface IWDinoService : NSObject

- (void)connect;

- (void)loginWithLoginModel:(IWLoginModel *)loginModel;
- (void)listChannels;
- (void)listRoomsWithChannelId:(NSString *)channelId;
- (void)createPrivateRoomWithUserId:(NSString *)userId1 userId2:(NSString *)userId2;
- (void)sendMessageWithRoomId:(NSString *)roomId objectType:(NSString *)objectType message:(NSString *)message;
- (void)getHistoryWithRoomId:(NSString *)roomId updatedTime:(NSString *)updateTime;
- (void)joinRoom:(NSString *)roomId;
@end
