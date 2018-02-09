//
//  IWDMessageModel.h
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IWDUserModel;
@class IWDRoomModel;

typedef NS_ENUM(NSInteger, IWDMessageStatus) {
    IWDMessageStatusNotAcked = 0,
    IWDMessageStatusReceived = 1,
    IWDMessageStatusRead = 2,
    IWDMessageStatusSent = 3,
    IWDMessageStatusFailed = 4
};

@interface IWDMessageModel : NSObject
@property (nonatomic, copy)         NSString        *uid;
@property (nonatomic, copy)         NSString        *content;
@property (nonatomic, copy)         NSString        *roomId;
@property (nonatomic, strong)       NSNumber        *status;
@property (nonatomic, readonly)     NSString        *displayStatus;
@property (nonatomic, strong)   IWDUserModel        *sender;

- (instancetype)initWithDic:(NSDictionary *)dic;
- (instancetype)initWithDinoResponse:(NSDictionary *)dic;
- (instancetype)initWithHistoryResponseDic:(NSDictionary *)dic;
@end
