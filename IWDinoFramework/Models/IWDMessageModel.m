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

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        _uid = dic[@"id"];
        _content = dic[@"content"];
    }
    return self;
}

- (NSString *)displayStatus {
    switch (self.status.integerValue) {
        case IWDMessageStatusUnknown:
            return @"Unknown";
            break;
        case IWDMessageStatusSending:
            return @"Sending";
            break;
        case IWDMessageStatusSent:
            return @"Sent";
            break;
        case IWDMessageStatusDelivered:
            return @"Delivered";
            break;
        case IWDMessageStatusRead:
            return @"Read";
            break;
        default:
            break;
    }
    return @"Unknown";
}
@end