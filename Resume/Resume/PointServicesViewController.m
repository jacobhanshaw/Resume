//
//  PointServicesViewController.m
//  Resume
//
//  Created by Jacob Hanshaw on 9/21/13.
//  Copyright (c) 2013 Jacob Hanshaw. All rights reserved.
//

#import "PointServicesViewController.h"

#import "LoginViewController.h"
#import "PointIOController.h"

typedef enum {
    PointSection,
    CodeSection,
    BumpSection,
    NumSections
} SectionLabel;

static NSString *PointCellIdentifier = @"PointCell";
static NSString *CodeCellIdentifier  = @"CodeCell";
static NSString *BumpCellIdentifier  = @"BumpCell";

@interface PointServicesViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *servicesTableView;
}

@end

@implementation PointServicesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    servicesTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    servicesTableView.dataSource = self;
    servicesTableView.delegate = self;
    [self.view addSubview:servicesTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
    if (![[PointIOController sharedPoint] loggedIn])
    {
        LoginViewController * loginVC = [[LoginViewController alloc] init];
        loginVC.logInType = PointIOLogIn;
        [self presentViewController: loginVC animated:YES completion:nil];
        return;
    }
    
    servicesTableView.frame = self.view.bounds;
}

#pragma mark Table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NumSections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == PointSection)
        return 0;
    else
        return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        /*case PointSection:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PointCellIdentifier];
            if(!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PointCellIdentifier];
                [cell addSubview:imageView];
                CGRect frame = captionTextView.frame;
                frame.size.width = cell.frame.size.width - 2 * NOTE_CONTENT_CELL_X_MARGIN - IMAGE_WIDTH - NOTE_CONTENT_IMAGE_TEXT_MARGIN;
                captionTextView.frame = frame;
                [cell addSubview:captionTextView];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                
                
                // set Cell Name
                NSString *tmpSiteName = [[_storageSiteTypesInUse objectAtIndex:indexPath.row] valueForKey:@"StorageSiteSiteTypeName"];
                cell.nameLabel.text = tmpSiteName;
                
                // Set Cell Image
                // Values are stored in sorted Dictionary in AppContent.plist
                NSString *tmpFileName               = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppContent"];
                NSString *tmpFilePath               = [[NSBundle mainBundle] pathForResource:tmpFileName ofType:@"plist"];
                NSMutableDictionary *tmpDictionary  = [[NSMutableDictionary alloc] initWithContentsOfFile:tmpFilePath];
                NSDictionary *cloudProviderDict     = [tmpDictionary valueForKey:@"storageProviderArtwork"];
                NSString *tmpImageName  = [cloudProviderDict valueForKey:tmpSiteName];
                cell.storageImage.image = [UIImage imageNamed:tmpImageName];
            }
            return cell;
        }
           */
        default:
            return nil;
    }
}

-(void)tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end