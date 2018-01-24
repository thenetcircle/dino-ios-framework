//
//  IWDChannelModel.m
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import "IWDChannelModel.h"

@implementation IWDChannelModel

- (instancetype)initWithDinoResponse:(NSDictionary *)dic {
    
    _uid = dic[@"id"];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:dic[@"displayName"] options:0];
    _displayName = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return self;
}


@end
