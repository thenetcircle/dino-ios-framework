//
//  IWRoomListTableViewController.h
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWRoomModel.h"
#import "IWChannelModel.h"
#import "IWCoreService.h"
@interface IWRoomListTableCell: UITableViewCell
- (void)applyRoom:(IWRoomModel *)room;
@end

@interface IWRoomListTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IWChannelModel *channel;
@property (nonatomic, strong) NSMutableArray *roomArray;
@end
