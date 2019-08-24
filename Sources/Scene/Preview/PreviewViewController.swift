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
import Photos
import CoreLocation

class PreviewViewController : UIViewController {
    var asset: PHAsset? {
        didSet {
            updateNavigationTitle()
            
            guard let asset = asset else {
                imageView.image = nil
                return
            }
            
            // Setup fetch options to be synchronous
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            
            // Load image for preview
            let targetSize = imageView.frame.size.resize(by: UIScreen.main.scale)
            PHCachingImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, _) in
                self.imageView.image = image
            }
        }
    }
    let imageView: UIImageView = UIImageView(frame: .zero)
    
    var fullscreen = false {
        didSet {
            guard oldValue != fullscreen else { return }
            UIView.animate(withDuration: 0.3) {
                self.updateNavigationBar()
                self.updateStatusBar()
                self.updateBackgroundColor()
            }
        }
    }

    private let titleLabel = UILabel(frame: .zero)
    private let scrollView = UIScrollView(frame: .zero)
    private let singleTapRecognizer = UITapGestureRecognizer()
    private let doubleTapRecognizer = UITapGestureRecognizer()

    override var prefersStatusBarHidden : Bool {
        return fullscreen
    }

    required init() {
        super.init(nibName: nil, bundle: nil)
        setupScrollView()
        setupImageView()
        setupSingleTapRecognizer()
        setupDoubleTapRecognizer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.contentInsetAdjustmentBehavior = .never // Allows the imageview to be 'under' the navigation bar
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
    }

    private func setupImageView() {
        imageView.frame = scrollView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
    }

    private func setupSingleTapRecognizer() {
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.addTarget(self, action: #selector(didSingleTap(_:)))
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
        view.addGestureRecognizer(singleTapRecognizer)
    }

    private func setupDoubleTapRecognizer() {
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.addTarget(self, action: #selector(didDoubleTap(_:)))
        view.addGestureRecognizer(doubleTapRecognizer)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateBackgroundColor()
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fullscreen = false
    }
    
    private func toggleFullscreen() {
        fullscreen = !fullscreen
    }

    @objc func didSingleTap(_ recognizer: UIGestureRecognizer) {
        toggleFullscreen()
    }

    @objc func didDoubleTap(_ recognizer: UIGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        } else {
            scrollView.zoom(to: zoomRect(scale: 2, center: recognizer.location(in: recognizer.view)), animated: true)
        }
    }

    private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        let newCenter = scrollView.convert(center, from: imageView)

        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)

        return zoomRect
    }
    
    private func updateNavigationBar() {
        navigationController?.setNavigationBarHidden(fullscreen, animated: true)
    }
    
    private func updateStatusBar() {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    private func updateBackgroundColor() {
        let aColor: UIColor
        
        if self.fullscreen {
            aColor = UIColor.black
        } else {
            aColor = UIColor.white
        }
        
        view.backgroundColor = aColor
    }
    
    private func updateNavigationTitle() {
        guard let asset = asset else { return }
        
        PreviewTitleBuilder.titleFor(asset: asset) { (text) in
            self.titleLabel.attributedText = text
            self.titleLabel.sizeToFit()
        }
    }
}

extension PreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            fullscreen = true

            guard let image = imageView.image else { return }

            let widthRatio = imageView.frame.width / image.size.width
            let heightRatio = imageView.frame.height / image.size.height

            let ratio = widthRatio < heightRatio ? widthRatio:heightRatio

            let newWidth = image.size.width * ratio
            let newHeight = image.size.height * ratio

            let left = 0.5 * (newWidth * scrollView.zoomScale > imageView.frame.width ? (newWidth - imageView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
            let top = 0.5 * (newHeight * scrollView.zoomScale > imageView.frame.height ? (newHeight - imageView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))

            scrollView.contentInset = UIEdgeInsets(top: top.rounded(), left: left.rounded(), bottom: top.rounded(), right: left.rounded())
        } else {
            scrollView.contentInset = .zero
        }
    }
}
