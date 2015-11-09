//
//  Created by Bryan Oltman on 10/30/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCPhotoGalleryViewController.h"

@interface UCPhotosViewController : UICollectionViewController

 /**
 *  Provides photo URLs
 */
@property (weak, nonatomic) NSObject<UCGalleryViewDataSource>* dataSource;
@property (weak, nonatomic) NSObject<UCGalleryViewDelegate>* delegate;

/**
 *  If a full-screen gallery is present, dismisses it
 *
 *  @param animated Whether the dismiss transition is animated
 */
- (void)dismiss:(BOOL)animated;

@end
