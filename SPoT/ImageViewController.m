//
//  ImageViewController.m
//  Shutterbug
//
//  Created by Matthew Evans on 3/3/13.
//  Copyright (c) 2013 Matt's Apps. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic) BOOL userDidZoom; // Tracks if the user has manually zoomed the image
@end

@implementation ImageViewController

#define MINIMUM_ZOOM_SCALE 0.2
#define MAXIMUM_ZOOM_SCALE 5.0

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = MINIMUM_ZOOM_SCALE;
    self.scrollView.maximumZoomScale = MAXIMUM_ZOOM_SCALE;
    self.scrollView.delegate = self;
    [self resetImage];
}

// When subviews get laid out, try to autozoom.
- (void)viewDidLayoutSubviews
{
    [self autoZoom];
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    
    return _imageView;
}

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        self.userDidZoom = NO;
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        
        if (image) {
            self.scrollView.zoomScale = 1.0;
            self.scrollView.contentSize = image.size;
            self.imageView.image = image;
            self.imageView.frame = CGRectMake(0,0,image.size.width, image.size.height);
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.userDidZoom = YES;
}

// This function will automatically set the zoom to show as much of the image as possible without showing any empty space.
- (void)autoZoom
{
    if (self.imageView.image && !self.userDidZoom) { // If the imageView has an image set and the user hasn't manually zoomed yet, autozoom.
        CGFloat widthRatio  = self.scrollView.bounds.size.width  / self.imageView.bounds.size.width;
        CGFloat heightRatio = self.scrollView.bounds.size.height / self.imageView.bounds.size.height;
        self.scrollView.zoomScale = (widthRatio > heightRatio) ? widthRatio : heightRatio;
        self.userDidZoom = NO; // Setting the zoom on the previous line triggered scrollViewDidZoom, but since we know that we did the zooming we need to set the userDidZoom flag back to NO
    }
}


@end
