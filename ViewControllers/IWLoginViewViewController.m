//
//  IWLoginViewViewController.m
//  Dino
//
//  Created by Devin Zhang on 18/01/2018.
//  Copyright © 2018 Ideawise Ltd. All rights reserved.
//

#import "IWLoginViewViewController.h"
#import "IWDinoService.h"
#import "IWChannelListTableViewController.h"
#import "IWLoginModel.h"
#import "IWDinoUserModel.h"

@interface IWLoginViewViewController ()<IWDinoServiceDelegate>
{
    IBOutlet    UITextField     *_fieldUserID;
    IBOutlet    UITextField     *_fieldToken;
    IBOutlet    UITextField     *_fieldDisplayName;
}
@end

@implementation IWLoginViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[IWDinoService sharedInstance] addDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    IWChannelListTableViewController *vc = (IWChannelListTableViewController *)segue.destinationViewController;
    vc.channelArray = sender;
}

- (void)didLogin:(BOOL)succeed {
    if (succeed) {
        
        IWDinoUserModel *user = [[IWDinoUserModel alloc] initWithUid:_fieldUserID.text
                                                               token:_fieldToken.text
                                                         displayName:_fieldDisplayName.text];
        [IWCoreService sharedInstance].currentUser = user;
        
        [self listChannels];
    }
}

- (void)didReceiveChannels:(NSArray *)channels {
    if (channels) {
        [self performSegueWithIdentifier:@"IWChannelListTableViewControllerSegue" sender:channels];
    }
}

- (IBAction)login:(UIButton *)button {
    
    IWLoginModel *model = [[IWLoginModel alloc] initWithToken:_fieldToken.text userId:_fieldUserID.text displayName:_fieldDisplayName.text];
    [[IWDinoService sharedInstance] loginWithLoginModel:model];
}

- (void)listChannels {
    [[IWDinoService sharedInstance] listChannels];
}
@end
