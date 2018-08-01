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

extension UIButton {
    func setAlbumTitle(_ title: String) {
        guard let imageView = imageView, let titleLabel = titleLabel else  { return }
        // Set image
        setImage(arrowDownImage, for: .normal)
        
        // Set title on button
        setTitle(title, for: .normal)

        // Also set title directly to label, since it isn't done right away when setting button title
        // And we need to know its width to calculate insets
        titleLabel.text = title
        titleLabel.sizeToFit()

        // Adjust insets to right align image
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView.bounds.size.width, bottom: 0, right: imageView.bounds.size.width)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: titleLabel.bounds.size.width + 12, bottom: 0, right: -(titleLabel.bounds.size.width + 12))
    }
    
    private var arrowDownImage: UIImage? {
        // Get path for BSImagePicker bundle
        let bundlePath = Bundle(for: PhotosViewController.self).path(forResource: "BSImagePicker", ofType: "bundle")
        let bundle: Bundle?
        
        // Load bundle
        if let bundlePath = bundlePath {
            bundle = Bundle(path: bundlePath)
        } else {
            bundle = nil
        }
        
        return UIImage(named: "arrow_down", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }
}
