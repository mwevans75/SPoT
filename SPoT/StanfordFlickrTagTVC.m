//
//  StanfordFlickrTagTVC.m
//  SPoT
//
//  Created by Matthew Evans on 3/5/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import "StanfordFlickrTagTVC.h"
#import "FlickrFetcher.h"

@interface StanfordFlickrTagTVC ()

@end

@implementation StanfordFlickrTagTVC

#define IGNORED_TAGS @[@"cs193pspot",@"portrait",@"landscape"]

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.ignoredTags = IGNORED_TAGS;
    self.photos = [FlickrFetcher stanfordPhotos];
    self.tags = [self parseTags:self.photos];
    
}

@end
