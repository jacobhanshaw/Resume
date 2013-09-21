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

#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@interface HomeViewController () <ReaderViewControllerDelegate, ReaderThumbsViewDelegate>

@end

@implementation HomeViewController
{
    BOOL ignoreInitialContentOffsetScroll;
	NSMutableArray *documents;
    
    CustomRefreshControl *refreshControl;
	ReaderThumbsView *theThumbsView;
    
	CGPoint thumbsOffset;
	CGPoint markedOffset;
    
    UILabel *noPDFsLabel;
    UIActivityIndicatorView *activityIndicator;
}

#pragma mark Constants

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
        ignoreInitialContentOffsetScroll = YES;
        thumbs = self; // Return an initialized ThumbsViewController object
    }
    
	return thumbs;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	activityIndicator.center = self.view.center;
    [self.view addSubview: activityIndicator];
    
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
	CGRect viewRect = self.view.bounds; // View controller's view bounds
    
	CGRect thumbsRect = viewRect; UIEdgeInsets insets = UIEdgeInsetsZero;
    
	theThumbsView = [[ReaderThumbsView alloc] initWithFrame:thumbsRect]; // Rest
    
	theThumbsView.contentInset = insets; theThumbsView.scrollIndicatorInsets = insets;
    
	theThumbsView.delegate = self;
    
	[self.view insertSubview:theThumbsView belowSubview:activityIndicator];
    
	BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
    
	NSInteger thumbSize = (large ? PAGE_THUMB_LARGE : PAGE_THUMB_SMALL); // Thumb dimensions
    
	[theThumbsView setThumbSize:CGSizeMake(thumbSize, thumbSize)]; // Thumb size based on device
    
    refreshControl = [[CustomRefreshControl alloc] init];
    refreshControl.hidden = YES;
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [theThumbsView addSubview:refreshControl];
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOut:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
}

- (void)logOut:(UIBarButtonItem *) sender
{
    [documents removeAllObjects];
    [PFUser logOut];
    [self presentViewController:[[LoginViewController alloc] init] animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    if (![PFUser currentUser])
    {
        [self presentViewController:[[LoginViewController alloc] init] animated:NO completion:nil];
        return;
    }
    
    if([documents count] == 0)
        [self refresh: nil];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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
    
    [self loadPDFS];
    
    if(!aRefreshControl)
        [activityIndicator stopAnimating];
    else
        [aRefreshControl endRefreshing];
}

- (void) clearPDFS
{
    [documents removeAllObjects];
    [theThumbsView reloadThumbsCenterOnIndex:([documents count] - 1)];
}

- (void) loadPDFS
{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
	NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
    for(NSString *filePath in pdfs)
    {
        [documents addObject:[ReaderDocument withDocumentFilePath:filePath password:phrase]];
    }
    
    [theThumbsView reloadThumbsCenterOnIndex:([documents count] - 1)];
}

#pragma mark UIThumbsViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!ignoreInitialContentOffsetScroll)
        refreshControl.hidden = NO;
    else
        ignoreInitialContentOffsetScroll = NO;
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
    ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:[documents objectAtIndex:index]];
    
    readerViewController.delegate = self;
    [self.navigationController pushViewController:readerViewController animated:YES];
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
	[self.navigationController popViewControllerAnimated:YES];
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
    
	UIImageView *bookMark;
    
	CGSize maximumSize;
    
	CGRect defaultRect;
}

#pragma mark Constants

#define CONTENT_INSET 8.0f

#pragma mark ThumbsPageThumb instance methods

- (CGRect)markRectInImageView
{
	CGRect iconRect = bookMark.frame; iconRect.origin.y = (-2.0f);
    
	iconRect.origin.x = (imageView.bounds.size.width - bookMark.image.size.width - 8.0f);
    
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
        
		UIImage *image = [UIImage imageNamed:@"Reader-Mark-Y"];
        
		bookMark = [[UIImageView alloc] initWithImage:image];
        
		bookMark.hidden = YES;
		bookMark.autoresizesSubviews = NO;
		bookMark.userInteractionEnabled = NO;
		bookMark.contentMode = UIViewContentModeCenter;
		bookMark.autoresizingMask = UIViewAutoresizingNone;
		bookMark.frame = [self markRectInImageView];
        
		[imageView addSubview:bookMark];
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
    
	bookMark.frame = [self markRectInImageView]; // Position bookmark image
    
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
    
	bookMark.hidden = YES; bookMark.frame = [self markRectInImageView];
    
	tintView.hidden = YES; tintView.frame = imageView.bounds; backView.frame = defaultRect;
    
#if (READER_SHOW_SHADOWS == TRUE) // Option
    
	backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;
    
#endif // end of READER_SHOW_SHADOWS Option
}

- (void)showTouched:(BOOL)touched
{
	tintView.hidden = (touched ? NO : YES);
}

- (void)showText:(NSString *)text
{
	textLabel.text = text;
}

@end
