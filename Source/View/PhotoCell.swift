// The MIT License (MIT)
//
// Copyright (c) 2016 Joakim Gyllström
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

class PhotoCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var selectionForegroundView: UIView!
    @IBOutlet var selectionImageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else { return }
            let animated = UIView.areAnimationsEnabled
            updateSelection(isSelected, animated: animated)
        }
    }
    
    func preview(_ previewable: Previewable, selectionImage: UIImage?) {
        previewable.thumbnail(size: bounds.size, contentMode: .aspectFill) { (image) in
            self.imageView.image = image
        }
        
        if let selectionImage = selectionImage {
            self.selectionImageView.image = selectionImage
        }
    }

    private func updateSelection(_ selected: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: TimeInterval(0.1), animations: { () -> Void in
                // Set alpha for views
                self.updateAlpha(selected: selected)

                // Scale all views down a little
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }, completion: { (finished: Bool) -> Void in
                    UIView.animate(withDuration: TimeInterval(0.1), animations: { () -> Void in
                        // And then scale them back upp again to give a bounce effect
                        self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: nil)
            })
        } else {
            self.updateAlpha(selected: selected)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateAlpha(selected: false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        tag = 0
    }

    private func updateAlpha(selected: Bool) {
        if selected == true {
            selectionImageView.alpha = 1.0
            selectionForegroundView.alpha = 0.3
        } else {
            selectionImageView.alpha = 0.0
            selectionForegroundView.alpha = 0.0
        }
    }
}

extension Bool {
    var CGFloat: CGFloat {
        if self == false {
            return 0.0
        } else {
            return 1.0
        }
    }
}
