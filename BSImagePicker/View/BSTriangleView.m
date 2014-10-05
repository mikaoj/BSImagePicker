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

#import "BSTriangleView.h"

@implementation BSTriangleView

- (id)initWithFrame:(CGRect)frame andPointerSize:(CGSize)pointerSize {
    if (self = [super initWithFrame:frame]) {
        //Need a color to make it appear...
        [self setBackgroundColor:[UIColor blackColor]];
        
        // Create a mask layer and the frame to determine what will be visible in the view.
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];

        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake( ceil((frame.size.width/2.0) - (pointerSize.width/2.0)), pointerSize.height)];
        [path addLineToPoint:CGPointMake( ceil(frame.size.width / 2.0), 0)];
        [path addLineToPoint:CGPointMake( ceil((frame.size.width/2.0) + (pointerSize.width/2.0)), pointerSize.height)];
        [path closePath];
        
        // Set the path to the mask layer.
        [maskLayer setPath:path.CGPath];
        
        // Set the mask of the view.
        [self.layer setMask:maskLayer];
        
        [self setPointerSize:pointerSize];
    }
    
    return self;
}

@end
