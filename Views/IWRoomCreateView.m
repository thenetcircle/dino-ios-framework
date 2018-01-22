//
//  IWRoomCreateView.m
//  Dino
//
//  Created by Devin Zhang on 22/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import "IWRoomCreateView.h"
@interface IWRoomCreateView() {
    IBOutlet UITextField *_fieldTargetUserId;
    IBOutlet UITextField *_fieldRoomName;
}
@end

@implementation IWRoomCreateView

- (IBAction)createRoom:(UIButton *)button {
    if (_delegate) {
        [_delegate createButtonPressed:_fieldTargetUserId.text roomName:_fieldRoomName.text];
    }
    [self hideScreen:nil];
}


- (IBAction)hideScreen:(UIButton *)button {
    self.hidden = YES;
}

@end
