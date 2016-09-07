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

/**
The photo cell.
*/
final class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectionOverlayView: UIView!
    @IBOutlet weak var selectionView: SelectionView!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoLengthLabel: UILabel!
    var videoGradient: CAGradientLayer!
    
    private lazy var dateFormatter: NSDateComponentsFormatter = {
        let formatter = NSDateComponentsFormatter()
        formatter.zeroFormattingBehavior = .Pad
        formatter.allowedUnits = [.Hour, .Minute, .Second]
        formatter.unitsStyle = .Positional
        return formatter
    }()
    
    weak var asset: PHAsset? {
        didSet {
            if let asset = asset {
                self.videoView.hidden = asset.mediaType != .Video
                self.videoLengthLabel.text = dateFormatter.stringFromTimeInterval(asset.duration)
            }
        }
    }
    
    var settings: BSImagePickerSettings {
        get {
            return selectionView.settings
        }
        set {
            selectionView.settings = newValue
        }
    }
    
    var selectionString: String {
        get {
            return selectionView.selectionString
        }
        
        set {
            selectionView.selectionString = newValue
        }
    }
    
    override var selected: Bool {
        get {
            return super.selected
        }
        
        set {
            let hasChanged = selected != newValue
            super.selected = newValue
            
            if UIView.areAnimationsEnabled() && hasChanged {
                UIView.animateWithDuration(NSTimeInterval(0.1), animations: { () -> Void in
                    // Set alpha for views
                    self.updateAlpha(newValue)
                    
                    // Scale all views down a little
                    self.transform = CGAffineTransformMakeScale(0.95, 0.95)
                    }) { (finished: Bool) -> Void in
                        UIView.animateWithDuration(NSTimeInterval(0.1), animations: { () -> Void in
                            // And then scale them back upp again to give a bounce effect
                            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                            }, completion: nil)
                }
            } else {
                updateAlpha(newValue)
            }
        }
    }
    
    private func updateAlpha(selected: Bool) {
        if selected == true {
            self.selectionView.alpha = 1.0
            self.selectionOverlayView.alpha = 0.3
        } else {
            self.selectionView.alpha = 0.0
            self.selectionOverlayView.alpha = 0.0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoGradient.frame = videoView.bounds
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        videoGradient = CAGradientLayer()
        videoGradient.frame = videoView.bounds
        videoGradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        videoView.layer.insertSublayer(videoGradient, atIndex: 0)
    }
}
