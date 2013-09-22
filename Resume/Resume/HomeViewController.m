//
//	ThumbsViewController.m
//	Reader v2.6.1
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011-2013 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "HomeViewController.h"

#import "ReaderConstants.h"
#import "ReaderThumbRequest.h"
#import "ReaderThumbCache.h"
#import "ReaderDocument.h"

#import "CustomRefreshControl.h"
#import "LoginViewController.h"
#import "ReaderViewController.h"
#import "PointServicesViewController.h"
#import "HomeMainToolbar.h"

#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@interface HomeViewController () <ReaderViewControllerDelegate, ReaderThumbsViewDelegate, HomeMainToolbarDelegate>

@end

@implementation HomeViewController
{
    BOOL editing;
    
    int ignoreInitialContentOffsetScroll;
	NSMutableArray *documents;
    
    CustomRefreshControl *refreshControl;
	ReaderThumbsView *theThumbsView;
    
	CGPoint thumbsOffset;
	CGPoint markedOffset;
    
    HomeMainToolbar *mainToolbar;
    UILabel *noPDFsLabel;
    UIActivityIndicatorView *activityIndicator;
    
    ReaderDocument *documentToDelete;
}

#pragma mark Constants

#define TOOLBAR_HEIGHT 44.0f

#define PAGE_THUMB_SMALL 160
#define PAGE_THUMB_LARGE 256

#pragma mark UIViewController methods

- (id)init
{
	id thumbs = nil; // ThumbsViewController object
    
    if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
    {
        documents = [[NSMutableArray alloc] init];
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        ignoreInitialContentOffsetScroll = 0;
        thumbs = self; // Return an initialized ThumbsViewController object
    }
    
	return thumbs;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
	CGRect viewRect = self.view.bounds; // View controller's view bounds
    
	CGRect thumbsRect = viewRect; UIEdgeInsets insets = UIEdgeInsetsZero;
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		thumbsRect.origin.y += TOOLBAR_HEIGHT; thumbsRect.size.height -= TOOLBAR_HEIGHT;
	}
	else // Set UIScrollView insets for non-UIUserInterfaceIdiomPad case
	{
		insets.top = TOOLBAR_HEIGHT;
	}
    
	theThumbsView = [[ReaderThumbsView alloc] initWithFrame:thumbsRect]; // Rest
    
	theThumbsView.contentInset = insets; theThumbsView.scrollIndicatorInsets = insets;
    
	theThumbsView.delegate = self;
    
	[self.view addSubview:theThumbsView];
    
    CGRect toolbarRect = viewRect; toolbarRect.size.height = TOOLBAR_HEIGHT;
    
	mainToolbar = [[HomeMainToolbar alloc] initWithFrame:toolbarRect andTitle:@"Resumes"]; // At top
	mainToolbar.delegate = self;
    [self.view addSubview:mainToolbar];
    
	BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
    
	NSInteger thumbSize = (large ? PAGE_THUMB_LARGE : PAGE_THUMB_SMALL); // Thumb dimensions
    
	[theThumbsView setThumbSize:CGSizeMake(thumbSize, thumbSize)]; // Thumb size based on device
    
    refreshControl = [[CustomRefreshControl alloc] init];
    refreshControl.hidden = YES;
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [theThumbsView addSubview:refreshControl];
    
    activityIndicator.center = self.view.center;
    [self.view addSubview: activityIndicator];
}

- (void)tappedInToolbar:(HomeMainToolbar *)toolbar logoutButton:(UIButton *)button
{
    [documents removeAllObjects];
    [PFUser logOut];
    
    LoginViewController * loginVC = [[LoginViewController alloc] init];
    loginVC.logInType = AppLogIn;
    [self presentViewController: loginVC animated:YES completion:nil];
}

- (void)tappedInToolbar:(HomeMainToolbar *)toolbar addButton:(UIButton *)button
{
    [self presentViewController: [[PointServicesViewController alloc] init] animated:YES completion:nil];
}

- (void)tappedInToolbar:(HomeMainToolbar *)toolbar editButton:(UIButton *)button
{
    editing = !editing;
    refreshControl.hidden = YES;
    ignoreInitialContentOffsetScroll = 0;
    [theThumbsView reloadThumbsCenterOnIndex:([documents count] - 1)];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    if([documents count] == 0)
        [self refresh: nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
#warning isAuthenticated BROKEN
    if ([[PFUser currentUser].username length] == 0)
    {
        LoginViewController * loginVC = [[LoginViewController alloc] init];
        loginVC.logInType = AppLogIn;
        [self presentViewController: loginVC animated:NO completion:nil];
        return;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	theThumbsView = nil;
    
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

/*
 - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
 {
 }
 
 - (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
 {
 }
 
 - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
 {
 //if (fromInterfaceOrientation == self.interfaceOrientation) return;
 }
 */

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[super didReceiveMemoryWarning];
}

#pragma mark Handle Documents Array

- (void) refresh:(UIRefreshControl *)aRefreshControl
{
    [self clearPDFS];
    
    if(!aRefreshControl)
        [activityIndicator startAnimating];
    
    [self fetchPDFS];
}

- (void) fetchPDFS
{
    if ([[PFUser currentUser].username length] != 0)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Resume"];
        [query whereKey:@"user" equalTo: [PFUser currentUser]];
        __weak id weakSelfForBlock = self;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d pdfs.", objects.count);
                
                [weakSelfForBlock savePDFObjects:objects];
                
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    else
        [self loadPDFS];
}

- (void) savePDFObjects: (NSArray *) objects
{
    __weak id weakSelfForBlock = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, (unsigned long)NULL), ^(void) {
        NSError *error;
        for (PFObject *object in objects)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: object.objectId];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
            
            NSString *finalPath = [dataPath stringByAppendingPathComponent: [object objectForKey:@"title"]];
            
            [[((PFFile *)[object objectForKey:@"applicantResumeFile"]) getData] writeToFile: finalPath options:NSDataWritingAtomic error:nil];
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelfForBlock loadPDFS];
        });
    });
}

