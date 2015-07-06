//
//  MainViewController.m
//  SimpleSample-videochat-ios
//
//  Created by QuickBlox team on 1/02/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "DialogsViewController.h"
#import "SSUUserCache.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize opponentID,array,opponentUser;

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    QBUUser *currentUser = [[SSUUserCache instance] currentUser];

    currentUser.login = appDelegate.uSerName;
    
    lblTittle.text =appDelegate.uSerName;
    opponentVideoView.layer.borderWidth = 1;
    opponentVideoView.layer.borderColor = [[UIColor grayColor] CGColor];
    opponentVideoView.layer.cornerRadius = 5;
    navBar.topItem.title = appDelegate.uSerName;
//    if ([kappDelegate CallerName]!=nil) {
//        [callButton setTitle:[NSString stringWithFormat:@"%@ %@",@"Call",[kappDelegate CallerName]] forState:UIControlStateNormal];
//        
//    }

    [callButton setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateNormal];
    [callButton setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateHighlighted];
    if(!QB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        audioOutput.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        audioOutput.frame = CGRectMake(audioOutput.frame.origin.x-15, audioOutput.frame.origin.y, audioOutput.frame.size.width+50, audioOutput.frame.size.height);
        videoOutput.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    }
    [self call:nil];

    [self setNeedsStatusBarAppearanceUpdate];

}
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [callButton setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateNormal];
    [callButton setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateHighlighted];
    btnSelectUser.hidden=YES;
    
    callButton.hidden=NO;
    
    // Start sending chat presence
    //
    [QBChat instance].delegate = self;
    [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [QBChat instance].delegate = nil;
}

- (IBAction)audioOutputDidChange:(UISegmentedControl *)sender{
    if(self.videoChat != nil){
        self.videoChat.useHeadphone = sender.selectedSegmentIndex;
    }
}

