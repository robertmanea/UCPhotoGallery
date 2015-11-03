#import "UCPhotosViewController.h"
#import "UCPhotoCell.h"
#import "UCPhotoGalleryFullscreenTransitionController.h"
#import <UIImageView+WebCache.h>

@interface UCPhotosViewController () <UCGalleryViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, UCPhotoCellDelegate>
@property (nonatomic) UCPhotoGalleryFullscreenTransitionController *transitionController;
@property (nonatomic) NSArray *urls;
@property (nonatomic) CGRect selectedPhotoRect;
@property (nonatomic) UCPhotoCell *selectedCell;
@property (nonatomic) NSCache *heightCache;
@end

@implementation UCPhotosViewController

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.heightCache = [NSCache new];
        self.transitionController = [UCPhotoGalleryFullscreenTransitionController new];
    }

    return self;
}

- (void)setDataSource:(NSObject<UCGalleryViewDataSource> *)dataSource {
    _dataSource = dataSource;
    self.urls = [dataSource imageURLsForGalleryView:nil];
    [self.collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[UCPhotoCell class]
            forCellWithReuseIdentifier:[UCPhotoCell reuseIdentifier]];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection
                 withTransitionCoordinator:coordinator];

    [self.heightCache removeAllObjects];
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.transitionController.presentFromRect = [self.view convertRect:self.selectedCell.imageFrame
                                                              fromView:self.selectedCell.contentView];
    self.transitionController.transitionImage = self.selectedCell.image;
}

#pragma mark - UICollectionView
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UCPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[UCPhotoCell reuseIdentifier]
                                                                  forIndexPath:indexPath];
    cell.delegate = self;
    cell.url = self.urls[indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.urls.count;
}

- (CGFloat)cachedHeightForImageAtURL:(NSURL *)url {
    NSNumber *heightNumber = [self.heightCache objectForKey:url.absoluteString];
    if (heightNumber) {
        return heightNumber.doubleValue;
    }

    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UCPhotoCell *cell = (UCPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    CGSize ret = CGSizeMake(collectionView.bounds.size.width, 250);
    NSURL *url = self.urls[indexPath.row];
    CGFloat cachedHeight = [self cachedHeightForImageAtURL:url];
    if (cachedHeight) {
        ret.height = cachedHeight;
    } else if (cell.image) {
        CGSize imageSize = cell.image.size;
        CGFloat aspectRatio = imageSize.width / imageSize.height;
        ret.height = ret.width / aspectRatio;
        [self.heightCache setObject:@(ret.height)
                             forKey:url.absoluteString];
    }

    return ret;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedCell = (UCPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIViewController *container = self.parentViewController;
    self.transitionController.presentFromRect = [container.view convertRect:[self.selectedCell imageFrame]
                                                                   fromView:self.selectedCell.contentView];
    self.transitionController.transitionImage = self.selectedCell.image;
    UCPhotoGalleryViewController *galleryVC = ({
        UCPhotoGalleryViewController *presentVC = [UCPhotoGalleryViewController new];
        presentVC.dataSource = self.dataSource;
        presentVC.delegate = self;
        presentVC.view.frame = container.view.bounds;
        presentVC.isFullscreen = YES;
        presentVC.currentIndex = indexPath.row;
        presentVC.transitioningDelegate = self;
        presentVC.modalPresentationStyle = UIModalPresentationCustom;
        presentVC;
    });

    [container presentViewController:galleryVC
                            animated:YES
                          completion:nil];

    // Give the animation a little time to begin to avoid the image briefly disappearing
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.selectedCell.alpha = 0;
    });
}

#pragma mark - UCPhotoCellDelegate
- (void)imageLoadedForPhotoCell:(UCPhotoCell *)cell {
    // If an image loads and the host cell is improperly sized, update the collection view's layout
    if ([self cachedHeightForImageAtURL:cell.url] != cell.bounds.size.height) {
        [UIView animateWithDuration:0.1 animations:^{
            [self.collectionView.collectionViewLayout invalidateLayout];
        }];
    }
}

#pragma mark - UCGalleryDelegate
- (void)dismissFullscreenGalleryController:(UCPhotoGalleryViewController *)galleryViewController {
    [galleryViewController dismissViewControllerAnimated:YES completion:^{
        self.selectedCell.alpha = 1;
        self.selectedCell = nil;
    }];
}

- (void)galleryView:(UCPhotoGalleryViewController *)galleryViewController
        pageChanged:(NSUInteger)page {
    // Keep the collection view in sync with the full-screen gallery view
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:page inSection:0];
    self.selectedCell.alpha = 1;
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];

    // Give the collection view time to scroll
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.selectedCell = (UCPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        self.selectedCell.alpha = 0;
        self.transitionController.presentFromRect = [self.view convertRect:self.selectedCell.imageFrame
                                                                  fromView:self.selectedCell.contentView];
        self.transitionController.transitionImage = self.selectedCell.image;
    });
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
