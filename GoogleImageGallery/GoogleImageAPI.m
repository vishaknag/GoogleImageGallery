//
//  GoogleImageAPI.m
//  GoogleImageGallery
//
//  Created by Vishak Nag Ashoka on 3/2/13.
//  Copyright 2013 Vishak Nag Ashoka All rights reserved.
//

#import "GoogleImageAPI.h"
#import "JSON.h"

#define googleImagesBaseURL @"https://ajax.googleapis.com/ajax/services/search/images?"
#define queryParam @"q"
#define protocolVersionParam @"v"
#define protocolVersion @"1.0"
#define colorScaleParam @"imgc"
#define colorScale @"gray"
#define fileFormatParam @"as_filetype"
#define fileFormat @"jpg"
#define imageSizeParam @"imgsz"
#define imageSize @"large"   // icon / small / medium / large / xlarge / icon / xxlarge / huge
#define pageIndexParam @"start"
#define resultsPerPageParam @"rsz"
#define resultsPerPage @"8"

// Results
#define imageHeading @"contentNoFormatting"
#define width @"width"
#define height @"height"

#define thumbURL @"tbUrl"
#define thumbWidth @"tbWidth"
#define thumbHeight @"tbHeight"

#define imageSrcPageURL @"originalContextUrl"
#define imageUnescapedURL @"unescapedUrl"
#define imageURL @"url"

@interface GoogleImageAPI ()
- (NSURL *)constructGImgsURLWithParameters:(NSDictionary *)parameters;
@end

@implementation GoogleImageAPI

- (NSArray *)imagesWithQueryString:(NSString *)queryString
{
    // Query Parameters
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                queryString, queryParam,
                                protocolVersion, protocolVersionParam,
                                resultsPerPage, resultsPerPageParam,
                                imageSize, imageSizeParam,
                                fileFormat, fileFormatParam,
                                nil];

    // Construct Google images API call 
    NSURL *url = [self constructGImgsURLWithParameters:parameters];
    
    // Get Json from API
    NSDictionary *json = [self getGImgsJsonFromURL:url];
    
    // If nothing received from Google Image API
    if(json == nil) return nil;
    
    // Response data
    NSDictionary *responseData = [json objectForKey:@"responseData"];
    
    // Grab images from Response : First page images
    NSMutableArray *images = [responseData objectForKey:@"results"];
    
    // Get cursor->pages->page->start
    NSDictionary *cursor = [responseData objectForKey:@"cursor"];
    NSArray *pages = [cursor objectForKey:@"pages"];
    for (NSDictionary *page in pages) {
        NSString *pageStartIndex = [page objectForKey:@"start"];
        
        // First page is received, go ahead and request rest of n-1 pages
        if([pageStartIndex isEqualToString:@"0"]) continue;
        
        // Query Parameters
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    queryString, queryParam,
                                    protocolVersion, protocolVersionParam,
                                    resultsPerPage, resultsPerPageParam,
                                    imageSize, imageSizeParam,
                                    fileFormat, fileFormatParam,
                                    pageStartIndex, pageIndexParam,
                                    nil];
        
        // Construct Google images API call
        url = [self constructGImgsURLWithParameters:parameters];
        
        // Get Json from API
        json = [self getGImgsJsonFromURL:url];
        
        // If nothing received from Google Image API
        if(json == nil) continue;
        
        // Response data
        responseData = [json objectForKey:@"responseData"];
        
        [images addObjectsFromArray:[responseData objectForKey:@"results"]];
    }
    
    NSArray *imageGallery = [[images copy] autorelease];
    
    return imageGallery;
}

- (NSDictionary*)getGImgsJsonFromURL:(NSURL*)url
{
    // Fetch response for the API call
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Response Data to string
    NSString *string = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    // Response String to JSON
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:string];
    [parser release];
    
    // Check response status
    NSNumber *responseStatus = [json objectForKey:@"responseStatus"];
    if([responseStatus.stringValue isEqualToString:@"200"]) {
        return json;
    }

    // return nil if response was unsuccessful
    return nil;
}

- (NSURL *)constructGImgsURLWithParameters:(NSDictionary *)parameters
{
    NSMutableString *URLString = [[NSMutableString alloc] initWithString:googleImagesBaseURL];
    for (id key in parameters) {
        NSString *value = [parameters objectForKey:key];
        [URLString appendFormat:@"%@=%@&", key, [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    NSURL *URL = [NSURL URLWithString:URLString];
    
    return URL;
}

@end
