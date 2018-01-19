//
//  IWRoomListTableViewController.m
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import "IWRoomListTableViewController.h"
#import "IWChatViewController.h"

#define IWRoomListTableCellIdentifier @"IWRoomListTableCellIdentifier"

@interface IWRoomListTableCell () {
    IBOutlet    UILabel     *_labelRoomName;
}
@end

@implementation IWRoomListTableCell
- (void)applyRoom:(IWRoomModel *)room {
    _labelRoomName.text = room.displayName;
}
@end

@interface IWRoomListTableViewController ()

@end

@implementation IWRoomListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
    IWRoomModel *room = self.roomArray[indexPath.row];
    [self performSegueWithIdentifier:@"IWChatViewControllerSegue" sender:room];
}


#pragma mark - getter / setter
- (void)setRoomArray:(NSMutableArray *)roomArray {
    if (_roomArray != roomArray) {
        _roomArray = roomArray;
        [self.tableView reloadData];
    }
}
@end
