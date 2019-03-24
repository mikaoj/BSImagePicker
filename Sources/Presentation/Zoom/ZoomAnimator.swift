// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
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

import UIKit
import BSImageView

final class ZoomAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    enum Mode {
        case expand
        case shrink
    }

    var sourceImageView: UIImageView?
    var destinationImageView: UIImageView?
    let mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if mode == .expand {
            return 0.4
        } else {
            return 0.2
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Get to and from view controller
        if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to), let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from), let sourceImageView = sourceImageView, let destinationImageView = destinationImageView {
            let containerView = transitionContext.containerView
            
            // Setup views
            sourceImageView.isHidden = true
            destinationImageView.isHidden = true
            toViewController.view.alpha = 0.0
            fromViewController.view.alpha = 1.0
            containerView.backgroundColor = toViewController.view.backgroundColor
            
            // Setup scaling image
            let scalingFrame = containerView.convert(sourceImageView.frame, from: sourceImageView.superview)
            let scalingImage = BSImageView(frame: scalingFrame)
            scalingImage.contentMode = sourceImageView.contentMode
            scalingImage.clipsToBounds = true
            if mode == .expand {
                scalingImage.image = destinationImageView.image
            } else {
                scalingImage.image = sourceImageView.image
            }
            
            //Init image scale
            let destinationFrame = containerView.convert(destinationImageView.frame, from: destinationImageView.superview)
            
            // Add views to container view
            containerView.addSubview(toViewController.view)
            containerView.addSubview(scalingImage)
            
            // Animate
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                delay: 0.0,
                options: [],
                animations: { () -> Void in
                    // Fade in
                    fromViewController.view.alpha = 0.0
                    toViewController.view.alpha = 1.0
                    
                    scalingImage.frame = destinationFrame
                    scalingImage.contentMode = destinationImageView.contentMode
                }, completion: { (finished) -> Void in
                    scalingImage.removeFromSuperview()
                    
                    // Unhide
                    destinationImageView.isHidden = false
                    fromViewController.view.alpha = 1.0
                    
                    // Finish transition
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
