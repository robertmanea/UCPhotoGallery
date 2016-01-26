#import "UCPhotoGalleryViewController.h"
#import "UCPhotoGalleryItemView.h"
#import "UCPhotoGalleryFullscreenTransitionController.h"
#import <UCDirectionalPanGestureRecognizer/UCDirectionalPanGestureRecognizer.h>
#import <WebImage/SDImageCache.h>
#import "tgmath.h"

@interface UCPhotoGalleryViewController () <UCGalleryViewDelegate, UCGalleryItemDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIViewControllerTransitioningDelegate>

@property NSUInteger indexBeforeRotation;
@property NSMutableSet *mutableOverlayViews;
@property NSMutableSet *visibleItems;
@property NSMutableSet *recycledItems;
@property NSArray *urls;
@property BOOL performingLayout;
@property BOOL rotating;
@property (getter=isDisappearing) BOOL disappearing;

@property (nonatomic) UIButton *doneButton;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UITapGestureRecognizer *singleTapRecognizer;
@property (nonatomic) UCDirectionalPanGestureRecognizer *scrollDismissRecognizer;
@property (nonatomic) UCPhotoGalleryFullscreenTransitionController *transitionController;

@property (nonatomic) UCPhotoGalleryViewController *fullscreenGalleryController;

@end

@implementation UCPhotoGalleryViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.canExpand = YES;
        self.imageScalingMode = UCImageScalingModeFit;
        self.imageCache = [SDImageCache sharedImageCache];
        self.transitionController = [UCPhotoGalleryFullscreenTransitionController new];
        self.currentIndex = 0;
        self.rotating = NO;
        self.mutableOverlayViews = [NSMutableSet new];
        self.visibleItems = [NSMutableSet new];
        self.recycledItems = [NSMutableSet new];

        [self reloadData];
    }

    return self;
}

#pragma mark - Getters/Setters
- (void)setCanExpand:(BOOL)canExpand {
    _canExpand = canExpand;
    self.singleTapRecognizer.enabled = canExpand;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    [self setCurrentIndex:currentIndex animated:NO];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
               animated:(BOOL)animated {
    if (_currentIndex == currentIndex) {
        return;
    }

    _currentIndex = currentIndex;
    [self.fullscreenGalleryController setCurrentIndex:currentIndex
                                             animated:animated];

    if (currentIndex < self.urls.count) {
        CGRect frame = [self frameForItemAtIndex:currentIndex];
        [self.scrollView setContentOffset:CGPointMake(frame.origin.x, 0)
                                 animated:animated];
        if ([self.delegate respondsToSelector:@selector(galleryViewController:pageChanged:)]) {
            [self.delegate galleryViewController:self pageChanged:currentIndex];
        }
    }
}

- (void)setDataSource:(NSObject<UCGalleryViewDataSource> *)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setDelegate:(NSObject<UCGalleryViewDelegate> *)delegate {
    _delegate = delegate;
    [self reloadData];
    [self updateDoneButton];
}

- (void)setImageScalingMode:(UCImageScalingMode)imageScalingMode {
    _imageScalingMode = imageScalingMode;
    [self reloadData];
}

- (void)setIsFullscreen:(BOOL)isFullscreen {
    _isFullscreen = isFullscreen;
    self.scrollDismissRecognizer.enabled = isFullscreen;
    [self updateDoneButton];
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    self.scrollView = ({
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|
                                       UIViewAutoresizingFlexibleHeight);
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;

        self.scrollDismissRecognizer = ({
            UCDirectionalPanGestureRecognizer *recognizer =
            [[UCDirectionalPanGestureRecognizer alloc] initWithTarget:self
                                                               action:@selector(scrollViewPanned:)];
            recognizer.direction = UCGestureRecognizerDirectionVertical;
            recognizer.delegate = self;
            recognizer.enabled = self.isFullscreen;
            [scrollView addGestureRecognizer:recognizer];
            recognizer;
        });

        [self.view addSubview:scrollView];
        scrollView;
    });

    self.singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(singleTapRecognized:)];
    self.singleTapRecognizer.enabled = self.canExpand;
    [self.view addGestureRecognizer:self.singleTapRecognizer];

    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    for (UCPhotoGalleryItemView *item in self.visibleItems) {
        item.userInteractionEnabled = self.isFullscreen;
    }

    self.scrollDismissRecognizer.enabled = self.isFullscreen;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.scrollView.contentSize = [self contentSizeForScrollView];

    // Annoying hacky way to ensure the layout is actually 100% finished before attempting to pass this info
    // on to the transition controller.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateTransitionControllerWithSelectedView];
    });
}