- (void) clearPDFS
{
    [documents removeAllObjects];
    [theThumbsView reloadThumbsCenterOnIndex:([documents count] - 1)];
}

- (void) loadPDFS
{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    /*
	NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@".pdf" inDirectory:nil];
    
    for(NSString *filePath in pdfs)
    {
        [documents addObject:[ReaderDocument withDocumentFilePath:filePath password:phrase]];
    }
    */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    NSError *error;
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    for(NSString *directory in directoryContents)
    {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent: directory];
        for(NSString *filePath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:&error])
        {
            fullPath = [fullPath stringByAppendingPathComponent:filePath];
            if(filePath && [[filePath substringFromIndex:[filePath length] - 3] isEqualToString:@"pdf"])
                [documents addObject:[ReaderDocument withDocumentFilePath:fullPath password:phrase]];
        }
    }
    
    [theThumbsView reloadThumbsCenterOnIndex:([documents count] - 1)];
    
    if([documents count] == 0)
    {
        noPDFsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        noPDFsLabel.center = self.view.center;
        noPDFsLabel.numberOfLines = 0;
        noPDFsLabel.text = @"No PDFs found. Add one with the add button above.";
        noPDFsLabel.textAlignment = UITextAlignmentCenter;
        
        [self.view addSubview:noPDFsLabel];
    }
    else
    {
        if(noPDFsLabel)
        {
            [noPDFsLabel removeFromSuperview];
            noPDFsLabel = nil;
        }
    }
    
    [activityIndicator stopAnimating];
    [refreshControl endRefreshing];
}

#pragma mark UIThumbsViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(ignoreInitialContentOffsetScroll == 2)
        refreshControl.hidden = NO;
    else
        ++ignoreInitialContentOffsetScroll;
}

- (NSUInteger)numberOfThumbsInThumbsView:(ReaderThumbsView *)thumbsView
{
	return [documents count];
}

