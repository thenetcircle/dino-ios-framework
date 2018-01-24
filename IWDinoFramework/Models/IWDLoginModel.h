//
//  IWDLoginModel.h
//  Dino
//
//  Created by Devin Zhang on 18/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWDAttachment : NSObject
@property (nonatomic, strong) NSString *objectType;
@property (nonatomic, strong) NSString *content;

- (NSDictionary *)dictionary;
@end


@interface IWDActorModel : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSMutableArray<IWDAttachment *> *attachments;

- (NSDictionary *)dictionary;
@end

@interface IWDLoginModel : NSObject

@property (nonatomic, strong) NSString *verb;
@property (nonatomic, strong) IWDActorModel *actor;

- (instancetype)initWithToken:(NSString *)token userId:(NSString *)userId displayName:(NSString *)displayName;
- (NSDictionary *)dictionary;
@end
