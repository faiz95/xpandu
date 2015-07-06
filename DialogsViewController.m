//
//  SecondViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "DialogsViewController.h"
#import "СhatViewController.h"
#import <Quickblox/Quickblox.h>
#import "UsersViewController.h"
#import "AppDelegate.h"
@interface DialogsViewController () <UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>

@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, weak) IBOutlet UITableView *dialogsTableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation DialogsViewController

#pragma mark
#pragma mark ViewController lyfe cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    if([LocalStorageService shared].currentUser != nil){
//        [self.activityIndicator startAnimating];
    NSLog(@"%@",self.dialogs);
        // get dialogs
        [QBChat dialogsWithExtendedRequest:nil delegate:self];
   // }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [QBChat instance].delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Show splash
//        [self.navigationController performSegueWithIdentifier:kShowSplashViewControllerSegue sender:nil];
    });
    
    if(self.createdDialog != nil){
        ChatViewController * dVC=[[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        
        dVC.dialog = self.createdDialog;
        self.createdDialog = nil;
        [self.navigationController pushViewController:dVC animated:YES];

//        [self performSegueWithIdentifier:kShowNewChatViewControllerSegue sender:nil];
    }

//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        // Show splash
//        [self.navigationController performSegueWithIdentifier:kShowSplashViewControllerSegue sender:nil];
//    });
//    
//    if(self.createdDialog != nil){
//        [self performSegueWithIdentifier:kShowNewChatViewControllerSegue sender:nil];
//    }
}


#pragma mark
#pragma mark Actions

- (IBAction)createDialog:(id)sender{
    UsersViewController * uVC=[[UsersViewController alloc] initWithNibName:@"UsersViewController" bundle:nil];
    
    [self.navigationController pushViewController:uVC animated:YES];
//    [self presentViewController:uVC animated:YES completion:nil];
//    [self performSegueWithIdentifier:kShowUsersViewControllerSegue sender:nil];
}
-(IBAction)DismissVC:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark
#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.destinationViewController isKindOfClass:ChatViewController.class]){
        ChatViewController *destinationViewController = (ChatViewController *)segue.destinationViewController;
        
        if(self.createdDialog != nil){
            destinationViewController.dialog = self.createdDialog;
            self.createdDialog = nil;
        }else{
            QBChatDialog *dialog = self.dialogs[((UITableViewCell *)sender).tag];
            destinationViewController.dialog = dialog;
        }
    }
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.dialogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    }
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    cell.tag  = indexPath.row;

    switch (chatDialog.type) {
        case QBChatDialogTypePrivate:{
            cell.detailTextLabel.text = @"private";
            QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(chatDialog.recipientID)];
            cell.textLabel.text = recipient.login == nil ? recipient.email : recipient.login;
        }
            break;
        case QBChatDialogTypeGroup:{
            cell.detailTextLabel.text = @"group";
            cell.textLabel.text = chatDialog.name;
        }
            break;
        case QBChatDialogTypePublicGroup:{
            cell.detailTextLabel.text = @"public group";
            cell.textLabel.text = chatDialog.name;
        }
            break;
            
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSLog(@"%ld",(long)tableView.tag);
    NSLog(@"%ld",(long)indexPath.row);

    NSLog(@"%@",self.dialogs);
    QBChatDialog *dialog = self.dialogs[tableView.tag];

    
    ChatViewController * destinationViewController=[[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    if(self.createdDialog != nil){
        destinationViewController.dialog = self.createdDialog;
        destinationViewController.dialog = dialog;

        self.createdDialog = nil;
        [self.navigationController pushViewController:destinationViewController animated:YES];

        
    }else{
        QBChatDialog *dialog =[self.dialogs objectAtIndex:indexPath.row];
        //self.dialogs[((UITableViewCell *)sender).tag];
        destinationViewController.dialog = dialog;
        [self.navigationController pushViewController:destinationViewController animated:YES];


        
    }

}

-(void)pushtoChatView
{
    NSLog(@"%@",self.dialogs);
    QBChatDialog *dialog = self.dialogs[0];
    
    
    ChatViewController * destinationViewController=[[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    if(self.createdDialog != nil){
        destinationViewController.dialog = self.createdDialog;
        destinationViewController.dialog = dialog;
        
        self.createdDialog = nil;
        [self.navigationController pushViewController:destinationViewController animated:YES];

        
    }else{
        
    }

}

#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(QBResult *)result
{
    if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        //
        NSArray *dialogs = pagedResult.dialogs;
        [self.dialogs addObjectsFromArray:dialogs];
        
        NSLog(@"%@",[NSString stringWithFormat:@"userID:%lu",(unsigned long)[kappDelegate UserId]]);

        

        
        QBGeneralResponsePage *pagedRequest = [QBGeneralResponsePage responsePageWithCurrentPage:0 perPage:100];
                //
        NSSet *dialogsUsersIDs = pagedResult.dialogsUsersIDs;
        //
        [QBRequest usersWithIDs:[dialogsUsersIDs allObjects] page:pagedRequest successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            
            [LocalStorageService shared].users = users;
            //
            [self.dialogsTableView reloadData];
            [self.activityIndicator stopAnimating];
            
        } errorBlock:nil];

    }
}

@end
