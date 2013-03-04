//
//  ImageCellView.m
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import "ImageCellView.h"
#import "ImageCellsGridViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation ImageCellView

@synthesize controller = controller_;

- (void)dealloc 
{
   [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame]) {

      [self addTarget:self
               action:@selector(didTouch:)
     forControlEvents:UIControlEventTouchUpInside];
      
      [self setClipsToBounds:YES];
      [[self imageView] setContentMode:UIViewContentModeScaleAspectFill];
   }
   return self;
}

- (void)didTouch:(id)sender
{
   if (controller_) {
      [controller_ didClickImageCellAtIndex:[self tag]];
   }
}

- (void)setThumbImage:(UIImage *)newImage 
{
  [self setImage:newImage forState:UIControlStateNormal];
}

- (void)setHasBorder:(BOOL)hasBorder
{
   if (hasBorder) {
      self.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
      self.layer.borderWidth = 1;
   } else {
      self.layer.borderColor = nil;
   }
}


@end
