//
// Created by Joakim Gyllström on 2014-05-29.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSZoomInAnimator.h"
#import "BSPhotosController.h"

@implementation BSZoomInAnimator

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.8;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    BSPreviewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    BSPhotosController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    //Disable selection so we don't select a cell while the push animation is running
    [fromViewController.collectionView setAllowsSelection:NO];

    [[transitionContext containerView] addSubview:toViewController.view];

    toViewController.collectionView.transform = CGAffineTransformMakeScale(0.1, 0.1);

    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.0
                        options:0
                     animations:^{
        toViewController.collectionView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        fromViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        fromViewController.view.alpha = 1.0;

        //Allow selection again
        [fromViewController.collectionView setAllowsSelection:YES];
    }];
}

@end