//
//  IWCoreService.h
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//
#define AS_SINGLETON \
+ (instancetype)sharedInstance;

#define DEF_SINGLETON \
+ (instancetype)sharedInstance \
{ \
static dispatch_once_t once; \
static id __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
return __singleton__; \
};


#import <Foundation/Foundation.h>
@class IWDinoService;
@class IWDUserModel;

@interface IWCoreService : NSObject
@property (nonatomic, strong) IWDinoService *dinoService;
@property (nonatomic, strong) IWDUserModel *currentUser;
AS_SINGLETON;
@end
