//
//  IWDinoUser.h
//  Dino
//
//  Created by Devin Zhang on 19/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWDinoUserModel : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *token;

- (instancetype)initWithUid:(NSString *)uid token:(NSString *)token displayName:(NSString *)displayName;
- (instancetype)initWithDinoResponse:(NSDictionary *)dic;
@end
