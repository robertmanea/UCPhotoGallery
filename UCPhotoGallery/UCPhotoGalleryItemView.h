//
//  Created by Bryan Oltman on 10/27/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDImageCache;
@class UCPhotoGalleryItemView;

@protocol UCGalleryItemDelegate <NSObject>
@optional;
/**
 *  Notifies that an image has loaded
 *
 *  @param galleryItem The host item
 */
- (void)imageLoadedForGalleryItem:(UCPhotoGalleryItemView *)galleryItem;

/**
 *  Notifies that zooming has occurred
 *
 *  @param galleryItem The zoomed item
 */
- (void)galleryItemDidZoom:(UCPhotoGalleryItemView *)galleryItem;
@end

@interface UCPhotoGalleryItemView : UIScrollView

@property (weak) id<UCGalleryItemDelegate> galleryItemDelegate;

/**
 * The shared image cache
 */
@property (strong, nonatomic) SDImageCache *imageCache;

/**
 *  The zooming image view
 */
@property (nonatomic) UIImageView *imageView;

/**
 *  The index of this item in the gallery view (internal)
 */
@property (nonatomic) NSUInteger index;

/**
 *  The frame of the scaled image
 *
 *  @return the image's frame
 */
- (CGRect)imageFrame;

- (void)prepareForReuse;

/**
 *  Zooms out the scroll view such that one dimension of the image is equal to the scroll view's bounds
 */
- (void)setMaxMinZoomScalesForCurrentBounds;

/**
 *  The image URL to load
 */
@property (nonatomic) NSURL *url;

@end
