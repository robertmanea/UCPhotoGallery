//
//  Created by Bryan Oltman on 11/4/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UCGestureRecognizerDirection) {
    UCGestureRecognizerDirectionHorizontal,
    UCGestureRecognizerDirectionVertical
};

@interface UCDirectionalPanGestureRecognizer : UIPanGestureRecognizer

/**
 *  The supported panning direction
 */
@property (assign, nonatomic) UCGestureRecognizerDirection direction;

@end
