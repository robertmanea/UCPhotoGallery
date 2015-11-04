#import "UCPhotoGalleryViewController.h"
#import "UCPhotoGalleryItemView.h"
#import "UCPhotoGalleryFullscreenTransitionController.h"
#import <UCDirectionalPanGestureRecognizer/UCDirectionalPanGestureRecognizer.h>

@interface UCPhotoGalleryViewController () <UCGalleryViewDelegate, UCGalleryItemDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIViewControllerTransitioningDelegate>

@property NSUInteger indexBeforeRotation;
@property NSMutableSet *visibleItems;
@property NSMutableSet *recycledItems;
@property (nonatomic) NSMutableArray *urls;
@property BOOL performingLayout;
@property BOOL rotating;

@property (nonatomic) UIButton *doneButton;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UCDirectionalPanGestureRecognizer *scrollDismissRecognizer;
@property (nonatomic) UCPhotoGalleryFullscreenTransitionController *transitionController;

@end

@implementation UCPhotoGalleryViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitionController = [UCPhotoGalleryFullscreenTransitionController new];
        [self.view setNeedsLayout];
    }

    return self;
}

#pragma mark - Getters/Setters
- (UIColor *)backgroundColor {
    return self.scrollView.backgroundColor;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    [self setCurrentIndex:currentIndex animated:NO];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
               animated:(BOOL)animated {
    _currentIndex = currentIndex;
    if (currentIndex < self.urls.count) {
        CGRect frame = [self frameForItemAtIndex:currentIndex];
        [self.scrollView setContentOffset:CGPointMake(frame.origin.x, 0)
                                 animated:animated];
    }
}

- (void)setDataSource:(NSObject<UCGalleryViewDataSource> *)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setIsFullscreen:(BOOL)isFullscreen {
    _isFullscreen = isFullscreen;
    self.doneButton.hidden = !isFullscreen;
    self.scrollDismissRecognizer.enabled = isFullscreen;
    for (UCPhotoGalleryItemView *item in self.visibleItems) {
        item.userInteractionEnabled = isFullscreen;
    }
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = ({
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|
                                       UIViewAutoresizingFlexibleHeight);
        scrollView.backgroundColor = [UIColor blackColor];
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;

        self.scrollDismissRecognizer = ({
            UCDirectionalPanGestureRecognizer *recognizer =
            [[UCDirectionalPanGestureRecognizer alloc] initWithTarget:self
                                                               action:@selector(scrollViewPanned:)];
            recognizer.direction = UCGestureRecognizerDirectionVertical;
            recognizer.delegate = self;
            recognizer.offsetThreshold = 20;
            [scrollView addGestureRecognizer:recognizer];
            recognizer;
        });
        
        [self.view addSubview:scrollView];
        scrollView;
    });

    self.doneButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 50, 30, 100, 44)];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button sizeToFit];
        [button addTarget:self
                   action:@selector(doneButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        button.hidden = !self.isFullscreen;
        [self.view addSubview:button];
        button;
    });

    self.currentIndex = 0;
    self.isFullscreen = NO;
    self.rotating = NO;
    self.visibleItems = [NSMutableSet new];
    self.recycledItems = [NSMutableSet new];

    [self.view addGestureRecognizer:
     [[UITapGestureRecognizer alloc] initWithTarget:self
                                             action:@selector(singleTapRecognized:)]];

    [self reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutVisibleItems];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // Annoying hacky way to ensure the layout is actually 100% finished before attempting to pass this info
    // on to the transition controller.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateTransitionControllerWithSelectedView];
    });
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    // Remember index before rotation
    self.indexBeforeRotation = self.currentIndex;
    self.rotating = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    self.currentIndex = self.indexBeforeRotation;
    [self layoutVisibleItems];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.rotating = NO;

    [self layoutVisibleItems];
}

- (void)updateTransitionControllerWithSelectedView {
    if (self.isFullscreen || !self.parentViewController) {
        return;
    }

    self.transitionController.presentFromRect = [self imageFrameInSuperview];
    self.transitionController.transitionImage = self.visibleItem.imageView.image;
}

- (void)reloadData {
    self.urls = [[self.dataSource imageURLsForGalleryView:self] mutableCopy];
    while (self.scrollView.subviews.count) {
        [[self.scrollView.subviews firstObject] removeFromSuperview];
    }

    [self.recycledItems addObjectsFromArray:self.visibleItems.allObjects];
    [self.visibleItems removeAllObjects];

    [self layoutVisibleItems];
    [self.view setNeedsLayout];
}

