//
//  BSSpeechBubbleView.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-06.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSSpeechBubbleView.h"
#import "BSTriangleView.h"


@interface BSSpeechBubbleView ()

@property (nonatomic, strong) BSTriangleView *triangle;


@end

@implementation BSSpeechBubbleView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self setContentView:[[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y+self.triangle.pointerSize.height, round(self.frame.size.width), round(self.frame.size.height-self.triangle.pointerSize.height))]];
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.contentView setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8]];
        [self.contentView.layer setCornerRadius:4.0];
        [self.contentView setClipsToBounds:YES];
        [self addSubview:self.contentView];
        
        [self addSubview:self.triangle];
        
        [self.layer setCornerRadius:4.0];
        [self setClipsToBounds:YES];
        
        //CHANGE THESE IF YOU WANT THE ARROW TO POINT IN ANOTHER DIRECTION
//        [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    }
    return self;
}

- (BSTriangleView *)triangle
{
    if(!_triangle) {
        _triangle = [[BSTriangleView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 7)];
        [_triangle setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_triangle setPointerSize:CGSizeMake(24, 7)];
        [_triangle setColor:self.contentView.backgroundColor];
    }
    
    return _triangle;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [self.contentView setBackgroundColor:backgroundColor];
    [self.triangle setColor:backgroundColor];
    [self.triangle setNeedsDisplay];
}

- (UIColor *)backgroundColor
{
    return self.contentView.backgroundColor;
}

@end
