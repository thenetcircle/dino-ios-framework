//
//  IWRoomListTableViewController.h
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWRoomModel.h"
@interface IWRoomListTableCell: UITableViewCell
- (void)applyRoom:(IWRoomModel *)room;
@end

@interface IWRoomListTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *roomArray;
@end