- (void)willRotateToInterfaceOrientation:(__unused UIInterfaceOrientation)toInterfaceOrientation
                                duration:(__unused NSTimeInterval)duration {
    // Remember index before rotation
    self.indexBeforeRotation = self.currentIndex;
    self.rotating = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(__unused UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(__unused NSTimeInterval)duration {
    self.currentIndex = self.indexBeforeRotation;
    [self layoutVisibleItems];
}

- (void)didRotateFromInterfaceOrientation:(__unused UIInterfaceOrientation)fromInterfaceOrientation {
    self.rotating = NO;
    [self layoutVisibleItems];
}

- (BOOL)prefersStatusBarHidden {
    return self.isFullscreen && !self.isDisappearing;
}

- (void)updateTransitionControllerWithSelectedView {
    if (self.isFullscreen) {
        return;
    }

    self.transitionController.presentFromRect = [self visibleImageFrameInApplicationWindow];
    self.transitionController.transitionImage = self.visibleItem.imageView.image;
}

- (void)registerOverlayView:(UIView *)overlayView {
    if (overlayView) {
        [self.mutableOverlayViews addObject:overlayView];
    }
}

- (void)deregisterOverlayView:(UIView *)overlayView {
    if (overlayView) {
        [self.mutableOverlayViews removeObject:overlayView];
    }
}

- (NSSet *)overlayViews {
    return self.mutableOverlayViews;
}

- (UIImage *)visibleImage {
    return [self imageAtIndex:self.currentIndex];
}

- (void)reloadData {
    self.urls = [self.dataSource imageURLsForGalleryView:self];
    while (self.scrollView.subviews.count) {
        [[self.scrollView.subviews firstObject] removeFromSuperview];
    }

    [self.recycledItems addObjectsFromArray:self.visibleItems.allObjects];
    [self.visibleItems removeAllObjects];

    [self layoutVisibleItems];
    [self.view setNeedsLayout];
}

- (void)expand:(BOOL)animated {
    if (self.isFullscreen) {
        return;
    }

    // Create a fullscreen gallery view controller
    self.fullscreenGalleryController = ({
        UCPhotoGalleryViewController *gallery = [UCPhotoGalleryViewController new];
        gallery.isFullscreen = YES;
        gallery.view.frame = [[[UIApplication sharedApplication] delegate] window].bounds;
        gallery.currentIndex = self.currentIndex;
        gallery.dataSource = self.dataSource;
        gallery.delegate = self;
        gallery.transitioningDelegate = self;
        gallery.modalPresentationStyle = UIModalPresentationCustom;
        gallery;
    });

    [self updateTransitionControllerWithSelectedView];

    if ([self.delegate respondsToSelector:@selector(willPresentGalleryViewController:)]) {
        [self.delegate willPresentGalleryViewController:self.fullscreenGalleryController];
    }

    [self presentViewController:self.fullscreenGalleryController
                       animated:animated
                     completion:^{
                         if ([self.delegate respondsToSelector:@selector(didPresentGalleryViewController:)]) {
                             [self.delegate didPresentGalleryViewController:self.fullscreenGalleryController];
                         }
                     }];

    // Give the transition animation time to start before hiding the selected item
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.visibleItem.alpha = 0;
    });
}

- (UCPhotoGalleryItemView *)visibleItem {
    for (UCPhotoGalleryItemView *item in self.visibleItems) {
        if (item.index == self.currentIndex) {
            return item;
        }
    }

    return nil;
}

- (CGRect)visibleImageFrameInApplicationWindow {
    CGRect ret;
    if ([self scalingModeForItemAtIndex:self.currentIndex] == UCImageScalingModeFill) {
        ret = self.view.bounds;
    } else {
        UCPhotoGalleryItemView *visibleItem = [self visibleItem];
        ret = visibleItem.imageView.frame;
    }

    UIView *rootView = [[[UIApplication sharedApplication] delegate] window];
    ret = [rootView convertRect:ret
                       fromView:self.view];
    return ret;
}

- (void)doneButtonTapped:(__unused UIButton *)button {
    self.disappearing = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    [self dismiss:YES];
}

#pragma mark - Helpers
/**
 *  Sets overall scroll view content size and updates gallery item frames
 */
