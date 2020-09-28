// The MIT License (MIT)
//
// Copyright (c) 2019 Joakim Gyllström
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

import Foundation
import UIKit

class DropdownPresentationController: UIPresentationController {
    private let dropDownHeight: CGFloat = 200
    private let backgroundView = UIView()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.backgroundColor = .clear
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:))))
    }
    
    @objc func backgroundTapped(_ recognizer: UIGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        containerView.insertSubview(backgroundView, at: 0)
        backgroundView.frame = containerView.bounds
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: dropDownHeight)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView,
            let presentingView = presentingViewController.view else { return .zero }

        let size = self.size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: presentingView.bounds.size)

        let position: CGPoint
        if let navigationBar = (presentingViewController as? UINavigationController)?.navigationBar {
            // We can't use the frame directly since iOS 13 new modal presentation style
            let navigationRect = navigationBar.convert(navigationBar.bounds, to: nil)
            let presentingRect = presentingView.convert(presentingView.frame, to: containerView)
            position = CGPoint(x: presentingRect.origin.x, y: presentingRect.origin.y + navigationRect.height)

            // Match color with navigation bar
            presentedViewController.view.backgroundColor = navigationBar.barTintColor
        } else {
            position = .zero
        }

        return CGRect(origin: position, size: size)
    }
}
