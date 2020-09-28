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
    private let imageManager = PHCachingImageManager.default()
    var settings: Settings!

    var asset: PHAsset? {
        didSet {
            updateNavigationTitle()
            
            guard let asset = asset else {
                imageView.image = nil
                return
            }
            
            // Load image for preview
            imageManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: settings.fetch.preview.photoOptions) { [weak self] (image, _) in
                guard let image = image else { return }
                self?.imageView.image = image
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

    let scrollView = UIScrollView(frame: .zero)
    let singleTapRecognizer = UITapGestureRecognizer()
    let doubleTapRecognizer = UITapGestureRecognizer()
    private let titleLabel = UILabel(frame: .zero)

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
        if #available(iOS 11.0, *) {
            // Allows the imageview to be 'under' the navigation bar
            scrollView.contentInsetAdjustmentBehavior = .never
        }
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

    private func setupTitleLabel() {
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byClipping
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateBackgroundColor()
        setupTitleLabel()
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
        guard let zoomView = viewForZooming(in: scrollView) else { return .zero }
        let newCenter = scrollView.convert(center, from: zoomView)

        var zoomRect = CGRect.zero
        zoomRect.size.height = zoomView.frame.size.height / scale
        zoomRect.size.width = zoomView.frame.size.width / scale
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
        
        if self.fullscreen && modalPresentationStyle == .fullScreen {
            aColor = UIColor.black
        } else {
            aColor = UIColor.systemBackgroundColor
        }
        
        view.backgroundColor = aColor
    }
    
    private func updateNavigationTitle() {
        guard let asset = asset else { return }
        
        PreviewTitleBuilder.titleFor(asset: asset,using:settings.theme) { [weak self] (text) in
            self?.titleLabel.attributedText = text
            self?.titleLabel.sizeToFit()
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
            guard let zoomView = viewForZooming(in: scrollView) else { return }

            let widthRatio = zoomView.frame.width / image.size.width
            let heightRatio = zoomView.frame.height / image.size.height

            let ratio = widthRatio < heightRatio ? widthRatio:heightRatio

            let newWidth = image.size.width * ratio
            let newHeight = image.size.height * ratio

            let left = 0.5 * (newWidth * scrollView.zoomScale > zoomView.frame.width ? (newWidth - zoomView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
            let top = 0.5 * (newHeight * scrollView.zoomScale > zoomView.frame.height ? (newHeight - zoomView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))

            scrollView.contentInset = UIEdgeInsets(top: top.rounded(), left: left.rounded(), bottom: top.rounded(), right: left.rounded())
        } else {
            scrollView.contentInset = .zero
        }
    }
}