- (void)layoutVisibleItems {
    self.performingLayout = YES;
    self.scrollView.contentSize = [self contentSizeForScrollView];

    for (UCPhotoGalleryItemView *item in self.visibleItems) {
        NSUInteger index = item.index;
        item.frame = [self frameForItemAtIndex:index];
        [item setMaxMinZoomScalesForCurrentBounds];
    }

    self.scrollView.contentOffset = [self contentOffsetForItemAtIndex:self.currentIndex];
    [self tileItems];
    self.performingLayout = NO;
}

/**
 *  Places visible items in view and recycles unused items
 */
- (void)tileItems {
    if (!self.urls.count) {
        return;
    }

    CGRect visibleBounds = self.scrollView.bounds;
    NSInteger firstVisibleIndex = (NSInteger)floor(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    NSInteger lastVisibleIndex  = (NSInteger)floor(CGRectGetMaxX(visibleBounds) / CGRectGetWidth(visibleBounds));

    // Ensure both indexes are within the url array bounds
    firstVisibleIndex = MIN(MAX(0, firstVisibleIndex), (NSInteger) self.urls.count - 1);
    lastVisibleIndex = MIN(MAX(0, lastVisibleIndex), (NSInteger) self.urls.count - 1);

    // Move non-visible items to the reuse pool
    for (UCPhotoGalleryItemView *item in self.visibleItems) {
        NSInteger index = (NSInteger)item.index;
        if (index < firstVisibleIndex || index > lastVisibleIndex) {
            [self.recycledItems addObject:item];
            [item prepareForReuse];
            [item removeFromSuperview];
            //            NSLog(@"Removed item at index %lu", (unsigned long)index);
        }
    }

    [self.visibleItems minusSet:self.recycledItems];
    while (self.recycledItems.count > 2) { // Only keep 2 recycled items
        [self.recycledItems removeObject:[self.recycledItems anyObject]];
    }

    // Add missing items
    for (NSUInteger index = (NSUInteger)firstVisibleIndex; index <= (NSUInteger)lastVisibleIndex; index++) {
        if (![self isItemVisibleAtIndex:index]) {
            UCPhotoGalleryItemView *item = [self dequeueRecycledItem];
            if (!item) {
                item = [UCPhotoGalleryItemView new];
                item.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                item.imageCache = self.imageCache;
                item.galleryItemDelegate = self;
                item.translatesAutoresizingMaskIntoConstraints = NO;
                item.userInteractionEnabled = self.isFullscreen;
            }

            [self.visibleItems addObject:item];
            [self configureItemView:item forIndex:index];
            [self.scrollView addSubview:item];
            //            NSLog(@"Added item at index %lu", (unsigned long)index);
        }
    }

    // ...and because iOS 8 can get a little aggressive about setting a top inset on child view controllers...
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

/**
 *  A convenience function that asks the delegate which scaling mode we should use and defaults to self.imageScalingMode
 *  if the delegate does not provide that information.
 *
 *  @param index The index of the image to scale
 *
 *  @return The scaling mode
 */
- (UCImageScalingMode)scalingModeForItemAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(galleryViewController:scalingModeForImageAtIndex:)]) {
        return [self.delegate galleryViewController:self
                         scalingModeForImageAtIndex:index];
    }

    return self.imageScalingMode;
}

/**
 *  The scroll view's content size, based on bounds and number of URLs
 *
 *  @return The appropriate content size
 */
- (CGSize)contentSizeForScrollView {
    return CGSizeMake(self.urls.count * self.view.bounds.size.width,
                      self.view.bounds.size.height);
}

- (UIImage *)imageAtIndex:(NSUInteger)index {
    for (UCPhotoGalleryItemView *view in [self visibleItems]) {
        if (view.index == index) {
            return view.imageView.image;
        }
    }

    return nil;
}

/**
 *  Creates a frame for the gallery item at the provided index
 *
 *  @param index The ordinal number of the desired frame
 *
 *  @return The frame for the gallery item at index
 */
- (CGRect)frameForItemAtIndex:(NSUInteger)index {
    CGSize size = self.view.bounds.size;
    CGFloat xOffset = index * size.width;
    return (CGRect){{xOffset, 0}, size};
}

/**
 *  Checks for existance of a gallery item with the provided index in the visible items collection
 *
 *  @param index The ordinal number of gallery item
 *
 *  @return A boolean indicating whether a gallery item is visible at index
 */
- (BOOL)isItemVisibleAtIndex:(NSUInteger)index {
    for (UCPhotoGalleryItemView *item in self.visibleItems) {
        if (item.index == index) {
            return YES;
        }
    }

    return NO;
}

/**
 *  Removes a gallery item from the recycle pool
 *
 *  @return The gallery item to be recycled
 */
