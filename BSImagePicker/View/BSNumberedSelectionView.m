// The MIT License (MIT)
//
// Copyright (c) 2014 Joakim Gyllström
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

#import "BSNumberedSelectionView.h"

@implementation BSNumberedSelectionView

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* checkmarkBlue2 = self.tintColor;
    
    //// Shadow Declarations
    UIColor* shadow2 = [UIColor blackColor];
    CGSize shadow2Offset = CGSizeMake(0.1, -0.1);
    CGFloat shadow2BlurRadius = 2.5;
    
    //// Frames
    CGRect frame = self.bounds;
    
    //// Subframes
    CGRect group = CGRectMake(CGRectGetMinX(frame) + 3, CGRectGetMinY(frame) + 3, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6);
    
    //// CheckedOval Drawing
    UIBezierPath* checkedOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(group) + floor(CGRectGetWidth(group) * 0.00000 + 0.5), CGRectGetMinY(group) + floor(CGRectGetHeight(group) * 0.00000 + 0.5), floor(CGRectGetWidth(group) * 1.00000 + 0.5) - floor(CGRectGetWidth(group) * 0.00000 + 0.5), floor(CGRectGetHeight(group) * 1.00000 + 0.5) - floor(CGRectGetHeight(group) * 0.00000 + 0.5))];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor);
    [checkmarkBlue2 setFill];
    [checkedOvalPath fill];
    CGContextRestoreGState(context);
    
    [[UIColor whiteColor] setStroke];
    checkedOvalPath.lineWidth = 1;
    [checkedOvalPath stroke];
    
    //// Bezier Drawing (Picture Number)
	if (self.pictureNumber > 0) {
		CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
		NSString *text = [@(self.pictureNumber) stringValue];
		UIFont *font   = [UIFont boldSystemFontOfSize:13.0f];
		CGSize size    = [text sizeWithFont:font];
		[text drawInRect:CGRectMake(CGRectGetMidX(frame) - size.width / 2.0f,
									CGRectGetMidY(frame) - size.height / 2.0f,
									size.width,
									size.height)
				withFont:font
		   lineBreakMode:NSLineBreakByTruncatingTail
			   alignment:NSTextAlignmentCenter];
	}
}

- (void)setPictureNumber:(NSUInteger)pictureNumber {
    if(pictureNumber != _pictureNumber) {
        _pictureNumber = pictureNumber;
        [self setNeedsDisplay];
    }
}

@end
