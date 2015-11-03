//
//  Created by Bryan Oltman on 10/27/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCPhotoGalleryItemView;

@protocol UCGalleryItemDelegate <NSObject>
@optional;
/**
 *  Notifies that an image has loaded
 *
 *  @param galleryItem The host item
 */
- (void)imageLoadedForGalleryItem:(UCPhotoGalleryItemView *)galleryItem;
@end

@interface UCPhotoGalleryItemView : UIScrollView

@property (weak) id<UCGalleryItemDelegate> galleryItemDelegate;

/**
 *  The image URL to load
 */
@property (nonatomic) NSURL *url;

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

@end
