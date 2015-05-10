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

internal class AlbumTitleView: UIView {
    @IBOutlet weak var albumButton: UIButton!
    
    internal var albumTitle = "" {
        didSet {
            albumButton.setTitle(self.albumTitle, forState: .Normal)
            albumButton.setImage(arrowDownImage, forState: .Normal)
            
            // Place image to the right
            if let imageView = albumButton.imageView, let titleLabel = albumButton.titleLabel {
                albumButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView.frame.size.width, bottom: 0, right: imageView.frame.size.width)
                albumButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: titleLabel.frame.size.width, bottom: 0, right: -titleLabel.frame.size.width - 8)
            }
        }
    }
    
    internal lazy var arrowDownImage: UIImage? = {
        // Get path for BSImagePicker bundle
        let bundlePath = NSBundle(forClass: PhotosViewController.self).pathForResource("BSImagePicker", ofType: "bundle")
        let bundle: NSBundle?
        
        // Load bundle
        if let bundlePath = bundlePath {
            bundle = NSBundle(path: bundlePath)
        } else {
            bundle = nil
        }
        
        return UIImage(named: "arrow_down", inBundle: bundle, compatibleWithTraitCollection: nil)
    }()
}
