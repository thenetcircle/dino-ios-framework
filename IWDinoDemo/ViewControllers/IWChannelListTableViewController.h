//
//  IWChannelListTableViewController.h
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWChannelModel.h"
#import "IWCoreService.h"
@interface IWChannelListTableCell: UITableViewCell
- (void)applyChannelName:(IWChannelModel *)channel;
@end


@interface IWChannelListTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *channelArray;
@end
