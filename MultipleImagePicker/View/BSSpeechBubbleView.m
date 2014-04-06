//
//  BSSpeechBubbleView.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-06.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSSpeechBubbleView.h"

@implementation BSSpeechBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setPointerSize:CGSizeMake(14, 7)];
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self setContentView:[[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y+self.pointerSize.height, round(self.frame.size.width), round(self.frame.size.height-self.pointerSize.height))]];
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.contentView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:self.contentView];
        
        //CHANGE THESE IF YOU WANT THE ARROW TO POINT IN ANOTHER DIRECTION
//        [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
//        [self.errorLabel setTransform:CGAffineTransformMakeRotation(M_PI_2*3)];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGRect currentFrame = self.bounds;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake( ceil((currentFrame.size.width/2.0) - (_pointerSize.width/2.0)), _pointerSize.height)];
    [path addLineToPoint:CGPointMake( ceil(currentFrame.size.width / 2.0), 0)];
    [path addLineToPoint:CGPointMake( ceil((currentFrame.size.width/2.0) + (_pointerSize.width/2.0)), _pointerSize.height)];
    [path closePath];
    [[UIColor blackColor] set];
    [path fill];
}

@end
