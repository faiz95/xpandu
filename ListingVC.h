//
//  ListingVC.h
//  Drivermatrics
//
//  Created by Puneetpal Singh on 03/04/15.
//  Copyright (c) 2015 Ruslan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListingVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray * arrayOfList;
    IBOutlet UITableView * tableView;
    
}
- (IBAction)backAction:(id)sender;
@end
