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
import PhotosUI
import CoreLocation

class PreviewViewController : UIViewController {
    var asset: PHAsset? {
        didSet {
            updateNavigationTitle()
            
            guard let asset = asset else {
                imageView.image = nil
                return
            }
            loadPhoto(from: asset)
        }
    }
    let imageView: UIImageView = UIImageView(frame: .zero)
    let livePhotoView: PHLivePhotoView = PHLivePhotoView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let geoCoder = CLGeocoder()
    let scale: CGFloat
    
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
        self.scale = UIScreen.main.scale
        super.init(nibName: nil, bundle: nil)

        [imageView, livePhotoView].forEach { subview in
            subview.frame = view.bounds
            subview.contentMode = .scaleAspectFit
            subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(subview)
        }

        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.addTarget(self, action: #selector(PreviewViewController.toggleFullscreen))
        view.addGestureRecognizer(tapRecognizer)

        // Use the custom long press recognizer instead of the build-in one
        // so that it plays nicely with the tap recognizer to toggle full screen.
        // Had some issue the build-in one work well with the tap recognizer.
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.addTarget(self, action: #selector(PreviewViewController.playLivePhoto))
        livePhotoView.addGestureRecognizer(longPressRecognizer)
        livePhotoView.playbackGestureRecognizer.isEnabled = false
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

    @objc func playLivePhoto() {
        livePhotoView.startPlayback(with: .full)
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

    private func loadPhoto(from asset: PHAsset) {
        if asset.mediaSubtypes.contains(.photoLive) {
            let options = PHLivePhotoRequestOptions()

            // Load live photo for preview
            let targetSize = livePhotoView.frame.size.resize(by: scale)
            PHCachingImageManager.default().requestLivePhoto(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (livePhoto, _)  in
                self.livePhotoView.livePhoto = livePhoto
            }
        } else {
            // Setup fetch options to be synchronous
            let options = PHImageRequestOptions()
            options.isSynchronous = true

            // Load image for preview
            let targetSize = imageView.frame.size.resize(by: scale)
            PHCachingImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, _) in
                self.imageView.image = image
            }
        }
    }
}
