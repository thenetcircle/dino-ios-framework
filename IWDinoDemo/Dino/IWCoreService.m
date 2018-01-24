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

@interface IWCoreService()

@end

@implementation IWCoreService
DEF_SINGLETON
- (instancetype)init {
    if (self = [super init]) {
        self.dinoService = [IWDinoService sharedInstance];
    }
    return self;
}


@end
