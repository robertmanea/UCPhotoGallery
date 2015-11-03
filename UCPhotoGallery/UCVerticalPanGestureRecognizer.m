#import "UCVerticalPanGestureRecognizer.h"

@interface UCVerticalPanGestureRecognizer () {
    CGPoint _startPoint;
}

@end

@implementation UCVerticalPanGestureRecognizer
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] > 1) {
        self.state = UIGestureRecognizerStateFailed;
    } else {
        _startPoint = [[touches anyObject] locationInView:self.view];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.state == UIGestureRecognizerStateFailed || self.state == UIGestureRecognizerStateCancelled) {
        return;
    }

    CGPoint currentLocation = [[touches anyObject] locationInView:self.view];
    CGPoint translation;
    translation.x = currentLocation.x - _startPoint.x;
    translation.y = currentLocation.y - _startPoint.y;

    if (self.state == UIGestureRecognizerStatePossible) {
        if (fabs(translation.x) > self.offsetThreshold) {
            // If the x-translation is above our threshold the gesture fails
            self.state = UIGestureRecognizerStateFailed;
        } else if (fabs(translation.y) > self.offsetThreshold) {
            // If the y-translation has reached the threshold the gesture is recognized
            // and the we start sending action methods
            self.state = UIGestureRecognizerStateBegan;
        }

        return;
    }

    // If we reached this point the gesture was succesfully recognized so we now enter changed state
    self.state = UIGestureRecognizerStateChanged;

    // We are just insterested in the vertical translation
    self.translation = translation.y;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // If at this point the state is still 'possible' the threshold wasn't reached at all so we fail
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateFailed;
    } else {
        CGPoint currentLocation = [[touches anyObject] locationInView:self.view];
        CGPoint translation;
        translation.x = _startPoint.x - currentLocation.x;
        translation.y = _startPoint.y - currentLocation.y;
        self.translation = translation.y;
        self.state = UIGestureRecognizerStateEnded;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)reset {
    [super reset];
    _startPoint = CGPointZero;
}

@end
