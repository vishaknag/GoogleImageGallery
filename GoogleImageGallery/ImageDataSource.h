//
//  ImageDataSource.h
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageAPI.h"


@interface ImageDataSource : NSObject <ImageAPI>
{
@private
    NSArray *images_;
    NSCache *imageCellCache_;
    NSCache *imageCache_;
}

- (void)getGoogleImages:(NSString*)searchQuery;
- (void)fetchImageCell:(NSDictionary*)imageJsonArray imageCellView:(ImageCellView *)imageCellView index:(NSNumber*)index;
- (void)fetchImage:(NSDictionary*)imageJsonArray imageView:(ImageView *)imageView index:(NSNumber*)index;
@end
