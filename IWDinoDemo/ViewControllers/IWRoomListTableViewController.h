//
//  IWRoomListTableViewController.h
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWDRoomModel.h"
#import "IWDChannelModel.h"
#import "IWCoreService.h"
@interface IWRoomListTableCell: UITableViewCell
- (void)applyRoom:(IWDRoomModel *)room;
@end

@interface IWRoomListTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IWDChannelModel *channel;
@property (nonatomic, strong) NSMutableArray *roomArray;
@end
