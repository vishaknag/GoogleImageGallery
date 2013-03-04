//
//  ImageCellView.h
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageCellsGridViewController;

@interface ImageCellView : UIButton 
{
@private
   ImageCellsGridViewController *controller_;
}

@property (nonatomic, assign) ImageCellsGridViewController *controller;

- (id)initWithFrame:(CGRect)frame;
- (void)setThumbImage:(UIImage *)newImage;
- (void)setHasBorder:(BOOL)hasBorder;

@end

