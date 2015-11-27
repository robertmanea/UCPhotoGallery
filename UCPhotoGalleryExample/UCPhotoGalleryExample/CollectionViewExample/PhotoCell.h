//
//  Created by Bryan Oltman on 10/30/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoCell;

@protocol UCPhotoCellDelegate <NSObject>
/**
 *  Notifies that an image has loaded
 *
 *  @param cell The host cell
 */
- (void)imageLoadedForPhotoCell:(PhotoCell *)cell;
@end

@interface PhotoCell : UICollectionViewCell

/**
 *  The URL corresponding to the image
 */
@property (nonatomic) NSURL *url;

/**
 *  The cell's image
 */
@property (readonly) UIImage *image;

@property (nonatomic) UIImageView *photoImageView;

/**
 *  The cell's delegate
 */
@property (weak) id<UCPhotoCellDelegate> delegate;

+ (NSString *)reuseIdentifier;

@end
