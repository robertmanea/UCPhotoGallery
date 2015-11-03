//
//  ViewController.m
//  UCPhotoGalleryExample
//
//  Created by Bryan Oltman on 11/3/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import "ViewController.h"

#import "UCPhotoGalleryViewController.h"
#import "UCPhotosViewController.h"

@interface ViewController () <UCGalleryViewDataSource, UCGalleryViewDelegate>
@property UCPhotoGalleryViewController *galleryVC;
@property UCPhotosViewController *photosVC;
@property NSMutableArray *inactiveURLs;
@end

@implementation ViewController

- (NSArray *)photoURLs {
    static NSArray *photos = nil;
    if (!photos) {
        photos = @[
                   [NSURL URLWithString:@"http://urbancompass-development.s3.amazonaws.com/image-indexer/a19a2d0c45485261b572b615ef7e00c7e2cce488.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-development.s3.amazonaws.com/image-indexer/7a4da9255bda9d69cb18233e9a1188a8a3b213e2.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-development.s3.amazonaws.com/image-indexer/9ce5239218f928ce746d8230794ee6d2688d8a7b.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-development.s3.amazonaws.com/image-indexer/81ed2ae54e3ccd7cc2d4ea506e639283455dfb60.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-development.s3.amazonaws.com/image-indexer/61e3f3c76dcf978e6b30983c84430fc1f5cb9d3d.jpg"]
                   ];
    }

    return photos;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

//    self.galleryVC = ({
//        CGRect galleryFrame = self.view.bounds ;
//        galleryFrame.origin.y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
//        galleryFrame.size.height = 350;
//        UCPhotoGalleryViewController *gallery = [UCPhotoGalleryViewController new];
//        gallery.dataSource = self;
//        gallery.delegate = self;
//        gallery.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        gallery.view.frame = galleryFrame;
//        [self addChildViewController:gallery];
//        [self.view addSubview:gallery.view];
//        gallery;
//    });

        self.photosVC = ({
            UCPhotosViewController *vc = [UCPhotosViewController new];
            vc.view.frame = self.view.bounds;
            vc.dataSource = self;
            vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            [self addChildViewController:vc];
            [self.view addSubview:vc.view];
            vc;
        });
}

#pragma mark - UCGalleryView
// data source
- (NSArray *)imageURLsForGalleryView:(UCPhotoGalleryViewController *)galleryViewController {
    return self.photoURLs;
}

// delegate
- (void)galleryView:(UCPhotoGalleryViewController *)galleryViewController
        pageChanged:(NSUInteger)page {
    NSLog(@"gallery view page changed to %@", @(page));
}

@end
