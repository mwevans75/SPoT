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
#define MAX_RECENT_PHOTOS 10

+ (void)addPhotoToUserDefaults: (NSDictionary *) recentPhoto
{
    NSString *recentPhotoID = recentPhoto[FLICKR_PHOTO_ID];
    NSDate *dateAdded = [NSDate date];
    BOOL addPhoto = YES;
    
    NSMutableDictionary *mutableRecentPhotosFromUserDefaults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_RESULTS_KEY] mutableCopy];
    
    if (!mutableRecentPhotosFromUserDefaults) {
        mutableRecentPhotosFromUserDefaults = [[NSMutableDictionary alloc] init];
    }
    
    // Set Enumerator for the Keys in the Dictionary
    NSEnumerator *enumerator = [mutableRecentPhotosFromUserDefaults keyEnumerator];
    id key;
    
    // Check for a Duplicate Key to the One Being Added
    NSString *keyToBeReplaced;
    while ((key = [enumerator nextObject])) {
        if ([[mutableRecentPhotosFromUserDefaults objectForKey:key][FLICKR_PHOTO_ID] isEqualToString:recentPhotoID]) {
            addPhoto = NO;
            keyToBeReplaced = key;
            break;
        }
    }
    
    if (addPhoto) {
        [mutableRecentPhotosFromUserDefaults setObject:recentPhoto forKey:[dateAdded description]];
    } else {
        // Replace Existing Photo with New One So that It Moves to Top of List
        [mutableRecentPhotosFromUserDefaults removeObjectForKey:keyToBeReplaced];
        [mutableRecentPhotosFromUserDefaults setObject:recentPhoto forKey:[dateAdded description]];
    }
    
    // Ensure Recents List Size is Not Too Big
    enumerator = [mutableRecentPhotosFromUserDefaults keyEnumerator];
    if ([mutableRecentPhotosFromUserDefaults count] > MAX_RECENT_PHOTOS) {
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        int keyCountToDelete = [mutableRecentPhotosFromUserDefaults count] - MAX_RECENT_PHOTOS;

        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        while ((key = [enumerator nextObject])) {
            
            [keys addObject:[dateFormat dateFromString:key]];
        }
        
        NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
        for (int i = 0; i<=keyCountToDelete-1; i++) {
            [mutableRecentPhotosFromUserDefaults removeObjectForKey:[sortedKeys[i] description]];
        }
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
    NSMutableArray *sortedValues = [[NSMutableArray alloc] init];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_RESULTS_KEY];
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    for (NSString *key in [sortedKeys reverseObjectEnumerator]){
        [sortedValues addObject: [dict objectForKey: key]];
    }
    
    return sortedValues;
}

@end
