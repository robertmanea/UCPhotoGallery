//
//  ViewController.m
//  UCDirectionalPanGestureRecognizerExample
//
//  Created by Bryan Oltman on 11/5/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import "ViewController.h"
#import "UCDirectionalPanGestureRecognizer.h"

@interface ViewController ()
@property UCDirectionalPanGestureRecognizer *panRecognizer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.panRecognizer = [[UCDirectionalPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(viewPanned:)];
    self.panRecognizer.direction = UCGestureRecognizerDirectionVertical;
    [self.view addGestureRecognizer:self.panRecognizer];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(directionLabelTapped:)];
    [self.directionLabel addGestureRecognizer:tapRecognizer];
    self.directionLabel.userInteractionEnabled = YES;

    BOOL isHorizontal = self.panRecognizer.direction == UCGestureRecognizerDirectionHorizontal;
    self.directionLabel.text = [NSString stringWithFormat:@"Direction: %@", (isHorizontal ? @"Horizontal" : @"Vertical")];
    self.velocityLabel.text = @"Velocity: N/A";
    self.translationLabel.text = @"Translation: N/A";
}

- (void)viewPanned:(UCDirectionalPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];

    CGFloat translationDimension = (recognizer.direction == UCGestureRecognizerDirectionHorizontal ?
                                    translation.x : translation.y);
    CGFloat velocityDimension = (recognizer.direction == UCGestureRecognizerDirectionHorizontal ?
                                 velocity.x : velocity.y);

    switch (recognizer.state) {
        case UIGestureRecognizerStateChanged: {
            self.velocityLabel.text = [NSString stringWithFormat:@"Velocity: %.02f", velocityDimension];
            self.translationLabel.text = [NSString stringWithFormat:@"Translation: %.02f", translationDimension];
        }
            break;

        case UIGestureRecognizerStateEnded:
            self.velocityLabel.text = @"Velocity: N/A";
            self.translationLabel.text = @"Translation: N/A";
            break;

        default:
            break;
    }
}

- (void)directionLabelTapped:(id)recognizer {
    BOOL isHorizontal = self.panRecognizer.direction == UCGestureRecognizerDirectionHorizontal;
    self.panRecognizer.direction = (isHorizontal ?
                                    UCGestureRecognizerDirectionVertical :
                                    UCGestureRecognizerDirectionHorizontal);
    self.directionLabel.text = [NSString stringWithFormat:@"Direction: %@", (isHorizontal ? @"Vertical" : @"Horizontal")];
}

@end
