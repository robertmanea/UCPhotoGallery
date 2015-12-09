//
//  ViewController.m
//  UCPhotoGalleryExample
//
//  Created by Bryan Oltman on 11/3/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import "GalleryContainerViewController.h"
#import "AppDelegate.h"

@import UCPhotoGallery;

@interface GalleryContainerViewController () <UCGalleryViewDataSource, UCGalleryViewDelegate>
@property UCPhotoGalleryViewController *galleryVC;
@property NSMutableArray *inactiveURLs;

@property UILabel *pageLabel;
@end

@implementation GalleryContainerViewController

- (NSArray *)photoURLs {
    return [((AppDelegate *)[[UIApplication sharedApplication] delegate]) photoURLs];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tabBarItem.title = @"Embedded";

    self.view.backgroundColor = [UIColor whiteColor];

    self.galleryVC = ({
        CGRect galleryFrame = self.view.bounds;
        galleryFrame.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height +
            self.navigationController.navigationBar.bounds.size.height;
        galleryFrame.size.height = self.view.bounds.size.height - 350;
        galleryFrame.size.height = 300;
        UCPhotoGalleryViewController *gallery = [UCPhotoGalleryViewController new];
        gallery.imageScalingMode = UCImageScalingModeFill;
        gallery.dataSource = self;
        gallery.delegate = self;
        gallery.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        gallery.view.frame = galleryFrame;
        gallery;
    });

    [self addChildViewController:self.galleryVC];
    [self.view addSubview:self.galleryVC.view];
}

- (void)buttonPressed:(UIButton *)button {
    [self.galleryVC dismiss:YES];
}

#pragma mark - UCGalleryView
// data source
- (NSArray *)imageURLsForGalleryView:(UCPhotoGalleryViewController *)galleryViewController {
    return self.photoURLs;
}

// delegate
- (void)didPresentGalleryViewController:(UCPhotoGalleryViewController *)galleryViewController {
    self.pageLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 30, 100, 30)];
        label.text = [NSString stringWithFormat:@"%@/%@", @(galleryViewController.currentIndex + 1), @(self.photoURLs.count)];
        label.textColor = [UIColor whiteColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
        [galleryViewController.view addSubview:label];
        label;
    });
}

- (void)galleryViewController:(UCPhotoGalleryViewController *)galleryViewController
                  pageChanged:(NSUInteger)page {
    self.pageLabel.text = [NSString stringWithFormat:@"%@/%@", @(page + 1), @(self.photoURLs.count)];
}

- (void)galleryViewControllerCancelledDismiss:(UCPhotoGalleryViewController *)galleryViewController {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)galleryViewControllerWillDismiss:(UCPhotoGalleryViewController *)galleryViewController {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)galleryViewControllerDidDismiss:(UCPhotoGalleryViewController *)galleryViewController {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)galleryItemDidZoom:(UCPhotoGalleryItemView *)galleryItem {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end

