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
    IBOutlet    UILabel         *_user1IdLabel;
    IBOutlet    UILabel         *_user2IdLabel;
    IBOutlet    UITextField     *_user1TokenField;
    IBOutlet    UITextField     *_user2TokenField;
    IBOutlet    UITextField     *_roomIdField;
    IBOutlet    UITextField     *_channelIdField;
    IBOutlet    UITextField     *_messageField;
    IBOutlet    UITextField     *_roomIdForMessageField;
    IBOutlet    UITextField     *_roomIdForHistoryField;
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


- (IBAction)user1Login:(UIButton *)button {
    
    IWLoginModel *model = [[IWLoginModel alloc] initWithToken:_user1TokenField.text userId:_user1IdLabel.text displayName:@"cool"];
    [self.socketService loginWithLoginModel:model];
    
}

- (IBAction)listRooms:(UIButton *)button {
    [self.socketService listRoomsWithChannelId:_channelIdField.text];
}

- (IBAction)listChannels:(UIButton *)button {
    [self.socketService listChannels];
}


- (IBAction)user2Login:(UIButton *)button {
    IWLoginModel *model = [[IWLoginModel alloc] initWithToken:_user2TokenField.text userId:_user2IdLabel.text displayName:@"kkk"];
    [self.socketService loginWithLoginModel:model];
}

- (IBAction)createRoom:(UIButton *)button {
    [self.socketService createPrivateRoomWithUserId:_user1IdLabel.text userId2:_user2IdLabel.text];
}

- (IBAction)joinRoom:(UIButton *)button {
    [self.socketService joinRoom:_roomIdField.text];
}

- (IBAction)sendMessage:(UIButton *)button {
    [self.socketService sendMessageWithRoomId:_roomIdForMessageField.text objectType:@"private" message:_messageField.text];
}

- (IBAction)getHistory:(UIButton *)button {
    [self.socketService getHistoryWithRoomId:_roomIdForHistoryField.text updatedTime:@"2018-01-09T15:00:00Z"];
}

- (IWDinoService *)socketService {
    if (!_socketService) {
        _socketService = [[IWDinoService alloc] init];
    }
    return _socketService;
}

@end
