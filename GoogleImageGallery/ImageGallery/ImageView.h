//
//  ImageView.h
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageScrollViewController;


@interface ImageView : UIScrollView <UIScrollViewDelegate>
{
   UIImageView *imageView_;
   ImageScrollViewController *scroller_;
   NSInteger index_;
}

@property (nonatomic, assign) ImageScrollViewController *scroller;
@property (nonatomic, assign) NSInteger index;

- (void)setImage:(UIImage *)newImage;
- (void)turnOffZoom;

- (CGPoint)pointToCenterAfterRotation;
- (CGFloat)scaleToRestoreAfterRotation;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;
- (UIImage *) loadImageFromResources:(NSString *)imageName;
@end
