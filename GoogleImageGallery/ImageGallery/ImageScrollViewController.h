//
//  ImageScrollViewController.h
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageView.h"

@class ImageViewController;
@protocol ImageAPI;

@interface ImageScrollViewController : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate> 
{
   id <ImageAPI> dataSource_;
   UIScrollView *scrollView_;
   UIToolbar *nav_;
   NSUInteger startWithIndex_;
   NSInteger currentIndex_;
   NSInteger numberOfImages_;
   
   NSMutableArray *imageViewsCache;

   // Keeping track of the page index before rotation 
   int firstVisiblePageIndexBeforeRotation_;
   CGFloat percentScrolledIntoFirstVisiblePage_;
   
   UIStatusBarStyle statusBarStyle_;

   BOOL statusbarHidden_; // Determines if statusbar is hidden at initial load. In other words, statusbar remains hidden when toggling chrome.
   BOOL rotationInProgress_;
  
   BOOL viewDidAppearOnce_;
   BOOL navbarWasTranslucent_;
   
   NSTimer *chromeHideTimer_;
   
   UIBarButtonItem *nextButton_;
   UIBarButtonItem *previousButton_;
}

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign, getter=isStatusbarHidden) BOOL statusbarHidden;
@property (nonatomic, assign) UIScrollView *ImageView;

- (id)initWithDataSource:(id <ImageAPI>)dataSource andStartWithPhotoAtIndex:(NSUInteger)index;

@end
