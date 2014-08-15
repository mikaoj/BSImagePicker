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

#import "BSExpandAnimator.h"
#import "BSPhotosController.h"
#import "BSPhotoCell.h"
#import "BSCollectionController+UICollectionView.h"
#import "UIImageViewModeScaleAspect.h"

@implementation BSExpandAnimator

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    BSPreviewController *toViewController = (BSPreviewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    BSPhotosController *fromViewController = (BSPhotosController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];

    //Disable selection so we don't select a cell while the push animation is running
    [fromViewController setDisableSelection:YES];
    
    //Get cells
    BSPhotoCell *fromCell = (BSPhotoCell *)[fromViewController.collectionView cellForItemAtIndexPath:toViewController.currentIndexPath];
    BSPhotoCell *toCell = (BSPhotoCell *)[toViewController collectionView:toViewController.collectionView cellForItemAtIndexPath:toViewController.currentIndexPath];
    
    //Setup views
    [fromCell.imageView setHidden:YES];
    [toViewController.view setHidden:YES];
    
    //Setup scaling image
    UIImageViewModeScaleAspect *scalingImage = [[UIImageViewModeScaleAspect alloc] initWithFrame:[containerView convertRect:fromCell.imageView.frame fromView:fromCell.imageView.superview]];
    [scalingImage setContentMode:UIViewContentModeScaleAspectFill];
    [scalingImage setImage:toCell.imageView.image];
    
    //Init image scale
    [scalingImage initToScaleAspectFitToFrame:CGRectMake(0, fromViewController.navigationController.navigationBar.frame.origin.y + fromViewController.navigationController.navigationBar.frame.size.height, toCell.imageView.frame.size.width, toCell.imageView.frame.size.height)];
    
    //Add views to container view
    [containerView addSubview:toViewController.view];
    [containerView addSubview:scalingImage];
    
    //Animate
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [fromViewController.view setAlpha:0.0];
                         [scalingImage animaticToScaleAspectFit];
                     } completion:^(BOOL finished) {
                         //Finish image scaling and remove image view
                         [scalingImage animateFinishToScaleAspectFit];
                         [scalingImage removeFromSuperview];
                         
                         //Unhide
                         [fromCell.imageView setHidden:NO];
                         [toViewController.view setHidden:NO];
                         [fromViewController.view setAlpha:1.0];
                         
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         
                         //Enable selection
                         [fromViewController setDisableSelection:NO];
                     }];
}

@end