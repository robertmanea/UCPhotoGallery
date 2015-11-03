//
//  Created by Bryan Oltman on 10/30/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCPhotoCell;

@protocol UCPhotoCellDelegate <NSObject>
/**
 *  Notifies that an image has loaded
 *
 *  @param cell The host cell
 */
- (void)imageLoadedForPhotoCell:(UCPhotoCell *)cell;
@end

@interface UCPhotoCell : UICollectionViewCell

/**
 *  The URL corresponding to the image
 */
@property (nonatomic) NSURL *url;

/**
 *  The cell's image
 */
@property (readonly) UIImage *image;

/**
 *  The cell's delegate
 */
@property (weak) id<UCPhotoCellDelegate> delegate;

+ (NSString *)reuseIdentifier;

/**
 *  The frame of the image (not the image view) in the cell's content view
 *
 *  @return The image's frame
 */
- (CGRect)imageFrame;

@end
