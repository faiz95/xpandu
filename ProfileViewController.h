//
//  ProfileViewController.h
//  Drivermatrics
//
//  Created by Puneetpal Singh on 03/04/15.
//  Copyright (c) 2015 Ruslan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITextField * txtFieldUserName;
    IBOutlet UITextField * txtFieldFullName;
    IBOutlet UITextField * txtFieldEmail;
    IBOutlet UITextField * txtFieldPhNo;
    IBOutlet UILabel * lblCategory;
    IBOutlet UIView * ViewForCategory;
    IBOutlet UITableView * tableViewForCategory;
    NSMutableDictionary * dicArrayData;
    NSMutableArray * arrayFrcategory;
    NSMutableArray * AryForID;
    NSString * strID;
    IBOutlet UITableView *tblUsers;
    
}
@end
