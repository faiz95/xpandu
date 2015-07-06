//
//  SpalshViewController.m
//  SimpleSample-videochat-ios
//
//  Created by QuickBlox team on 1/02/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "SignUpVC.h"
#import "MainScreenViewController.h"
#import "SSUUserCache.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize activityIndicator;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)viewDidLoad
{
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];
    self.title=@"LOGIN";
    txtFieldUserName.text = @"tim";
    txtFieldPassword.text = @"12345678";
}
-(IBAction)btn1:(id)sender
{

    
    
    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10];
    
    [QBRequest usersForPage:page successBlock:^(QBResponse *response, QBGeneralResponsePage *pageInformation, NSArray *users) {
        NSLog(@"%@",pageInformation);
        NSLog(@"%@",response);
        NSLog(@"%@",users);
        arrayForName=[users mutableCopy];
        [self ListingOfNames];
        // Successful response contains current page infromation + list of users
    } errorBlock:^(QBResponse *response) {
        // Handle error
    }];

}
-(void)ListingOfNames
{
    NSLog(@"%@",arrayForName);
    
}
// Start
-(IBAction)NavigateToSignUp:(id)sender
{
    SignUpVC * SignUpObj=[[SignUpVC alloc] initWithNibName:@"SignUpVC" bundle:nil];
    

    [self.navigationController pushViewController:SignUpObj animated:YES];
    
}


- (void)successfullLoginWithUser:(QBUUser *)user
{
    [[SSUUserCache instance] saveUser:user];
    [kappDelegate stopLoaderFromView:self.view];
    [kappDelegate setUSerName:user.login];
    [kappDelegate setUserId:user.ID];
    [[LocalStorageService shared] setCurrentUser:user];
    MainScreenViewController *mainViewController = [[MainScreenViewController alloc] init];
    [self.navigationController pushViewController:mainViewController animated:YES];    
}

- (void (^)(QBResponse *response, QBUUser *user))successBlock
{
    return ^(QBResponse *response, QBUUser *user)
    {
        [kappDelegate stopLoaderFromView:self.view];
        [self successfullLoginWithUser:user];
        [self.activityIndicator stopAnimating];
    };
}

- (QBRequestErrorBlock)errorBlock
{
    return ^(QBResponse *response) {
        [kappDelegate stopLoaderFromView:self.view];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        [self.activityIndicator stopAnimating];

    };
}

- (void)login
{
    // Authenticate user
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        [QBRequest logInWithUserLogin:txtFieldUserName.text password:txtFieldPassword.text
                         successBlock:[self successBlock] errorBlock:[self errorBlock]];
        
        [self.activityIndicator startAnimating];
        
        // session created
        
    } errorBlock:^(QBResponse *response) {
        // handle errors
        NSLog(@"%@", response.error);
    }];

    
}


- (IBAction)loginAsUser1:(id)sender
{
    if([kappDelegate CheckInternetConnection])
    {
        NSString *newtxtName = [txtFieldUserName.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        NSString *newtxtPassword = [txtFieldPassword.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];

        if([newtxtName length] == 0 || [newtxtPassword length]==0)
        {
            [kappDelegate showAlertWithTitle:@"" message:@"Please enter valid username & password."];
            return;
        }
        
        [self.view endEditing:YES];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.currentUser = 1;
        
        [kappDelegate startLoaderOnView:self.view withMessage:@"Please Wait"];
        
        // Your app connects to QuickBlox server here.
        //
        // Create extended session request with user authorization
        //
        [self login];
        
        /*QBSessionParameters *parameters = [QBSessionParameters new];
         parameters.userLogin = txtFieldUserName.text;
         parameters.userPassword = txtFieldPassword.text;
         
         // QuickBlox session creation
         [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
         [self loginToChat:session];
         
         } errorBlock:[self handleError]];
         
         
         
         [activityIndicator startAnimating];*/
        

    }
    else
    {
        [kappDelegate showAlertWithTitle:KInternetNotAvailableTitle message:KInternetNotWorking];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}
- (void(^)(QBResponse *))handleError
{
    return ^(QBResponse *response) {
        loginAsUser1Button.enabled = YES;
        loginAsUser2Button.enabled = YES;
        [kappDelegate showAlertWithTitle:NSLocalizedString(@"Error", "") message:[response.error description]];
        [kappDelegate stopLoaderFromView:self.view];

    };
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)loginToChat:(QBASession *)session{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // Set QuickBlox Chat delegate

    [QBChat instance].delegate = self;
    
    QBUUser *user = [QBUUser user];
    [appDelegate setUSerName:txtFieldUserName.text];
    user.ID = session.userID;
    [kappDelegate setUserId:session.userID];
    NSLog(@"%lu",(unsigned long)user.ID);
    NSLog(@"%lu",(unsigned long)session.userID);
    [[LocalStorageService shared] setCurrentUser:user];
    NSLog(@"%lu",(unsigned long)[LocalStorageService shared].currentUser.ID);

    NSLog(@"%@",[kappDelegate arrayData]);

    user.password = txtFieldPassword.text;
    
    // Login to QuickBlox Chat

    [[QBChat instance] loginWithUser:user];
}


#pragma mark -
#pragma mark QBChatDelegate

- (void)chatDidLogin{
    // Show Main controller
    
    [kappDelegate stopLoaderFromView:self.view];
    MainScreenViewController *mainViewController = [[MainScreenViewController alloc] init];
    [self.navigationController pushViewController:mainViewController animated:YES];
}

- (void)chatDidNotLogin{
    loginAsUser1Button.enabled = YES;
    loginAsUser2Button.enabled = YES;
}

@end
