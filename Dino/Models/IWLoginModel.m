//
//  IWLoginModel.m
//  Dino
//
//  Created by Devin Zhang on 18/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import "IWLoginModel.h"

@implementation IWAttachment

- (instancetype)initWithToken:(NSString *)token {
    if (self = [super init]) {
        _content = token;
        _objectType = @"token";
    }
    return self;
}

- (NSDictionary *)dictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.content, @"content", self.objectType, @"objectType", nil];
}


@end

@implementation IWActorModel

- (instancetype)initWithUserId:(NSString *)userId displayName:(NSString *)displayName token:(NSString *)token {
    if (self = [super init]) {
        _uid = userId;
        _displayName = [[displayName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        IWAttachment *attachment = [[IWAttachment alloc] initWithToken:token];
        _attachments = [NSMutableArray arrayWithObject:attachment];
    }
    return self;
}

- (NSDictionary *)dictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.uid, @"id", self.displayName, @"displayName", @[[self.attachments.firstObject dictionary]], @"attachments", nil];
}

- (NSMutableArray *)attachments {
    if (!_attachments) {
        _attachments = [@[] mutableCopy];
    }
    return _attachments;
}

@end

@implementation IWLoginModel

- (instancetype)initWithToken:(NSString *)token userId:(NSString *)userId displayName:(NSString *)displayName {
    if (self = [super init]) {
        _verb = @"login";
        _actor = [[IWActorModel alloc] initWithUserId:userId displayName:displayName token:token];
    }
    return self;
}

- (NSDictionary *)dictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.verb, @"verb", [self.actor dictionary], @"actor", nil];
}


@end

