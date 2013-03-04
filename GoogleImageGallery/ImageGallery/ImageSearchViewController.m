//
//  ImageSearchViewController.m
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/3/13.
//  Copyright (c) 2013 White Peak Software Inc. All rights reserved.
//

#import "ImageSearchViewController.h"
#import "ImageDataSource.h"

@interface ImageSearchViewController ()
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
- (ImageDataSource *)imageDataSource:(NSString*)searchQuery;
@end

@implementation ImageSearchViewController

@synthesize activityIndicator = activityIndicator_;
@synthesize searchField = _searchField;
@synthesize imageDataSource = imageDataSource_;

- (void)dealloc {
    [imageDataSource_ release], imageDataSource_ = nil;
    [activityIndicator_ release], activityIndicator_ = nil;
    [_searchField release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.view.hidden = NO;
}

- (ImageDataSource *)imageDataSource:(NSString*)searchQuery
{
    if (imageDataSource_) {
        return imageDataSource_;
    }
 
     imageDataSource_ = [[ImageDataSource alloc] init];
     [imageDataSource_ getGoogleImages:searchQuery];
 
     return imageDataSource_;
}

- (void)searchBackButtonClicked
{
    ImageSearchViewController *searchViewController = [[ImageSearchViewController alloc] initWithNibName:@"ImageSearchViewController" bundle:nil];
    
    UIView *tmpView = (UIView *)[self.view viewWithTag:10];
    
    [self.view addSubview:searchViewController.view];
    [searchViewController release];
}

-(IBAction)searchButton
{
    for (UIView *subView in self.view.subviews) {
        if([subView isKindOfClass:[ImageSearchViewController class]]) {
            [subView removeFromSuperview];
        }
    }
            
    NSString *searchQuery = [self.searchField.text stringByAppendingString:@""];

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
    [activityIndicator setCenter:[[self view] center]];
    [activityIndicator startAnimating];
    [self setActivityIndicator:activityIndicator];
    [activityIndicator release];

    [[self view] addSubview:[self activityIndicator]];

    // Back button from Image Scroll view
    if(self.navigationController.navigationBar.backItem == nil) {
        UIBarButtonItem *galleryButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Gallery", @"Back button title") style:UIBarButtonItemStylePlain target:nil action:nil];
        [[self navigationItem] setBackBarButtonItem:galleryButton];
        [galleryButton release];
    }

    // Link here
    [self setDataSource:[self imageDataSource:searchQuery]];
    [self setTitle:[NSString stringWithFormat:@"Google Images"]];
    [[self activityIndicator] stopAnimating];

    /*
    if(self.navigationItem.leftBarButtonItem == nil) {
        UIBarButtonItem *searchBackButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Search", @"Search button") style:UIBarButtonItemStylePlain target:self action:@selector(searchBackButtonClicked)];
        self.navigationItem.leftBarButtonItem = searchBackButton;
        [searchBackButton release];
    }
    */
    
    [self loadImageGridView];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload {
    [self setSearchField:nil];
    [super viewDidUnload];
}
@end
