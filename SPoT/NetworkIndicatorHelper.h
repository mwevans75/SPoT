//
//  NetworkIndicatorHelper.h
//  SPoT
//
//  Created by Matthew Evans on 3/20/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkIndicatorHelper : NSObject

+ (void) setNetworkActivityIndicatorVisible:(BOOL) visible;
+ (BOOL) networkActivityIndicatorVisible;

@end
