//
//  MainScreenViewController.m
//  Drivermatrics
//
//  Created by Puneetpal Singh on 03/04/15.
//  Copyright (c) 2015 Ruslan. All rights reserved.
//

#import "MainScreenViewController.h"
#import "ProfileViewController.h"
#import "ListingVC.h"
#import "DialogsViewController.h"
#import "UsersViewController.h"

@interface MainScreenViewController ()

@end

@implementation MainScreenViewController

- (void) initializeCamera {
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    captureVideoPreviewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:captureVideoPreviewLayer atIndex:0];
    
    UIView *view = [self view];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    
    
    {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:input];
    }
    
   
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
#if !(TARGET_IPHONE_SIMULATOR)
    [self initializeCamera];
#endif


}
-(void)viewWillAppear:(BOOL)animated
{
#if !(TARGET_IPHONE_SIMULATOR)
    [session startRunning];
#endif
}

-(void)viewWillDisappear:(BOOL)animated
{
#if !(TARGET_IPHONE_SIMULATOR)
    [session stopRunning];
#endif
}

-(IBAction)LogoutAction:(id)sender
{
    if([[QBChat instance] isLoggedIn])
    {
        [[QBChat instance] logout];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)NavigateToProfile:(id)sender
{
    //[kappDelegate showAlertWithTitle:@"Coming Soon:" message:@""];
    ProfileViewController * PVC=[[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    [self.navigationController pushViewController:PVC animated:YES];

}

-(IBAction)NavigateToLisiting:(id)sender
{
    
    ListingVC * PVC=[[ListingVC alloc] initWithNibName:@"ListingVC" bundle:nil];
    [self.navigationController pushViewController:PVC animated:YES];
}
-(IBAction)ChatVC:(id)sender
{
    //[kappDelegate showAlertWithTitle:@"Coming Soon:" message:@""];

    UsersViewController * DVC=[[UsersViewController alloc] initWithNibName:@"UsersViewController" bundle:nil];
    
    [self.navigationController pushViewController:DVC animated:YES];
}

@end
