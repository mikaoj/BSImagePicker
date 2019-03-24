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
            PHCachingImageManager.default().requestImage(for: asset, targetSize: imageView.frame.size, contentMode: .aspectFit, options: options) { (image, _) in
                self.imageView.image = image
            }
        }
    }
    let imageView: UIImageView = UIImageView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let geoCoder = CLGeocoder()
    
    var fullscreen = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.updateNavigationBar()
                self.updateStatusBar()
                self.updateBackgroundColor()
            }
        }
    }

    override var prefersStatusBarHidden : Bool {
        return fullscreen
    }

    required init() {
        super.init(nibName: nil, bundle: nil)

        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)

        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.addTarget(self, action: #selector(PreviewViewController.toggleFullscreen))
        view.addGestureRecognizer(tapRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateBackgroundColor()
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }
    
    @objc func toggleFullscreen() {
        fullscreen = !fullscreen
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
