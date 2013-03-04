//
//  ImageDataSource.m
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import "ImageDataSource.h"
#import "GoogleImageAPI.h"


@interface ImageDataSource ()
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) NSCache *imageCellCache;
@property (nonatomic, retain) NSCache *imageCache;
@end

@implementation ImageDataSource

@synthesize photos = photos_;
@synthesize imageCellCache = imageCellCache_;
@synthesize imageCache = imageCache_;

- (void)dealloc
{
   [photos_ release], photos_ = nil;
   [imageCellCache_ release], imageCellCache_ = nil;
   [imageCache_ release], imageCache_ = nil;
   [super dealloc];
}

- (id)init
{
   self = [super init];
   if (self) {

   }
    
   // Allocate memory for cache
   self.imageCellCache = [[NSCache alloc] init];
   self.imageCache = [[NSCache alloc] init];
    
   return self;
}

- (void)fetchImageCell:(NSDictionary*)imageJson imageCellView:(ImageCellView *)imageCellView index:(NSNumber*)index
{
    // Use the Short Image Title string as the hash string to store the image in cache
    NSString *imageTitleAsValue = [imageJson objectForKey:@"contentNoFormatting"];
    UIImage *cachedImage = [self.imageCellCache objectForKey:imageTitleAsValue];
    
    // If cache not present then create one
    if(self.imageCellCache == nil) {
        self.imageCellCache = [[NSCache alloc] init];
    }
    
    if (cachedImage)
    {
        // Cache version exists
        [imageCellView setThumbImage:cachedImage];
        
        //NSLog(@"Image cell cache fetched = %@", cachedImage);
    }
    else
    {
        //NSLog(@"From internet");
        
        // Set default image as a temporary place holder
        [imageCellView setThumbImage:[UIImage imageNamed:@"photoDefault.png"]];
        
        // the get the image in a parallel thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // get the UIImage
            NSString *urlString = [imageJson objectForKey:@"tbUrl"];
            NSURL *URL = [NSURL URLWithString:urlString];
            NSData *data = [NSData dataWithContentsOfURL:URL];
            UIImage *imageFromData = [UIImage imageWithData:data];
            
            // Once image is downloaded in the background, set it in the view
            if (imageFromData)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Set the image
                    [imageCellView setThumbImage:imageFromData];
                });
                
                // Store the downloaded image into cache for later use
                NSAssert(self.imageCellCache != nil, @"Image cell cache object is missing");
                [self.imageCellCache setObject:imageFromData forKey:imageTitleAsValue];
                
                //NSLog(@"Image cell cache Stored = %@", imageFromData);
            }
        });
    }
}

- (void)fetchImage:(NSDictionary*)imageJson imageView:(ImageView *)imageView index:(NSNumber*)index
{
    // Use the Short Image Title string as the hash string to store the image in cache
    NSString *imageTitleAsValue = [imageJson objectForKey:@"contentNoFormatting"];
    UIImage *cachedImage = [self.imageCache objectForKey:imageTitleAsValue];
    
    // If cache not present then create one
    if(self.imageCache == nil) {
        self.imageCache = [[NSCache alloc] init];
    }
    
    if (cachedImage)
    {
        // Cache version exists
        [imageView setImage:cachedImage];
        
        //NSLog(@"Image cache fetched = %@", cachedImage);
    }
    else
    {
        // Set default image as a temporary place holder
        [imageView setImage:[UIImage imageNamed:@"photoDefault.png"]];
        
        // the get the image in a parallel thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // get the UIImage
            NSString *urlString = [imageJson objectForKey:@"url"];
            NSURL *URL = [NSURL URLWithString:urlString];
            NSData *data = [NSData dataWithContentsOfURL:URL];
            UIImage *imageFromData = [UIImage imageWithData:data];
            
            // Once image is downloaded in the background, set it in the view
            if (imageFromData)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Set the image
                    [imageView setImage:imageFromData];
                });
                
                // Store the downloaded image into cache for later use
                NSAssert(self.imageCache != nil, @"Image cache object is missing");
                [self.imageCache setObject:imageFromData forKey:imageTitleAsValue];
                
                //NSLog(@"Iamge cache Stored = %@", imageFromData);
            }
        });
    }
}

- (void)getGoogleImages:(NSString*)searchQuery
{
   GoogleImageAPI *googleImageAPIObj = [[GoogleImageAPI alloc] init];
   
   NSArray *photos = [googleImageAPIObj imagesWithQueryString:searchQuery];
    
    [googleImageAPIObj release];
   [self setPhotos:photos];
}

#pragma -
#pragma ImageAPI

- (NSInteger)numberOfPhotos
{
   NSInteger count = [[self photos] count];
   return count;
}

// Get image from scroll View
- (void)getImageAtIndex:(NSInteger)index imageView:(ImageView *)imageView {
   NSDictionary *imageJson = [[self photos] objectAtIndex:index];
   
   // cache / Download image
   [self fetchImage:imageJson imageView:imageView index:(NSNumber*)index];
}

// Get image from grid view
- (void)getImageCellAtIndex:(NSInteger)index imageCellView:(ImageCellView *)imageCellView {
   NSDictionary *imageJson = [[self photos] objectAtIndex:index];
   
   // cache / Download image
   [self fetchImageCell:imageJson imageCellView:imageCellView index:(NSNumber*)index];
}

@end
