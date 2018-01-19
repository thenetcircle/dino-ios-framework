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
#import "IWLoginModel.h"
@import SocketIO;

@interface ViewController ()
{
    IBOutlet    UITextField     *_userIdField;
    IBOutlet    UITextField     *_userTokenField;
    IBOutlet    UITextField     *_roomIdField;
    IBOutlet    UITextField     *_channelIdField;
    IBOutlet    UITextField     *_messageField;
    IBOutlet    UITextField     *_roomIdForMessageField;
    IBOutlet    UITextField     *_roomIdForHistoryField;
    IBOutlet    UITextField     *_roomNameForCreateRoomField;
}


@property (nonatomic, strong) IWDinoService  *socketService;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.socketService connect];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)userLogin:(UIButton *)button {
    
    IWLoginModel *model = [[IWLoginModel alloc] initWithToken:_userTokenField.text userId:_userIdField.text displayName:@"cool"];
    [self.socketService loginWithLoginModel:model];
    
}

- (IBAction)listRooms:(UIButton *)button {
    [self.socketService listRoomsWithChannelId:_channelIdField.text];
}

- (IBAction)listChannels:(UIButton *)button {
    [self.socketService listChannels];
}

- (IBAction)createRoom:(UIButton *)button {
    [self.socketService createPrivateRoomWithUserId:@"179906"
                                            userId2:@"179677"
                                           roomName:_roomNameForCreateRoomField.text];
}

- (IBAction)joinRoom:(UIButton *)button {
    [self.socketService joinRoom:_roomIdField.text];
}

- (IBAction)sendMessage:(UIButton *)button {
    [self.socketService sendMessageWithRoomId:_roomIdForMessageField.text
                                   objectType:@"private"
                                      message:_messageField.text
                                   completion:^(IWMessageModel *message, IWDError *error) {
        if (!error) {

        }
    }];
}

- (IBAction)getHistory:(UIButton *)button {
    [self.socketService getHistoryWithRoomId:_roomIdForHistoryField.text updatedTime:nil];
}

- (IWDinoService *)socketService {
    if (!_socketService) {
        _socketService = [[IWDinoService alloc] init];
    }
    return _socketService;
}

@end
