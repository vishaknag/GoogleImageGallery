//
//  ImageCellsGridViewController.m
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import "ImageCellsGridViewController.h"
#import "ImageCellsGridView.h"
#import "ImageCellView.h"
#import "ImageScrollViewController.h"


@interface ImageCellsGridViewController (Private)
@end


@implementation ImageCellsGridViewController

@synthesize dataSource = dataSource_;

- (void)dealloc {
   [imageCellsGridView_ release], imageCellsGridView_ = nil;
   
   [super dealloc];
}

- (void)loadImageGridView {
    NSLog(@"1");
   [self setWantsFullScreenLayout:YES];

   // Create the image cells grid scroll view
   ImageCellsGridView *imageCellsGridView = [[ImageCellsGridView alloc] initWithFrame:CGRectZero];
    
   // Controller serves as datasource
   [imageCellsGridView setDataSource:self];
   [imageCellsGridView setController:self];
    
   [imageCellsGridView setScrollsToTop:YES];
   [imageCellsGridView setScrollEnabled:YES];
   [imageCellsGridView setAlwaysBounceVertical:YES];
   [imageCellsGridView setBackgroundColor:[UIColor blackColor]];
   
   if ([self.dataSource respondsToSelector:@selector(thumbsHaveBorder)]) {
      [imageCellsGridView setThumbsHaveBorder:[self.dataSource thumbsHaveBorder]];
   }
   
   if ([self.dataSource respondsToSelector:@selector(thumbSize)]) {
      [imageCellsGridView setThumbSize:[self.dataSource thumbSize]];
   }
   
   if ([self.dataSource respondsToSelector:@selector(thumbsPerRow)]) {
      [imageCellsGridView setThumbsPerRow:[self.dataSource thumbsPerRow]];
   }
    
   // show navigation bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
   // Make the grid view as the main view
   imageCellsGridView.tag = 10;
   [self setView:imageCellsGridView];
    
   // Retain the reference
   imageCellsGridView_ = imageCellsGridView;
   [imageCellsGridView_ retain];
   
   [imageCellsGridView release];
}

- (void)viewWillAppear:(BOOL)animated {
  UINavigationBar *navbar = [[self navigationController] navigationBar];
  
  if (!viewDidAppearOnce_) {
    viewDidAppearOnce_ = YES;
    navbarWasTranslucent_ = [navbar isTranslucent];
  }
  
  [navbar setTranslucent:YES];
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  UINavigationBar *navbar = [[self navigationController] navigationBar];
  [navbar setTranslucent:navbarWasTranslucent_];
  [super viewWillDisappear:animated];
}

- (void)reloadThumbs {
   [imageCellsGridView_ reloadData];
}

// Receive new list of images for Google API
- (void)setDataSource:(id <ImageAPI>)newDataSource {
   dataSource_ = newDataSource;
   [self reloadThumbs];
}

// Fire the Scroll View to display the selected image in full screen, zoomable, scrollable
- (void)didClickImageCellAtIndex:(NSUInteger)index {
   ImageScrollViewController *newController = [[ImageScrollViewController alloc]
                                                 initWithDataSource:dataSource_
                                                 andStartWithPhotoAtIndex:index];
  
   // Firing a segue using code
   [[self navigationController] pushViewController:newController animated:YES];
   [newController release];
}


#pragma mark -
#pragma mark ImageViewDataSource

- (NSInteger)thumbsViewNumberOfThumbs:(ImageCellsGridView *)thumbsView
{
   // Grabs the image count from Google Images datasource
   NSInteger count = [dataSource_ numberOfPhotos];
   return count;
}

// Get ImageCell at index from the ImageCellsGrid
- (ImageCellView *)thumbsView:(ImageCellsGridView *)imageCellsGridView thumbForIndex:(NSInteger)index
{
   // Fetch a reusable imageCell
   ImageCellView *imageCellView = [imageCellsGridView dequeueReusableThumbView];
    
   // If not found in the reusable pool, create a brand new one
   if (!imageCellView) {
      imageCellView = [[[ImageCellView alloc] initWithFrame:CGRectZero] autorelease];
      [imageCellView setController:self];
   }

   // Set image fetched from Google images datasource into the cell created
   if ([dataSource_ respondsToSelector:@selector(getThumbImageAtIndex:thumbView:)] == NO) {
       
      // Set thumbnail image asynchronously.
      [dataSource_ getImageCellAtIndex:index imageCellView:imageCellView];
       
   }
   
   return imageCellView;
}


@end
