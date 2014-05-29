//
// Created by Joakim Gyllström on 2014-05-29.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSZoomOutAnimator.h"
#import "BSPhotosController.h"


@implementation BSZoomOutAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    BSPhotosController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    BSPreviewController*fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    [[transitionContext containerView] addSubview:toViewController.view];
    [[transitionContext containerView] addSubview:fromViewController.view];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.transform = CGAffineTransformMakeScale(0.0, 0.0);
        fromViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        fromViewController.view.alpha = 1.0;

    }];

}

@end