- (IBAction)videoOutputDidChange:(UISegmentedControl *)sender{
    if(self.videoChat != nil){
        self.videoChat.useBackCamera = sender.selectedSegmentIndex;
    }
}
-(IBAction)btn1:(id)sender
{
    [kappDelegate startLoaderOnView:self.view withMessage:@"Please Wait while Fetching users"];
    
    [QBRequest createSessionWithSuccessBlock:nil errorBlock:nil];

    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10];
    
    [QBRequest usersForPage:page successBlock:^(QBResponse *response, QBGeneralResponsePage *pageInformation, NSArray *users) {
        NSLog(@"%@",pageInformation);
        NSLog(@"%@",response);
        NSLog(@"%@",users);
        arrayForName=[users mutableCopy];
        [kappDelegate stopLoaderFromView:self.view];

        
        //[self SHOWLISTING];
        
        // Successful response contains current page infromation + list of users
    } errorBlock:^(QBResponse *response) {
        [kappDelegate stopLoaderFromView:self.view];

        // Handle error
    }];
    
}
-(IBAction)LogoutAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)nxt:(id)sender
{
    NSUInteger randomIndex = arc4random() % [[kappDelegate arrayData] count];
    
    [kappDelegate setOpponentID:[[[kappDelegate arrayData] valueForKey:@"ID"] objectAtIndex:randomIndex]];

    //[kappDelegate setCallerName:[[[kappDelegate arrayData] valueForKey:@"login"] objectAtIndex:randomIndex]];
    NSLog(@"%@",[[[kappDelegate arrayData] valueForKey:@"login"] objectAtIndex:randomIndex]);
    //[callButton setTitle:[NSString stringWithFormat:@"%@ %@",@"Call",[kappDelegate CallerName]] forState:UIControlStateNormal];
    [callButton setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateNormal];
    [callButton setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateHighlighted];

}
- (IBAction)addFriendAction:(id)sender {
    
    
    [QBRequest objectsWithClassName:@"tblFriend" successBlock:^(QBResponse *response, NSArray *objects)
    {
        // response processing
        NSLog(@"%@",objects);
        NSPredicate* applePred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userID == %@ AND fields.friendId == %@", [NSNumber numberWithInteger:[kappDelegate UserId]],[NSNumber numberWithInteger:[[kappDelegate opponentID] integerValue]]]];
        
        NSArray *appleEmployees = [objects filteredArrayUsingPredicate:applePred];
        if(appleEmployees.count == 0)
        {
            QBCOCustomObject *object = [QBCOCustomObject customObject];
            object.className = @"tblFriend"; // your Class name
            
            // Object fields
            [object.fields setObject:[NSNumber numberWithInteger:[kappDelegate UserId]] forKey:@"User ID"];
            [object.fields setObject:[NSNumber numberWithInteger:[kappDelegate UserId]] forKey:@"_parent_id"]; // Movie ID
            [object.fields setObject:[kappDelegate opponentID] forKey:@"friendId"]; // Movie ID
            
            [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object)
             {
                 // do something when object is successfully created on a server
                 NSLog(@"%@",object.description);
                 [kappDelegate showAlertWithTitle:@"" message:@"Successfully added."];

             } errorBlock:^(QBResponse *response) {
                 // error handling
                 NSLog(@"Response error: %@", [response.error description]);
             }];
        }
        else
        {
            [kappDelegate showAlertWithTitle:@"" message:@"This person is already in your friend list."];
        }

    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}

- (IBAction)friendProfileAccount:(id)sender {
}

- (IBAction)reportAction:(id)sender {
}

- (IBAction)call:(id)sender
{
    // Call
    if(callButton.tag == 101)
    {
        callButton.tag = 102;
        
        // Setup video chat
        //
        if(self.videoChat == nil){
            self.videoChat = [[QBChat instance] createAndRegisterVideoChatInstance];
            self.videoChat.viewToRenderOpponentVideoStream = opponentVideoView;
            self.videoChat.viewToRenderOwnVideoStream = myVideoView;
        }
        
        // Set Audio & Video output
        //
        self.videoChat.useHeadphone = audioOutput.selectedSegmentIndex;
        self.videoChat.useBackCamera = videoOutput.selectedSegmentIndex;
        
        // Call user by ID
        //
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        NSLog(@"%ld",(long)[appDelegate.opponentID integerValue]);
        [self.videoChat callUser:[appDelegate.opponentID integerValue] conferenceType:QBVideoChatConferenceTypeAudioAndVideo];
        
        
        //callButton.hidden = YES;//gj
        ringigngLabel.hidden = NO;
        ringigngLabel.text = @"Calling...";
        ringigngLabel.frame = CGRectMake(128, 375, 90, 37);
        callingActivityIndicator.hidden = NO;
        [self.view bringSubviewToFront:callingActivityIndicator];
        // Finish
    }else{
        callButton.tag = 101;
        
        // Finish call
        //
        [self.videoChat finishCall];
        
        myVideoView.hidden = YES;
        opponentVideoView.layer.contents = (id)[[UIImage imageNamed:@"person.png"] CGImage];
        opponentVideoView.image = [UIImage imageNamed:@"person.png"];
        //[callButton setTitle:[NSString stringWithFormat:@"%@ %@",@"Call",[kappDelegate CallerName]] forState:UIControlStateNormal];
        [callButton setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateNormal];
        [callButton setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateHighlighted];
        opponentVideoView.layer.borderWidth = 1;
        
        [startingCallActivityIndicator stopAnimating];
        
        
        // release video chat
        //
        [[QBChat instance] unregisterVideoChatInstance:self.videoChat];
        self.videoChat = nil;
    }
}


- (void)reject{
    // Reject call
    //
    if(self.videoChat == nil){
        self.videoChat = [[QBChat instance] createAndRegisterVideoChatInstanceWithSessionID:sessionID];
    }
    [self.videoChat rejectCallWithOpponentID:videoChatOpponentID];
    //
    //
    [[QBChat instance] unregisterVideoChatInstance:self.videoChat];
    self.videoChat = nil;

    // update UI
    callButton.hidden = NO;
    ringigngLabel.hidden = YES;
    
    // release player
    ringingPlayer = nil;
}

- (void)accept{
    
    NSLog(@"accept");
    
    // Setup video chat
    //
    if(self.videoChat == nil){
        self.videoChat = [[QBChat instance] createAndRegisterVideoChatInstanceWithSessionID:sessionID];
        self.videoChat.viewToRenderOpponentVideoStream = opponentVideoView;
        self.videoChat.viewToRenderOwnVideoStream = myVideoView;
    }
    
    // Set Audio & Video output
    //
    self.videoChat.useHeadphone = audioOutput.selectedSegmentIndex;
    self.videoChat.useBackCamera = videoOutput.selectedSegmentIndex;
    
    // Accept call
    //
    [self.videoChat acceptCallWithOpponentID:videoChatOpponentID conferenceType:videoChatConferenceType];
    
    ringigngLabel.hidden = YES;
    callButton.hidden = NO;
   // [callButton setTitle:@"Hang up" forState:UIControlStateNormal];
    [callButton setImage:[UIImage imageNamed:@"callend.png"] forState:UIControlStateNormal];
    [callButton setImage:[UIImage imageNamed:@"callend.png"] forState:UIControlStateHighlighted];
    callButton.tag = 102;
    
    opponentVideoView.layer.borderWidth = 0;
    
    [startingCallActivityIndicator startAnimating];
    
    myVideoView.hidden = NO;
    
    ringingPlayer = nil;
}

- (void)hideCallAlert{
    [self.callAlert dismissWithClickedButtonIndex:-1 animated:YES];
    self.callAlert = nil;
    
    callButton.hidden = NO;
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    ringingPlayer = nil;
}


#pragma mark -
#pragma mark QBChatDelegate 
//
// VideoChat delegate

-(void) chatDidReceiveCallRequestFromUser:(NSUInteger)userID withSessionID:(NSString *)_sessionID conferenceType:(enum QBVideoChatConferenceType)conferenceType
{
    NSLog(@"chatDidReceiveCallRequestFromUser %lu", (unsigned long)userID);
    
    // save  opponent data
    videoChatOpponentID = userID;
    videoChatConferenceType = conferenceType;
    sessionID = _sessionID;
    
    
   // callButton.hidden = YES;//gj
    
    // show call alert
    //
    if (self.callAlert == nil) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *message = [NSString stringWithFormat:@"%@ is calling. Would you like to answer?", appDelegate.currentUser == 1 ? @"Anonymous" : @"Anonymous"];
        self.callAlert = [[UIAlertView alloc] initWithTitle:@"Call" message:message delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
        [self.callAlert show];
    }
    
    // hide call alert if opponent has canceled call
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCallAlert) object:nil];
    [self performSelector:@selector(hideCallAlert) withObject:nil afterDelay:4];
    
    // play call music
    //
    if(ringingPlayer == nil){
        NSString *path =[[NSBundle mainBundle] pathForResource:@"ringing" ofType:@"wav"];
        NSURL *url = [NSURL fileURLWithPath:path];
        ringingPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        ringingPlayer.delegate = self;
        [ringingPlayer setVolume:1.0];
        [ringingPlayer play];
    }
}

