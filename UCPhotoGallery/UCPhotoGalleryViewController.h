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
 *  @return An array of NSURL objects representing image URLs
 */
- (NSArray *)imageURLsForGalleryView:(UCPhotoGalleryViewController *)galleryViewController;
@end

/**
 *  Responds to various gallery interactions
 */
@protocol UCGalleryViewDelegate<NSObject>
@optional
/**
 *  Notifies the delegate when the gallery view has been paged
 *
 *  @param galleryViewController The gallery view controller
 *  @param page                  The now-visible page
 */
- (void)galleryView:(UCPhotoGalleryViewController *)galleryViewController
        pageChanged:(NSUInteger)page;

/**
 *  Allows the delegate to control the dismissal of a full-screen gallery controller
 *
 *  @param galleryViewController The full-screen gallery controller
 */
- (void)dismissFullscreenGalleryController:(UCPhotoGalleryViewController *)galleryViewController;
@end

@interface UCPhotoGalleryViewController : UIViewController

/**
 *  The background color of the gallery's scroll view
 */
@property (readonly) UIColor *backgroundColor;

/**
 *  The current visible gallery item
 */
@property (readonly) UCPhotoGalleryItemView *visibleItem;

/**
 *  The index of the currently visible item
 */
@property (nonatomic) NSUInteger currentIndex;

/**
 *  Whether the gallery view is in an expanded state (showing a done button, etc.)
 */
@property (nonatomic) BOOL isFullscreen;

@property (weak, nonatomic) NSObject<UCGalleryViewDataSource>* dataSource;
@property (weak, nonatomic) NSObject<UCGalleryViewDelegate>* delegate;

/**
 *  Reload image URLs from the dataSource and reset gallery items layout
 */
- (void)reloadData;

/**
 *  Creates a new full-screen gallery view controller and displays it in viewController
 *
 *  @param viewController The host view controller for display
 */
- (void)expandInViewController:(UIViewController *)viewController;

/**
 *  The frame of the image in the gallery view's superview
 *
 *  @return (see above)
 */
- (CGRect)imageFrameInSuperview;

/**
 *  A setter for currentIndex with an optional animation parameter
 *
 *  @param currentPageIndex The new current index
 *  @param animated         Whether to animate the transition to the new index
 */
- (void)setCurrentIndex:(NSUInteger)currentPageIndex
               animated:(BOOL)animated;

@end
