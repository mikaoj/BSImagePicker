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

#import "BSCameraView.h"

@implementation BSCameraView

- (void)drawRect:(CGRect)rect {
    //Draw it
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(0, 2.84)];
    [bezierPath addLineToPoint: CGPointMake(0, 12.84)];
    [bezierPath addCurveToPoint: CGPointMake(2, 14.84) controlPoint1: CGPointMake(0, 14.84) controlPoint2: CGPointMake(2, 14.84)];
    [bezierPath addLineToPoint: CGPointMake(13.92, 14.84)];
    [bezierPath addCurveToPoint: CGPointMake(15.92, 12.84) controlPoint1: CGPointMake(13.92, 14.84) controlPoint2: CGPointMake(15.92, 14.84)];
    [bezierPath addLineToPoint: CGPointMake(15.92, 2.84)];
    [bezierPath addCurveToPoint: CGPointMake(13.92, 0.84) controlPoint1: CGPointMake(15.92, 0.84) controlPoint2: CGPointMake(13.92, 0.84)];
    [bezierPath addLineToPoint: CGPointMake(2, 0.84)];
    [bezierPath addCurveToPoint: CGPointMake(0, 2.84) controlPoint1: CGPointMake(2, 0.84) controlPoint2: CGPointMake(0, 0.84)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(17.08, 10.97)];
    [bezierPath addLineToPoint: CGPointMake(22, 14.84)];
    [bezierPath addLineToPoint: CGPointMake(22, 0.84)];
    [bezierPath addLineToPoint: CGPointMake(17.08, 4.74)];
    [bezierPath addLineToPoint: CGPointMake(17.08, 10.97)];
    [bezierPath closePath];
    [bezierPath setMiterLimit:4];
    
    //Scale it (22 and 16 is the original width and height)
    CGFloat scale = MIN(self.bounds.size.width/22.0, self.bounds.size.height/16.0);
    [bezierPath applyTransform:CGAffineTransformMakeScale(scale, scale)];
    
    //Fill it
    [self.color setFill];
    [bezierPath fill];
}

@end
