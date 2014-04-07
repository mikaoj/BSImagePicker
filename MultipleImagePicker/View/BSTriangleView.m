//
//  BSTriangleView.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-07.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSTriangleView.h"

@implementation BSTriangleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setColor:[UIColor blackColor]];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect currentFrame = self.bounds;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake( ceil((currentFrame.size.width/2.0) - (_pointerSize.width/2.0)), _pointerSize.height)];
    [path addLineToPoint:CGPointMake( ceil(currentFrame.size.width / 2.0), 0)];
    [path addLineToPoint:CGPointMake( ceil((currentFrame.size.width/2.0) + (_pointerSize.width/2.0)), _pointerSize.height)];
    [path closePath];
    [self.color set];
    [path fill];
}

@end
