//
//  ActivityAlertView.m
//  CreamLRG
//
//  Created by Gaurav Jindal on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityAlertView.h"


@implementation ActivityAlertView
@synthesize activityView;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(120,50,30,30)];
		[self addSubview:activityView];
		activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[activityView startAnimating];
    }
	
    return self;
}

- (void) close
{
	[self dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)statAnimation
{
    [activityView startAnimating];
}

//- (void) dealloc
//{
//	[activityView release];
//	[super dealloc];
//}

@end
