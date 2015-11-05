#import "UCDirectionalPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface UCDirectionalPanGestureRecognizer () {
    CGPoint _startPoint;
    NSTimeInterval _lastTimestamp;
    CGPoint _lastPosition;
}

@end

@implementation UCDirectionalPanGestureRecognizer

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    if (self.state == UIGestureRecognizerStateBegan) {
        CGPoint velocity = [self velocityInView:self.view];
        switch (self.direction) {
            case UCGestureRecognizerDirectionVertical:
                if (fabs(velocity.x) > fabs(velocity.y)) {
                    self.state = UIGestureRecognizerStateCancelled;
                }
                break;
            case UCGestureRecognizerDirectionHorizontal:
                if (fabs(velocity.y) > fabs(velocity.x)) {
                    self.state = UIGestureRecognizerStateCancelled;
                }
                break;
            default:
                break;
        }
    }
}

@end
