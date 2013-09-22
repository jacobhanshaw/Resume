//
//  QrCodeViewController.h
//  Resume
//
//  Created by Jacob Hanshaw on 9/22/13.
//  Copyright (c) 2013 Jacob Hanshaw. All rights reserved.
//

@interface QrCodeViewController : UIViewController
{
    
}

@property(weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

- (void) setUpWithText:(NSString *) text;
- (IBAction)doneButtonPressed:(id)sender;

@end