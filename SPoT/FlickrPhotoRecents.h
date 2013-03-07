//
//  FlickrPhotoRecents.h
//  SPoT
//
//  Created by Matthew Evans on 3/6/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrPhotoRecents : NSObject

+ (NSArray *)allRecentPhotos; //of Photo

+ (void)resetRecentPhotos;

+ (void)addPhotoToUserDefaults: (NSDictionary *) recentPhoto;

@end
