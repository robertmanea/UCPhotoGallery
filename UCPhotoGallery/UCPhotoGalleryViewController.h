//
//  Created by Bryan Oltman on 10/28/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCPhotoGalleryItemView.h"

@class UCPhotoGalleryViewController;

/**
 *  Provides URLs to the gallery view
 */
@protocol UCGalleryViewDataSource<NSObject>

/**
 *  The image URLs for the gallery view to load
 *
 *  @param galleryViewController The requesting gallery view
 *
 *  @return An array of NSURL objects
 */
- (NSArray *)imageURLsForGalleryView:(UCPhotoGalleryViewController *)galleryViewController;
@end

/**
 *  Responds to various gallery interactions
 */
@protocol UCGalleryViewDelegate<NSObject>
@optional

/**
 *  A button to use in place of the default done button for the full-screen gallery
 *
 *  @return A done button
 */
- (UIButton *)doneButtonForFullscreenGalleryController:(UCPhotoGalleryViewController *)galleryViewController;

/**
 *  Notifies the delegate when the gallery view has been paged
 *
 *  @param galleryViewController The gallery view controller
 *  @param page                  The now-visible page
 */
- (void)galleryViewController:(UCPhotoGalleryViewController *)galleryViewController
        pageChanged:(NSUInteger)page;

/**
 *  Notifies that the dismissal of a full-screen gallery controller has begun
 *
 *  @param galleryViewController The full-screen gallery controller
 */
- (void)galleryViewControllerWillDismiss:(UCPhotoGalleryViewController *)galleryViewController;

/**
 *  Notifies that the dismissal of a full-screen gallery controller was cancelled
 *
 *  @param galleryViewController The dismissing gallery view controller
 */
- (void)galleryViewControllerCancelledDismiss:(UCPhotoGalleryViewController *)galleryViewController;

/**
 *  Notifies that the dismissal of a full-screen gallery controller finished
 *
 *  @param galleryViewController The dismissing gallery view controller
 */
- (void)galleryViewControllerDidDismiss:(UCPhotoGalleryViewController *)galleryViewController;

/**
 *  Notifies that this controller will trigger a transition to a full-screen gallery view controller
 *
 *  @param galleryViewController The full-screen gallery view controller
 */
- (void)willPresentGalleryViewController:(UCPhotoGalleryViewController *)galleryViewController;

/**
 *  Notifies that this controller completed a transition to a full-screen gallery view controller
 *
 *  @param galleryViewController The full-screen gallery view controller
 */
- (void)didPresentGalleryViewController:(UCPhotoGalleryViewController *)galleryViewController;

/**
 *  Notifies that an item is being zoomed in a full-screen gallery view contorller 
 *  (forwards from UCPhotoGalleryItemView)
 *
 *  @param galleryItem The zoomed item
 */
- (void)galleryItemDidZoom:(UCPhotoGalleryItemView *)galleryItem;
@end

@interface UCPhotoGalleryViewController : UIViewController

/**
 *  The current visible gallery item
 */
@property (readonly) UCPhotoGalleryItemView *visibleItem;

/**
 *  Whether a single tap will cause the gallery to expand into a full-screen mode
 */
@property (nonatomic) BOOL canExpand;

/**
 *  The index of the currently visible item
 */
@property (nonatomic) NSUInteger currentIndex;

/**
 *  If a full-screen gallery is present, dismisses it
 *
 *  @param animated Whether the dismiss transition is animated
 */
- (void)dismiss:(BOOL)animated;

/**
 *  Creates a new full-screen gallery view controller
 *
 *  @param animated Whether to animate the transition
 */
- (void)expand:(BOOL)animated;

@property (weak, nonatomic) NSObject<UCGalleryViewDataSource>* dataSource;
@property (weak, nonatomic) NSObject<UCGalleryViewDelegate>* delegate;

@property (nonatomic) UIViewContentMode imageContentMode;

@property (nonatomic) BOOL isFullscreen;

/**
 *  Registers overlayView for animations during interactive dismissal
 *
 *  @param overlayView The view to be registered
 */
- (void)registerOverlayView:(UIView *)overlayView;

/**
 *  Deregisters overlayView for animations during interactive dismissal
 *
 *  @param overlayView The view to be deregistered
 */
- (void)deregisterOverlayView:(UIView *)overlayView;

/**
 *  The set of all views that have been registered as overlay views
 */
@property (nonatomic, readonly) NSSet *overlayViews;

/**
 *  Reload image URLs from the dataSource and reset gallery items layout
 */
- (void)reloadData;

/**
 *  The frame of the image in the gallery view's superview
 *
 *  @return (see above)
 */
- (CGRect)imageFrameInRootView;

/**
 *  A setter for currentIndex with an optional animation parameter
 *
 *  @param currentPageIndex The new current index
 *  @param animated         Whether to animate the transition to the new index
 */
- (void)setCurrentIndex:(NSUInteger)currentPageIndex
               animated:(BOOL)animated;

@end
