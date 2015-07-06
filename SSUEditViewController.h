//
//  EditViewController.h
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 13.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class enables update QB user
//

@interface SSUEditViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UILabel * lblCategory;
    IBOutlet UIView * ViewForCategory;
    IBOutlet UITableView * tableViewForCategory;
    NSMutableDictionary * ArrayData;
    NSMutableArray * arrayFrcategory;
    NSMutableArray * AryForID;
    NSString * strID;

}
@end