- (void)expandInViewController:(UIViewController *)viewController {
    if (!viewController || self.isFullscreen) {
        return;
    }

    // Create a fullscreen gallery view controller
    UCPhotoGalleryViewController *galleryVC = ({
        UCPhotoGalleryViewController *gallery = [UCPhotoGalleryViewController new];
        gallery.view.frame = viewController.view.bounds;
        gallery.currentIndex = self.currentIndex;
        gallery.dataSource = self.dataSource;
        gallery.delegate = self;
        gallery.isFullscreen = YES;
        gallery.transitioningDelegate = self;
        gallery.modalPresentationStyle = UIModalPresentationCustom;
        gallery;
    });

    [self updateTransitionControllerWithSelectedView];

    [viewController presentViewController:galleryVC
                                 animated:YES
                               completion:nil];

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

- (CGRect)imageFrameInSuperview {
    UCPhotoGalleryItemView *visibleItem = [self visibleItem];
    CGRect ret = [self.view.superview convertRect:visibleItem.imageView.frame
                                         fromView:self.view];
    return ret;
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
    NSInteger firstVisibleIndex = (NSInteger)floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    NSInteger lastVisibleIndex  = (NSInteger)floorf(CGRectGetMaxX(visibleBounds) / CGRectGetWidth(visibleBounds));

    // Ensure both indexes are within the url array bounds
    firstVisibleIndex = MIN(MAX(0, firstVisibleIndex), self.urls.count - 1);
    lastVisibleIndex = MIN(MAX(0, lastVisibleIndex), self.urls.count - 1);

    // Move non-visible items to the reuse pool
    NSInteger index;
    for (UCPhotoGalleryItemView *item in self.visibleItems) {
        index = item.index;
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
 *  The scroll view's content size, based on bounds and number of URLs
 *
 *  @return The appropriate content size
 */
- (CGSize)contentSizeForScrollView {
    return CGSizeMake(self.urls.count * self.view.bounds.size.width,
                      self.view.bounds.size.height);
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
 *  Shows or hides the done button based on whether the gallery is full-screen and whether the 
 *  currently visible item is zoomed in at all
 */
- (void)updateDoneButtonVisibility {
    CGFloat zoomScale = self.visibleItem.zoomScale;
    self.doneButton.hidden = !self.isFullscreen || (zoomScale > self.visibleItem.minimumZoomScale);
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

#pragma mark - UIActions
- (void)doneButtonClicked:(__unused UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(dismissFullscreenGalleryController:)]) {
        [self.delegate dismissFullscreenGalleryController:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Gesture Recognizers
- (void)scrollViewPanned:(UCDirectionalPanGestureRecognizer *)recognizer {
    static UCPhotoGalleryItemView *visibleItemView = nil;
    CGFloat yTranslation = recognizer.translation;
    CGFloat translationThreshold = 175;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            visibleItemView = [self visibleItem];
            break;
        case UIGestureRecognizerStateChanged:
            visibleItemView.transform = CGAffineTransformMakeTranslation(0, yTranslation);
            self.scrollView.backgroundColor = [UIColor colorWithWhite:0
                                                                alpha:1 - (fabs(yTranslation) / translationThreshold)];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded: {
            BOOL shouldClose = fabs(yTranslation) >= translationThreshold;
            if (!shouldClose) {
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     visibleItemView.transform = CGAffineTransformIdentity;
                                     self.scrollView.backgroundColor = [UIColor blackColor];
                                 }];
            } else {
                self.scrollView.backgroundColor = [UIColor clearColor];
                if ([self.delegate respondsToSelector:@selector(dismissFullscreenGalleryController:)]) {
                    [self.delegate dismissFullscreenGalleryController:self];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }

            visibleItemView = nil;
        }
            break;
        default:
            break;
    }
}

- (void)singleTapRecognized:(UITapGestureRecognizer *)recognizer {
    if (!self.isFullscreen) {
        if (self.parentViewController) {
            [self expandInViewController:self.parentViewController];
        }
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
- (void)galleryView:(UCPhotoGalleryViewController *)galleryViewController
        pageChanged:(NSUInteger)page {
    self.visibleItem.alpha = 1;
    [self setCurrentIndex:page animated:NO];
    self.visibleItem.alpha = 0;

    if (self.visibleItem.imageView.image) {
        [self updateTransitionControllerWithSelectedView];
    }
}

- (void)dismissFullscreenGalleryController:(UCPhotoGalleryViewController *)galleryViewController {
    [galleryViewController dismissViewControllerAnimated:YES completion:^{
        self.visibleItem.alpha = 1;
    }];
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

- (void)galleryItemDidZoom:(__unused UCPhotoGalleryItemView *)galleryItem {
    [self updateDoneButtonVisibility];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.performingLayout || self.rotating) {
        return;
    }

    [self tileItems];

    // Calculate current item
    CGRect visibleBounds = self.scrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    index = MIN(MAX(0, index), self.urls.count - 1);
    NSUInteger previousIndex = self.currentIndex;
    _currentIndex = index; // use the ivar to avoid setter logic

    if (self.urls.count && self.currentIndex != previousIndex) {
        [self updateDoneButtonVisibility];

        // Notify delegate of page change
        if ([self.delegate respondsToSelector:@selector(galleryView:pageChanged:)]) {
            [self.delegate galleryView:self pageChanged:index];
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
