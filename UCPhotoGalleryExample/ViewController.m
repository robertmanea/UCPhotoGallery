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
#import <UCDirectionalPanGestureRecognizer/UCDirectionalPanGestureRecognizer.h>

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
                   [NSURL URLWithString:@"http://urbancompass-development.s3.amazonaws.com/image-indexer/61e3f3c76dcf978e6b30983c84430fc1f5cb9d3d.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/fcbc833287a61e6b4f0c053b2e5db8361e0b54a4.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/32005d9cb6ca67c626cfd31bae50d963312e23ae.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/3d55c227a60f557268ce7b92d8db71e6c0b9f162.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/5651d1cfa1a047a5488bd9af473d4e616a0417b7.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/208e2e0c820e2c6801fe0237c1f1f820037e96f0.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/569e0e23b936040a70f426cee7bf30d5e143a14b.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/b19d4d17c384b17fd14339003b4ada34507b0195.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/7e2cc65c7ddd5be0e61dcaeff92c3faabbd55e61.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/070d6a6da536cdb67877f4b0d0f84262ec6ea502.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/99dd883e48fa04185e855bea96ad95e22a0a107f.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/94366a9903f544cdd793b63356cbe95f36e080e3.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/04f34be1f05f7b0548bf2e60c8ac87e5497a8dae.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/3c3ef71d6b45613f4f09cb83cb246955961da682.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/f40e62e9ac8e5a856b946c9fa085b81d41250f74.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/5fcd2f9a1a44769da5cf35f9bfa10b161a35b545.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/967885750d974be926d366fb21d29339297aaaf6.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/58b9212d39164815a40ae1c899e55a0e1b78ae3a.jpg"]
                   ];
    }

    return photos;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.galleryVC = ({
        CGRect galleryFrame = self.view.bounds ;
        galleryFrame.origin.y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        galleryFrame.size.height = 350;
        UCPhotoGalleryViewController *gallery = [UCPhotoGalleryViewController new];
        gallery.dataSource = self;
        gallery.delegate = self;
        gallery.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        gallery.view.frame = galleryFrame;
        [self addChildViewController:gallery];
        [self.view addSubview:gallery.view];
        gallery;
    });

    self.photosVC = ({
        UCPhotosViewController *vc = [UCPhotosViewController new];
        CGRect frame = self.view.bounds;
//        frame.size.width = 175;
//        frame.origin.x = 100;
//        frame.origin.y = 64;
        vc.view.frame = frame;
        vc.dataSource = self;
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        vc.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        vc;
    });

    self.galleryVC.view.hidden = YES;
//    self.photosVC.view.hidden = YES;
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
