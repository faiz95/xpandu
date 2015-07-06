//
//  SignUpVC.h
//  Drivermatrics
//
//  Created by Puneetpal Singh on 23/02/15.
//  Copyright (c) 2015 Ruslan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITextField * txtFieldUserName;
    IBOutlet UITextField * txtFieldPassword;
    IBOutlet UITextField * txtFieldFullName;
    IBOutlet UITextField * txtFieldEmail;
    IBOutlet UITextField * txtFieldPhNo;
    IBOutlet UIView * ViewForCategory;

    IBOutlet UILabel * lblCategory;
    NSMutableArray * ArryForCategories;
    NSMutableArray * AryForID;
    NSString * strID;
    IBOutlet UITableView * tableViewForCategory;
}
@end
