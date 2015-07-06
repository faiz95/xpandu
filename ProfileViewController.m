//
//  ProfileViewController.m
//  Drivermatrics
//
//  Created by Puneetpal Singh on 03/04/15.
//  Copyright (c) 2015 Ruslan. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "SBJSON.h"
#import <Parse/Parse.h>
#import "SSUUserCache.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self arrayData];
    
    QBUUser* user = [SSUUserCache instance].currentUser;
    [self FetchCategories:user.customData];

    
    txtFieldFullName.text =user.fullName;
    
    txtFieldEmail.text = user.email;
    
    
    txtFieldPhNo.text = user.phone;
    
    txtFieldUserName.text =user.login;
    // Do any additional setup after loading the view from its nib.
}
-(void)FetchBlogName
{
    [QBRequest objectWithClassName:@"blogname" ID:[dicArrayData valueForKey:@"custom_data"] successBlock:^(QBResponse *response, QBCOCustomObject *object)
     {
         NSString *string = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
         SBJSON * json =[[SBJSON alloc] init];
         NSMutableDictionary * dict =   [json objectWithString:string error:nil];
         lblCategory.text =[dict valueForKey:@"name"];
         [kappDelegate stopLoaderFromView:self.view];
     }
                        errorBlock:^(QBResponse *response)
     {
         [kappDelegate stopLoaderFromView:self.view];
     }];
}

- (void)completedWithResult:(QBResult *)result
{
    if(result.success && [result isKindOfClass:QBUUserPagedResult.class])
    {

    }

}
-(IBAction)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)CategoryAction:(id)sender
{
    if ([ViewForCategory isHidden]) {
        ViewForCategory.hidden=NO;
        tableViewForCategory.delegate=self;
        tableViewForCategory.dataSource=self;
        [tableViewForCategory reloadData];
    }
    else
    {
        ViewForCategory.hidden=YES;
    }
    [self.view bringSubviewToFront:ViewForCategory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)JsonData
{
   
 
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tblUsers)
        return [[kappDelegate arrayData] count];
    return [arrayFrcategory count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = nil;
    if (cell == Nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(tableView == tblUsers)
    {
        QBUUser *user = [[kappDelegate arrayData] objectAtIndex:indexPath.row];
        cell.textLabel.text=user.fullName;
    }
    else
        cell.textLabel.text=[arrayFrcategory objectAtIndex:indexPath.row];

    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tblUsers)
    {
        
    }
    else
    {
        lblCategory.text=[arrayFrcategory objectAtIndex:indexPath.row];
        
        strID = [NSString stringWithFormat:@"%@",  [AryForID objectAtIndex:indexPath.row]];
        if (![ViewForCategory isHidden]) {
            ViewForCategory.hidden=YES;
            
        }
        
        NSLog(@"%@",strID);
    }
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![ViewForCategory isHidden]) {
        ViewForCategory.hidden=YES;
        
    }
    [txtFieldFullName  endEditing:YES];
    [txtFieldEmail  endEditing:YES];
    [txtFieldUserName  endEditing:YES];
    [txtFieldPhNo endEditing:YES];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *expression = @"^[a-zA-Z0-9\\!\\£\\$\\&\\@\\_\\+\\=\\,\\.\\?\\ -]*$";
    
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                        options:0
                                                          range:NSMakeRange(0, [newString length])];
    if (numberOfMatches == 0)
        return NO;
    
    else if (textField == txtFieldUserName)
    {
        if([string isEqualToString:@" "])
            return NO;
    }
    else  if (textField == txtFieldPhNo)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        NSError *error = nil;
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
    }
    
    
    if (textField == txtFieldFullName  && newLength>30)
        return NO;
    return YES;
}

