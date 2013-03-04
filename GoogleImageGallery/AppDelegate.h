//
//  GoogleImageGalleryAppDelegate.h
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : NSObject <UIApplicationDelegate> 
{
@private
   UIWindow *window_;
   UINavigationController *navController_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