-(void) chatCallUserDidNotAnswer:(NSUInteger)userID{
    NSLog(@"chatCallUserDidNotAnswer %lu", (unsigned long)userID);
    
    callButton.hidden = NO;
    ringigngLabel.hidden = YES;
    callingActivityIndicator.hidden = YES;
    callButton.tag = 101;
    [kappDelegate showAlertWithTitle:@"QuickBlox VideoChat" message:@"User isn't answering. Please try again."];
}

-(void) chatCallDidRejectByUser:(NSUInteger)userID{
    NSLog(@"chatCallDidRejectByUser %lu", (unsigned long)userID);
    
    callButton.hidden = NO;
    ringigngLabel.hidden = YES;
    callingActivityIndicator.hidden = YES;
    
    callButton.tag = 101;
    
    [kappDelegate showAlertWithTitle:@"QuickBlox VideoChat" message:@"User has rejected your call."];

}

-(void) chatCallDidAcceptByUser:(NSUInteger)userID{
    NSLog(@"chatCallDidAcceptByUser %lu", (unsigned long)userID);
    
    ringigngLabel.hidden = YES;
    callingActivityIndicator.hidden = YES;
    
    opponentVideoView.layer.borderWidth = 0;
    
    callButton.hidden = NO;
//    [callButton setTitle:@"Hang up" forState:UIControlStateNormal];
    [callButton setImage:[UIImage imageNamed:@"callend.png"] forState:UIControlStateNormal];
    [callButton setImage:[UIImage imageNamed:@"callend.png"] forState:UIControlStateHighlighted];

    callButton.tag = 102;
    
    myVideoView.hidden = NO;
    
    [startingCallActivityIndicator startAnimating];
}

-(void) chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status{
    NSLog(@"chatCallDidStopByUser %lu purpose %@", (unsigned long)userID, status);
    
    if([status isEqualToString:kStopVideoChatCallStatus_OpponentDidNotAnswer]){
        
        self.callAlert.delegate = nil;
        [self.callAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.callAlert = nil;
        
        ringigngLabel.hidden = YES;
        
        ringingPlayer = nil;
        
    }else{
        myVideoView.hidden = YES;
        opponentVideoView.layer.contents = (id)[[UIImage imageNamed:@"person.png"] CGImage];
        opponentVideoView.layer.borderWidth = 1;

        //[callButton setTitle:[NSString stringWithFormat:@"%@ %@",@"Call",[kappDelegate CallerName]] forState:UIControlStateNormal];
        [callButton setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateNormal];
        [callButton setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateHighlighted];

        callButton.tag = 101;
    }
    
    callButton.hidden = NO;
    
    // release video chat
    //
    [[QBChat instance] unregisterVideoChatInstance:self.videoChat];
    self.videoChat = nil;
}

- (void)chatCallDidStartWithUser:(NSUInteger)userID sessionID:(NSString *)sessionID{
    [startingCallActivityIndicator stopAnimating];
}

- (void)didStartUseTURNForVideoChat{
    //    NSLog(@"_____TURN_____TURN_____");
}


#pragma mark -
#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
            // Reject
        case 0:
            [self reject];
            break;
            // Accept
        case 1:
            [self accept];
            break;
            
        default:
            break;
    }
    
    self.callAlert = nil;
}


-(IBAction)ChatVC:(id)sender
{
    DialogsViewController * DVC=[[DialogsViewController alloc] initWithNibName:@"DialogsViewController" bundle:nil];
    
    [self.navigationController pushViewController:DVC animated:YES];
}

@end
