//
//  Created by Bryan Oltman on 10/28/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCPhotoGalleryFullscreenTransitionController : NSObject <UIViewControllerAnimatedTransitioning>

/**
 * The frame of the animating image in the presenting view
 */
@property (nonatomic) CGRect presentFromRect;

/**
 *  The image that is being animated
 */
@property (nonatomic) UIImage *transitionImage;

@end
