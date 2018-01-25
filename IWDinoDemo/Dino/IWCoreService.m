//
//  IWCoreService.m
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import "IWCoreService.h"
#import "IWDinoService.h"
#import "IWDUserModel.h"
#define IW_DINO_SERVICE_ADDRESS @"http://10.60.1.124:9210/ws"
#define IW_DINO_NAME_SPACE @"/ws"

@interface IWCoreService()

@end

@implementation IWCoreService
DEF_SINGLETON
- (instancetype)init {
    if (self = [super init]) {
        self.dinoService = [IWDinoService sharedInstance];
        [self.dinoService connectWithServerAddress:IW_DINO_SERVICE_ADDRESS nameSpace:IW_DINO_NAME_SPACE];
    }
    return self;
}


@end
