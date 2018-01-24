//
//  IWChatViewController.m
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import "IWChatViewController.h"
#import "IWDUserModel.h"
#define IWChatListTableCellIndentifier @"IWChatListTableCellIndentifier"

@interface IWChatListTableCell() {
    IBOutlet    UILabel     *_labelMessage;
    IBOutlet    UILabel     *_lableMessageStatus;
}

@end

@implementation IWChatListTableCell
- (void)applyMessage:(IWDMessageModel *)message {
    if ([self isSentByMyself:message]) {
        _labelMessage.textAlignment = NSTextAlignmentRight;
    }else {
        _labelMessage.textAlignment = NSTextAlignmentLeft;
    }
    _lableMessageStatus.hidden = ![self isSentByMyself:message];
    _lableMessageStatus.text = message.displayStatus;
    _labelMessage.text = message.content;
}

- (BOOL)isSentByMyself:(IWDMessageModel *)message {
    if ([message.sender isEqual:[IWCoreService sharedInstance].currentUser]) {
        return YES;
    }
    return NO;
}
@end



@interface IWChatViewController ()<UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView    *_tableView;
    IBOutlet UITextField    *_labelMessage;
    IBOutlet UIButton       *_buttonSend;
}
@property (nonatomic, strong) NSMutableArray *messageArray;
@end

@implementation IWChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[IWDinoService sharedInstance] addDelegate:self];
    _labelMessage.enabled = NO;
    _buttonSend.enabled = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveMessages:(NSArray<IWDMessageModel *> *)messages error:(IWDError *)error {
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:error.domain
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSMutableArray *messagesFromOthersForCurrentRoom = [@[] mutableCopy];
    for (IWDMessageModel *message in messages) {
        if (![message.roomId isEqualToString:self.room.uid] || [message.sender.uid isEqualToString:[IWCoreService sharedInstance].currentUser.uid]) {
            continue;
        }
        [messagesFromOthersForCurrentRoom addObject:message];
    }
    if (messagesFromOthersForCurrentRoom.count == 0) {
        return;
    }
    [[IWDinoService sharedInstance] sentAckRead:self.room.uid messages:messagesFromOthersForCurrentRoom];
//    [[IWDinoService sharedInstance] sentAckReceived:self.room.uid messages:messagesFromOthersForCurrentRoom];
    [self addMessages:messagesFromOthersForCurrentRoom];
}

- (void)didMessagesDelivered:(NSArray<IWDMessageModel *> *)messages error:(IWDError *)error {
    if (error) {
        return;
    }
    for (IWDMessageModel *msg in self.messageArray) {
        for (IWDMessageModel *message in messages) {
            if ([msg.uid isEqualToString:message.uid]) {
                msg.status = @(IWDMessageStatusDelivered);
                [self updateMessageStatus:msg];
            }
        }
    }
}

- (void)didMessagesRead:(NSArray<IWDMessageModel *> *)messages error:(IWDError *)error {
    if (error) {
        return;
    }
    for (IWDMessageModel *msg in self.messageArray) {
        for (IWDMessageModel *message in messages) {
            if ([msg.uid isEqualToString:message.uid]) {
                msg.status = @(IWDMessageStatusRead);
                [self updateMessageStatus:msg];
            }
        }
    }
}

- (void)updateMessageStatus:(IWDMessageModel *)message {
    NSInteger row = [self.messageArray indexOfObject:message];
    IWChatListTableCell *cell = [_tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:row inSection:0]];
    [cell applyMessage:message];
}


- (IBAction)send:(UIButton *)button {
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  button send  <<<<<<<<<<<<<<<<<<<<<<<<<");
    [[IWCoreService sharedInstance].dinoService sendMessageWithRoomId:self.room.uid objectType:@"private" message:_labelMessage.text completion:^(IWDMessageModel *message, IWDError *error) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>  gn_message  <<<<<<<<<<<<<<<<<<<<<<<<<");
        if (!error) {
            message.sender = [IWCoreService sharedInstance].currentUser;
            message.status = @(IWDMessageStatusSent);
            _labelMessage.text = @"";
            [self addMessages:@[message]];
        }
    }];
}

- (void)didJoin:(IWDError *)error {
    if (!error) {
        _labelMessage.enabled = YES;
        _buttonSend.enabled = YES;
    }else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:error.domain
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)addMessages:(NSArray<IWDMessageModel *> *)messages {
    NSMutableArray *indexPaths = [@[] mutableCopy];
    for (int i = 0; i < messages.count; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:self.messageArray.count + i inSection:0];
        [indexPaths addObject:path];
    }
    [self.messageArray addObjectsFromArray:messages];
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0]
                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma  mark - tableview delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IWDMessageModel *message = self.messageArray[indexPath.row];
    IWChatListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IWChatListTableCellIdentifier"];
    [cell applyMessage:message];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0 )];
}

#pragma  mark - getter / setter
- (void)setRoom:(IWDRoomModel *)room {
    if (_room != room) {
        _room = room;
        [[IWDinoService sharedInstance] joinRoom:self.room.uid];
    }
}

- (NSMutableArray *)messageArray {
    if (!_messageArray) {
        _messageArray = [@[] mutableCopy];
    }
    return _messageArray;
}
@end
