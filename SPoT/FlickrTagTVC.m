//
//  FlickrTagTVC.m
//  SPoT
//
//  Created by Matthew Evans on 3/5/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import "FlickrTagTVC.h"
#import "FlickrFetcher.h"

@interface FlickrTagTVC ()

@end

@implementation FlickrTagTVC

#define TAG_DESCRIPTION @"Tag_Desc"
#define TAG_INDEXES_OF_PHOTOS @"Tag_Indexes_Of_Photos"

- (void)setTags:(NSArray *)tags
{
    _tags = tags;
    [self.tableView reloadData];
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
}

-(NSArray *) parseTags:(NSArray *)photos
{
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    NSLog(@"Beginning Parsing Tags");
    
    // Look at each photo
    for (NSDictionary *photo in self.photos) {
        // Look at each tag on each photo
        for (NSString *tag in [photo[FLICKR_TAGS] componentsSeparatedByString:@" "]) {
            // Only proceed if the tag isn't a tag we're ignoring
            if (![self.ignoredTags containsObject:tag]) {
                BOOL existingTagFound = NO;
                // Check if the current tag already exists in our list of tags
                for (NSMutableDictionary *existingTag in tags) {
                    if ([tag isEqualToString:existingTag[TAG_DESCRIPTION]]) { // If tag already exists, add index of photo to existing array of photo indexes
                        existingTagFound = YES;
                        [existingTag[TAG_INDEXES_OF_PHOTOS] addObject:@([self.photos indexOfObject:photo])];
                        break;
                    }
                }
                if (!existingTagFound) { // If tag was not found in existing tags, add new tag and create mutable array containing index of photo as NSNumber
                    NSMutableArray *indexesOfPhotosWithTag = [[NSMutableArray alloc] initWithArray:@[@([self.photos indexOfObject:photo])]];
                    [tags addObject:[@{ TAG_DESCRIPTION : tag, TAG_INDEXES_OF_PHOTOS : indexesOfPhotosWithTag } mutableCopy]];
                }
            }
        }
    }
    
    NSLog(@"Parsing Tags Complete");
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:TAG_DESCRIPTION ascending:YES];
    
    return [tags sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}


#pragma mark - Table view data source

- (NSString *)titleForRow:(NSUInteger)row
{
    return [self.tags[row][TAG_DESCRIPTION] capitalizedString];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Tag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    int tagCount = [self.tags[indexPath.row][TAG_INDEXES_OF_PHOTOS] count];
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo%@", tagCount, (tagCount == 1) ? @"" : @"s"];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Tag Details"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    NSArray *photoArray = [self arrayOfPhotosWithTag:[self titleForRow:indexPath.row]];                    
                    [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:photoArray];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                }
            }
        }
    }
}

- (NSArray *)arrayOfPhotosWithTag:(NSString *)tag
{
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
    
    // Look at each photo
    for (NSDictionary *photo in self.photos) {
        if ([[photo[FLICKR_TAGS] componentsSeparatedByString:@" "] containsObject:[tag lowercaseString]]) {
            [photoArray addObject:photo];
        }
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:FLICKR_PHOTO_TITLE ascending:YES];
    
    return [photoArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}

@end
