//
//  FlickrRecentPhotoTVC.m
//  SPoT
//
//  Created by Matthew Evans on 3/6/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import "FlickrRecentPhotoTVC.h"
#import "FlickrPhotoRecents.h"

@interface FlickrRecentPhotoTVC ()

@end

@implementation FlickrRecentPhotoTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.storeRecent = NO;
    [self setTitle:@"Recent Photos"];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.photos = [FlickrPhotoRecents allRecentPhotos];
}

- (IBAction)clearRecents:(id)sender {
    [FlickrPhotoRecents resetRecentPhotos];
    self.photos = [FlickrPhotoRecents allRecentPhotos];
}

@end
