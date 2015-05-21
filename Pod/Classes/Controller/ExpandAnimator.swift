//
//  ExpandAnimator.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-05-17.
//
//

import UIKit
import UIImageViewModeScaleAspect

internal class ExpandAnimator : NSObject, UIViewControllerAnimatedTransitioning {
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
            if destinationImageView.contentMode == .ScaleAspectFit {
                scalingImage.initToScaleAspectFitToFrame(destinationImageView.frame)
            } else {
                scalingImage.initToScaleAspectFillToFrame(destinationImageView.frame)
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
                    scalingImage.animaticToScaleAspectFit()
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
    }
}
