//
//  AppDelegate.m
//  SimpleSample-videochat-ios
//
//  Created by QuickBlox team on 1/02/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "ActivityAlertView.h"
#import <Parse/Parse.h>
#import "Reachability.h"

@implementation AppDelegate
@synthesize window = _window;
@synthesize testOpponents;
@synthesize currentUser,arrayData;
@synthesize opponentID;
@synthesize uSerName,CallerName;
@synthesize UserId,internetWorking;



- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == internetReach)
    {
        NSLog(@"Internet");
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        switch (netStatus)
        {
            case NotReachable:
            {
                internetWorking = -1;
                NSLog(@"Internet NOT WORKING");
                break;
            }
            case ReachableViaWiFi:
            {
                internetWorking = 0;
                break;
            }
            case ReachableViaWWAN:
            {
                internetWorking = 0;
                break;
                
            }
        }
    }
}

-(BOOL)validEmail:(NSString*)myemail
{
    myemail=[myemail stringByReplacingOccurrencesOfString:@" " withString:@""];
    if([myemail length]<1)
        return NO;
    else
    {
        NSArray *mailParts=[myemail componentsSeparatedByString:@"@"];
        if(([mailParts count]>2) ||-([mailParts count]<2))
            return NO;
        else
        {
            NSString *lastPart=[mailParts objectAtIndex:[mailParts count]-1] ;
            NSArray *mailParts2=[lastPart componentsSeparatedByString:@"."];
            if([mailParts2 count]<2)
                return NO;
            else
            {
                NSString *lastPart2=[mailParts2 objectAtIndex:[mailParts2 count] -1];
                NSString *firstPart=[mailParts2 objectAtIndex:[mailParts2 count] -2];
                if([lastPart2 length]<1)
                    return NO;
                else if( [firstPart length]<1)
                    return NO;
                else
                    return YES;
            }
        }
    }
}

-(NSString *)validPassword:(NSString *)pwd
{
    NSString *strMessage = @"";
    NSRange rang;
    rang = [pwd rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    if ( !rang.length ) //Password should contain at least one upper case character
    {
        strMessage = [strMessage stringByAppendingFormat:@"%@",@"at least one upper case character"];
    }
    rang = [pwd rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    if ( !rang.length )  //Password should contain at least one lower case character
    {
        if([strMessage hasPrefix:@"at least one upper case character"])
            strMessage = [strMessage stringByAppendingFormat:@" and %@",@"at least one lower case character"];
        else
            strMessage = [strMessage stringByAppendingFormat:@"%@",@"at least one lower case character"];
    }
    return strMessage;
}

-(BOOL)CheckInternetConnection
{
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifer];
    [self updateInterfaceWithReachability: internetReach];
    if(internetWorking == -1)
        return NO;
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [application setIdleTimerDisabled:YES];
    
    
    [QBApplication sharedApplication].applicationId = 19699;
    [QBConnection registerServiceKey:@"TprCXPTuWVKs35r"];
    [QBConnection registerServiceSecret:@"hdm8KcbzCm8te4H"];
    [QBSettings setAccountKey:@"zrotpKsxfMkKpdyzx44H"];
    
    NSMutableDictionary *videoChatConfiguration = [[QBSettings videoChatConfiguration] mutableCopy];
    [videoChatConfiguration setObject:@20 forKey:kQBVideoChatCallTimeout];
    [videoChatConfiguration setObject:@10 forKey:kQBVideoChatVideoFramesPerSecond];
    // config video quality here
    [videoChatConfiguration setObject:AVCaptureSessionPresetMedium forKey:kQBVideoChatFrameQualityPreset];
    [QBSettings setVideoChatConfiguration:videoChatConfiguration];
    
    /*NSMutableDictionary *videoChatConfiguration = [[QBSettings videoChatConfiguration] mutableCopy];
    [videoChatConfiguration setObject:@20 forKey:kQBVideoChatCallTimeout];
    [videoChatConfiguration setObject:AVCaptureSessionPresetLow forKey:kQBVideoChatFrameQualityPreset];
    [videoChatConfiguration setObject:@2 forKey:kQBVideoChatVideoFramesPerSecond];
    [videoChatConfiguration setObject:@3 forKey:kQBVideoChatP2PTimeout];
    [videoChatConfiguration setObject:@10 forKey:kQBVideoChatBadConnectionTimeout];
    [QBSettings setVideoChatConfiguration:videoChatConfiguration];*/

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // Show Splash screen
    //
    LoginViewController *splashViewController = [[LoginViewController alloc] init];
   nav=[[UINavigationController alloc]initWithRootViewController:splashViewController];
    nav.navigationBarHidden = YES;
    self.window.rootViewController=nav;
    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
 //   [self.window setRootViewController:splashViewController];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)showAlertWithTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
-(void)startLoaderOnView:(UIView*)view withMessage:(NSString*)msg
{
    activityAlert = [[ActivityAlertView alloc] initWithTitle:msg message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [activityAlert statAnimation];
    [activityAlert show];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}
-(void)stopLoaderFromView:(UIView*)view
{
    [activityAlert close];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    __block UIBackgroundTaskIdentifier backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        NSLog(@"Background Time:%f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
        
        //[self endBackgroundTask:backgroundTaskIdentifier];
        backgroundTaskIdentifier = backgroundTaskIdentifier;
    }];

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
