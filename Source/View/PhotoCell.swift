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
    private let imageView = UIImageView()
    private let selectionImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
        
        selectionImageView.frame = imageView.bounds
        selectionImageView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        selectionImageView.alpha = 0.0
        imageView.addSubview(selectionImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            let animated = UIView.areAnimationsEnabled
            updateSelection(isSelected, animated: animated)
        }
    }
    
    func preview(_ previewable: Previewable, selectionImage: UIImage) {
        previewable.thumbnail(size: bounds.size, contentMode: .aspectFill) { (image) in
            self.imageView.image = image
        }
    }

    private func updateSelection(_ selected: Bool, animated: Bool) {
        // No change? Then do nothing
        guard self.selectionImageView.alpha != selected.CGFloat else { return }
        
        let animationDuration: TimeInterval
        if animated {
            animationDuration = 0.4
        } else {
            animationDuration = 0.0
        }
        
        UIView.animate(withDuration: animationDuration) { 
            self.selectionImageView.alpha = selected.CGFloat
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        isSelected = false
        tag = 0
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
