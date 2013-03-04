//
//  ImageSearchViewController.h
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/3/13.
//  Copyright (c) 2013 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCellsGridViewController.h"

@class ImageDataSource;

@interface ImageSearchViewController : ImageCellsGridViewController

@property (retain, nonatomic) IBOutlet UITextField *searchField;
- (IBAction)searchButton;

@property (nonatomic, retain) ImageDataSource *imageDataSource;

@end


