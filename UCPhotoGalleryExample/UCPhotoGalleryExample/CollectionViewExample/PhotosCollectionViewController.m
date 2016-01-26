//
//  PhotosCollectionViewController.m
//  UCPhotoGalleryExample
//
//  Created by Bryan Oltman on 11/26/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import "PhotoCell.h"
#import "AppDelegate.h"
@import UCPhotoGallery;

@interface PhotosCollectionViewController () <UCGalleryViewDataSource, UCGalleryViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate>
@property (nonatomic) UCPhotoGalleryFullscreenTransitionController *transitionController;
@property (nonatomic) CGRect selectedPhotoRect;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) UCPhotoGalleryViewController *fullscreenGalleryController;
@property (nonatomic) SDImageCache *imageCache;
@end

@implementation PhotosCollectionViewController

- (NSArray *)photoURLs {
    return [((AppDelegate *)[[UIApplication sharedApplication] delegate]) photoURLs];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageCache = [[SDImageCache alloc] initWithNamespace:@"UCPhotoGallery"];
        self.tabBarItem.title = @"Transition";
        self.selectedIndex = NSNotFound;
        self.transitionController = [UCPhotoGalleryFullscreenTransitionController new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

// Handle rotation
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
    [self.imageCache queryDiskCacheForKey:url.absoluteString
                                     done:^(UIImage *image, SDImageCacheType cacheType) {
                                         if (image) {
                                             cell.photoImageView.image = image;
                                         } else {
                                             [cell.photoImageView sd_setImageWithURL:url
                                                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                                               [self.imageCache storeImage:image forKey:url.absoluteString];
                                                                               cell.photoImageView.image = image;
                                                                           }];
                                         }
                                     }];
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
        gallery.imageCache = self.imageCache;
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

- (void)galleryViewControllerDidDismiss:(UCPhotoGalleryViewController *)galleryViewController {
    self.selectedCell.alpha = 1;
    self.selectedIndex = NSNotFound;
    self.fullscreenGalleryController = nil;
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