-(void)arrayData
{
    
    [QBRequest usersWithSuccessBlock:^(QBResponse *response, QBGeneralResponsePage *pageInformation, NSArray *users) {
        NSPredicate* applePred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"ID != %@", [NSNumber numberWithInteger:[kappDelegate UserId]]]];
        users = [users filteredArrayUsingPredicate:applePred];
        [kappDelegate setArrayData:[NSMutableArray arrayWithArray:users]];
        if([users count]>0)
        {
            tblUsers.delegate=self;
            tblUsers.dataSource=self;
            [tblUsers reloadData];
        }
        // Successful response contains current page infromation + list of users
    } errorBlock:^(QBResponse *response) {
        // Handle error
    }];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}


-(IBAction)Save:(id)sender
{
    if([kappDelegate CheckInternetConnection])
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *newtxtName = [txtFieldUserName.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        
        NSString *newtxtFullName = [txtFieldFullName.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        NSString *newtxtEmail = [txtFieldEmail.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        NSString *newPhone = [txtFieldPhNo.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        NSString *newtxtCat = [lblCategory.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        
        if([newtxtName length] == 0)
        {
            [kappDelegate showAlertWithTitle:@"" message:@"Please enter valid username."];
            return;
        }
        
        else if([newtxtFullName length] == 0)
        {
            [kappDelegate showAlertWithTitle:@"" message:@"Please enter valid name."];
            return;
        }
        else if([newtxtEmail length] == 0)
        {
            [kappDelegate showAlertWithTitle:@"" message:@"Please enter valid email."];
            return;
        }
        else if([newPhone length] == 0)
        {
            [kappDelegate showAlertWithTitle:@"" message:@"Please enter valid phone number."];
            return;
        }
        else if([newtxtCat length] == 0 || [newtxtCat isEqualToString:@"Select Community"])
        {
            [kappDelegate showAlertWithTitle:@"" message:@"Please select valid community."];
            return;
        }
        else if(![kappDelegate validEmail:newtxtEmail])
        {
            [kappDelegate showAlertWithTitle:@"" message:@"Please enter your valid email address."];
            return;
        }
        
        else if([newPhone length]<8)
        {
            [kappDelegate showAlertWithTitle:@"" message:@"Password should have at least 8 characters."];
            return;
        }
        else
        {
            [kappDelegate startLoaderOnView:self.view withMessage:@"Please Wait"];
            QBUUser* currentUser = [[SSUUserCache instance].currentUser copy];
            
            if ([txtFieldFullName.text length] != 0) currentUser.fullName = newtxtFullName;
            
            if ([txtFieldEmail.text length] != 0) currentUser.email = newtxtEmail;
            
            if ([txtFieldPhNo.text length] != 0) currentUser.phone = newPhone;
            
            
            if ([txtFieldUserName.text length] != 0) currentUser.login = newtxtName;
            currentUser.customData = strID;
            [QBRequest updateUser:currentUser successBlock:^(QBResponse *response, QBUUser *aUser) {
                [[SSUUserCache instance] saveUser:aUser];
                [kappDelegate stopLoaderFromView:self.view];
                [kappDelegate showAlertWithTitle:@"" message:@"Account has been updated successfully."];
                
            } errorBlock:^(QBResponse *response) {
                
                [kappDelegate stopLoaderFromView:self.view];
                
            }];
        }
    }
    else
    {
        [kappDelegate showAlertWithTitle:KInternetNotAvailableTitle message:KInternetNotWorking];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }

    
}

-(void)FetchCategories:(NSString *)selectedCat
{
    [kappDelegate startLoaderOnView:self.view withMessage:@"Please Wait"];
    [QBRequest objectsWithClassName:@"blogname" successBlock:^(QBResponse *response, NSArray *objects)
     {
         [kappDelegate stopLoaderFromView:self.view];
         NSMutableDictionary * dict=[objects valueForKey:@"fields"];
         arrayFrcategory=[dict valueForKey:@"name"];
         AryForID=[objects valueForKey:@"ID"];
         if([AryForID containsObject:selectedCat])
         {
             lblCategory.text =[arrayFrcategory objectAtIndex:[AryForID indexOfObject:selectedCat]];
         }
     }errorBlock:^(QBResponse *response)
     {
         
     }];
    
}
@end
