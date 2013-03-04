//
//  ImageScrollViewController.m
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import "ImageScrollViewController.h"
#import "ImageAPI.h"

const CGFloat navBarHeight = 44;

@interface ImageScrollViewController (ISVPrivate)
- (void)updateImageViewsCacheWindow:(NSInteger)newIndex;
- (void)nextPhoto;
- (void)previousPhoto;
- (void)updateNavButtonStatus;
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (void)updateImageAt:(NSInteger)index;
- (void)removeImageAt:(NSInteger)index;

@end

@implementation ImageScrollViewController

@synthesize statusBarStyle = statusBarStyle_;
@synthesize statusbarHidden = statusbarHidden_;
@synthesize ImageView = ImageView_;

- (void)dealloc 
{
   [nextButton_ release], nextButton_ = nil;
   [previousButton_ release], previousButton_ = nil;
   [scrollView_ release], scrollView_ = nil;
   [nav_ release], nav_ = nil;
   [imageViewsCache release], imageViewsCache = nil;
  
   [dataSource_ release], dataSource_ = nil;  
   
   [super dealloc];
}

- (id)initWithDataSource:(id <ImageAPI>)dataSource andStartWithPhotoAtIndex:(NSUInteger)index 
{
   if (self = [super init]) {
     startWithIndex_ = index;
     dataSource_ = [dataSource retain];
     
     // Make sure to set wantsFullScreenLayout or the photo
     // will not display behind the status bar.
     [self setWantsFullScreenLayout:YES];

     BOOL isStatusbarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
     [self setStatusbarHidden:isStatusbarHidden];
     
     self.hidesBottomBarWhenPushed = YES;
       
     self.ImageView = [[ImageView alloc] init];
   }
   return self;
}

- (void)loadView 
{
   [super loadView];
   
    // New Frame and View for loading the image at Index
   CGRect scrollFrame = [self frameForPagingScrollView];
   UIScrollView *newView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    
    // Set View properties
   [newView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
   [newView setDelegate:self];
   
    // Black background for Images while scrolling (landscape images)
   UIColor *backgroundColor = [dataSource_ respondsToSelector:@selector(imageBackgroundColor)] ?
                                [dataSource_ imageBackgroundColor] : [UIColor blackColor];
    
   [newView setBackgroundColor:backgroundColor];
   [newView setAutoresizesSubviews:YES];
   [newView setPagingEnabled:YES];
   [newView setShowsVerticalScrollIndicator:NO];
   [newView setShowsHorizontalScrollIndicator:NO];
   
    // Add the ImageScrollView to the FrameScrollView
   [[self view] addSubview:newView];
   
    // Save the newImageScrollView in the controller
   scrollView_ = [newView retain];
   
   [newView release];
   
    // Create Navigation buttons
   nextButton_ = [[UIBarButtonItem alloc] 
                  initWithImage:[self.ImageView loadImageFromResources:(@"nextIcon.png")]
                  style:UIBarButtonItemStylePlain
                  target:self
                  action:@selector(nextPhoto)];
   
   previousButton_ = [[UIBarButtonItem alloc]
                      initWithImage:[self.ImageView loadImageFromResources:(@"previousIcon.png")]
                      style:UIBarButtonItemStylePlain
                      target:self
                      action:@selector(previousPhoto)];

   UIBarItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                    target:nil 
                                                                    action:nil];
   
   NSMutableArray *navItems = [[NSMutableArray alloc] initWithCapacity:7];
   
   [navItems addObject:space];
   [navItems addObject:previousButton_];
   [navItems addObject:space];
   [navItems addObject:space];
   [navItems addObject:space];
   [navItems addObject:nextButton_];
   [navItems addObject:space];
   
   CGRect screenFrame = [[UIScreen mainScreen] bounds];
   CGRect navFrame = CGRectMake(0, screenFrame.size.height - navBarHeight,screenFrame.size.width, navBarHeight);
    
   nav_ = [[UIToolbar alloc] initWithFrame:navFrame];
   [nav_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin];
   [nav_ setBarStyle:UIBarStyleBlackTranslucent];
   [nav_ setItems:navItems];
   [[self view] addSubview:nav_];
   
   [navItems release];
   [space release];
}

- (void)setTitleWithCurrentPhotoIndex 
{
   NSString *title = [NSString stringWithFormat:NSLocalizedString(@"%1$i of %2$i", @"X(current) of Y(total)"), currentIndex_ + 1, numberOfImages_, nil];
   [self setTitle:title];
}

