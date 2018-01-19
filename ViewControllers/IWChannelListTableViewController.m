//
//  IWChannelListTableViewController.m
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//
#import "IWChannelListTableViewController.h"
#import "IWDinoService.h"
#import "IWRoomListTableViewController.h"

#define IWChannelListTableCellIdentifier @"IWChannelListTableCellIdentifier"
@interface IWChannelListTableCell () {
    IBOutlet    UILabel     *_labelChannelName;
}
@end

@interface IWChannelListTableViewController()<IWDinoServiceDelegate>

@end

@implementation IWChannelListTableCell
- (void)applyChannelName:(IWChannelModel *)channel {
    _labelChannelName.text = channel.displayName;
}
@end


@interface IWChannelListTableViewController ()

@end

@implementation IWChannelListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[IWDinoService sharedInstance] addDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    IWRoomListTableViewController *vc = (IWRoomListTableViewController *)segue.destinationViewController;
    vc.roomArray = sender;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IWChannelListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:IWChannelListTableCellIdentifier forIndexPath:indexPath];
    [cell applyChannelName:self.channelArray[indexPath.row]];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IWChannelModel *channel = self.channelArray[indexPath.row];
    [[IWDinoService sharedInstance] listRoomsWithChannelId:channel.uid];
}

- (void)didReceiveRooms:(NSArray *)rooms {
    if (rooms) {
        [self performSegueWithIdentifier:@"IWRoomListTableViewControllerSegue" sender:rooms];
    }
}


#pragma mark - getter / setter
- (void)setChannelArray:(NSMutableArray *)channelArray {
    if (_channelArray != channelArray) {
        _channelArray = channelArray;
        [self.tableView reloadData];
    }
    
}
@end
