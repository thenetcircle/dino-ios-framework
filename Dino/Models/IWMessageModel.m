//
//  IWMessageModel.m
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import "IWMessageModel.h"
#import "IWDinoUserModel.h"

@implementation IWMessageModel

- (instancetype)initWithDinoResponse:(NSDictionary *)dic {
    
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
        _sender = [[IWDinoUserModel alloc] initWithUid:dic[@"actor"][@"id"] token:nil displayName:displayName];
    }
    
    return self;
}
@end
