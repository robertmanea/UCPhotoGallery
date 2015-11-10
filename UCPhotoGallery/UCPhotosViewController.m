#import "UCPhotosViewController.h"
#import "UCPhotoCell.h"
#import "UCPhotoGalleryFullscreenTransitionController.h"

@interface UCPhotosViewController () <UCGalleryViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, UCPhotoCellDelegate>
@property (nonatomic) UCPhotoGalleryFullscreenTransitionController *transitionController;
@property (nonatomic) NSArray *urls;
@property (nonatomic) CGRect selectedPhotoRect;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) NSCache *heightCache;
@property (nonatomic) UCPhotoGalleryViewController *fullscreenGalleryController;
@end

@implementation UCPhotosViewController

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.heightCache = [NSCache new];
        self.selectedIndex = NSNotFound;
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
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UCPhotoCell class]
            forCellWithReuseIdentifier:[UCPhotoCell reuseIdentifier]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateTransitionControllerWithSelectedView];
}

- (void)updateTransitionControllerWithSelectedView {
    UCPhotoCell *selectedCell = [self selectedCell];
    if (selectedCell) {
        UIViewController *container = self.parentViewController;
        self.transitionController.presentFromRect = [container.view convertRect:[selectedCell imageFrame]
                                                                       fromView:selectedCell.contentView];
        self.transitionController.transitionImage = selectedCell.image;
        selectedCell.alpha = 0;
    }
}

- (UCPhotoCell *)selectedCell {
    if (self.selectedIndex != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)self.selectedIndex inSection:0];
        return (UCPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }

    return nil;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection
                 withTransitionCoordinator:coordinator];

    [self.heightCache removeAllObjects];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)dismiss:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(galleryViewControllerWillDismiss:)]) {
        [self.delegate galleryViewControllerWillDismiss:self.fullscreenGalleryController];
    }

    [self dismissViewControllerAnimated:animated completion:^{
        if ([self.delegate respondsToSelector:@selector(galleryViewControllerDidDismiss:)]) {
            [self.delegate galleryViewControllerDidDismiss:self.fullscreenGalleryController];
        }

        self.selectedCell.alpha = 1;
        self.selectedIndex = NSNotFound;
    }];
}

#pragma mark - UICollectionView
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UCPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[UCPhotoCell reuseIdentifier]
                                                                  forIndexPath:indexPath];
    cell.delegate = self;
    cell.url = self.urls[(NSUInteger)indexPath.row];
    cell.alpha = (self.selectedIndex == (NSUInteger)indexPath.row) ? 0 : 1;
    return cell;
}

- (NSInteger)collectionView:(__unused UICollectionView *)collectionView
     numberOfItemsInSection:(__unused NSInteger)section {
    return (NSInteger)self.urls.count;
}

- (CGFloat)cachedHeightForImageAtURL:(NSURL *)url {
    NSNumber *heightNumber = [self.heightCache objectForKey:url.absoluteString];
    if (heightNumber) {
        return heightNumber.floatValue;
    }

    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(__unused UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UCPhotoCell *cell = (UCPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    CGSize ret = CGSizeMake(collectionView.bounds.size.width, 250);
    NSURL *url = self.urls[(NSUInteger)indexPath.row];
    CGFloat cachedHeight = [self cachedHeightForImageAtURL:url];
    if (cachedHeight != 0) {
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

- (void)collectionView:(__unused UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = (NSUInteger)indexPath.row;
    UCPhotoGalleryViewController *galleryVC = ({
        UCPhotoGalleryViewController *gallery = [UCPhotoGalleryViewController new];
        gallery.dataSource = self.dataSource;
        gallery.isFullscreen = YES;
        gallery.view.frame = [[[UIApplication sharedApplication] delegate] window].bounds;
        gallery.currentIndex = (NSUInteger)indexPath.row;
        gallery.transitioningDelegate = self;
        gallery.modalPresentationStyle = UIModalPresentationCustom;
        gallery;
    });

    [self updateTransitionControllerWithSelectedView];

    if ([self.delegate respondsToSelector:@selector(willPresentGalleryViewController:)]) {
        [self.delegate willPresentGalleryViewController:galleryVC];
    }

    [self presentViewController:galleryVC
                            animated:YES
                          completion:^{
                              galleryVC.delegate = self;
                              if ([self.delegate respondsToSelector:@selector(didPresentGalleryViewController:)]) {
                                  [self.delegate didPresentGalleryViewController:galleryVC];
                              }
                          }];

    // Give the animation a little time to begin to avoid the image briefly disappearing
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.selectedCell.alpha = 0;
    });
}

#pragma mark - UCPhotoCellDelegate
- (void)imageLoadedForPhotoCell:(UCPhotoCell *)cell {
    // If an image loads and the host cell is improperly sized, update the collection view's layout
    if ([self cachedHeightForImageAtURL:cell.url] != cell.bounds.size.height) {
        // NOTE: This was previously animated, but the collection view is not interactive during the animations,
        // so non-animated it is
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}

#pragma mark - UCGalleryDelegate
- (void)galleryViewController:(UCPhotoGalleryViewController *)galleryViewController
        pageChanged:(NSUInteger)page {
    if ([self.delegate respondsToSelector:@selector(galleryViewController:pageChanged:)]) {
        [self.delegate galleryViewController:galleryViewController pageChanged:page];
    }

    UCPhotoCell *previouslySelectedCell = [self selectedCell];
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
    if ([self.delegate respondsToSelector:@selector(galleryViewControllerWillDismiss:)]) {
        [self.delegate galleryViewControllerWillDismiss:galleryViewController];
    }
}

- (void)galleryViewControllerCancelledDismiss:(UCPhotoGalleryViewController *)galleryViewController {
    if ([self.delegate respondsToSelector:@selector(galleryViewControllerCancelledDismiss:)]) {
        [self.delegate galleryViewControllerCancelledDismiss:galleryViewController];
    }
}

- (void)galleryViewControllerDidDismiss:(UCPhotoGalleryViewController *)galleryViewController {
    if ([self.delegate respondsToSelector:@selector(galleryViewControllerDidDismiss:)]) {
        [self.delegate galleryViewControllerDidDismiss:galleryViewController];
    }

    self.selectedCell.alpha = 1;
    self.selectedIndex = NSNotFound;
}

- (void)galleryItemDidZoom:(UCPhotoGalleryItemView *)galleryItem {
    if ([self.delegate respondsToSelector:@selector(galleryItemDidZoom:)]) {
        [self.delegate galleryItemDidZoom:galleryItem];
    }
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
