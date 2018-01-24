//
//  IWDChannelModel.h
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWDChannelModel : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *displayName;

- (instancetype)initWithDinoResponse:(NSDictionary *)dic;

@end
