//
//  FlickrPhotoRecents.m
//  SPoT
//
//  Created by Matthew Evans on 3/6/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import "FlickrPhotoRecents.h"
#import "FlickrFetcher.h"

@implementation FlickrPhotoRecents

#define ALL_RESULTS_KEY @"RecentPhotos_ALL"
#define PHOTO_KEY @"Photo"
#define DATE_ADDED_KEY @"DateAdded"
#define MAX_RECENT_PHOTOS 5

+ (void)addPhotoToUserDefaults: (NSDictionary *) recentPhoto
{
    NSString *recentPhotoID = recentPhoto[FLICKR_PHOTO_ID];
    NSDate *dateAdded = [NSDate date];
    
    NSMutableDictionary *mutableRecentPhotosFromUserDefaults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_RESULTS_KEY] mutableCopy];
    
    if (!mutableRecentPhotosFromUserDefaults) {
        mutableRecentPhotosFromUserDefaults = [[NSMutableDictionary alloc] init];
    }
    
    if ([mutableRecentPhotosFromUserDefaults count] >= MAX_RECENT_PHOTOS) {
        NSLog(@"TOO MANY ENTRIES");
    }
    
    if (![mutableRecentPhotosFromUserDefaults objectForKey:recentPhotoID]) {
        [mutableRecentPhotosFromUserDefaults setObject:@{ PHOTO_KEY : recentPhoto, DATE_ADDED_KEY : dateAdded} forKey:recentPhotoID];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mutableRecentPhotosFromUserDefaults forKey:ALL_RESULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

+ (void)resetRecentPhotos
{
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs removeObjectForKey:ALL_RESULTS_KEY];
    [defs synchronize];
}

+ (NSArray *)allRecentPhotos
{
    NSMutableArray *allRecentPhotos = [[NSMutableArray alloc] init];
    
    for (id plist in [[[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_RESULTS_KEY] allValues]) {
        [allRecentPhotos addObject:plist[PHOTO_KEY]];
    }
    
    return allRecentPhotos;
}

@end
