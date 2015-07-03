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

@IBDesignable internal class SelectionView: UIView {
    var selectionString: String = "" {
        didSet {
            if selectionString != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    var fillColor: UIColor!
    var strokeColor: UIColor
    var shadowColor: UIColor
    lazy var textAttributes: [NSObject: AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByTruncatingTail
        paragraphStyle.alignment = .Center
        return [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(10.0),
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
    }()

    required init(coder aDecoder: NSCoder) {
        strokeColor = UIColor.whiteColor()
        shadowColor = UIColor.blackColor()
        
        super.init(coder: aDecoder)
        
        fillColor = tintColor
    }
    
    override func drawRect(rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        
        //// Shadow Declarations
        let shadow2Offset = CGSize(width: 0.1, height: -0.1);
        let shadow2BlurRadius: CGFloat = 2.5;
        
        //// Frames
        let checkmarkFrame = bounds;
        
        //// Subframes
        let group = CGRect(x: CGRectGetMinX(checkmarkFrame) + 3, y: CGRectGetMinY(checkmarkFrame) + 3, width: CGRectGetWidth(checkmarkFrame) - 6, height: CGRectGetHeight(checkmarkFrame) - 6)
        
        //// CheckedOval Drawing
        let checkedOvalPath = UIBezierPath(ovalInRect: CGRectMake(CGRectGetMinX(group) + floor(CGRectGetWidth(group) * 0.0 + 0.5), CGRectGetMinY(group) + floor(CGRectGetHeight(group) * 0.0 + 0.5), floor(CGRectGetWidth(group) * 1.0 + 0.5) - floor(CGRectGetWidth(group) * 0.0 + 0.5), floor(CGRectGetHeight(group) * 1.0 + 0.5) - floor(CGRectGetHeight(group) * 0.0 + 0.5)))
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadowColor.CGColor)
        fillColor.setFill()
        checkedOvalPath.fill()
        CGContextRestoreGState(context)
        
        strokeColor.setStroke()
        checkedOvalPath.lineWidth = 1
        checkedOvalPath.stroke()
        
        //// Bezier Drawing (Picture Number)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        let size = selectionString.sizeWithAttributes(textAttributes)

        selectionString.drawInRect(CGRectMake(CGRectGetMidX(checkmarkFrame) - size.width / 2.0,
            CGRectGetMidY(checkmarkFrame) - size.height / 2.0,
            size.width,
            size.height), withAttributes: textAttributes)
    }
}
