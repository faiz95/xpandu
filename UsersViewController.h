//
//  FirstViewController.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersViewController : UIViewController
{
    IBOutlet UISegmentedControl * segemntCntrolObj;
}
- (IBAction)backAction:(id)sender;
@property (strong, nonatomic) QBChatDialog *createdDialog;
@property (nonatomic, strong) NSMutableArray *dialogs;


@end
