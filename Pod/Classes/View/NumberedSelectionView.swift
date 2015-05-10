//
//  NumberedSelectionView.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-05-10.
//
//

import UIKit

@IBDesignable internal class NumberedSelectionView: UIView {
    internal var pictureNumber: Int = 1 {
        didSet {
            if pictureNumber != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let checkmarkBlue2 = tintColor
        
        //// Shadow Declarations
        let shadow2 = UIColor.blackColor()
        let shadow2Offset = CGSize(width: 0.1, height: -0.1);
        let shadow2BlurRadius: CGFloat = 2.5;
        
        //// Frames
        let checkmarkFrame = self.bounds;
        
        //// Subframes
        let group = CGRect(x: CGRectGetMinX(checkmarkFrame) + 3, y: CGRectGetMinY(checkmarkFrame) + 3, width: CGRectGetWidth(checkmarkFrame) - 6, height: CGRectGetHeight(checkmarkFrame) - 6)
        
        //// CheckedOval Drawing
        let checkedOvalPath = UIBezierPath(ovalInRect: CGRectMake(CGRectGetMinX(group) + floor(CGRectGetWidth(group) * 0.00000 + 0.5), CGRectGetMinY(group) + floor(CGRectGetHeight(group) * 0.00000 + 0.5), floor(CGRectGetWidth(group) * 1.00000 + 0.5) - floor(CGRectGetWidth(group) * 0.00000 + 0.5), floor(CGRectGetHeight(group) * 1.00000 + 0.5) - floor(CGRectGetHeight(group) * 0.00000 + 0.5)))
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor)
        checkmarkBlue2.setFill()
        checkedOvalPath.fill()
        CGContextRestoreGState(context)
        
        UIColor.whiteColor().setStroke()
        checkedOvalPath.lineWidth = 1
        checkedOvalPath.stroke()
        
        //// Bezier Drawing (Picture Number)
        if (pictureNumber > 0) {
            CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
            let text = String(pictureNumber)
            let font = UIFont.boldSystemFontOfSize(13.0)
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
}