- (id)thumbsView:(ReaderThumbsView *)thumbsView thumbCellWithFrame:(CGRect)frame
{
	return [[ThumbsPageThumbNoBookmark alloc] initWithFrame:frame];
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView updateThumbCell:(ThumbsPageThumbNoBookmark *)thumbCell forIndex:(NSInteger)index
{
	CGSize size = [thumbCell maximumContentSize]; // Get the cell's maximum content size
    
	ReaderDocument *document = [documents objectAtIndex:index];
    
	[thumbCell showText:[document.fileName stringByDeletingPathExtension]]; // Page number place holder
    [thumbCell showEditImage:editing];
    
	NSURL *fileURL = document.fileURL; NSString *guid = document.guid; NSString *phrase = document.password; // Document info
    
	ReaderThumbRequest *thumbRequest = [ReaderThumbRequest newForView:thumbCell fileURL:fileURL password:phrase guid:guid page:1 size:size];
    
	UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:thumbRequest priority:YES]; // Request the thumbnail
    
	if ([image isKindOfClass:[UIImage class]]) [thumbCell showImage:image]; // Show image from cache
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView refreshThumbCell:(ThumbsPageThumbNoBookmark *)thumbCell forIndex:(NSInteger)index
{
    
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView didSelectThumbWithIndex:(NSInteger)index
{
    if(editing)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Are you sure you would like to delete this document?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
        documentToDelete = [documents objectAtIndex:index];
    }
    else
    {
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:[documents objectAtIndex:index]];
        readerViewController.delegate = self;
        [self presentViewController:readerViewController animated:YES completion:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"Are you sure?"] && buttonIndex != 0)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        if ([fileManager removeItemAtPath:documentToDelete.fullFilePath error:&error] != YES)
            NSLog(@"%@", [error localizedDescription]);
        [self refresh:nil];
    }
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
	[viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView didPressThumbWithIndex:(NSInteger)index
{
    
}

@end

#pragma mark -

//
//	ThumbsPageThumb class implementation
//

@implementation ThumbsPageThumbNoBookmark
{
	UIView *backView;
    
	UIView *tintView;
    
	UILabel *textLabel;
    
	UIImageView *deleteImage;
    
	CGSize maximumSize;
    
	CGRect defaultRect;
}

#pragma mark Constants

#define CONTENT_INSET 8.0f

#pragma mark ThumbsPageThumb instance methods

- (CGRect)markRectInImageView
{
	CGRect iconRect = deleteImage.frame; iconRect.origin.y = (0.0f);
    
	iconRect.origin.x = (imageView.bounds.size.width - deleteImage.frame.size.width);
    
	return iconRect; // Frame position rect inside of image view
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		imageView.contentMode = UIViewContentModeCenter;
        
		defaultRect = CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET);
        
		maximumSize = defaultRect.size; // Maximum thumb content size
        
		CGFloat newWidth = ((defaultRect.size.width / 4.0f) * 3.0f);
        
		CGFloat offsetX = ((defaultRect.size.width - newWidth) / 2.0f);
        
		defaultRect.size.width = newWidth; defaultRect.origin.x += offsetX;
        
		imageView.frame = defaultRect; // Update the image view frame
        
		CGFloat fontSize = (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 19.0f : 16.0f);
        
		textLabel = [[UILabel alloc] initWithFrame:defaultRect];
        
		textLabel.autoresizesSubviews = NO;
		textLabel.userInteractionEnabled = NO;
		textLabel.contentMode = UIViewContentModeRedraw;
		textLabel.autoresizingMask = UIViewAutoresizingNone;
		textLabel.textAlignment = UITextAlignmentCenter;
		textLabel.font = [UIFont systemFontOfSize:fontSize];
		textLabel.textColor = [UIColor colorWithWhite:0.24f alpha:1.0f];
		textLabel.backgroundColor = [UIColor whiteColor];
        
		[self insertSubview:textLabel belowSubview:imageView];
        
		backView = [[UIView alloc] initWithFrame:defaultRect];
        
		backView.autoresizesSubviews = NO;
		backView.userInteractionEnabled = NO;
		backView.contentMode = UIViewContentModeRedraw;
		backView.autoresizingMask = UIViewAutoresizingNone;
		backView.backgroundColor = [UIColor whiteColor];
        
#if (READER_SHOW_SHADOWS == TRUE) // Option
        
		backView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
		backView.layer.shadowRadius = 3.0f; backView.layer.shadowOpacity = 1.0f;
		backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;
        
#endif // end of READER_SHOW_SHADOWS Option
        
		[self insertSubview:backView belowSubview:textLabel];
        
		tintView = [[UIView alloc] initWithFrame:imageView.bounds];
        
		tintView.hidden = YES;
		tintView.autoresizesSubviews = NO;
		tintView.userInteractionEnabled = NO;
		tintView.contentMode = UIViewContentModeRedraw;
		tintView.autoresizingMask = UIViewAutoresizingNone;
		tintView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
        
		[imageView addSubview:tintView];
        
		UIImage *image = [UIImage imageNamed:@"x-mark-64.png"];
        
		deleteImage = [[UIImageView alloc] initWithImage:image];
        deleteImage.frame = CGRectMake(0, 0, 20, 20);
		deleteImage.hidden = YES;
		deleteImage.autoresizesSubviews = NO;
		deleteImage.userInteractionEnabled = NO;
		deleteImage.contentMode = UIViewContentModeScaleAspectFit;
		deleteImage.autoresizingMask = UIViewAutoresizingNone;
		deleteImage.frame = [self markRectInImageView];
        
		[imageView addSubview:deleteImage];
	}
    
	return self;
}

- (CGSize)maximumContentSize
{
	return maximumSize;
}

- (void)showImage:(UIImage *)image
{
	NSInteger x = (self.bounds.size.width / 2.0f);
	NSInteger y = (self.bounds.size.height / 2.0f);
    
	CGPoint location = CGPointMake(x, y); // Center point
    
	CGRect viewRect = CGRectZero; viewRect.size = image.size;
    
	textLabel.bounds = viewRect; textLabel.center = location; // Position
    
	imageView.bounds = viewRect; imageView.center = location; imageView.image = image;
    
	deleteImage.frame = [self markRectInImageView]; // Position bookmark image
    
	tintView.frame = imageView.bounds; backView.bounds = viewRect; backView.center = location;
    
#if (READER_SHOW_SHADOWS == TRUE) // Option
    
	backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;
    
#endif // end of READER_SHOW_SHADOWS Option
}

- (void)reuse
{
	[super reuse]; // Reuse thumb view
    
	textLabel.text = nil; textLabel.frame = defaultRect;
    
	imageView.image = nil; imageView.frame = defaultRect;
    
	deleteImage.hidden = YES; deleteImage.frame = [self markRectInImageView];
    
	tintView.hidden = YES; tintView.frame = imageView.bounds; backView.frame = defaultRect;
    
#if (READER_SHOW_SHADOWS == TRUE) // Option
    
	backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;
    
#endif // end of READER_SHOW_SHADOWS Option
}

- (void)showTouched:(BOOL)touched
{
	tintView.hidden = (touched ? NO : YES);
}

- (void)showEditImage:(BOOL)aEditing
{
	deleteImage.hidden = (aEditing ? NO : YES);
}

- (void)showText:(NSString *)text
{
	textLabel.text = text;
}

@end
