//
//  IWDMessageModel.m
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import "IWDMessageModel.h"
#import "IWDUserModel.h"

@implementation IWDMessageModel

- (instancetype)initWithDinoResponse:(NSDictionary *)dic {
    if (self = [super init]) {
        if (dic[@"object"]) {
            _uid = dic[@"object"][@"url"];
            _roomId = dic[@"object"][@"roomId"];
            if (dic[@"object"][@"content"] && ![dic[@"object"][@"content"] isEqual:[NSNull null]]) {
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:dic[@"object"][@"content"] options:0];
                _content = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            }
        }
        if (dic[@"actor"]) {
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:dic[@"actor"][@"displayName"] options:0];
            NSString *displayName = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            _sender = [[IWDUserModel alloc] initWithUid:dic[@"actor"][@"id"] token:nil displayName:displayName];
        }
    }
    
    return self;
}

- (instancetype)initWithHistoryResponseDic:(NSDictionary *)dic {
    _uid = dic[@"id"];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:dic[@"content"] options:0];
    _content = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    _status = @2;
    if (dic[@"author"]) {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:dic[@"author"][@"displayName"] options:0];
        NSString *displayName = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        _sender = [[IWDUserModel alloc] initWithUid:dic[@"author"][@"id"] token:nil displayName:displayName];
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        _uid = dic[@"id"];
        _content = dic[@"content"];
    }
    return self;
}

- (NSString *)displayStatus {
    switch (self.status.integerValue) {
        case IWDMessageStatusNotAcked:
            return @"NotAcked";
            break;
        case IWDMessageStatusSent:
            return @"Sent";
            break;
        case IWDMessageStatusReceived:
            return @"Received";
            break;
        case IWDMessageStatusRead:
            return @"Read";
            break;
        case IWDMessageStatusFailed:
            return @"Failed";
            break;
        default:
            break;
    }
    return @"Unknown";
}
@end
