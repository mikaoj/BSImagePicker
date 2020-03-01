// The MIT License (MIT)
//
// Copyright (c) 2020 Joakim Gyllström
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

/**
Used as an overlay on selected cells
*/
class SelectionView: UIView {
    var settings: Settings!
    
    var selectionIndex: Int? {
        didSet {
            guard let numberView = icon as? NumberView, let selectionIndex = selectionIndex else { return }
            // Add 1 since selections should be 1-indexed
            numberView.text = (selectionIndex + 1).description
            setNeedsDisplay()
        }
    }
    
    private lazy var icon: UIView = {
        switch settings.theme.selectionStyle {
        case .checked:
            return CheckmarkView()
        case .numbered:
            return NumberView()
        }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
                
        //// Shadow Declarations
        let shadow2Offset = CGSize(width: 0.1, height: -0.1);
        let shadow2BlurRadius: CGFloat = 2.5;
        
        //// Frames
        let selectionFrame = bounds;
        
        //// Subframes
        let group = selectionFrame.insetBy(dx: 3, dy: 3)
        
        //// SelectedOval Drawing
        let selectedOvalPath = UIBezierPath(ovalIn: CGRect(x: group.minX + floor(group.width * 0.0 + 0.5), y: group.minY + floor(group.height * 0.0 + 0.5), width: floor(group.width * 1.0 + 0.5) - floor(group.width * 0.0 + 0.5), height: floor(group.height * 1.0 + 0.5) - floor(group.height * 0.0 + 0.5)))
        context?.saveGState()
        context?.setShadow(offset: shadow2Offset, blur: shadow2BlurRadius, color: settings.theme.selectionShadowColor.cgColor)
        settings.theme.selectionFillColor.setFill()
        selectedOvalPath.fill()
        context?.restoreGState()
        
        settings.theme.selectionStrokeColor.setStroke()
        selectedOvalPath.lineWidth = 1
        selectedOvalPath.stroke()
        
        //// Selection icon
        let largestSquareInCircleInsetRatio: CGFloat = 0.5 - (0.25 * sqrt(2))
        let dx = group.size.width * largestSquareInCircleInsetRatio
        let dy = group.size.height * largestSquareInCircleInsetRatio
        icon.frame = group.insetBy(dx: dx, dy: dy)
        icon.tintColor = settings.theme.selectionStrokeColor
        icon.draw(icon.frame)
    }
}
