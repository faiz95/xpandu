//
//  СhatViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/18/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "СhatViewController.h"
#import "ChatMessageTableViewCell.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, weak) IBOutlet UITextField *messageTextField;
@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, strong) QBChatRoom *chatRoom;

- (IBAction)sendMessage:(id)sender;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.messages = [NSMutableArray array];
    
    messageTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    messageTable = [[UITableView alloc] init];
    messageTable.frame = CGRectMake(0, 44, 320, 480);
    messageTable.backgroundColor = [UIColor clearColor];
    messageTable.separatorColor = [UIColor clearColor];
    [self.view insertSubview:messageTable atIndex:2];
    lblTitle.text = [kappDelegate CallerName];
}
-(void)backAction
{
    NSArray *array = [self.navigationController viewControllers];
    
    [self.navigationController popToViewController:[array objectAtIndex:2] animated:YES];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // Set chat notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessageFromRoom object:nil];
    
    // Set title
    if(self.dialog.type == QBChatDialogTypePrivate){
        QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(self.dialog.recipientID)];
        self.title = recipient.login == nil ? recipient.email : recipient.login;
    }else{
        self.title = self.dialog.name;
    }
    
    // Join room
    if(self.dialog.type != QBChatDialogTypePrivate){
        self.chatRoom = [self.dialog chatRoom];
        [[ChatService instance] joinRoom:self.chatRoom completionBlock:^(QBChatRoom *joinedChatRoom) {
            // joined
        }];
    }
    
    NSLog(@"%@",self.dialog.ID);
    // get messages history
    [QBChat messagesWithDialogID:self.dialog.ID extendedRequest:nil delegate:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [QBChat instance].delegate = nil;

    [self.chatRoom leaveRoom];
    self.chatRoom = nil;
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark
#pragma mark Actions

- (IBAction)sendMessage:(id)sender{
    if(self.messageTextField.text.length == 0){
        return;
    }
    
    // create a message
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = self.messageTextField.text;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
    NSLog(@"%lu",(unsigned long)[LocalStorageService shared].currentUser.ID);

    // 1-1 Chat
    if(self.dialog.type == QBChatDialogTypePrivate){
        // send message
        message.recipientID = [self.dialog recipientID];
        message.senderID = [LocalStorageService shared].currentUser.ID;
        
        [[ChatService instance] sendMessage:message];
        
        // save message
        [self.messages addObject:message];
        
        // Group Chat
    }else {
        [[ChatService instance] sendMessage:message toRoom:self.chatRoom];
    }
    
    // Reload table
    messageTable.delegate = self;
    messageTable.dataSource = self;
    [messageTable reloadData];
    if(self.messages.count > 0){
        [messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // Clean text field
    [self.messageTextField setText:nil];
}


#pragma mark
#pragma mark Chat Notifications

- (void)chatDidReceiveMessageNotification:(NSNotification *)notification{
    
    QBChatMessage *message = notification.userInfo[kMessage];
    if(message.senderID != self.dialog.recipientID){
        return;
    }
    
    // save message
    [self.messages addObject:message];
    
    // Reload table
    messageTable.delegate = self;
    messageTable.dataSource = self;

    [messageTable reloadData];
    if(self.messages.count > 0){
        [messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification{
    QBChatMessage *message = notification.userInfo[kMessage];
    NSString *roomJID = notification.userInfo[kRoomJID];
    
    if(![self.chatRoom.JID isEqualToString:roomJID]){
        return;
    }
    
    // save message
    [self.messages addObject:message];
    
    // Reload table
    messageTable.delegate = self;
    messageTable.dataSource = self;

    [messageTable reloadData];
    if(self.messages.count > 0){
        [messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ChatMessageCellIdentifier = @"ChatMessageCellIdentifier";
    
    ChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatMessageCellIdentifier];
    if(cell == nil){
        cell = [[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChatMessageCellIdentifier];
    }
    
    QBChatAbstractMessage *message = self.messages[indexPath.row];
    //
    [cell configureCellWithMessage:message];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QBChatAbstractMessage *chatMessage = [self.messages objectAtIndex:indexPath.row];
    CGFloat cellHeight = [ChatMessageTableViewCell heightForCellWithMessage:chatMessage];
    return cellHeight;
}


#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note
{
    NSDictionary* keyboardInfo = [note userInfo];

    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    NSLog(@"..%@",keyboardFrameBegin);
    [UIView animateWithDuration:0.1 animations:^{
        self.messageTextField.transform = CGAffineTransformMakeTranslation(0, -425);
        self.sendMessageButton.transform = CGAffineTransformMakeTranslation(0, -425);
        messageTable.frame = CGRectMake(messageTable.frame.origin.x,
                                                  messageTable.frame.origin.y,
                                                  messageTable.frame.size.width,
                                                  messageTable.frame.size.height-210);
        if(self.messages.count>0)
            [messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];

    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.1 animations:^{
        self.messageTextField.transform = CGAffineTransformIdentity;
        self.sendMessageButton.transform = CGAffineTransformIdentity;
        messageTable.frame = CGRectMake(messageTable.frame.origin.x,
                                                  messageTable.frame.origin.y,
                                                  messageTable.frame.size.width,
                                                  messageTable.frame.size.height+210);
        if(self.messages.count>0)
            [messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];

    }];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(QBResult *)result
{
    if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class])
    {
        [kappDelegate stopLoaderFromView:self.view];
        QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
        NSArray *messages = res.messages;
        if(messages.count > 0){
            [self.messages addObjectsFromArray:messages];
            //
            messageTable.delegate = self;
            messageTable.dataSource = self;

            [messageTable reloadData];
            if(self.messages.count>0)
                [messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3] animated:YES];
}
@end