- (void)scrollToIndex:(NSInteger)index 
{
   CGRect frame = scrollView_.frame;
   frame.origin.x = frame.size.width * index;
   frame.origin.y = 0;
   [scrollView_ scrollRectToVisible:frame animated:NO];
}

- (void)setScrollViewContentSize
{
   NSInteger pageCount = numberOfImages_;
   if (pageCount == 0) {
      pageCount = 1;
   }

   CGSize size = CGSizeMake(scrollView_.frame.size.width * pageCount,
                            scrollView_.frame.size.height / 2);   // Cut in half to prevent horizontal scrolling.
   [scrollView_ setContentSize:size];
}

// Set ViewContentSize
// Allocate view cache array
- (void)viewDidLoad
{
   [super viewDidLoad];
  
   numberOfImages_ = [dataSource_ numberOfPhotos];
   [self setScrollViewContentSize];
   
   imageViewsCache = [[NSMutableArray alloc] initWithCapacity:numberOfImages_];
   for (int i=0; i < numberOfImages_; i++) {
      [imageViewsCache addObject:[NSNull null]];
   }
}

- (void)viewWillAppear:(BOOL)animated 
{
   [super viewWillAppear:animated];
   
   // The first time the view appears, store away the previous controller's values so we can reset on pop.
   UINavigationBar *navbar = [[self navigationController] navigationBar];
   if (!viewDidAppearOnce_) {
      viewDidAppearOnce_ = YES;
      navbarWasTranslucent_ = [navbar isTranslucent];
      statusBarStyle_ = [[UIApplication sharedApplication] statusBarStyle];
   }
   // Then ensure translucency. Without it, the view will appear below rather than under it.  
   [navbar setTranslucent:YES];
   [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];

   // Set the scroll view's content size, auto-scroll to the stating photo,
   // and setup the other display elements.
   [self setScrollViewContentSize];
   [self updateImageViewsCacheWindow:startWithIndex_];
   [self scrollToIndex:startWithIndex_];

   [self setTitleWithCurrentPhotoIndex];
    
    // 
   [self updateNavButtonStatus];
}

