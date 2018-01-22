//
//  IWRoomCreateView.h
//  Dino
//
//  Created by Devin Zhang on 22/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol IWRoomCreateViewDelegate
- (void)createButtonPressed:(NSString *)targetUserId roomName:(NSString *)roomName;
@end

@interface IWRoomCreateView : UIView

@property (nonatomic, assign) id<IWRoomCreateViewDelegate> delegate;

@end
