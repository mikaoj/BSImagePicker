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
        [self addSubview:self.triangle];
        
        [self setContentView:[[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y+self.triangle.pointerSize.height, round(self.frame.size.width), round(self.frame.size.height-self.triangle.pointerSize.height))]];
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.contentView setBackgroundColor:[UIColor blueColor]];
        [self addSubview:self.contentView];
        
        //CHANGE THESE IF YOU WANT THE ARROW TO POINT IN ANOTHER DIRECTION
//        [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    }
    return self;
}

- (BSTriangleView *)triangle
{
    if(!_triangle) {
        _triangle = [[BSTriangleView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 7)];
        [_triangle setPointerSize:CGSizeMake(14, 7)];
        [_triangle setColor:[UIColor blueColor]];
    }
    
    return _triangle;
}

@end
