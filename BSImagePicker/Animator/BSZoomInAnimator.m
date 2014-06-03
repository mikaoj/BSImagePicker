// The MIT License (MIT)
//
// Copyright (c) 2014 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "BSZoomInAnimator.h"
#import "BSPhotosController.h"

@implementation BSZoomInAnimator

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    BSPreviewController *toViewController = (BSPreviewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    BSPhotosController *fromViewController = (BSPhotosController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    //Disable selection so we don't select a cell while the push animation is running
    [fromViewController.collectionView setAllowsSelection:NO];

    [[transitionContext containerView] addSubview:toViewController.view];

    CGAffineTransform origTransform = toViewController.collectionView.transform;

    CGPoint center = toViewController.view.center;
    [toViewController.collectionView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.01, 0.01), CGAffineTransformMakeTranslation(CGRectGetMidX(self.animateFromRect)-center.x, (self.animateFromRect.origin.y+self.animateFromRect.size.height)-center.y))];

    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.0
                        options:0
                     animations:^{
        toViewController.collectionView.transform = origTransform;
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