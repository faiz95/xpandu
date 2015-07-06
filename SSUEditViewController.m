//
//  EditViewController.m
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 13.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSUEditViewController.h"
#import "SSUUserCache.h"

@interface SSUEditViewController ()

@property (nonatomic, strong) IBOutlet UITextField* loginTextField1;
@property (nonatomic, strong) IBOutlet UITextField* fullNameTextField1;
@property (nonatomic, strong) IBOutlet UITextField* phoneTextField1;
@property (nonatomic, strong) IBOutlet UITextField* emailTextField1;
@property (nonatomic, strong) IBOutlet UITextField* websiteTextField1;
@property (nonatomic, strong) IBOutlet UITextField *tagsTextField1;

@end

@implementation SSUEditViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    QBUUser* currentUser = [SSUUserCache instance].currentUser;
    //[self FetchCategories:currentUser.customData];
    self.loginTextField1.text = currentUser.login;
    self.fullNameTextField1.text = currentUser.fullName;
    self.phoneTextField1.text = currentUser.phone;
    self.emailTextField1.text = currentUser.email;
    self.websiteTextField1.text = currentUser.website;
    
    for (NSString *tag in currentUser.tags) {
        if ([self.tagsTextField1.text length] == 0) {
            self.tagsTextField1.text = tag;
        } else {
            self.tagsTextField1.text = [NSString stringWithFormat:@"%@, %@", self.tagsTextField1.text, tag];
        }
    }
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
    
    cell.textLabel.text=[arrayFrcategory objectAtIndex:indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lblCategory.text=[arrayFrcategory objectAtIndex:indexPath.row];
    
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
    [self.loginTextField1 resignFirstResponder];
    [self.fullNameTextField1 resignFirstResponder];
    [self.phoneTextField1 resignFirstResponder];
    [self.emailTextField1 resignFirstResponder];
    [self.websiteTextField1 resignFirstResponder];
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

- (IBAction)updateButtonTouched:(id)sender
{
    QBUUser* currentUser = [[SSUUserCache instance].currentUser copy];
    if ([self.loginTextField1.text length] != 0) currentUser.login = self.loginTextField1.text;

    if ([self.fullNameTextField1.text length] != 0) currentUser.fullName = self.fullNameTextField1.text;

    if ([self.phoneTextField1.text length] != 0) currentUser.phone = self.phoneTextField1.text;
    
    if ([self.emailTextField1.text length] != 0) currentUser.email = self.emailTextField1.text;
    
    if ([self.websiteTextField1.text length] != 0) currentUser.website = self.websiteTextField1.text;
    
    if ([self.tagsTextField1.text length] != 0)
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[[self.tagsTextField1.text stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","]];
        currentUser.tags = array;
    }
    
    [QBRequest updateUser:currentUser successBlock:^(QBResponse *response, QBUUser *aUser) {
        [[SSUUserCache instance] saveUser:aUser];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } errorBlock:^(QBResponse *response) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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


@end
