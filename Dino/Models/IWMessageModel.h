//
//  IWMessageModel.h
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IWDinoUserModel;
@class IWRoomModel;

@interface IWMessageModel : NSObject
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, strong) IWDinoUserModel *sender;

- (instancetype)initWithDinoResponse:(NSDictionary *)dic;
@end