- (UCPhotoGalleryItemView *)dequeueRecycledItem {
    if (!self.recycledItems.count) {
        return nil;
    }

    UCPhotoGalleryItemView *item = [self.recycledItems anyObject];
    [self.recycledItems removeObject:item];
    return item;
}

/**
 *  Prepare the gallery item for presentation
 *
 *  @param view  The gallery item
 *  @param index The index at which the item will be displayed
 */
- (void)configureItemView:(UCPhotoGalleryItemView *)view
                 forIndex:(NSUInteger)index {
    view.frame = [self frameForItemAtIndex:index];
    UCImageScalingMode scalingMode = [self scalingModeForItemAtIndex:index];
    view.imageView.contentMode = (scalingMode == UCImageScalingModeFill ?
                                  UIViewContentModeScaleAspectFill :
                                  UIViewContentModeCenter);
    view.index = index;
    view.url = self.urls[index];
}

/**
 *  The offset for the gallery item at index
 *
 *  @param index The ordinal number of the item
 *
 *  @return A CGPoint representing the content offset in the gallery scroll view for the item at index
 */
- (CGPoint)contentOffsetForItemAtIndex:(NSUInteger)index {
    CGFloat itemWidth = self.scrollView.bounds.size.width;
    CGFloat newOffset = index * itemWidth;
    return CGPointMake(newOffset, 0);
}

- (void)updateDoneButton {
    if (!self.isFullscreen) {
        self.doneButton.hidden = YES;
        return;
    }

    [self deregisterOverlayView:self.doneButton];
    [self.doneButton removeFromSuperview];
    self.doneButton = nil;

    if ([self.delegate respondsToSelector:@selector(doneButtonForFullscreenGalleryController:)]) {
        self.doneButton = [self.delegate doneButtonForFullscreenGalleryController:self];
    }

    if (!self.doneButton) {
        self.doneButton = ({
            UIButton *button = [UIButton new];
            [button setTitle:@"Done" forState:UIControlStateNormal];
            button;
        });
    }

    [self registerOverlayView:self.doneButton];
    [self.view addSubview:self.doneButton];
    [self.doneButton addTarget:self
                        action:@selector(doneButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
    self.doneButton.hidden = NO;
    [self.doneButton sizeToFit];
    CGPoint origin = CGPointMake(self.view.bounds.size.width - self.doneButton.frame.size.width - 20, 30);
    self.doneButton.frame = (CGRect) { origin, self.doneButton.bounds.size };
    self.doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view bringSubviewToFront:self.doneButton];
}

#pragma mark - Gesture Recognizers
- (void)scrollViewPanned:(UCDirectionalPanGestureRecognizer *)recognizer {
    static UCPhotoGalleryItemView *visibleItemView = nil;
    CGFloat yTranslation = [recognizer translationInView:self.view].y;
    CGFloat translationThreshold = 175.0f;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            visibleItemView = [self visibleItem];
            if ([self.delegate respondsToSelector:@selector(galleryViewControllerWillDismiss:)]) {
                [self.delegate galleryViewControllerWillDismiss:self];
            }
            break;
        case UIGestureRecognizerStateChanged: {
            visibleItemView.transform = CGAffineTransformMakeTranslation(0, yTranslation);
            CGFloat alpha = 1.0f - (fabs(yTranslation) / translationThreshold);
            self.view.backgroundColor = [UIColor colorWithWhite:0
                                                          alpha:alpha];
            [self updateOverlaysWithAlpha:alpha];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded: {
            BOOL shouldClose = fabs(yTranslation) >= translationThreshold;
            if (!shouldClose) {
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     visibleItemView.transform = CGAffineTransformIdentity;
                                     [self updateOverlaysWithAlpha:1];
                                     self.view.backgroundColor = [UIColor colorWithWhite:0
                                                                                   alpha:1];
                                 }];
                if ([self.delegate respondsToSelector:@selector(galleryViewControllerCancelledDismiss:)]) {
                    [self.delegate galleryViewControllerCancelledDismiss:self];
                }
            } else {
                self.view.backgroundColor = [UIColor clearColor];
                [self dismissViewControllerAnimated:YES completion:^{
                    if ([self.delegate respondsToSelector:@selector(galleryViewControllerDidDismiss:)]) {
                        [self.delegate galleryViewControllerDidDismiss:self];
                    }
                }];
            }

            visibleItemView = nil;
        }
            break;
        default:
            break;
    }
}

- (void)updateOverlaysWithAlpha:(CGFloat)alpha {
    for (UIView *overlayView in self.overlayViews) {
        overlayView.alpha = alpha;
    }
}

