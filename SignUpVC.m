//
//  SignUpVC.m
//  Drivermatrics
//
//  Created by Puneetpal Singh on 23/02/15.
//  Copyright (c) 2015 Ruslan. All rights reserved.
//

#import "SignUpVC.h"
#import <Parse/Parse.h>

@interface SignUpVC ()

@end

@implementation SignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"SIGN UP";
    ArryForCategories=[[NSMutableArray alloc] init];
    AryForID=[[NSMutableArray alloc] init];
    [self FetchCategories];
    // Do any additional setup after loading the view from its nib.
}
-(void)FetchCategories
{
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        [QBRequest objectsWithClassName:@"blogname" successBlock:^(QBResponse *response, NSArray *objects)
         {
             NSLog(@"%@",objects);
             NSMutableDictionary * dict=[objects valueForKey:@"fields"];
             NSLog(@"%@",dict);
             
             ArryForCategories=[dict valueForKey:@"name"];
             AryForID=[objects valueForKey:@"ID"];
             tableViewForCategory.delegate=self;
             tableViewForCategory.dataSource=self;
             [tableViewForCategory performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
         }
                             errorBlock:^(QBResponse *response)
         {
             
         }];

        // session created
        
    } errorBlock:^(QBResponse *response) {
        // handle errors
        NSLog(@"%@", response.error);
    }];
    

}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)dismissVC:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    else  if (textField == txtFieldPassword && newLength>20)
    {
        UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:@"" message:@"Your password must be between 8-20 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    if (textField == txtFieldFullName  && newLength>30)
        return NO;
    return YES;
}

-(IBAction)SignUp:(id)sender
{
    if([kappDelegate CheckInternetConnection])
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *newtxtName = [txtFieldUserName.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        NSString *newtxtPassword = [txtFieldPassword.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        
        NSString *newtxtFullName = [txtFieldFullName.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        NSString *newtxtEmail = [txtFieldEmail.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        NSString *newPhone = [txtFieldPhNo.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        NSString *newtxtCat = [lblCategory.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        
        if([newtxtName length] == 0)
        {
            [kappDelegate showAlertWithTitle:@"" message:@"Please enter valid username."];
            return;
        }
        else if([newtxtPassword length] == 0)
        {
            [kappDelegate showAlertWithTitle:@"" message:@"Please enter valid Password."];
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
        else if([newtxtPassword length]<8)
        {
            [kappDelegate showAlertWithTitle:@"" message:@"Password should have at least 8 characters."];
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
            [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
                
                QBUUser *user = [QBUUser user];
                user.login = newtxtName;
                user.password = newtxtPassword;
                user.fullName= newtxtFullName;
                user.phone= newPhone;
                user.email= newtxtEmail;
                user.customData=strID;
                
                // Registration/sign up of User
                [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
                    
                    // Sign up was successful
                    [kappDelegate stopLoaderFromView:self.view];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success:" message:@"Account successfully created." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                } errorBlock:^(QBResponse *response) {
                    // Handle error here
                    
                    [kappDelegate showAlertWithTitle:@"Error:" message:response.error.description];
                    
                    NSLog(@"error while signing up with QB");
                }];
            }
             
                                          errorBlock:^(QBResponse *response) {
                                              //   handle errors
                                              NSLog(@"%@", response.error);    }];
        }
        
        
    }
    else
    {
        [kappDelegate showAlertWithTitle:KInternetNotAvailableTitle message:KInternetNotWorking];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[alertView message] isEqualToString:@"Account successfully created."])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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
-(void)SaveInParse
{
    //01722601023
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
    return [ArryForCategories count];
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
    
    cell.textLabel.text=[ArryForCategories objectAtIndex:indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lblCategory.text=[ArryForCategories objectAtIndex:indexPath.row];
    

    strID = [NSString stringWithFormat:@"%@",  [AryForID objectAtIndex:indexPath.row]];
    if (![ViewForCategory isHidden]) {
        ViewForCategory.hidden=YES;
        
    }

    NSLog(@"%@",strID);
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![ViewForCategory isHidden]) {
        ViewForCategory.hidden=YES;

    }
    [txtFieldFullName  endEditing:YES];
    [txtFieldEmail  endEditing:YES];
    [txtFieldPassword  endEditing:YES];
    [txtFieldUserName  endEditing:YES];
    [txtFieldPhNo endEditing:YES];

}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

@end
