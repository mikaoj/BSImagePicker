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

@IBDesignable internal class NumberedSelectionView: UIView {
    internal var pictureNumber: Int = 0 {
        didSet {
            if pictureNumber != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        // Only draw numbers greater than 0
        if pictureNumber < 1 {
            return
        }
        
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let checkmarkBlue2 = tintColor
        
        //// Shadow Declarations
        let shadow2 = UIColor.blackColor()
        let shadow2Offset = CGSize(width: 0.1, height: -0.1);
        let shadow2BlurRadius: CGFloat = 2.5;
        
        //// Frames
        let checkmarkFrame = bounds;
        
        //// Subframes
        let group = CGRect(x: CGRectGetMinX(checkmarkFrame) + 3, y: CGRectGetMinY(checkmarkFrame) + 3, width: CGRectGetWidth(checkmarkFrame) - 6, height: CGRectGetHeight(checkmarkFrame) - 6)
        
        //// CheckedOval Drawing
        let checkedOvalPath = UIBezierPath(ovalInRect: CGRectMake(CGRectGetMinX(group) + floor(CGRectGetWidth(group) * 0.0 + 0.5), CGRectGetMinY(group) + floor(CGRectGetHeight(group) * 0.0 + 0.5), floor(CGRectGetWidth(group) * 1.0 + 0.5) - floor(CGRectGetWidth(group) * 0.0 + 0.5), floor(CGRectGetHeight(group) * 1.0 + 0.5) - floor(CGRectGetHeight(group) * 0.0 + 0.5)))
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor)
        checkmarkBlue2.setFill()
        checkedOvalPath.fill()
        CGContextRestoreGState(context)
        
        UIColor.whiteColor().setStroke()
        checkedOvalPath.lineWidth = 1
        checkedOvalPath.stroke()
        
        //// Bezier Drawing (Picture Number)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        let text = String(pictureNumber)
        let font = UIFont.boldSystemFontOfSize(10.0)
        let textAttributes: [NSObject: AnyObject] = [NSFontAttributeName: font]
        let size = text.sizeWithAttributes(textAttributes)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByTruncatingTail
        paragraphStyle.alignment = .Center
        let drawAttributes: [NSObject: AnyObject] = [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        text.drawInRect(CGRectMake(CGRectGetMidX(checkmarkFrame) - size.width / 2.0,
            CGRectGetMidY(checkmarkFrame) - size.height / 2.0,
            size.width,
            size.height), withAttributes: drawAttributes)
    }
}
