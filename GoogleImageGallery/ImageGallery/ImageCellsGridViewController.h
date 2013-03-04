//
//  ImageCellsGridViewController.h
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageAPI.h"
#import "ImageCellsGridView.h"

@class ImageCellsGridView;

@interface ImageCellsGridViewController : UIViewController <ImageViewDataSource>
{
@private
   id <ImageAPI> dataSource_;
   ImageCellsGridView *imageCellsGridView_;
   BOOL viewDidAppearOnce_;
   BOOL navbarWasTranslucent_;
}

@property (nonatomic, retain) id <ImageAPI> dataSource;


// Redisplay image cells
- (void)reloadThumbs;

// When a user clicks and image cell
- (void)didClickImageCellAtIndex:(NSUInteger)index;

- (void)loadImageGridView;
@end
