//
//  ViewController.m
//  Dino
//
//  Created by Devin Zhang on 12/12/2017.
//  Copyright © 2017 Ideawise Ltd. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+IWJSONTool.h"
#import "IWDinoService.h"
@import SocketIO;

@interface ViewController ()
@property (nonatomic, strong) SocketManager  *socketManager;
@property (nonatomic, strong) SocketIOClient *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self getDinoConnected];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getDinoConnected {
//    NSURL* url = [[NSURL alloc] initWithString:@"http://10.60.1.124:9210/ws"];
//    self.socketManager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log":@YES,
//                                                                                   @"forceNew":@YES,
//                                                                                   @"forcePolling":@YES,
//                                                                                   @"transports":@[@"websocket"]}];
//    self.socket = self.socketManager.defaultSocket;
//
//    [self.socket on:@"gn_connect" callback:^(NSArray *data, SocketAckEmitter *ack) {
//        NSLog(@"socket connected");
//    }];
//
//    [self.socket on:@"connect" callback:^(NSArray *data, SocketAckEmitter *ack) {
//        NSLog(@"socket connected");
//    }];
//
//
//    [self.socket connect];
    IWDinoService *service = [[IWDinoService alloc] init];
    [service connect];
}

@end