- (void)dismiss:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(galleryViewControllerWillDismiss:)]) {
        [self.delegate galleryViewControllerWillDismiss:self];
    }

    [self dismissViewControllerAnimated:animated completion:^{
        if ([self.delegate respondsToSelector:@selector(galleryViewControllerDidDismiss:)]) {
            [self.delegate galleryViewControllerDidDismiss:self];
        }

        [self.mutableOverlayViews removeAllObjects];
        self.visibleItem.alpha = 1;
    }];
}

- (void)singleTapRecognized:(__unused UITapGestureRecognizer *)recognizer {
    if (!self.isFullscreen) {
        [self expand:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (gestureRecognizer == self.scrollDismissRecognizer &&
            otherGestureRecognizer == self.scrollView.panGestureRecognizer);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return !(gestureRecognizer == self.scrollDismissRecognizer &&
             otherGestureRecognizer == self.scrollView.panGestureRecognizer);
}

#pragma mark - UCGalleryViewDelegate
- (UIButton *)doneButtonForFullscreenGalleryController:(UCPhotoGalleryViewController *)galleryViewController {
    if ([self.delegate respondsToSelector:@selector(doneButtonForFullscreenGalleryController:)]) {
        return [self.delegate doneButtonForFullscreenGalleryController:galleryViewController];
    }

    return nil;
}

- (void)galleryViewController:(__unused UCPhotoGalleryViewController *)galleryViewController
        pageChanged:(NSUInteger)page {
    self.visibleItem.alpha = 1;
    [self setCurrentIndex:page animated:NO];
    self.visibleItem.alpha = 0;
}

#pragma mark - UCGalleryItemDelegate
/**
 *  Used to observe image loads - mainly useful for updating the transition controller
 *
 *  @param galleryItem The item hosting the image view that finished loading
 */
- (void)imageLoadedForGalleryItem:(UCPhotoGalleryItemView *)galleryItem {
    if (galleryItem == self.visibleItem) {
        [self updateTransitionControllerWithSelectedView];
    }
}

- (void)galleryItemDidZoom:(UCPhotoGalleryItemView *)galleryItem {
    if ([self.delegate respondsToSelector:@selector(galleryItemDidZoom:)]) {
        [self.delegate galleryItemDidZoom:galleryItem];
    }

    if (galleryItem.zoomScale > galleryItem.minimumZoomScale) {
        self.scrollDismissRecognizer.enabled = NO;
        [self updateOverlaysWithAlpha:0];
    } else {
        if (self.isFullscreen) {
            self.scrollDismissRecognizer.enabled = YES;
        }
        
        [self updateOverlaysWithAlpha:1];
    }
}

- (void)galleryViewControllerWillDismiss:(__unused UCPhotoGalleryViewController *)galleryViewController {
    [self updateTransitionControllerWithSelectedView];
    if ([self.delegate respondsToSelector:@selector(galleryViewControllerWillDismiss:)]) {
        [self.delegate galleryViewControllerWillDismiss:self];
    }
}

- (void)galleryViewControllerCancelledDismiss:(__unused UCPhotoGalleryViewController *)galleryViewController {
    if ([self.delegate respondsToSelector:@selector(galleryViewControllerCancelledDismiss:)]) {
        [self.delegate galleryViewControllerCancelledDismiss:self];
    }
}

- (void)galleryViewControllerDidDismiss:(__unused UCPhotoGalleryViewController *)galleryViewController {
    if ([self.delegate respondsToSelector:@selector(galleryViewControllerDidDismiss:)]) {
        [self.delegate galleryViewControllerDidDismiss:self];
    }

    self.fullscreenGalleryController = nil;
    self.visibleItem.alpha = 1;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(__unused UIScrollView *)scrollView {
    if (self.performingLayout || self.rotating) {
        return;
    }

    [self tileItems];

    // Calculate current item
    CGRect visibleBounds = self.scrollView.bounds;
    NSInteger index = (NSInteger)(floor(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    index = MIN(MAX(0, index), (NSInteger)self.urls.count - 1);
    NSUInteger previousIndex = self.currentIndex;
    _currentIndex = (NSUInteger)index; // use the ivar to avoid setter logic

    if (self.urls.count && self.currentIndex != previousIndex) {
        // Notify delegate of page change
        if ([self.delegate respondsToSelector:@selector(galleryViewController:pageChanged:)]) {
            [self.delegate galleryViewController:self pageChanged:_currentIndex];
        }
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
