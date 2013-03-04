//
//  ImageCellsGridView.h
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageViewDataSource;
@class ImageCellsGridViewController;
@class ImageCellView;

@interface ImageCellsGridView : UIScrollView <UIScrollViewDelegate>
{
@private
   id <ImageViewDataSource> dataSource_;
   ImageCellsGridViewController *controller_;
   BOOL thumbsHaveBorder_;
   NSInteger thumbsPerRow_;
   CGSize thumbSize_;
   
   NSMutableSet *reusableThumbViews_;
   
   // Keeping track of imge cells visible on screen
   int firstVisibleIndex_;
   int lastVisibleIndex_;
   int lastItemsPerRow_;
}

@property (nonatomic, assign) id<ImageViewDataSource> dataSource;
@property (nonatomic, assign) ImageCellsGridViewController *controller;
@property (nonatomic, assign) BOOL thumbsHaveBorder;
@property (nonatomic, assign) NSInteger thumbsPerRow;
@property (nonatomic, assign) CGSize thumbSize;

- (ImageCellView *)dequeueReusableThumbView;
- (void)reloadData;

@end

@protocol ImageViewDataSource <NSObject>
@required
- (NSInteger)thumbsViewNumberOfThumbs:(ImageCellsGridView *)thumbsView;
- (ImageCellView *)thumbsView:(ImageCellsGridView *)thumbsView thumbForIndex:(NSInteger)index;

@end
