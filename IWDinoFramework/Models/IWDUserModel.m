//
//  IWDinoUser.m
//  Dino
//
//  Created by Devin Zhang on 19/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import "IWDUserModel.h"

@implementation IWDUserModel
- (instancetype)initWithUid:(NSString *)uid token:(NSString *)token displayName:(NSString *)displayName {
    if (self = [super init]) {
        _uid = uid;
        _displayName = displayName;
        _token = token;
    }
    return self;
}
- (instancetype)initWithDinoResponse:(NSDictionary *)dic {
    if (self = [super init]) {
        _uid = dic[@"id"];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:dic[@"displayName"] options:0];
        _displayName = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        _token = dic[@"id"];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object class] != [self class]) {
        return NO;
    }
    if ([((IWDUserModel *)object).uid isEqualToString:_uid]) {
        return YES;
    }
    return NO;
}

@end
