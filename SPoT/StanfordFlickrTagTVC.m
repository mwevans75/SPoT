//
//  StanfordFlickrTagTVC.m
//  SPoT
//
//  Created by Matthew Evans on 3/5/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import "StanfordFlickrTagTVC.h"
#import "FlickrFetcher.h"
#import "NetworkIndicatorHelper.h"

@interface StanfordFlickrTagTVC ()

@end

@implementation StanfordFlickrTagTVC

#define IGNORED_TAGS @[@"cs193pspot",@"portrait",@"landscape"]

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ignoredTags = IGNORED_TAGS;
    [self loadStanfordPhotosFromFlickr];
	
    [self.refreshControl addTarget:self
                            action:@selector(loadStanfordPhotosFromFlickr)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)loadStanfordPhotosFromFlickr
{
    [self.refreshControl beginRefreshing];
    
    dispatch_queue_t loaderQ = dispatch_queue_create("flickr stanford photo loader", NULL);
    dispatch_async(loaderQ, ^{
        [NetworkIndicatorHelper setNetworkActivityIndicatorVisible:YES];
        NSArray *stanfordPhotos = [FlickrFetcher stanfordPhotos];
        [NetworkIndicatorHelper setNetworkActivityIndicatorVisible:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = stanfordPhotos;
            self.tags = [self parseTags:self.photos];
            [self.refreshControl endRefreshing];
        });
    });
}

@end
