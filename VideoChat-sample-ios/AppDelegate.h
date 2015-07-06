//
//  AppDelegate.h
//  SimpleSample-videochat-ios
//
//  Created by QuickBlox team on 1/02/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//
//
// This class sets QuickBlox credentials
// Then shows splash screen where you have to create QuickBlox session with user in order to use QuickBlox API.
//

#import <UIKit/UIKit.h>
#import "ActivityAlertView.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate,UINavigationBarDelegate>{
    NSString * uSerName;
NSString * CallerName;
    ActivityAlertView* activityAlert;
    UINavigationController *nav;
    Reachability *internetReach;
    int internetWorking;
//    NSInteger * opponentID;
}
-(void)startLoaderOnView:(UIView*)view withMessage:(NSString*)msg;
-(void)stopLoaderFromView:(UIView*)view;
-(void)showAlertWithTitle:(NSString *)title message:(NSString *)msg;

@property (strong, nonatomic)NSMutableArray * arrayData;
@property (strong, nonatomic)NSString * uSerName;
@property (strong, nonatomic)NSString * CallerName;
@property	int internetWorking;

@property (strong) NSNumber *opponentID;

@property (strong, nonatomic) UIWindow *window;

/* VideoChat test opponents */
@property (strong, nonatomic) NSArray *testOpponents;

/* Current logged in test user*/
@property (assign, nonatomic) int currentUser;
@property (assign, nonatomic) NSUInteger UserId;
-(BOOL)CheckInternetConnection;
-(BOOL)validEmail:(NSString*)myemail;
-(NSString *)validPassword:(NSString *)pwd;
@end
