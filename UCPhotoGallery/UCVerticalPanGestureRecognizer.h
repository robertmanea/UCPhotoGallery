//
//  Created by Bryan Oltman on 10/30/15.
//  Copyright © 2015 Compass. All rights reserved.
//  Taken from http://stackoverflow.com/questions/16003613/ive-made-uipangesturerecognizer-only-detect-mostly-vertical-pans-how-do-i-make
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface UCVerticalPanGestureRecognizer : UIGestureRecognizer

/**
 *  The vertical translation in the host view (analog to translationInView:).
 */
@property (assign, nonatomic) float translation;

/**
 *  The amount of horizontal movement allowed before this recogznier fails AND the amount of 
 *  vertical movement required before the recognizer is triggered.
 */
@property (assign, nonatomic) float offsetThreshold;

@end
