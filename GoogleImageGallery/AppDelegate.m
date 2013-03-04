//
//  GoogleImageGalleryAppDelegate.m
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"


@implementation AppDelegate


@synthesize window=window_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:@"ImageSearchViewController" bundle:nil];
   navController_ = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [navController_ setNavigationBarHidden:YES animated:YES];
    
   [rootViewController release];
   
   [[self window] addSubview:[navController_ view]];

   [self.window makeKeyAndVisible];
   return YES;
}

- (void)dealloc
{
   [navController_ release];
   [window_ release];
   [super dealloc];
}

@end
