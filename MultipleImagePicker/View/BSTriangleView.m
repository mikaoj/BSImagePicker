//
//  BSTriangleView.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-07.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSTriangleView.h"

@implementation BSTriangleView

- (id)initWithFrame:(CGRect)frame andPointerSize:(CGSize)pointerSize
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8]];
        
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
