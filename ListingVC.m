//
//  ListingVC.m
//  Drivermatrics
//
//  Created by Puneetpal Singh on 03/04/15.
//  Copyright (c) 2015 Ruslan. All rights reserved.
//

#import "ListingVC.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "MainViewController.h"

@interface ListingVC ()

@end

@implementation ListingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetch];
    [self arrayData];
    [kappDelegate startLoaderOnView:self.view withMessage:@"Please Wait"];

}

-(void)fetch
{

    [QBRequest objectsWithClassName:@"blogname" successBlock:^(QBResponse *response, NSArray *objects)
     {
         NSLog(@"%@",objects);
         NSMutableDictionary * dict=[objects valueForKey:@"fields"];
         NSLog(@"%@",dict);

         arrayOfList=objects;
         if([arrayOfList count]>0)
         {
             tableView.delegate=self;
             tableView.dataSource=self;
             [tableView reloadData];
         }
     }errorBlock:^(QBResponse *response)
     {
         
     }];
    
    


}
-(void)arrayData
{
    
    [QBRequest usersWithSuccessBlock:^(QBResponse *response, QBGeneralResponsePage *pageInformation, NSArray *users) {
        NSLog(@"%@",pageInformation);
        NSLog(@"%@",response);
        NSLog(@"%@",users);
        [kappDelegate stopLoaderFromView:self.view];
        NSPredicate* applePred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"ID != %@", [NSNumber numberWithInteger:[kappDelegate UserId]]]];
        users = [users filteredArrayUsingPredicate:applePred];
        [kappDelegate setArrayData:[NSMutableArray arrayWithArray:users]];

        if([arrayOfList count]>0)
        {
            tableView.delegate=self;
            tableView.dataSource=self;
            [tableView reloadData];
        }
        // Successful response contains current page infromation + list of users
    } errorBlock:^(QBResponse *response) {
        // Handle error
    }];

}

-(void)arrayDataWithCommunity:(NSString *)strCommunity
{
    NSPredicate* applePred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"customData == \"%@\"", strCommunity]];

    NSArray *appleEmployees = [[kappDelegate arrayData] filteredArrayUsingPredicate:applePred];
    if([appleEmployees count]>0)
    {
        NSUInteger randomIndex = arc4random() % [appleEmployees count];
        
        [kappDelegate setOpponentID:[[appleEmployees valueForKey:@"ID"] objectAtIndex:randomIndex]];
        
        //[kappDelegate setCallerName:[[appleEmployees valueForKey:@"login"] objectAtIndex:randomIndex]];
        
        MainViewController * MainVC=[[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        [MainVC setOpponentUser:[appleEmployees objectAtIndex:randomIndex]];
        [self.navigationController pushViewController:MainVC animated:YES];
    }
   else
   {
       [kappDelegate showAlertWithTitle:@"" message:@"No user found."];
//       NSUInteger randomIndex = arc4random() % [[kappDelegate arrayData] count];
//       
//       [kappDelegate setOpponentID:[[[kappDelegate arrayData] valueForKey:@"ID"] objectAtIndex:randomIndex]];
//       
//       [kappDelegate setCallerName:[[[kappDelegate arrayData] valueForKey:@"login"] objectAtIndex:randomIndex]];
//       
//       MainViewController * MainVC=[[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
//       
//       [self.navigationController pushViewController:MainVC animated:YES];
   }
}

-(NSUInteger)arrayDataWithCommunityCount:(NSString *)strCommunity
{
    NSPredicate* applePred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"customData == \"%@\"", strCommunity]];
    
    NSArray *appleEmployees = [[kappDelegate arrayData] filteredArrayUsingPredicate:applePred];
    return [appleEmployees count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tab2.png"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayOfList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = nil;
    if (cell == Nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text=[[[arrayOfList objectAtIndex:indexPath.row] valueForKey:@"fields"] valueForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[self arrayDataWithCommunityCount:[[arrayOfList objectAtIndex:indexPath.row] valueForKey:@"ID"]]];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self arrayDataWithCommunity:[[arrayOfList objectAtIndex:indexPath.row] valueForKey:@"ID"]];
    
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}
@end
