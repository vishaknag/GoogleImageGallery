//
//  GoogleImageAPI.h
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GoogleImageAPI : NSObject {

}
- (NSArray *)imagesWithQueryString:(NSString *)queryString;
- (NSDictionary*)getGImgsJsonFromURL:(NSURL*)url;
- (NSURL *)constructGImgsURLWithParameters:(NSDictionary *)parameters;
@end
