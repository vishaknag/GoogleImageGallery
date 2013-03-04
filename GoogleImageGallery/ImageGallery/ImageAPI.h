//
//  ImageAPI.h
//  ImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageView;
@class ImageCellView;

@protocol ImageAPI <NSObject>
@required
- (NSInteger)numberOfPhotos;

@optional

// Implement either these, for synchronous images…
- (UIImage *)getImageAtIndex:(NSInteger)index;
- (UIImage *)getThumbImageAtIndex:(NSInteger)index;

// …or these, for asynchronous images.
- (void)getImageAtIndex:(NSInteger)index imageView:(ImageView *)imageView;
- (void)getImageCellAtIndex:(NSInteger)index imageCellView:(ImageCellView *)imageCellView;

- (CGSize)thumbSize;
- (NSInteger)thumbsPerRow;
- (BOOL)thumbsHaveBorder;
- (UIColor *)imageBackgroundColor;

@end
