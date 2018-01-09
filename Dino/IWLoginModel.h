//
//  IWLoginModel.h
//  Dino
//
//  Created by Devin Zhang on 18/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWAttachment : NSObject
@property (nonatomic, strong) NSString *objectType;
@property (nonatomic, strong) NSString *content;

- (NSDictionary *)dictionary;
@end


@interface IWActorModel : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSMutableArray<IWAttachment *> *attachments;

- (NSDictionary *)dictionary;
@end

@interface IWLoginModel : NSObject

@property (nonatomic, strong) NSString *verb;
@property (nonatomic, strong) IWActorModel *actor;

- (instancetype)initWithToken:(NSString *)token userId:(NSString *)userId displayName:(NSString *)displayName;
- (NSDictionary *)dictionary;
@end
