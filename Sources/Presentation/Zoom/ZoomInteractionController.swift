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

import UIKit

class ZoomInteractionController: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
    private weak var navigationController: UINavigationController?
    private var containerView: UIView!
    private var sourceView: UIView!
    private var destinationView: UIView!
    private var hasCompleted = false
    private let separationView = UIView()
    private var transform: CGAffineTransform!
    private let threshold: CGFloat = 70 // How many pixels for swipe to dismiss
    
    override init() {
        super.init()
        wantsInteractiveStart = false
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        let viewController = transitionContext.viewController(forKey: .to)
        setupGestureRecognizer(in: viewController?.view)
        navigationController = viewController?.navigationController

        sourceView = transitionContext.view(forKey: .to)
        destinationView = transitionContext.view(forKey: .from)
        containerView = transitionContext.containerView
        transform = sourceView.transform
    }
    
    private func setupGestureRecognizer(in view: UIView?) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        gesture.delegate = self
        view?.addGestureRecognizer(gesture)
    }
    
    private var f: CGRect = .zero
    @objc func handlePan(_ panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .began:
            begin()
        case .changed:
            let translation = panRecognizer.translation(in: panRecognizer.view!.superview!)
            update(translation: translation)
        case .cancelled:
            cancel()
        case .ended:
            if hasCompleted {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        return translation(for: pan).y >= 0
    }
    
    private func translation(for pan: UIPanGestureRecognizer) -> CGPoint {
        return pan.translation(in: pan.view!.superview!)
    }
    
    private func percentDone(translation: CGPoint) -> CGFloat {
        guard translation.y > 0 else { return 0 }
        let progress = translation.y / threshold
        return min(progress, 1)
    }
    
    func begin() {
        containerView.addSubview(destinationView)
        containerView.addSubview(separationView)
        containerView.bringSubviewToFront(sourceView)
        separationView.backgroundColor = sourceView.backgroundColor
        separationView.frame = destinationView.frame
        sourceView.backgroundColor = sourceView.backgroundColor?.withAlphaComponent(0)
        transform = sourceView.transform
    }
    
    override func cancel() {
        super.cancel()
        sourceView.backgroundColor = sourceView.backgroundColor?.withAlphaComponent(1)
        sourceView.transform = transform
        destinationView.removeFromSuperview()
        separationView.removeFromSuperview()
    }
    
    override func finish() {
        super.finish()
        navigationController?.popViewController(animated: true)
    }
    
    func update(translation: CGPoint) {
        let progress = percentDone(translation: translation)
        super.update(progress)
        let y = translation.y > 0 ? translation.y : 0
        let scale = 1 - (y / destinationView.frame.size.height)
        let translateX = translation.x / scale
        let translateY = translation.y / scale
        sourceView.transform = CGAffineTransform.init(translationX: translateX, y: translateY).concatenating(CGAffineTransform.init(scaleX: scale, y: scale))
        separationView.backgroundColor = separationView.backgroundColor?.withAlphaComponent(scale)
        hasCompleted = progress == 1
    }
}
