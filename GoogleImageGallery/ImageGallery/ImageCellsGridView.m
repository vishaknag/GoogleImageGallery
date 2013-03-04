//
//  ImageCellsGridView.m
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import "ImageCellsGridView.h"
#import "ImageCellView.h"
#import "ImageCellsGridViewController.h"


@implementation ImageCellsGridView

@synthesize dataSource = dataSource_;
@synthesize controller = controller_;
@synthesize thumbsHaveBorder = thumbsHaveBorder_;
@synthesize thumbsPerRow = thumbsPerRow_;
@synthesize thumbSize = thumbSize_;

- (void)dealloc
{
   [reusableThumbViews_ release], reusableThumbViews_ = nil;
   [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      thumbsHaveBorder_ = YES;
      thumbsPerRow_ = 3;
      thumbSize_ = CGSizeMake(100, 100);
      reusableThumbViews_ = [[NSMutableSet alloc] init];
      
      firstVisibleIndex_ = NSIntegerMax;
      lastVisibleIndex_  = NSIntegerMin;
      lastItemsPerRow_   = NSIntegerMin;
   }
   return self;
}

- (ImageCellView *)dequeueReusableThumbView
{
   ImageCellView *thumbView = [reusableThumbViews_ anyObject];
   if (thumbView != nil) {
      [[thumbView retain] autorelease];
      [reusableThumbViews_ removeObject:thumbView];
   }
   return thumbView;
}

- (void)queueReusableThumbViews
{
   for (UIView *view in [self subviews]) {
      if ([view isKindOfClass:[ImageCellView class]]) {
         [reusableThumbViews_ addObject:view];
         [view removeFromSuperview];
      }
   }
   
   firstVisibleIndex_ = NSIntegerMax;
   lastVisibleIndex_  = NSIntegerMin;
}

- (void)reloadData
{
   [self queueReusableThumbViews];
   [self setNeedsLayout];
}

// Keep track on the current screen position and efficiently add/remove ImageCells
- (void)layoutSubviews 
{
   [super layoutSubviews];

   CGRect visibleBounds = [self bounds];
   int visibleWidth = visibleBounds.size.width;
   int visibleHeight = visibleBounds.size.height;
   
   // Find the visible rows and columns
   int itemsPerRow = thumbsPerRow_;
   if (itemsPerRow == NSIntegerMin) {
      itemsPerRow = floor(visibleWidth / thumbSize_.width);
   }
   if (itemsPerRow != lastItemsPerRow_) {
       [self queueReusableThumbViews];
   }
   lastItemsPerRow_ = itemsPerRow;
   
   // Ensure a minimum of space between images.
   int minimumSpace = 5;
   if (visibleWidth - itemsPerRow * thumbSize_.width < minimumSpace) {
     itemsPerRow--;
   }
   
   if (itemsPerRow < 1) itemsPerRow = 1;  // Ensure at least one per row.
   
   // Space around each imageCell
   int spaceWidth = round((visibleWidth - thumbSize_.width * itemsPerRow) / (itemsPerRow + 1));
   int spaceHeight = spaceWidth;
   
   // Calculate content size.
   int thumbCount = [dataSource_ thumbsViewNumberOfThumbs:self];
   int rowCount = ceil(thumbCount / (float)itemsPerRow);
   int rowHeight = thumbSize_.height + spaceHeight;
    
   // Scrolabble content size based on the number of images to be displayed
   CGSize contentSize = CGSizeMake(visibleWidth, (rowHeight * rowCount + spaceHeight));
   [self setContentSize:contentSize];
   
   // Number of rows that can fit into screen
   NSInteger rowsPerView = visibleHeight / rowHeight;
    
   // Index of Top row on screen - will be first or any intermediate row
   NSInteger topRow = MAX(0, floorf(visibleBounds.origin.y / rowHeight));
   
   // Index of Bottom row on screen
   NSInteger bottomRow = topRow + rowsPerView;

   // Size of rows on screen + 1 row (if half row is visible, then we will have to load the n+1th row onload)
   CGRect extendedVisibleBounds = CGRectMake(visibleBounds.origin.x, MAX(0, visibleBounds.origin.y), visibleBounds.size.width, visibleBounds.size.height + rowHeight);
   
   // Push imageCells to reusable pool once out of view
   for (UIView *view in [self subviews]) {
      
      if ([view isKindOfClass:[ImageCellView class]]) {
         
         CGRect imageCellFrame = [view frame];
         
         // If the view doesn't intersect, it's not visible, so we can recycle it
         if (! CGRectIntersectsRect(imageCellFrame, extendedVisibleBounds)) {
            [reusableThumbViews_ addObject:view];
            [view removeFromSuperview];
         }
      }
   }
    
   // ImageCell start and end Index in the current frame of time
   NSInteger startAtIndex = MAX(0, topRow * itemsPerRow);
   NSInteger stopAtIndex = MIN(thumbCount, (bottomRow * itemsPerRow) + itemsPerRow);

   // Origin of the view at this point of time
   int x = spaceWidth;
   int y = spaceHeight + (topRow * rowHeight);
   
   // Create and add any ImageCells between startIndex and endIndex if not already on screen
   for (int index = startAtIndex; index < stopAtIndex; index++) {
    
      // If the required ImageCell index is already on screen,
      // then continue checking with the next cell
      BOOL isThumbViewMissing = !(index >= firstVisibleIndex_ && index < lastVisibleIndex_);

      if (isThumbViewMissing) {
          
         // Create a brand new Imagecell
         ImageCellView *thumbView = [dataSource_ thumbsView:self thumbForIndex:index];

         // Add cell into Frame for proper alignment
         CGRect newFrame = CGRectMake(x, y, thumbSize_.width, thumbSize_.height);
         [thumbView setFrame:newFrame];

         // Mark it with its Index
         [thumbView setTag:index];
         
         [thumbView setHasBorder:thumbsHaveBorder_];
         
         // Show it on Screen
         [self addSubview:thumbView];
      }

      
      // If this is the last ImageCell in the current row then update both x and y
      if ( (index+1) % itemsPerRow == 0) {
         x = spaceWidth;
         y += thumbSize_.height + spaceHeight;
      } else {  // Just update x position
         x += thumbSize_.width + spaceWidth;
      }
   }
   
   // Remember which thumb view indexes are visible.
   firstVisibleIndex_ = startAtIndex;
   lastVisibleIndex_  = stopAtIndex;
}


@end
