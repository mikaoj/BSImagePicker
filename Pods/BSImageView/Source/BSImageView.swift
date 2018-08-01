// The MIT License (MIT)
//
// Copyright (c) 2018 Joakim Gyllström
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

@IBDesignable
public class BSImageView: UIView {
    private let imageView: UIImageView = UIImageView(frame: .zero)
    
    override public var isUserInteractionEnabled: Bool {
        didSet { imageView.isUserInteractionEnabled = isUserInteractionEnabled }
    }
    
    override public var tintColor: UIColor! {
        didSet { imageView.tintColor = tintColor }
    }
    
    override public var contentMode: UIViewContentMode {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(imageView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let image = imageView.image {
            imageView.frame = ImageViewLayout.frameForImageWithSize(image.size, previousFrame: imageView.frame, inContainerWithSize: bounds.size, usingContentMode: contentMode)
        } else {
            imageView.frame = .zero
        }
    }
}

// MARK: UIImageView API
extension BSImageView {
    /// See UIImageView documentation
    public convenience init(image: UIImage?) {
        self.init(frame: .zero)
        imageView.image = image
    }
    
    /// See UIImageView documentation
    public convenience init(image: UIImage?, highlightedImage: UIImage?) {
        self.init(frame: .zero)
        imageView.image = image
        imageView.highlightedImage = highlightedImage
    }
    
    /// See UIImageView documentation
    @IBInspectable
    open var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    /// See UIImageView documentation
    @IBInspectable
    open var highlightedImage: UIImage? {
        get { return imageView.highlightedImage }
        set {
            imageView.highlightedImage = newValue
        }
    }
    
    /// See UIImageView documentation
    @IBInspectable
    open var isHighlighted: Bool {
        get { return imageView.isHighlighted }
        set { imageView.isHighlighted = newValue }
    }
    
    /// See UIImageView documentation
    open var animationImages: [UIImage]? {
        get { return imageView.animationImages }
        set { imageView.animationImages = newValue }
    }
    
    /// See UIImageView documentation
    open var highlightedAnimationImages: [UIImage]? {
        get { return imageView.highlightedAnimationImages }
        set { imageView.highlightedAnimationImages = newValue }
    }
    
    /// See UIImageView documentation
    open var animationDuration: TimeInterval {
        get { return imageView.animationDuration }
        set { imageView.animationDuration = newValue }
    }
    
    /// See UIImageView documentation
    open var animationRepeatCount: Int {
        get { return imageView.animationRepeatCount }
        set { imageView.animationRepeatCount = newValue }
    }
    
    /// See UIImageView documentation
    open func startAnimating() {
        imageView.startAnimating()
    }
    
    /// See UIImageView documentation
    open func stopAnimating() {
        imageView.stopAnimating()
    }
    
    /// See UIImageView documentation
    open var isAnimating: Bool {
        get { return imageView.isAnimating }
    }
}
