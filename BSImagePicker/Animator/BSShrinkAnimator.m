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

#import "BSShrinkAnimator.h"
#import "BSPhotosController.h"
#import "BSPhotoCell.h"
#import "BSCollectionController+UICollectionView.h"
#import "UIImageViewModeScaleAspect.h"
#import "BSItemsModel.h"

@implementation BSShrinkAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    BSPhotosController *toViewController = (BSPhotosController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    BSPreviewController *fromViewController = (BSPreviewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    //Disable selection so we don't select a cell while the push animation is running
    [fromViewController.collectionView setAllowsSelection:NO];
    
    //Get cells
    BSPhotoCell *fromCell = (BSPhotoCell *)[fromViewController.collectionView cellForItemAtIndexPath:fromViewController.currentIndexPath];
    BSPhotoCell *toCell = (BSPhotoCell *)[toViewController.collectionView cellForItemAtIndexPath:fromViewController.currentIndexPath];
    
    //Setup views
    [toCell setHidden:YES];
    [fromCell.imageView setHidden:YES];
    
    UIImageView *iv = fromCell.imageView;
    CGSize imageSize = iv.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(iv.bounds)/imageSize.width, CGRectGetHeight(iv.bounds)/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(roundf(0.5f*(CGRectGetWidth(iv.bounds)-scaledImageSize.width)), roundf(0.5f*(CGRectGetHeight(iv.bounds)-scaledImageSize.height)), roundf(scaledImageSize.width), roundf(scaledImageSize.height));
    CGRect scaledFrame = CGRectMake((fromCell.frame.size.width-imageFrame.size.width)/2.0, (fromCell.frame.size.height-imageFrame.size.height)/2.0, imageFrame.size.width, imageFrame.size.height);
    
    //Setup scaling image
    UIImageViewModeScaleAspect *scalingImage = [[UIImageViewModeScaleAspect alloc] initWithFrame:[containerView convertRect:scaledFrame fromView:fromCell.imageView.superview]];
    [scalingImage setContentMode:UIViewContentModeScaleAspectFill];
    [scalingImage setImage:fromCell.imageView.image];
    [scalingImage setClipsToBounds:YES];
    
    //Add views to container view
    [containerView addSubview:toViewController.view];
    [containerView addSubview:scalingImage];
    [toViewController.view setAlpha:0.0];

    //Init image scale
    [scalingImage initToScaleAspectFillToFrame:[containerView convertRect:toCell.frame fromView:toCell.superview]];

    //Animate
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                             [toViewController.view setAlpha:1.0];
                         [scalingImage animaticToScaleAspectFill];
                     } completion:^(BOOL finished) {
                         //Finish image scaling and remove image view
                         [scalingImage animateFinishToScaleAspectFill];
                         [scalingImage removeFromSuperview];
                         
                         //Unhide
                         [fromCell.imageView setHidden:NO];
                         [toCell setHidden:NO];
                         
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         
                         //Enable selection
                         [fromViewController.collectionView setAllowsSelection:YES];
                     }];
}

@end