//
//  FirstViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "UsersViewController.h"
#import "СhatViewController.h"
#import "DialogsViewController.h"
#import "AppDelegate.h"

@interface UsersViewController () <UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>

@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, weak) IBOutlet UITableView *usersTableView;

@end

@implementation UsersViewController


#pragma mark
#pragma mark ViewController lyfe cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [kappDelegate startLoaderOnView:self.view withMessage:@"Please wait"];
    self.selectedUsers = [NSMutableArray array];
    // Fetch 10 users
    [self fetchFriends];
}

-(void)fetchFriends
{
    [QBRequest objectsWithClassName:@"tblFriend" successBlock:^(QBResponse *response, NSArray *objects)
     {
         // response processing
         NSLog(@"%@",objects);
         NSPredicate* applePred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userID == %@", [NSNumber numberWithInteger:[kappDelegate UserId]]]];
         NSArray *appleEmployees = [objects filteredArrayUsingPredicate:applePred];
         if(appleEmployees.count>0)
         {
             [self fetchFriendsProfiles:[NSMutableArray arrayWithArray:appleEmployees]];
         }
         else
         {
             [kappDelegate showAlertWithTitle:@"" message:@"No user found."];
             [kappDelegate stopLoaderFromView:self.view];
         }
         
         
     }errorBlock:^(QBResponse *response) {
         // error handling
         NSLog(@"Response error: %@", [response.error description]);
     }];
}
-(void)fetchFriendsProfiles:(NSMutableArray *)arrUsers
{
    
    [QBRequest usersWithSuccessBlock:^(QBResponse *response, QBGeneralResponsePage *pageInformation, NSArray *users) {
        [kappDelegate stopLoaderFromView:self.view];
        
        for (QBCOCustomObject *object in arrUsers)
        {
            NSPredicate* applePred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"ID == %@", [object.fields objectForKey:@"friendId"]]];
            users = [users filteredArrayUsingPredicate:applePred];
            [self.selectedUsers addObjectsFromArray:users];
        }
        self.usersTableView.delegate=self;
        self.usersTableView.dataSource=self;
        [self.usersTableView reloadData];
    // Successful response contains current page infromation + list of users
    } errorBlock:^(QBResponse *response) {
        // Handle error
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

}

- (IBAction)createDialog:(QBUUser *)user{
    
    QBChatDialog *chatDialog = [QBChatDialog new];
    
    NSMutableArray *selectedUsersIDs = [NSMutableArray array];
    NSMutableArray *selectedUsersNames = [NSMutableArray array];
    [selectedUsersIDs addObject:@(user.ID)];
    [selectedUsersNames addObject:user.login == nil ? user.email : user.login];
    [kappDelegate setCallerName:user.fullName];
    chatDialog.occupantIDs = selectedUsersIDs;
    chatDialog.type = QBChatDialogTypePrivate;

//    if(self.selectedUsers.count == 1){
//        chatDialog.type = QBChatDialogTypePrivate;
//    }else{
//        chatDialog.name = [selectedUsersNames componentsJoinedByString:@","];
//        chatDialog.type = QBChatDialogTypeGroup;
//    }
    
    [QBChat createDialog:chatDialog delegate:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [QBChat instance].delegate = nil;
}



#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg.png"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.selectedUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = nil;
    if (cell == Nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.tag = indexPath.row;
    QBUUser *user = (QBUUser *)self.selectedUsers[indexPath.row];
    cell.textLabel.text=user.fullName;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.text = @"";
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [kappDelegate startLoaderOnView:self.view withMessage:@"Please Wait"];
 //   UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    QBUUser *user = (QBUUser *)self.selectedUsers[indexPath.row];
    [self createDialog:user];
}



#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(QBResult *)result{
    if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
        // dialog created
        
        QBChatDialogResult *dialogRes = (QBChatDialogResult *)result;
        
        DialogsViewController * dialogsViewController=[[DialogsViewController alloc] initWithNibName:@"DialogsViewController" bundle:nil];
        dialogsViewController.createdDialog = dialogRes.dialog;
        
        [self.navigationController pushViewController:dialogsViewController animated:YES
         ];
        dialogsViewController.view.hidden = YES;
    }else{
        [kappDelegate showAlertWithTitle:@"Errors" message:[[result errors] componentsJoinedByString:@","]];

    }
}



- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}
@end
