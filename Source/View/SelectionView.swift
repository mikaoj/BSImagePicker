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

/**
Used as an overlay on selected cells
*/
@IBDesignable final class SelectionView: UIView {
    @objc var selectionString: String = "" {
        didSet {
            if selectionString != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    var settings: BSImagePickerSettings = Settings()
    
    override func draw(_ rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        
        //// Shadow Declarations
        let shadow2Offset = CGSize(width: 0.1, height: -0.1);
        let shadow2BlurRadius: CGFloat = 2.5;
        
        //// Frames
        let checkmarkFrame = bounds;
        
        //// Subframes
        let group = CGRect(x: checkmarkFrame.minX + 3, y: checkmarkFrame.minY + 3, width: checkmarkFrame.width - 6, height: checkmarkFrame.height - 6)
        
        //// CheckedOval Drawing
        let checkedOvalPath = UIBezierPath(ovalIn: CGRect(x: group.minX + floor(group.width * 0.0 + 0.5), y: group.minY + floor(group.height * 0.0 + 0.5), width: floor(group.width * 1.0 + 0.5) - floor(group.width * 0.0 + 0.5), height: floor(group.height * 1.0 + 0.5) - floor(group.height * 0.0 + 0.5)))
        context?.saveGState()
        context?.setShadow(offset: shadow2Offset, blur: shadow2BlurRadius, color: settings.selectionShadowColor.cgColor)
        settings.selectionFillColor.setFill()
        checkedOvalPath.fill()
        context?.restoreGState()
        
        settings.selectionStrokeColor.setStroke()
        checkedOvalPath.lineWidth = 1
        checkedOvalPath.stroke()
        
        
        context?.setFillColor(UIColor.white.cgColor)
        
        //// Check mark for single assets
        if (settings.maxNumberOfSelections == 1) {
            context?.setStrokeColor(UIColor.white.cgColor)
            
            let checkPath = UIBezierPath()
            checkPath.move(to: CGPoint(x: 7, y: 12.5))
            checkPath.addLine(to: CGPoint(x: 11, y: 16))
            checkPath.addLine(to: CGPoint(x: 17.5, y: 9.5))
            checkPath.stroke()
            return;
        }
        
        //// Bezier Drawing (Picture Number)
        let size = selectionString.size(withAttributes: settings.selectionTextAttributes)

        selectionString.draw(in: CGRect(x: checkmarkFrame.midX - size.width / 2.0,
            y: checkmarkFrame.midY - size.height / 2.0,
            width: size.width,
            height: size.height), withAttributes: settings.selectionTextAttributes)
    }
}
