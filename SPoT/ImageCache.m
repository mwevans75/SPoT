//
//  ImageCache.m
//  SPoT
//
//  Created by Matthew Evans on 3/23/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import "ImageCache.h"
#import "NetworkIndicatorHelper.h"

@implementation ImageCache

#define CACHE_SIZE_IPHONE 3000000
#define CACHE_SIZE_IPAD 12000000

#define NAME_KEY @"name"
#define DATE_KEY @"date"
#define BYTES_KEY @"bytes"
#define URL_KEY @"url"
#define SUM_OF_BYTES_KEY @"@sum.bytes"

// returns the maximum size in bytes for the cache
+ (NSUInteger)maximumCacheSize
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? CACHE_SIZE_IPAD : CACHE_SIZE_IPHONE;
}

+ (NSData *)imageFromURL:(NSURL *)url
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSURL *file = [self localURLForFile:url];
    NSData *imageData;
    // if the file exists in cache directory then:
    // fetch the image from the local file
    // else fetch the image from Flickr
    if ([fm fileExistsAtPath:[file path]]) {
        // fetch the image from the local file
        NSLog(@"Getting Image from Cache");
        imageData = [[NSData alloc] initWithContentsOfURL:file];
    } else {
        // fetch the image from Flickr
        NSLog(@"Getting Image from Flickr");
        [NSThread sleepForTimeInterval:2.0]; // to test delay, eliminate in production environment
        [NetworkIndicatorHelper setNetworkActivityIndicatorVisible:YES];
        imageData = [[NSData alloc] initWithContentsOfURL:url];
        [NetworkIndicatorHelper setNetworkActivityIndicatorVisible:NO];
        
    }
    return imageData;
}


+ (void)storeImage:(NSData *)imageData forURL:(NSURL *)imageURL
{
    
    // if imageURL is not a file url it means it is not in the cache
    if (![imageURL isFileURL]) {
        NSLog(@" ");
        NSLog(@"Storing Image to Cache");
        
        NSLog(@"Old Image Cache Size: %d", [[self imageCacheSize] integerValue]);
        NSURL *file = [self localURLForFile:imageURL]; // create the local name for the file
        [self makeRoomInCacheForData:imageData]; // verify that the cache does not exceed maximum size
        [imageData writeToURL:file atomically:YES]; // write image to a file
        
        NSLog(@"New Image Cache Size: %d", [[self imageCacheSize] integerValue]);
    } else {
        NSLog(@"Image URL is a File URL");
    }
    
    [self logCacheContents];
}

// returns the local file url for the image to store in the cache
+ (NSURL *)localURLForFile:(NSURL *)url
{
    // gets the filename from the url
    NSString *fileName = [url lastPathComponent];
    
    // creates the local url for the file
    NSURL *file = [[self URLForImagesDir] URLByAppendingPathComponent:fileName];
    return file;
}

// returns the local URL to access the Caches/Images dir and creates it if does not exist
+ (NSURL *)URLForImagesDir
{
    // contruct local path to images subdir in cache dir
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSURL *cachesDir = [fm URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *imagesDir = [cachesDir URLByAppendingPathComponent:@"Images"];
    // if the images directory does not exist we create it (lazy instantiation!?)
    if (![fm fileExistsAtPath:[imagesDir path]]) {
        [fm createDirectoryAtURL:imagesDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return imagesDir;
}

// deletes files in order to maintain cache size below CACHE_SIZE_IPAD or CACHE_SIZE_IPHONE
+(void) makeRoomInCacheForData:(NSData *)data
{
    NSUInteger imageSize = [data length]; // image size in bytes
    
    NSArray *files = [self filesInCache];
    // calculate the size of the cache by adding the sizes of the files
    
    NSUInteger cacheSizeBeforeAddingData = [[files valueForKeyPath:SUM_OF_BYTES_KEY] integerValue];
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    // iterate the list of files and erase files until the size of the cache is below the maximum permitted size
    for (NSUInteger i=0;(cacheSizeBeforeAddingData>[self maximumCacheSize]-imageSize);i++) {
        NSLog(@"Removing Image: %@", files[i][NAME_KEY]);
        [fm removeItemAtURL:files[i][URL_KEY] error:nil];
        cacheSizeBeforeAddingData-=[files[i][BYTES_KEY] integerValue];
    }
}

/*
 returns an array of all image files in the cache
 each element is a dictionary that represents the following file attributes
 DATE_KEY : the time at which the file was most recently accessed
 BYTES_KEY : the file’s size in bytes
 URL_KEY : the file's url
 */
+(NSArray *)filesInCache
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *attributes = @[NSURLNameKey,NSURLContentAccessDateKey,NSURLFileSizeKey]; // attributes to fetch from the file system
    // use an enumerator to iterate through the list of the files in the directory
    NSDirectoryEnumerator *de = [fm enumeratorAtURL:[self URLForImagesDir]
                         includingPropertiesForKeys:attributes
                                            options:NSDirectoryEnumerationSkipsHiddenFiles
                                       errorHandler:nil];
    NSMutableArray *files = [[NSMutableArray alloc] init]; // of NSDictionary
    
    // we iterate all the files in the Images subdirectory
    for (NSURL *url in de) {
        // for each file we get the values of the properties we want
        NSString *fileName;
        [url getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        NSDate *date;
        [url getResourceValue:&date forKey:NSURLContentAccessDateKey error:nil];
        NSNumber *bytes;
        [url getResourceValue:&bytes forKey:NSURLFileSizeKey error:nil];
        [files addObject:@{NAME_KEY:fileName, DATE_KEY:date,BYTES_KEY:bytes,URL_KEY:url}]; // we create the dictionary for the file and add it to the array
        
    }
    // we return the array of files sorted
    NSSortDescriptor *key = [[NSSortDescriptor alloc] initWithKey:DATE_KEY ascending:YES];
    return [files sortedArrayUsingDescriptors:@[key]]; //sorted by date
}

+ (void) clearImageCache
{
    // Create a local file manager instance
    NSFileManager *fm=[[NSFileManager alloc] init];
    NSLog(@"Image Cache Size: %d", [[self imageCacheSize] integerValue]);
    NSLog(@"Clearing Image Cache");
    [fm removeItemAtURL:[self URLForImagesDir] error:nil];
    NSLog(@"Clearing Image Cache Complete");
    NSLog(@"Image Cache Size: %d", [[self imageCacheSize] integerValue]);
}

+ (NSNumber *) imageCacheSize
{
    NSArray *files = [self filesInCache];
    return [files valueForKeyPath:SUM_OF_BYTES_KEY];
}

+ (void)logCacheContents
{
    NSArray *files = [self filesInCache];
    
    NSLog(@" ");
    NSLog(@"Current Image Cache %d",[files count]);
    NSLog(@"-------------------");
    
    for (NSUInteger i=0;i < [files count];i++) {
        NSLog(@"%@ - %@ - %@",files[i][URL_KEY], files[i][DATE_KEY], files[i][BYTES_KEY]);
    }
    
}

@end
