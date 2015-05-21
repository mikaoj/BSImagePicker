//
//  ShrinkAnimator.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-05-17.
//
//

import UIKit
import UIImageViewModeScaleAspect

internal class ShrinkAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    internal var sourceImageView: UIImageView?
    internal var destinationImageView: UIImageView?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 2.0
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // Get to and from view controller
        if let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey), let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey), let sourceImageView = sourceImageView, let destinationImageView = destinationImageView {
            // Disable selection so we don't select anything while the push animation is running
            fromViewController.view?.userInteractionEnabled = false
            
            // Get views
            let containerView = transitionContext.containerView()
            
            // Setup views
            sourceImageView.hidden = true
            destinationImageView.hidden = true
            toViewController.view.alpha = 0.0
            fromViewController.view.alpha = 1.0
            containerView.backgroundColor = toViewController.view.backgroundColor
            
            // Setup scaling image
            let scalingFrame = containerView.convertRect(sourceImageView.frame, fromView: sourceImageView.superview)
            let scalingImage = UIImageViewModeScaleAspect(frame: scalingFrame)
            scalingImage.contentMode = sourceImageView.contentMode
            scalingImage.image = sourceImageView.image
            
            //Init image scale
            let destinationFrame = containerView.convertRect(destinationImageView.frame, fromView: destinationImageView.superview)
            if destinationImageView.contentMode == .ScaleAspectFit {
                scalingImage.initToScaleAspectFitToFrame(destinationFrame)
            } else {
                scalingImage.initToScaleAspectFillToFrame(destinationFrame)
            }
            
            // Add views to container view
            containerView.addSubview(toViewController.view)
            containerView.addSubview(scalingImage)
            
            // Animate
            UIView.animateWithDuration(transitionDuration(transitionContext),
                delay: 0.0,
                options: UIViewAnimationOptions.TransitionNone,
                animations: { () -> Void in
                    // Fade in
                    fromViewController.view.alpha = 0.0
                    toViewController.view.alpha = 1.0
                    
                    if destinationImageView.contentMode == .ScaleAspectFit {
                        scalingImage.animaticToScaleAspectFit()
                    } else {
                        scalingImage.animaticToScaleAspectFill()
                    }
                }, completion: { (finished) -> Void in
                    
                    // Finish image scaling and remove image view
                    if destinationImageView.contentMode == .ScaleAspectFit {
                        scalingImage.animateFinishToScaleAspectFit()
                    } else {
                        scalingImage.animateFinishToScaleAspectFill()
                    }
                    scalingImage.removeFromSuperview()
                    
                    // Unhide
                    destinationImageView.hidden = false
                    sourceImageView.hidden = false
                    fromViewController.view.alpha = 1.0
                    
                    // Finish transition
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                    
                    // Enable selection again
                    fromViewController.view?.userInteractionEnabled = true
            })
        }
//        BSPhotosController *toViewController = (BSPhotosController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//        BSPreviewController *fromViewController = (BSPreviewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//        UIView *containerView = [transitionContext containerView];
//        
//        //Disable selection so we don't select a cell while the push animation is running
//        [fromViewController.collectionView setAllowsSelection:NO];
//        
//        //Get cells
//        BSPhotoCell *fromCell = (BSPhotoCell *)[fromViewController.collectionView cellForItemAtIndexPath:fromViewController.currentIndexPath];
//        BSPhotoCell *toCell = (BSPhotoCell *)[toViewController.collectionView cellForItemAtIndexPath:fromViewController.currentIndexPath];
//        
//        //Setup views
//        [toCell setHidden:YES];
//        [fromCell.imageView setHidden:YES];
//        
//        UIImageView *iv = fromCell.imageView;
//        CGSize imageSize = iv.image.size;
//        CGFloat imageScale = fminf(CGRectGetWidth(iv.bounds)/imageSize.width, CGRectGetHeight(iv.bounds)/imageSize.height);
//        CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
//        CGRect imageFrame = CGRectMake(roundf(0.5f*(CGRectGetWidth(iv.bounds)-scaledImageSize.width)), roundf(0.5f*(CGRectGetHeight(iv.bounds)-scaledImageSize.height)), roundf(scaledImageSize.width), roundf(scaledImageSize.height));
//        CGRect scaledFrame = CGRectMake((fromCell.frame.size.width-imageFrame.size.width)/2.0, (fromCell.frame.size.height-imageFrame.size.height)/2.0, imageFrame.size.width, imageFrame.size.height);
//        
//        //Setup scaling image
//        UIImageViewModeScaleAspect *scalingImage = [[UIImageViewModeScaleAspect alloc] initWithFrame:[containerView convertRect:scaledFrame fromView:fromCell.imageView.superview]];
//        [scalingImage setContentMode:UIViewContentModeScaleAspectFill];
//        [scalingImage setImage:fromCell.imageView.image];
//        [scalingImage setClipsToBounds:YES];
//        
//        //Add views to container view
//        [containerView addSubview:toViewController.view];
//        [containerView addSubview:scalingImage];
//        [toViewController.view setAlpha:0.0];
//        
//        //Init image scale
//        [scalingImage initToScaleAspectFillToFrame:[containerView convertRect:toCell.frame fromView:toCell.superview]];
//        
//        //Animate
//        [UIView animateWithDuration:[self transitionDuration:transitionContext]
//            delay:0.0
//            options:UIViewAnimationOptionAllowUserInteraction
//            animations:^{
//            [toViewController.view setAlpha:1.0];
//            [scalingImage animaticToScaleAspectFill];
//            } completion:^(BOOL finished) {
//            //Finish image scaling and remove image view
//            [scalingImage animateFinishToScaleAspectFill];
//            [scalingImage removeFromSuperview];
//            
//            //Unhide
//            [fromCell.imageView setHidden:NO];
//            [toCell setHidden:NO];
//            
//            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//            
//            //Enable selection
//            [fromViewController.collectionView setAllowsSelection:YES];
//            }];
    }
}
