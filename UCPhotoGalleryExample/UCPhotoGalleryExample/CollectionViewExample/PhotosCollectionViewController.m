//
//  PhotosCollectionViewController.m
//  UCPhotoGalleryExample
//
//  Created by Bryan Oltman on 11/26/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import "PhotoCell.h"
@import UCPhotoGallery;

@interface PhotosCollectionViewController () <UCGalleryViewDataSource, UCGalleryViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate>
@property (nonatomic) UCPhotoGalleryFullscreenTransitionController *transitionController;
@property (nonatomic) CGRect selectedPhotoRect;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) UCPhotoGalleryViewController *fullscreenGalleryController;
@end

@implementation PhotosCollectionViewController

- (NSArray *)photoURLs {
    static NSArray *photos = nil;
    if (!photos) {
        photos = @[
                   [NSURL URLWithString:@"http://urbancompass-development.s3.amazonaws.com/image-indexer/a19a2d0c45485261b572b615ef7e00c7e2cce488.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-development.s3.amazonaws.com/image-indexer/7a4da9255bda9d69cb18233e9a1188a8a3b213e2.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-development.s3.amazonaws.com/image-indexer/9ce5239218f928ce746d8230794ee6d2688d8a7b.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-development.s3.amazonaws.com/image-indexer/81ed2ae54e3ccd7cc2d4ea506e639283455dfb60.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-development.s3.amazonaws.com/image-indexer/61e3f3c76dcf978e6b30983c84430fc1f5cb9d3d.jpg"],
                   [NSURL URLWithString:@"http://urbancompass-image-index.s3.amazonaws.com/5a39676e268b8fc7edd0a9273f2c5ef01d6c0632.jpg"],
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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedIndex = NSNotFound;
        self.transitionController = [UCPhotoGalleryFullscreenTransitionController new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.transitioningDelegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateTransitionControllerWithSelectedView];
}

- (void)updateTransitionControllerWithSelectedView {
    PhotoCell *selectedCell = [self selectedCell];
    if (selectedCell) {
        UIViewController *container = self.parentViewController;
        self.transitionController.presentFromRect = [container.view convertRect:selectedCell.bounds
                                                                       fromView:selectedCell.contentView];
        self.transitionController.transitionImage = selectedCell.image;
        selectedCell.alpha = 0;
    }
}

- (PhotoCell *)selectedCell {
    if (self.selectedIndex != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)self.selectedIndex inSection:0];
        return (PhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }

    return nil;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection
                 withTransitionCoordinator:coordinator];

    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - UICollectionView
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PhotoCell reuseIdentifier]
                                                                forIndexPath:indexPath];
    NSURL *url = self.photoURLs[(NSUInteger)indexPath.row];
    cell.alpha = (self.selectedIndex == (NSUInteger)indexPath.row) ? 0 : 1;
    [cell.photoImageView sd_setImageWithURL:url];
    return cell;
}

- (NSInteger)collectionView:(__unused UICollectionView *)collectionView
     numberOfItemsInSection:(__unused NSInteger)section {
    return (NSInteger)self.photoURLs.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(__unused UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, 250);
}

- (void)collectionView:(__unused UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = (NSUInteger)indexPath.row;
    UCPhotoGalleryViewController *galleryVC = ({
        UCPhotoGalleryViewController *gallery = [UCPhotoGalleryViewController new];
        gallery.dataSource = self;
        gallery.isFullscreen = YES;
        gallery.view.frame = [[[UIApplication sharedApplication] delegate] window].bounds;
        gallery.currentIndex = (NSUInteger)indexPath.row;
        gallery.transitioningDelegate = self;
        gallery.modalPresentationStyle = UIModalPresentationCustom;
        gallery;
    });

    [self updateTransitionControllerWithSelectedView];

    [self presentViewController:galleryVC
                       animated:YES
                     completion:^{
                         galleryVC.delegate = self;
                     }];

    // Give the animation a little time to begin to avoid the image briefly disappearing
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.selectedCell.alpha = 0;
    });
}

- (NSArray *)imageURLsForGalleryView:(UCPhotoGalleryViewController *)galleryViewController {
    return self.photoURLs;
}

#pragma mark - UCGalleryDelegate
- (void)galleryViewController:(UCPhotoGalleryViewController *)galleryViewController
                  pageChanged:(NSUInteger)page {
    PhotoCell *previouslySelectedCell = [self selectedCell];
    previouslySelectedCell.alpha = 1;

    // Keep the collection view in sync with the full-screen gallery view
    self.selectedIndex = page;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)page inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
    [self updateTransitionControllerWithSelectedView];
}

- (void)galleryViewControllerWillDismiss:(UCPhotoGalleryViewController *)galleryViewController {
    // TODO
}

- (void)galleryViewControllerCancelledDismiss:(UCPhotoGalleryViewController *)galleryViewController {
    // TODO
}

- (void)galleryViewControllerDidDismiss:(UCPhotoGalleryViewController *)galleryViewController {
    self.selectedCell.alpha = 1;
    self.selectedIndex = NSNotFound;
    self.fullscreenGalleryController = nil;
}

- (void)galleryItemDidZoom:(UCPhotoGalleryItemView *)galleryItem {
    // TODO
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(__unused UIViewController *)presented
                                                                   presentingController:(__unused UIViewController *)presenting
                                                                       sourceController:(__unused UIViewController *)source {
    return self.transitionController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(__unused UIViewController *)dismissed
{
    return self.transitionController;
}

@end