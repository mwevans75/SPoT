//
//  FlickrTagTVC.h
//  SPoT
//
//  Created by Matthew Evans on 3/5/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrTagTVC : UITableViewController

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSArray *ignoredTags;

-(NSArray *) parseTags:(NSArray *)photos;

@end
