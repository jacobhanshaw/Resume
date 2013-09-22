//
//  QrCodeViewController.m
//  Resume
//
//  Created by Jacob Hanshaw on 9/22/13.
//  Copyright (c) 2013 Jacob Hanshaw. All rights reserved.
//

#import "QrCodeViewController.h"

#import "QRCodeGenerator.h"

@interface QrCodeViewController ()
{
    NSString *text;
}

@end

@implementation QrCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _qrCodeImageView.image = [QRCodeGenerator qrImageForString:text imageSize:_qrCodeImageView.bounds.size.width];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpWithText:(NSString *) aText
{
    text = aText;
}

- (IBAction)doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
