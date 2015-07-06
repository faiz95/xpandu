//
//  MainViewController.h
//  SimpleSample-videochat-ios
//
//  Created by QuickBlox team on 1/02/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//
//
// This class demonstrates how to work with VideoChat API.
// It shows how to setup video conference between 2 users
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MainViewController : UIViewController <QBChatDelegate, AVAudioPlayerDelegate, UIAlertViewDelegate,UIActionSheetDelegate>{
    IBOutlet UIButton *callButton;
    IBOutlet UILabel *ringigngLabel;
    IBOutlet UIActivityIndicatorView *callingActivityIndicator;
    IBOutlet UIActivityIndicatorView *startingCallActivityIndicator;
    IBOutlet UIImageView *opponentVideoView;
    IBOutlet UIImageView *myVideoView;
    IBOutlet UINavigationBar *navBar;
    IBOutlet UISegmentedControl *audioOutput;
    IBOutlet UISegmentedControl *videoOutput;
    NSArray * array;
    AVAudioPlayer *ringingPlayer;
    NSMutableArray * arrayForName;
    IBOutlet UILabel *VideoOutputLbl;

    IBOutlet UIButton * btnSelectUser;
    //
    NSUInteger videoChatOpponentID;
    enum QBVideoChatConferenceType videoChatConferenceType;
    NSString *sessionID;
    IBOutlet UILabel *lblTittle;
    IBOutlet UIButton * NxtBtn;
}

@property (strong) NSNumber *opponentID;
@property (strong) QBVideoChat *videoChat;
@property (strong) QBUUser *opponentUser;
@property (strong) UIAlertView *callAlert;
@property (strong) NSArray * array;
- (IBAction)addFriendAction:(id)sender;
- (IBAction)friendProfileAccount:(id)sender;
- (IBAction)reportAction:(id)sender;

- (IBAction)call:(id)sender;
- (IBAction)nxt:(id)sender;

- (void)reject;
- (void)accept;

@end
