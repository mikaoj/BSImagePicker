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

#import "BSSpeechBubbleView.h"
#import "BSTriangleView.h"

@interface BSSpeechBubbleView ()

@property (nonatomic, strong) BSTriangleView *triangle;

@end

@implementation BSSpeechBubbleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setContentView:[[UIToolbar alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y+self.triangle.pointerSize.height, round(self.frame.size.width), round(self.frame.size.height-self.triangle.pointerSize.height))]];
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.contentView.layer setCornerRadius:4.0];
        [self.contentView setClipsToBounds:YES];
        [self addSubview:self.contentView];
        
        [self addSubview:self.triangle];
        
        [self.layer setCornerRadius:4.0];
        [self setClipsToBounds:NO];
    }
    return self;
}

- (BSTriangleView *)triangle {
    if(!_triangle) {
        _triangle = [[BSTriangleView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 7) andPointerSize:CGSizeMake(24, 7)];
        [_triangle setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    }
    
    return _triangle;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBarTintColor:backgroundColor];
    [self.triangle setBarTintColor:backgroundColor];
}

- (UIColor *)backgroundColor {
    return self.contentView.barTintColor;
}

@end
