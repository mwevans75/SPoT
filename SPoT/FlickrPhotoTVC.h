//
//  FlickrPhotoTVC.h
//  Shutterbug
//
//  Created by Matthew Evans on 3/3/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPhotoTVC : UITableViewController

@property (nonatomic, strong) NSArray *photos; // of Dictionary
@property (nonatomic) BOOL storeRecent;

@end