- (void)viewWillDisappear:(BOOL)animated 
{
  // Reset nav bar translucency and status bar style to whatever it was before.
  UINavigationBar *navbar = [[self navigationController] navigationBar];
  [navbar setTranslucent:navbarWasTranslucent_];
  [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle_ animated:YES];
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated 
{
   [super viewDidDisappear:animated];
}

- (void)updateNavButtonStatus 
{
   [previousButton_ setEnabled:(currentIndex_ > 0)];
   [nextButton_ setEnabled:(currentIndex_ < numberOfImages_ - 1)];
}


#pragma mark -
#pragma mark Frame calculations
#define PADDING  20

- (CGRect)frameForPagingScrollView 
{
   CGRect frame = [[UIScreen mainScreen] bounds];
   frame.origin.x -= PADDING;
   frame.size.width += (2 * PADDING);
   return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index 
{
   // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
   // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
   // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
   // because it has a rotation transform applied.
   CGRect bounds = [scrollView_ bounds];
   CGRect pageFrame = bounds;
   pageFrame.size.width -= (2 * PADDING);
   pageFrame.origin.x = (bounds.size.width * index) + PADDING;
   return pageFrame;
}


#pragma mark -
#pragma mark Photo (Page) Management - Load photo from gallery to full screen

- (void)updateImageAt:(NSInteger)index
{
   // Out of bounds check
   if (index < 0 || index >= numberOfImages_) {
      return;
   }
   
   id currentPhotoView = [imageViewsCache objectAtIndex:index];
    
   // There is no image in the image view cache, create one
   if (NO == [currentPhotoView isKindOfClass:[ImageView class]]) {
      
      // Allocate a Frame and load the photo view.
      CGRect frame = [self frameForPageAtIndex:index];
      ImageView *photoView = [[ImageView alloc] initWithFrame:frame];
      [photoView setScroller:self];
      [photoView setIndex:index];
      [photoView setBackgroundColor:[UIColor clearColor]];
      
      // Set the photo image.
      if (dataSource_) {
         if ([dataSource_ respondsToSelector:@selector(getImageAtIndex:imageView:)] == NO) {
            UIImage *image = [dataSource_ getImageAtIndex:index];
            [photoView setImage:image]; 
         } else {
            [dataSource_ getImageAtIndex:index imageView:photoView];
         }
      }
      
      // Add image view to scroll view at "index", this can be current, prev, next positions
      [scrollView_ addSubview:photoView];
       
      // Save the image view into cache array
      [imageViewsCache replaceObjectAtIndex:index withObject:photoView];
      [photoView release];
       
   } else {
      // Turn off zooming as the image is out of screen bounds
      [currentPhotoView turnOffZoom];
   }
}

- (void)removeImageAt:(NSInteger)index
{
    // Out of bounds check
    if (index < 0 || index >= numberOfImages_) {
      return;
   }
   
   /// remove image view from cache array
   id currentPhotoView = [imageViewsCache objectAtIndex:index];
   if ([currentPhotoView isKindOfClass:[ImageView class]]) {
      [currentPhotoView removeFromSuperview];
      [imageViewsCache replaceObjectAtIndex:index withObject:[NSNull null]];
   }
}

- (void)updateImageViewsCacheWindow:(NSInteger)newIndex
{
   currentIndex_ = newIndex;
   
    // Save the new current imageView into cache
   [self updateImageAt:currentIndex_];
    
   // Update the 3 view cache based on the new current image index
   [self updateImageAt:currentIndex_ + 1];
   [self updateImageAt:currentIndex_ - 1];
   [self removeImageAt:currentIndex_ + 2];
   [self removeImageAt:currentIndex_ - 2];
   
   [self setTitleWithCurrentPhotoIndex];
    
   // Sets to Active/Incative state based on the current index of the image being displayed
   [self updateNavButtonStatus];
}

- (void)resetToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   CGRect navFrame = nav_.frame;
   if ((interfaceOrientation) == UIInterfaceOrientationPortrait || (interfaceOrientation) == UIInterfaceOrientationPortraitUpsideDown) {
      navFrame.size.height = navBarHeight;
   }
   
   navFrame.size.width = self.view.frame.size.width;
   navFrame.origin.y =  self.view.frame.size.height - navFrame.size.height;
   nav_.frame = navFrame;
}

- (void)layoutScrollViewSubviews
{
   [self setScrollViewContentSize];

   NSArray *subviews = [scrollView_ subviews];
   
   for (ImageView *photoView in subviews) {
      CGPoint restorePoint = [photoView pointToCenterAfterRotation];
      CGFloat restoreScale = [photoView scaleToRestoreAfterRotation];
      [photoView setFrame:[self frameForPageAtIndex:[photoView index]]];
      [photoView setMaxMinZoomScalesForCurrentBounds];
      [photoView restoreCenterPoint:restorePoint scale:restoreScale];
   }
   
   // adjust contentOffset to preserve page location based on values collected prior to location
   CGFloat pageWidth = scrollView_.bounds.size.width;
   CGFloat newOffset = (firstVisiblePageIndexBeforeRotation_ * pageWidth) + (percentScrolledIntoFirstVisiblePage_ * pageWidth);
   scrollView_.contentOffset = CGPointMake(newOffset, 0);
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
   return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration 
{
   // here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
   // place to calculate the content offset that we will need in the new orientation
   CGFloat offset = scrollView_.contentOffset.x;
   CGFloat pageWidth = scrollView_.bounds.size.width;
   
   if (offset >= 0) {
      firstVisiblePageIndexBeforeRotation_ = floorf(offset / pageWidth);
      percentScrolledIntoFirstVisiblePage_ = (offset - (firstVisiblePageIndexBeforeRotation_ * pageWidth)) / pageWidth;
   } else {
      firstVisiblePageIndexBeforeRotation_ = 0;
      percentScrolledIntoFirstVisiblePage_ = offset / pageWidth;
   }    
   
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration 
{
   [self layoutScrollViewSubviews];
   [self resetToolbarWithOrientation:toInterfaceOrientation];
   
   if (statusbarHidden_ == NO) {
      UINavigationBar *navbar = [[self navigationController] navigationBar];
      CGRect frame = [navbar frame];
      frame.origin.y = 20;
      [navbar setFrame:frame];
   }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
}

- (UIView *)rotatingFooterView 
{
   return nav_;
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
   CGFloat pageWidth = scrollView.frame.size.width;
   float fractionalPage = scrollView.contentOffset.x / pageWidth;
   NSInteger page = floor(fractionalPage);
	if (page != currentIndex_) {
		[self updateImageViewsCacheWindow:page];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
}


#pragma mark -
#pragma mark Toolbar Actions

- (void)nextPhoto 
{
   [self scrollToIndex:currentIndex_ + 1];
}

- (void)previousPhoto 
{
   [self scrollToIndex:currentIndex_ - 1];
}
@end
