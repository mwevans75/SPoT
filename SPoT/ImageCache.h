//
//  ImageCache.h
//  SPoT
//
//  Created by Matthew Evans on 3/23/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject
+ (NSData *)imageFromURL:(NSURL *)url;
+ (void)storeImage:(NSData *)imageData forURL:(NSURL *)imageURL;
+ (void)clearImageCache;
@end
