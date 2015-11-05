//
//  UCDirectionalPanGestureRecognizer.h
//  UCDirectionalPanGestureRecognizer
//
//  Created by Bryan Oltman on 11/5/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for UCDirectionalPanGestureRecognizer.
FOUNDATION_EXPORT double UCDirectionalPanGestureRecognizerVersionNumber;

//! Project version string for UCDirectionalPanGestureRecognizer.
FOUNDATION_EXPORT const unsigned char UCDirectionalPanGestureRecognizerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <UCDirectionalPanGestureRecognizer/PublicHeader.h>

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

