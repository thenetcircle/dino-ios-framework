//
//  IWChatViewController.h
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWDMessageModel.h"
#import "IWDinoService.h"
#import "IWDRoomModel.h"
#import "IWCoreService.h"

@interface IWChatListTableCell: UITableViewCell<IWDinoServiceDelegate>
- (void)applyMessage:(IWDMessageModel *)message;
@end

@interface IWChatViewController : UIViewController
@property (nonatomic, strong) IWDRoomModel *room;
@end
