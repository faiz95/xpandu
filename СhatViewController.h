//
//  СhatViewController.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/18/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController
{
    
    IBOutlet UITableView *messageTable;
    IBOutlet UILabel *lblTitle;
}
@property (nonatomic, strong) QBChatDialog *dialog;
- (IBAction)backAction:(id)sender;

@end
