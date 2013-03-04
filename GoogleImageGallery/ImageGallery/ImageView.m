//
//  ImageView.m
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import "ImageView.h"
#import "ImageScrollViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ImageView (PrivateMethods)
- (void)loadSubviewsWithFrame:(CGRect)frame;
- (BOOL)isZoomed;
@end

@implementation ImageView

@synthesize scroller = scroller_;
@synthesize index = index_;

- (UIImage *)loadImageFromResources:(NSString *)imageName {
    NSString *relativePath = [NSString stringWithFormat:@"ImageGallery.bundle/images/%@", imageName];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSData *data = [NSData dataWithContentsOfFile:[resourcePath stringByAppendingPathComponent:relativePath]];
    return [UIImage imageWithData:data];
}

- (void)dealloc 
{
   [imageView_ release], imageView_ = nil;
   [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      [self setDelegate:self];
      [self setMaximumZoomScale:5.0];
      [self setShowsHorizontalScrollIndicator:NO];
      [self setShowsVerticalScrollIndicator:NO];
      [self loadSubviewsWithFrame:frame];
   }
   return self;
}

- (void)loadSubviewsWithFrame:(CGRect)frame
{
   imageView_ = [[UIImageView alloc] initWithFrame:frame];
   [imageView_ setContentMode:UIViewContentModeScaleAspectFit];
   [self addSubview:imageView_];
}

- (void)setImage:(UIImage *)newImage 
{
   [imageView_ setImage:newImage];
}

- (void)layoutSubviews 
{
   [super layoutSubviews];

   if ([self isZoomed] == NO && CGRectEqualToRect([self bounds], [imageView_ frame]) == NO) {
      [imageView_ setFrame:[self bounds]];
   }
}


- (BOOL)isZoomed
{
   return !([self zoomScale] == [self minimumZoomScale]);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center 
{
   
   CGRect zoomRect;
   zoomRect.size.height = [self frame].size.height / scale;
   zoomRect.size.width  = [self frame].size.width  / scale;
    
   zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
   zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
   
   return zoomRect;
}

- (void)zoomToLocation:(CGPoint)location
{
   float newScale;
   CGRect zoomRect;
   if ([self isZoomed]) {
      zoomRect = [self bounds];
   } else {
      newScale = [self maximumZoomScale];
      zoomRect = [self zoomRectForScale:newScale withCenter:location];
   }
   
   [self zoomToRect:zoomRect animated:YES];
}

- (void)turnOffZoom
{
   if ([self isZoomed]) {
      [self zoomToLocation:CGPointZero];
   }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
   UITouch *touch = [touches anyObject];
   
   if ([touch view] == self) {
      if ([touch tapCount] == 2) {
         [self zoomToLocation:[touch locationInView:self]];
      }
   }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   UITouch *touch = [touches anyObject];
   
   if ([touch view] == self) {
      if ([touch tapCount] == 1) {
      }
   }
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
   UIView *viewToZoom = imageView_;
   return viewToZoom;
}


#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

- (void)setMaxMinZoomScalesForCurrentBounds
{
   CGSize boundsSize = self.bounds.size;
   CGSize imageSize = imageView_.bounds.size;
   
   // calculate min/max zoomscale
   CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
   CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
   CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
   
   // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
   // maximum zoom scale to 0.5.
   CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
   
   // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
   if (minScale > maxScale) {
      minScale = maxScale;
   }
   
   self.maximumZoomScale = maxScale;
   self.minimumZoomScale = minScale;
}

// returns the center point, in image coordinate space, to try to restore after rotation. 
- (CGPoint)pointToCenterAfterRotation
{
   CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
   return [self convertPoint:boundsCenter toView:imageView_];
}

// returns the zoom scale to attempt to restore after rotation. 
- (CGFloat)scaleToRestoreAfterRotation
{
   CGFloat contentScale = self.zoomScale;
   
   // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
   // allowable scale when the scale is restored.
   if (contentScale <= self.minimumZoomScale + FLT_EPSILON)
      contentScale = 0;
   
   return contentScale;
}

- (CGPoint)maximumContentOffset
{
   CGSize contentSize = self.contentSize;
   CGSize boundsSize = self.bounds.size;
   return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
   return CGPointZero;
}

// Adjusts content offset and scale to try to preserve the old zoomscale and center.
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale
{    
   // Step 1: restore zoom scale, first making sure it is within the allowable range.
   self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, oldScale));
   
   
   // Step 2: restore center point, first making sure it is within the allowable range.
   
   // 2a: convert our desired center point back to our own coordinate space
   CGPoint boundsCenter = [self convertPoint:oldCenter fromView:imageView_];
   // 2b: calculate the content offset that would yield that center point
   CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0, 
                                boundsCenter.y - self.bounds.size.height / 2.0);
   // 2c: restore offset, adjusted to be within the allowable range
   CGPoint maxOffset = [self maximumContentOffset];
   CGPoint minOffset = [self minimumContentOffset];
   offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
   offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
   self.contentOffset = offset;
}



@end
