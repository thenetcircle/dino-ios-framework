//
//  IWRoomListTableViewController.m
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import "IWRoomListTableViewController.h"
#import "IWChatViewController.h"
#import "IWRoomCreateView.h"
#import "IWDUserModel.h"

#define IWRoomListTableCellIdentifier @"IWRoomListTableCellIdentifier"

@interface IWRoomListTableCell () {
    IBOutlet    UILabel     *_labelRoomName;
}
@end

@implementation IWRoomListTableCell
- (void)applyRoom:(IWDRoomModel *)room {
    _labelRoomName.text = room.displayName;
}
@end

@interface IWRoomListTableViewController ()<IWRoomCreateViewDelegate>
@property (nonatomic, strong) IWRoomCreateView *roomCreateView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation IWRoomListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *roomCreateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showRoomCreate)];
    self.navigationItem.rightBarButtonItem = roomCreateButton;
}

- (void)showRoomCreate {
    self.roomCreateView.hidden = NO;
}

- (void)createButtonPressed:(NSString *)targetUserId roomName:(NSString *)roomName {
    [[IWDinoService sharedInstance] createPrivateRoomWithChannelId:self.channel.uid
                                                            userId:[IWCoreService sharedInstance].currentUser.uid
                                                        userId2:targetUserId
                                                       roomName:roomName
                                                     completion:^(IWDRoomModel *room, IWDError *error) {
                                                         if (!error) {
                                                             
                                                             NSIndexPath *index = [NSIndexPath indexPathForRow:self.roomArray.count inSection:0];
                                                             [self.roomArray addObject:room];
                                                             [self.tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                             [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                                                         }else {
                                                             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                                                            message:error.domain
                                                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                                             
                                                             [alert addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil]];
                                                             [self presentViewController:alert animated:YES completion:nil];
                                                         }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    IWChatViewController *vc = (IWChatViewController *)segue.destinationViewController;
    vc.room = sender;   
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IWRoomListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:IWRoomListTableCellIdentifier forIndexPath:indexPath];
    [cell applyRoom:self.roomArray[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IWDRoomModel *room = self.roomArray[indexPath.row];
    [self performSegueWithIdentifier:@"IWChatViewControllerSegue" sender:room];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    IWDRoomModel *room = self.roomArray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[IWDinoService sharedInstance] removeRoom:room.uid completion:^(IWDError *error) {
            if (!error) {
                [self.roomArray removeObjectAtIndex:indexPath.row];
                [self.tableView reloadData];
            }else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:error.domain
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
}


#pragma mark - getter / setter
- (void)setRoomArray:(NSMutableArray *)roomArray {
    if (_roomArray != roomArray) {
        _roomArray = roomArray;
        [self.tableView reloadData];
    }
}

- (IWRoomCreateView *)roomCreateView {
    if (!_roomCreateView) {
        _roomCreateView = [[NSBundle mainBundle] loadNibNamed:@"IWRoomCreateView" owner:self options:0][0];
        _roomCreateView.frame = self.view.bounds;
        _roomCreateView.hidden = YES;
        _roomCreateView.delegate = self;
        [self.view addSubview:_roomCreateView];
    }
    return _roomCreateView;
}
@end
