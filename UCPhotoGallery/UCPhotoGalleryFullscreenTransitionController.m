#import "UCPhotoGalleryFullscreenTransitionController.h"
#import "UCPhotoGalleryViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation UCPhotoGalleryFullscreenTransitionController

- (NSTimeInterval)transitionDuration:(__unused id <UIViewControllerContextTransitioning>)transitionContext {
    if (!self.transitionImage) {
        return 0;
    }

    return 0.35f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context {
    UIView *containerView = [context containerView];
    UIViewController *fromController = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *shadowboxView = ({
        UIView *view = [[UIView alloc] initWithFrame:containerView.bounds];
        [containerView addSubview:view];
        view;
    });

    const BOOL isUnwinding = [toController presentedViewController] == fromController;
    const BOOL isPresenting = !isUnwinding;

    UCPhotoGalleryViewController *fullscreenGalleryController =
        (UCPhotoGalleryViewController *)(isPresenting ? toController : fromController);

    UIImageView *transitionImageView = [[UIImageView alloc] initWithImage:self.transitionImage];
    transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
    transitionImageView.clipsToBounds = YES;
    CGRect startRect, endRect;
    fullscreenGalleryController.view.alpha = 0;
    if (isPresenting) {
        [containerView addSubview:fullscreenGalleryController.view];

        shadowboxView.backgroundColor = [UIColor blackColor];
        shadowboxView.alpha = 0;

        startRect = self.presentFromRect;
        if (self.transitionImage) {
            endRect = AVMakeRectWithAspectRatioInsideRect(self.transitionImage.size, containerView.bounds);
        }
        transitionImageView.frame = startRect;
//        NSLog(@"in start:%@ end:%@", NSStringFromCGRect(startRect), NSStringFromCGRect(endRect));
        [containerView addSubview:transitionImageView];

        [UIView animateWithDuration:[self transitionDuration:context]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             transitionImageView.frame = endRect;
                             shadowboxView.alpha = 1;
                         } completion:^(BOOL finished) {
                             fullscreenGalleryController.view.alpha = 1;
                             [transitionImageView removeFromSuperview];
                             [shadowboxView removeFromSuperview];
                             [context completeTransition:finished];
                         }];
    } else {
        shadowboxView.backgroundColor = [fullscreenGalleryController.view backgroundColor];

        if (self.transitionImage) {
            startRect = AVMakeRectWithAspectRatioInsideRect(self.transitionImage.size, containerView.bounds);
            startRect = CGRectOffset(startRect, 0, [fullscreenGalleryController visibleItem].transform.ty);
        }

        endRect = self.presentFromRect;
        transitionImageView.frame = startRect;
//        NSLog(@"out start:%@ end:%@", NSStringFromCGRect(startRect), NSStringFromCGRect(endRect));
        [containerView addSubview:transitionImageView];

        [UIView animateWithDuration:[self transitionDuration:context]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             shadowboxView.alpha = 0;
                             transitionImageView.frame = endRect;
                         }
                         completion:^(BOOL finished) {
                             [transitionImageView removeFromSuperview];
                             [shadowboxView removeFromSuperview];
                             [context completeTransition:finished];
                         }];
    }
}

@end
